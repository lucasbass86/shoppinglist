import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shoppinglist/models/models.dart';
import 'package:shoppinglist/pages/_pages.dart';
import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/sharedpreferences/preferences.dart';
import 'package:shoppinglist/utils/enums.dart';
import 'package:shoppinglist/utils/utils.dart';
import 'package:shoppinglist/widgets/_widgets.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ShopSliverGraphicsWidget extends StatefulWidget {
  final Shop shop;
  const ShopSliverGraphicsWidget({super.key, required this.shop});

  @override
  State<ShopSliverGraphicsWidget> createState() => _ShopSliverGraphicsWidgetState();
}

class _ShopSliverGraphicsWidgetState extends State<ShopSliverGraphicsWidget> {
  late MainProvider mainProvider;
  late List<ShoppingHistory> historicoCompras;
  late Shop shop;
  List<String> years = ['TODOS'];
  String selectedYear = 'TODOS';
  final PageController graphicPageController = PageController(initialPage: 0);
  int currentPage = 0;
  bool _isInit = true;
  List<Color> shuffledList = List.from(Utils.palettes);

  @override
  void initState() {
    super.initState();
    shuffledList.shuffle(Random());
  }

  @override
  Widget build(BuildContext context) {
    mainProvider = Provider.of<MainProvider>(context);
    shop = widget.shop;
    historicoCompras = historicoCompras = mainProvider.loadShoppingHistoryByShop(shop);

    if (_isInit) {
      years.addAll(historicoCompras.map((h) => h.date.year.toString()).toSet().toList());
      _isInit = false;
    }
    return historicoCompras.isEmpty
        ? _noHistory()
        : SliverMainAxisGroup(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      spacing: 10,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _typeGraphic(),
                        _years(),
                        _order(),
                        _productOrder(),
                      ],
                    ),
                  ),
                ),
              ),
              if (Preferences.shopTypeGraphic == ETypeGraphic.general) ..._graphicsGeneralByYears(),
              if (Preferences.shopTypeGraphic == ETypeGraphic.product) ..._graphicsByProduct(),
            ],
          );
  }

  Widget _noHistory() {
    return SliverFillRemaining(
      child: Center(
        child: Text('No hay compras', style: mainProvider.titleStyle),
      ),
    );
  }

  Widget _productOrder() {
    if (Preferences.shopTypeGraphic == ETypeGraphic.product) {
      return Row(
        spacing: 10,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.only(left: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Utils.claro,
              ),
            ),
            child: DropdownButton<EGraphicProductShow>(
              isExpanded: false,
              elevation: 16,
              style: TextStyle(fontSize: 20, color: Utils.oscuro),
              dropdownColor: Utils.oscuro,
              borderRadius: BorderRadius.circular(20),
              underline: Container(height: 2),
              value: Preferences.graphicByAmount
                  ? EGraphicProductShow.price
                  : EGraphicProductShow.quantity,
              items: EGraphicProductShow.values
                  .map(
                    (o) => DropdownMenuItem(
                      value: o,
                      child: Text(
                        o.displayName,
                        style: mainProvider.itemStyle.copyWith(fontSize: 13, color: Utils.claro),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  Preferences.graphicByAmount = value == EGraphicProductShow.price;
                });
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Utils.claro,
              ),
            ),
            child: DropdownButton<EOrderGraphicByProduct>(
              isExpanded: false,
              elevation: 16,
              style: TextStyle(fontSize: 20, color: Utils.oscuro),
              dropdownColor: Utils.oscuro,
              borderRadius: BorderRadius.circular(20),
              underline: Container(height: 2),
              value: Preferences.graphicShopProductOrder,
              items: EOrderGraphicByProduct.values
                  .map(
                    (o) => DropdownMenuItem(
                      value: o,
                      child: Text(
                        o.displayName(),
                        style: mainProvider.itemStyle.copyWith(fontSize: 13, color: Utils.claro),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != Preferences.graphicShopProductOrder) {
                  setState(() {
                    Preferences.graphicShopProductOrder = value!;
                  });
                }
              },
            ),
          ),
        ],
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget _order() {
    if (Preferences.shopTypeGraphic == ETypeGraphic.general && selectedYear != 'TODOS') {
      return Container(
        padding: const EdgeInsets.only(left: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Utils.claro,
          ),
        ),
        child: DropdownButton<EOrderGraphic>(
          isExpanded: false,
          elevation: 16,
          style: TextStyle(fontSize: 20, color: Utils.oscuro),
          dropdownColor: Utils.oscuro,
          borderRadius: BorderRadius.circular(20),
          underline: Container(height: 2),
          value: Preferences.graphicShopGeneralOrder,
          items: EOrderGraphic.values
              .map(
                (o) => DropdownMenuItem(
                  value: o,
                  child: Text(
                    o.displayName(),
                    style: mainProvider.itemStyle.copyWith(fontSize: 13, color: Utils.claro),
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != Preferences.graphicShopGeneralOrder) {
              setState(() {
                Preferences.graphicShopGeneralOrder = value!;
              });
            }
          },
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget _years() {
    return Container(
      padding: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Utils.claro,
        ),
      ),
      child: DropdownButton(
        borderRadius: BorderRadius.circular(20),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        dropdownColor: Utils.oscuro,
        value: selectedYear,
        underline: Container(),
        alignment: Alignment.center,
        items: years.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value,
                style: mainProvider.itemStyle.copyWith(fontSize: 13, color: Utils.claro)),
          );
        }).toList(),
        onChanged: <String>(value) {
          selectedYear = value;
        },
      ),
    );
  }

  Widget _typeGraphic() {
    return Container(
      padding: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Utils.claro,
        ),
      ),
      child: DropdownButton(
        borderRadius: BorderRadius.circular(20),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        dropdownColor: Utils.oscuro,
        value: Preferences.shopTypeGraphic,
        underline: Container(),
        alignment: Alignment.center,
        items: ETypeGraphic.values.map<DropdownMenuItem<ETypeGraphic>>((ETypeGraphic value) {
          return DropdownMenuItem<ETypeGraphic>(
            value: value,
            child: Text(value.displayName(),
                style: mainProvider.itemStyle.copyWith(fontSize: 13, color: Utils.claro)),
          );
        }).toList(),
        onChanged: <ETypeGraphic>(value) {
          Preferences.shopTypeGraphic = value;
        },
      ),
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

      data.sort((a, b) => a.year.compareTo(b.year));

      series = [
        PieSeries<_PieDataByYears, String>(
          explode: true,
          explodeIndex: 0,
          dataSource: data,
          xValueMapper: (_PieDataByYears data, _) => data.year,
          yValueMapper: (_PieDataByYears data, _) => data.quantity,
          dataLabelMapper: (_PieDataByYears data, _) => '${data.quantity.toStringAsFixed(2)}€',
          dataLabelSettings: DataLabelSettings(isVisible: true, color: Utils.claro),
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
          dataLabelSettings:
              DataLabelSettings(isVisible: true, textStyle: TextStyle(color: Utils.claro)),
          pointColorMapper: (data, index) => shuffledList[index],
          borderRadius:
              BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
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
                    Icon(Icons.calendar_month, color: Utils.claro),
                    Text(data[index].year,
                        style: mainProvider.itemStyle.copyWith(color: Utils.claro)),
                  ],
                ),
                Text('${data[index].quantity.toStringAsFixed(2)}€',
                    style: mainProvider.itemStyle.copyWith(color: Utils.claro)),
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
          dataLabelSettings: DataLabelSettings(isVisible: true, color: Utils.claro),
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
          dataLabelSettings:
              DataLabelSettings(isVisible: true, textStyle: TextStyle(color: Utils.claro)),
          pointColorMapper: (data, index) => shuffledList[index],
          borderRadius:
              BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
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
                        Icon(Icons.calendar_month, color: Utils.claro),
                        Text(data[index].monthName!,
                            style: mainProvider.itemStyle.copyWith(color: Utils.claro)),
                      ],
                    ),
                    Row(
                      spacing: 7,
                      children: [
                        Text('${data[index].quantity.toStringAsFixed(2)}€',
                            style: mainProvider.itemStyle.copyWith(color: Utils.claro)),
                        Icon(Icons.remove_red_eye, color: Utils.claro),
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
              color: Utils.oscuro.withAlpha(100),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Utils.claro),
            ),
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: graphicPageController,
                    scrollDirection: Axis.horizontal,
                    onPageChanged: (index) => setState(() => currentPage = index),
                    children: [
                      RepaintBoundary(
                        child: SfCircularChart(
                          palette: shuffledList,
                          legend: Legend(isVisible: true, textStyle: TextStyle(color: Utils.claro)),
                          series: series,
                          tooltipBehavior: TooltipBehavior(
                            enable: true,
                            color: Utils.oscuro,
                            textStyle: TextStyle(color: Utils.claro),
                          ),
                        ),
                      ),
                      RepaintBoundary(
                        child: SfCartesianChart(
                          primaryXAxis: CategoryAxis(
                            labelRotation: 45,
                            labelStyle: TextStyle(fontSize: 12, color: Utils.claro),
                          ),
                          primaryYAxis: NumericAxis(
                            title: AxisTitle(
                                text: 'Importe', textStyle: TextStyle(color: Utils.claro)),
                            minimum: 0,
                            labelFormat: '{value}',
                            labelStyle: TextStyle(color: Utils.claro),
                            numberFormat: NumberFormat.decimalPatternDigits(
                                decimalDigits: Preferences.graphicByAmount ? 2 : 0),
                          ),
                          palette: shuffledList,
                          series: seriesLinear,
                          tooltipBehavior: TooltipBehavior(
                            enable: true,
                            color: Utils.oscuro,
                            textStyle: TextStyle(color: Utils.claro),
                          ),
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
                Stack(
                  children: [
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
                              color: Utils.claro,
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 600),
                            width: currentPage == 1 ? 25 : 10,
                            height: currentPage == 1 ? 15 : 10,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Utils.claro,
                            ),
                          )
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, MaximizeCharPage.routeName,
                          arguments: [series, seriesLinear]),
                      child: Icon(
                        Icons.fit_screen_rounded,
                        color: Utils.claro,
                      ),
                    ),
                  ],
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
              color: Utils.oscuro.withAlpha(100),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Utils.claro),
            ),
            child: Column(
              children: [
                listView,
                Divider(color: Utils.claro),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    spacing: 10,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('TOTAL', style: mainProvider.itemStyle.copyWith(color: Utils.claro)),
                      Text('${totalAmount.toStringAsFixed(2)}€',
                          style: mainProvider.itemStyle.copyWith(color: Utils.claro)),
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
        dataLabelSettings: DataLabelSettings(isVisible: true, color: Utils.claro),
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
        dataLabelSettings:
            DataLabelSettings(isVisible: true, textStyle: TextStyle(color: Utils.claro)),
        pointColorMapper: (data, index) => shuffledList[Random().nextInt(shuffledList.length)],
        borderRadius:
            BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
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
    listView = ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: data.length,
      itemBuilder: (context, index) {
        return GraphicProductWidget(
            product: data[index].product,
            shop: shop,
            quantity: data[index].quantity,
            year: selectedYear);
      },
      separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 10),
    );

    return [
      SliverToBoxAdapter(
        child: ZoomIn(
          child: Container(
            height: 500,
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Utils.oscuro.withAlpha(100),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Utils.claro),
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
                        legend: Legend(isVisible: true, textStyle: TextStyle(color: Utils.claro)),
                        series: series,
                        tooltipBehavior: TooltipBehavior(
                          enable: true,
                          color: Utils.oscuro,
                          textStyle: TextStyle(color: Utils.claro),
                        ),
                      ),
                      SfCartesianChart(
                        primaryXAxis: CategoryAxis(
                          labelRotation: 45,
                          labelStyle: TextStyle(fontSize: 12, color: Utils.claro),
                        ),
                        primaryYAxis: NumericAxis(
                          title: AxisTitle(
                              text: Preferences.graphicByAmount ? 'Importe' : 'Cantidad',
                              textStyle: TextStyle(color: Utils.claro)),
                          minimum: 0,
                          labelFormat: '{value}',
                          labelStyle: TextStyle(color: Utils.claro),
                          numberFormat: NumberFormat.decimalPatternDigits(
                              decimalDigits: Preferences.graphicByAmount ? 2 : 0),
                        ),
                        palette: shuffledList,
                        legend: Legend(isVisible: false),
                        series: seriesLinear,
                        tooltipBehavior: TooltipBehavior(
                          enable: true,
                          color: Utils.oscuro,
                          textStyle: TextStyle(color: Utils.claro),
                        ),
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
                Stack(
                  children: [
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
                              color: Utils.claro,
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 600),
                            width: currentPage == 1 ? 25 : 10,
                            height: currentPage == 1 ? 15 : 10,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Utils.claro,
                            ),
                          )
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, MaximizeCharPage.routeName,
                          arguments: [series, seriesLinear]),
                      child: Icon(
                        Icons.fit_screen_rounded,
                        color: Utils.claro,
                      ),
                    )
                  ],
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
              color: Utils.oscuro.withAlpha(100),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Utils.claro),
            ),
            child: Column(
              children: [
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
}

class _PieDataByYears {
  final String year;
  final double quantity;

  @override
  String toString() => 'Year: $year';

  _PieDataByYears(this.year, this.quantity);
}

class _PieDataByYear {
  final int month;
  final double quantity;
  String? monthName;

  @override
  String toString() => 'Month: $month';

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
