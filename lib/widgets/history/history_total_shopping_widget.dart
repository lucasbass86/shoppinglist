import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:shoppinglist/models/models.dart';
import 'package:shoppinglist/pages/_pages.dart';
import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/utils/enums.dart';
import 'package:shoppinglist/utils/utils.dart';
import 'package:shoppinglist/widgets/decorations/marquee_widget.dart';

class HistoryTotalShoppingWidget extends StatelessWidget {
  final List<ShoppingHistory> shoppingHistory;
  const HistoryTotalShoppingWidget({super.key, required this.shoppingHistory});

  @override
  Widget build(BuildContext context) {
    MainProvider mainProvider = Provider.of(context);
    List<int> ids = shoppingHistory.map((e) => e.product.id).toSet().toList();

    return SliverList.builder(
      itemCount: ids.length,
      itemBuilder: (context, index) {
        Product product = mainProvider.products.firstWhere((e) => e.id == ids[index]);
        List<ShoppingHistory> group =
            shoppingHistory.where((e) => e.product.id == ids[index]).toList();
        final int total = group.fold(0, (sum, item) => sum + item.quantity);
        final double price = group.fold(0, (sum, item) => sum + (item.quantity * item.price));
        return GestureDetector(
          onTap: () => Navigator.pushNamed(context, ProductPage.routeName, arguments: product),
          child: FadeInLeft(
            delay: Duration(milliseconds: 20 * index),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Utils.claro,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Hero(
                    tag: '${Utils.tagProduct}${product.id}',
                    child: Image(image: product.imageType.image(), width: 40, height: 40),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MarqueeWidget(child: Text(product.name, style: mainProvider.itemStyle)),
                        Text('${price.toStringAsFixed(2)}€', style: mainProvider.itemStyle),
                      ],
                    ),
                  ),
                  Text('$total uds', style: mainProvider.itemStyle),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
