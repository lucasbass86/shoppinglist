import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shoppinglist/models/models.dart';
import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/utils/utils.dart';
import 'package:shoppinglist/widgets/_widgets.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartAmountPage extends StatefulWidget {
  static const String routeName = 'ChartAmountPage';
  const ChartAmountPage({super.key});

  @override
  State<ChartAmountPage> createState() => _ChartAmountPageState();
}

class _ChartAmountPageState extends State<ChartAmountPage> {
  late MainProvider mainProvider;
  String selectedShopName = 'TODAS';
  List<String> yearsOfDropDown = [];
  String selectedYear = 'TODOS';
  List<String> names = ['TODAS'];
  List<Color> palette = List.from(Utils.palettes);

  @override
  void initState() {
    super.initState();
    palette.shuffle(Random());
  }

  @override
  Widget build(BuildContext context) {
    mainProvider = Provider.of<MainProvider>(context, listen: false);
    names.clear();
    names.add('TODAS');
    names.addAll(mainProvider.shoppingHistory.map((h) => h.shop.name).toSet().toList()
      ..sort((a, b) => a.compareTo(b)));

    return Scaffold(
      body: Stack(
        children: [
          BackgroundWidget(),
          Column(
            children: [
              _top(),
              ..._chart(),
            ],
          )
        ],
      ),
    );
  }

  Widget _top() {
    return const TopWidget(
      showBack: true,
      title: 'Gráficos',
      showCart: false,
      showExit: true,
    );
  }

