import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:shoppinglist/dialogs/dialogs.dart';
import 'package:shoppinglist/models/models.dart';
import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/utils/enums.dart';
import 'package:shoppinglist/utils/utils.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ShopProductHistory extends StatefulWidget {
  final Product product;
  final Shop shop;
  const ShopProductHistory({super.key, required this.product, required this.shop});

  @override
  State<ShopProductHistory> createState() => _ShopProductHistoryState();
}

class _ShopProductHistoryState extends State<ShopProductHistory> {
  late MainProvider mainProvider;
  List<PriceHistory> historico = [];
  @override
  Widget build(BuildContext context) {
    mainProvider = Provider.of<MainProvider>(context, listen: false);
    historico = mainProvider.pricesHistory
        .where((h) =>
            h.productShop.shop.id == widget.shop.id &&
            h.productShop.product.id == widget.product.id)
        .toList();
    return ZoomIn(
      child: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(10),
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
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 10,
              children: [
                Image(image: widget.product.imageType.image(), width: 30, height: 30),
                Text(widget.product.name, style: mainProvider.itemStyle.copyWith(fontSize: 23)),
              ],
            ),
            const SizedBox(height: 10),
            productGraphic(widget.product),
          ],
        ),
      ),
    );
  }

  Widget productGraphic(Product product) {
    List<_GroupGraphic> principal = [];
    List<CartesianSeries<_Graphic, String>> graf = [];
    for (PriceHistory h in historico) {
      final _Graphic g = _Graphic(h);
      principal
          .firstWhere(
            (p) => p.shop.id == h.productShop.shop.id,
            orElse: () {
              final _GroupGraphic group = _GroupGraphic(shop: h.productShop.shop);
              principal.add(group);
              return group;
            },
          )
          .list
          .add(g);
    }

    for (_GroupGraphic g in principal) {
      if (g.list.length == 1) {
        graf.add(
          BubbleSeries<_Graphic, String>(
            dataSource: g.list,
            xValueMapper: (_Graphic hist, _) =>
                hist.historicoPrecio.fecha.toString().substring(0, 10),
            yValueMapper: (_Graphic hist, _) => hist.historicoPrecio.productShop.price,
            name: g.shop.name,
            legendItemText: g.shop.name,
            dataLabelSettings:
                DataLabelSettings(isVisible: true, color: mainProvider.itemStyle.color),
            onPointLongPress: (pointInteractionDetails) {
              final List<_Graphic> actual =
                  graf.elementAt(pointInteractionDetails.seriesIndex!).dataSource as List<_Graphic>;
              final PriceHistory historicoPrecio = actual[0].historicoPrecio;
              showMessage(
                      context: context,
                      cancel: true,
                      message: '¿Eliminar el histórico del producto?',
                      secondMessage:
                          'Tienda: ${historicoPrecio.productShop.shop.name} \r\nPrecio: ${historicoPrecio.productShop.price.toStringAsFixed(2)}€\r\nFecha: ${historicoPrecio.fecha}')
                  .then((value) {
                if (value) {
                  mainProvider.deleteHistoricoPrecio(historicoPrecio);
                  setState(() {});
                }
              });
            },
          ),
        );
      } else {
        graf.add(
          LineSeries<_Graphic, String>(
            dataSource: g.list,
            xValueMapper: (_Graphic hist, _) =>
                hist.historicoPrecio.fecha.toString().substring(0, 10),
            yValueMapper: (_Graphic hist, _) => hist.historicoPrecio.productShop.price,
            name: g.shop.name,
            legendItemText: g.shop.name,
            dataLabelSettings:
                DataLabelSettings(isVisible: true, color: mainProvider.itemStyle.color),
            markerSettings: const MarkerSettings(isVisible: true),
            onPointLongPress: (pointInteractionDetails) {
              final _Graphic otro = g.list[pointInteractionDetails.pointIndex!];
              final PriceHistory historicoPrecio = otro.historicoPrecio;
              showMessage(
                      context: context,
                      cancel: true,
                      message: '¿Eliminar el histórico del producto?',
                      secondMessage:
                          'Tienda: ${historicoPrecio.productShop.shop.name} \r\nPrecio: ${historicoPrecio.productShop.price.toStringAsFixed(2)}€\r\nFecha: ${Utils.dateEnglishToSpanish(historicoPrecio.fecha.toString(), showTime: false)}')
                  .then((value) {
                if (value) {
                  mainProvider.deleteHistoricoPrecio(historicoPrecio);
                  setState(() {});
                }
              });
            },
          ),
        );
      }
    }

    return SfCartesianChart(
      primaryXAxis: CategoryAxis(
        labelRotation: 45,
        labelStyle: TextStyle(fontSize: 10, color: Utils.oscuro),
        majorGridLines: MajorGridLines(color: Utils.oscuro),
        // minorGridLines: MinorGridLines(color: Utils.oscuro),
        axisLine: AxisLine(color: Utils.oscuro),
        axisLabelFormatter: (details) {
          final fechaEsp = Utils.dateEnglishToSpanish(details.text, showTime: false);
          return ChartAxisLabel(fechaEsp, details.textStyle);
        },
      ),
      primaryYAxis: NumericAxis(
        labelStyle: TextStyle(fontSize: 12, color: Utils.oscuro),
        labelFormat: '{value}€',
        majorGridLines: MajorGridLines(color: Utils.oscuro),
        minorGridLines: MinorGridLines(color: Utils.oscuro),
        axisLine: AxisLine(color: Utils.oscuro),
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
    );
  }
}

class _GroupGraphic {
  Shop shop;
  List<_Graphic> list = [];

  @override
  String toString() => shop.name;

  _GroupGraphic({required this.shop});
}

class _Graphic {
  late PriceHistory historicoPrecio;
  _Graphic(this.historicoPrecio);
}
