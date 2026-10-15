import 'package:flutter/material.dart';
import 'package:shoppinglist/models/models.dart';
import 'package:shoppinglist/pages/_pages.dart';
import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/utils/enums.dart';
import 'package:shoppinglist/utils/utils.dart';

class PriceGroupByShopWidget extends StatelessWidget {
  const PriceGroupByShopWidget({super.key});

  //OPTIMIZADO PARA VER POR TIENDA
  @override
  Widget build(BuildContext context) {
    MainProvider mainProvider = Provider.of<MainProvider>(context, listen: false);
    List<Shop> shops = mainProvider.pricesHistory.map((e) => e.productShop.shop).toSet().toList();
    return SliverList.builder(
      itemCount: shops.length,
      itemBuilder: (context, index) {
        final Shop shop = shops[index];
        List<int> productsIds = mainProvider.pricesHistory
            .where((s) => s.productShop.shop.id == shop.id)
            .map((p) => p.productShop.product.id)
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
              onLongPress: () => Navigator.pushNamed(context, ShopPage.routeName, arguments: shop),
              child: Row(
                children: [
                  Image.asset(Utils.assetShop, width: 40, height: 40),
                  const SizedBox(width: 7),
                  Text(
                    shop.name,
                    style: mainProvider.minititleStyle.copyWith(color: Utils.claro),
                  ),
                ],
              ),
            ),
            children: [
              ListView.builder(
                physics: const ClampingScrollPhysics(),
                shrinkWrap: true,
                itemCount: productsIds.length,
                itemBuilder: (BuildContext context, int index) {
                  final Product product =
                      mainProvider.products.firstWhere((p) => p.id == productsIds[index]);
                  final List<PriceHistory> prices = mainProvider.priceHistoryByProduct(product);
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
                            Image(image: product.imageType.image(), width: 30, height: 30),
                            Text(product.name,
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
