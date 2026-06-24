import 'dart:convert';
import 'package:shoppinglist/sharedpreferences/preferences.dart';
import 'package:shoppinglist/utils/enums.dart';
import 'package:shoppinglist/utils/utils.dart';
import 'package:uuid/uuid.dart';

class Product {
  int id;
  String name;
  String details;
  EImageType imageType;

  Product({required this.id, required this.name, required this.details, required this.imageType});

  @override
  String toString() {
    return name;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        details: json['details'],
        id: json['id'],
        imageType: EImageType.values.byName(json['imageType']),
        name: json['name'],
      );

  Map toJson() => {
        'id': id,
        'name': name,
        'details': details,
        'imageType': imageType.nameToString(),
      };
}

class Shop {
  int id;
  String name;

  Shop(this.id, this.name);

  @override
  String toString() {
    return name;
  }

  factory Shop.fromJson(Map<String, dynamic> json) => Shop(
        json['id'],
        json['name'],
      );

  Map toJson() => {
        'id': id,
        'name': name,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Shop && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class ProductShop {
  int id;
  Product product;
  Shop shop;
  double price;
  DateTime date;

  ProductShop(this.id, this.product, this.shop, this.price, this.date);

  @override
  String toString() {
    return '${product.name}, en ${shop.name}: $price';
  }

  Map toJson() => {
        'id': id,
        'product': product.toJson(),
        'shop': shop.toJson(),
        'price': price,
        'date': date.toIso8601String(),
      };
  factory ProductShop.fromJson(Map<String, dynamic> json) => ProductShop(
        json['id'],
        Product.fromJson(Map<String, dynamic>.from(json['product'])),
        Shop.fromJson(Map<String, dynamic>.from(json['shop'])),
        double.parse(json['price'].toString()),
        DateTime.parse(json['date']),
      );
}

class Cart {
  late String id;
  late List<CartProduct> products;
  late Shop shop;
  double totalAmount = 0;

  Cart() {
    products = [];
  }

  Map toJson() => {
        'id': id,
        'products': jsonEncode(products),
        'shop': shop.toJson(),
        'totalAmount': totalAmount,
      };

  @override
  String toString() {
    return shop.toString();
  }
}

class CartProduct {
  Product product;
  int quantity;

  CartProduct({required this.product, required this.quantity, required});

  Map toJson() => {'product': product.toJson(), 'quantity': quantity};

  factory CartProduct.fromJson(Map<String, dynamic> json) => CartProduct(
        product: Product.fromJson(json['product']),
        quantity: json['quantity'],
      );

  @override
  String toString() {
    return '$product,$quantity';
  }

  CartProduct.copy(CartProduct other)
      : product = other.product,
        quantity = other.quantity;
}

class CartCartProduct {
  Cart cart;
  CartProduct cartProduct;

  CartCartProduct({required this.cart, required this.cartProduct});

  @override
  String toString() {
    return '${cart.shop.name} - ${cartProduct.product.name}';
  }
}

class CheapPrice {
  late bool isCheap;
  late ProductShop productShop;

  CheapPrice(this.isCheap, this.productShop);
}

class PriceHistory {
  late int id;
  late DateTime fecha;
  late ProductShop productShop;

  PriceHistory(this.id, this.productShop, this.fecha);

  @override
  String toString() {
    return '${Utils.dateEnglishToSpanish(fecha.toString(), showTime: false)}-${productShop.product.name}-${productShop.shop.name}-${productShop.price}';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'productShop': productShop.toJson(),
        'fecha': fecha.toIso8601String(),
      };

  factory PriceHistory.fromJson(Map<String, dynamic> json) => PriceHistory(
        json['id'],
        ProductShop.fromJson(Map<String, dynamic>.from(json['productShop'])),
        DateTime.parse(json['fecha']),
      );
}

class ShoppingHistory {
  late String id;
  late Product product;
  late Shop shop;
  late DateTime date;
  late int quantity;
  late double price;
  late String cartId;
  late int order;

  @override
  String toString() => '$date: ${product.name} - $quantity:${shop.name}';

  ShoppingHistory(this.id, this.product, this.shop, this.date, this.quantity, this.price,
      this.cartId, this.order);

  Map<String, dynamic> toJson() => {
        'id': id,
        'product': product.toJson(),
        'shop': shop.toJson(),
        'fecha': date.toIso8601String(),
        'cantidad': quantity,
        'precio': price,
        'cartId': cartId,
        'order': order,
      };

  factory ShoppingHistory.fromJson(Map<String, dynamic> json) => ShoppingHistory(
        json['id'].toString(),
        Product.fromJson(Map<String, dynamic>.from(json['product'])),
        Shop.fromJson(Map<String, dynamic>.from(json['shop'])),
        DateTime.parse(json['fecha']),
        json['cantidad'],
        double.parse(json['precio'].toString()),
        json['cartId'] ?? '',
        json['order'] ?? 0,
      );
}

class GroupGraphic {
  Shop shop;
  List<Graphic> list = [];

  @override
  String toString() => shop.name;

  GroupGraphic({required this.shop});
}

class Graphic {
  late PriceHistory historicoPrecio;
  Graphic(this.historicoPrecio);
}

class User {
  String email;
  String password;
  List<ShoppingHistory> shoppingHistory;
  List<PriceHistory> priceHistory;
  List<ProductShop> productShops;
  List<Product> products;
  List<Shop> shops;

  @override
  String toString() => email;

  User({
    required this.email,
    required this.password,
    required this.shoppingHistory,
    required this.priceHistory,
    required this.productShops,
    required this.products,
    required this.shops,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        email: json['email'],
        password: json['password'].toString(),
        products: (json['products'] as List).map((e) => Product.fromJson(e)).toList(),
        shops: (json['shops'] as List).map((e) => Shop.fromJson(e)).toList(),
        productShops:
            (json['productShops'] as List?)?.map((e) => ProductShop.fromJson(e)).toList() ?? [],
        priceHistory:
            (json['priceHistory'] as List?)?.map((e) => PriceHistory.fromJson(e)).toList() ?? [],
        shoppingHistory:
            (json['shoppingHistory'] as List?)?.map((e) => ShoppingHistory.fromJson(e)).toList() ??
                [],
      );

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'products': (products).map((e) => e.toJson()).toList(),
        'shops': (shops).map((e) => e.toJson()).toList(),
        'productShops': (productShops).map((e) => e.toJson()).toList(),
        'priceHistory': (priceHistory).map((e) => e.toJson()).toList(),
        'shoppingHistory': (shoppingHistory).map((e) => e.toJson()).toList(),
      };
}

class ShoppingForecast {
  final List<ShoppingHistory> history;

  ShoppingForecast(this.history);

  List<Forecast> generateForecast() {
    // Agrupar por producto
    final Map<int, List<ShoppingHistory>> groupedByProduct = {};
    for (ShoppingHistory entry in history) {
      groupedByProduct.putIfAbsent(entry.product.id, () => []).add(entry);
    }

    final Map<int, Forecast> forecasts = {};

    // Procesar cada producto
    for (var productId in groupedByProduct.keys) {
      final entries = groupedByProduct[productId]!
        ..sort((a, b) => a.date.compareTo(b.date)); // Ordenar por fecha

      if (entries.length < 2) continue; // Necesitamos al menos 2 compras para predecir

      // Calcular intervalo promedio entre compras (en días)
      double totalInterval = 0;
      for (int i = 1; i < entries.length; i++) {
        totalInterval += entries[i].date.difference(entries[i - 1].date).inDays;
      }
      final avgInterval = totalInterval / (entries.length - 1);

      // Calcular cantidad promedio
      final avgQuantity = entries.map((e) => e.quantity).reduce((a, b) => a + b) / entries.length;

      // Fecha de la última compra
      final lastPurchase = entries.last.date;

      // Predecir próxima compra
      final nextPurchase = lastPurchase.add(Duration(days: avgInterval.round()));

      forecasts[productId] = Forecast(
        id: Uuid().v4(),
        product: entries.first.product,
        shop: entries.first.shop,
        nextPurchaseDate: nextPurchase,
        predictedQuantity: avgQuantity.round(),
      );
    }
    final currentDate = DateTime.now().add(Duration(days: -Preferences.forecastDays));
    final sortedForecasts = forecasts.values
        .toList()
        .where(
            (forecast) => forecast.nextPurchaseDate.isAfter(currentDate)) // Filtrar fechas pasadas
        .toList()
      ..sort((a, b) => a.nextPurchaseDate.compareTo(b.nextPurchaseDate));

    return sortedForecasts;
  }
}

class Forecast {
  final String id;
  final Product product;
  final Shop shop;
  final DateTime nextPurchaseDate;
  final int predictedQuantity;

  @override
  String toString() => '${shop.name}: ${product.name}';
  Forecast({
    required this.id,
    required this.product,
    required this.shop,
    required this.nextPurchaseDate,
    required this.predictedQuantity,
  });
}
