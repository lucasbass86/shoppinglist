import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:shoppinglist/dialogs/bottoms.dart';
import 'package:shoppinglist/models/models.dart';
import 'package:shoppinglist/pages/_pages.dart';
import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/utils/enums.dart';
import 'package:shoppinglist/utils/utils.dart';
import 'package:shoppinglist/widgets/_widgets.dart';

class HistoryByProductWidget extends StatelessWidget {
  final List<ShoppingHistory> shoppingHistory;
  const HistoryByProductWidget({super.key, required this.shoppingHistory});

  @override
  Widget build(BuildContext context) {
    MainProvider mainProvider = Provider.of<MainProvider>(context, listen: false);
    List<Shop> shops = shoppingHistory.map((h) => h.shop).toSet().toList();
    final double totalAmount = shoppingHistory.fold(0, (prev, s) => prev + (s.price * s.quantity));
    final int totalQuantity = shoppingHistory.fold(0, (prev, s) => prev + s.quantity);
    int countShowSaving = 0;
    //OBTENER EL PRODUCTO ORIGINAL:
    Product product =
        mainProvider.products.firstWhere((p) => p.id == shoppingHistory[0].product.id);
    return ZoomIn(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        decoration: BoxDecoration(
          color: Utils.oscuro.withAlpha(100),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Utils.claro),
        ),
        child: ExpansionTile(
          iconColor: Utils.claro,
          collapsedIconColor: Utils.claro,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          childrenPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          title: GestureDetector(
            onLongPress: () =>
                Navigator.pushNamed(context, ProductPage.routeName, arguments: product),
            child: Row(
              spacing: 10,
              children: [
                Image(image: shoppingHistory[0].product.imageType.image(), width: 30, height: 30),
                Text(product.name, style: mainProvider.titleStyle.copyWith(color: Utils.claro)),
              ],
            ),
          ),
          children: [
            ListView.builder(
              physics: ClampingScrollPhysics(),
              shrinkWrap: true,
              itemCount: shops.length,
              itemBuilder: (context, index) {
                final List<ShoppingHistory> shoppingList =
                    shoppingHistory.where((sh) => sh.shop.id == shops[index].id).toList();
                return HistoryForProductGroupedByShop(shoppingHistory: shoppingList);
              },
            ),
            //TOTAL DEL MES SELECCIONADO
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: GestureDetector(
                onTap: () async {
                  countShowSaving++;
                  if (countShowSaving == 3) {
                    await showSavingAmount(context, mainProvider, shoppingHistory[0].shop,
                        shoppingHistory.where((s) => s.price == 0).toList());
                    countShowSaving = 0;
                  }
                },
                child: HistoryLevelTotalWidget(
                  uds: totalQuantity,
                  amount: totalAmount,
                  title: 'Total producto',
                  isLastTotal: false,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
