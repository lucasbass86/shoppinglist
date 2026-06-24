import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shoppinglist/models/models.dart';
import 'package:shoppinglist/pages/_pages.dart';
import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/sharedpreferences/preferences.dart';
import 'package:shoppinglist/utils/enums.dart';
import 'package:shoppinglist/utils/utils.dart';
import 'package:shoppinglist/widgets/various/calculator_widget.dart';
import 'package:shoppinglist/widgets/decorations/marquee_widget.dart';

Future<dynamic> showMessage(
    {required BuildContext context,
    required String message,
    String secondMessage = '',
    bool hideTitle = false,
    bool cancel = false}) {
  return showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        backgroundColor: Utils.claro,
        title: !hideTitle
            ? Text("Información", style: TextStyle(color: Utils.oscuro))
            : SizedBox.shrink(),
        content: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message, style: TextStyle(color: Utils.oscuro)),
              if (secondMessage.isNotEmpty)
                Text(secondMessage, style: TextStyle(color: Utils.oscuro, fontSize: 19)),
            ],
          ),
        ),
        titleTextStyle: TextStyle(fontWeight: FontWeight.bold, color: Utils.oscuro, fontSize: 27),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        actions: [
          if (cancel)
            OutlinedButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.resolveWith((states) => Utils.oscuro),
              ),
              child: const Text('Cancelar'),
            ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith((states) => Utils.oscuro),
            ),
            child: const Text('Aceptar'),
          ),
        ],
      );
    },
  ).then((onValue) => onValue ?? false);
}

Future<dynamic> showShops(BuildContext context,
    {Product? product, bool showQuantity = true, int quantity = 1}) {
  MainProvider mainProvider = Provider.of<MainProvider>(context, listen: false);
  String shopName = mainProvider.selectedShop.name;
  int cantidad = quantity;

  if (!Preferences.isOrderShopByName && product != null) {
    final Map<int, int> shopQuantities = {};
    final Set<int> shopIds = mainProvider.shops.map((shop) => shop.id).toSet();

    // Comprobar si hay alguna compra ya hecha de ese producto.
    if (mainProvider.shoppingHistory.any((p) => p.product.id == product.id)) {
      // Agrupar cantidades por Shop para el Product específico
      for (final history in mainProvider.shoppingHistory) {
        if (shopIds.contains(history.shop.id) && history.product.id == product.id) {
          shopQuantities.update(
            history.shop.id,
            (value) => value + history.quantity,
            ifAbsent: () => history.quantity,
          );
        }
      }

      final sorted = shopQuantities.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

      // Ordenar shopList descendentemente según la cantidad total
      mainProvider.shops.sort((a, b) {
        final quantityA = shopQuantities[a.id] ?? 0;
        final quantityB = shopQuantities[b.id] ?? 0;
        return quantityB.compareTo(quantityA);
      });
      shopName = mainProvider.shops.firstWhere((s) => s.id == sorted.first.key).name;
    }
  }

  return showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        backgroundColor: Utils.claro,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        title: Text("Indica la tienda", style: TextStyle(color: Utils.oscuro)),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  DropdownButton(
                    isExpanded: true,
                    value: shopName,
                    elevation: 16,
                    style: TextStyle(fontSize: 20, color: Utils.oscuro),
                    underline: Container(
                      height: 2,
                    ),
                    onChanged: (String? value) {
                      setState(() {
                        shopName = value!;
                        mainProvider.nameSelectedShop = shopName;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    items: mainProvider.shops.map<DropdownMenuItem<String>>((Shop shop) {
                      return DropdownMenuItem<String>(
                        value: shop.name,
                        child: Text(shop.name),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 15),
                  if (showQuantity)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Utils.oscuro,
                            borderRadius: const BorderRadius.all(Radius.circular(15)),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              if (cantidad > 1) {
                                setState(() {
                                  cantidad--;
                                  ProductsPage.controllerDialog.reset();
                                });
                              }
                            },
                            child: Icon(Icons.remove, color: Utils.claro),
                          ),
                        ),
                        const SizedBox(width: 25),
                        BounceInDown(
                          from: 30,
                          controller: (controller) {
                            ProductsPage.controllerDialog = controller;
                          },
                          child: Text(
                            cantidad.toString(),
                            style: TextStyle(
                                fontSize: 50, color: Utils.oscuro, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 25),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Utils.oscuro,
                            borderRadius: const BorderRadius.all(Radius.circular(15)),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                cantidad++;
                                ProductsPage.controllerDialog.reset();
                              });
                            },
                            child: Icon(Icons.add, color: Utils.claro),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            );
          },
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(dialogContext).pop([false]),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              mainProvider.nameSelectedShop = shopName;
              if (mainProvider.borrarBusqueda) mainProvider.searchText = '';
              Navigator.of(dialogContext).pop([true, cantidad, shopName]);
            },
            child: const Text('Aceptar'),
          ),
        ],
      );
    },
  ).then((value) => value ?? [false]);
}

