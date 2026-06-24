import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:shoppinglist/main.dart';
import 'package:shoppinglist/models/models.dart';
import 'package:shoppinglist/pages/_pages.dart';
import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/utils/utils.dart';
import 'package:shoppinglist/widgets/_widgets.dart';

class ForecastPage extends StatefulWidget {
  static const String routeName = 'ForecastPage';
  const ForecastPage({super.key});

  @override
  State<ForecastPage> createState() => _ForecastPageState();
}

class _ForecastPageState extends State<ForecastPage> {
  late MainProvider mainProvider;
  double cartSize = 90;
  IconData iconCarrito = Icons.shopping_cart;
  bool fromCart = navigatorObserver.previousRoute == CartPage.routeName;

  @override
  Widget build(BuildContext context) {
    mainProvider = Provider.of<MainProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          const BackgroundWidget(),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _top(),
              if (mainProvider.shoppingHistory.isNotEmpty) _sliverList(),
              if (mainProvider.shoppingHistory.isEmpty) _nosHistory()
            ],
          ),
        ],
      ),
    );
  }

  Widget _top() {
    return SliverAppBar(
      pinned: false,
      automaticallyImplyLeading: false,
      expandedHeight: 60,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: TopWidget(
          title: 'Previsión',
          showBack: true,
          showHiddenForecast: true,
          showCart: !fromCart,
        ),
      ),
    );
  }

  Widget _sliverList() {
    List<Forecast> forecast = ShoppingForecast(mainProvider.shoppingHistory).generateForecast();
    forecast.removeWhere((f) => mainProvider.hiddenForecast.contains(f.product));
    forecast.removeWhere((f) => mainProvider.cart.any((c) {
          for (CartProduct cp in c.products) {
            if (cp.product.id == f.product.id) {
              return true;
            }
          }
          return false;
        }));
    return SliverList.separated(
      itemCount: forecast.length,
      itemBuilder: (context, index) {
        final entry = forecast[index];
        return Dismissible(
          key: Key(entry.id),
          direction: DismissDirection.startToEnd,
          background: Row(
            children: [
              const SizedBox(
                width: 20,
              ),
              Icon(
                Icons.delete_outline_rounded,
                color: Utils.claro,
                size: Utils.iconSizeSelected,
              ),
            ],
          ),
          child: BounceInLeft(
            delay: Duration(milliseconds: index + 100),
            child: ForecastWidget(entry: entry),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 10),
    );
  }

  Widget _nosHistory() {
    return SliverFillRemaining(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('No hay histórico', style: mainProvider.titleStyle),
            const SizedBox(height: 20),
            Icon(Icons.remove_shopping_cart_rounded, size: 100, color: Utils.medio),
          ],
        ),
      ),
    );
  }
}
