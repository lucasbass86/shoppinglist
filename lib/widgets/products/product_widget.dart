import 'package:flutter/material.dart';
import 'package:shoppinglist/dialogs/dialogs.dart';
import 'package:shoppinglist/models/models.dart';
import 'package:shoppinglist/pages/_pages.dart';
import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/utils/enums.dart';
import 'package:shoppinglist/utils/utils.dart';
import 'package:shoppinglist/widgets/_widgets.dart';

class ProductWidget extends StatefulWidget {
  final Product product;
  const ProductWidget({super.key, required this.product});

  @override
  State<ProductWidget> createState() => _ProductWidgetState();
}

class _ProductWidgetState extends State<ProductWidget> {
  late CartProduct producto;
  late MainProvider mainProvider;
  bool isMoving = false;

  @override
  Widget build(BuildContext context) {
    mainProvider = Provider.of<MainProvider>(context, listen: false);
    final double size = Utils.productImageSize.toDouble();
    final Image image = Image(image: widget.product.imageType.image(), width: size, height: size);
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, ProductPage.routeName, arguments: widget.product),
      onLongPress: () {
        producto = CartProduct(product: widget.product, quantity: 1);
        addToCart();
      },
      child: Draggable<Product>(
        data: widget.product,
        feedback: FeedbackProductWidget(image: image, quantity: 1),
        childWhenDragging: WhenDraggin(type: widget.product.imageType),
        onDragStarted: () {
          setState(() {
            isMoving = true;
            mainProvider.isMoving = isMoving;
          });
        },
        onDragEnd: (details) {
          setState(() {
            isMoving = false;
            mainProvider.isMoving = isMoving;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Utils.claro.withAlpha(isMoving ? 100 : 255),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              SizedBox(
                width: double.infinity,
                child: Column(
                  spacing: 3,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Hero(tag: '${Utils.tagProduct}${widget.product.id}', child: image),
                    MarqueeWidget(
                      child: Text(
                        widget.product.name +
                            (widget.product.details.isNotEmpty
                                ? ' (${widget.product.details})'
                                : ''),
                        style: mainProvider.titleStyle.copyWith(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isMoving)
                Positioned(
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      if (mainProvider.shops.isNotEmpty) {
                        showShops(context, product: widget.product).then((value) {
                          if (value[0]) {
                            producto = CartProduct(product: widget.product, quantity: value[1]);
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
                                  addToCart();
                                });
                              } else {
                                addToCart();
                              }
                            } else {
                              addToCart();
                            }
                          }
                        });
                      } else {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(Utils.snackBar('No hay tiendas creadas', isGood: false));
                      }
                    },
                    child: const MenuProductRightActionWidget(isAdd: true),
                  ),
                ),
            ],
          ),
        ),
      ),
      //  Container(
      //   padding: const EdgeInsets.all(10),
      //   margin: const EdgeInsets.all(10),
      //   decoration: BoxDecoration(
      //     color: Utils.claro.withAlpha(isMoving ? 100 : 255),
      //     borderRadius: BorderRadius.circular(20),
      //     border: Border.all(
      //       color: Utils.oscuro,
      //       width: 1,
      //     ),
      //   ),
      //   child: Stack(
      //     children: [
      //       SizedBox(
      //         width: double.infinity,
      //         child: Column(
      //           crossAxisAlignment: CrossAxisAlignment.center,
      //           children: [
      //             Expanded(
      //               child: Hero(
      //                 tag: '${Utils.tagProduct}${widget.product.id}',
      //                 child: Draggable<Product>(
      //                   data: widget.product,
      //                   feedback: FeedbackProductWidget(image: image, quantity: 1),
      //                   childWhenDragging: WhenDraggin(type: widget.product.imageType),
      //                   child: image,
      //                   onDragStarted: () {
      //                     setState(() {
      //                       isMoving = true;
      //                       mainProvider.isMoving = isMoving;
      //                     });
      //                   },
      //                   onDragEnd: (details) {
      //                     setState(() {
      //                       isMoving = false;
      //                       mainProvider.isMoving = isMoving;
      //                     });
      //                   },
      //                 ),
      //               ),
      //             ),
      //             MarqueeWidget(
      //               child: Text(
      //                 widget.product.name,
      //                 style: mainProvider.titleStyle.copyWith(fontSize: 13),
      //               ),
      //             ),
      //             if (widget.product.details.isNotEmpty)
      //               Text(
      //                 widget.product.details,
      //                 style: mainProvider.titleStyle.copyWith(fontSize: 11),
      //               ),
      //           ],
      //         ),
      //       ),
      //       if (!isMoving)
      //         Positioned(
      //           right: 0,
      //           child: GestureDetector(
      //             onTap: () {
      //               if (mainProvider.shops.isNotEmpty) {
      //                 showShops(context, product: widget.product).then((value) {
      //                   if (value[0]) {
      //                     producto = CartProduct(product: widget.product, quantity: value[1]);
      //                     if (mainProvider.avisoBarato) {
      //                       CheapPrice barato = mainProvider.checkBarato(producto);
      //                       if (barato.isCheap && context.mounted) {
      //                         showMessage(
      //                                 context: context,
      //                                 cancel: true,
      //                                 message:
      //                                     'Está más barato en ${barato.productShop.shop.name} a ${barato.productShop.price}€.\r\n¿Cambiar la tienda?')
      //                             .then((value) {
      //                           if (value) {
      //                             mainProvider.selectedShop = barato.productShop.shop;
      //                           }
      //                           addToCart();
      //                         });
      //                       } else {
      //                         addToCart();
      //                       }
      //                     } else {
      //                       addToCart();
      //                     }
      //                   }
      //                 });
      //               } else {
      //                 ScaffoldMessenger.of(context)
      //                     .showSnackBar(Utils.snackBar('No hay tiendas creadas', isGood: false));
      //               }
      //             },
      //             child: const MenuProductRightActionWidget(isAdd: true),
      //           ),
      //         ),
      //     ],
      //   ),
      // ),
    );
  }

  void addToCart() {
    mainProvider.addCart(shop: mainProvider.selectedShop, cartProduct: producto);
    if (mainProvider.borrarBusqueda && mainProvider.filter.isNotEmpty) {
      mainProvider.searchProduct('');
      mainProvider.searchShop('');
      WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
    }
    TopWidget.topAnimationController.forward(from: 0.0);
  }
}
