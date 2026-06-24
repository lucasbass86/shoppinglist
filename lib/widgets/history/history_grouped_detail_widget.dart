import 'package:flutter/material.dart';
import 'package:shoppinglist/models/models.dart';
import 'package:shoppinglist/pages/_pages.dart';
import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/utils/enums.dart';
import 'package:shoppinglist/utils/utils.dart';
import 'package:shoppinglist/widgets/_widgets.dart';

class HistoryGroupedDetailWidget extends StatelessWidget {
  final List<ShoppingHistory> shoppingHistory;
  final ETypeShoppings type;
  final bool little;
  const HistoryGroupedDetailWidget({
    super.key,
    required this.shoppingHistory,
    required this.type,
    this.little = false,
  });

  @override
  Widget build(BuildContext context) {
    final mainProvider = Provider.of<MainProvider>(context, listen: false);
    final years = shoppingHistory.map((e) => e.date.year).toSet().toList()
      ..sort((a, b) => b.compareTo(a));

    final double totalAmountYears = shoppingHistory.fold(
      0,
      (previousValue, element) => previousValue + (element.price * element.quantity),
    );
    final int totalQuantityYears =
        shoppingHistory.fold(0, (previousValue, element) => previousValue + element.quantity);

    return HistoryLevel1Widget(
      expansionTitle: _level1Header(context, mainProvider),
      children: [
        ...years.map(
          (year) {
            final histYear = shoppingHistory.where((h) => h.date.year == year).toList();
            final months = histYear.map((h) => h.date.month).toSet().toList()..sort();
            months.sort((a, b) => b.compareTo(a));
            final totalQuantityYear = histYear.fold<int>(0, (sum, item) => sum + item.quantity);
            final totalPriceYear =
                histYear.fold<double>(0, (sum, item) => sum + (item.quantity * item.price));

            return HistoryLevel2Widget(
              expansionTitle: _level2Header(year, mainProvider),
              children: [
                ...months.map((month) => _detail(month, mainProvider, histYear, context)),
                const SizedBox(height: 10),
                HistoryLevelTotalWidget(
                    title: 'Total $year', amount: totalPriceYear, uds: totalQuantityYear),
              ],
            );
          },
        ),
        HistoryLevelTotalWidget(
            title: 'TOTAL', amount: totalAmountYears, uds: totalQuantityYears, isLastTotal: true),
      ],
    );
  }

  Widget _detail(
    int month,
    MainProvider mainProvider,
    List<ShoppingHistory> histYear,
    BuildContext context,
  ) {
    final histMonth = histYear.where((h) => h.date.month == month).toList();
    histMonth.sort((a, b) => b.date.compareTo(a.date));
    final totalQuantityMonth = histMonth.fold<int>(0, (sum, item) => sum + item.quantity);
    final totalPriceMonth = histMonth.fold<double>(
      0,
      (sum, item) => sum + (item.quantity * item.price),
    );

    return HistoryLevel3Widget(
      expansionTitle: _level3Header(month, mainProvider),
      children: [
        ...histMonth.map((h) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: InkWell(
              splashColor: Utils.oscuro,
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                List<ShoppingHistory> history =
                    mainProvider.shoppingHistory.where((his) => his.cartId == h.cartId).toList();
                Navigator.pushNamed(context, HistoryDetailPage.routeName, arguments: history);
              },
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      Utils.dateEnglishToSpanish(h.date.toString(), showTime: false),
                      style: mainProvider.itemStyle,
                    ),
                  ),
                  Text('${h.quantity}x',
                      style: mainProvider.itemStyle.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(width: 6),
                  Text(
                    h.price.toStringAsFixed(2),
                    style: mainProvider.itemStyle,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '= ${(h.quantity * h.price).toStringAsFixed(2)}€',
                    style: mainProvider.itemStyle.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
        HistoryLevelTotalWidget(
            uds: totalQuantityMonth,
            amount: totalPriceMonth,
            title: 'Total ${Utils.monthName(month)}:'),
      ],
    );
  }

  Widget _level1Header(BuildContext context, MainProvider mainProvider) {
    //OBTENER EL PRODUCTO ORIGINAL:
    Product product =
        mainProvider.products.firstWhere((p) => p.id == shoppingHistory[0].product.id);
    return GestureDetector(
      onLongPress: () => type == ETypeShoppings.byProduct
          ? Navigator.pushNamed(context, ProductPage.routeName, arguments: product)
          : Navigator.pushNamed(context, ShopPage.routeName, arguments: shoppingHistory[0].shop),
      child: Row(
        children: [
          Hero(
            tag: type == ETypeShoppings.byProduct ? product.name : shoppingHistory[0].shop.name,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: type == ETypeShoppings.byProduct
                  ? Image(
                      image: shoppingHistory[0].product.imageType.image(), width: 36, height: 36)
                  : Image.asset(Utils.assetShop, width: 36, height: 36),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: MarqueeWidget(
              child: Text(
                type == ETypeShoppings.byProduct ? product.name : shoppingHistory[0].shop.name,
                style: mainProvider.mainTitleStyle.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Utils.oscuro,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _level2Header(int year, MainProvider mainProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Utils.medio.withAlpha(250), Utils.oscuro.withAlpha(210)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$year',
        style: mainProvider.minititleStyle.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _level3Header(int month, MainProvider mainProvider) {
    return Row(
      children: [
        Icon(Icons.calendar_month, color: Utils.oscuro.withAlpha((255 * 0.8).toInt())),
        const SizedBox(width: 6),
        Text(
          Utils.monthName(month),
          style: mainProvider.itemStyle.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Utils.oscuro,
          ),
        ),
      ],
    );
  }
}