Future<dynamic> showChangeCartShop(BuildContext context, Shop oldShop) {
  MainProvider mainProvider = Provider.of<MainProvider>(context, listen: false);
  List<Shop> shops = mainProvider.shops.map((e) => e).toSet().toList();
  shops.removeWhere((s) => s.id == oldShop.id);
  Shop sH = shops[0];
  String shopName = sH.name;
  return showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        backgroundColor: Utils.claro,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        title: Text("Indica la tienda", style: TextStyle(color: Utils.oscuro)),
        content: StatefulBuilder(
          builder: (context, setState) {
            return DropdownButton(
              isExpanded: true,
              value: sH,
              elevation: 16,
              style: TextStyle(fontSize: 20, color: Utils.oscuro),
              underline: Container(
                height: 2,
              ),
              // onChanged: (Shop value) {
              //   setState(() {
              //     shopName = value!;
              //     mainProvider.nameSelectedShop = shopName;
              //   });
              // },
              onChanged: <Shop>(value) {
                setState(
                  () {
                    sH = value;
                  },
                );
              },
              borderRadius: BorderRadius.circular(20),
              items: shops.map<DropdownMenuItem<Shop>>((Shop shop) {
                return DropdownMenuItem<Shop>(
                  value: shop,
                  child: Text(shop.name),
                );
              }).toList(),
            );
          },
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(dialogContext).pop([false]),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              mainProvider.nameSelectedShop = shopName;
              if (mainProvider.borrarBusqueda) mainProvider.searchText = '';
              Navigator.of(dialogContext).pop([true, sH]);
            },
            child: const Text('Aceptar'),
          ),
        ],
      );
    },
  ).then((value) => value);
}

Future<dynamic> showProductPrice(BuildContext context, ProductShop productShop,
    {bool isFromShopping = false}) {
  TextEditingController controller =
      TextEditingController(text: productShop.price.toStringAsFixed(2));
  double price = productShop.price;
  return showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        backgroundColor: Utils.claro,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        title: Text('Precio en ${productShop.shop.name}', style: TextStyle(color: Utils.oscuro)),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Row(
              children: [
                Expanded(
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      if (value.isNotEmpty) price = double.tryParse(value)!;
                    },
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: '${productShop.price}',
                      fillColor: Utils.claro,
                      filled: true,
                      counterText: '',
                    ),
                    maxLength: 6,
                    cursorColor: Utils.oscuro,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(Utils.regNumeroDecimal),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () async {
                    final resp = await calculator(context, quantity: price);
                    if (resp[0]) {
                      controller.text = (resp[1] as double).toStringAsFixed(2);
                      price = resp[1];
                    }
                  },
                  child: Icon(
                    Icons.calculate,
                    color: Utils.oscuro,
                    size: 40,
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(dialogContext).pop([false]),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (price == 0 && !isFromShopping) {
                Navigator.of(dialogContext).pop([false, 0]);
              } else {
                if (!isFromShopping) {
                  productShop.price = price;
                }
                Navigator.of(dialogContext).pop([true, price]);
              }
            },
            child: const Text('Aceptar'),
          ),
        ],
      );
    },
  ).then((value) => value ?? [false]);
}

