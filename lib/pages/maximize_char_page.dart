import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shoppinglist/sharedpreferences/preferences.dart';
import 'package:shoppinglist/utils/utils.dart';
import 'package:shoppinglist/widgets/_widgets.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class MaximizeCharPage extends StatefulWidget {
  static const String routeName = 'MaximizeCharPage';
  const MaximizeCharPage({super.key});

  @override
  State<MaximizeCharPage> createState() => _MaximizeCharPageState();
}

class _MaximizeCharPageState extends State<MaximizeCharPage> {
  final PageController graphicPageController = PageController(initialPage: 0);
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    List<Color> shuffledList = List.from(Utils.palettes);
    List<CircularSeries<dynamic, dynamic>> series = (ModalRoute.of(context)!.settings.arguments
        as List)[0] as List<CircularSeries<dynamic, dynamic>>;
    List<ColumnSeries<dynamic, dynamic>> seriesLinear = (ModalRoute.of(context)!.settings.arguments
        as List)[1] as List<ColumnSeries<dynamic, dynamic>>;
    return Scaffold(
      body: Stack(
        children: [
          BackgroundWidget(),
          Column(
            children: [
              TopWidget(showBack: true, title: 'Gráfica', showCart: false),
              Expanded(
                child: PageView(
                    physics: const BouncingScrollPhysics(),
                    controller: graphicPageController,
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
                    ]),
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
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
