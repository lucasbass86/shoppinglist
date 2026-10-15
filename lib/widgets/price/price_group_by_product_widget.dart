import 'package:flutter/material.dart';
import 'package:shoppinglist/models/models.dart';
import 'package:shoppinglist/pages/_pages.dart';
import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/utils/enums.dart';
import 'package:shoppinglist/utils/utils.dart';

class PriceGroupByProductWidget extends StatelessWidget {
  const PriceGroupByProductWidget({super.key});

  //OPTIMIZADO PARA VER POR PRODUCTO
  @override
  Widget build(BuildContext context) {
    MainProvider mainProvider = Provider.of<MainProvider>(context, listen: false);
    List<Product> products =
        mainProvider.pricesHistory.map((e) => e.productShop.product).toSet().toList();
    return SliverList.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final Product product = products[index];
        List<int> shopsIds = mainProvider.pricesHistory
            .where((s) => s.productShop.product.id == product.id)
            .map((p) => p.productShop.shop.id)
            .toSet()
            .toList();
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
            title: GestureDetector(
              onLongPress: () =>
                  Navigator.pushNamed(context, ProductPage.routeName, arguments: product),
              child: Row(
                children: [
                  Image(image: product.imageType.image(), width: 40, height: 40),
                  const SizedBox(width: 7),
                  Text(
                    product.name,
                    style: mainProvider.minititleStyle.copyWith(color: Utils.claro),
                  ),
                ],
              ),
            ),
            children: [
              ListView.builder(
                physics: const ClampingScrollPhysics(),
                shrinkWrap: true,
                itemCount: shopsIds.length,
                itemBuilder: (BuildContext context, int index) {
                  final Shop shop = mainProvider.shops.firstWhere((p) => p.id == shopsIds[index]);
                  final List<PriceHistory> prices = mainProvider.pricesHistory
                      .where((p) =>
                          p.productShop.shop.id == shop.id &&
                          p.productShop.product.id == product.id)
                      .toList();
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
                      shape:
                          RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(20)),
                      collapsedShape:
                          RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(20)),
                      childrenPadding: EdgeInsets.all(10),
                      title: GestureDetector(
                        onLongPress: () =>
                            Navigator.pushNamed(context, ProductPage.routeName, arguments: product),
                        child: Row(
                          spacing: 10,
                          children: [
                            Image.asset(Utils.assetShop, width: 30, height: 30),
                            Text(shop.name,
                                style: mainProvider.minititleStyle.copyWith(color: Utils.claro)),
                          ],
                        ),
                      ),
                      children: [
                        ListView.builder(
                          physics: const ClampingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: prices.length,
                          itemBuilder: (BuildContext context, int index) {
                            final PriceHistory price = prices[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      Utils.dateEnglishToSpanish(price.fecha.toString(),
                                          showTime: false),
                                      style: mainProvider.itemStyle.copyWith(color: Utils.claro)),
                                  Text('${price.productShop.price.toStringAsFixed(2)} €',
                                      style: mainProvider.itemStyle.copyWith(color: Utils.claro)),
                                ],
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