Future<dynamic> showPrice(BuildContext context, String title, double price) {
  TextEditingController controller = TextEditingController(text: price.toStringAsFixed(2));
  return showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        backgroundColor: Utils.claro,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        title: Text(title, style: TextStyle(color: Utils.oscuro)),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Row(
              children: [
                Expanded(
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      if (value.isNotEmpty) price = double.tryParse(value)!;
                    },
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: '$price',
                      fillColor: Utils.claro,
                      filled: true,
                      counterText: '',
                    ),
                    maxLength: 6,
                    cursorColor: Utils.oscuro,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(Utils.regNumeroDecimal),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () async {
                    final resp = await calculator(context, quantity: price);
                    if (resp[0]) {
                      controller.text = (resp[1] as double).toStringAsFixed(2);
                      price = resp[1];
                    }
                  },
                  child: Icon(
                    Icons.calculate,
                    color: Utils.oscuro,
                    size: 40,
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(dialogContext).pop([false]),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop([true, price]),
            child: const Text('Aceptar'),
          ),
        ],
      );
    },
  ).then((value) => value ?? [false]);
}

Future<dynamic> confirmDeleteCart(BuildContext context, Cart cart) {
  return showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        backgroundColor: Utils.claro,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        title:
            Text('¿Borrar la lista de ${cart.shop.name}?', style: TextStyle(color: Utils.oscuro)),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(true);
            },
            child: const Text('Aceptar'),
          ),
        ],
      );
    },
  );
}

Future<dynamic> confirmDeleteAll(BuildContext context) {
  return showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        backgroundColor: Utils.claro,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        title: Text('¿Borrar todos los datos?', style: TextStyle(color: Utils.oscuro)),
        content: Text('No se podrán recuperar!', style: TextStyle(color: Utils.oscuro)),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(true);
            },
            child: const Text('Aceptar'),
          ),
        ],
      );
    },
  );
}

Future<dynamic> newShop(BuildContext context) {
  MainProvider mainProvider = Provider.of<MainProvider>(context, listen: false);
  TextEditingController controller = TextEditingController();
  String name = '';
  return showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        backgroundColor: Utils.claro,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        title: Text('Introduce el nombre de la tienda', style: TextStyle(color: Utils.oscuro)),
        content: StatefulBuilder(
          builder: (context, setState) {
            return TextFormField(
              onChanged: (value) {
                if (value.isNotEmpty) name = value;
              },
              controller: controller,
              decoration: InputDecoration(
                fillColor: Utils.claro,
                filled: true,
                counterText: '',
              ),
              maxLength: 50,
              cursorColor: Utils.oscuro,
              textCapitalization: TextCapitalization.words,
            );
          },
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (name.isEmpty) {
                Utils.snackBarOverlay(context, 'Indica el nombre de la tienda', isGood: false);
                return;
              }
              mainProvider.addShop(name.trim());
              Navigator.of(dialogContext).pop(true);
            },
            child: const Text('Aceptar'),
          ),
        ],
      );
    },
  );
}

Future<bool> confirmDelete(BuildContext context, String title) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        backgroundColor: Utils.claro,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        title: Text(title, style: TextStyle(color: Utils.oscuro)),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Aceptar'),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

Future<dynamic> changeShopName(BuildContext context, Shop shop) {
  TextEditingController controller = TextEditingController(text: shop.name);
  return showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        backgroundColor: Utils.claro,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        title: Text('Editar el nombre', style: TextStyle(color: Utils.oscuro)),
        content: StatefulBuilder(
          builder: (context, setState) {
            return TextFormField(
              controller: controller,
              decoration: InputDecoration(
                hintText: shop.name,
                fillColor: Utils.claro,
                filled: true,
              ),
              maxLength: 50,
              cursorColor: Utils.oscuro,
            );
          },
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              shop.name = controller.text;
              Navigator.of(dialogContext).pop(true);
            },
            child: const Text('Aceptar'),
          ),
        ],
      );
    },
  );
}

