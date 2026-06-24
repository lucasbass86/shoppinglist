import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/utils/utils.dart';

class MenuHomeWidget extends StatelessWidget {
  final String name;
  final String asset;
  final String route;

  const MenuHomeWidget({super.key, required this.name, required this.asset, required this.route});

  @override
  Widget build(BuildContext context) {
    MainProvider mainProvider = Provider.of<MainProvider>(context);
    final double indicatorSize = Utils.iconSizeSelected == Utils.iconSizeStandar ? 25 : 60;
    final double indicatorPosition = Utils.iconSizeSelected == Utils.iconSizeStandar ? 10 : 20;
    final double indicatorFontSize = Utils.iconSizeSelected == Utils.iconSizeStandar ? 13 : 27;
    final double fontSize = Utils.iconSizeSelected == Utils.iconSizeStandar ? 17 : 27;

    return GestureDetector(
      onTap: () {
        if (route != '') {
          Navigator.pushNamed(context, route).then((_) {
            mainProvider.searchText = '';
            mainProvider.searchProduct('');
            mainProvider.searchShop('');
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(Utils.snackBar('No implementado'));
        }
      },
      child: ZoomIn(
        duration: Utils.fadeInDuration,
        child: Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Utils.claro,
          ),
          child: Stack(
            children: [
              SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      asset,
                      width: Utils.homeIconImageSize.toDouble(),
                      height: Utils.homeIconImageSize.toDouble(),
                    ),
                    const SizedBox(height: 5),
                    Text(name,
                        style: mainProvider.titleStyle.copyWith(fontSize: fontSize),
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              if (mainProvider.cartItems > 0 && name == 'Cesta')
                Positioned(
                  right: indicatorPosition,
                  top: indicatorPosition,
                  child: Container(
                    width: indicatorSize,
                    height: indicatorSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Utils.medio,
                    ),
                    child: Center(
                      child: Text(
                        '${mainProvider.cartItems}',
                        style: mainProvider.itemStyle.copyWith(fontSize: indicatorFontSize),
                      ),
                    ),
                  ),
                ),
              if (!mainProvider.updateView && name == 'Configuración')
                Positioned(
                  right: indicatorPosition,
                  top: indicatorPosition,
                  child: Container(
                    width: indicatorSize,
                    height: indicatorSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Utils.medio,
                    ),
                    child: Center(
                      child: Text(
                        '!',
                        style: mainProvider.itemStyle.copyWith(fontSize: indicatorFontSize),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
