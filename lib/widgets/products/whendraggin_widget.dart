import 'package:flutter/material.dart';
import 'package:shoppinglist/utils/enums.dart';
import 'package:shoppinglist/utils/utils.dart';

class WhenDraggin extends StatelessWidget {
  final EImageType type;
  const WhenDraggin({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final double size = Utils.productImageSize.toDouble();
    return SizedBox(
      child: Image(
        image: type.image(),
        color: Utils.oscuro.withAlpha(80),
        colorBlendMode: BlendMode.modulate,
        width: size,
        height: size,
      ),
    );
  }
}
