import 'package:flutter/material.dart';
import 'package:shoppinglist/models/models.dart';
import 'package:shoppinglist/pages/_pages.dart';
import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/utils/utils.dart';
import 'package:shoppinglist/widgets/decorations/marquee_widget.dart';

class ShopWidget extends StatelessWidget {
  final Shop shop;
  const ShopWidget({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    MainProvider mainProvider = Provider.of<MainProvider>(context);
    final double size = Utils.productImageSize.toDouble();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.pushNamed(context, ShopPage.routeName, arguments: shop),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Container(
            decoration: BoxDecoration(
              color: Utils.claro,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Utils.oscuro,
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Hero(
                  tag: '${Utils.tagShop}${shop.id}',
                  child: Image.asset(
                    Utils.assetShop,
                    width: size,
                    height: size,
                  ),
                ),
                MarqueeWidget(
                  child: Text(
                    shop.name,
                    style: mainProvider.titleStyle.copyWith(fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
