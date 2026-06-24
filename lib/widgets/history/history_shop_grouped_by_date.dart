import 'package:flutter/material.dart';
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
  @override
  Widget build(BuildContext context) {
    mainProvider = Provider.of<MainProvider>(context, listen: false);
    final months = widget.shoppingHistory.map((e) => e.date.month).toSet().toList()
      ..sort((a, b) => b.compareTo(a));

    final double totalAmount = widget.shoppingHistory.fold(
      0,
      (previousValue, element) => previousValue + (element.price * element.quantity),
    );
    final int totalQuantity = widget.shoppingHistory
        .fold(0, (previousValue, element) => previousValue + element.quantity);

    List<ShoppingHistory> nullPricesLevel1 =
        widget.shoppingHistory.where((h) => h.price == 0).toList();

    return HistoryLevel1Widget(
      expansionTitle: _level1Header(),
      children: [
        ...months.map((month) {
          final histMonth = widget.shoppingHistory.where((h) => h.date.month == month).toList();
          final days = histMonth.map((h) => h.date.day).toSet().toList()..sort();
          days.sort((a, b) => b.compareTo(a));
          final totalQuantityMonth = histMonth.fold<int>(0, (sum, item) => sum + item.quantity);
          final totalPriceMonth =
              histMonth.fold<double>(0, (sum, item) => sum + (item.quantity * item.price));

          List<ShoppingHistory> nullPricesLevel2 = histMonth.where((h) => h.price == 0).toList();

          return HistoryLevel2Widget(
            expansionTitle: _level2Header(month),
            children: [
              ...days.map((day) => _dayDetail(day, histMonth)),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () async {
                  countShowSaving++;
                  if (countShowSaving == 3) {
                    await _showSavingAmount(context, nullPricesLevel2);
                    countShowSaving = 0;
                  }
                },
                child: HistoryLevelTotalWidget(
                  uds: totalQuantityMonth,
                  amount: totalPriceMonth,
                  title: 'Total ${Utils.monthName(month)}',
                ),
              ),
            ],
          );
        }),
        GestureDetector(
          onTap: () async {
            countShowSaving++;
            if (countShowSaving == 5) {
              await _showSavingAmount(context, nullPricesLevel1);
              countShowSaving = 0;
            }
          },
          child: HistoryLevelTotalWidget(
              title: 'TOTAL', uds: totalQuantity, amount: totalAmount, isLastTotal: true),
        )
      ],
    );
  }

  Future<dynamic> _showSavingAmount(BuildContext context, List<ShoppingHistory> nullPrices) {
    final double savingAmount = nullPrices.fold(
      0.0,
      (sum, line) => sum + line.quantity * mainProvider.getProductPrice(line.product, line.shop),
    );
    Map<Product, int> mapProducts = {};
    for (ShoppingHistory his in nullPrices) {
      mapProducts.putIfAbsent(
          his.product,
          () => nullPrices
              .where((h) => h.product.id == his.product.id)
              .fold(0, (previousValue, element) => previousValue + element.quantity));
    }
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Utils.claro,
              borderRadius:
                  BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...mapProducts.entries.map(
                  (e) {
                    Product line = e.key;
                    double newPrice =
                        mainProvider.getProductPrice(line, widget.shoppingHistory[0].shop);
                    double totalLine = e.value * newPrice;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 3),
                      child: Row(
                        children: [
                          Image(image: line.imageType.image(), width: 20, height: 20),
                          const SizedBox(width: 7),
                          Expanded(
                            child: MarqueeWidget(
                                child: Text(line.name, style: mainProvider.itemStyle)),
                          ),
                          Text('${e.value}x', style: mainProvider.itemStyle),
                          Text("${newPrice.toStringAsFixed(2)}=", style: mainProvider.itemStyle),
                          Text(
                            '${totalLine.toStringAsFixed(2)}€',
                            style: mainProvider.itemStyle.copyWith(
                                color: totalLine == 0
                                    ? Colors.red[800]!.withAlpha(175)
                                    : Utils.oscuro),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Divider(color: Utils.oscuro),
                Text('El importe ahorrado es:  ${savingAmount.toStringAsFixed(2)}€',
                    style: mainProvider.titleStyle.copyWith(fontSize: 20)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _dayDetail(int day, List<ShoppingHistory> histMonth) {
    final histDay = histMonth.where((h) => h.date.day == day).toList();
    histDay.sort((a, b) => a.order.compareTo(b.order));
    final totalQuantityDay = histDay.fold<int>(0, (sum, item) => sum + item.quantity);
    final totalPriceDay = histDay.fold<double>(
      0,
      (sum, item) => sum + (item.quantity * item.price),
    );
    return HistoryLevel3Widget(
      expansionTitle:
          _level3Header(Utils.dateEnglishToSpanish(histDay[0].date.toString(), showTime: false)),
      children: [
        ...histDay.map(
          (h) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: InkWell(
                splashColor: Utils.oscuro,
                borderRadius: BorderRadius.circular(20),
                onTap: () =>
                    Navigator.pushNamed(context, ProductPage.routeName, arguments: h.product),
                child: Row(
                  children: [
                    Image(image: h.product.imageType.image(), width: 20, height: 20),
                    const SizedBox(width: 7),
                    Expanded(
                      child:
                          MarqueeWidget(child: Text(h.product.name, style: mainProvider.itemStyle)),
                    ),
                    Text('${h.quantity}x', style: mainProvider.itemStyle),
                    Text(h.price.toStringAsFixed(2), style: mainProvider.itemStyle),
                    Text('= ${(h.quantity * h.price).toStringAsFixed(2)}€',
                        style: mainProvider.itemStyle),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        HistoryLevelTotalWidget(
          action: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () =>
                Navigator.pushNamed(context, HistoryDetailPage.routeName, arguments: histDay),
            child: Icon(Icons.edit, color: Utils.medio),
          ),
          uds: totalQuantityDay,
          amount: totalPriceDay,
          title: 'Total:',
        ),
      ],
    );
  }

  Widget _level3Header(String histDay) {
    return Row(
      children: [
        Icon(Icons.calendar_month, color: Utils.oscuro.withAlpha((255 * 0.8).toInt())),
        const SizedBox(width: 6),
        Text(
          histDay,
          style: mainProvider.itemStyle.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Utils.oscuro,
          ),
        ),
      ],
    );
  }

  Widget _level2Header(int month) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Utils.medio.withAlpha(250), Utils.oscuro.withAlpha(210)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        Utils.monthName(month),
        style: mainProvider.minititleStyle.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _level1Header() {
    return Row(
      children: [
        Icon(Icons.calendar_month),
        const SizedBox(width: 12),
        Expanded(
          child: MarqueeWidget(
            child: Text(
              widget.shoppingHistory[0].date.year.toString(),
              style: mainProvider.mainTitleStyle.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Utils.oscuro,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
