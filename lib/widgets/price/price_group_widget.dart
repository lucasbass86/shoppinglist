import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:shoppinglist/models/models.dart';
import 'package:shoppinglist/pages/_pages.dart';
import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/utils/enums.dart';
import 'package:shoppinglist/utils/utils.dart';
import 'package:shoppinglist/widgets/decorations/marquee_widget.dart';

class PriceGroupWidget extends StatelessWidget {
  final ETypeHistoryGroup type;
  const PriceGroupWidget({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    MainProvider mainProvider = Provider.of<MainProvider>(context, listen: false);
    late List<int> ids;
    late List<int> idsn2;
    if (type == ETypeHistoryGroup.product) {
      ids = mainProvider.pricesHistory.map((e) => e.productShop.product.id).toSet().toList();
    } else {
      ids = mainProvider.pricesHistory.map((e) => e.productShop.shop.id).toSet().toList();
    }

    return SliverList.builder(
      itemCount: ids.length,
      itemBuilder: (context, index) {
        List<PriceHistory> group;
        String title;
        if (type == ETypeHistoryGroup.product) {
          group = mainProvider.pricesHistory
              .where((h) => h.productShop.product.id == ids[index])
              .toList()
            ..sort((a, b) => a.productShop.product.name.compareTo(b.productShop.product.name));
          title = group[0].productShop.product.name;
          group.sort((a, b) => a.productShop.shop.id.compareTo(b.productShop.shop.id));
          idsn2 = group.map((e) => e.productShop.shop.id).toSet().toList();
        } else {
          group = mainProvider.pricesHistory
              .where((h) => h.productShop.shop.id == ids[index])
              .toList()
            ..sort((a, b) => a.productShop.product.name.compareTo(b.productShop.shop.name));
          title = group[0].productShop.shop.name;
          group.sort((a, b) => a.productShop.product.id.compareTo(b.productShop.product.id));
          idsn2 = group.map((e) => e.productShop.product.id).toSet().toList();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ZoomIn(
            delay: Duration(milliseconds: index * 20),
            child: Card(
              color: Utils.claro,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              borderOnForeground: false,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  title: GestureDetector(
                    onLongPress: () {
                      if (type == ETypeHistoryGroup.shop) {
                        Navigator.pushNamed(context, ShopPage.routeName,
                            arguments: group[0].productShop.shop);
                      } else if (type == ETypeHistoryGroup.product) {
                        Navigator.pushNamed(context, ProductPage.routeName,
                            arguments: group[0].productShop.product);
                      }
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Row(
                        children: [
                          if (type == ETypeHistoryGroup.product)
                            Hero(
                                tag: '${Utils.tagProduct}${group[0].productShop.product.id}',
                                child: Image(
                                    image: group[0].productShop.product.imageType.image(),
                                    width: 30,
                                    height: 30)),
                          if (type == ETypeHistoryGroup.shop)
                            Image.asset(Utils.assetShop, width: 30, height: 30),
                          const SizedBox(width: 7),
                          MarqueeWidget(
                              child: Text(title,
                                  style: mainProvider.mainTitleStyle.copyWith(fontSize: 20))),
                        ],
                      ),
                    ),
                  ),
                  childrenPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  iconColor: Utils.medio,
                  collapsedIconColor: Utils.medio,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  children: [
                    ...idsn2.map(
                      (item) {
                        List<PriceHistory> group2;
                        if (type == ETypeHistoryGroup.shop) {
                          group2 = group.where((e) => e.productShop.product.id == item).toList();
                        } else {
                          group2 = group.where((e) => e.productShop.shop.id == item).toList();
                        }
                        return InkWell(
                          borderRadius: BorderRadius.circular(20),
                          splashColor: Utils.medio,
                          onTap: () {
                            if (type == ETypeHistoryGroup.shop) {
                              Navigator.pushNamed(context, ProductPage.routeName,
                                  arguments: group2[index].productShop.product);
                            } else if (type == ETypeHistoryGroup.product) {
                              Navigator.pushNamed(context, ShopPage.routeName,
                                  arguments: group2[index].productShop.shop);
                            }
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (type == ETypeHistoryGroup.shop)
                                    FadeInDown(
                                        child: type == ETypeHistoryGroup.shop
                                            ? Image(
                                                image:
                                                    group2[0].productShop.product.imageType.image(),
                                                width: 30,
                                                height: 30)
                                            : Image.asset(Utils.assetShop, width: 30, height: 30)),
                                  const SizedBox(width: 7),
                                  ZoomIn(
                                      child: Text(
                                          type == ETypeHistoryGroup.shop
                                              ? group2[0].productShop.product.name
                                              : group2[0].productShop.shop.name,
                                          style: mainProvider.itemStyle)),
                                ],
                              ),
                              const SizedBox(height: 7),
                              ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: group2.length,
                                itemBuilder: (context, index2) {
                                  return ElasticInLeft(
                                    delay: Duration(milliseconds: index2 * 200),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            Utils.dateEnglishToSpanish(
                                                group2[index2].fecha.toString()),
                                            style: mainProvider.itemStyle),
                                        Text(
                                            '${group2[index2].productShop.price.toStringAsFixed(2)} €',
                                            style: mainProvider.itemStyle),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              Divider(color: Utils.oscuro),
                              const SizedBox(height: 10),
                            ],
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
