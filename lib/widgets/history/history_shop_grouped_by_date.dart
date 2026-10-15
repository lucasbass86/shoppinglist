import 'package:flutter/material.dart';
import 'package:shoppinglist/dialogs/bottoms.dart';
import 'package:shoppinglist/models/models.dart';
import 'package:shoppinglist/pages/_pages.dart';
import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/utils/enums.dart';
import 'package:shoppinglist/utils/utils.dart';
import 'package:shoppinglist/widgets/_widgets.dart';

class HistoryShopGroupedByDate extends StatefulWidget {
  final List<ShoppingHistory> shoppingHistory;
  const HistoryShopGroupedByDate({
    super.key,
    required this.shoppingHistory,
  });

  @override
  State<HistoryShopGroupedByDate> createState() => _HistoryShopGroupedByDateState();
}

class _HistoryShopGroupedByDateState extends State<HistoryShopGroupedByDate> {
  late MainProvider mainProvider;
  int countShowSaving = 0;

  //OPTIMIZADO PARA VER DESDE UNA TIENDA
  @override
  Widget build(BuildContext context) {
    mainProvider = Provider.of<MainProvider>(context, listen: false);
    final List<int> months = widget.shoppingHistory.map((s) => s.date.month).toSet().toList()
      ..sort((a, b) => b.compareTo(a));
    int countShowSaving = 0;
    final totalQuantityYear =
        widget.shoppingHistory.fold<int>(0, (sum, item) => sum + item.quantity);
    double totalYear = widget.shoppingHistory.fold(0, (pre, s) => pre + (s.price * s.quantity));
    return SliverMainAxisGroup(
      slivers: [
        SliverList.separated(
          itemCount: months.length,
          itemBuilder: (context, index) {
            final List<ShoppingHistory> month =
                widget.shoppingHistory.where((s) => s.date.month == months[index]).toList();
            final totalQuantityMonth = month.fold<int>(0, (sum, item) => sum + item.quantity);
            double totalMonth = month.fold(0, (pre, s) => pre + (s.price * s.quantity));
            final days = month.map((h) => h.date.day).toSet().toList()
              ..sort((a, b) => b.compareTo(a));
            int selectedDay = days[0];
            return StatefulBuilder(
              builder: (BuildContext context, setState) {
                final List<ShoppingHistory> day = widget.shoppingHistory
                    .where((s) => s.date.month == months[index] && s.date.day == selectedDay)
                    .toList();
                final totalQuantityDay = day.fold<int>(0, (sum, item) => sum + item.quantity);
                final totalPriceDay = day.fold<double>(
                  0,
                  (sum, item) => sum + (item.quantity * item.price),
                );
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  decoration: BoxDecoration(
                    color: Utils.oscuro.withAlpha(100),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Utils.claro),
                  ),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(20)),
                    collapsedShape:
                        RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(20)),
                    childrenPadding: EdgeInsets.all(10),
                    title:
                        //CABECERA
                        Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          Utils.monthName(months[index]),
                          style: mainProvider.minititleStyle.copyWith(color: Utils.claro),
                        ),
                        Text(
                          '${totalMonth.toStringAsFixed(2)} €',
                          style: mainProvider.minititleStyle.copyWith(color: Utils.claro),
                        ),
                      ],
                    ),
                    children: [
                      //DIAS DE COMPRA DEL MES
                      SizedBox(
                        height: 20,
                        child: ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: days.length,
                          itemBuilder: (context, index2) {
                            return GestureDetector(
                              onTap: () => setState(() => selectedDay = days[index2]),
                              child: Text(
                                '${days[index2].toString().padLeft(2, '0')}-${months[index].toString().padLeft(2, '0')}-${widget.shoppingHistory[0].date.year}',
                                style: mainProvider.itemStyle.copyWith(
                                    color: days[index2] == selectedDay ? Utils.claro : Utils.medio),
                              ),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) =>
                              const SizedBox(width: 30),
                        ),
                      ),
                      Divider(color: Utils.medio),
                      //DETALLE DE COMPRA DEL DIA SELECCIONADO
                      ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: day.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                            child: InkWell(
                              splashColor: Utils.oscuro,
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => Navigator.pushNamed(context, ProductPage.routeName,
                                  arguments: day[index].product),
                              child: Row(
                                children: [
                                  Image(
                                      image: day[index].product.imageType.image(),
                                      width: 20,
                                      height: 20),
                                  const SizedBox(width: 7),
                                  Expanded(
                                    child: MarqueeWidget(
                                        child: Text(day[index].product.name,
                                            style: mainProvider.itemStyle
                                                .copyWith(color: Utils.claro))),
                                  ),
                                  Text('${day[index].quantity}x',
                                      style: mainProvider.itemStyle.copyWith(color: Utils.claro)),
                                  Text(day[index].price.toStringAsFixed(2),
                                      style: mainProvider.itemStyle.copyWith(color: Utils.claro)),
                                  Text(
                                      '= ${(day[index].quantity * day[index].price).toStringAsFixed(2)}€',
                                      style: mainProvider.itemStyle.copyWith(color: Utils.claro)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      //TOTAL DEL DIA SELECCIONADO
                      GestureDetector(
                        onTap: () async {
                          countShowSaving++;
                          if (countShowSaving == 3) {
                            await showSavingAmount(context, mainProvider, day[0].shop,
                                day.where((s) => s.price == 0).toList());
                            countShowSaving = 0;
                          }
                        },
                        child: HistoryLevelTotalWidget(
                          action: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => Navigator.pushNamed(context, HistoryDetailPage.routeName,
                                arguments: day),
                            child: Icon(Icons.edit, color: Utils.medio),
                          ),
                          uds: totalQuantityDay,
                          amount: totalPriceDay,
                          title: 'Total día',
                          isLastTotal: false,
                        ),
                      ),
                      Divider(color: Utils.medio),
                      //TOTAL DEL MES ACTUAL
                      GestureDetector(
                        onTap: () async {
                          countShowSaving++;
                          if (countShowSaving == 5) {
                            await showSavingAmount(context, mainProvider, month[0].shop,
                                month.where((s) => s.price == 0).toList());
                            countShowSaving = 0;
                          }
                        },
                        child: HistoryLevelTotalWidget(
                            title: 'TOTAL MES',
                            uds: totalQuantityMonth,
                            amount: totalMonth,
                            isLastTotal: true),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          separatorBuilder: (context, index) => const SizedBox(height: 10),
        ),
        //TOTAL AÑO
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.only(right: 10, left: 10, top: 20, bottom: 10),
            child: GestureDetector(
              onTap: () async {
                countShowSaving++;
                if (countShowSaving == 5) {
                  await showSavingAmount(context, mainProvider, widget.shoppingHistory[0].shop,
                      widget.shoppingHistory.where((s) => s.price == 0).toList());
                  countShowSaving = 0;
                }
              },
              child: HistoryLevelTotalWidget(
                  title: 'TOTAL AÑO',
                  uds: totalQuantityYear,
                  amount: totalYear,
                  isLastTotal: false),
            ),
          ),
        ),
      ],
    );
  }
}
