import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:shoppinglist/models/models.dart';
import 'package:shoppinglist/pages/_pages.dart';
import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/utils/enums.dart';
import 'package:shoppinglist/utils/utils.dart';

class HistoryProductWidget extends StatelessWidget {
  final ShoppingHistory shoppingHistory;
  final bool isProduct;
  const HistoryProductWidget({super.key, required this.shoppingHistory, this.isProduct = true});

  @override
  Widget build(BuildContext context) {
    MainProvider mainProvider = Provider.of<MainProvider>(context, listen: false);
    return GestureDetector(
      onTap: () {
        if (!isProduct) {
          Product product =
              mainProvider.products.firstWhere((p) => p.id == shoppingHistory.product.id);
          Navigator.pushNamed(context, ProductPage.routeName, arguments: product);
        } else {
          Navigator.pushNamed(context, ShopPage.routeName, arguments: shoppingHistory.shop);
        }
      },
      onLongPress: () => _changeCuantity(context, mainProvider),
      child: Container(
        // height: 70,
        margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Utils.claro,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            if (!isProduct)
              Row(
                children: [
                  Image(image: shoppingHistory.product.imageType.image(), width: 30, height: 30),
                  const SizedBox(width: 7),
                ],
              ),
            if (isProduct)
              Row(
                children: [
                  Image.asset(Utils.assetShop, width: 30, height: 30),
                  const SizedBox(width: 7),
                ],
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isProduct ? shoppingHistory.shop.name : shoppingHistory.product.name,
                    style: mainProvider.titleStyle.copyWith(fontSize: 20),
                  ),
                  Text(
                    Utils.dateEnglishToSpanish(shoppingHistory.date.toString()),
                    style: mainProvider.titleStyle.copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${shoppingHistory.quantity} ${shoppingHistory.quantity == 1 ? 'ud' : 'uds'}',
                  style: mainProvider.titleStyle.copyWith(fontSize: 17),
                ),
                Text(
                  '${shoppingHistory.price.toStringAsFixed(2)}€',
                  style: mainProvider.titleStyle.copyWith(fontSize: 17),
                ),
                if (shoppingHistory.quantity > 1 && shoppingHistory.price != 0)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        height: 1.5,
                        width: 70,
                        color: Utils.oscuro,
                      ),
                      Text(
                        '${(shoppingHistory.price * shoppingHistory.quantity).toStringAsFixed(2)}€',
                        style: mainProvider.titleStyle.copyWith(fontSize: 15),
                      ),
                    ],
                  )
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _changeCuantity(BuildContext context, MainProvider mainProvider) {
    int cantidad = shoppingHistory.quantity;
    showModalBottomSheet(
      sheetAnimationStyle:
          AnimationStyle(curve: Curves.easeInOutExpo, duration: const Duration(milliseconds: 800)),
      elevation: 30,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              width: double.infinity,
              height: 200,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Utils.claro,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Indica la cantidad', style: mainProvider.titleStyle),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Utils.oscuro,
                          borderRadius: const BorderRadius.all(Radius.circular(15)),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            if (cantidad > 1) {
                              setState(() {
                                cantidad--;
                                ProductsPage.controllerDialog.reset();
                              });
                            }
                          },
                          child: Icon(Icons.remove, color: Utils.claro),
                        ),
                      ),
                      const SizedBox(width: 25),
                      BounceInDown(
                        from: 30,
                        controller: (controller) {
                          ProductsPage.controllerDialog = controller;
                        },
                        child: Text(
                          cantidad.toString(),
                          style: TextStyle(
                              fontSize: 50, color: Utils.oscuro, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 25),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Utils.oscuro,
                          borderRadius: const BorderRadius.all(Radius.circular(15)),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              cantidad++;
                              ProductsPage.controllerDialog.reset();
                            });
                          },
                          child: Icon(Icons.add, color: Utils.claro),
                        ),
                      ),
                    ],
                  ),
                  Expanded(child: SizedBox(height: 1)),
                  ElevatedButton(
                    onPressed: () {
                      if (cantidad != shoppingHistory.quantity) {
                        shoppingHistory.quantity = cantidad;
                        mainProvider.updateShoppingHistory(shoppingHistory);
                        ScaffoldMessenger.of(context)
                            .showSnackBar(Utils.snackBar('Cantidad modificada'));
                        Navigator.pop(context);
                      }
                    },
                    child: Text('Aceptar'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
