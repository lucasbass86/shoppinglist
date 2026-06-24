import 'package:flutter/material.dart';
import 'package:shoppinglist/pages/_pages.dart';

Map<String, Widget Function(BuildContext)> routes = <String, WidgetBuilder>{
  HomePage.routeName: (_) => const HomePage(),
  ProductsPage.routeName: (_) => const ProductsPage(),
  ProductPage.routeName: (_) => const ProductPage(),
  NewProductPage.routeName: (_) => const NewProductPage(),
  ShopsPage.routeName: (_) => const ShopsPage(),
  CartPage.routeName: (_) => const CartPage(),
  ShopPage.routeName: (_) => const ShopPage(),
  SettingsPage.routeName: (_) => const SettingsPage(),
  HelpPage.routeName: (_) => const HelpPage(),
  WelcomePage.routeName: (_) => const WelcomePage(),
  TutorialPage.routeName: (_) => const TutorialPage(),
  UpdatePage.routeName: (_) => const UpdatePage(),
  UserPage.routeName: (_) => const UserPage(),
  HistoryPage.routeName: (_) => const HistoryPage(),
  HistoryDetailPage.routeName: (_) => const HistoryDetailPage(),
  ChartPage.routeName: (_) => const ChartPage(),
  ForecastPage.routeName: (_) => const ForecastPage(),
  ForecastHiddenPage.routeName: (_) => const ForecastHiddenPage(),
  ChartAmountPage.routeName: (_) => const ChartAmountPage(),
};
