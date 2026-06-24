import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shoppinglist/models/models.dart';
import 'package:shoppinglist/pages/_pages.dart';
import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/utils/enums.dart';
import 'package:shoppinglist/utils/utils.dart';
import 'package:shoppinglist/widgets/_widgets.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartPage extends StatefulWidget {
  static const String routeName = 'ChartPage';
  const ChartPage({super.key});

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  ETypePrices typeGraphicData = ETypePrices.byShop;
  List<Color> palette = List.from(Utils.palettes);

  @override
  void initState() {
    super.initState();
    palette.shuffle(Random());
  }

  @override
  Widget build(BuildContext context) {
    MainProvider mainProvider = Provider.of(context, listen: false);
    // List<ShoppingHistory> history =ModalRoute.of(context)!.settings.arguments as List<ShoppingHistory>;
    DateTime? startDate;
    DateTime? finisDate;
    late List<ShoppingHistory> history;
    final params = (ModalRoute.of(context)?.settings.arguments as List?) ?? [];
    history = params[0];
    if (params[1] != null) {
      startDate = params[1];
      history.where((h) => h.date.isAfter(startDate!));
    }
    if (params[2] != null) {
      finisDate = params[2];
      history.where((h) => h.date.isBefore(finisDate!));
    }
    List<ColumnSeries> series = [];
    Map<Shop, Map<Product, double>> allShoppings = {};
    Map<Product, double> allProducts = {};

    if (typeGraphicData == ETypePrices.byShop) {
      //OBTENER UNA LISTA DE LAS TIENDAS:
      List<Shop> shops = history.map((h) => h.shop).toSet().toList();
      for (Shop s in shops) {
        List<ShoppingHistory> hist = history.where((h) => h.shop.id == s.id).toList();
        List<Product> products = hist.map((p) => p.product).toSet().toList();
        products.sort((a, b) => a.name.compareTo(b.name));
        Map<Product, double> pQ = {};
        for (Product p in products) {
          double q = hist.where((h) => h.product.id == p.id).fold<double>(
              0, (previousValue, element) => previousValue + (element.quantity * element.price));
          final pq = <Product, double>{p: q};
          pQ.addEntries(pq.entries);
        }
        allShoppings.addEntries({s: pQ}.entries);
      }

      for (var s in allShoppings.entries) {
        List<ChartData> chartData0 = [];
        for (var e in s.value.entries) {
          chartData0.add(ChartData(e.key, e.value));
        }
        ColumnSeries columnSerie = ColumnSeries<ChartData, String>(
          dataSource: chartData0,
          xValueMapper: (ChartData data, _) => data.product.name,
          yValueMapper: (ChartData data, _) => data.amount,
          name: s.key.name,
          dataLabelSettings: const DataLabelSettings(isVisible: true),
        );
        series.add(columnSerie);
      }
    } else {
      //OBTENER UNA LISTA DE LOS PRODUCTOS:
      List<Product> products = history.map((h) => h.product).toSet().toList();
      products.sort((a, b) => a.name.compareTo(b.name));
      for (Product p in products) {
        List<ShoppingHistory> hist = history.where((h) => h.product.id == p.id).toList();
        double q = hist.where((h) => h.product.id == p.id).fold<double>(
            0, (previousValue, element) => previousValue + (element.quantity * element.price));
        allProducts.addEntries({p: q}.entries);
      }

      for (var s in allProducts.entries) {
        List<ChartData> chartData0 = [];
        chartData0.add(ChartData(s.key, s.value));
        ColumnSeries columnSerie = ColumnSeries<ChartData, String>(
          dataSource: chartData0,
          xValueMapper: (ChartData data, _) => data.product.name,
          yValueMapper: (ChartData data, _) => data.amount,
          name: s.key.name,
          dataLabelSettings: const DataLabelSettings(isVisible: true),
        );
        series.add(columnSerie);
      }
    }

    return Scaffold(
      body: Stack(
        children: [
          BackgroundWidget(),
          SingleChildScrollView(
            child: Column(
              children: [
                TopWidget(
                    showBack: true,
                    title: 'Gráfico',
                    showCart: false,
                    showExit: true,
                    showChart: true),
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  decoration:
                      BoxDecoration(color: Utils.claro, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    spacing: 5,
                    children: [
                      Text('Agrupado por:', style: mainProvider.itemStyle),
                      DropdownButton<ETypePrices>(
                        borderRadius: BorderRadius.circular(20),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        dropdownColor: Utils.claro,
                        isExpanded: false,
                        value: typeGraphicData,
                        underline: Container(),
                        alignment: Alignment.center,
                        items: ETypePrices.values
                            .map<DropdownMenuItem<ETypePrices>>((ETypePrices value) {
                          return DropdownMenuItem<ETypePrices>(
                            value: value,
                            child: Text(value.displayName(), style: mainProvider.itemStyle),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != typeGraphicData) {
                            setState(() {
                              typeGraphicData = value!;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(10),
                  height: 600,
                  decoration:
                      BoxDecoration(color: Utils.claro, borderRadius: BorderRadius.circular(20)),
                  child: RepaintBoundary(
                    child: SfCartesianChart(
                      primaryXAxis: const CategoryAxis(
                        labelRotation: 45,
                        labelStyle: TextStyle(fontSize: 12),
                      ),
                      primaryYAxis: NumericAxis(
                        //title: AxisTitle(text: 'Importe'),
                        minimum: 0,
                        labelFormat: '{value}€',
                        numberFormat: NumberFormat.decimalPatternDigits(decimalDigits: 0),
                      ),
                      // title: ChartTitle(text: 'Compras', textStyle: mainProvider.itemStyle),
                      legend: Legend(isVisible: true),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      zoomPanBehavior: ZoomPanBehavior(
                        enablePinching: true,
                        enableDoubleTapZooming: true,
                        enableSelectionZooming: true,
                        enableMouseWheelZooming: true,
                        enablePanning: true,
                      ),
                      palette: palette,
                      series: series,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      if (typeGraphicData == ETypePrices.byShop)
                        ...allShoppings.entries.map(
                          (entrie) {
                            return _Shop(
                                entrie: entrie,
                                mainProvider: mainProvider,
                                history: history,
                                startDate: startDate,
                                finisDate: finisDate);
                          },
                        ),
                      if (typeGraphicData == ETypePrices.byProduct)
                        ...allProducts.entries.map(
                          (entrie) {
                            return _Product(
                                entrie: entrie,
                                mainProvider: mainProvider,
                                history:
                                    history.where((h) => h.product.id == entrie.key.id).toList(),
                                startDate: startDate,
                                finisDate: finisDate);
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Shop extends StatelessWidget {
  final MapEntry<Shop, Map<Product, double>> entrie;
  final MainProvider mainProvider;
  final List<ShoppingHistory> history;
  final DateTime? startDate;
  final DateTime? finisDate;

  const _Shop({
    required this.entrie,
    required this.mainProvider,
    required this.history,
    this.startDate,
    this.finisDate,
  });

  @override
  Widget build(BuildContext context) {
    Shop shop = entrie.key;
    final double totalAmount = history
        .where((h) => h.shop.id == shop.id)
        .fold(0, (prev, s) => prev + (s.price * s.quantity));
    final double totalQuantity =
        history.where((h) => h.shop.id == shop.id).fold(0, (prev, s) => prev + s.quantity);
    return Card(
      color: Utils.claro,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      borderOnForeground: false,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ExpansionTile(
          iconColor: Utils.medio,
          collapsedIconColor: Utils.medio,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          childrenPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          title: GestureDetector(
            onLongPress: () => Navigator.pushNamed(context, ShopPage.routeName, arguments: shop),
            child: Row(
              spacing: 10,
              children: [
                Image.asset(Utils.assetShop, width: 30, height: 30),
                Expanded(
                    child: MarqueeWidget(child: Text(shop.name, style: mainProvider.titleStyle))),
                Text('${totalAmount.toStringAsFixed(2)}€',
                    style: mainProvider.titleStyle.copyWith(fontSize: 17)),
              ],
            ),
          ),
          children: [
            ListView.builder(
              physics: const ClampingScrollPhysics(),
              shrinkWrap: true,
              itemCount: entrie.value.length,
              itemBuilder: (context, index) {
                Product product = entrie.value.entries.elementAt(index).key;
                double quantity = entrie.value.entries.elementAt(index).value;
                return GraphicProductWidget(
                    product: product,
                    quantity: quantity,
                    shop: shop,
                    startDate: startDate,
                    finishDate: finisDate);
              },
            ),
            //TOTAL POR TIENDA
            Card(
              color: Utils.claro,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              borderOnForeground: false,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Utils.medio.withAlpha((255 * 0.2).toInt()),
                      Utils.medio.withAlpha((255 * 0.1).toInt())
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Utils.medio.withAlpha((255 * 0.5).toInt()), width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total ${shop.name}',
                      style: mainProvider.mainTitleStyle.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Utils.oscuro,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${totalAmount.toStringAsFixed(2)}€',
                          style: mainProvider.itemStyle,
                        ),
                        Text(
                          '${totalQuantity.toStringAsFixed(0)} uds',
                          style: mainProvider.itemStyle,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Product extends StatelessWidget {
  final MapEntry<Product, double> entrie;
  final MainProvider mainProvider;
  final List<ShoppingHistory> history;
  final DateTime? startDate;
  final DateTime? finisDate;

  const _Product({
    required this.entrie,
    required this.mainProvider,
    required this.history,
    this.startDate,
    this.finisDate,
  });

  @override
  Widget build(BuildContext context) {
    Product product = entrie.key;
    final double totalAmount = history
        .where((h) => h.product.id == product.id)
        .fold(0, (prev, s) => prev + (s.price * s.quantity));
    final double totalQuantity =
        history.where((h) => h.product.id == product.id).fold(0, (prev, s) => prev + s.quantity);
    List<Shop> shops = history.map((h) => h.shop).toSet().toList();
    return Card(
      color: Utils.claro,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      borderOnForeground: false,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ExpansionTile(
          iconColor: Utils.medio,
          collapsedIconColor: Utils.medio,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          childrenPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          title: GestureDetector(
            onLongPress: () =>
                Navigator.pushNamed(context, ProductPage.routeName, arguments: product),
            child: Row(
              spacing: 10,
              children: [
                Image(image: product.imageType.image(), width: 30, height: 30),
                Expanded(
                    child: MarqueeWidget(child: Text(product.name, style: mainProvider.itemStyle))),
                Text('${totalAmount.toStringAsFixed(2)}€', style: mainProvider.itemStyle),
              ],
            ),
          ),
          children: [
            ...shops.map((shop) {
              List<ShoppingHistory> his = history.where((h) => h.shop.id == shop.id).toList();
              return HistoryGroupedDetailWidget(shoppingHistory: his, type: ETypeShoppings.byShop);
            }),
            //TOTAL POR PRODUCTO
            Card(
              color: Utils.claro,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              borderOnForeground: false,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Utils.medio.withAlpha((255 * 0.2).toInt()),
                      Utils.medio.withAlpha((255 * 0.1).toInt())
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Utils.medio.withAlpha((255 * 0.5).toInt()), width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total ${product.name}',
                      style: mainProvider.mainTitleStyle.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Utils.oscuro,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${totalAmount.toStringAsFixed(2)}€',
                          style: mainProvider.itemStyle,
                        ),
                        Text(
                          '${totalQuantity.toStringAsFixed(0)} uds',
                          style: mainProvider.itemStyle,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChartData {
  final Product product;
  final double amount;
  ChartData(this.product, this.amount);
}
