import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/utils/enums.dart';
import 'package:shoppinglist/utils/utils.dart';

class ProductFilterWidget extends StatelessWidget {
  const ProductFilterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    MainProvider mainProvider = Provider.of<MainProvider>(context);
    ScrollController controller = ScrollController();
    List<EImageType> typesFromProducts =
        mainProvider.filter.map((p) => p.imageType).toSet().toList();
    List<EImageType> types = EImageType.values.toList();
    types.removeWhere((t) => !typesFromProducts.contains(t));
    switch (mainProvider.orderType) {
      case EOrderType.az:
      case EOrderType.taz:
        types.sort((a, b) => a.displayName().compareTo(b.displayName()));
        break;
      case EOrderType.za:
      case EOrderType.tza:
        types.sort((a, b) => b.displayName().compareTo(a.displayName()));
        break;
      case EOrderType.used:
        Map<EImageType, int> grouped = {};
        for (var sh in mainProvider.shoppingHistory) {
          final id = sh.product.imageType;
          grouped[id] = (grouped[id] ?? 0) + sh.quantity;
        }
        grouped =
            Map.fromEntries(grouped.entries.toList()..sort((a, b) => b.value.compareTo(a.value)));
        types.sort((a, b) {
          final ca = grouped[a] ?? 0;
          final cb = grouped[b] ?? 0;
          return cb.compareTo(ca);
        });
        break;
    }
    types.remove(EImageType.todo);
    types.insert(0, EImageType.todo);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      height: 40,
      width: double.infinity,
      child: ListView.builder(
        controller: controller,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: types.length,
        itemBuilder: (context, index) =>
            FadeInLeft(child: _FilterItem(type: types[index], controller: controller)),
      ),
    );
  }
}

class _FilterItem extends StatelessWidget {
  final EImageType type;
  final ScrollController controller;
  const _FilterItem({required this.type, required this.controller});

  @override
  Widget build(BuildContext context) {
    MainProvider mainProvider = Provider.of<MainProvider>(context);
    return GestureDetector(
      onTap: () {
        if (mainProvider.selectedFilter != type) {
          mainProvider.selectedFilter = type;
        } else {
          mainProvider.selectedFilter = EImageType.todo;
          controller.jumpTo(0);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
        decoration: BoxDecoration(
          color: type == mainProvider.selectedFilter ? Utils.oscuro : Utils.claro,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Utils.oscuro),
        ),
        child: Row(
          spacing: 5,
          children: [
            Image(image: type.image()),
            Text(
              type.displayName(),
              style: TextStyle(
                  color: type == mainProvider.selectedFilter ? Utils.claro : Utils.oscuro),
            ),
          ],
        ),
      ),
    );
  }
}
