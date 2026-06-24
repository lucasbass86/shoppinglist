import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shoppinglist/dialogs/dialogs.dart';
import 'package:shoppinglist/models/models.dart';
import 'package:shoppinglist/pages/_pages.dart';
import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/sharedpreferences/preferences.dart';
import 'package:shoppinglist/utils/enums.dart';
import 'package:shoppinglist/utils/utils.dart';
import 'package:shoppinglist/widgets/_widgets.dart';

class ProductsPage extends StatefulWidget {
  static const String routeName = 'ProductosPage';
  static late AnimationController controllerDialog;
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> with SingleTickerProviderStateMixin {
  PageController pageController = PageController();
  late ScrollController scrollController;
  late MainProvider mainProvider;
  final bool isBig = Utils.iconSizeSelected == Utils.iconSizeBig;
  String productNameToCart = '';

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    ProductsPage.controllerDialog = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    scrollController.dispose();
    pageController.dispose();
    Preferences.tutorialCrearProducto = mainProvider.products.isNotEmpty;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    mainProvider = Provider.of<MainProvider>(context);
    switch (mainProvider.orderType) {
      case EOrderType.az:
        mainProvider.filter.sort((a, b) => a.name.toUpperCase().compareTo(b.name.toUpperCase()));
        break;
      case EOrderType.za:
        mainProvider.filter.sort((a, b) => b.name.toUpperCase().compareTo(a.name.toUpperCase()));
        break;
      case EOrderType.taz:
        mainProvider.filter.sort(
            (a, b) => a.imageType.name.toUpperCase().compareTo(b.imageType.name.toUpperCase()));
        break;
      case EOrderType.tza:
        mainProvider.filter.sort(
            (a, b) => b.imageType.name.toUpperCase().compareTo(a.imageType.name.toUpperCase()));
        break;
      case EOrderType.used:
        Map<int, int> grouped = {};
        for (var sh in mainProvider.shoppingHistory) {
          final id = sh.product.id;
          grouped[id] = (grouped[id] ?? 0) + sh.quantity;
        }
        grouped =
            Map.fromEntries(grouped.entries.toList()..sort((a, b) => b.value.compareTo(a.value)));

        mainProvider.filter.sort((a, b) {
          final ca = grouped[a.id] ?? 0;
          final cb = grouped[b.id] ?? 0;
          return cb.compareTo(ca);
        });
        break;
    }

    return Scaffold(
      floatingActionButton: !mainProvider.isMoving
          ? ScrollVisibilityWidget(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    heroTag: Key('toUp'),
                    mini: true,
                    onPressed: () => scrollController.jumpTo(0),
                    child: const Icon(Icons.keyboard_arrow_up_sharp),
                  ),
                  FloatingActionButton(
                    heroTag: Key('newProduct'),
                    onPressed: () => Navigator.pushNamed(context, NewProductPage.routeName),
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
            )
          : null,
      body: Stack(
        children: [
          const BackgroundWidget(),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            controller: scrollController,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              _appBar(),
              sliverProductos(),
            ],
          ),
          if (mainProvider.isMoving) _bottomCart(),
        ],
      ),
    );
  }

  Widget _appBar() {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: false,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const TopWidget(title: 'Productos', showBack: true, showForecast: true),
              Row(
                children: [
                  const Expanded(child: SearchWidget(searchType: ESearchType.productos)),
                  popupMenuButton(),
                  SizedBox(width: 20),
                ],
              ),
              ProductFilterWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomCart() {
    return Positioned(
      bottom: 0,
      right: 0,
      left: 0,
      child: SizedBox(
        height: 150,
        child: DragTarget<Product>(
          builder:
              (BuildContext context, List<Product?> candidateData, List<dynamic> rejectedData) {
            return Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                height: 150,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(20), right: Radius.circular(20)),
                    color: Utils.medio.withAlpha(190)),
                child: Column(
                  spacing: 10,
                  children: [
                    Text('Agregar al carrito', style: TextStyle(fontSize: 20)),
                    Icon(Icons.add_shopping_cart_rounded,
                        size: 90, color: Utils.oscuro.withAlpha(150)),
                  ],
                ),
              ),
            );
          },
          onAcceptWithDetails: (product) {
            if (mainProvider.shops.isNotEmpty) {
              if (mainProvider.nameSelectedShop.isEmpty) {
                if (mainProvider.cart.isNotEmpty) {
                  mainProvider.nameSelectedShop = mainProvider.cart[0].shop.name;
                } else {
                  mainProvider.nameSelectedShop = mainProvider.shops[0].name;
                }
              }
              if (mainProvider.cart.isEmpty) {
                showShops(context, product: product.data).then((value) {
                  if (value[0]) {
                    _addToCart(product.data, value[1]);
                  }
                });
              } else {
                _addToCart(product.data, 1);
              }
            } else {
              ScaffoldMessenger.of(context)
                  .showSnackBar(Utils.snackBar('No hay tiendas creadas', isGood: false));
            }
          },
          onLeave: (data) {
            setState(() {
              productNameToCart = '';
            });
          },
          onWillAcceptWithDetails: (data) {
            setState(() {
              productNameToCart = (data.data).name;
            });
            return true;
          },
        ),
      ),
    );
  }

  void _addToCart(Product product, int value) {
    mainProvider.addCart(
        shop: mainProvider.selectedShop,
        cartProduct: CartProduct(product: product, quantity: value));
    if (mainProvider.borrarBusqueda && mainProvider.filter.isNotEmpty) {
      mainProvider.searchProduct('');
      mainProvider.searchShop('');
      mainProvider.searchText = '';
      WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
    }
    TopWidget.topAnimationController.forward(from: 0.0);
  }

  Widget popupMenuButton() {
    return PopupMenuButton<EOrderType>(
      color: Utils.oscuro,
      iconSize: Utils.iconSizeSelected,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(20.0),
        ),
      ),
      icon: Icon(Icons.filter_list_rounded, color: Utils.oscuro),
      onSelected: (order) => mainProvider.orderType = order,
      itemBuilder: (BuildContext context) {
        return EOrderType.values.map((order) {
          final bool isSelected = order == mainProvider.orderType;
          final Color itemColor = isSelected ? Utils.claro : Utils.medio;
          return PopupMenuItem(
            value: order,
            child: Text(order.displayName(), style: TextStyle(color: itemColor)),
          );
        }).toList();
      },
    );
  }

  Widget sliverProductos() {
    SliverGridDelegate delegate = Utils.homeIconImageSize == Utils.productImageSizeStandar
        ? const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            childAspectRatio: 0.8,
          )
        : const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3);

    if (mainProvider.filter.isNotEmpty) {
      List<Product> products = mainProvider.filter;
      if (mainProvider.selectedFilter != EImageType.todo) {
        products = products.where((p) => p.imageType == mainProvider.selectedFilter).toList();
      }
      if (products.isNotEmpty) {
        return SliverGrid.builder(
          gridDelegate: delegate,
          itemCount: products.length,
          itemBuilder: (_, index) {
            return FadeIn(
              duration: Utils.fadeInDuration,
              child: ProductWidget(product: products[index]),
            );
          },
        );
      } else {
        return noProductos();
      }
    } else {
      return noProductos();
    }
  }

  Widget noProductos() {
    return SliverFillRemaining(
      child: ZoomIn(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (mainProvider.searchText.isEmpty) const Expanded(child: SizedBox(height: 1)),
            SvgPicture.asset('assets/svg/no_data.svg', width: 200, height: 200),
            const SizedBox(height: 30),
            Text('No hay productos', style: mainProvider.mainTitleStyle),
            if (mainProvider.searchText.isEmpty) const Expanded(child: SizedBox(height: 1)),
          ],
        ),
      ),
    );
  }
}