Future<dynamic> changeProductName(BuildContext context, Product product) {
  TextEditingController controllerName = TextEditingController(text: product.name);
  TextEditingController controllerDetail = TextEditingController(text: product.details);
  return showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        backgroundColor: Utils.claro,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        title: Text('Editar el producto', style: TextStyle(color: Utils.oscuro)),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SizedBox(
              height: 185,
              child: Column(
                children: [
                  TextFormField(
                    controller: controllerName,
                    decoration: InputDecoration(
                      hintText: product.name,
                      fillColor: Utils.claro,
                      filled: true,
                    ),
                    maxLength: 50,
                    cursorColor: Utils.oscuro,
                  ),
                  TextFormField(
                    controller: controllerDetail,
                    decoration: InputDecoration(
                      hintText: product.details,
                      fillColor: Utils.claro,
                      filled: true,
                    ),
                    maxLength: 150,
                    cursorColor: Utils.oscuro,
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              product.name = controllerName.text;
              product.details = controllerDetail.text;
              Navigator.of(dialogContext).pop(true);
            },
            child: const Text('Aceptar'),
          ),
        ],
      );
    },
  ).then((value) => value);
}

Future<dynamic> addShopPrice(BuildContext context, Product product) {
  MainProvider mainProvider = Provider.of<MainProvider>(context, listen: false);
  List<Shop> tiendasDisponibles = [];
  for (Shop s in mainProvider.shops) {
    bool exists = false;
    for (ProductShop p in mainProvider.productsShops) {
      if (p.shop.id == s.id && p.product.id == product.id) {
        exists = true;
        break;
      }
    }
    if (!exists) {
      tiendasDisponibles.add(s);
    }
  }
  String shopName = '';
  for (Shop s in tiendasDisponibles) {
    if (s.name == mainProvider.nameSelectedShop) {
      shopName = mainProvider.nameSelectedShop;
      break;
    }
  }
  if (shopName.isEmpty) shopName = tiendasDisponibles[0].name;

  return showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        backgroundColor: Utils.claro,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        title: Text("Indica la tienda", style: TextStyle(color: Utils.oscuro)),
        content: StatefulBuilder(
          builder: (context, setState) {
            return DropdownButton(
              isExpanded: true,
              value: shopName,
              elevation: 16,
              style: TextStyle(fontSize: 20, color: Utils.oscuro),
              underline: Container(
                height: 2,
              ),
              onChanged: (String? value) {
                setState(() {
                  shopName = value!;
                });
              },
              borderRadius: BorderRadius.circular(20),
              items: tiendasDisponibles.map<DropdownMenuItem<String>>((Shop shop) {
                return DropdownMenuItem<String>(
                  value: shop.name,
                  child: Text(shop.name),
                );
              }).toList(),
            );
          },
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              mainProvider.nameSelectedShop = shopName;
              Navigator.of(dialogContext).pop(true);
            },
            child: const Text('Aceptar'),
          ),
        ],
      );
    },
  ).then((value) => value);
}

