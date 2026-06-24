import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shoppinglist/dialogs/dialogs.dart';
import 'package:shoppinglist/models/models.dart';
import 'package:shoppinglist/pages/_pages.dart';
import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/sharedpreferences/preferences.dart';
import 'package:shoppinglist/utils/utils.dart';

class TopWidget extends StatefulWidget {
  final String title;
  final bool showBack;
  final bool showCart;
  final bool showExit;
  final bool showHelp;
  final bool showForecast;
  final bool showHiddenForecast;
  final bool showChart;
  const TopWidget({
    super.key,
    this.title = '',
    required this.showBack,
    this.showCart = true,
    this.showExit = false,
    this.showHelp = false,
    this.showForecast = false,
    this.showHiddenForecast = false,
    this.showChart = false,
  });

  @override
  State<TopWidget> createState() => _TopWidgetState();
  static late AnimationController topAnimationController;
}

class _TopWidgetState extends State<TopWidget> with SingleTickerProviderStateMixin {
  double cartSize = Utils.iconSizeSelected;
  final double counterSize = Utils.iconSizeSelected == Utils.iconSizeStandar ? 20 : 40;
  final double fontSize = Utils.iconSizeSelected == Utils.iconSizeStandar ? 13 : 20;
  late MainProvider mainProvider;

  @override
  void initState() {
    super.initState();
    TopWidget.topAnimationController =
        AnimationController(vsync: this, duration: Utils.fadeInDuration);
  }

  @override
  Widget build(BuildContext context) {
    mainProvider = Provider.of<MainProvider>(context);
    bool showCart = widget.showCart;
    bool showExit = widget.showExit;
    bool showHelp = widget.showHelp;
    bool showForecast = widget.showForecast;
    bool showHiddenForecast = widget.showHiddenForecast;
    bool showChart = widget.showChart;
    if (!Preferences.tutorialPage) {
      showCart = false;
      showExit = false;
      showHelp = false;
    }
    return FadeInDown(
      duration: Utils.fadeInDuration,
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            if (widget.showBack)
              Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => close(),
                      child: Icon(Icons.arrow_back_ios_new_rounded,
                          color: Utils.oscuro, size: Utils.iconSizeSelected),
                    ),
                  ),
                  const SizedBox(width: 5),
                ],
              ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (ModalRoute.of(context)!.settings.name != HomePage.routeName) {
                    close();
                  }
                },
                child: Text(
                  widget.title,
                  style: mainProvider.mainTitleStyle.copyWith(
                    shadows: [
                      BoxShadow(
                        color: Utils.claro,
                        offset: const Offset(2, 2),
                        spreadRadius: 3,
                        blurRadius: 7,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (showForecast)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => Navigator.pushNamed(context, ForecastPage.routeName),
                  child: Icon(Icons.calendar_today_rounded,
                      color: Utils.oscuro, size: Utils.iconSizeSelected),
                ),
              ),
            if (showHiddenForecast)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => Navigator.pushNamed(context, ForecastHiddenPage.routeName),
                  child: Icon(Icons.hide_source_rounded,
                      color: Utils.oscuro, size: Utils.iconSizeSelected),
                ),
              ),
            if (showChart)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => Navigator.pushNamed(context, ChartAmountPage.routeName),
                  child: Icon(Icons.pie_chart_rounded,
                      color: Utils.oscuro, size: Utils.iconSizeSelected),
                ),
              ),
            if (showCart)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => Navigator.pushNamed(context, CartPage.routeName),
                  child: DragTarget<Product>(
                    builder: (context, candidateData, rejectedData) {
                      return Stack(
                        children: [
                          Icon(Icons.shopping_cart, color: Utils.oscuro, size: cartSize),
                          if (mainProvider.cartItems > 0)
                            Positioned(
                              right: 0,
                              child: ElasticInUp(
                                from: 10,
                                duration: Utils.fadeInDuration,
                                controller: (controller) =>
                                    TopWidget.topAnimationController = controller,
                                child: Container(
                                  width: counterSize,
                                  height: counterSize,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Utils.claro,
                                  ),
                                  child: Center(
                                    child: Text('${mainProvider.cartItems}',
                                        style: mainProvider.itemStyle.copyWith(fontSize: fontSize)),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                    onAcceptWithDetails: (product) {
                      if (mainProvider.shops.isNotEmpty) {
                        if (mainProvider.nameSelectedShop.isEmpty) {
                          mainProvider.nameSelectedShop = mainProvider.shops[0].name;
                        }
                        showShops(context, product: product.data).then((value) {
                          if (value[0]) {
                            mainProvider.addCart(
                                shop: mainProvider.selectedShop,
                                cartProduct:
                                    CartProduct(product: product.data, quantity: value[1]));
                            if (mainProvider.borrarBusqueda && mainProvider.filter.isNotEmpty) {
                              mainProvider.searchProduct('');
                              mainProvider.searchShop('');
                              WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
                            }
                            TopWidget.topAnimationController.forward(from: 0.0);
                          }
                        });
                      } else {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(Utils.snackBar('No hay tiendas creadas', isGood: false));
                      }
                      setState(() {
                        cartSize = Utils.iconSizeSelected;
                      });
                    },
                    onWillAcceptWithDetails: (data) {
                      setState(() {
                        cartSize = Utils.iconSizeDrag;
                      });
                      return true;
                    },
                    onLeave: (data) {
                      setState(() {
                        cartSize = Utils.iconSizeSelected;
                      });
                    },
                  ),
                ),
              ),
            if (showExit)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => SystemNavigator.pop(),
                  child: Icon(Icons.power_settings_new_rounded,
                      color: Utils.oscuro, size: Utils.iconSizeSelected),
                ),
              ),
            if (showHelp)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => Navigator.pushNamed(context, HelpPage.routeName),
                  child: Stack(
                    children: [
                      Icon(Icons.help_outline_rounded,
                          color: Utils.oscuro, size: Utils.iconSizeSelected),
                      if (!mainProvider.updateView)
                        Positioned(
                          right: 0,
                          child: ElasticInUp(
                            from: 10,
                            duration: Utils.fadeInDuration,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Utils.claro,
                              ),
                              child: Center(
                                child: Text('!',
                                    style: mainProvider.itemStyle.copyWith(fontSize: fontSize)),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void close() {
    mainProvider.searchText = '';
    mainProvider.searchProduct('');
    mainProvider.searchShop('');
    WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
    Navigator.pop(context);
  }
}
