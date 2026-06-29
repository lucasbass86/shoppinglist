import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shoppinglist/dialogs/dialogs.dart';
import 'package:shoppinglist/models/models.dart';
import 'package:shoppinglist/pages/_pages.dart';
import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/sharedpreferences/preferences.dart';
import 'package:shoppinglist/utils/enums.dart';
import 'package:shoppinglist/utils/utils.dart';
import 'package:shoppinglist/widgets/_widgets.dart';

class CartPage extends StatefulWidget {
  static const String routeName = 'CartPage';
  const CartPage({super.key});

  static String shopNameSelected = '';

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> with SingleTickerProviderStateMixin {
  late MainProvider mainProvider;
  ScrollController scrollController = ScrollController();
  PageController pageController = PageController(initialPage: 0);
  ItemScrollController itemScrollController = ItemScrollController();
  late AnimationController fabController;
  int scrollTo = 0;
  late double width;
  late double height;
  bool isExpanded = false;
  bool showNewShop = false;
  late CartProduct deletedCartProduct;
  late ShoppingHistory shoppingHistory;

  @override
  void dispose() {
    scrollController.dispose();
    pageController.dispose();
    Preferences.tutorialVisitarCarrito = true;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mainProvider.cart.isNotEmpty) {
        setState(() {
          CartPage.shopNameSelected = mainProvider.cart[0].shop.name;
        });
      }
    });
    fabController = AnimationController(vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width * 0.85;
    height = MediaQuery.of(context).size.height * 0.75;
    mainProvider = Provider.of<MainProvider>(context);
    return Scaffold(
      floatingActionButton: floatingButton(context),
      body: Stack(
        children: [
          const BackgroundWidget(),
          Column(
            children: [
              const TopWidget(
                  showBack: true,
                  showCart: false,
                  title: 'Carrito',
                  showExit: true,
                  showForecast: true),
              if (mainProvider.cart.isNotEmpty) shopsNames(),
              if (mainProvider.cart.isNotEmpty) paginadero(),
              if (mainProvider.cart.isEmpty) noProducts(context),
            ],
          ),
          _toNewShow(),
        ],
      ),
    );
  }

  Widget _toNewShow() {
    return Positioned(
      left: 20,
      bottom: 25,
      child: Visibility(
        visible: showNewShop,
        child: DragTarget<CartCartProduct>(
          builder: (context, candidateData, rejectedData) {
            return ZoomIn(
              duration: const Duration(milliseconds: 1200),
              child: Container(
                margin: const EdgeInsets.only(left: 10),
                width: 200,
                height: 60,
                decoration: BoxDecoration(
                  color: candidateData.isEmpty ? Utils.claro : Utils.oscuro,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Icon(Icons.add_shopping_cart_rounded,
                    color: candidateData.isNotEmpty ? Utils.claro : Utils.oscuro,
                    size: Utils.iconSizeStandar),
              ),
            );
          },
          onAcceptWithDetails: (cartMove) async {
            await showChangeCartShop(context, cartMove.data.cart.shop).then((onValue) {
              if (onValue[0]) {
                Shop shop = onValue[1];
                Cart? cart;
                for (Cart c in mainProvider.cart) {
                  if (c.shop.id == shop.id) {
                    cart = c;
                    break;
                  }
                }
                if (cart == null) {
                  CartProduct cartProduct = CartProduct(
                      product: cartMove.data.cartProduct.product,
                      quantity: cartMove.data.cartProduct.quantity);
                  mainProvider.addCart(shop: shop, cartProduct: cartProduct);
                  mainProvider.removeFromCartAllProduct(
                      cartMove.data.cart, cartMove.data.cartProduct);
                } else {
                  mainProvider.moveCart(cartMove.data.cart, cart, cartMove.data.cartProduct);
                }
                if (cartMove.data.cart.products.isEmpty) {
                  pageController.jumpToPage(0);
                }
                setState(() {});
              }
            });
          },
        ),
      ),
    );
  }

  Widget paginadero() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        child: PageView.builder(
          physics: const BouncingScrollPhysics(),
          controller: pageController,
          itemCount: mainProvider.cart.length,
          onPageChanged: (page) {
            scrollTo = page;
            itemScrollController.jumpTo(index: scrollTo);
            fabController.reset();
            setState(() {
              CartPage.shopNameSelected = mainProvider.cart[page].shop.name;
              isExpanded = false;
            });
          },
          itemBuilder: (_, index) {
            return Container(
              decoration: BoxDecoration(
                color: Utils.claro.withAlpha(100),
                borderRadius: BorderRadius.circular(20),
              ),
              child: products(mainProvider.cart[index]),
            );
          },
        ),
      ),
    );
  }

  Widget noProducts(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SvgPicture.asset('assets/svg/checklist.svg'),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Utils.claro,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('Está todo hecho!', style: mainProvider.mainTitleStyle),
          ),
        ],
      ),
    );
  }

  Widget floatingButton(BuildContext context) {
    if (mainProvider.cart.isNotEmpty && !isExpanded) {
      return ScrollVisibilityWidget(
        controller: scrollController,
        child: ElasticInRight(
          controller: (c) => fabController = c,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FloatingActionButton(
                elevation: 17,
                mini: true,
                onPressed: () {
                  final Cart cart = mainProvider.cart[pageController.page!.toInt()];
                  confirmDeleteCart(context, cart).then((value) {
                    if (value) {
                      setState(() {
                        mainProvider.clearCart(cart);
                      });
                    }
                  });
                },
                child: Icon(Icons.delete_forever, color: Utils.claro, size: 25),
              ),
              const SizedBox(height: 5),
              Container(
                decoration: BoxDecoration(
                  color: Utils.oscuro,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  onPressed: () async {
                    final p = await showAddProduct(context);
                    if (p[0]) {
                      final Cart cart = mainProvider.cart[pageController.page!.toInt()];
                      mainProvider.addCart(
                          shop: cart.shop, cartProduct: CartProduct(product: p[1], quantity: p[2]));
                      setState(() {});
                    }
                  },
                  icon: Icon(Icons.add, color: Utils.claro, size: 40),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget shopsNames() {
    return SizedBox(
      height: 60,
      child: ScrollablePositionedList.builder(
        itemScrollController: itemScrollController,
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: mainProvider.cart.length,
        itemBuilder: (_, index) {
          return shopName(mainProvider.cart[index]);
        },
      ),
    );
  }

  Widget shopName(Cart cart) {
    return GestureDetector(
      onTap: () => setState(() {
        scrollTo = mainProvider.cart
            .indexOf(mainProvider.cart.where((c) => c.shop.name == cart.shop.name).first);
        CartPage.shopNameSelected = cart.shop.name;
        pageController.jumpToPage(scrollTo);
      }),
      onLongPress: () => Navigator.pushNamed(context, ShopPage.routeName, arguments: cart.shop),
      child: DragTarget<CartCartProduct>(
        builder: (context, candidateData, rejectedData) {
          return Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(left: 10),
            decoration: BoxDecoration(
              color: candidateData.isNotEmpty
                  ? Utils.medio
                  : CartPage.shopNameSelected == cart.shop.name
                      ? Utils.oscuro
                      : Utils.claro,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Utils.oscuro,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(cart.shop.name,
                  style: CartPage.shopNameSelected == cart.shop.name
                      ? mainProvider.titleStyle.copyWith(color: Utils.claro)
                      : mainProvider.titleStyle),
            ),
          );
        },
        onAcceptWithDetails: (cartMove) {
          if (cartMove.data.cart.shop.name != cart.shop.name) {
            setState(() {
              mainProvider.moveCart(cartMove.data.cart, cart, cartMove.data.cartProduct);
              if (cartMove.data.cart.products.isEmpty) {
                pageController.jumpToPage(0);
              }
            });
          }
        },
      ),
    );
  }

  Widget products(Cart cart) {
    Widget productos;
    SliverGridDelegate delegate = Utils.homeIconImageSize == Utils.productImageSizeStandar
        ? const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 180,
            childAspectRatio: 0.8,
            crossAxisSpacing: 10,
            mainAxisSpacing: 20,
          )
        : const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
          );
    productos = GridView.builder(
      physics: const BouncingScrollPhysics(),
      controller: scrollController,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      gridDelegate: delegate,
      itemCount: cart.products.length,
      itemBuilder: (_, index) {
        return CartMiniWidget(
          cart: cart,
          cartProduct: cart.products[index],
          onMove: (move) => setState(() => showNewShop = move),
          onCheck: (history) {
            if (Preferences.deshacer) {
              _onCheckItem(context, cart.shop, cart.products[index], history);
            }
          },
          onDelete: (quantity) {
            if (Preferences.deshacer) {
              _onDeleteItem(context, cart.shop, cart.products[index], quantity);
            }
          },
        );
      },
    );

    return Stack(
      children: [
        productos,
        if (!showNewShop) _totalAmount(cart),
      ],
    );
  }

  Widget _totalAmount(Cart cart) {
    return Positioned(
      bottom: 16,
      left: 20,
      child: FadeInUp(
        child: GestureDetector(
          onTap: () => _bottomInfo(cart),
          child: Container(
            padding: const EdgeInsets.only(bottom: 10, left: 25, top: 10, right: 25),
            decoration: BoxDecoration(
              color: Utils.claro,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Center(
              child: Text('${cart.totalAmount.toStringAsFixed(2)}€',
                  style: mainProvider.mainTitleStyle),
            ),
          ),
        ),
      ),
    );
  }

  void _bottomInfo(Cart cart) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.only(bottom: 10, left: 15, top: 10, right: 15),
            decoration: BoxDecoration(
              color: Utils.claro,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text('Listado de ${cart.shop.name}', style: mainProvider.itemStyle),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    separatorBuilder: (context, index) => ZoomIn(
                      delay: Duration(milliseconds: 100 * index),
                      child: Divider(color: Utils.oscuro, thickness: 1),
                    ),
                    physics: const BouncingScrollPhysics(),
                    itemCount: cart.products.length,
                    itemBuilder: (context, index) {
                      double precio = mainProvider.productsShops
                          .firstWhere(
                              (p) =>
                                  p.product.id == cart.products[index].product.id &&
                                  p.shop.id == cart.shop.id,
                              orElse: () => ProductShop(
                                  0, cart.products[index].product, cart.shop, 0, DateTime.now()))
                          .price;
                      double total = precio * cart.products[index].quantity;
                      return ZoomIn(
                        delay: Duration(milliseconds: 100 * index),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 5),
                          child: Row(
                            children: [
                              Image(
                                  image: cart.products[index].product.imageType.image(),
                                  width: 30,
                                  height: 30),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 4,
                                child: SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  child: Text(
                                      cart.products[index].product.name +
                                          (cart.products[index].product.details.isNotEmpty
                                              ? ' (${cart.products[index].product.details})'
                                              : ''),
                                      style: mainProvider.itemStyle),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      Text(
                                          '${cart.products[index].quantity} x ${precio.toStringAsFixed(2)} = ',
                                          style: mainProvider.itemStyle),
                                      Text('${total.toStringAsFixed(2)} €',
                                          style: mainProvider.itemStyle),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                ZoomIn(
                  delay: const Duration(milliseconds: 500),
                  child: Container(
                    padding: const EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
                    decoration: BoxDecoration(
                      color: Utils.oscuro,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Utils.medio,
                          offset: const Offset(0, 5),
                          blurRadius: 17,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total', style: mainProvider.itemStyle.copyWith(color: Colors.white)),
                        Text('${cart.totalAmount.toStringAsFixed(2)} €',
                            style: mainProvider.itemStyle.copyWith(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _onDeleteItem(
      BuildContext context, Shop shop, CartProduct cartProduct, int quantity) async {
    deletedCartProduct = CartProduct.copy(cartProduct);
    deletedCartProduct.quantity = quantity;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.fixed,
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Producto borrado', style: mainProvider.itemStyle.copyWith(color: Utils.claro)),
          IconButton(
            onPressed: () {
              mainProvider.addCart(shop: shop, cartProduct: deletedCartProduct);
              if (context.mounted) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              }
            },
            icon: Container(
              width: 50,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Utils.medio,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.undo,
                color: Utils.claro,
                size: 30,
              ),
            ),
          )
        ],
      ),
    ));
  }

  Future<void> _onCheckItem(
      BuildContext context, Shop shop, CartProduct cartProduct, ShoppingHistory history) async {
    deletedCartProduct = CartProduct.copy(cartProduct);
    shoppingHistory = history;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.fixed,
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Comprado', style: mainProvider.itemStyle.copyWith(color: Utils.claro)),
          IconButton(
            onPressed: () async {
              await mainProvider.removeShoppingHistory(history);
              mainProvider.addCart(shop: shop, cartProduct: deletedCartProduct);
              if (context.mounted) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              }
            },
            icon: Container(
              width: 50,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Utils.medio,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.undo,
                color: Utils.claro,
                size: 30,
              ),
            ),
          )
        ],
      ),
    ));
  }
}
