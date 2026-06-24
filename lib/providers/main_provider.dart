import 'package:flutter/material.dart';
import 'package:shoppinglist/models/models.dart';
import 'package:shoppinglist/pages/_pages.dart';
import 'package:shoppinglist/sharedpreferences/preferences.dart';
import 'package:shoppinglist/themes/themes.dart';
import 'package:shoppinglist/utils/enums.dart';
import 'package:shoppinglist/utils/utils.dart';
import 'package:uuid/uuid.dart';
export 'package:provider/provider.dart';

class MainProvider extends ChangeNotifier {
  bool canLoad = true;
  bool _isMoving = false;
  bool get isMoving => _isMoving;
  set isMoving(bool value) {
    _isMoving = value;
    notifyListeners();
  }

  bool isLoaded = false;
  EImageType _selectedProductType = EImageType.aceite;
  EImageType get selectedProductType => _selectedProductType;
  set selectedProductType(EImageType type) {
    _selectedProductType = type;
    notifyListeners();
  }

  EImageType _selectedFilter = EImageType.todo;
  EImageType get selectedFilter => _selectedFilter;
  set selectedFilter(EImageType filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  EOrderType get orderType => Preferences.orderType;
  set orderType(EOrderType order) {
    Preferences.orderType = order;
    notifyListeners();
  }

  TextStyle mainTitleStyle =
      TextStyle(color: Utils.oscuro, fontSize: 35, fontWeight: FontWeight.bold);
  TextStyle titleStyle = TextStyle(color: Utils.oscuro, fontSize: 25, fontWeight: FontWeight.bold);
  TextStyle minititleStyle =
      TextStyle(color: Utils.oscuro, fontSize: 21, fontWeight: FontWeight.bold);
  TextStyle itemStyle = TextStyle(color: Utils.oscuro, fontSize: 17, fontWeight: FontWeight.bold);
  TextStyle itemStyleN = TextStyle(color: Utils.oscuro, fontSize: 17);

  bool get borrarBusqueda {
    if (Preferences.borrarBusqueda) {
      Utils.fadeInDuration = const Duration(milliseconds: 800);
    } else {
      Utils.fadeInDuration = const Duration(milliseconds: 0);
    }
    return Preferences.borrarBusqueda;
  }

  set borrarBusqueda(bool value) {
    Preferences.borrarBusqueda = value;
    notifyListeners();
  }

  String _searchText = '';
  String get searchText => _searchText;
  set searchText(String value) {
    _searchText = value;
    notifyListeners();
  }

  ETheme _theme = ETheme.verde;
  ETheme get theme {
    switch (Preferences.theme) {
      case 0:
        _theme = ETheme.verde;
        break;
      case 1:
        _theme = ETheme.natural;
        break;
      case 2:
        _theme = ETheme.azul;
        break;
      case 3:
        _theme = ETheme.dark;
        break;
    }
    switch (_theme) {
      case ETheme.verde:
        Utils.oscuro = Utils.cVerdeOscuro;
        Utils.medio = Utils.cVerdeMedio;
        Utils.claro = Utils.cVerdeClaro;
        break;
      case ETheme.natural:
        Utils.oscuro = Utils.cNaturalOscuro;
        Utils.medio = Utils.cNaturalMedio;
        Utils.claro = Utils.cNaturalClaro;
        break;
      case ETheme.dark:
        Utils.oscuro = Utils.cDarkOscuro;
        Utils.medio = Utils.cDarkMedio;
        Utils.claro = Utils.cDarkClaro;
        break;
      case ETheme.azul:
        Utils.oscuro = Utils.cAzulOscuro;
        Utils.medio = Utils.cAzulMedio;
        Utils.claro = Utils.cAzulClaro;
        break;
    }

    mainTitleStyle = mainTitleStyle.copyWith(color: Utils.oscuro);
    titleStyle = titleStyle.copyWith(color: Utils.oscuro);
    minititleStyle = titleStyle.copyWith(color: Utils.oscuro);
    itemStyle = itemStyle.copyWith(color: Utils.oscuro);
    itemStyleN = itemStyle.copyWith(color: Utils.oscuro);
    return _theme;
  }

  set theme(ETheme t) {
    _theme = t;

    switch (t) {
      case ETheme.verde:
        Utils.oscuro = Utils.cVerdeOscuro;
        Utils.medio = Utils.cVerdeMedio;
        Utils.claro = Utils.cVerdeClaro;
        break;
      case ETheme.natural:
        Utils.oscuro = Utils.cNaturalOscuro;
        Utils.medio = Utils.cNaturalMedio;
        Utils.claro = Utils.cNaturalClaro;
        break;
      case ETheme.dark:
        Utils.oscuro = Utils.cDarkOscuro;
        Utils.medio = Utils.cDarkMedio;
        Utils.claro = Utils.cDarkClaro;
        break;
      case ETheme.azul:
        Utils.oscuro = Utils.cAzulOscuro;
        Utils.medio = Utils.cAzulMedio;
        Utils.claro = Utils.cAzulClaro;
        break;
    }

    mainTitleStyle = mainTitleStyle.copyWith(color: Utils.oscuro);
    titleStyle = titleStyle.copyWith(color: Utils.oscuro);
    itemStyle = itemStyle.copyWith(color: Utils.oscuro);

    getTheme(_theme);
    notifyListeners();
  }

  void updateMainProvider() {
    notifyListeners();
  }

  bool get avisoBarato => Preferences.avisoBarato;
  set avisoBarato(bool value) {
    Preferences.avisoBarato = value;
    notifyListeners();
  }

  bool get updateView => Preferences.updateView;
  set updateView(bool value) {
    Preferences.updateView = value;
    notifyListeners();
  }

  List<PriceHistory> _pricesHistory = [];
  List<PriceHistory> get pricesHistory => _pricesHistory;
  set pricesHistory(List<PriceHistory> price) {
    _pricesHistory = price;
    notifyListeners();
  }

  List<PriceHistory> priceHistoryByProduct(Product product) {
    List<PriceHistory> hist = pricesHistory
        .where((e) => e.productShop.product.id == product.id)
        .toList()
      ..sort((a, b) => a.fecha.compareTo(b.fecha));
    return hist;
  }

  // void addHistoricoPrecio(ProductShop productShop) async {
  //   int id = 0;
  //   for (PriceHistory h in pricesHistory) {
  //     if (h.id > id) {
  //       id = h.id;
  //     }
  //     if (h.productShop.product.id == productShop.product.id &&
  //         h.productShop.shop.id == productShop.shop.id &&
  //         h.productShop.price == productShop.price) {
  //       return;
  //     }
  //   }
  //   id++;
  //   PriceHistory hP = PriceHistory(id, productShop, productShop.date);

  //   await Utils.boxHistoryPrice.put(hP.id, hP.toJson());
  //   loadHistoricoPrecios();
  // }

  Future<PriceHistory> addHistoricoPrecio(ProductShop productShop) async {
    int id = 0;
    for (PriceHistory h in pricesHistory) {
      if (h.id > id) {
        id = h.id;
      }
      if (h.productShop.product.id == productShop.product.id &&
          h.productShop.shop.id == productShop.shop.id &&
          h.productShop.price == productShop.price) {
        break;
      }
    }
    id++;
    PriceHistory hP = PriceHistory(id, productShop, productShop.date);

    await Utils.boxHistoryPrice.put(hP.id, hP.toJson());
    loadHistoricoPrecios();

    return hP;
  }

  Future<PriceHistory> checkHistoricoPrecio(ProductShop productShop) async {
    List<PriceHistory> history = pricesHistory
        .where((h) =>
            h.productShop.product.id == productShop.product.id &&
            h.productShop.shop.id == productShop.shop.id &&
            h.fecha == productShop.date)
        .toList()
      ..sort((a, b) => b.fecha.compareTo(a.fecha));

    if (history.isNotEmpty) {
      return history[0];
    } else {
      return await addHistoricoPrecio(productShop);
    }
  }

  void updateHistoricoPrecio(PriceHistory history) async {
    await Utils.boxHistoryPrice.put(history.id, history.toJson());
    loadHistoricoPrecios();
  }

  void loadHistoricoPrecios() {
    pricesHistory = Utils.boxHistoryPrice.keys.map((key) {
      final value = Utils.boxHistoryPrice.get(key);
      return PriceHistory(
        key,
        ProductShop.fromJson(Map<String, dynamic>.from(value['productShop'])),
        DateTime.parse(value['fecha']),
      );
    }).toList()
      ..sort((a, b) => a.fecha.compareTo(b.fecha));
    notifyListeners();
  }

  void deleteHistoricoPrecio(PriceHistory toDel) async {
    await Utils.boxHistoryPrice.delete(toDel.id);
    await Utils.boxHistoryPrice.flush();
    loadHistoricoPrecios();
  }

  List<Product> _products = [];
  List<Product> _filter = [];
  List<Product> get filter => _filter;
  set filter(List<Product> f) {
    f.sort((a, b) => a.name.compareTo(b.name));
    _filter = f;
  }

  List<Product> get products => _products;
  set products(List<Product> products) {
    _products = products;
    products.sort((a, b) => a.name.compareTo(b.name));
    filter = products;
    notifyListeners();
  }

  void addEmptyProduct(String name, String details, EImageType imageType) {
    int id = 0;
    for (Product p in products) {
      if (p.id > id) {
        id = p.id;
      }
    }
    id++;
    Product product = Product(id: id, name: name, details: details, imageType: imageType);
    addProduct(product);
  }

  void addProduct(Product product) async {
    _products.add(product);
    filter = products;
    await Utils.boxProducts.put(product.id, product.toJson());
    notifyListeners();
  }

  void updateProduct(Product product) async {
    await Utils.boxProducts.put(product.id, product.toJson());
    for (ProductShop p in _productsShops.where((ps) => ps.product.id == product.id)) {
      p.product.name = product.name;
      p.product.details = product.details;
      p.product.imageType = product.imageType;
      await Utils.boxPrices.put(p.id, p.toJson());
    }
    for (Product p in _hiddenForecast.where((f) => f.id == product.id)) {
      p.name = product.name;
      p.details = product.details;
      p.imageType = product.imageType;
      await Utils.boxHiddenForecast.put(p.id, p.toJson());
    }
    for (PriceHistory p in _pricesHistory.where((ph) => ph.productShop.product.id == product.id)) {
      p.productShop.product.name = product.name;
      p.productShop.product.details = product.details;
      p.productShop.product.imageType = product.imageType;
      await Utils.boxHistoryPrice.put(p.id, p.toJson());
    }
    // NO ACTUALIZO LAS COMPRAS POR SI SE HAN CAMBIADO NOMBRES.
    // for (ShoppingHistory p in _shoppingHistory.where((sh) => sh.product.id == product.id)) {
    //   p.product.name = product.name;
    //   p.product.details = product.details;
    //   p.product.imageType = product.imageType;
    //   await Utils.boxShoppingHistory.put(p.id, p.toJson());
    // }
    for (Cart cart
        in _cart.where((c) => c.products.where((c2) => c2.product.id == product.id).isNotEmpty)) {
      cart.products.where((p1) => p1.product.id == product.id).map((p) {
        p.product.name = product.name;
        p.product.details = product.details;
        p.product.imageType = product.imageType;
      });
      await Utils.boxCart.put(cart.id, cart.toJson());
    }
    notifyListeners();
  }

  void removeProduct(Product product) async {
    // //BORRAR LOS PRECIOS GUARDADOS:
    // productsShops.removeWhere((p) => p.product.id == product.id);

    // //BORRAR DEL CARRO DE LA COMPRA:
    // for (Cart c in cart) {
    //   c.products.removeWhere((p) => p.product.id == product.id);
    //   if (c.products.isEmpty) cart.remove(c);
    // }

    //BORRAR EL PRODUCTO:
    _products.remove(product);
    filter = products;

    await Utils.boxProducts.delete(product.id);

    notifyListeners();
  }

  bool productHasMovement(Product product) {
    if (productsShops.where((p) => p.product.id == product.id).isNotEmpty) return true;
    if (pricesHistory.where((p) => p.productShop.product.id == product.id).isNotEmpty) return true;
    if (shoppingHistory.where((p) => p.product.id == product.id).isNotEmpty) return true;

    for (Cart c in cart) {
      if (c.products.where((p) => p.product.id == product.id).isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  void searchProduct(String toSearch) {
    if (toSearch.isNotEmpty) {
      filter = _products
          .where((p) =>
              Utils.quitarTildes(p.name.toUpperCase())
                  .contains(Utils.quitarTildes(toSearch.toUpperCase())) ||
              Utils.quitarTildes(p.details.toUpperCase())
                  .contains(Utils.quitarTildes(toSearch.toUpperCase())))
          .toList();
    } else {
      filter = products;
    }
    filter.sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
  }

  List<Shop> _shops = [];
  List<Shop> _filterShops = [];
  List<Shop> get filterShops {
    _filterShops.sort((a, b) => a.name.compareTo(b.name));
    return _filterShops;
  }

  set filterShops(List<Shop> f) {
    _filterShops = f;
  }

  List<Shop> get shops => _shops;
  set shops(List<Shop> shops) {
    _shops = shops;
    _filterShops = shops;
    _filterShops.sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
  }

  void searchShop(String name) {
    if (name.isNotEmpty) {
      filterShops = _shops.where((p) => p.name.toUpperCase().contains(name.toUpperCase())).toList();
    } else {
      filterShops = _shops;
    }
    notifyListeners();
  }

  void addShop(String name) async {
    int index = 0;
    for (Shop s in _shops) {
      if (s.id > index) {
        index = s.id;
      }
    }
    index++;
    Shop shop = Shop(index, name);
    _shops.add(shop);
    _filterShops = _shops;

    await Utils.boxShops.put(shop.id, shop.toJson());

    notifyListeners();
  }

  void removeShop(Shop shop) async {
    // //BORRAR LOS PRECIOS GUARDADOS:
    // productsShops.removeWhere((p) => p.shop.id == shop.id);

    // //BORRAR DEL CARRO DE LA COMPRA:
    // cart.removeWhere((s) => s.shop.id == shop.id);

    // //BORRAR EL HISTORICO DE PRECIOS:
    // pricesHistory.removeWhere((s) => s.productShop.shop.id == shop.id);

    // //BORRAR EL HISTORICO DE COMPRAS:
    // shoppingHistory.removeWhere((s) => s.shop.id == shop.id);

    //BORRAR LA TIENDA:
    _shops.remove(shop);
    _filterShops = _shops;

    await Utils.boxShops.delete(shop.id);
    notifyListeners();
  }

  bool shopHasMovements(Shop shop) {
    if (productsShops.where((s) => s.shop.id == shop.id).isNotEmpty) return true;
    if (pricesHistory.where((s) => s.productShop.shop.id == shop.id).isNotEmpty) return true;
    if (shoppingHistory.where((s) => s.shop.id == shop.id).isNotEmpty) return true;
    if (cart.where((s) => s.shop.id == shop.id).isNotEmpty) return true;
    return false;
  }

  void renameShop(Shop shop) async {
    await Utils.boxShops.put(shop.id, shop.toJson());
    for (ShoppingHistory shoppingHistory
        in shoppingHistory.where((h) => h.shop.id == shop.id).toList()) {
      shoppingHistory.shop.name = shop.name;
      await Utils.boxShoppingHistory.put(shoppingHistory.id, shoppingHistory.toJson());
    }
    for (PriceHistory priceHistory
        in pricesHistory.where((p) => p.productShop.shop.id == shop.id).toList()) {
      priceHistory.productShop.shop.name = shop.name;
      await Utils.boxHistoryPrice.put(priceHistory.id, priceHistory.toJson());
    }
    for (ProductShop productShop in productsShops.where((p) => p.shop.id == shop.id).toList()) {
      productShop.shop.name = shop.name;
      await Utils.boxPrices.put(productShop.id, productShop.toJson());
    }
    for (Cart c in cart.where((c) => c.shop.id == shop.id).toList()) {
      c.shop.name = shop.name;
      await Utils.boxCart.put(c.id, c.toJson());
    }
    notifyListeners();
  }

  late Shop _selectedShop;
  Shop get selectedShop {
    if (Preferences.selectedShopID != -100) {
      _selectedShop = shops.firstWhere((s) => s.id == Preferences.selectedShopID);
    } else if (shops.isNotEmpty && _nameSelectedShop == '') {
      _selectedShop = shops[0];
    }
    nameSelectedShop = _selectedShop.name;
    return _selectedShop;
  }

  set selectedShop(Shop s) {
    _selectedShop = s;
    Preferences.selectedShopID = s.id;
    notifyListeners();
  }

  String _nameSelectedShop = '';
  String get nameSelectedShop => _nameSelectedShop;
  set nameSelectedShop(String name) {
    _nameSelectedShop = name;
    selectedShop = shops.where((t) => t.name == name).toList()[0];
    notifyListeners();
  }

  List<ProductShop> _productsShops = [];
  List<ProductShop> get productsShops => _productsShops;
  set productsShops(List<ProductShop> p) {
    _productsShops = p;
    notifyListeners();
  }

  int getIndexProductShop() {
    int index = 0;
    for (ProductShop p in productsShops) {
      if (p.id > index) {
        index = p.id;
      }
    }
    index++;
    return index;
  }

  ProductShop newProductShop(Product product, Shop shop, double price) {
    int index = getIndexProductShop();
    ProductShop productShop = ProductShop(index, product, shop, price, DateTime.now());
    Utils.boxPrices.put(productShop.id, productShop.toJson());
    _productsShops.add(productShop);
    return productShop;
  }

  void addProductShop(ProductShop productShop) {
    // bool contains = _productsShops
    //     .any((p) => p.product.id == productShop.product.id && p.shop.id == productShop.shop.id);
    // ProductShop contains = _productsShops.firstWhere(
    //     (p) => p.product.id == productShop.product.id && p.shop.id == productShop.shop.id);

    bool contains = false;
    for (ProductShop p in _productsShops) {
      if (p.product.id == productShop.product.id && p.shop.id == productShop.shop.id) {
        productShop.id = p.id;
        contains = true;
        break;
      }
    }

    if (!contains) {
      _productsShops.add(productShop);
      Utils.boxPrices.put(productShop.id, productShop.toJson());
      calculateAmount();
      notifyListeners();
    } else {
      updateProductShop(productShop);
    }
  }

  void updateProductShop(ProductShop productShop) {
    _productsShops[_productsShops.indexWhere(
        (p) => p.id == productShop.id && p.shop.id == productShop.shop.id)] = productShop;
    Utils.boxPrices.put(productShop.id, productShop.toJson());
    calculateAmount();
    notifyListeners();
  }

  void removeProductShop(ProductShop productShop) {
    _productsShops.remove(productShop);

    Utils.boxPrices.delete(productShop.id);
    notifyListeners();
  }

  double getProductPrice(Product product, Shop shop) {
    ProductShop productShop = _productsShops.lastWhere(
        (h) => h.product.id == product.id && h.shop.id == shop.id,
        orElse: () => ProductShop(-1, product, shop, 0, DateTime.now()));
    return productShop.price;
  }

  List<Cart> _cart = [];
  List<Cart> get cart => _cart;
  set cart(List<Cart> c) {
    _cart = c;
    notifyListeners();
  }

  int get cartItems {
    int total = 0;
    for (Cart c in cart) {
      total += c.products.length;
    }
    return total;
  }

  // int getIdCart() {
  //   int index = 0;
  //   for (Cart c in cart) {
  //     if (c.id > index) {
  //       index = c.id;
  //     }
  //   }
  //   index++;
  //   return index;
  // }

  String getIdCart(Shop shop) {
    for (Cart c in cart) {
      if (c.shop.id == shop.id) {
        return c.id;
      }
    }
    return Uuid().v4();
  }

  void addCart({required Shop shop, required CartProduct cartProduct, bool updateCart = false}) {
    bool insert = false;
    Cart aux = Cart()..id = getIdCart(shop);
    for (Cart c in cart) {
      if (c.shop.name == shop.name) {
        if (c.products.where((p) => p.product.id == cartProduct.product.id).isEmpty) {
          c.products.add(cartProduct);
          aux = c;
          insert = true;
          break;
        } else {
          if (!updateCart) {
            c
                .products[c.products
                    .indexOf(c.products.where((p) => p.product.id == cartProduct.product.id).first)]
                .quantity += cartProduct.quantity;
          } else {
            c
                .products[c.products
                    .indexOf(c.products.where((p) => p.product.id == cartProduct.product.id).first)]
                .quantity += 1;
          }
          insert = true;
          aux = c;
          break;
        }
      }
    }
    if (aux.products.isEmpty) {
      aux.products.add(cartProduct);
      aux.shop = shop;
    }

    if (!insert) {
      Cart c = Cart()
        // ..id = getIdCart(shop)
        ..id = aux.id
        ..shop = shop
        ..products = <CartProduct>[cartProduct];
      c.products.sort((a, b) => a.product.name.compareTo(b.product.name));
      cart.add(c);

      Utils.boxCart.put(c.id, c.toJson());
    } else {
      Utils.boxCart.put(aux.id, aux.toJson());
    }

    cart.sort((a, b) => a.shop.name.compareTo(b.shop.name));

    calculateAmount();
    notifyListeners();
  }

  void calculateAmount() {
    for (Cart cart in _cart) {
      cart.totalAmount = 0;
      for (CartProduct pro in cart.products) {
        double precio = productsShops
            .firstWhere((p) => p.product.id == pro.product.id && p.shop.id == cart.shop.id,
                orElse: () => ProductShop(0, pro.product, cart.shop, 0, DateTime.now()))
            .price;
        double total = precio * pro.quantity;
        cart.totalAmount += total;
      }
    }
  }

  void clearCart(Cart cart) {
    _cart.remove(cart);
    Utils.boxCart.delete(cart.id);
    // Utils.boxCart.deleteAll(Utils.boxCart.keys);
    // Utils.boxCart.delete();
    notifyListeners();
  }

  Future<void> removeFromCart(Cart cart, CartProduct cartProduct) async {
    _cart[_cart.indexOf(cart)]
        .products
        .where((p) => p.product.id == cartProduct.product.id)
        .first
        .quantity--;
    // _cart[_cart.indexOf(cart)].totalAmount -=
    //     precios.firstWhere((p) => p.product.id == cartProduct.product.id && p.shop.id == cart.shop.id, orElse: () => ProductShop(0, cartProduct.product, cart.shop, 0)).price;
    if (cartProduct.quantity == 0) {
      _cart[_cart.indexOf(cart)].products.remove(cartProduct);
    }
    Utils.boxCart.put(cart.id, _cart[_cart.indexOf(cart)].toJson());
    if (_cart[_cart.indexOf(cart)].products.isEmpty) {
      _cart.remove(cart);
      Utils.boxCart.delete(cart.id);
    }
    if (!_cart.contains(cart)) {
      if (_cart.isNotEmpty) {
        CartPage.shopNameSelected = _cart[0].shop.name;
      }
    }
    calculateAmount();
    notifyListeners();
  }

  void removeFromCartAllProduct(Cart cart, CartProduct cartProduct) {
    _cart[_cart.indexOf(cart)]
        .products
        .where((p) => p.product.id == cartProduct.product.id)
        .first
        .quantity = 0;
    // _cart[_cart.indexOf(cart)].totalAmount -=
    //     precios.firstWhere((p) => p.product.id == cartProduct.product.id && p.shop.id == cart.shop.id, orElse: () => ProductShop(0, cartProduct.product, cart.shop, 0)).price;
    if (cartProduct.quantity == 0) {
      _cart[_cart.indexOf(cart)].products.remove(cartProduct);
    }
    Utils.boxCart.put(cart.id, _cart[_cart.indexOf(cart)].toJson());
    if (_cart[_cart.indexOf(cart)].products.isEmpty) {
      _cart.remove(cart);
      Utils.boxCart.delete(cart.id);
    }
    if (!_cart.contains(cart)) {
      if (_cart.isNotEmpty) {
        CartPage.shopNameSelected = _cart[0].shop.name;
      }
    }
    calculateAmount();
    notifyListeners();
  }

  void moveCart(Cart from, Cart to, CartProduct cartProduct) {
    if (to.products.where((p) => p.product.id == cartProduct.product.id).isEmpty) {
      to.products.add(cartProduct);
    } else {
      to
          .products[to.products
              .indexOf(to.products.where((p) => p.product.id == cartProduct.product.id).first)]
          .quantity += cartProduct.quantity;
    }

    _cart[_cart.indexOf(from)].products.remove(cartProduct);
    Utils.boxCart.put(from.id, _cart[_cart.indexOf(from)].toJson());
    Utils.boxCart.put(to.id, _cart[_cart.indexOf(to)].toJson());
    if (_cart[_cart.indexOf(from)].products.isEmpty) {
      _cart.remove(from);
      Utils.boxCart.delete(from.id);
    }
    if (!_cart.contains(from)) {
      if (_cart.isNotEmpty) {
        CartPage.shopNameSelected = _cart[0].shop.name;
      }
    }
    calculateAmount();
    notifyListeners();
  }

  CheapPrice checkBarato(CartProduct cartProduct) {
    ProductShop tiendaActual = productsShops.firstWhere(
        (p) => p.shop.id == selectedShop.id && p.product.id == cartProduct.product.id,
        orElse: () => ProductShop(0, cartProduct.product, selectedShop, 0, DateTime.now()));
    CheapPrice precioBarato = CheapPrice(false, tiendaActual);
    double value = tiendaActual.price;
    double valAux = value;
    List<ProductShop> preciosProductoAct =
        productsShops.where((p) => p.product.id == cartProduct.product.id).toList();
    for (ProductShop precio in preciosProductoAct) {
      if (precio.price < value && precio.price < valAux) {
        precioBarato = CheapPrice(true, precio);
        valAux = precio.price;
      }
    }
    return precioBarato;
  }

  List<ShoppingHistory> _shoppingHistory = [];
  List<ShoppingHistory> get shoppingHistory => _shoppingHistory;
  set shoppingHistory(List<ShoppingHistory> history) {
    _shoppingHistory = history;
    notifyListeners();
  }

  void loadShoppingHistory({bool notify = true}) {
    shoppingHistory.clear();
    shoppingHistory = Utils.boxShoppingHistory.keys.map((key) {
      final value = Utils.boxShoppingHistory.get(key);
      return ShoppingHistory(
        key.toString(),
        Product.fromJson(Map<String, dynamic>.from(value['product'])),
        Shop.fromJson(Map<String, dynamic>.from(value['shop'])),
        DateTime.parse(value['fecha']),
        value['cantidad'],
        value['precio'] ?? 0,
        value['cartId'] ?? '0',
        value['order'] ?? 0,
      );
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    notifyListeners();
  }

  Future<ShoppingHistory> addShoppingHistory(
      Product product, Shop shop, int cantidad, String cartId,
      {DateTime? dateTime}) async {
    String id = Uuid().v4();
    ProductShop productShop = productsShops.lastWhere(
      (p) => p.shop.id == shop.id && p.product.id == product.id,
      orElse: () => newProductShop(product, shop, 0),
    );
    List<ShoppingHistory> c = shoppingHistory.where((s) => s.cartId == cartId).toList();
    int order = 0;
    if (c.isNotEmpty) {
      if (c.any((e) => e.product.id == product.id)) {
        ShoppingHistory sH = c.firstWhere((e) => e.product.id == product.id);
        sH.quantity += cantidad;
        await Utils.boxShoppingHistory.put(sH.id, sH.toJson());
        _shoppingHistory.firstWhere((e) => e.id == sH.id).quantity = sH.quantity;
        loadShoppingHistory();
        // notifyListeners();
        return sH;
      }
      order = c.length;
    }
    ShoppingHistory hC = ShoppingHistory(
        id, product, shop, dateTime ?? DateTime.now(), cantidad, productShop.price, cartId, order);
    await Utils.boxShoppingHistory.put(hC.id, hC.toJson());
    loadShoppingHistory();
    return hC;
  }

  List<ShoppingHistory> loadshoppingHistoryByProduct(Product product) {
    return shoppingHistory.where((h) => h.product.id == product.id).toList();
  }

  List<ShoppingHistory> loadShoppingHistoryByShop(Shop shop) {
    return shoppingHistory.where((h) => h.shop.id == shop.id).toList();
  }

  Future<void> removeShoppingHistory(ShoppingHistory history) async {
    _shoppingHistory.remove(history);
    await Utils.boxShoppingHistory.delete(history.id);
    loadShoppingHistory(notify: false);
  }

  Future<void> renameShoppingHistory(ShoppingHistory history, String text) async {
    _shoppingHistory.firstWhere((s) => s.id == history.id).product.name = text;
    await Utils.boxShoppingHistory.put(history.id, history.toJson());
    loadShoppingHistory(notify: false);
  }

  void updateShoppingHistory(ShoppingHistory history) async {
    final index = shoppingHistory.indexWhere((sh) => sh.id == history.id);
    shoppingHistory[index] = history;
    await Utils.boxShoppingHistory.put(history.id, history.toJson());
    notifyListeners();
  }

  ///Renueva el ID de cada carrito de compra por si hay algo que no se compra en un día,
  ///al comprarlo otro día, no se mezclen los datos.
  void renewCartId() {
    for (Cart c in cart) {
      Utils.boxCart.delete(c.id);
      c.id = Uuid().v4();
      Utils.boxCart.put(c.id, c.toJson());
    }
  }

  void maintenance() async {
    // for (ShoppingHistory history in shoppingHistory) {
    //   history.cartId = '';
    //   await Utils.boxShoppingHistory.put(history.id, history.toJson());
    // }
    if (!Preferences.maintenanceIdCartOrder && shoppingHistory.isNotEmpty) {
      //ACTUALIZAR LOS IDCART:
      DateTime dateTime = shoppingHistory[0].date;
      Shop shop = shoppingHistory[0].shop;
      String uuid = '';
      for (ShoppingHistory history in shoppingHistory) {
        if (history.cartId != '') continue;

        if (history.date.year == dateTime.year &&
            history.date.month == dateTime.month &&
            history.date.day == dateTime.day &&
            history.shop.id == shop.id) {
          if (uuid.isEmpty) {
            uuid = Uuid().v4();
          }
        } else {
          uuid = Uuid().v4();
          dateTime = history.date;
          shop = history.shop;
        }
        history.cartId = uuid;
      }
      //PONER UN ORDER EN TODOS:
      Map<String, List<ShoppingHistory>> groupedByCartId = {};

      // Iterar sobre la lista y agrupar
      for (ShoppingHistory history in shoppingHistory) {
        if (!groupedByCartId.containsKey(history.cartId)) {
          groupedByCartId[history.cartId] = [];
        }
        groupedByCartId[history.cartId]!.add(history);
      }

      // Asignar un valor de order secuencial dentro de cada grupo
      groupedByCartId.forEach((cartId, items) {
        for (int i = 0; i < items.length; i++) {
          items[i].order = i;
        }
      });
      for (ShoppingHistory history in shoppingHistory) {
        await Utils.boxShoppingHistory.put(history.id, history.toJson());
      }
      Preferences.maintenanceIdCartOrder = true;
    }
  }

  List<Product> _hiddenForecast = [];
  List<Product> get hiddenForecast => _hiddenForecast;
  set hiddenForecast(List<Product> hidden) {
    _hiddenForecast = hidden;
    hiddenForecast.sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
  }

  void addHiddenForecast(Product product) async {
    _hiddenForecast.add(product);
    await Utils.boxHiddenForecast.put(product.id, product.toJson());
    notifyListeners();
  }

  void removeHiddenForecast(Product product) async {
    _hiddenForecast.removeWhere((p) => p.id == product.id);
    await Utils.boxHiddenForecast.delete(product.id);
    notifyListeners();
  }
}