Future<dynamic> addShopPriceFromShop(BuildContext context, Shop shop) {
  MainProvider mainProvider = Provider.of<MainProvider>(context, listen: false);
  List<Product> productosDisponibles = [];
  for (Product p in mainProvider.products) {
    bool exists = false;
    for (ProductShop ps in mainProvider.productsShops) {
      if (p.id == ps.product.id && ps.shop.id == shop.id) {
        exists = true;
        break;
      }
    }
    if (!exists) {
      productosDisponibles.add(p);
    }
  }
  productosDisponibles.sort((a, b) => a.name.compareTo(b.name));
  String productId = productosDisponibles[0].id.toString();
  return showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        backgroundColor: Utils.claro,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        title: Text("Indica el producto", style: TextStyle(color: Utils.oscuro)),
        content: StatefulBuilder(
          builder: (context, setState) {
            return DropdownButton(
              isExpanded: true,
              value: productId,
              elevation: 16,
              style: TextStyle(fontSize: 20, color: Utils.oscuro),
              underline: Container(
                height: 2,
              ),
              onChanged: (String? value) => setState(() => productId = value!),
              borderRadius: BorderRadius.circular(20),
              items: productosDisponibles.map<DropdownMenuItem<String>>((Product product) {
                return DropdownMenuItem<String>(
                  value: product.id.toString(),
                  child: Text(product.name),
                );
              }).toList(),
            );
          },
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(dialogContext).pop([false]),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(
                  [true, mainProvider.products.where((p) => p.id.toString() == productId).first]);
            },
            child: const Text('Aceptar'),
          ),
        ],
      );
    },
  ).then((value) => value);
}

Future<dynamic> showDeleteHistorico(BuildContext context, PriceHistory historicoPrecio) {
  return showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        backgroundColor: Utils.claro,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        title: Text('¿Eliminar del histórico?', style: TextStyle(color: Utils.oscuro)),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(true);
            },
            child: const Text('Aceptar'),
          ),
        ],
      );
    },
  ).then((value) => value);
}

Future<DateTime?> showDate(BuildContext context, {DateTime? initialDate}) {
  return showDatePicker(
    context: context,
    initialDate: initialDate ?? DateTime.now(),
    firstDate: DateTime(1986, 4, 21),
    lastDate: DateTime(DateTime.now().year, 12, 31),
    cancelText: 'Cancelar',
    confirmText: 'Aceptar',
    helpText: 'Indica la fecha',
    initialEntryMode: DatePickerEntryMode.calendarOnly,
  );
}

