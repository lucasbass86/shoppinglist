import 'package:flutter/material.dart';
import 'package:shoppinglist/dialogs/dialogs.dart';
import 'package:shoppinglist/models/models.dart';
import 'package:shoppinglist/pages/_pages.dart';
import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/sharedpreferences/preferences.dart';
import 'package:shoppinglist/utils/enums.dart';
import 'package:shoppinglist/utils/utils.dart';
import 'package:shoppinglist/widgets/_widgets.dart';

class ShopSliverPricesWidget extends StatefulWidget {
  final List<ProductShop> productosAct;
  final Shop shop;
  const ShopSliverPricesWidget({super.key, required this.shop, required this.productosAct});

  @override
  State<ShopSliverPricesWidget> createState() => _ShopSliverPricesWidgetState();
}

class _ShopSliverPricesWidgetState extends State<ShopSliverPricesWidget> {
  late MainProvider mainProvider;
  @override
  Widget build(BuildContext context) {
    mainProvider = Provider.of<MainProvider>(context);
    return SliverMainAxisGroup(
        slivers: widget.productosAct.isNotEmpty
            ? [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: !Preferences.isViewGraphic
                          ? MainAxisAlignment.spaceBetween
                          : MainAxisAlignment.end,
                      children: [
                        if (!Preferences.isViewGraphic)
                          Icon(Icons.swap_horiz_rounded,
                              size: Utils.iconSizeStandar, color: Utils.claro),
                        Row(
                          children: [
                            Text('Lista',
                                style: mainProvider.titleStyle
                                    .copyWith(fontSize: 17, color: Utils.claro)),
                            const SizedBox(width: 7),
                            Switch(
                              value: !Preferences.isViewGraphic,
                              onChanged: (value) {
                                setState(() {
                                  Preferences.isViewGraphic = !value;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Preferences.isViewGraphic
                    ? SliverList.builder(
                        itemCount: widget.productosAct.length,
                        itemBuilder: (context, index) {
                          final item = widget.productosAct[index];
                          return Dismissible(
                            key: Key('${widget.productosAct[index].id}shop'),
                            direction: DismissDirection.startToEnd,
                            confirmDismiss: (direction) async {
                              showMessage(
                                      context: context, message: '¿Borrar el precio?', cancel: true)
                                  .then((value) {
                                if (value) {
                                  mainProvider.removeProductShop(widget.productosAct[index]);
                                } else {
                                  widget.productosAct.insert(index, item);
                                }
                                setState(() {});
                              });
                              return false;
                            },
                            background: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.delete,
                                  size: 40,
                                  color: Colors.red[300],
                                ),
                              ],
                            ),
                            child: PriceWidget(
                                productShop: widget.productosAct[index], isProduct: true),
                          );
                        },
                      )
                    : SliverList.builder(
                        itemCount: widget.productosAct.length,
                        itemBuilder: (context, index) {
                          final item = widget.productosAct[index];
                          return Dismissible(
                            key: Key('${widget.productosAct[index].id}product'),
                            background: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(Icons.delete, size: 40, color: Colors.red[300]),
                                  Icon(Icons.edit, size: 40, color: Colors.green[300]),
                                ],
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: GestureDetector(
                                onTap: () => Navigator.pushNamed(context, ProductPage.routeName,
                                    arguments: item.product),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 10, right: 10, left: 10),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Utils.oscuro.withAlpha(100),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Utils.claro),
                                  ),
                                  child: Row(
                                    children: [
                                      Image(
                                          image: item.product.imageType.image(),
                                          width: 50,
                                          height: 50),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.product.name,
                                              style: mainProvider.itemStyle
                                                  .copyWith(color: Utils.claro),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              Utils.dateEnglishToSpanish(item.date.toString()),
                                              style: mainProvider.itemStyle
                                                  .copyWith(fontSize: 13, color: Utils.claro),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text('${item.price.toStringAsFixed(2)} €',
                                          style:
                                              mainProvider.itemStyle.copyWith(color: Utils.claro)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            confirmDismiss: (direction) async {
                              bool ret = true;
                              if (direction == DismissDirection.endToStart) {
                                DateTime? date = DateTime.now();
                                final c =
                                    await showProductPrice(context, widget.productosAct[index]);
                                if (c[0] && context.mounted) {
                                  final value = await showDate(context);
                                  if (value != null) {
                                    date = DateTime(value.year, value.month, value.day,
                                        DateTime.now().hour + 1, DateTime.now().minute);
                                  }
                                  widget.productosAct[index].date = date;
                                  Utils.boxPrices.put(widget.productosAct[index].id,
                                      widget.productosAct[index].toJson());
                                  mainProvider.calculateAmount();
                                  mainProvider.addHistoricoPrecio(widget.productosAct[index]);
                                  ret = true;
                                }
                                ret = false;
                              } else {
                                final value = await showMessage(
                                    context: context, message: '¿Borrar el precio?', cancel: true);
                                if (value) {
                                  mainProvider.removeProductShop(widget.productosAct[index]);
                                  ret = true;
                                } else {
                                  widget.productosAct.insert(index, item);
                                  ret = false;
                                }
                              }
                              setState(() {});
                              return ret;
                            },
                          );
                        }),
              ]
            : [sliverNoProducts()]);
  }

  Widget sliverNoProducts() {
    return SliverFillRemaining(
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('No hay precios asociados', style: mainProvider.titleStyle),
            const SizedBox(width: 15),
            InkWell(
              onTap: () => _createPrice(context),
              borderRadius: BorderRadius.circular(20),
              child: Icon(Icons.add, color: Utils.oscuro, size: 40),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createPrice(BuildContext context) async {
    if (mainProvider.products.isNotEmpty) {
      final confirmShop = await addShopPriceFromShop(context, widget.shop);
      if (confirmShop[0] && context.mounted) {
        ProductShop productShop = mainProvider.newProductShop(confirmShop[1], widget.shop, 0);
        final price = await showProductPrice(context, productShop);
        if (price[0]) {
          setState(() {
            mainProvider.addProductShop(productShop);
          });
        }
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(Utils.snackBar('No hay productos creados . . .', isGood: false));
    }
  }
}
