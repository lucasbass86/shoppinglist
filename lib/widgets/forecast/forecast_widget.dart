import 'package:flutter/material.dart';
import 'package:shoppinglist/dialogs/dialogs.dart';
import 'package:shoppinglist/models/models.dart';
import 'package:shoppinglist/pages/_pages.dart';
import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/utils/enums.dart';
import 'package:shoppinglist/utils/utils.dart';
import 'package:shoppinglist/widgets/_widgets.dart';

class ForecastWidget extends StatefulWidget {
  final Forecast entry;
  const ForecastWidget({super.key, required this.entry});

  @override
  State<ForecastWidget> createState() => _ForecastWidgetState();
}

class _ForecastWidgetState extends State<ForecastWidget> {
  late MainProvider mainProvider;

  @override
  Widget build(BuildContext context) {
    mainProvider = Provider.of<MainProvider>(context);
    final double size = Utils.productImageSize.toDouble();
    final Image image =
        Image(image: widget.entry.product.imageType.image(), width: size, height: size);
    return Stack(
      children: [
        GestureDetector(
          onTap: () =>
              Navigator.pushNamed(context, ProductPage.routeName, arguments: widget.entry.product),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            decoration: BoxDecoration(
              color: Utils.oscuro.withAlpha(100),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Utils.claro),
            ),
            child: ListTile(
              title: Row(
                children: [
                  Hero(
                      tag: '${Utils.tagProduct}${widget.entry.product.id}',
                      child: Image(image: image.image, width: 70, height: 70)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MarqueeWidget(
                          child: Text(
                              widget.entry.product.name +
                                  (widget.entry.product.details.isNotEmpty
                                      ? ' (${widget.entry.product.details})'
                                      : ''),
                              style: mainProvider.titleStyle
                                  .copyWith(fontSize: 20, color: Utils.claro)),
                        ),
                        Text(
                            Utils.dateEnglishToSpanish(widget.entry.nextPurchaseDate.toString(),
                                showTime: false),
                            style:
                                mainProvider.titleStyle.copyWith(fontSize: 17, color: Utils.claro)),
                        Text(widget.entry.shop.name,
                            style:
                                mainProvider.titleStyle.copyWith(fontSize: 17, color: Utils.claro)),
                      ],
                    ),
                  ),
                  Text(widget.entry.predictedQuantity.toString(),
                      style: mainProvider.titleStyle.copyWith(fontSize: 35, color: Utils.claro)),
                  const SizedBox(width: 35)
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: 20,
          top: 10,
          child: GestureDetector(
            onTap: () {
              if (mainProvider.shops.isNotEmpty) {
                CartProduct producto = CartProduct(
                    product: widget.entry.product, quantity: widget.entry.predictedQuantity);
                if (mainProvider.avisoBarato) {
                  CheapPrice barato = mainProvider.checkBarato(producto);
                  if (barato.isCheap && context.mounted) {
                    showMessage(
                            context: context,
                            cancel: true,
                            message:
                                'Está más barato en ${barato.productShop.shop.name} a ${barato.productShop.price}€.\r\n¿Cambiar la tienda?')
                        .then((value) {
                      if (value) {
                        mainProvider.selectedShop = barato.productShop.shop;
                      }
                      _addToCart(mainProvider.selectedShop, producto);
                    });
                  } else {
                    _addToCart(widget.entry.shop, producto);
                  }
                } else {
                  _addToCart(widget.entry.shop, producto);
                }
              } else {
                ScaffoldMessenger.of(context)
                    .showSnackBar(Utils.snackBar('No hay tiendas creadas', isGood: false));
              }
            },
            child: const MenuProductRightActionWidget(isAdd: true),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 20,
          child: PopupMenuButton<Product>(
            color: Utils.oscuro,
            iconSize: 30,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(20.0),
              ),
            ),
            icon: Icon(
              Icons.more_vert_rounded,
              color: Utils.claro,
            ),
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                    value: widget.entry.product,
                    child: Center(child: Text('Ocultar', style: TextStyle(color: Utils.claro))))
              ];
            },
            onSelected: (product) async {
              final res = await showMessage(
                  context: context, message: '¿Ocultar producto en las previsiones?', cancel: true);
              if (res) {
                mainProvider.addHiddenForecast(product);
              }
            },
          ),
        ),
      ],
    );
  }

  void _addToCart(Shop shop, CartProduct cartProduct) {
    mainProvider.addCart(shop: shop, cartProduct: cartProduct);
    TopWidget.topAnimationController.forward(from: 0.0);
  }
}
