import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:shoppinglist/models/models.dart';
import 'package:shoppinglist/pages/_pages.dart';
import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/utils/enums.dart';
import 'package:shoppinglist/utils/utils.dart';
import 'package:shoppinglist/widgets/_widgets.dart';
import 'dart:math' as math;

class CartMiniWidget extends StatefulWidget {
  final Cart cart;
  final CartProduct cartProduct;
  final Function onMove;
  final Function onDelete;
  final Function onCheck;
  const CartMiniWidget({
    super.key,
    required this.cart,
    required this.cartProduct,
    required this.onMove,
    required this.onDelete,
    required this.onCheck,
  });

  @override
  State<CartMiniWidget> createState() => _CartMiniWidgetState();
}

class _CartMiniWidgetState extends State<CartMiniWidget> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _checkController;
  late MainProvider mainProvider;
  bool isMoving = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _checkController = AnimationController(vsync: this);
  }

  double turns = 0.0;

  void _changeRotation() {
    setState(() => turns += 2.545 * math.pi / 8);
  }

  @override
  Widget build(BuildContext context) {
    mainProvider = Provider.of<MainProvider>(context, listen: false);
    final Image image = Image(
        image: widget.cartProduct.product.imageType.image(),
        width: Utils.productImageSize.toDouble(),
        height: Utils.productImageSize.toDouble());
    return ZoomOut(
      duration: Utils.fadeInDuration,
      manualTrigger: true,
      animate: false,
      controller: (c) => _controller = c,
      child: GestureDetector(
        onLongPress: () => Navigator.pushNamed(context, ProductPage.routeName,
            arguments: widget.cartProduct.product),
        onTap: () {
          late ShoppingHistory shoppingHistory;
          _checkController.forward().then((onValue) => _checkController.reset()).then((_) async {
            shoppingHistory = await mainProvider.addShoppingHistory(widget.cartProduct.product,
                widget.cart.shop, widget.cartProduct.quantity, widget.cart.id);
            widget.onCheck.call(shoppingHistory);
            mainProvider.removeFromCartAllProduct(widget.cart, widget.cartProduct);
          });
        },
        child: Container(
          width: 160,
          height: 160,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Utils.claro.withAlpha(isMoving ? 100 : 255),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 3,
                  children: [
                    Expanded(
                      child: Hero(
                        tag: '${Utils.tagProduct}${widget.cartProduct.product.id}',
                        child: Draggable<CartCartProduct>(
                          data: CartCartProduct(cart: widget.cart, cartProduct: widget.cartProduct),
                          feedback: FeedbackProductWidget(
                              image: image, quantity: widget.cartProduct.quantity),
                          childWhenDragging:
                              WhenDraggin(type: widget.cartProduct.product.imageType),
                          child: image,
                          onDragStarted: () {
                            setState(() {
                              isMoving = true;
                              widget.onMove.call(true);
                            });
                          },
                          onDragEnd: (details) {
                            setState(() {
                              isMoving = false;
                              widget.onMove.call(false);
                            });
                          },
                        ),
                      ),
                    ),
                    MarqueeWidget(
                      child: Text(
                        widget.cartProduct.product.name +
                            (widget.cartProduct.product.details.isNotEmpty
                                ? ' (${widget.cartProduct.product.details})'
                                : ''),
                        style: mainProvider.titleStyle.copyWith(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isMoving)
                Positioned(
                  top: 0,
                  left: 0,
                  child: CounterContainerWidget(
                    cart: widget.cart,
                    cartProduct: widget.cartProduct,
                  ),
                ),
              if (!isMoving)
                Positioned(
                  right: 0,
                  child: GestureDetector(
                    onTap: _removeProduct,
                    onLongPress: _removeAll,
                    child: AnimatedRotation(
                      turns: turns,
                      duration: const Duration(milliseconds: 300),
                      child: const MenuProductRightActionWidget(isAdd: false),
                    ),
                  ),
                ),
              Center(
                child: ZoomIn(
                  duration: const Duration(milliseconds: 400),
                  animate: false,
                  controller: (p0) => _checkController = p0,
                  child: Container(
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Utils.medio),
                    child: Icon(Icons.check, size: 40, color: Colors.greenAccent),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _removeProduct() {
    widget.onDelete.call(1);
    if (widget.cartProduct.quantity - 1 == 0) {
      _controller
          .forward(from: 1)
          .then((value) => mainProvider.removeFromCart(widget.cart, widget.cartProduct));
      setState(() {});
    } else {
      mainProvider.removeFromCart(widget.cart, widget.cartProduct);
      _changeRotation();
    }
  }

  void _removeAll() {
    widget.onDelete.call(widget.cartProduct.quantity);
    mainProvider.removeFromCartAllProduct(widget.cart, widget.cartProduct);
  }
}
