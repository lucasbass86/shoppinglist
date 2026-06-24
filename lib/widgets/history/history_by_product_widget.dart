import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
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
    final double totalQuantity = shoppingHistory.fold(0, (prev, s) => prev + s.quantity);

    //OBTENER EL PRODUCTO ORIGINAL:
    Product product =
        mainProvider.products.firstWhere((p) => p.id == shoppingHistory[0].product.id);
    return ZoomIn(
      child: Card(
        color: Utils.claro,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        borderOnForeground: false,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: ExpansionTile(
            iconColor: Utils.medio,
            collapsedIconColor: Utils.medio,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            childrenPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            title: Row(
              spacing: 10,
              children: [
                Image(image: shoppingHistory[0].product.imageType.image(), width: 30, height: 30),
                Text(product.name, style: mainProvider.titleStyle),
              ],
            ),
            children: [
              ListView.builder(
                physics: ClampingScrollPhysics(),
                shrinkWrap: true,
                itemCount: shops.length,
                itemBuilder: (context, index) {
                  final List<ShoppingHistory> shoppingList =
                      shoppingHistory.where((sh) => sh.shop.id == shops[index].id).toList();
                  return HistoryGroupedDetailWidget(
                      shoppingHistory: shoppingList, type: ETypeShoppings.byShop);
                },
              ),
              //TOTAL
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Utils.medio.withAlpha((255 * 0.2).toInt()),
                      Utils.medio.withAlpha((255 * 0.1).toInt())
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Utils.medio.withAlpha((255 * 0.5).toInt()), width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      spacing: 10,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, ProductPage.routeName,
                              arguments: shoppingHistory[0].product),
                          child: Icon(Icons.info, color: Utils.oscuro),
                        ),
                        Text(
                          'Total ${shoppingHistory[0].product.name}',
                          style: mainProvider.mainTitleStyle.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Utils.oscuro,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${totalAmount.toStringAsFixed(2)}€',
                          style: mainProvider.itemStyle,
                        ),
                        Text(
                          '${totalQuantity.toStringAsFixed(0)} uds',
                          style: mainProvider.itemStyle,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
