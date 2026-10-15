import 'package:flutter/material.dart';
import 'package:shoppinglist/models/models.dart';
import 'package:shoppinglist/pages/_pages.dart';
import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/utils/enums.dart';
import 'package:shoppinglist/utils/utils.dart';
import 'package:shoppinglist/widgets/decorations/marquee_widget.dart';

Future<dynamic> showSavingAmount(
    BuildContext context, MainProvider mainProvider, Shop shop, List<ShoppingHistory> nullPrices) {
  final double savingAmount = nullPrices.fold(
    0.0,
    (sum, line) => sum + line.quantity * mainProvider.getProductPrice(line.product, shop),
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
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...mapProducts.entries.map(
                (e) {
                  Product line = e.key;
                  double newPrice = mainProvider.getProductPrice(line, shop);
                  double totalLine = e.value * newPrice;
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      splashColor: Utils.oscuro,
                      borderRadius: BorderRadius.circular(20),
                      onTap: () =>
                          Navigator.pushNamed(context, ProductPage.routeName, arguments: line),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 3),
                        child: Row(
                          children: [
                            Image(image: line.imageType.image(), width: 20, height: 20),
                            const SizedBox(width: 7),
                            Expanded(
                              child: MarqueeWidget(
                                  child: Text(
                                      line.name +
                                          (line.details.isNotEmpty ? ' (${line.details})' : ''),
                                      style: mainProvider.itemStyle)),
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
                      ),
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
