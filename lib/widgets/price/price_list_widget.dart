import 'package:flutter/material.dart';
import 'package:shoppinglist/models/models.dart';
import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/utils/utils.dart';

class PriceListWidget extends StatelessWidget {
  final ProductShop item;
  const PriceListWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    MainProvider mainProvider = Provider.of(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10, left: 5, right: 5),
        padding: const EdgeInsets.all(10),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Utils.oscuro.withAlpha(100),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Utils.claro),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.shop.name,
                  style: mainProvider.itemStyle.copyWith(color: Utils.claro),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  Utils.dateEnglishToSpanish(item.date.toString()),
                  style: mainProvider.itemStyle.copyWith(fontSize: 13, color: Utils.claro),
                ),
              ],
            ),
            Text(
              '${item.price.toStringAsFixed(2)} €',
              style: mainProvider.itemStyle.copyWith(color: Utils.claro),
            ),
          ],
        ),
      ),
    );
  }
}
