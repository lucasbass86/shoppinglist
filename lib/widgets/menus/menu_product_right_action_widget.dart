import 'package:flutter/material.dart';
import 'package:shoppinglist/utils/utils.dart';

class MenuProductRightActionWidget extends StatelessWidget {
  final bool isAdd;
  const MenuProductRightActionWidget({super.key, required this.isAdd});

  @override
  Widget build(BuildContext context) {
    final double size = Utils.productImageSize <= Utils.productImageSizeStandar ? 35 : 60;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Utils.oscuro,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          isAdd ? Icons.add : Icons.delete,
          color: Utils.claro,
        ),
      ),
    );
  }
}