  Widget _group() {
    return FadeInLeft(
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(color: Utils.claro, borderRadius: BorderRadius.circular(20)),
        child: Row(
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
                setState(() {
                  selectedShopName = value;
                  selectedYear = 'TODOS';
                });
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
                setState(() {
                  selectedYear = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _chart() {
    double media = 0;
    List<CartesianSeries<dynamic, dynamic>> series = [];
    List<Shop> shops = selectedYear == 'TODOS'
        ? mainProvider.shoppingHistory.map((s) => s.shop).toSet().toList()
        : mainProvider.shoppingHistory
            .where((s) => s.date.year == int.parse(selectedYear))
            .map((s) => s.shop)
            .toSet()
            .toList();

    shops.sort((a, b) => a.name.compareTo(b.name));

    if (selectedShopName == 'TODAS') {
      media = 0;
      yearsOfDropDown.clear();
      yearsOfDropDown.add('TODOS');
      yearsOfDropDown
          .addAll(mainProvider.shoppingHistory.map((h) => h.date.year.toString()).toSet().toList());
      Map<Shop, double> groupedByShop = {};
      for (Shop s in shops) {
        if (selectedYear == 'TODOS') {
          final shop = <Shop, double>{
            s: mainProvider.shoppingHistory
                .where((h) => h.shop.id == s.id)
                .fold<double>(0, (sum, item) => sum + (item.quantity * item.price))
          };
          media += shop.values.first;
          groupedByShop.addEntries(shop.entries);
        } else {
          final shop = <Shop, double>{
            s: mainProvider.shoppingHistory
                .where((h) => h.shop.id == s.id && h.date.year == int.parse(selectedYear))
                .fold<double>(0, (sum, item) => sum + (item.quantity * item.price))
          };
          media += shop.values.first;
          groupedByShop.addEntries(shop.entries);
        }
      }
      List<_PieDataShops> data = [];
      for (var v in groupedByShop.entries) {
        if (v.value > 0) {
          data.add(_PieDataShops(v.key.name, v.value));
        }
      }
      media = media / data.length;
      series = [
        AreaSeries<_PieDataShops, String>(
          dataSource: data,
          name: 'Imp.Total',
          xValueMapper: (_PieDataShops data, _) => data.shopName,
          yValueMapper: (_PieDataShops data, _) => data.quantity,
          dataLabelMapper: (_PieDataShops data, _) => '${data.quantity.toStringAsFixed(2)}€',
          dataLabelSettings: DataLabelSettings(isVisible: true, textStyle: mainProvider.itemStyle),
          markerSettings: MarkerSettings(isVisible: true),
        ),
        LineSeries<_PieDataShops, String>(
          dataSource: data,
          name: 'Media',
          xValueMapper: (_PieDataShops data, _) => data.shopName,
          yValueMapper: (_PieDataShops data, _) => media,
          markerSettings: MarkerSettings(isVisible: true, shape: DataMarkerType.diamond),
          dataLabelMapper: (_PieDataShops data, _) => '${media.toStringAsFixed(2)}€',
          color: Utils.oscuro,
        ),
      ];
    }

    //PARA UNA TIENDA EN PARTICULAR
    if (selectedShopName != 'TODAS' && selectedYear == 'TODOS') {
      media = 0;
      Shop shop = mainProvider.shops.firstWhere((s) => s.name == selectedShopName);
      List<ShoppingHistory> shoppingHistory =
          mainProvider.shoppingHistory.where((h) => h.shop.id == shop.id).toList();
      yearsOfDropDown.clear();
      yearsOfDropDown.add('TODOS');
      yearsOfDropDown.addAll(shoppingHistory.map((h) => h.date.year.toString()).toSet().toList());
      Map<String, double> groupedByShopYears = {};
      List<String> yearsOfShop = [];
      yearsOfShop = shoppingHistory.map((h) => h.date.year.toString()).toSet().toList();
      yearsOfShop.sort((a, b) => a.compareTo(b));
      if (yearsOfShop.length == 1) {
        setState(() {
          selectedYear = yearsOfShop[0];
        });
      }

      for (String year in yearsOfShop) {
        final entry = <String, double>{
          year: shoppingHistory
              .where((h) => h.date.year.toString() == year)
              .fold<double>(0, (sum, item) => sum + (item.quantity * item.price))
        };
        media += entry.values.first;
        groupedByShopYears.addEntries(entry.entries);
      }
      List<_PieDataShopYears> data = [];
      for (var v in groupedByShopYears.entries) {
        if (v.value > 0) {
          data.add(_PieDataShopYears(v.key, v.value));
        }
      }
      media = media / data.length;
      series = [
        AreaSeries<_PieDataShopYears, String>(
          dataSource: data,
          name: selectedShopName,
          xValueMapper: (_PieDataShopYears data, _) => data.year,
          yValueMapper: (_PieDataShopYears data, _) => data.quantity,
          dataLabelMapper: (_PieDataShopYears data, _) => '${data.quantity.toStringAsFixed(2)}€',
          dataLabelSettings: DataLabelSettings(isVisible: true, textStyle: mainProvider.itemStyle),
          markerSettings: MarkerSettings(isVisible: true),
        ),
        LineSeries<_PieDataShopYears, String>(
          dataSource: data,
          name: 'Media',
          xValueMapper: (_PieDataShopYears data, _) => data.year,
          yValueMapper: (_PieDataShopYears data, _) => media,
          markerSettings: MarkerSettings(isVisible: true, shape: DataMarkerType.diamond),
          dataLabelMapper: (_PieDataShopYears data, _) => '${media.toStringAsFixed(2)}€',
          // dataLabelSettings: DataLabelSettings(isVisible: true, textStyle: mainProvider.itemStyle),
          color: Utils.oscuro,
        ),
      ];
    }

    //PARA UNA TIENDA EN PARTICULAR Y UN AÑO
    if (selectedShopName != 'TODAS' && selectedYear != 'TODOS') {
      media = 0;
      Shop shop = mainProvider.shops.firstWhere((s) => s.name == selectedShopName);
      List<ShoppingHistory> shoppingHistory =
          mainProvider.shoppingHistory.where((h) => h.shop.id == shop.id).toList();
      yearsOfDropDown.clear();
      yearsOfDropDown.add('TODOS');
      yearsOfDropDown.addAll(shoppingHistory.map((h) => h.date.year.toString()).toSet().toList());
      Map<int, double> groupedByShopYear = {};
      List<int> monthsOfShopByYear = shoppingHistory
          .where((h) => h.date.year.toString() == selectedYear)
          .map((r) => r.date.month)
          .toSet()
          .toList();
      monthsOfShopByYear.sort((a, b) => a.compareTo(b));
      for (int month in monthsOfShopByYear) {
        final entry = <int, double>{
          month: shoppingHistory
              .where((h) => h.date.year.toString() == selectedYear && h.date.month == month)
              .fold<double>(0, (sum, item) => sum + (item.quantity * item.price))
        };
        media += entry.values.first;
        groupedByShopYear.addEntries(entry.entries);
      }
      List<_PieDataShopYear> data = [];
      for (var v in groupedByShopYear.entries) {
        if (v.value > 0) {
          data.add(_PieDataShopYear(v.key, v.value));
        }
      }
      media = media / data.length;

      series = [
        AreaSeries<_PieDataShopYear, String>(
          dataSource: data,
          name: selectedShopName,
          xValueMapper: (_PieDataShopYear data, _) => data.shortName,
          yValueMapper: (_PieDataShopYear data, _) => data.quantity,
          dataLabelMapper: (_PieDataShopYear data, _) => '${data.quantity.toStringAsFixed(2)}€',
          dataLabelSettings: DataLabelSettings(isVisible: true, textStyle: mainProvider.itemStyle),
          markerSettings: MarkerSettings(isVisible: true),
        ),
        LineSeries<_PieDataShopYear, String>(
          dataSource: data,
          name: 'Media',
          xValueMapper: (_PieDataShopYear data, _) => data.shortName,
          yValueMapper: (_PieDataShopYear data, _) => media,
          markerSettings: MarkerSettings(isVisible: true, shape: DataMarkerType.diamond),
          dataLabelMapper: (_PieDataShopYear data, _) => '${media.toStringAsFixed(2)}€',
          color: Utils.oscuro,
        ),
      ];
    }

    return [
      _group(),
      Expanded(
        child: Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(color: Utils.claro, borderRadius: BorderRadius.circular(20)),
          child: RepaintBoundary(
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(
                labelRotation: 45,
                labelStyle: mainProvider.itemStyle.copyWith(fontSize: 13),
              ),
              primaryYAxis: NumericAxis(
                minimum: 0,
                labelFormat: '{value}€',
                numberFormat: NumberFormat.decimalPatternDigits(decimalDigits: 0),
                labelStyle: mainProvider.itemStyle.copyWith(fontSize: 13),
              ),
              legend: Legend(isVisible: false),
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
      )
    ];
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
  String? shortName;
  _PieDataShopYear(this.month, this.quantity) {
    switch (month) {
      case 1:
        monthName = 'ENERO';
        shortName = 'ENE';
        break;
      case 2:
        monthName = 'FEBRERO';
        shortName = 'FEB';
        break;
      case 3:
        monthName = 'MARZO';
        shortName = 'MAR';
        break;
      case 4:
        monthName = 'ABRIL';
        shortName = 'ABR';
        break;
      case 5:
        monthName = 'MAYO';
        shortName = 'MAY';
        break;
      case 6:
        monthName = 'JUNIO';
        shortName = 'JUN';
        break;
      case 7:
        monthName = 'JULIO';
        shortName = 'JUL';
        break;
      case 8:
        monthName = 'AGOSTO';
        shortName = 'AGO';
        break;
      case 9:
        monthName = 'SEPTIEMBRE';
        shortName = 'SEP';
        break;
      case 10:
        monthName = 'OCTUBRE';
        shortName = 'OCT';
        break;
      case 11:
        monthName = 'NOVIEMBRE';
        shortName = 'NOV';
        break;
      case 12:
        monthName = 'DICIEMBRE';
        shortName = 'DIC';
        break;
    }
  }
}
