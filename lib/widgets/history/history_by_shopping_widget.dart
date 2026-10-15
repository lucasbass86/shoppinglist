import 'package:flutter/material.dart';
import 'package:shoppinglist/dialogs/bottoms.dart';
import 'package:shoppinglist/models/models.dart';
import 'package:shoppinglist/pages/_pages.dart';
import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/utils/enums.dart';
import 'package:shoppinglist/utils/utils.dart';
import 'package:shoppinglist/widgets/_widgets.dart';

class HistoryByShoppingWidget extends StatelessWidget {
  final List<ShoppingHistory> shoppingHistory;
  final bool showShopName;
  const HistoryByShoppingWidget(
      {super.key, required this.shoppingHistory, this.showShopName = true});

  //OPTIMIZADO PARA VER DESDE UNA TIENDA
  @override
  Widget build(BuildContext context) {
    MainProvider mainProvider = Provider.of<MainProvider>(context, listen: false);
    final int totalQuantity = shoppingHistory.fold(0, (sum, item) => sum + item.quantity);
    final double totalPrice =
        shoppingHistory.fold<double>(0, (sum, item) => sum + (item.quantity * item.price));
    shoppingHistory.sort((a, b) => a.order.compareTo(b.order));
    int countShowSaving = 0;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      decoration: BoxDecoration(
        color: Utils.oscuro.withAlpha(100),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Utils.claro),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ExpansionTile(
          iconColor: Utils.claro,
          collapsedIconColor: Utils.claro,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          tilePadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          title: Row(
            children: [
              if (showShopName) Image.asset(Utils.assetShop, width: 30, height: 30),
              if (!showShopName)
                Icon(
                  Icons.calendar_month,
                  color: Utils.claro,
                  size: 30,
                ),
              const SizedBox(width: 7),
              if (showShopName)
                MarqueeWidget(
                  child: Text(
                    shoppingHistory[0].shop.name,
                    style: mainProvider.minititleStyle.copyWith(color: Utils.claro),
                  ),
                ),
              if (!showShopName)
                Text(
                  Utils.dateEnglishToSpanish(shoppingHistory[0].date.toString(), showTime: false),
                  style: mainProvider.minititleStyle.copyWith(color: Utils.claro),
                ),
            ],
          ),
          childrenPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          children: [
            if (showShopName)
              Text(
                Utils.dateEnglishToSpanish(shoppingHistory[0].date.toString(), showTime: false),
                style: mainProvider.minititleStyle.copyWith(color: Utils.claro),
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
                            child: Text(
                                shoppingHistory[index].product.name +
                                    (shoppingHistory[index].product.details.isNotEmpty
                                        ? ' (${shoppingHistory[index].product.details})'
                                        : ''),
                                style: mainProvider.itemStyle.copyWith(color: Utils.claro))),
                      ),
                      Text('${shoppingHistory[index].quantity}x',
                          style: mainProvider.itemStyle.copyWith(color: Utils.claro)),
                      Text('${shoppingHistory[index].price.toStringAsFixed(2)}=',
                          style: mainProvider.itemStyle.copyWith(color: Utils.claro)),
                      Text(
                          '${(shoppingHistory[index].quantity * shoppingHistory[index].price).toStringAsFixed(2)} €',
                          style: mainProvider.itemStyle.copyWith(color: Utils.claro)),
                    ],
                  ),
                );
              },
            ),
            Divider(color: Utils.oscuro),
            //TOTAL DEL DIA SELECCIONADO
            GestureDetector(
              onTap: () async {
                countShowSaving++;
                if (countShowSaving == 3) {
                  await showSavingAmount(
                      context, mainProvider, shoppingHistory[0].shop, shoppingHistory);
                  countShowSaving = 0;
                }
              },
              child: HistoryLevelTotalWidget(
                action: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => Navigator.pushNamed(context, HistoryDetailPage.routeName,
                      arguments: shoppingHistory),
                  child: Icon(Icons.edit, color: Utils.medio),
                ),
                uds: totalQuantity,
                amount: totalPrice,
                title: 'Total',
                isLastTotal: false,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
