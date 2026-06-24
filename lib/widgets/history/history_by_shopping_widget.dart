import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:shoppinglist/models/models.dart';
import 'package:shoppinglist/pages/_pages.dart';
import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/utils/enums.dart';
import 'package:shoppinglist/utils/utils.dart';
import 'package:shoppinglist/widgets/decorations/marquee_widget.dart';

class HistoryByShoppingWidget extends StatelessWidget {
  final List<ShoppingHistory> shoppingHistory;
  final bool showShopName;
  const HistoryByShoppingWidget(
      {super.key, required this.shoppingHistory, this.showShopName = true});

  @override
  Widget build(BuildContext context) {
    MainProvider mainProvider = Provider.of<MainProvider>(context, listen: false);
    final int totalQuantity = shoppingHistory.fold(0, (sum, item) => sum + item.quantity);
    final double totalPrice =
        shoppingHistory.fold<double>(0, (sum, item) => sum + (item.quantity * item.price));
    shoppingHistory.sort((a, b) => a.order.compareTo(b.order));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ZoomIn(
        child: Card(
          color: Utils.claro,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          borderOnForeground: false,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              title: Row(
                children: [
                  if (showShopName) Image.asset(Utils.assetShop, width: 30, height: 30),
                  if (!showShopName) Icon(Icons.calendar_month, color: Utils.oscuro),
                  const SizedBox(width: 7),
                  if (showShopName)
                    MarqueeWidget(
                        child: Text(shoppingHistory[0].shop.name,
                            style: mainProvider.mainTitleStyle.copyWith(fontSize: 20))),
                  if (!showShopName)
                    Text(
                        Utils.dateEnglishToSpanish(shoppingHistory[0].date.toString(),
                            showTime: false),
                        style: mainProvider.mainTitleStyle.copyWith(fontSize: 20))
                ],
              ),
              childrenPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              iconColor: Utils.medio,
              collapsedIconColor: Utils.medio,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              children: [
                if (showShopName)
                  Text(
                    Utils.dateEnglishToSpanish(shoppingHistory[0].date.toString(), showTime: false),
                    style: mainProvider.mainTitleStyle.copyWith(fontSize: 17),
                  ),
                ListView.builder(
                  physics: ClampingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: shoppingHistory.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      borderRadius: BorderRadius.circular(20),
                      splashColor: Utils.medio,
                      onTap: () {
                        Navigator.pushNamed(context, ProductPage.routeName,
                            arguments: shoppingHistory[index].product);
                      },
                      child: Row(
                        children: [
                          Image(
                              image: shoppingHistory[index].product.imageType.image(),
                              width: 20,
                              height: 20),
                          const SizedBox(width: 7),
                          Expanded(
                            child: MarqueeWidget(
                                child: Text(shoppingHistory[index].product.name,
                                    style: mainProvider.itemStyle)),
                          ),
                          Text('${shoppingHistory[index].quantity}x',
                              style: mainProvider.itemStyle),
                          Text('${shoppingHistory[index].price.toStringAsFixed(2)}=',
                              style: mainProvider.itemStyle),
                          Text(
                              '${(shoppingHistory[index].quantity * shoppingHistory[index].price).toStringAsFixed(2)} €',
                              style: mainProvider.itemStyle),
                        ],
                      ),
                    );
                  },
                ),
                Divider(color: Utils.oscuro),
                ZoomIn(
                  delay: const Duration(milliseconds: 400),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        splashColor: Utils.medio,
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          Navigator.pushNamed(context, HistoryDetailPage.routeName,
                                  arguments: shoppingHistory)
                              .then((_) {
                            mainProvider.canLoad = true;
                            mainProvider.loadShoppingHistory();
                          });
                        },
                        child: Icon(Icons.edit, color: Utils.oscuro, size: 30),
                      ),
                      const SizedBox(width: 5),
                      Text('Total ${totalPrice.toStringAsFixed(2)}€',
                          style: mainProvider.itemStyle),
                      Expanded(child: const SizedBox(width: 1)),
                      Text('$totalQuantity ${totalQuantity == 1 ? 'ud' : 'uds'}',
                          style: mainProvider.itemStyle),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
