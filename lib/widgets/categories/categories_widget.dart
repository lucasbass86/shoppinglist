import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/sharedpreferences/preferences.dart';
import 'package:shoppinglist/utils/enums.dart';
import 'package:shoppinglist/utils/utils.dart';

class CategoriesWidget extends StatefulWidget {
  final Function onSet;
  const CategoriesWidget({super.key, required this.onSet});

  @override
  State<CategoriesWidget> createState() => _CategoriesWidgetState();
}

class _CategoriesWidgetState extends State<CategoriesWidget> {
  late MainProvider mainProvider;
  @override
  Widget build(BuildContext context) {
    mainProvider = Provider.of<MainProvider>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        width: double.infinity,
        height: 60,
        margin: const EdgeInsets.only(right: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                BounceInLeft(
                  duration: Utils.fadeInDuration,
                  child: GestureDetector(
                    child: category('Precios', EProductView.prices,
                        Preferences.productTabIndex == EProductView.prices,
                        icon: Icons.euro),
                  ),
                ),
                const SizedBox(width: 15),
                BounceInRight(
                  duration: Utils.fadeInDuration,
                  child: category('Estadística', EProductView.estatistics,
                      Preferences.productTabIndex == EProductView.estatistics,
                      icon: Icons.bar_chart_rounded),
                ),
                const SizedBox(width: 15),
                BounceInDown(
                  duration: Utils.fadeInDuration,
                  child: category('Historial', EProductView.history,
                      Preferences.productTabIndex == EProductView.history,
                      icon: Icons.watch_later_outlined),
                ),
                const SizedBox(width: 15),
                BounceInUp(
                  duration: Utils.fadeInDuration,
                  child: category('Gráficas', EProductView.graphics,
                      Preferences.productTabIndex == EProductView.graphics,
                      icon: Icons.pie_chart_rounded),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget category(String name, EProductView productView, bool isSelected, {IconData? icon}) {
    return GestureDetector(
      onTap: () {
        Preferences.productTabIndex = productView;
        widget.onSet.call();
      },
      child: Container(
        height: 50,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Utils.oscuro.withAlpha(100),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Utils.claro : Colors.transparent, width: 2),
        ),
        child: Center(
          child: Row(
            spacing: 10,
            children: [
              if (icon != null)
                Icon(
                  icon,
                  color: isSelected ? Utils.claro : Utils.oscuro,
                ),
              Text(
                name,
                style: isSelected
                    ? mainProvider.itemStyleN.copyWith(color: Utils.claro)
                    : mainProvider.itemStyleN,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
