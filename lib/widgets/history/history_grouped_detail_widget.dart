import 'package:flutter/material.dart';
import 'package:shoppinglist/dialogs/bottoms.dart';
import 'package:shoppinglist/models/models.dart';
import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/utils/enums.dart';
import 'package:shoppinglist/utils/utils.dart';
import 'package:shoppinglist/widgets/_widgets.dart';

class HistoryGroupedDetailWidget extends StatelessWidget {
  final List<ShoppingHistory> shoppingHistory;
  const HistoryGroupedDetailWidget({
    super.key,
    required this.shoppingHistory,
  });

  //OPTIMIZADO PARA VER DESDE UNA TIENDA.
  @override
  Widget build(BuildContext context) {
    final mainProvider = Provider.of<MainProvider>(context, listen: false);
    final Product product = shoppingHistory[0].product;
    final double totalAmountProduct = shoppingHistory.fold(
      0,
      (previousValue, element) => previousValue + (element.price * element.quantity),
    );
    final int totalQuantityProduct =
        shoppingHistory.fold(0, (previousValue, element) => previousValue + element.quantity);

    final months = shoppingHistory.map((h) => h.date.month).toSet().toList()..sort();
    months.sort((a, b) => b.compareTo(a));
    int selectedMonth = months[0];
    int countShowSaving = 0;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      decoration: BoxDecoration(
        color: Utils.oscuro.withAlpha(100),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Utils.claro),
      ),
      child: ExpansionTile(
        iconColor: Utils.claro,
        collapsedIconColor: Utils.claro,
        tilePadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(20)),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(20)),
        childrenPadding: EdgeInsets.all(10),
        title: Row(
          children: [
            Image(image: product.imageType.image(), width: 40, height: 40),
            const SizedBox(width: 7),
            Text(
              product.name,
              style: mainProvider.minititleStyle.copyWith(color: Utils.claro),
            ),
          ],
        ),
        children: [
          StatefulBuilder(
            builder: (BuildContext context, setState) {
              List<ShoppingHistory> month = shoppingHistory
                  .where((s) => s.date.month == selectedMonth)
                  .toList()
                ..sort((a, b) => b.date.compareTo(a.date));
              final totalQuantityMonth = month.fold<int>(0, (sum, item) => sum + item.quantity);
              final totalPriceMonth = month.fold<double>(
                0,
                (sum, item) => sum + (item.quantity * item.price),
              );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //MESES
                  SizedBox(
                    height: 20,
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: months.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => setState(() => selectedMonth = months[index]),
                          child: Text(
                            Utils.monthName(months[index]),
                            style: mainProvider.itemStyle.copyWith(
                                color: selectedMonth == months[index] ? Utils.claro : Utils.medio),
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          const SizedBox(width: 30),
                    ),
                  ),
                  Divider(color: Utils.medio),
                  //DETALLE DE COMPRA DEL MES SELECCIONADO
                  ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: month.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Row(
                        children: [
                          Expanded(
                            child: Text(
                              Utils.dateEnglishToSpanish(month[index].toString(), showTime: false),
                              style: mainProvider.itemStyle.copyWith(color: Utils.claro),
                            ),
                          ),
                          Text('${month[index].quantity}x',
                              style: mainProvider.itemStyle.copyWith(color: Utils.claro)),
                          const SizedBox(width: 6),
                          Text(
                            month[index].price.toStringAsFixed(2),
                            style: mainProvider.itemStyle.copyWith(color: Utils.claro),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '= ${(month[index].quantity * month[index].price).toStringAsFixed(2)}€',
                            style: mainProvider.itemStyle.copyWith(color: Utils.claro),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  //TOTAL DEL MES SELECCIONADO
                  GestureDetector(
                    onTap: () async {
                      countShowSaving++;
                      if (countShowSaving == 3) {
                        await showSavingAmount(context, mainProvider, month[0].shop,
                            month.where((s) => s.price == 0).toList());
                        countShowSaving = 0;
                      }
                    },
                    child: HistoryLevelTotalWidget(
                      uds: totalQuantityMonth,
                      amount: totalPriceMonth,
                      title: 'Total mes',
                      isLastTotal: false,
                    ),
                  ),
                  Divider(color: Utils.medio),
                  //TOTAL DEL PRODUCTO ACTUAL
                  GestureDetector(
                    onTap: () async {
                      countShowSaving++;
                      if (countShowSaving == 5) {
                        await showSavingAmount(context, mainProvider, shoppingHistory[0].shop,
                            shoppingHistory.where((s) => s.price == 0).toList());
                        countShowSaving = 0;
                      }
                    },
                    child: HistoryLevelTotalWidget(
                        title: 'TOTAL',
                        uds: totalQuantityProduct,
                        amount: totalAmountProduct,
                        isLastTotal: true),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
