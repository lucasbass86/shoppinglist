import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shoppinglist/models/models.dart';
import 'package:shoppinglist/pages/_pages.dart';
import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/routes/routes.dart';
import 'package:shoppinglist/services/update_service.dart';
import 'package:shoppinglist/sharedpreferences/preferences.dart';
import 'package:shoppinglist/themes/themes.dart';
import 'package:shoppinglist/utils/utils.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MyNavigatorObserver extends NavigatorObserver {
  String? _previousRoute;

  String? get previousRoute => _previousRoute;

  @override
  void didPush(Route route, Route? previousRoute) {
    _previousRoute = previousRoute?.settings.name;
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    _previousRoute = previousRoute?.settings.name;
    super.didPop(route, previousRoute);
  }
}

final MyNavigatorObserver navigatorObserver = MyNavigatorObserver();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, // Solo vertical normal
    DeviceOrientation.portraitDown, // (Opcional) Vertical invertido
  ]);

  await Preferences.init();

  Utils.path = await getApplicationDocumentsDirectory();
  Hive.init(Utils.path.path);

  await Hive.openBox('shoppingListProductos');
  await Hive.openBox('shoppingListTiendas');
  await Hive.openBox('shoppingListPrecios');
  await Hive.openBox('shoppingListCart');
  await Hive.openBox('shoppingHistoricoPrecios');
  await Hive.openBox('shoppingHistoricoCompras');
  await Hive.openBox('shoppingHiddenForecast');

  runApp(const AppState());
}

class AppState extends StatelessWidget {
  const AppState({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MainProvider(), lazy: true),
        ChangeNotifierProvider(create: (_) => UpdateService(), lazy: true),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    MainProvider mainProvider = Provider.of<MainProvider>(context);
    if (!mainProvider.isLoaded) {
      Future.delayed(const Duration(seconds: 1), () {
        mainProvider.products = Utils.boxProducts.keys.map((key) {
          final value = Utils.boxProducts.get(key);
          return Product.fromJson(Map<String, dynamic>.from(value));
        }).toList();

        mainProvider.shops = Utils.boxShops.keys.map((key) {
          final value = Utils.boxShops.get(key);
          return Shop(key, value['name']);
        }).toList();

        mainProvider.productsShops = Utils.boxPrices.keys.map((key) {
          final value = Utils.boxPrices.get(key);
          final ProductShop productShop = ProductShop(
            key,
            Product.fromJson(Map<String, dynamic>.from(value['product'])),
            Shop.fromJson(Map<String, dynamic>.from(value['shop'])),
            value['price'],
            DateTime.parse(value['date']),
          );
          Utils.boxPrices.put(productShop.id, productShop.toJson());
          return productShop;
        }).toList();

        mainProvider.cart = Utils.boxCart.keys.map((key) {
          final value = Utils.boxCart.get(key);
          List<dynamic> list = jsonDecode(value['products']);
          Cart cart = Cart()
            ..id = key.toString()
            ..shop = Shop.fromJson(Map<String, dynamic>.from(value['shop']))
            ..products = list.map((p) => CartProduct.fromJson(p)).toList()
            ..totalAmount = value['totalAmount'];
          mainProvider.cart.add(cart);
          return cart;
        }).toList();

        mainProvider.hiddenForecast = Utils.boxHiddenForecast.keys.map((key) {
          final value = Utils.boxHiddenForecast.get(key);
          return Product.fromJson(Map<String, dynamic>.from(value));
        }).toList();

        mainProvider.loadHistoricoPrecios();

        mainProvider.isLoaded = true;
        mainProvider.filter = mainProvider.products;
        mainProvider.filterShops = mainProvider.shops;

        mainProvider.calculateAmount();

        mainProvider.loadShoppingHistory();

        mainProvider.renewCartId();

        mainProvider.maintenance();

        //BORRAR DATOS:
        //     Utils.boxHistoricoCompras.deleteAll(Utils.boxHistoricoCompras.keys);
        // Utils.boxCart.deleteAll(Utils.boxCart.keys);
      });
    }
    return MaterialApp(
      navigatorObservers: [navigatorObserver],
      title: 'Shopping List App',
      debugShowCheckedModeBanner: false,
      initialRoute: Preferences.welcomePage
          ? Preferences.tutorialPage
              ? HomePage.routeName
              : TutorialPage.routeName
          : WelcomePage.routeName,
      routes: routes,
      theme: getTheme(mainProvider.theme),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        //Locale('en'), // English
        Locale('es'), // Spanish
      ],
    );
  }
}
