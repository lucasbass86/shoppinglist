import 'package:flutter/material.dart';
import 'package:shoppinglist/dialogs/dialogs.dart';
import 'package:shoppinglist/models/models.dart';
import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/utils/utils.dart';

class Helper {
  static Future<bool> createPrice(
      BuildContext context, MainProvider mainProvider, Shop shop) async {
    if (mainProvider.products.isNotEmpty) {
      final confirmShop = await addShopPriceFromShop(context, shop);
      if (confirmShop[0] && context.mounted) {
        ProductShop productShop = mainProvider.newProductShop(confirmShop[1], shop, 0);
        final price = await showProductPrice(context, productShop);
        if (price[0]) {
          mainProvider.addProductShop(productShop);
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(Utils.snackBar('No hay productos creados . . .', isGood: false));
      return false;
    }
  }
}