Future<bool> showSlideToUnlock(
  BuildContext context, {
  Color backColor = const Color.fromRGBO(224, 224, 224, 1),
  Color slideColor = Colors.blue,
  String text = 'Desliza para confirmar',
  Color textColor = Colors.white,
  IconData iconData = Icons.arrow_forward,
}) async {
  final unlocked = await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      double offset = 0.0;
      bool unlocked0 = false;
      return StatefulBuilder(
        builder: (context, setState) {
          final width = MediaQuery.of(context).size.width - 32;
          final maxOffset = width - 80;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: backColor,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Opacity(
                        opacity: 1.0 - (offset / maxOffset),
                        child: Text(
                          text,
                          style: TextStyle(color: textColor),
                        ),
                      ),
                    ),
                    Positioned(
                      left: offset,
                      child: GestureDetector(
                        onHorizontalDragUpdate: (details) {
                          setState(() {
                            offset += details.delta.dx;
                            if (offset < 0) offset = 0;
                            if (offset > maxOffset) offset = maxOffset;
                          });
                        },
                        onHorizontalDragEnd: (_) {
                          if (offset > maxOffset * 0.9) {
                            setState(() {
                              unlocked0 = true;
                              offset = maxOffset;
                            });
                            Navigator.of(context).pop(true);
                          } else {
                            setState(() {
                              offset = 0;
                            });
                          }
                        },
                        child: Container(
                          width: 80,
                          height: 60,
                          decoration: BoxDecoration(
                            color: unlocked0 ? Colors.green : slideColor,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          alignment: Alignment.center,
                          child: unlocked0
                              ? Icon(Icons.check_rounded, color: Colors.green[900])
                              : Icon(iconData, color: Colors.white),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
  return unlocked == true;
}

Future<dynamic> showAddProduct(BuildContext context) {
  MainProvider mainProvider = Provider.of(context, listen: false);
  final TextEditingController controller = TextEditingController();
  Product? selectedProduct;
  int cantidad = 1;
  return showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return SizedBox(
        width: double.infinity,
        child: StatefulBuilder(
          builder: (context, setState) {
            List<Product> products = [];
            if (controller.text.isEmpty) {
              products = mainProvider.products;
            } else {
              products = mainProvider.products
                  .where((p) => Utils.quitarTildes(p.name.toUpperCase())
                      .contains(Utils.quitarTildes(controller.text.trim().toUpperCase())))
                  .toList();
              products.sort((a, b) => a.name.compareTo(b.name));
            }
            switch (mainProvider.orderType) {
              case EOrderType.az:
                products.sort((a, b) => a.name.toUpperCase().compareTo(b.name.toUpperCase()));
                break;
              case EOrderType.za:
                products.sort((a, b) => b.name.toUpperCase().compareTo(a.name.toUpperCase()));
                break;
              case EOrderType.taz:
                products.sort((a, b) =>
                    a.imageType.name.toUpperCase().compareTo(b.imageType.name.toUpperCase()));
                break;
              case EOrderType.tza:
                products.sort((a, b) =>
                    b.imageType.name.toUpperCase().compareTo(a.imageType.name.toUpperCase()));
                break;
              case EOrderType.used:
                Map<int, int> grouped = {};
                for (var sh in mainProvider.shoppingHistory) {
                  final id = sh.product.id;
                  grouped[id] = (grouped[id] ?? 0) + sh.quantity;
                }
                grouped = Map.fromEntries(
                    grouped.entries.toList()..sort((a, b) => b.value.compareTo(a.value)));

                products.sort((a, b) {
                  final ca = grouped[a.id] ?? 0;
                  final cb = grouped[b.id] ?? 0;
                  return cb.compareTo(ca);
                });
                break;
            }
            return AlertDialog(
              backgroundColor: Utils.claro,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Elige Producto', style: mainProvider.titleStyle),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Utils.oscuro,
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                    ),
                    child: GestureDetector(
                      onTap: () async {
                        await Navigator.pushNamed(context, NewProductPage.routeName);
                        setState(() {});
                      },
                      child: Icon(Icons.add, color: Utils.claro),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      height: 45,
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white54,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Utils.oscuro),
                      ),
                      child: TextFormField(
                        onChanged: (value) => setState(() {}),
                        onTapOutside: (event) => FocusScope.of(context).unfocus(),
                        cursorColor: Utils.oscuro,
                        controller: controller,
                        style: mainProvider.itemStyle,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search, color: Utils.oscuro),
                          suffixIcon: controller.text.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    setState(
                                      () {
                                        controller.clear();
                                        products = mainProvider.products;
                                      },
                                    );
                                  },
                                  child: Icon(Icons.close))
                              : const SizedBox.shrink(),
                          border: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          hintText: 'Buscar . . .',
                          hintStyle: TextStyle(fontSize: 15.0, color: Utils.medio),
                          isCollapsed: true,
                        ),
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SizedBox(
                        height: 100,
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: products.isNotEmpty
                            ? ListView.builder(
                                scrollDirection: Axis.horizontal,
                                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                                physics: const BouncingScrollPhysics(),
                                itemCount: products.length,
                                itemBuilder: (context, index) {
                                  final Product product = products[index];
                                  final bool isSelected = product.id == selectedProduct?.id;
                                  return GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      setState(() {
                                        selectedProduct = product;
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 10),
                                      padding: const EdgeInsets.all(5),
                                      height: 100,
                                      width: 100,
                                      decoration: BoxDecoration(
                                        color: isSelected ? Utils.medio : Utils.claro,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isSelected ? Utils.claro : Utils.oscuro,
                                          width: 2,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Image(
                                              image: product.imageType.image(),
                                              width: 50,
                                              height: 50),
                                          const SizedBox(height: 3),
                                          MarqueeWidget(
                                            child: Text(
                                              product.name +
                                                  (product.details.isNotEmpty
                                                      ? ' (${product.details})'
                                                      : ''),
                                              style: mainProvider.itemStyle.copyWith(
                                                  fontSize: 13,
                                                  color: isSelected ? Utils.claro : Utils.oscuro),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Center(child: Text('Sin resultados', style: mainProvider.titleStyle)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (products.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Utils.oscuro,
                              borderRadius: const BorderRadius.all(Radius.circular(15)),
                            ),
                            child: GestureDetector(
                              onTap: () {
                                if (cantidad > 1) {
                                  setState(() {
                                    cantidad--;
                                    ProductsPage.controllerDialog.reset();
                                  });
                                }
                              },
                              child: Icon(Icons.remove, color: Utils.claro),
                            ),
                          ),
                          const SizedBox(width: 25),
                          BounceInDown(
                            from: 30,
                            controller: (controller) {
                              ProductsPage.controllerDialog = controller;
                            },
                            child: Text(
                              cantidad.toString(),
                              style: TextStyle(
                                  fontSize: 50, color: Utils.oscuro, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 25),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Utils.oscuro,
                              borderRadius: const BorderRadius.all(Radius.circular(15)),
                            ),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  cantidad++;
                                  ProductsPage.controllerDialog.reset();
                                });
                              },
                              child: Icon(Icons.add, color: Utils.claro),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              actions: [
                OutlinedButton(
                  onPressed: () => Navigator.of(dialogContext).pop([false]),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedProduct != null) {
                      Navigator.of(dialogContext).pop([true, selectedProduct, cantidad]);
                    } else if (products.length == 1) {
                      Navigator.of(dialogContext).pop([true, products[0], cantidad]);
                    } else {
                      Utils.snackBarOverlay(context, 'Falta indicar la cantidad', isGood: false);
                    }
                  },
                  child: const Text('Aceptar'),
                ),
              ],
            );
          },
        ),
      );
    },
  ).then((value) => value ?? [false]);
}

Future<dynamic> password(BuildContext context, {String title = 'Introduce el password'}) {
  MainProvider mainProvider = Provider.of(context, listen: false);
  final TextEditingController edPassword = TextEditingController();
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (_) {
      return BounceInDown(
        child: AlertDialog(
          backgroundColor: Utils.claro,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          title: Text(title, style: mainProvider.itemStyle),
          content: StatefulBuilder(
            builder: (context, setState) {
              return TextFormField(
                onChanged: (value) {},
                controller: edPassword,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password';
                  }
                  return null;
                },
                decoration: InputDecoration(hintText: 'Password'),
              );
            },
          ),
          actions: [
            OutlinedButton(
                onPressed: () => Navigator.of(context).pop([false]), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop([true, edPassword.text]);
              },
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    },
  );
}

Future<dynamic> inputDialog(BuildContext context, String title) {
  MainProvider mainProvider = Provider.of(context, listen: false);
  final TextEditingController controller = TextEditingController();
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (_) {
      return BounceInDown(
        child: AlertDialog(
          backgroundColor: Utils.claro,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          title: Text(title, style: mainProvider.itemStyle),
          content: StatefulBuilder(
            builder: (context, setState) {
              return TextFormField(
                onChanged: (value) {},
                controller: controller,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Valor';
                  }
                  return null;
                },
                decoration: InputDecoration(hintText: 'Valor'),
              );
            },
          ),
          actions: [
            OutlinedButton(
                onPressed: () => Navigator.of(context).pop([false]), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop([true, controller.text]);
              },
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    },
  );
}

Future<dynamic> calculator(BuildContext context, {double? quantity}) {
  double res = 0;
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Utils.claro,
        insetPadding: EdgeInsets.zero,
        // contentPadding: EdgeInsets.zero,
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.85,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CalculatorWidget(quantity: quantity, onResult: (double result) => res = result),
              const SizedBox(height: 20),
            ],
          ),
        ),
        actions: [
          OutlinedButton(onPressed: () => Navigator.pop(context, [false]), child: Text('Cancelar')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, [true, res]), child: Text('Aceptar'))
        ],
      );
    },
  ).then((r) => r ?? [false]);
}
