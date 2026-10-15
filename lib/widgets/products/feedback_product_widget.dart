import 'package:flutter/material.dart';
import 'package:shoppinglist/utils/utils.dart';

class FeedbackProductWidget extends StatelessWidget {
  final Image image;
  final int quantity;
  final double imageSize;
  const FeedbackProductWidget(
      {super.key, required this.image, required this.quantity, this.imageSize = 130});

  @override
  Widget build(BuildContext context) {
    final double size = 35;
    return SizedBox(
      width: imageSize,
      height: imageSize,
      child: Stack(
        children: [
          Positioned.fill(child: image),
          Positioned(
            left: 3,
            top: 3,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1), // 0 a 1 vuelta completa
              duration: const Duration(seconds: 2),
              builder: (context, value, child) {
                return Transform.rotate(
                  angle: value * 2 * 3.1416, // 1 vuelta completa (360°)
                  child: child,
                );
              },
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
                    '$quantity',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
