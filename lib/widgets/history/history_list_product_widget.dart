import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:shoppinglist/dialogs/dialogs.dart';
import 'package:shoppinglist/models/models.dart';
import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/widgets/_widgets.dart';

class HistoryListProductWidget extends StatelessWidget {
  final List<ShoppingHistory> historicoCompras;
  final bool canDelete;
  final bool isProduct;
  const HistoryListProductWidget(
      {super.key, required this.historicoCompras, this.canDelete = true, this.isProduct = true});

  @override
  Widget build(BuildContext context) {
    MainProvider mainProvider = Provider.of<MainProvider>(context);
    return SliverList.builder(
      itemCount: historicoCompras.length,
      itemBuilder: (context, index) {
        final item = historicoCompras[index];
        return FadeInLeft(
          delay: Duration(milliseconds: index * 20),
          child: Dismissible(
            key: Key('${item.id.toString()}product'),
            direction: canDelete ? DismissDirection.horizontal : DismissDirection.none,
            background: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.delete, size: 40, color: Colors.red[300]),
                Icon(Icons.edit, size: 40, color: Colors.green[300]),
              ],
            ),
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.startToEnd) {
                showMessage(context: context, message: '¿Borrar la compra?', cancel: true)
                    .then((value) {
                  if (value) {
                    mainProvider.removeShoppingHistory(item);
                  }
                });
              } else {
                final value = await showPrice(context, 'Comprado en ${item.shop.name}', item.price);
                if (value[0]) {
                  item.price = value[1];
                  mainProvider.updateShoppingHistory(item);
                }
              }
              return false;
            },
            child: HistoryProductWidget(shoppingHistory: item, isProduct: isProduct),
          ),
        );
      },
    );
  }
}
