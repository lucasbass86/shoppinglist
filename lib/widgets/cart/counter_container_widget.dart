import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:shoppinglist/models/models.dart';
import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/utils/utils.dart';

class CounterContainerWidget extends StatefulWidget {
  final CartProduct cartProduct;
  final Cart cart;
  const CounterContainerWidget({
    super.key,
    required this.cartProduct,
    required this.cart,
  });

  @override
  State<CounterContainerWidget> createState() => _CounterContainerWidgetState();
}

class _CounterContainerWidgetState extends State<CounterContainerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this);
    controller.stop();
  }

  @override
  void dispose() {
    if (controller.isAnimating) {
      controller.stop();
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double size = 35;
    MainProvider provider = Provider.of<MainProvider>(context);
    return GestureDetector(
      onTap: () {
        provider.addCart(shop: widget.cart.shop, cartProduct: widget.cartProduct, updateCart: true);
        controller.repeat();
      },
      child: BounceInDown(
        controller: (c) => controller = c,
        child: Container(
          padding: const EdgeInsets.all(10),
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Utils.colorNumItems,
            shape: BoxShape.circle,
          ),
          child: FittedBox(
            fit: BoxFit.cover,
            child: Text(
              '${widget.cartProduct.quantity}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
