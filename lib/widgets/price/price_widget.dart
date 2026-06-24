import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:shoppinglist/dialogs/dialogs.dart';
import 'package:shoppinglist/models/models.dart';
import 'package:shoppinglist/pages/_pages.dart';
import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/utils/enums.dart';
import 'package:shoppinglist/utils/utils.dart';
import 'package:shoppinglist/widgets/_widgets.dart';

class PriceWidget extends StatefulWidget {
  final ProductShop productShop;
  final bool isProduct;
  const PriceWidget({super.key, required this.productShop, this.isProduct = false});

  @override
  State<PriceWidget> createState() => _PriceWidgetState();
}

class _PriceWidgetState extends State<PriceWidget> {
  double buttonSize = 40;
  @override
  Widget build(BuildContext context) {
    MainProvider mainProvider = Provider.of<MainProvider>(context);
    return GestureDetector(
      onTap: () {
        if (!widget.isProduct) {
          Navigator.pushNamed(context, ShopPage.routeName, arguments: widget.productShop.shop);
        } else {
          Navigator.pushNamed(context, ProductPage.routeName,
              arguments: widget.productShop.product);
        }
      },
      child: ZoomIn(
        duration: Utils.fadeInDuration,
        child: Container(
          width: double.infinity,
          height: 90,
          margin: const EdgeInsets.only(right: 20, top: 25),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                bottom: 0,
                left: 45,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.only(left: 40, top: 10),
                  decoration: BoxDecoration(
                    color: Utils.claro,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              child: Text(
                                widget.isProduct
                                    ? widget.productShop.product.name
                                    : widget.productShop.shop.name,
                                style: mainProvider.itemStyle,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Row(
                              children: [
                                Text(
                                  widget.productShop.price.toStringAsFixed(2),
                                  style: mainProvider.itemStyle.copyWith(fontSize: 20),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Container(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    '€',
                                    style: mainProvider.itemStyle.copyWith(fontSize: 17),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              Utils.dateEnglishToSpanish(widget.productShop.date.toString()),
                              style: mainProvider.titleStyle.copyWith(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          DateTime? date = DateTime.now();
                          final modPrice = await showProductPrice(context, widget.productShop);
                          if (modPrice[0] && context.mounted) {
                            DateTime? date2 = await showDate(context);
                            if (date2 != null) {
                              date = DateTime(date2.year, date2.month, date2.day,
                                  DateTime.now().hour + 1, DateTime.now().minute);
                            }
                            widget.productShop.date = date;
                            Utils.boxPrices.put(widget.productShop.id, widget.productShop.toJson());
                            mainProvider.calculateAmount();
                            mainProvider.addHistoricoPrecio(widget.productShop);
                            setState(() {});
                          }
                        },
                        child: Container(
                          width: buttonSize,
                          height: buttonSize,
                          decoration: BoxDecoration(
                            color: Utils.oscuro,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.edit,
                              color: Utils.claro,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            mainProvider.addCart(
                                shop: widget.productShop.shop,
                                cartProduct:
                                    CartProduct(product: widget.productShop.product, quantity: 1));
                            TopWidget.topAnimationController.forward(from: 0.0);
                          });
                        },
                        child: Container(
                          width: buttonSize,
                          height: buttonSize,
                          decoration: BoxDecoration(
                            color: Utils.oscuro,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.shopping_basket_rounded,
                              color: Utils.claro,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                    ],
                  ),
                ),
              ),
              !widget.isProduct
                  ? Image.asset(Utils.assetShop, width: 80, height: 80)
                  : Hero(
                      tag: '${Utils.tagProduct}${widget.productShop.product.id}',
                      child: Image(
                          image: widget.productShop.product.imageType.image(),
                          width: 80,
                          height: 80),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
