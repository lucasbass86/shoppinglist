import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:shoppinglist/helpers/helper.dart';
import 'package:shoppinglist/models/models.dart';
import 'package:shoppinglist/pages/_pages.dart';
import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/sharedpreferences/preferences.dart';
import 'package:shoppinglist/utils/enums.dart';
import 'package:shoppinglist/utils/utils.dart';
import 'package:shoppinglist/widgets/_widgets.dart';

class ShopSliverStatisticsWidget extends StatefulWidget {
  final Shop shop;
  final List<ProductShop> productosAct;
  final List<Product> productos;
  const ShopSliverStatisticsWidget(
      {super.key, required this.productosAct, required this.shop, required this.productos});

  @override
  State<ShopSliverStatisticsWidget> createState() => _ShopSliverStatisticsWidgetState();
}

class _ShopSliverStatisticsWidgetState extends State<ShopSliverStatisticsWidget> {
  late MainProvider mainProvider;
  TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    mainProvider = Provider.of<MainProvider>(context);
    return SliverMainAxisGroup(
        slivers: widget.productosAct.isNotEmpty
            ? [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('Gráfica',
                            style:
                                mainProvider.titleStyle.copyWith(fontSize: 17, color: Utils.claro)),
                        const SizedBox(width: 7),
                        Switch(
                          value: Preferences.isViewGraphic,
                          onChanged: (value) => setState(() => Preferences.isViewGraphic = value),
                        ),
                      ],
                    ),
                  ),
                ),
                _searchBar(),
                Preferences.isViewGraphic ? _statistics() : _statisticsDetailed(),
              ]
            : [sliverNoProducts()]);
  }

  Widget _searchBar() {
    return SliverToBoxAdapter(
      child: Container(
        height: 45,
        margin: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Utils.claro,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Utils.oscuro),
        ),
        child: TextFormField(
          onChanged: (value) => setState(() {}),
          cursorColor: Utils.oscuro,
          controller: searchController,
          style: mainProvider.itemStyle,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search, color: Utils.oscuro),
            suffixIcon: GestureDetector(
              onTap: () {
                searchController.text = '';
                WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
                setState(() {});
              },
              child: Icon(Icons.clear, color: Utils.oscuro, size: 25),
            ),
            border: InputBorder.none,
            disabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            hintText: 'Buscar . . .',
            hintStyle: TextStyle(fontSize: 15.0, color: Utils.medio),
            isCollapsed: true,
          ),
          textCapitalization: TextCapitalization.sentences,
        ),
      ),
    );
  }

  Widget sliverNoProducts() {
    return SliverFillRemaining(
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('No hay precios asociados', style: mainProvider.titleStyle),
            const SizedBox(width: 15),
            InkWell(
              onTap: () => Helper.createPrice(context, mainProvider, widget.shop),
              borderRadius: BorderRadius.circular(20),
              child: Icon(Icons.add, color: Utils.oscuro, size: 40),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statistics() {
    final allProducts = widget.productos;
    List<Product> filteredProducts = allProducts;
    final query = searchController.text.trim();

    if (query.isNotEmpty) {
      final normalizedQuery = Utils.quitarTildes(query.toUpperCase());
      filteredProducts = allProducts.where((h) {
        final name = Utils.quitarTildes(
          h.name.toUpperCase(),
        );
        return name.contains(normalizedQuery);
      }).toList();
    }

    return SliverList.builder(
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        return ShopProductHistory(product: filteredProducts[index], shop: widget.shop);
      },
    );
  }

  Widget _statisticsDetailed() {
    // 1. Partimos SIEMPRE de la lista original
    final allPricesHistory = mainProvider.pricesHistory;
    final allProducts = widget.productos;

    // 2. Aplicamos filtro de búsqueda (si hay texto)
    List<PriceHistory> filteredPrices = allPricesHistory;
    List<Product> filteredProducts = allProducts;
    final query = searchController.text.trim();

    if (query.isNotEmpty) {
      final normalizedQuery = Utils.quitarTildes(query.toUpperCase());

      filteredPrices = allPricesHistory.where((h) {
        final name = Utils.quitarTildes(
          h.productShop.product.name.toUpperCase(),
        );
        return name.contains(normalizedQuery);
      }).toList();

      filteredProducts = allProducts.where((h) {
        final name = Utils.quitarTildes(
          h.name.toUpperCase(),
        );
        return name.contains(normalizedQuery);
      }).toList();
    }

    // 3. Filtramos por tienda
    filteredPrices = filteredPrices.where((p) => p.productShop.shop.id == widget.shop.id).toList();

    // 4. Agrupamos por producto
    final pricesByProduct = <int, List<PriceHistory>>{};
    for (final price in filteredPrices) {
      pricesByProduct.putIfAbsent(price.productShop.product.id, () => []).add(price);
    }

    return SliverList.separated(
      itemCount: filteredProducts.length,
      separatorBuilder: (context, index) => SizedBox(height: 15),
      itemBuilder: (context, index) {
        final prices = pricesByProduct[filteredProducts[index].id] ?? [];
        return FadeInLeft(
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, ProductPage.routeName,
                arguments: filteredProducts[index]),
            child: Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: Utils.oscuro.withAlpha(100),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Utils.claro),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Hero(
                        tag: '${Utils.tagProduct}${filteredProducts[index].id}',
                        child: Image(
                          image: filteredProducts[index].imageType.image(),
                          width: MediaQuery.of(context).size.width * 0.06,
                          height: MediaQuery.of(context).size.width * 0.06,
                          errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Text(filteredProducts[index].name,
                          style: mainProvider.minititleStyle.copyWith(color: Utils.claro)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Column(
                    children: prices.asMap().entries.map((entry) {
                      final price = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                Utils.dateEnglishToSpanish(price.fecha.toString(), showTime: false),
                                style: mainProvider.itemStyleN.copyWith(color: Utils.claro)),
                            Text('${price.productShop.price} €',
                                style: mainProvider.itemStyleN.copyWith(color: Utils.claro)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
