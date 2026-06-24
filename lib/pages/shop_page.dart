import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shoppinglist/dialogs/dialogs.dart';
import 'package:shoppinglist/models/models.dart';
import 'package:shoppinglist/pages/_pages.dart';
import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/sharedpreferences/preferences.dart';
import 'package:shoppinglist/utils/enums.dart';
import 'package:shoppinglist/utils/utils.dart';
import 'package:shoppinglist/widgets/_widgets.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ShopPage extends StatefulWidget {
  static const String routeName = 'ShopPage';
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  late List<ProductShop> productosAct;
  late List<Product> productos;
  late MainProvider mainProvider;
  late Shop shop;
  late List<ShoppingHistory> historicoCompras;
  ShopHistoryGroup groupSelected = Preferences.typeShopHistoryGroup;
  String selectedYear = 'TODOS';
  bool _isInit = true;
  List<Color> shuffledList = List.from(Utils.palettes);
  List<String> years = ['TODOS'];
  final PageController graphicPageController = PageController(initialPage: 0);
  int currentPage = 0;
  TextEditingController searchController = TextEditingController();
  EOrderHistory orderHistory = EOrderHistory.date;
  EAscDesc orderAsc = EAscDesc.descendent;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    shop = ModalRoute.of(context)!.settings.arguments as Shop;
    mainProvider = Provider.of<MainProvider>(context, listen: false);
    productosAct = mainProvider.productsShops.where((p) => p.shop.id == shop.id).toList();
    productos = mainProvider.pricesHistory
        .where((p) => p.productShop.shop.id == shop.id)
        .map<Product>((p) => p.productShop.product)
        .toList();
    List<Product> sinRepetir = productos.toSet().toList();
    productos = sinRepetir;
    historicoCompras = mainProvider.loadShoppingHistoryByShop(shop);

    if (_isInit) {
      shuffledList.shuffle(Random());
      years.addAll(historicoCompras.map((h) => h.date.year.toString()).toSet().toList());

      _isInit = false;
    }
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          _mainTop(),
          _sliverTop(),
          ..._toShow(),
        ],
      ),
    );
  }

  Widget _mainTop() {
    return SliverToBoxAdapter(
      child: Container(
        color: Utils.medio,
        child: Column(
          children: [
            const TopWidget(showBack: true),
            SizedBox(
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned(
                    bottom: 0,
                    left: 100,
                    child: Container(
                      width: 150,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                  Center(
                    child: FadeInLeft(
                      child: Hero(
                          tag: '${Utils.tagShop}${shop.id}',
                          child: Image.asset(Utils.assetShop, width: 200, height: 200)),
                    ),
                  ),
                  lateralFunctions(context),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sliverTop() {
    return SliverToBoxAdapter(
      child: Container(
        color: Utils.medio,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.only(top: 20, left: 20),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(shop.name, style: mainProvider.titleStyle),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: categories(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Positioned lateralFunctions(BuildContext context) {
    return Positioned(
      right: 20,
      top: 0,
      child: SizedBox(
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  changeShopName(context, shop).then((value) {
                    if (value) {
                      mainProvider.renameShop(shop);
                      setState(() {});
                    }
                  });
                },
                child: Icon(Icons.edit, color: Utils.claro, size: 40),
              ),
            ),
            const SizedBox(height: 10),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () async {
                  if (mainProvider.shopHasMovements(shop)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        Utils.snackBar('No se puede borrar. Tiene movimientos', isGood: false));
                  } else {
                    final resp = await confirmDelete(context, '¿Borrar la tienda?');
                    if (resp && context.mounted) {
                      mainProvider.removeShop(shop);
                      ScaffoldMessenger.of(context)
                          .showSnackBar(Utils.snackBar('Tienda borrada...', isGood: false));
                      Navigator.pop(context);
                    }
                  }
                },
                child: Icon(Icons.delete, color: Utils.claro, size: 40),
              ),
            ),
            const SizedBox(height: 10),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () async {
                  if (mainProvider.products.isNotEmpty) {
                    final value = await addShopPriceFromShop(context, shop);
                    if (value[0] && context.mounted) {
                      ProductShop productShop = mainProvider.newProductShop(value[1], shop, 0);
                      final value2 = await showProductPrice(context, productShop);
                      if (value2[0]) {
                        setState(() {
                          mainProvider.addProductShop(productShop);
                        });
                      }
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        Utils.snackBar('No hay productos creados . . .', isGood: false));
                  }
                },
                child: Icon(Icons.euro, color: Utils.claro, size: 40),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget categories(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      margin: const EdgeInsets.only(right: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              BounceInLeft(
                duration: Utils.fadeInDuration,
                child: GestureDetector(
                  child: category('Precios', EProductView.prices,
                      Preferences.productTabIndex == EProductView.prices),
                ),
              ),
              const SizedBox(width: 15),
              BounceInRight(
                duration: Utils.fadeInDuration,
                child: category('Estadística', EProductView.estatistics,
                    Preferences.productTabIndex == EProductView.estatistics),
              ),
              const SizedBox(width: 15),
              BounceInDown(
                duration: Utils.fadeInDuration,
                child: category('Historial', EProductView.history,
                    Preferences.productTabIndex == EProductView.history),
              ),
              const SizedBox(width: 15),
              BounceInUp(
                duration: Utils.fadeInDuration,
                child: category('Gráficas', EProductView.graphics,
                    Preferences.productTabIndex == EProductView.graphics),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget category(String name, EProductView productView, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() {
        Preferences.productTabIndex = productView;
      }),
      child: Container(
        height: 50,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? Utils.oscuro : Utils.claro,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Utils.oscuro,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            name,
            style: isSelected
                ? mainProvider.itemStyleN.copyWith(color: Utils.claro)
                : mainProvider.itemStyleN,
          ),
        ),
      ),
    );
  }

  Widget sliverNoProducts() {
    return SliverFillRemaining(
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('No hay precios asociados', style: mainProvider.titleStyle),
            const SizedBox(width: 15),
            InkWell(
              onTap: () => _createPrice(context),
              borderRadius: BorderRadius.circular(20),
              child: Icon(Icons.add, color: Utils.oscuro, size: 40),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _toShow() {
    switch (Preferences.productTabIndex) {
      case EProductView.prices:
        return sliverPrices();
      case EProductView.estatistics:
        return sliverStatistics();
      case EProductView.history:
        return sliverHistory();
      case EProductView.graphics:
        if (historicoCompras.isEmpty) {
          return [
            SliverFillRemaining(
              child: Center(
                child: Text('No hay compras', style: mainProvider.titleStyle),
              ),
            )
          ];
        } else {
          return [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      DropdownButton(
                        borderRadius: BorderRadius.circular(20),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        dropdownColor: Utils.claro,
                        value: Preferences.shopTypeGraphic,
                        underline: Container(),
                        alignment: Alignment.center,
                        items: ETypeGraphic.values
                            .map<DropdownMenuItem<ETypeGraphic>>((ETypeGraphic value) {
                          return DropdownMenuItem<ETypeGraphic>(
                            value: value,
                            child: Text(value.displayName(), style: mainProvider.itemStyle),
                          );
                        }).toList(),
                        onChanged: <ETypeGraphic>(value) {
                          Preferences.shopTypeGraphic = value;
                        },
                      ),
                      DropdownButton(
                        borderRadius: BorderRadius.circular(20),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        dropdownColor: Utils.claro,
                        value: selectedYear,
                        underline: Container(),
                        alignment: Alignment.center,
                        items: years.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: mainProvider.itemStyle),
                          );
                        }).toList(),
                        onChanged: <String>(value) {
                          selectedYear = value;
                        },
                      ),
                    ],
                  ),
                  if (Preferences.shopTypeGraphic == ETypeGraphic.product)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      spacing: 5,
                      children: [
                        Text('Datos por: Cantidad', style: mainProvider.itemStyle),
                        Switch(
                          value: Preferences.graphicByAmount,
                          onChanged: (value) {
                            setState(() {
                              Preferences.graphicByAmount = value;
                            });
                          },
                        ),
                        Text('Importe', style: mainProvider.itemStyle),
                        const SizedBox(width: 20),
                      ],
                    ),
                ],
              ),
            ),
            if (Preferences.shopTypeGraphic == ETypeGraphic.general) ..._graphicsGeneralByYears(),
            if (Preferences.shopTypeGraphic == ETypeGraphic.product) ..._graphicsByProduct(),
          ];
        }
    }
  }

  List<Widget> sliverPrices() {
    return productosAct.isNotEmpty
        ? [
            SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: !Preferences.isViewGraphic
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.end,
                children: [
                  if (!Preferences.isViewGraphic)
                    Icon(Icons.swap_horiz_rounded, size: Utils.iconSizeStandar, color: Utils.claro),
                  Row(
                    children: [
                      Text('Lista', style: mainProvider.titleStyle.copyWith(fontSize: 13)),
                      const SizedBox(width: 7),
                      Switch(
                        value: !Preferences.isViewGraphic,
                        onChanged: (value) {
                          setState(() {
                            Preferences.isViewGraphic = !value;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Preferences.isViewGraphic
                ? SliverList.builder(
                    itemCount: productosAct.length,
                    itemBuilder: (context, index) {
                      final item = productosAct[index];
                      return Dismissible(
                        key: Key('${productosAct[index].id}shop'),
                        direction: DismissDirection.startToEnd,
                        confirmDismiss: (direction) async {
                          showMessage(context: context, message: '¿Borrar el precio?', cancel: true)
                              .then((value) {
                            if (value) {
                              mainProvider.removeProductShop(productosAct[index]);
                            } else {
                              productosAct.insert(index, item);
                            }
                            setState(() {});
                          });
                          return false;
                        },
                        background: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.delete,
                              size: 40,
                              color: Colors.red[300],
                            ),
                          ],
                        ),
                        child: PriceWidget(productShop: productosAct[index], isProduct: true),
                      );
                    },
                  )
                : SliverList.builder(
                    itemCount: productosAct.length,
                    itemBuilder: (context, index) {
                      final item = productosAct[index];
                      return Dismissible(
                        key: Key('${productosAct[index].id}product'),
                        background: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(Icons.delete, size: 40, color: Colors.red[300]),
                              Icon(Icons.edit, size: 40, color: Colors.green[300]),
                            ],
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: GestureDetector(
                            onTap: () => Navigator.pushNamed(context, ProductPage.routeName,
                                arguments: item.product),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(10),
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                color: Utils.claro,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Image(
                                      image: item.product.imageType.image(), width: 50, height: 50),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.product.name,
                                          style: mainProvider.itemStyle,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          Utils.dateEnglishToSpanish(item.date.toString()),
                                          style: mainProvider.itemStyle.copyWith(fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text('${item.price.toStringAsFixed(2)} €',
                                      style: mainProvider.itemStyle),
                                ],
                              ),
                            ),
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          bool ret = true;
                          if (direction == DismissDirection.endToStart) {
                            DateTime? date = DateTime.now();
                            final c = await showProductPrice(context, productosAct[index]);
                            if (c[0] && context.mounted) {
                              final value = await showDate(context);
                              if (value != null) {
                                date = DateTime(value.year, value.month, value.day,
                                    DateTime.now().hour + 1, DateTime.now().minute);
                              }
                              productosAct[index].date = date;
                              Utils.boxPrices
                                  .put(productosAct[index].id, productosAct[index].toJson());
                              mainProvider.calculateAmount();
                              mainProvider.addHistoricoPrecio(productosAct[index]);
                              ret = true;
                            }
                            ret = false;
                          } else {
                            final value = await showMessage(
                                context: context, message: '¿Borrar el precio?', cancel: true);
                            if (value) {
                              mainProvider.removeProductShop(productosAct[index]);
                              ret = true;
                            } else {
                              productosAct.insert(index, item);
                              ret = false;
                            }
                          }
                          setState(() {});
                          return ret;
                        },
                      );
                    }),
          ]
        : [sliverNoProducts()];
  }

  List<Widget> sliverStatistics() {
    return productosAct.isNotEmpty
        ? [
            SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Gráfica', style: mainProvider.titleStyle.copyWith(fontSize: 13)),
                  const SizedBox(width: 7),
                  Switch(
                    value: Preferences.isViewGraphic,
                    onChanged: (value) => setState(() => Preferences.isViewGraphic = value),
                  ),
                ],
              ),
            ),
            _searchBar(),
            Preferences.isViewGraphic ? _statistics() : _statisticsDetailed(),
          ]
        : [sliverNoProducts()];
  }

  List<Widget> sliverHistory() {
    if (searchController.text.isNotEmpty) {
      historicoCompras = historicoCompras
          .where((h) => Utils.quitarTildes(h.product.name.toUpperCase())
              .contains(Utils.quitarTildes(searchController.text.toUpperCase())))
          .toList();
    }
    double totalAmount =
        historicoCompras.fold(0, (previousValue, e) => previousValue + (e.price * e.quantity));
    double totalQuantity =
        historicoCompras.fold(0, (previousValue, e) => previousValue + e.quantity);
    return historicoCompras.isNotEmpty
        ? [
            SliverToBoxAdapter(
              child: Row(
                spacing: 20,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  DropdownButton(
                    borderRadius: BorderRadius.circular(20),
                    dropdownColor: Utils.claro,
                    isExpanded: false,
                    value: groupSelected,
                    underline: Container(),
                    items: ShopHistoryGroup.values
                        .map<DropdownMenuItem<ShopHistoryGroup>>((ShopHistoryGroup value) {
                      return DropdownMenuItem<ShopHistoryGroup>(
                        value: value,
                        child: Text(value.displayName(), style: mainProvider.itemStyle),
                      );
                    }).toList(),
                    onChanged: <ShopHistoryGroup>(value) {
                      groupSelected = value;
                      Preferences.typeShopHistoryGroup = groupSelected;
                    },
                  ),
                  if (groupSelected == ShopHistoryGroup.nogroup)
                    DropdownButton(
                      borderRadius: BorderRadius.circular(20),
                      dropdownColor: Utils.claro,
                      isExpanded: false,
                      value: orderHistory,
                      underline: Container(),
                      items: EOrderHistory.values
                          .map<DropdownMenuItem<EOrderHistory>>((EOrderHistory value) {
                        return DropdownMenuItem<EOrderHistory>(
                          value: value,
                          child: Text(value.displayName(), style: mainProvider.itemStyle),
                        );
                      }).toList(),
                      onChanged: <EOrderHistory>(value) {
                        orderHistory = value;
                      },
                    ),
                  if (groupSelected == ShopHistoryGroup.byProduct ||
                      groupSelected == ShopHistoryGroup.nogroup)
                    DropdownButton(
                      borderRadius: BorderRadius.circular(20),
                      dropdownColor: Utils.claro,
                      isExpanded: false,
                      value: orderAsc,
                      underline: Container(),
                      items: EAscDesc.values.map<DropdownMenuItem<EAscDesc>>((EAscDesc value) {
                        return DropdownMenuItem<EAscDesc>(
                          value: value,
                          child: Text(value.displayName(), style: mainProvider.itemStyle),
                        );
                      }).toList(),
                      onChanged: <EAscDesc>(value) {
                        orderAsc = value;
                      },
                    ),
                ],
              ),
            ),
            if (groupSelected == ShopHistoryGroup.byProduct ||
                groupSelected == ShopHistoryGroup.nogroup)
              _searchBar(),
            _history(),
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(top: 20, left: 5, right: 5),
                decoration: BoxDecoration(
                  color: Utils.claro,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Utils.medio.withAlpha((255 * 0.5).toInt()), width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('Total: ${totalAmount.toStringAsFixed(2)}€',
                        style: mainProvider.titleStyle.copyWith(fontSize: 17)),
                    Text('Unidades: ${totalQuantity.toStringAsFixed(0)}',
                        style: mainProvider.titleStyle.copyWith(fontSize: 17)),
                  ],
                ),
              ),
            ),
          ]
        : [
            SliverFillRemaining(
              child: Center(child: Text('No hay compras', style: mainProvider.titleStyle)),
            )
          ];
  }

  Widget _searchBar() {
    return SliverToBoxAdapter(
      child: Container(
        height: 45,
        margin: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Utils.oscuro),
        ),
        child: TextFormField(
          onChanged: (value) => setState(() {}),
          cursorColor: Utils.oscuro,
          controller: searchController,
          style: mainProvider.itemStyle,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search, color: Utils.oscuro),
            suffixIcon: GestureDetector(
              onTap: () {
                searchController.text = '';
                WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
                setState(() {});
              },
              child: Icon(Icons.clear, color: Utils.oscuro, size: 25),
            ),
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
    );
  }

  Widget _history() {
    switch (groupSelected) {
      case ShopHistoryGroup.nogroup:
        switch (orderHistory) {
          case EOrderHistory.date:
            if (orderAsc == EAscDesc.ascendent) {
              historicoCompras.sort((a, b) => a.date.compareTo(b.date));
            } else {
              historicoCompras.sort((a, b) => b.date.compareTo(a.date));
            }
            break;
          case EOrderHistory.name:
            if (orderAsc == EAscDesc.ascendent) {
              historicoCompras.sort((a, b) => a.product.name.compareTo(b.product.name));
            } else {
              historicoCompras.sort((a, b) => b.product.name.compareTo(a.product.name));
            }
            break;
        }
        return HistoryListProductWidget(historicoCompras: historicoCompras, isProduct: false);
      case ShopHistoryGroup.byProduct:
        List<Product> products = historicoCompras.map((e) => e.product).toSet().toList();
        switch (orderHistory) {
          case EOrderHistory.date:
          case EOrderHistory.name:
            if (orderAsc == EAscDesc.ascendent) {
              products.sort((a, b) => a.name.compareTo(b.name));
            } else {
              products.sort((a, b) => b.name.compareTo(a.name));
            }
            break;
        }
        return SliverList.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final List<ShoppingHistory> shoppingList =
                historicoCompras.where((h) => h.product.id == products[index].id).toList();
            return HistoryGroupedDetailWidget(
                shoppingHistory: shoppingList, type: ETypeShoppings.byProduct);
          },
        );
      case ShopHistoryGroup.byDate:
        List<int> years = historicoCompras.map((e) => e.date.year).toSet().toList();
        return SliverList.builder(
          itemCount: years.length,
          itemBuilder: (context, index) {
            final List<ShoppingHistory> shoppingList =
                historicoCompras.where((h) => h.date.year == years[index]).toList();
            return HistoryShopGroupedByDate(shoppingHistory: shoppingList);
          },
        );
      case ShopHistoryGroup.byShopping:
        List<String> idCarts = historicoCompras.map((e) => e.cartId).toSet().toList();
        return SliverList.builder(
          itemCount: idCarts.length,
          itemBuilder: (context, index) {
            final List<ShoppingHistory> shoppingList =
                historicoCompras.where((h) => h.cartId == idCarts[index]).toList();
            return HistoryByShoppingWidget(shoppingHistory: shoppingList, showShopName: false);
          },
        );
    }
  }

  Widget _statistics() {
    final allProducts = productos;
    List<Product> filteredProducts = allProducts;
    final query = searchController.text.trim();

    if (query.isNotEmpty) {
      final normalizedQuery = Utils.quitarTildes(query.toUpperCase());
      filteredProducts = allProducts.where((h) {
        final name = Utils.quitarTildes(
          h.name.toUpperCase(),
        );
        return name.contains(normalizedQuery);
      }).toList();
    }

    return SliverList.builder(
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        return ShopProductHistory(product: filteredProducts[index], shop: shop);
      },
    );
  }

  Widget _statisticsDetailed() {
    // List<PriceHistory> pricesHistory = mainProvider.pricesHistory;
    // if (searchController.text.isNotEmpty) {
    //   pricesHistory = pricesHistory
    //       .where((h) => Utils.quitarTildes(h.productShop.product.name.toUpperCase())
    //           .contains(Utils.quitarTildes(searchController.text.toUpperCase())))
    //       .toList();
    // } else {
    //   pricesHistory = mainProvider.pricesHistory;
    // }

    // // Prefiltrar datos para mejorar rendimiento
    // final pricesByProduct = <int, List<PriceHistory>>{};
    // for (PriceHistory price in pricesHistory) {
    //   if (price.productShop.shop.id == shop.id) {
    //     pricesByProduct.putIfAbsent(price.productShop.product.id, () => []).add(price);
    //   }
    // }

    // 1. Partimos SIEMPRE de la lista original
    final allPricesHistory = mainProvider.pricesHistory;
    final allProducts = productos;

    // 2. Aplicamos filtro de búsqueda (si hay texto)
    List<PriceHistory> filteredPrices = allPricesHistory;
    List<Product> filteredProducts = allProducts;
    final query = searchController.text.trim();

    if (query.isNotEmpty) {
      final normalizedQuery = Utils.quitarTildes(query.toUpperCase());

      filteredPrices = allPricesHistory.where((h) {
        final name = Utils.quitarTildes(
          h.productShop.product.name.toUpperCase(),
        );
        return name.contains(normalizedQuery);
      }).toList();

      filteredProducts = allProducts.where((h) {
        final name = Utils.quitarTildes(
          h.name.toUpperCase(),
        );
        return name.contains(normalizedQuery);
      }).toList();
    }

    // 3. Filtramos por tienda
    filteredPrices = filteredPrices.where((p) => p.productShop.shop.id == shop.id).toList();

    // 4. Agrupamos por producto
    final pricesByProduct = <int, List<PriceHistory>>{};
    for (final price in filteredPrices) {
      pricesByProduct.putIfAbsent(price.productShop.product.id, () => []).add(price);
    }

    return SliverList.separated(
      itemCount: filteredProducts.length,
      separatorBuilder: (context, index) => SizedBox(height: 15),
      itemBuilder: (context, index) {
        final prices = pricesByProduct[filteredProducts[index].id] ?? [];
        return FadeInLeft(
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, ProductPage.routeName,
                arguments: filteredProducts[index]),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Utils.claro,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Hero(
                        tag: '${Utils.tagProduct}${filteredProducts[index].id}',
                        child: Image(
                          image: filteredProducts[index].imageType.image(),
                          width: MediaQuery.of(context).size.width * 0.06,
                          height: MediaQuery.of(context).size.width * 0.06,
                          errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Text(filteredProducts[index].name, style: mainProvider.minititleStyle),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Column(
                    children: prices.asMap().entries.map((entry) {
                      final price = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                Utils.dateEnglishToSpanish(price.fecha.toString(), showTime: false),
                                style: mainProvider.itemStyleN),
                            Text('${price.productShop.price} €', style: mainProvider.itemStyleN),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _graphicsGeneralByYears() {
    List<CircularSeries<dynamic, dynamic>> series = [];
    List<ColumnSeries<dynamic, dynamic>> seriesLinear = [];
    late Widget listView;
    double totalAmount = 0;

    if (selectedYear == 'TODOS') {
      Map<String, double> groupedByYears = {};
      for (String y in years.getRange(1, years.length)) {
        final year = <String, double>{
          y: historicoCompras
              .where((h) => h.date.year == int.parse(y))
              .fold<double>(0, (sum, item) => sum + (item.quantity * item.price))
        };
        groupedByYears.addEntries(year.entries);
      }
      List<_PieDataByYears> data = [];
      for (var v in groupedByYears.entries) {
        if (v.value > 0) {
          data.add(_PieDataByYears(v.key, v.value));
          totalAmount += v.value;
        }
      }
      series = [
        PieSeries<_PieDataByYears, String>(
          explode: true,
          explodeIndex: 0,
          dataSource: data,
          xValueMapper: (_PieDataByYears data, _) => data.year,
          yValueMapper: (_PieDataByYears data, _) => data.quantity,
          dataLabelMapper: (_PieDataByYears data, _) => '${data.quantity.toStringAsFixed(2)}€',
          dataLabelSettings: DataLabelSettings(isVisible: true),
          onPointTap: (ChartPointDetails details) {
            final _PieDataByYears tappedData = data[details.pointIndex!];
            setState(() {
              selectedYear = tappedData.year;
            });
          },
        )
      ];
      seriesLinear = [
        ColumnSeries<_PieDataByYears, String>(
          name: shop.name,
          dataSource: data,
          xValueMapper: (_PieDataByYears data, _) => data.year,
          yValueMapper: (_PieDataByYears data, _) => data.quantity,
          dataLabelMapper: (_PieDataByYears data, _) => Preferences.graphicByAmount
              ? '${data.quantity.toStringAsFixed(2)}€'
              : data.quantity.toStringAsFixed(0),
          dataLabelSettings: DataLabelSettings(isVisible: true),
          pointColorMapper: (data, index) => shuffledList[index],
        ),
      ];
      listView = ListView.builder(
        shrinkWrap: true,
        itemCount: data.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  spacing: 10,
                  children: [
                    Icon(Icons.calendar_month, color: Utils.oscuro),
                    Text(data[index].year, style: mainProvider.itemStyle),
                  ],
                ),
                Text('${data[index].quantity.toStringAsFixed(2)}€', style: mainProvider.itemStyle),
              ],
            ),
          );
        },
      );
    } else {
      Map<int, double> groupedByYear = {};
      List<int> monthsOfShopByYear = historicoCompras
          .where((h) => h.date.year == int.parse(selectedYear))
          .map((r) => r.date.month)
          .toSet()
          .toList();
      for (int month in monthsOfShopByYear) {
        final entry = <int, double>{
          month: historicoCompras
              .where((h) => h.date.year.toString() == selectedYear && h.date.month == month)
              .fold<double>(0, (sum, item) => sum + (item.quantity * item.price))
        };
        groupedByYear.addEntries(entry.entries);
        totalAmount += entry.values.first;
      }
      List<_PieDataByYear> data = [];

      for (var v in groupedByYear.entries) {
        if (v.value > 0) {
          data.add(_PieDataByYear(v.key, v.value));
        }
      }

      switch (Preferences.graphicShopGeneralOrder) {
        case EOrderGraphic.ascendingMonth:
          data.sort((a, b) => a.month.compareTo(b.month));
          break;
        case EOrderGraphic.descendingMonth:
          data.sort((a, b) => b.month.compareTo(a.month));
          break;
        case EOrderGraphic.amountDesc:
          data.sort((a, b) => b.quantity.compareTo(a.quantity));
          break;
        case EOrderGraphic.amountAsc:
          data.sort((a, b) => a.quantity.compareTo(b.quantity));
          break;
      }

      series = [
        PieSeries<_PieDataByYear, String>(
          explode: true,
          explodeIndex: 0,
          dataSource: data,
          xValueMapper: (_PieDataByYear data, _) => data.monthName,
          yValueMapper: (_PieDataByYear data, _) => data.quantity,
          dataLabelMapper: (_PieDataByYear data, _) => '${data.quantity.toStringAsFixed(2)}€',
          dataLabelSettings: DataLabelSettings(isVisible: true),
        )
      ];
      seriesLinear = [
        ColumnSeries<_PieDataByYear, String>(
          name: shop.name,
          dataSource: data,
          xValueMapper: (_PieDataByYear data, _) => data.monthName,
          yValueMapper: (_PieDataByYear data, _) => data.quantity,
          dataLabelMapper: (_PieDataByYear data, _) => Preferences.graphicByAmount
              ? '${data.quantity.toStringAsFixed(2)}€'
              : data.quantity.toStringAsFixed(0),
          dataLabelSettings: DataLabelSettings(isVisible: true),
          pointColorMapper: (data, index) => shuffledList[index],
        )
      ];
      listView = ListView.builder(
        physics: const ClampingScrollPhysics(),
        shrinkWrap: true,
        itemCount: data.length,
        itemBuilder: (context, index) {
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, HistoryPage.routeName,
                    arguments: [shop, int.parse(selectedYear), data[index].month]);
              },
              borderRadius: BorderRadius.circular(20),
              splashColor: Utils.oscuro,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      spacing: 7,
                      children: [
                        Icon(Icons.calendar_month, color: Utils.oscuro),
                        Text(data[index].monthName!, style: mainProvider.itemStyle),
                      ],
                    ),
                    Row(
                      spacing: 7,
                      children: [
                        Text('${data[index].quantity.toStringAsFixed(2)}€',
                            style: mainProvider.itemStyle),
                        Icon(Icons.remove_red_eye, color: Utils.oscuro),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    return [
      SliverToBoxAdapter(
        child: ZoomIn(
          child: Container(
            height: 500,
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Utils.claro,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Utils.oscuro,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: graphicPageController,
                    scrollDirection: Axis.horizontal,
                    onPageChanged: (index) {
                      setState(() {
                        currentPage = index;
                      });
                    },
                    children: [
                      RepaintBoundary(
                        child: SfCircularChart(
                          palette: shuffledList,
                          legend: Legend(isVisible: true),
                          series: series,
                        ),
                      ),
                      RepaintBoundary(
                        child: SfCartesianChart(
                          primaryXAxis: const CategoryAxis(
                            labelRotation: 45,
                            labelStyle: TextStyle(fontSize: 12),
                          ),
                          primaryYAxis: NumericAxis(
                            title: AxisTitle(text: 'Importe'),
                            minimum: 0,
                            labelFormat: '{value}',
                            numberFormat: NumberFormat.decimalPatternDigits(
                                decimalDigits: Preferences.graphicByAmount ? 2 : 0),
                          ),
                          palette: shuffledList,
                          // legend: Legend(isVisible: true),
                          series: seriesLinear,
                          tooltipBehavior: TooltipBehavior(enable: true),
                          zoomPanBehavior: ZoomPanBehavior(
                            enablePinching: true,
                            enableDoubleTapZooming: true,
                            enableSelectionZooming: true,
                            enableMouseWheelZooming: true,
                            enablePanning: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 10,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        width: currentPage == 0 ? 25 : 10,
                        height: currentPage == 0 ? 15 : 10,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Utils.medio,
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        width: currentPage == 1 ? 25 : 10,
                        height: currentPage == 1 ? 15 : 10,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Utils.medio,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: ZoomIn(
          child: Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Utils.claro,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Utils.oscuro,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                if (selectedYear != 'TODOS')
                  Row(
                    spacing: 20,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('Ordenar por', style: mainProvider.itemStyle),
                      DropdownButton<EOrderGraphic>(
                        isExpanded: false,
                        elevation: 16,
                        style: TextStyle(fontSize: 20, color: Utils.oscuro),
                        dropdownColor: Utils.claro,
                        borderRadius: BorderRadius.circular(20),
                        underline: Container(height: 2),
                        value: Preferences.graphicShopGeneralOrder,
                        items: EOrderGraphic.values
                            .map((o) => DropdownMenuItem(value: o, child: Text(o.displayName())))
                            .toList(),
                        onChanged: (value) {
                          if (value != Preferences.graphicShopGeneralOrder) {
                            setState(() {
                              Preferences.graphicShopGeneralOrder = value!;
                            });
                          }
                        },
                        selectedItemBuilder: (context) {
                          return EOrderGraphic.values.map((p) {
                            return DropdownMenuItem(
                                value: p,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Utils.claro,
                                  ),
                                  child: Center(
                                    child: Text(
                                      p.displayName(),
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ));
                          }).toList();
                        },
                      ),
                    ],
                  ),
                listView,
                Divider(color: Utils.oscuro),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    spacing: 10,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('TOTAL', style: mainProvider.itemStyle),
                      Text('${totalAmount.toStringAsFixed(2)}€', style: mainProvider.itemStyle),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ];
  }

  List<Widget> _graphicsByProduct() {
    List<CircularSeries<dynamic, dynamic>> series = [];
    List<ColumnSeries<dynamic, dynamic>> seriesLinear = [];
    List<Product> productos = historicoCompras.map((h) => h.product).toSet().toList();
    late Widget listView;
    double totalQuantity = 0;

    Map<Product, double> groupedByProduct = {};
    for (Product p in productos) {
      final producto = <Product, double>{
        p: selectedYear == 'TODOS'
            ? historicoCompras.where((h) => h.product.id == p.id).fold<double>(
                0,
                (sum, item) => Preferences.graphicByAmount
                    ? sum + (item.quantity * item.price)
                    : sum + item.quantity)
            : historicoCompras
                .where((h) => h.product.id == p.id && h.date.year == int.parse(selectedYear))
                .fold<double>(
                    0,
                    (sum, item) => Preferences.graphicByAmount
                        ? sum + (item.quantity * item.price)
                        : sum + item.quantity)
      };
      groupedByProduct.addEntries(producto.entries);
      totalQuantity += producto.values.first;
    }
    List<_PieDataByProduct> data = [];
    for (var v in groupedByProduct.entries) {
      if (v.value > 0) {
        data.add(_PieDataByProduct(v.key, v.value));
      }
    }
    series = [
      PieSeries<_PieDataByProduct, String>(
        explode: true,
        explodeIndex: 0,
        dataSource: data,
        xValueMapper: (_PieDataByProduct data, _) => data.product.name,
        yValueMapper: (_PieDataByProduct data, _) => data.quantity,
        dataLabelMapper: (_PieDataByProduct data, _) => Preferences.graphicByAmount
            ? '${data.quantity.toStringAsFixed(2)}€'
            : data.quantity.toStringAsFixed(0),
        dataLabelSettings: DataLabelSettings(isVisible: true),
      )
    ];
    seriesLinear = [
      ColumnSeries<_PieDataByProduct, String>(
        name: shop.name,
        dataSource: data,
        xValueMapper: (_PieDataByProduct data, _) => data.product.name,
        yValueMapper: (_PieDataByProduct data, _) => data.quantity,
        dataLabelMapper: (_PieDataByProduct data, _) => Preferences.graphicByAmount
            ? '${data.quantity.toStringAsFixed(2)}€'
            : data.quantity.toStringAsFixed(0),
        dataLabelSettings: DataLabelSettings(isVisible: true),
        pointColorMapper: (data, index) => shuffledList[Random().nextInt(shuffledList.length)],
      )
    ];
    switch (Preferences.graphicShopProductOrder) {
      case EOrderGraphicByProduct.name:
        data.sort((a, b) => a.product.name.compareTo(b.product.name));
        break;
      case EOrderGraphicByProduct.usedAscending:
        data.sort((a, b) => a.quantity.compareTo(b.quantity));
        break;
      case EOrderGraphicByProduct.usedDescending:
        data.sort((a, b) => b.quantity.compareTo(a.quantity));
        break;
    }
    listView = ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: data.length,
      itemBuilder: (context, index) {
        return GraphicProductWidget(
            product: data[index].product,
            shop: shop,
            quantity: data[index].quantity,
            year: selectedYear);
        // return Material(
        //   color: Colors.transparent,
        //   child: InkWell(
        //     splashColor: Utils.oscuro,
        //     onTap: () =>
        //         Navigator.pushNamed(context, ProductPage.routeName, arguments: data[index].product),
        //     borderRadius: BorderRadius.circular(20),
        //     child: Padding(
        //       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        //       child: Row(
        //         children: [
        //           Hero(
        //             tag: '${Utils.tagProduct}${data[index].product.id}',
        //             child: Image.asset(Assets.getAsset(data[index].product.imageType),
        //                 width: 30, height: 30),
        //           ),
        //           const SizedBox(width: 10),
        //           Expanded(
        //               child: MarqueeWidget(
        //                   child: Text(data[index].product.name, style: mainProvider.itemStyle))),
        //           Text(
        //               Preferences.graphicByAmount
        //                   ? '${data[index].quantity.toStringAsFixed(2)}€'
        //                   : data[index].quantity.toStringAsFixed(0),
        //               style: mainProvider.itemStyle),
        //         ],
        //       ),
        //     ),
        //   ),
        // );
      },
    );

    return [
      SliverToBoxAdapter(
        child: ZoomIn(
          child: Container(
            height: 500,
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Utils.claro,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Utils.oscuro,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: graphicPageController,
                    scrollDirection: Axis.horizontal,
                    onPageChanged: (index) {
                      setState(() {
                        currentPage = index;
                      });
                    },
                    children: [
                      SfCircularChart(
                        palette: shuffledList,
                        legend: Legend(isVisible: true),
                        series: series,
                        tooltipBehavior: TooltipBehavior(enable: true),
                      ),
                      SfCartesianChart(
                        primaryXAxis: const CategoryAxis(
                          labelRotation: 45,
                          labelStyle: TextStyle(fontSize: 12),
                        ),
                        primaryYAxis: NumericAxis(
                          title:
                              AxisTitle(text: Preferences.graphicByAmount ? 'Importe' : 'Cantidad'),
                          minimum: 0,
                          labelFormat: '{value}',
                          numberFormat: NumberFormat.decimalPatternDigits(
                              decimalDigits: Preferences.graphicByAmount ? 2 : 0),
                        ),
                        palette: shuffledList,
                        legend: Legend(isVisible: false),
                        series: seriesLinear,
                        tooltipBehavior: TooltipBehavior(enable: true),
                        zoomPanBehavior: ZoomPanBehavior(
                          enablePinching: true,
                          enableDoubleTapZooming: true,
                          enableSelectionZooming: true,
                          enableMouseWheelZooming: true,
                          enablePanning: true,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 10,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        width: currentPage == 0 ? 25 : 10,
                        height: currentPage == 0 ? 15 : 10,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Utils.medio,
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        width: currentPage == 1 ? 25 : 10,
                        height: currentPage == 1 ? 15 : 10,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Utils.medio,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // sliverList,
      SliverToBoxAdapter(
        child: ZoomIn(
          child: Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Utils.claro,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Utils.oscuro,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  spacing: 20,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Ordenar por', style: mainProvider.itemStyle),
                    DropdownButton<EOrderGraphicByProduct>(
                      isExpanded: false,
                      elevation: 16,
                      style: TextStyle(fontSize: 20, color: Utils.oscuro),
                      dropdownColor: Utils.claro,
                      borderRadius: BorderRadius.circular(20),
                      underline: Container(height: 2),
                      value: Preferences.graphicShopProductOrder,
                      items: EOrderGraphicByProduct.values
                          .map((o) => DropdownMenuItem(value: o, child: Text(o.displayName())))
                          .toList(),
                      onChanged: (value) {
                        if (value != Preferences.graphicShopProductOrder) {
                          setState(() {
                            Preferences.graphicShopProductOrder = value!;
                          });
                        }
                      },
                      selectedItemBuilder: (context) {
                        return EOrderGraphicByProduct.values.map((p) {
                          return DropdownMenuItem(
                              value: p,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Utils.claro,
                                ),
                                child: Center(
                                  child: Text(
                                    p.displayName(),
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ));
                        }).toList();
                      },
                    ),
                  ],
                ),
                listView,
                Divider(color: Utils.oscuro),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    spacing: 10,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('TOTAL', style: mainProvider.itemStyle),
                      if (Preferences.graphicByAmount)
                        Text('${totalQuantity.toStringAsFixed(2)}€', style: mainProvider.itemStyle),
                      if (!Preferences.graphicByAmount)
                        Text(totalQuantity.toStringAsFixed(0), style: mainProvider.itemStyle),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ];
  }

  Future<void> _createPrice(BuildContext context) async {
    if (mainProvider.products.isNotEmpty) {
      final confirmShop = await addShopPriceFromShop(context, shop);
      if (confirmShop[0] && context.mounted) {
        ProductShop productShop = mainProvider.newProductShop(confirmShop[1], shop, 0);
        final price = await showProductPrice(context, productShop);
        if (price[0]) {
          setState(() {
            mainProvider.addProductShop(productShop);
          });
        }
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(Utils.snackBar('No hay productos creados . . .', isGood: false));
    }
  }
}

class _PieDataByYears {
  final String year;
  final double quantity;
  _PieDataByYears(this.year, this.quantity);
}

class _PieDataByYear {
  final int month;
  final double quantity;
  String? monthName;

  _PieDataByYear(this.month, this.quantity) {
    switch (month) {
      case 1:
        monthName = 'ENERO';
        break;
      case 2:
        monthName = 'FEBRERO';
        break;
      case 3:
        monthName = 'MARZO';
        break;
      case 4:
        monthName = 'ABRIL';
        break;
      case 5:
        monthName = 'MAYO';
        break;
      case 6:
        monthName = 'JUNIO';
        break;
      case 7:
        monthName = 'JULIO';
        break;
      case 8:
        monthName = 'AGOSTO';
        break;
      case 9:
        monthName = 'SEPTIEMBRE';
        break;
      case 10:
        monthName = 'OCTUBRE';
        break;
      case 11:
        monthName = 'NOVIEMBRE';
        break;
      case 12:
        monthName = 'DICIEMBRE';
        break;
    }
  }
}

class _PieDataByProduct {
  final Product product;
  final double quantity;
  _PieDataByProduct(this.product, this.quantity);
}
