import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/utils/enums.dart';
import 'package:shoppinglist/utils/utils.dart';

class ProductTypeWidget extends StatelessWidget {
  final EImageType type;
  const ProductTypeWidget({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    MainProvider mainProvider = Provider.of<MainProvider>(context);

    return GestureDetector(
      onTap: () => mainProvider.selectedProductType = type,
      child: ZoomIn(
        duration: Utils.fadeInDuration,
        child: Container(
          width: 120,
          height: 120,
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: mainProvider.selectedProductType == type
                ? Utils.claro.withAlpha(200)
                : Utils.oscuro.withAlpha(100),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Utils.claro),
          ),
          child: Center(
            child: Image(image: type.image()),
          ),
        ),
      ),
    );
  }
}
