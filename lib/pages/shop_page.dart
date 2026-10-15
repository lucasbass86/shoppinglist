import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:shoppinglist/dialogs/dialogs.dart';
import 'package:shoppinglist/models/models.dart';
import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/sharedpreferences/preferences.dart';
import 'package:shoppinglist/utils/enums.dart';
import 'package:shoppinglist/utils/utils.dart';
import 'package:shoppinglist/widgets/_widgets.dart';

class ShopPage extends StatefulWidget {
  static const String routeName = 'ShopPage';
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  late List<ProductShop> productosAct;
  late List<Product> productos;
  late MainProvider mainProvider;
  late Shop shop;
  late List<ShoppingHistory> historicoCompras;

  @override
  Widget build(BuildContext context) {
    shop = ModalRoute.of(context)!.settings.arguments as Shop;
    mainProvider = Provider.of<MainProvider>(context, listen: false);
    productosAct = mainProvider.productsShops.where((p) => p.shop.id == shop.id).toList();
    productos = mainProvider.pricesHistory
        .where((p) => p.productShop.shop.id == shop.id)
        .map<Product>((p) => p.productShop.product)
        .toList();
    List<Product> sinRepetir = productos.toSet().toList();
    productos = sinRepetir;
    historicoCompras = mainProvider.loadShoppingHistoryByShop(shop);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          _mainTop(),
          _sliverTop(),
          _toShow(),
        ],
      ),
    );
  }

  Widget _mainTop() {
    return SliverToBoxAdapter(
      child: Container(
        color: Utils.medio,
        child: Column(
          children: [
            const TopWidget(showBack: true),
            SizedBox(
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned(
                    bottom: 0,
                    left: 100,
                    child: Container(
                      width: 150,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                  Center(
                    child: FadeInLeft(
                      child: Hero(
                          tag: '${Utils.tagShop}${shop.id}',
                          child: Image.asset(Utils.assetShop, width: 200, height: 200)),
                    ),
                  ),
                  lateralFunctions(context),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sliverTop() {
    return SliverToBoxAdapter(
      child: Container(
        color: Utils.medio,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.only(top: 20, left: 20),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(shop.name, style: mainProvider.titleStyle),
              const SizedBox(height: 20),
              CategoriesWidget(
                onSet: () => setState(() {}),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Positioned lateralFunctions(BuildContext context) {
    return Positioned(
      right: 20,
      top: 0,
      child: SizedBox(
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  changeShopName(context, shop).then((value) {
                    if (value) {
                      mainProvider.renameShop(shop);
                      setState(() {});
                    }
                  });
                },
                child: Icon(Icons.edit, color: Utils.claro, size: 40),
              ),
            ),
            const SizedBox(height: 10),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () async {
                  if (mainProvider.shopHasMovements(shop)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        Utils.snackBar('No se puede borrar. Tiene movimientos', isGood: false));
                  } else {
                    final resp = await confirmDelete(context, '¿Borrar la tienda?');
                    if (resp && context.mounted) {
                      mainProvider.removeShop(shop);
                      ScaffoldMessenger.of(context)
                          .showSnackBar(Utils.snackBar('Tienda borrada...', isGood: false));
                      Navigator.pop(context);
                    }
                  }
                },
                child: Icon(Icons.delete, color: Utils.claro, size: 40),
              ),
            ),
            const SizedBox(height: 10),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () async {
                  if (mainProvider.products.isNotEmpty) {
                    final value = await addShopPriceFromShop(context, shop);
                    if (value[0] && context.mounted) {
                      ProductShop productShop = mainProvider.newProductShop(value[1], shop, 0);
                      final value2 = await showProductPrice(context, productShop);
                      if (value2[0]) {
                        setState(() {
                          mainProvider.addProductShop(productShop);
                        });
                      }
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        Utils.snackBar('No hay productos creados . . .', isGood: false));
                  }
                },
                child: Icon(Icons.euro, color: Utils.claro, size: 40),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toShow() {
    switch (Preferences.productTabIndex) {
      case EProductView.prices:
        return ShopSliverPricesWidget(shop: shop, productosAct: productosAct);
      case EProductView.estatistics:
        return ShopSliverStatisticsWidget(
            productosAct: productosAct, shop: shop, productos: productos);
      case EProductView.history:
        return ShopSliverHistoryWidget(historicoCompras: historicoCompras);
      case EProductView.graphics:
        return ShopSliverGraphicsWidget(shop: shop);
    }
  }
}
