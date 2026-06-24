import 'package:flutter/material.dart';
import 'package:shoppinglist/models/models.dart';
import 'package:shoppinglist/pages/_pages.dart';
import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/sharedpreferences/preferences.dart';
import 'package:shoppinglist/utils/enums.dart';
import 'package:shoppinglist/utils/utils.dart';
import 'package:shoppinglist/widgets/decorations/marquee_widget.dart';

class GraphicProductWidget extends StatelessWidget {
  final Product product;
  final Shop shop;
  final String? year;
  final double quantity;
  final DateTime? startDate;
  final DateTime? finishDate;
  const GraphicProductWidget(
      {super.key,
      required this.product,
      required this.shop,
      this.year,
      required this.quantity,
      this.startDate,
      this.finishDate});

  @override
  Widget build(BuildContext context) {
    MainProvider mainProvider = Provider.of(context, listen: false);
    List<ShoppingHistory> shoppingHistory = mainProvider.shoppingHistory
        .where((h) => h.product.id == product.id && h.shop.id == shop.id)
        .toList();
    if (year != 'TODOS' && year != null) {
      shoppingHistory = shoppingHistory.where((h) => h.date.year == int.parse(year!)).toList();
    }
    if (startDate != null) {
      shoppingHistory = shoppingHistory.where((h) => h.date.isAfter(startDate!)).toList();
    }
    if (finishDate != null) {
      shoppingHistory = shoppingHistory.where((h) => h.date.isBefore(finishDate!)).toList();
    }
    final double totalAmount = shoppingHistory.fold(0, (prev, s) => prev + (s.price * s.quantity));
    final double totalQuantity = shoppingHistory.fold(0, (prev, s) => prev + s.quantity);
    return Card(
      color: Utils.claro,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      borderOnForeground: false,
      elevation: 20,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ExpansionTile(
          iconColor: Utils.medio,
          collapsedIconColor: Utils.medio,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          childrenPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          title: GestureDetector(
            onLongPress: () =>
                Navigator.pushNamed(context, ProductPage.routeName, arguments: product),
            child: Row(
              children: [
                Hero(
                    tag: '${Utils.tagProduct}${product.id}',
                    child: Image(image: product.imageType.image(), width: 30, height: 30)),
                const SizedBox(width: 10),
                Expanded(
                    child: MarqueeWidget(child: Text(product.name, style: mainProvider.itemStyle))),
                const SizedBox(width: 10),
                Text(
                    Preferences.graphicByAmount
                        ? '${quantity.toStringAsFixed(2)}€'
                        : quantity.toStringAsFixed(0),
                    style: mainProvider.itemStyle),
              ],
            ),
          ),
          children: [
            ListView.builder(
              physics: ClampingScrollPhysics(),
              shrinkWrap: true,
              itemCount: shoppingHistory.length,
              itemBuilder: (context, index) {
                ShoppingHistory h = shoppingHistory[index];
                return Row(
                  children: [
                    Expanded(
                      child: Text(Utils.dateEnglishToSpanish(h.date.toString(), showTime: false),
                          style: mainProvider.itemStyle),
                    ),
                    Text('${h.quantity}x',
                        style: mainProvider.itemStyle.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 6),
                    Text('${h.price.toStringAsFixed(2)}€', style: mainProvider.itemStyle),
                    const SizedBox(width: 6),
                    Text(
                      '= ${(h.quantity * h.price).toStringAsFixed(2)}€',
                      style: mainProvider.itemStyle.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 10),
            //TOTAL
            Container(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
              margin: const EdgeInsets.symmetric(vertical: 20),
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
                    'Total ${shoppingHistory[0].product.name}',
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
          ],
        ),
      ),
    );
  }
}
