import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:shoppinglist/dialogs/dialogs.dart';
import 'package:shoppinglist/models/models.dart';
import 'package:shoppinglist/pages/_pages.dart';
import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/utils/enums.dart';
import 'package:shoppinglist/utils/utils.dart';
import 'package:shoppinglist/widgets/_widgets.dart';

class HistoryDetailPage extends StatefulWidget {
  static const String routeName = 'HistoryDetailPage';
  const HistoryDetailPage({super.key});

  @override
  State<HistoryDetailPage> createState() => _HistoryDetailPageState();
}

class _HistoryDetailPageState extends State<HistoryDetailPage> {
  late List<ShoppingHistory> group;
  @override
  Widget build(BuildContext context) {
    MainProvider mainProvider = Provider.of(context);
    group = ModalRoute.of(context)!.settings.arguments as List<ShoppingHistory>;
    group.sort((a, b) => a.order.compareTo(b.order));
    final int totalQuantity = group.fold(0, (sum, item) => sum + item.quantity);
    final double totalPrice =
        group.fold<double>(0, (sum, item) => sum + (item.quantity * item.price));
    return Scaffold(
      floatingActionButton: _fab(context, mainProvider, group),
      body: Stack(
        children: [
          BackgroundWidget(),
          Column(
            children: [
              TopWidget(showBack: true, title: 'Detalle Compra', showCart: false, showExit: true),
              if (group.isNotEmpty)
                Expanded(
                  child: Card(
                    color: Utils.claro,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    borderOnForeground: false,
                    margin: const EdgeInsets.all(10),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Image.asset(Utils.assetShop, width: 30, height: 30),
                                  const SizedBox(width: 10),
                                  Text(group[0].shop.name, style: mainProvider.titleStyle),
                                ],
                              ),
                              Row(
                                spacing: 10,
                                children: [
                                  InkWell(
                                      splashColor: Utils.medio,
                                      borderRadius: BorderRadius.circular(20),
                                      onTap: () async {
                                        final date =
                                            await showDate(context, initialDate: group[0].date);
                                        if (date != null && !Utils.isSameDay(date, group[0].date)) {
                                          for (ShoppingHistory history in group) {
                                            history.date = date;
                                            await Utils.boxShoppingHistory
                                                .put(history.id, history.toJson());
                                          }
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(Utils.snackBar('Fecha cambiada'));
                                          }
                                        }
                                      },
                                      child: Icon(Icons.calendar_month,
                                          color: Utils.oscuro, size: 30)),
                                  InkWell(
                                      splashColor: Utils.medio,
                                      borderRadius: BorderRadius.circular(20),
                                      onTap: () => showMessage(
                                          context: context,
                                          message:
                                              'Arrastrando desde el icono de la izquierda puedas cambiar el orden'),
                                      child: Icon(Icons.info_outline_rounded,
                                          color: Utils.oscuro, size: 30)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: ReorderableListView(
                              shrinkWrap: true,
                              physics: const BouncingScrollPhysics(),
                              onReorder: (int oldIndex, int newIndex) {
                                setState(() {
                                  if (newIndex > oldIndex) {
                                    newIndex -= 1;
                                  }
                                  final ShoppingHistory item = group.removeAt(oldIndex);
                                  item.order = newIndex;
                                  mainProvider.updateShoppingHistory(item);
                                  group.insert(newIndex, item);
                                  if (newIndex < oldIndex) {
                                    for (int i = newIndex + 1; i < group.length; i++) {
                                      final history = group[i];
                                      history.order = i;
                                      mainProvider.updateShoppingHistory(history);
                                    }
                                  } else {
                                    for (int i = oldIndex; i < newIndex; i++) {
                                      final history = group[i];
                                      history.order = i;
                                      mainProvider.updateShoppingHistory(history);
                                    }
                                  }
                                });
                              },
                              proxyDecorator:
                                  (Widget child, int index, Animation<double> animation) {
                                return AnimatedBuilder(
                                  animation: animation,
                                  builder: (context, child) {
                                    final double animValue =
                                        Curves.easeInOut.transform(animation.value);
                                    return Transform.scale(
                                      scale: 1.0 + animValue * 0.01,
                                      child: Material(
                                        elevation: 12 * animValue,
                                        borderRadius: BorderRadius.circular(20.0),
                                        color: Utils.medio.withAlpha(130),
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Utils.oscuro),
                                            borderRadius: BorderRadius.circular(20.0),
                                          ),
                                          child: child,
                                        ),
                                      ),
                                    );
                                  },
                                  child: child,
                                );
                              },
                              children: List.generate(
                                group.length,
                                (index) {
                                  late Color? c;
                                  if (group[index].price == 0) {
                                    c = Colors.red[800]!.withAlpha(175);
                                  } else if (group[index].price !=
                                      // _getProductPrice(
                                      //     mainProvider, group[index].product, group[index].shop)
                                      mainProvider.getProductPrice(
                                          group[index].product, group[index].shop)) {
                                    c = Colors.blue[800]!.withAlpha(175);
                                  } else {
                                    c = Utils.oscuro;
                                  }
                                  return Container(
                                    // key: ValueKey(group[index]),
                                    key: ValueKey(group[index].id),
                                    margin: const EdgeInsets.symmetric(vertical: 1.5),
                                    child: Row(
                                      children: [
                                        ReorderableDragStartListener(
                                          index: index,
                                          child: popupMenuButton(
                                              context, mainProvider, group, group[index]),
                                        ),
                                        Expanded(
                                          child: InkWell(
                                            splashColor: Utils.oscuro,
                                            borderRadius: BorderRadius.circular(20),
                                            onTap: () {
                                              //OBTENER EL PRODUCTO ORIGINAL:
                                              Product product = mainProvider.products.firstWhere(
                                                  (p) => p.id == group[index].product.id);
                                              Navigator.pushNamed(context, ProductPage.routeName,
                                                  arguments: product);
                                              // Navigator.pushNamed(context, ProductPage.routeName,
                                              //     arguments: group[index].product);
                                            },
                                            child: Row(
                                              children: [
                                                const SizedBox(width: 5),
                                                Image(
                                                    image: group[index].product.imageType.image(),
                                                    width: 30,
                                                    height: 30),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                    child: Text(group[index].product.name,
                                                        style: mainProvider.itemStyle)),
                                                Row(
                                                  children: [
                                                    Text('${group[index].quantity} x ',
                                                        style: mainProvider.itemStyle),
                                                    Text(group[index].price.toStringAsFixed(2),
                                                        style: mainProvider.itemStyle
                                                            .copyWith(color: c)),
                                                    Text(
                                                        ' = ${(group[index].quantity * group[index].price).toStringAsFixed(2)}€',
                                                        style: mainProvider.itemStyle),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Divider(color: Utils.oscuro),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(Utils.dateEnglishToSpanish(group[0].date.toString()),
                                  style: mainProvider.itemStyle),
                              Text('$totalQuantity uds', style: mainProvider.itemStyle),
                            ],
                          ),
                          const SizedBox(height: 25),
                          Text('Total ${totalPrice.toStringAsFixed(2)}€',
                              style: mainProvider.titleStyle),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fab(BuildContext context, MainProvider mainProvider, List<ShoppingHistory> group) {
    return FloatingActionButton(
      onPressed: () async {
        final p = await showAddProduct(context);
        if (p[0]) {
          ShoppingHistory shoppingHistory = await mainProvider.addShoppingHistory(
              p[1], group[0].shop, p[2], group[0].cartId,
              dateTime: group[0].date);
          group.add(shoppingHistory);
        }
      },
      child: Icon(
        Icons.add,
      ),
    );
  }

  Widget popupMenuButton(BuildContext context, MainProvider mainProvider,
      List<ShoppingHistory> group, ShoppingHistory shoppingHistory) {
    return PopupMenuButton<EModificationType>(
      color: Utils.oscuro,
      iconSize: 30,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(20.0),
        ),
      ),
      icon: Icon(Icons.more_vert, color: Utils.oscuro),
      onSelected: (order) {
        switch (order) {
          case EModificationType.price:
            _changePrice(context, mainProvider, shoppingHistory);
            break;
          case EModificationType.quantity:
            _changeCuantity(context, mainProvider, shoppingHistory);
            break;
          case EModificationType.shop:
            _changeShop(context, mainProvider, shoppingHistory);
            break;
          case EModificationType.shopping:
            _shopping(context, mainProvider, shoppingHistory);
            break;
          case EModificationType.delete:
            _delete(context, mainProvider, group, shoppingHistory);
            break;
          case EModificationType.rename:
            _rename(context, mainProvider, shoppingHistory);
            break;
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem(
            value: EModificationType.price,
            child: ListTile(
              title:
                  Text(EModificationType.price.displayName(), style: TextStyle(color: Utils.claro)),
              leading: Icon(Icons.euro, color: Utils.claro),
            ),
          ),
          PopupMenuItem(
            value: EModificationType.shopping,
            child: ListTile(
              title: Text(EModificationType.shopping.displayName(),
                  style: TextStyle(color: Utils.claro)),
              leading: Icon(Icons.shopping_basket_rounded, color: Utils.claro),
            ),
          ),
          PopupMenuItem(
            value: EModificationType.quantity,
            child: ListTile(
              title: Text(EModificationType.quantity.displayName(),
                  style: TextStyle(color: Utils.claro)),
              leading: Icon(Icons.paste_rounded, color: Utils.claro),
            ),
          ),
          PopupMenuItem(
            value: EModificationType.shop,
            child: ListTile(
              title:
                  Text(EModificationType.shop.displayName(), style: TextStyle(color: Utils.claro)),
              leading: Icon(Icons.house_siding_rounded, color: Utils.claro),
            ),
          ),
          PopupMenuItem(
            value: EModificationType.rename,
            child: ListTile(
              title: Text(EModificationType.rename.displayName(),
                  style: TextStyle(color: Utils.claro)),
              leading: Icon(Icons.drive_file_rename_outline_outlined, color: Utils.claro),
            ),
          ),
          PopupMenuItem(
            value: EModificationType.delete,
            child: ListTile(
              title: Text(EModificationType.delete.displayName(),
                  style: TextStyle(color: Utils.claro)),
              leading: Icon(Icons.delete, color: Utils.claro),
            ),
          ),
        ];
      },
    );
  }

  void _changeCuantity(
      BuildContext context, MainProvider mainProvider, ShoppingHistory shoppingHistory) {
    int cantidad = shoppingHistory.quantity;
    showModalBottomSheet(
      sheetAnimationStyle:
          AnimationStyle(curve: Curves.easeInOutExpo, duration: const Duration(milliseconds: 800)),
      elevation: 30,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              width: double.infinity,
              height: 200,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Utils.claro,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Indica la cantidad', style: mainProvider.titleStyle),
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
                  Expanded(child: SizedBox(height: 1)),
                  ElevatedButton(
                    onPressed: () {
                      if (cantidad != shoppingHistory.quantity) {
                        shoppingHistory.quantity = cantidad;
                        mainProvider.updateShoppingHistory(shoppingHistory);
                        ScaffoldMessenger.of(context)
                            .showSnackBar(Utils.snackBar('Cantidad modificada'));
                        Navigator.pop(context);
                      }
                    },
                    child: Text('Aceptar'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _changeShop(
      BuildContext context, MainProvider mainProvider, ShoppingHistory shoppingHistory) async {
    final resp = await showShops(context, showQuantity: false, product: shoppingHistory.product);
    if (resp[0]) {
      Shop shop = mainProvider.shops.firstWhere((s) => s.name == resp[2]);
      shoppingHistory.shop = shop;
      mainProvider.updateShoppingHistory(shoppingHistory);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(Utils.snackBar('Tienda cambiada'));
      }
    }
  }

  void _changePrice(
      BuildContext context, MainProvider mainProvider, ShoppingHistory shoppingHistory) async {
    ProductShop productShop = ProductShop(mainProvider.getIndexProductShop(),
        shoppingHistory.product, shoppingHistory.shop, 0, DateTime.now());
    if (context.mounted) {
      productShop.price =
          mainProvider.getProductPrice(shoppingHistory.product, shoppingHistory.shop);
      final isPriceConfirmed = await showProductPrice(context, productShop);
      if (isPriceConfirmed[0]) {
        mainProvider.addProductShop(productShop);
        PriceHistory history = await mainProvider.checkHistoricoPrecio(productShop);
        mainProvider.updateHistoricoPrecio(history);
      }
      if (!context.mounted || !isPriceConfirmed[0]) return;
      final resp = await showMessage(
          context: context, message: '¿Poner el precio en la compra?', cancel: true);
      if (resp) {
        shoppingHistory.price = productShop.price;
        mainProvider.updateShoppingHistory(shoppingHistory);
      }
    }
  }

  void _shopping(
      BuildContext context, MainProvider mainProvider, ShoppingHistory shoppingHistory) async {
    ProductShop productShop = mainProvider.productsShops.lastWhere(
      (p) => p.shop.id == shoppingHistory.shop.id && p.product.id == shoppingHistory.product.id,
      orElse: () => mainProvider.newProductShop(shoppingHistory.product, shoppingHistory.shop, 0),
    );
    final value = await showProductPrice(context, productShop, isFromShopping: true);
    if (value[0]) {
      shoppingHistory.price = value[1];
      mainProvider.updateShoppingHistory(shoppingHistory);
    }
  }

  void _delete(BuildContext context, MainProvider mainProvider, List<ShoppingHistory> group,
      ShoppingHistory shoppingHistory) async {
    final resp = await showMessage(
        context: context, message: '¿Borrar ${shoppingHistory.product.name}?', cancel: true);
    if (resp && context.mounted) {
      mainProvider.removeShoppingHistory(shoppingHistory);
      ScaffoldMessenger.of(context).showSnackBar(Utils.snackBar('Borrado'));
      group.remove(shoppingHistory);
      if (group.isEmpty) {
        Navigator.pop(context);
      }
    }
  }

  void _rename(
      BuildContext context, MainProvider mainProvider, ShoppingHistory shoppingHistory) async {
    var r2 = await inputDialog(context, 'Nombre');
    if (r2[0]) {
      mainProvider.renameShoppingHistory(shoppingHistory, r2[1]);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(Utils.snackBar('Renombrado'));
      }
    }
  }
}
