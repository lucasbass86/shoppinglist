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

class ProductPage extends StatefulWidget {
  static const String routeName = 'ProductPage';
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> with SingleTickerProviderStateMixin {
  late MainProvider mainProvider;
  late List<ProductShop> productosAct;
  late List<ShoppingHistory> historicoCompras;
  late List<PriceHistory> historico;
  late Product product;
  bool simpleListPrices = false;

  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _shadowAnimation;
  String selectedShopName = 'TODAS';
  List<String> yearsOfDropDown = [];
  String selectedYear = 'TODOS';
  List<Color> shuffledList = List.from(Utils.palettes);

  final PageController graphicPageController = PageController(initialPage: 0);
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true); // Repite hacia arriba y abajo

    _animation = Tween<double>(begin: 0, end: 40).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _shadowAnimation = Tween<double>(begin: 150, end: 20).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    shuffledList.shuffle(Random());
  }

  @override
  void dispose() {
    _controller.dispose(); // Libera el controlador
    graphicPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    product = ModalRoute.of(context)!.settings.arguments as Product;
    mainProvider = Provider.of<MainProvider>(context);
    historico = mainProvider.priceHistoryByProduct(product);

    productosAct = mainProvider.productsShops.where((p) => p.product.id == product.id).toList();
    historicoCompras = mainProvider.loadshoppingHistoryByProduct(product);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        //physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()), // Forzar desplazamiento
        slivers: [
          _mainTop(),
          _sliverTop(),
          ..._toShow(),
        ],
      ),
    );
  }

  Widget _mainTop() {
    final Image image = Image(image: product.imageType.image(), width: 200, height: 200);
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
                    left: 0,
                    right: 0,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) => Container(
                          width: _shadowAnimation.value,
                          height: _shadowAnimation.value * 50 / 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: SizedBox(
                      width: 200,
                      height: 200,
                      child: Hero(
                        tag: '${Utils.tagProduct}${product.id}',
                        child: AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, -_animation.value),
                              child: child,
                            );
                          },
                          child: Draggable<Product>(
                            data: product,
                            feedback:
                                FeedbackProductWidget(image: image, quantity: 1, imageSize: 200),
                            childWhenDragging: WhenDraggin(type: product.imageType),
                            child: image,
                          ),
                        ),
                      ),
                    ),
                  ),
                  lateralFunctions(context, mainProvider),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget lateralFunctions(BuildContext context, MainProvider mainProvider) {
    return Positioned(
      right: 20,
      top: 0,
      child: FadeInRight(
        child: Column(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  Navigator.pushNamed(context, NewProductPage.routeName, arguments: product)
                      .then((value) {
                    setState(() {});
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
                  if (mainProvider.productHasMovement(product)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        Utils.snackBar('Tiene movimientos. No se puede borrar', isGood: false));
                  } else {
                    final value = await confirmDelete(context, '¿Borrar el producto?');
                    if (value && context.mounted) {
                      final unlock = await showSlideToUnlock(context,
                          backColor: Utils.medio, slideColor: Utils.oscuro);
                      if (unlock && context.mounted) {
                        mainProvider.removeProduct(product);
                        ScaffoldMessenger.of(context)
                            .showSnackBar(Utils.snackBar('Producto borrado...'));
                        Navigator.pop(context);
                      }
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
                onTap: () => _handleAddProductPrice(context, product),
                child: Icon(Icons.euro, color: Utils.claro, size: 40),
              ),
            ),
            const SizedBox(height: 10),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  if (mainProvider.shops.isNotEmpty) {
                    showShops(context, product: product).then((value) {
                      if (value[0]) {
                        mainProvider.addCart(
                            shop: mainProvider.selectedShop,
                            cartProduct: CartProduct(product: product, quantity: value[1]));
                        setState(() {});
                      }
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        Utils.snackBar('No hay tiendas creadas . . .', isGood: false));
                  }
                },
                child: Icon(Icons.shopping_basket_rounded, color: Utils.claro, size: 40),
              ),
            ),
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
              Text(product.name, style: mainProvider.titleStyle),
              if (product.details.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    product.details,
                    style: const TextStyle(color: Colors.grey, fontSize: 17),
                    textAlign: TextAlign.justify,
                  ),
                ),
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

  List<Widget> _toShow() {
    switch (Preferences.productTabIndex) {
      case EProductView.prices:
        return [sliverPrices()];
      case EProductView.estatistics:
        return [sliverStatistics()];
      case EProductView.history:
        return sliverHistory();
      case EProductView.graphics:
        return graphics();
    }
  }

  Widget sliverPrices() {
    return productosAct.isNotEmpty
        ? SliverFillRemaining(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: !Preferences.isViewGraphic
                      ? MainAxisAlignment.spaceBetween
                      : MainAxisAlignment.end,
                  children: [
                    if (!Preferences.isViewGraphic) _swipe(),
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
                Expanded(
                  child: Preferences.isViewGraphic
                      ? ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: productosAct.length,
                          itemBuilder: (context, index) {
                            final item = productosAct[index];
                            return Dismissible(
                              key: Key('${productosAct[index].id}product'),
                              confirmDismiss: (direction) async {
                                showMessage(
                                        context: context,
                                        message: '¿Borrar el precio?',
                                        cancel: true)
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
                              direction: DismissDirection.startToEnd,
                              background: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(Icons.delete, size: 40, color: Colors.red[300]),
                                ],
                              ),
                              child: PriceWidget(productShop: productosAct[index]),
                            );
                          },
                        )
                      : ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
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
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(10),
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    color: Utils.claro,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.shop.name,
                                            style: mainProvider.itemStyle,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            Utils.dateEnglishToSpanish(item.date.toString()),
                                            style: mainProvider.itemStyle.copyWith(fontSize: 13),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        '${item.price.toStringAsFixed(2)} €',
                                        style: mainProvider.itemStyle,
                                      ),
                                    ],
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
                                      context: context,
                                      message: '¿Borrar el precio?',
                                      cancel: true);
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
                          },
                        ),
                ),
              ],
            ),
          )
        : sliverNoProducts();
  }

  Widget sliverStatistics() {
    return productosAct.isNotEmpty
        ? SliverFillRemaining(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: !Preferences.isViewGraphic
                      ? MainAxisAlignment.spaceBetween
                      : MainAxisAlignment.end,
                  children: [
                    if (!Preferences.isViewGraphic) _swipe(),
                    Row(
                      children: [
                        Text('Gráfica', style: mainProvider.titleStyle.copyWith(fontSize: 17)),
                        const SizedBox(width: 7),
                        Switch(
                          value: Preferences.isViewGraphic,
                          onChanged: (value) {
                            setState(() {
                              Preferences.isViewGraphic = value;
                            });
                          },
                        ),
                        if (Preferences.isViewGraphic)
                          Row(
                            children: [
                              const SizedBox(width: 10),
                              Text('Leyenda',
                                  style: mainProvider.titleStyle.copyWith(fontSize: 13)),
                              Switch(
                                value: Preferences.showLegend,
                                onChanged: (value) {
                                  setState(() {
                                    Preferences.showLegend = value;
                                  });
                                },
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
                Expanded(child: productGraphic(product)),
              ],
            ),
          )
        : sliverNoProducts();
  }

  Widget _swipe() {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => showModalBottomSheet(
          context: context,
          builder: (context) => Container(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Desliza hacia la derecha para borrar. Hacia la izquierda para editar.',
                  style: mainProvider.itemStyle,
                ),
              )),
      child: Icon(Icons.swap_horiz_rounded, size: Utils.iconSizeStandar, color: Utils.claro),
    );
  }

  List<Widget> sliverHistory() {
    //CALCULAR TOTAL CANTIDAD Y TOTAL PRECIO:
    List<ShoppingHistory> group =
        mainProvider.shoppingHistory.where((p) => p.product.id == product.id).toList();
    final int totalQuantity = group.fold(0, (sum, item) => sum + item.quantity);
    final double totalPrice =
        group.fold<double>(0, (sum, item) => sum + (item.quantity * item.price));

    List<int> idShops = mainProvider.shoppingHistory
        .where((h) => h.product.id == product.id)
        .map((s) => s.shop.id)
        .toSet()
        .toList();

    return historicoCompras.isNotEmpty
        ? [
            SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: !Preferences.groupByShop
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.end,
                children: [
                  if (!Preferences.groupByShop)
                    Row(
                      children: [
                        _swipe(),
                        _touch(),
                      ],
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                          onTap: () =>
                              setState(() => Preferences.groupByShop = !Preferences.groupByShop),
                          child: Text('Agrupar por tienda',
                              style: mainProvider.titleStyle.copyWith(fontSize: 13))),
                      const SizedBox(width: 10),
                      Switch.adaptive(
                        value: Preferences.groupByShop,
                        onChanged: (value) =>
                            setState(() => Preferences.groupByShop = !Preferences.groupByShop),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            !Preferences.groupByShop
                ? HistoryListProductWidget(
                    historicoCompras: historicoCompras..sort((a, b) => b.date.compareTo(a.date)))
                : SliverToBoxAdapter(
                    child: Column(
                    children: [
                      ...idShops.map(
                        (id) {
                          List<ShoppingHistory> his = mainProvider.shoppingHistory
                              .where((h) => h.product.id == product.id && h.shop.id == id)
                              .toList();
                          return HistoryGroupedDetailWidget(
                              shoppingHistory: his, type: ETypeShoppings.byShop);
                        },
                      ),
                    ],
                  )),
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Utils.claro,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Utils.medio.withAlpha((255 * 0.5).toInt()), width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('Total: ${totalPrice.toStringAsFixed(2)}€',
                        style: mainProvider.titleStyle.copyWith(fontSize: 15)),
                    Text('Unidades: ${totalQuantity.toStringAsFixed(0)}',
                        style: mainProvider.titleStyle.copyWith(fontSize: 15)),
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

  Widget _touch() {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => showModalBottomSheet(
          context: context,
          builder: (context) => Container(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Pulsa para ir a la tienda. Manten pulsado para cambiar cantidad.',
                  style: mainProvider.itemStyle,
                ),
              )),
      child: Icon(Icons.touch_app, size: Utils.iconSizeStandar, color: Utils.claro),
    );
  }

  Widget sliverNoProducts() {
    return SliverFillRemaining(
      child: Center(
        child: GestureDetector(
          onTap: () => _handleAddProductPrice(context, product),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('No hay precios asociados', style: mainProvider.titleStyle),
              const SizedBox(width: 15),
              Icon(Icons.add, color: Utils.oscuro, size: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget categories(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.only(right: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SingleChildScrollView(
          clipBehavior: Clip.hardEdge,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              BounceInLeft(
                duration: Utils.fadeInDuration,
                child: category('Precios', EProductView.prices,
                    Preferences.productTabIndex == EProductView.prices),
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

  Widget productGraphic(Product product) {
    // ---------------------GENERADO POR CHATGPT
    // 1. Agrupar por tienda
    // ---------------------
    List<GroupGraphic> principal = [];
    historico.sort((a, b) => b.fecha.compareTo(a.fecha));

    for (PriceHistory h in historico) {
      final Graphic g = Graphic(h);

      principal
          .firstWhere(
            (p) => p.shop.id == h.productShop.shop.id,
            orElse: () {
              final group = GroupGraphic(shop: h.productShop.shop);
              principal.add(group);
              return group;
            },
          )
          .list
          .add(g);
    }

    // ---------------------------------------
    // 2. Construir lista completa de fechas X
    // ---------------------------------------
    final List<DateTime> allDates = historico.map((h) => h.fecha).toSet().toList()
      ..sort((a, b) => a.compareTo(b));

    // -------------------------------------------------------
    // 3. Función que alinea cada serie a TODAS las fechas X
    // -------------------------------------------------------
    List<Graphic?> fillSeries(List<Graphic> data, List<DateTime> dates) {
      final map = {
        for (var g in data) g.historicoPrecio.fecha: g,
      };

      return dates.map((date) => map[date]).toList();
    }

    // -----------------------------
    // 4. Crear todas las series
    // -----------------------------
    List<CartesianSeries<Graphic?, String>> graf = [];
    for (GroupGraphic g in principal) {
      final List<Graphic?> aligned = fillSeries(g.list, allDates);
      if (g.list.length == 1) {
        graf.add(
          BubbleSeries<Graphic?, String>(
            dataSource: aligned,
            xValueMapper: (Graphic? hist, i) => allDates[i].toString().substring(0, 10),
            yValueMapper: (Graphic? hist, _) => hist?.historicoPrecio.productShop.price,
            name: g.shop.name,
            legendItemText: g.shop.name,
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
              color: mainProvider.itemStyle.color,
            ),
            onPointLongPress: (details) {
              final Graphic? item = aligned[details.pointIndex!];
              if (item == null) return;

              final PriceHistory hist = item.historicoPrecio;
              showMessage(
                context: context,
                cancel: true,
                message: '¿Eliminar el histórico del producto?',
                secondMessage: 'Tienda: ${hist.productShop.shop.name}\r\n'
                    'Precio: ${hist.productShop.price.toStringAsFixed(2)}€\r\n'
                    'Fecha: ${Utils.dateEnglishToSpanish(hist.fecha.toString(), showTime: false)}',
              ).then((value) {
                if (value) {
                  mainProvider.deleteHistoricoPrecio(hist);
                  setState(() {});
                }
              });
            },
          ),
        );
      } else {
        graf.add(
          LineSeries<Graphic?, String>(
            dataSource: aligned,
            xValueMapper: (Graphic? hist, i) => allDates[i].toString().substring(0, 10),
            yValueMapper: (Graphic? hist, _) => hist?.historicoPrecio.productShop.price,
            markerSettings: const MarkerSettings(isVisible: true),
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
              color: mainProvider.itemStyle.color,
            ),
            name: g.shop.name,
            legendItemText: g.shop.name,
            emptyPointSettings: EmptyPointSettings(mode: EmptyPointMode.drop),
            onPointLongPress: (details) {
              final Graphic? item = aligned[details.pointIndex!];
              if (item == null) return;

              final PriceHistory hist = item.historicoPrecio;
              showMessage(
                context: context,
                cancel: true,
                message: '¿Eliminar el histórico del producto?',
                secondMessage: 'Tienda: ${hist.productShop.shop.name}\r\n'
                    'Precio: ${hist.productShop.price.toStringAsFixed(2)}€\r\n'
                    'Fecha: ${Utils.dateEnglishToSpanish(hist.fecha.toString(), showTime: false)}',
              ).then((value) {
                if (value) {
                  mainProvider.deleteHistoricoPrecio(hist);
                  setState(() {});
                }
              });
            },
          ),
        );
      }
    }

    if (historico.isEmpty) {
      return Expanded(
        child: Center(
          child: Text('No hay compras', style: mainProvider.titleStyle),
        ),
      );
    }

    return Preferences.isViewGraphic
        ? ZoomIn(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Utils.claro,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Utils.oscuro,
                  width: 1,
                ),
              ),
              child: RepaintBoundary(
                child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(
                    labelRotation: 45,
                    labelStyle: const TextStyle(fontSize: 10),
                    axisLabelFormatter: (details) {
                      final fechaEsp = Utils.dateEnglishToSpanish(details.text, showTime: false);
                      return ChartAxisLabel(fechaEsp, details.textStyle);
                    },
                  ),
                  primaryYAxis: NumericAxis(labelFormat: '{value}€'),
                  legend: Legend(
                    isVisible: Preferences.showLegend,
                    textStyle: TextStyle(color: mainProvider.itemStyle.color),
                  ),
                  tooltipBehavior: TooltipBehavior(enable: true),
                  series: graf,
                  zoomPanBehavior: ZoomPanBehavior(
                    enablePinching: true,
                    enableDoubleTapZooming: true,
                    enableSelectionZooming: true,
                    enableMouseWheelZooming: true,
                    enablePanning: true,
                  ),
                ),
              ),
            ),
          )
        : ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: principal.length,
            separatorBuilder: (BuildContext context, int index) => SizedBox(height: 15),
            itemBuilder: (context, index) {
              return FadeInLeft(
                delay: Duration(milliseconds: 100 * index),
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
                        spacing: 10,
                        children: [
                          Image.asset(Utils.assetShop, width: 30, height: 30),
                          Text(principal[index].shop.name,
                              style: TextStyle(color: Utils.oscuro, fontSize: 21)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: principal[index].list.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index2) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Dismissible(
                              key: Key(principal[index].list[index2].historicoPrecio.id.toString()),
                              background: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(Icons.delete, size: 20, color: Colors.red[300]),
                                  Icon(Icons.edit, size: 20, color: Colors.green[300]),
                                ],
                              ),
                              confirmDismiss: (direction) async {
                                bool ret = true;

                                if (direction == DismissDirection.startToEnd) {
                                  await showMessage(
                                          context: context,
                                          message: '¿Borrar el precio?',
                                          cancel: true)
                                      .then((value) {
                                    if (value) {
                                      ret = true;
                                      mainProvider.deleteHistoricoPrecio(
                                          principal[index].list[index2].historicoPrecio);
                                    } else {
                                      ret = false;
                                    }
                                  });
                                } else {
                                  DateTime? date =
                                      principal[index].list[index2].historicoPrecio.fecha;
                                  final c = await showProductPrice(context, productosAct[index]);
                                  if (c[0] && context.mounted) {
                                    final value = await showDate(context, initialDate: date);
                                    if (value != null) {
                                      date = DateTime(value.year, value.month, value.day,
                                          DateTime.now().hour + 1, DateTime.now().minute);
                                    }
                                    mainProvider.calculateAmount();
                                    principal[index].list[index2].historicoPrecio.fecha = date;
                                    principal[index]
                                        .list[index2]
                                        .historicoPrecio
                                        .productShop
                                        .price = c[1];
                                    mainProvider.updateHistoricoPrecio(
                                        principal[index].list[index2].historicoPrecio);
                                    ret = true;
                                  }
                                  ret = false;
                                }
                                setState(() {});
                                return ret;
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    Utils.dateEnglishToSpanish(
                                        principal[index]
                                            .list[index2]
                                            .historicoPrecio
                                            .fecha
                                            .toString(),
                                        showTime: false),
                                    style: TextStyle(color: Utils.oscuro, fontSize: 17),
                                  ),
                                  Text(
                                    '${principal[index].list[index2].historicoPrecio.productShop.price.toStringAsFixed(2)} €',
                                    style: TextStyle(color: Utils.oscuro, fontSize: 17),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  List<Widget> graphics() {
    List<ShoppingHistory> selected = historicoCompras;
    List<CircularSeries<dynamic, dynamic>> series = [];
    List<ColumnSeries<dynamic, dynamic>> seriesLinear = [];
    late Widget listView;
    double totalAmount = 0;

    //COMPROBAR QUE TIENE HISTORICO:
    if (selected.isEmpty) {
      return [
        SliverFillRemaining(
          child: Center(
            child: Text('No hay compras', style: mainProvider.titleStyle),
          ),
        )
      ];
    }
    List<String> names = ['TODAS'];
    names.addAll(historicoCompras.map((h) => h.shop.name).toSet().toList());
    if (selectedShopName != 'TODAS') {
      selected = selected.where((h) => h.shop.name == selectedShopName).toList();
    }
    List<Shop> shops = selectedYear == 'TODOS'
        ? selected.map((s) => s.shop).toSet().toList()
        : selected
            .where((s) => s.date.year == int.parse(selectedYear))
            .map((s) => s.shop)
            .toSet()
            .toList();

    //PARA TODAS LAS TIENDAS
    if (selectedShopName == 'TODAS') {
      Map<Shop, double> groupedByShop = {};
      for (Shop s in shops) {
        if (selectedYear == 'TODOS') {
          final shop = <Shop, double>{
            s: selected.where((h) => h.shop.id == s.id).fold<double>(
                0,
                (sum, item) => Preferences.graphicByAmount
                    ? sum + (item.quantity * item.price)
                    : sum + item.quantity)
          };
          groupedByShop.addEntries(shop.entries);
        } else {
          final shop = <Shop, double>{
            s: selected
                .where((h) => h.shop.id == s.id && h.date.year == int.parse(selectedYear))
                .fold<double>(
                    0,
                    (sum, item) => Preferences.graphicByAmount
                        ? sum + (item.quantity * item.price)
                        : sum + item.quantity)
          };
          groupedByShop.addEntries(shop.entries);
        }
      }
      List<_PieDataShops> data = [];
      for (var v in groupedByShop.entries) {
        if (v.value > 0) {
          data.add(_PieDataShops(v.key.name, v.value));
          totalAmount += v.value;
        }
      }
      series = [
        PieSeries<_PieDataShops, String>(
          explode: true,
          explodeIndex: 0,
          dataSource: data,
          xValueMapper: (_PieDataShops data, _) => data.shopName,
          yValueMapper: (_PieDataShops data, _) => data.quantity,
          dataLabelMapper: (_PieDataShops data, _) => Preferences.graphicByAmount
              ? '${data.quantity.toStringAsFixed(2)}€'
              : data.quantity.toStringAsFixed(0),
          dataLabelSettings: DataLabelSettings(isVisible: true),
        )
      ];
      seriesLinear = [
        ColumnSeries<_PieDataShops, String>(
          dataSource: data,
          name: 'Total Tienda',
          xValueMapper: (_PieDataShops data, _) => data.shopName,
          yValueMapper: (_PieDataShops data, _) => data.quantity,
          dataLabelMapper: (_PieDataShops data, _) => Preferences.graphicByAmount
              ? '${data.quantity.toStringAsFixed(2)}€'
              : data.quantity.toStringAsFixed(0),
          dataLabelSettings: DataLabelSettings(isVisible: true),
          pointColorMapper: (data, index) => shuffledList[Random().nextInt(shuffledList.length)],
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
                  spacing: 7,
                  children: [
                    Image.asset(Utils.assetShop, width: 20, height: 20),
                    Text(data[index].shopName, style: mainProvider.itemStyle),
                  ],
                ),
                Text(
                    Preferences.graphicByAmount
                        ? '${data[index].quantity.toStringAsFixed(2)}€'
                        : data[index].quantity.toStringAsFixed(0),
                    style: mainProvider.itemStyle),
              ],
            ),
          );
        },
      );
    }

    //PARA UNA TIENDA EN PARTICULAR
    if (selectedShopName != 'TODAS' && selectedYear == 'TODOS') {
      Map<String, double> groupedByShopYears = {};
      List<String> yearsOfShop = [];
      yearsOfShop = selected.map((h) => h.date.year.toString()).toSet().toList();
      if (yearsOfShop.length == 1) {
        setState(() {
          selectedYear = yearsOfShop[0];
        });
      }

      for (String year in yearsOfShop) {
        final entry = <String, double>{
          year: selected.where((h) => h.date.year.toString() == year).fold<double>(
              0,
              (sum, item) => Preferences.graphicByAmount
                  ? sum + (item.quantity * item.price)
                  : sum + item.quantity)
        };
        groupedByShopYears.addEntries(entry.entries);
      }
      List<_PieDataShopYears> data = [];
      for (var v in groupedByShopYears.entries) {
        if (v.value > 0) {
          data.add(_PieDataShopYears(v.key, v.value));
          totalAmount += v.value;
        }
      }
      series = [
        PieSeries<_PieDataShopYears, String>(
          explode: true,
          explodeIndex: 0,
          dataSource: data,
          xValueMapper: (_PieDataShopYears data, _) => data.year,
          yValueMapper: (_PieDataShopYears data, _) => data.quantity,
          dataLabelMapper: (_PieDataShopYears data, _) => Preferences.graphicByAmount
              ? '${data.quantity.toStringAsFixed(2)}€'
              : data.quantity.toStringAsFixed(0),
          dataLabelSettings: DataLabelSettings(isVisible: true),
        ),
      ];
      seriesLinear = [
        ColumnSeries<_PieDataShopYears, int>(
          dataSource: data,
          name: selectedShopName,
          xValueMapper: (_PieDataShopYears data, _) => int.parse(data.year),
          yValueMapper: (_PieDataShopYears data, _) => data.quantity,
          dataLabelMapper: (_PieDataShopYears data, _) => Preferences.graphicByAmount
              ? '${data.quantity.toStringAsFixed(2)}€'
              : data.quantity.toStringAsFixed(0),
          dataLabelSettings: DataLabelSettings(isVisible: true),
          pointColorMapper: (data, index) => shuffledList[Random().nextInt(shuffledList.length)],
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
                Text(data[index].year, style: mainProvider.itemStyle),
                Text(
                    Preferences.graphicByAmount
                        ? '${data[index].quantity.toStringAsFixed(2)}€'
                        : data[index].quantity.toStringAsFixed(0),
                    style: mainProvider.itemStyle),
              ],
            ),
          );
        },
      );
    }

    if (selectedShopName != 'TODAS' && selectedYear != 'TODOS') {
      Map<int, double> groupedByShopYear = {};
      List<int> monthsOfShopByYear = [];
      monthsOfShopByYear = selected
          .where((h) => h.date.year.toString() == selectedYear)
          .map((r) => r.date.month)
          .toSet()
          .toList();
      for (int month in monthsOfShopByYear) {
        final entry = <int, double>{
          month: selected
              .where((h) => h.date.year.toString() == selectedYear && h.date.month == month)
              .fold<double>(
                  0,
                  (sum, item) => Preferences.graphicByAmount
                      ? sum + (item.quantity * item.price)
                      : sum + item.quantity)
        };
        groupedByShopYear.addEntries(entry.entries);
      }
      List<_PieDataShopYear> data = [];
      for (var v in groupedByShopYear.entries) {
        if (v.value > 0) {
          data.add(_PieDataShopYear(v.key, v.value));
          totalAmount += v.value;
        }
      }

      switch (Preferences.graphicProductGeneralOrder) {
        case EOrderGraphic.ascendingMonth:
          data.sort((a, b) => a.month.compareTo(b.month));
          break;
        case EOrderGraphic.descendingMonth:
          data.sort((a, b) => b.month.compareTo(a.month));
          break;
        case EOrderGraphic.amountAsc:
          data.sort((a, b) => a.quantity.compareTo(b.quantity));
          break;
        case EOrderGraphic.amountDesc:
          data.sort((a, b) => b.quantity.compareTo(a.quantity));
          break;
      }

      series = [
        PieSeries<_PieDataShopYear, String>(
          explode: true,
          explodeIndex: 0,
          dataSource: data,
          xValueMapper: (_PieDataShopYear data, _) => data.monthName,
          yValueMapper: (_PieDataShopYear data, _) => data.quantity,
          dataLabelMapper: (_PieDataShopYear data, _) => Preferences.graphicByAmount
              ? '${data.quantity.toStringAsFixed(2)}€'
              : data.quantity.toStringAsFixed(0),
          dataLabelSettings: DataLabelSettings(isVisible: true),
        )
      ];
      seriesLinear = [
        ColumnSeries<_PieDataShopYear, String>(
          dataSource: data,
          name: '$selectedShopName: $selectedYear',
          xValueMapper: (_PieDataShopYear data, _) => data.monthName,
          yValueMapper: (_PieDataShopYear data, _) => data.quantity,
          dataLabelMapper: (_PieDataShopYear data, _) => Preferences.graphicByAmount
              ? '${data.quantity.toStringAsFixed(2)}€'
              : data.quantity.toStringAsFixed(0),
          dataLabelSettings: DataLabelSettings(isVisible: true),
          pointColorMapper: (data, index) => shuffledList[Random().nextInt(shuffledList.length)],
        )
      ];
      listView = ListView.builder(
        physics: const ClampingScrollPhysics(),
        shrinkWrap: true,
        itemCount: data.length,
        itemBuilder: (context, index) {
          return Padding(
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
                Text(
                    Preferences.graphicByAmount
                        ? '${data[index].quantity.toStringAsFixed(2)}€'
                        : data[index].quantity.toStringAsFixed(0),
                    style: mainProvider.itemStyle),
              ],
            ),
          );
        },
      );
    }

    yearsOfDropDown.clear();
    yearsOfDropDown.add('TODOS');
    yearsOfDropDown.addAll(selected.map((h) => h.date.year.toString()).toSet().toList());

    if (selected.isEmpty) {
      return [
        SliverFillRemaining(
          child: Text(
            'Sin datos . . .',
            style: mainProvider.mainTitleStyle,
          ),
        )
      ];
    } else {
      return [
        SliverToBoxAdapter(
          child: Column(
            children: [
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                spacing: 10,
                children: [
                  DropdownButton(
                    borderRadius: BorderRadius.circular(20),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    dropdownColor: Utils.claro,
                    isExpanded: false,
                    value: selectedShopName,
                    underline: Container(),
                    alignment: Alignment.center,
                    items: names.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value.toUpperCase(), style: mainProvider.itemStyle),
                      );
                    }).toList(),
                    onChanged: <String>(value) {
                      selectedShopName = value;
                      selectedYear = 'TODOS';
                    },
                  ),
                  DropdownButton(
                    borderRadius: BorderRadius.circular(20),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    dropdownColor: Utils.claro,
                    isExpanded: false,
                    value: selectedYear,
                    underline: Container(),
                    alignment: Alignment.center,
                    items: yearsOfDropDown.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value.toUpperCase(), style: mainProvider.itemStyle),
                      );
                    }).toList(),
                    onChanged: <String>(value) {
                      selectedYear = value;
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
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
                            tooltipBehavior: TooltipBehavior(enable: true),
                          ),
                        ),
                        RepaintBoundary(
                          child: SfCartesianChart(
                            primaryXAxis: const CategoryAxis(
                              labelRotation: 45,
                              labelStyle: TextStyle(fontSize: 12),
                            ),
                            primaryYAxis: NumericAxis(
                              title: AxisTitle(
                                  text: Preferences.graphicByAmount ? 'Importe' : 'Cantidad'),
                              minimum: 0,
                              labelFormat: '{value}',
                              numberFormat: NumberFormat.decimalPatternDigits(
                                  decimalDigits: Preferences.graphicByAmount ? 2 : 0),
                            ),
                            palette: shuffledList,
                            legend: Legend(isVisible: false),
                            tooltipBehavior: TooltipBehavior(enable: true),
                            series: seriesLinear,
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
                  if (selectedShopName != 'TODAS')
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
                          value: Preferences.graphicProductGeneralOrder,
                          items: EOrderGraphic.values
                              .map((o) => DropdownMenuItem(value: o, child: Text(o.displayName())))
                              .toList(),
                          onChanged: (value) {
                            if (value != Preferences.graphicProductGeneralOrder) {
                              setState(() {
                                Preferences.graphicProductGeneralOrder = value!;
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
                  Divider(
                    color: Utils.oscuro,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total', style: mainProvider.itemStyle),
                      Text(
                          Preferences.graphicByAmount
                              ? '${totalAmount.toStringAsFixed(2)}€'
                              : totalAmount.toStringAsFixed(0),
                          style: mainProvider.itemStyle),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ];
    }
  }

  Future<void> _handleAddProductPrice(BuildContext context, Product product) async {
    if (mainProvider.shops.isNotEmpty) {
      // final isShopAdded = await addShopPrice(context, product);
      // if (isShopAdded) {
      final shop = await showShops(context, showQuantity: false);
      if (shop[0]) {
        // ProductShop productShop =mainProvider.newProductShop(product, mainProvider.selectedShop, 0);
        ProductShop productShop = ProductShop(mainProvider.getIndexProductShop(), product,
            mainProvider.selectedShop, 0, DateTime.now());
        if (context.mounted) {
          productShop.price = mainProvider.getProductPrice(product, mainProvider.selectedShop);
          final isPriceConfirmed = await showProductPrice(context, productShop);
          if (isPriceConfirmed[0]) {
            mainProvider.addProductShop(productShop);
            mainProvider.addHistoricoPrecio(productShop);
          }
        }
      }
      // }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(Utils.snackBar('No hay tiendas creadas', isGood: false));
    }
  }
}

class _PieDataShops {
  final String shopName;
  final double quantity;
  _PieDataShops(this.shopName, this.quantity);
}

class _PieDataShopYears {
  final String year;
  final double quantity;
  _PieDataShopYears(this.year, this.quantity);
}

class _PieDataShopYear {
  final int month;
  final double quantity;
  String? monthName;
  _PieDataShopYear(this.month, this.quantity) {
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
