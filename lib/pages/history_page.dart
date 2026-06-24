import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:shoppinglist/dialogs/dialogs.dart';
import 'package:shoppinglist/models/models.dart';
import 'package:shoppinglist/pages/_pages.dart';

import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/sharedpreferences/preferences.dart';
import 'package:shoppinglist/utils/enums.dart';
import 'package:shoppinglist/utils/utils.dart';
import 'package:shoppinglist/widgets/_widgets.dart';

class HistoryPage extends StatefulWidget {
  static const String routeName = 'HistoryPage';
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late MainProvider mainProvider;
  ETypeHistory typeHistory = Preferences.typeHistory;
  ETypeShoppings typeShoppings = Preferences.typeShoppings;
  ETypePrices typePrices = Preferences.typePrices;
  TextEditingController controller = TextEditingController();
  bool _isSearchExpanded = false;
  List<ShoppingHistory> history = [];
  OutlineInputBorder border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(20),
  );
  Timer? _debounce;
  DateTime? startDate, finishDate;
  ScrollController scrollController = ScrollController();
  Shop? selectedShop;
  EOrderNoGroup selectedOrderNoGroup = EOrderNoGroup.fechaDesc;

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    mainProvider.canLoad = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    mainProvider = Provider.of<MainProvider>(context);
    if (mainProvider.canLoad) {
      startDate = DateTime(DateTime.now().year, 1, 1);
      finishDate = DateTime(DateTime.now().year, 12, 31);
    }
    final params = (ModalRoute.of(context)?.settings.arguments as List?) ?? [];
    if (params.isNotEmpty && mainProvider.canLoad) {
      selectedShop = params[0] as Shop;
      startDate = DateTime(params[1], params[2], 1);
      finishDate = DateTime(params[1], params[2], (params[2] as int).monthDays(params[1]));
      _filterHistory();
      mainProvider.canLoad = false;
    }
    if (mainProvider.canLoad) {
      _filterHistory();
      mainProvider.canLoad = false;
    }
    return Scaffold(
      body: Stack(
        children: [
          BackgroundWidget(),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            controller: scrollController,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              _top(),
              _filters(),
              _history(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _top() {
    return SliverAppBar(
      expandedHeight: 70,
      pinned: false,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: TopWidget(
          showBack: true,
          title: 'Historial',
          showCart: false,
          showExit: true,
          showForecast: true,
          showChart: true,
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  Widget _filters() {
    return SliverToBoxAdapter(
      child: FadeInLeft(
        child: Container(
          margin: const EdgeInsets.all(10),
          child: Card(
            color: Utils.claro,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            borderOnForeground: false,
            elevation: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: ExpansionTile(
                enabled: typeHistory == ETypeHistory.shoppings,
                iconColor: Utils.medio,
                collapsedIconColor: Utils.medio,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                childrenPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    DropdownButton(
                      borderRadius: BorderRadius.circular(20),
                      dropdownColor: Utils.claro,
                      isExpanded: false,
                      value: typeHistory,
                      underline: Container(),
                      items: ETypeHistory.values
                          .map<DropdownMenuItem<ETypeHistory>>((ETypeHistory value) {
                        return DropdownMenuItem<ETypeHistory>(
                          value: value,
                          child: Text(value.displayName(), style: mainProvider.itemStyle),
                        );
                      }).toList(),
                      onChanged: <ETypeHistory>(value) {
                        setState(() {
                          typeHistory = value;
                          Preferences.typeHistory = typeHistory;
                        });
                      },
                    ),
                    if (typeHistory == ETypeHistory.prices)
                      DropdownButton(
                        borderRadius: BorderRadius.circular(20),
                        dropdownColor: Utils.claro,
                        isExpanded: false,
                        value: typePrices,
                        underline: Container(),
                        items: ETypePrices.values
                            .map<DropdownMenuItem<ETypePrices>>((ETypePrices value) {
                          return DropdownMenuItem<ETypePrices>(
                            value: value,
                            child: Text(value.displayName(), style: mainProvider.itemStyle),
                          );
                        }).toList(),
                        onChanged: <ETypePrices>(value) {
                          setState(() {
                            typePrices = value;
                            Preferences.typePrices = typePrices;
                          });
                        },
                      ),
                    if (typeHistory == ETypeHistory.shoppings)
                      DropdownButton(
                        borderRadius: BorderRadius.circular(20),
                        dropdownColor: Utils.claro,
                        isExpanded: false,
                        value: typeShoppings,
                        underline: Container(),
                        items: ETypeShoppings.values
                            .map<DropdownMenuItem<ETypeShoppings>>((ETypeShoppings value) {
                          return DropdownMenuItem<ETypeShoppings>(
                            value: value,
                            child: Text(value.displayName(), style: mainProvider.itemStyle),
                          );
                        }).toList(),
                        onChanged: <ETypeShoppings>(value) {
                          setState(() {
                            typeShoppings = value;
                            Preferences.typeShoppings = typeShoppings;
                          });
                        },
                      ),
                  ],
                ),
                children: [
                  if (typeShoppings == ETypeShoppings.nogroup) _order(),
                  _shops(),
                  _dates(),
                  _search(),
                  _totalPrice(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _search() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return AnimatedContainer(
                height: 45,
                duration: const Duration(milliseconds: 400),
                margin: const EdgeInsets.all(10),
                width: _isSearchExpanded ? constraints.maxWidth : 50,
                decoration: BoxDecoration(
                  color: Colors.white54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: controller,
                  maxLength: 20,
                  onChanged: (value) => _filterHistory(),
                  onTapOutside: (event) => FocusScope.of(context).unfocus(),
                  style: mainProvider.itemStyle,
                  decoration: InputDecoration(
                    border: border,
                    enabledBorder: border,
                    focusedBorder: border,
                    counterText: '',
                    hintText: 'Buscar',
                    hintStyle: TextStyle(fontSize: 15.0, color: Utils.medio),
                    prefixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          controller.clear();
                          _isSearchExpanded = !_isSearchExpanded;
                          history = mainProvider.shoppingHistory;
                          FocusScope.of(context).unfocus();
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 7),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          widthFactor: 1,
                          heightFactor: 2,
                          child: AnimatedCrossFade(
                            secondChild: Icon(Icons.arrow_back_ios_new_rounded,
                                color: Utils.oscuro, size: 30),
                            firstChild: Icon(Icons.search, color: Utils.oscuro, size: 30),
                            crossFadeState: !_isSearchExpanded
                                ? CrossFadeState.showFirst
                                : CrossFadeState.showSecond,
                            duration: const Duration(milliseconds: 500),
                            firstCurve: Curves.easeIn,
                            secondCurve: Curves.easeIn,
                          ),
                        ),
                      ),
                    ),
                    suffixIcon: controller.text.isNotEmpty && _isSearchExpanded
                        ? GestureDetector(
                            onTap: () {
                              setState(
                                () {
                                  controller.clear();
                                  _filterHistory();
                                },
                              );
                            },
                            child: Icon(Icons.close, color: Utils.oscuro),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              );
            },
          ),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => Navigator.pushNamed(context, ChartPage.routeName,
                arguments: [history, startDate, finishDate]),
            child: Icon(Icons.pie_chart_rounded, color: Utils.oscuro, size: 40),
          ),
        ),
      ],
    );
  }

  Widget _dates() {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Utils.claro,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Utils.oscuro),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            children: [
              Text(
                  startDate == null
                      ? '--/--/----'
                      : Utils.dateEnglishToSpanish(startDate.toString(), showTime: false),
                  style: mainProvider.itemStyle),
              const SizedBox(width: 10),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () async {
                    final resp = await showDate(context, initialDate: startDate);
                    if (resp != null) {
                      setState(() {
                        startDate = resp;
                        _filterHistory();
                      });
                    }
                  },
                  child: Icon(
                    Icons.calendar_month_outlined,
                    color: Utils.oscuro,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                  finishDate == null
                      ? '--/--/----'
                      : Utils.dateEnglishToSpanish(finishDate.toString(), showTime: false),
                  style: mainProvider.itemStyle),
              const SizedBox(width: 10),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () async {
                    final resp = await showDate(context, initialDate: finishDate);
                    if (resp != null) {
                      setState(() {
                        finishDate = resp;
                        _filterHistory();
                      });
                    }
                  },
                  child: Icon(
                    Icons.calendar_month_outlined,
                    color: Utils.oscuro,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          if (startDate != null || finishDate != null)
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  startDate = null;
                  finishDate = null;
                  _filterHistory();
                },
                child: Icon(Icons.close, color: Utils.oscuro, size: 30),
              ),
            ),
        ],
      ),
    );
  }

  Widget _shops() {
    List<Shop> shops = mainProvider.shoppingHistory.map((e) => e.shop).toSet().toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Utils.claro,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Utils.oscuro),
      ),
      child: Row(
        children: [
          Text('Tienda:', style: mainProvider.itemStyle),
          Expanded(
            child: DropdownButton(
              borderRadius: BorderRadius.circular(20),
              dropdownColor: Utils.claro,
              isExpanded: true,
              underline: Container(),
              value: selectedShop,
              padding: EdgeInsets.only(left: 20),
              items: shops
                  .map((s) => DropdownMenuItem<Shop>(
                      value: s, child: Text(s.name.toUpperCase(), style: mainProvider.itemStyle)))
                  .toList(),
              onChanged: <Shop>(value) {
                setState(() {
                  selectedShop = value;
                  _filterHistory();
                });
              },
            ),
          ),
          const SizedBox(width: 10),
          if (selectedShop != null)
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  selectedShop = null;
                  _filterHistory();
                },
                child: Icon(Icons.close, color: Utils.oscuro, size: 30),
              ),
            ),
        ],
      ),
    );
  }

  Widget _order() {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Utils.claro,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Utils.oscuro),
      ),
      child: Row(
        children: [
          Text('Ordenar:', style: mainProvider.itemStyle),
          Expanded(
            child: DropdownButton(
              borderRadius: BorderRadius.circular(20),
              dropdownColor: Utils.claro,
              isExpanded: true,
              underline: Container(),
              value: selectedOrderNoGroup,
              padding: EdgeInsets.only(left: 20),
              items: EOrderNoGroup.values
                  .map((s) => DropdownMenuItem<EOrderNoGroup>(
                      value: s, child: Text(s.displayName(), style: mainProvider.itemStyle)))
                  .toList(),
              onChanged: <EOrderNoGroup>(value) {
                setState(() {
                  selectedOrderNoGroup = value;
                  _filterHistory();
                });
              },
            ),
          ),
          const SizedBox(width: 10),
          if (selectedShop != null)
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  selectedShop = null;
                  _filterHistory();
                },
                child: Icon(Icons.close, color: Utils.oscuro, size: 30),
              ),
            ),
        ],
      ),
    );
  }

  Widget _totalPrice() {
    final double totalPrice =
        history.fold<double>(0, (sum, item) => sum + (item.quantity * item.price));
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: Utils.claro,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text('TOTAL: ${totalPrice.toStringAsFixed(2)}€', style: mainProvider.itemStyle),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              setState(() {
                selectedShop = null;
                controller.text = '';
                startDate = null;
                finishDate = null;
                _filterHistory();
              });
            },
            child: Icon(Icons.delete, size: 40, color: Utils.oscuro),
          ),
        ),
      ],
    );
  }

  Widget _history() {
    if (typeHistory == ETypeHistory.shoppings) {
      if (history.isNotEmpty) {
        switch (typeShoppings) {
          case ETypeShoppings.nogroup:
            return HistoryListProductWidget(
                historicoCompras: history, //..sort((a, b) => b.date.compareTo(a.date)),
                canDelete: true,
                isProduct: false);
          case ETypeShoppings.byProduct:
            List<Product> products = history.map((e) => e.product).toSet().toList();
            return SliverList.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final List<ShoppingHistory> shoppingList =
                    history.where((h) => h.product.id == products[index].id).toList();
                return HistoryByProductWidget(shoppingHistory: shoppingList);
              },
            );
          case ETypeShoppings.byShop:
            List<Shop> shops = history.map((e) => e.shop).toSet().toList();
            return SliverList.builder(
              itemCount: shops.length,
              itemBuilder: (context, index) {
                final List<ShoppingHistory> shoppingList =
                    history.where((h) => h.shop.id == shops[index].id).toList();
                return HistoryByShopWidget(shoppingHistory: shoppingList);
              },
            );
          case ETypeShoppings.byCart:
            List<String> idCarts = history.map((e) => e.cartId).toSet().toList();
            return SliverList.builder(
              itemCount: idCarts.length,
              itemBuilder: (context, index) {
                final List<ShoppingHistory> shoppingList =
                    history.where((h) => h.cartId == idCarts[index]).toList();
                return HistoryByShoppingWidget(shoppingHistory: shoppingList);
              },
            );
          case ETypeShoppings.total:
            return HistoryTotalShoppingWidget(shoppingHistory: history);
        }
      } else {
        return SliverFillRemaining(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('No hay compras guardadas', style: mainProvider.titleStyle),
                const SizedBox(height: 20),
                Icon(Icons.remove_shopping_cart_rounded, size: 100, color: Utils.medio),
              ],
            ),
          ),
        );
      }
    } else {
      if (mainProvider.pricesHistory.isNotEmpty) {
        switch (typePrices) {
          case ETypePrices.byShop:
            return PriceGroupWidget(type: ETypeHistoryGroup.shop);
          case ETypePrices.byProduct:
          default:
            return PriceGroupWidget(type: ETypeHistoryGroup.product);
        }
      } else {
        return SliverFillRemaining(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('No hay precios', style: mainProvider.titleStyle),
              const SizedBox(height: 20),
              Icon(Icons.euro_rounded, size: 100, color: Utils.medio),
            ],
          ),
        );
      }
    }
  }

  Future<void> _filterHistory() async {
    String value = controller.text;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          history = value.isEmpty
              ? mainProvider.shoppingHistory
              : mainProvider.shoppingHistory
                  .where((h) => Utils.quitarTildes(h.product.name.toUpperCase())
                      .contains(Utils.quitarTildes(value.toUpperCase())))
                  .toList();
          if (startDate != null || finishDate != null) {
            history = history.where((h) {
              final date = h.date;
              if (startDate != null && finishDate != null) {
                return Utils.isBetweenDays(date, startDate!, finishDate!);
              } else if (startDate != null) {
                return Utils.isSameOrAfterDay(date, startDate!);
              } else if (finishDate != null) {
                return Utils.isSameOrBeforeDay(date, finishDate!);
              }
              return true;
            }).toList();
          }
          if (selectedShop != null) {
            history = history.where((h) => h.shop.id == selectedShop!.id).toList();
          }
          if (typeShoppings == ETypeShoppings.nogroup) {
            switch (selectedOrderNoGroup) {
              case EOrderNoGroup.fechaAsc:
                history.sort((a, b) => a.date.compareTo(b.date));
                break;
              case EOrderNoGroup.fechaDesc:
                history.sort((a, b) => b.date.compareTo(a.date));
                break;
              case EOrderNoGroup.precioAsc:
                history.sort((a, b) => a.price.compareTo(b.price));
                break;
              case EOrderNoGroup.precioDesc:
                history.sort((a, b) => b.price.compareTo(a.price));
                break;
              case EOrderNoGroup.cantidadAsc:
                history.sort((a, b) => a.quantity.compareTo(b.quantity));
                break;
              case EOrderNoGroup.cantidadDesc:
                history.sort((a, b) => b.quantity.compareTo(a.quantity));
                break;
            }
          }
        });
      }
    });
  }
}
