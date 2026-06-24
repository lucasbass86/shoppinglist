import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shoppinglist/dialogs/dialogs.dart';
import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/sharedpreferences/preferences.dart';
import 'package:shoppinglist/utils/enums.dart';
import 'package:shoppinglist/utils/utils.dart';
import 'package:shoppinglist/widgets/_widgets.dart';

class SettingsPage extends StatefulWidget {
  static const String routeName = 'SettingsPage';
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late MainProvider mainProvider;

  @override
  void dispose() {
    Preferences.tutorialVisitarConfiguracion = true;
    super.dispose();
  }

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
              _appBar(),
              _desing(),
              _forecast(),
              _products(),
              _data(),
              _aplication(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _appBar() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      expandedHeight: 70,
      pinned: false,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: const TopWidget(
            showBack: true, title: 'Configuración', showCart: false, showHelp: true),
      ),
    );
  }

  Widget _desing() {
    return _settingsContainer(
      title: 'Diseño',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _themes(),
          Divider(color: Utils.oscuro),
          _orderShops(),
        ],
      ),
    );
  }

  Widget _themes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tema', style: mainProvider.titleStyle.copyWith(fontSize: 20)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            BounceInLeft(
              duration: Utils.fadeInDuration,
              child: Column(
                children: [
                  Switch(
                    value: mainProvider.theme == ETheme.verde,
                    onChanged: (value) {
                      setState(() {
                        mainProvider.theme = ETheme.verde;
                        Preferences.theme = 0;
                      });
                    },
                  ),
                  GestureDetector(
                    onTap: () => setState(() {
                      mainProvider.theme = ETheme.verde;
                      Preferences.theme = 0;
                    }),
                    child: Container(
                      width: 80,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Utils.cVerdeClaro,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            BounceInDown(
              duration: Utils.fadeInDuration,
              child: Column(
                children: [
                  Switch(
                    value: mainProvider.theme == ETheme.natural,
                    onChanged: (value) {
                      setState(() {
                        mainProvider.theme = ETheme.natural;
                        Preferences.theme = 1;
                      });
                    },
                  ),
                  GestureDetector(
                    onTap: () => setState(() {
                      mainProvider.theme = ETheme.natural;
                      Preferences.theme = 1;
                    }),
                    child: Container(
                      width: 80,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Utils.cNaturalClaro,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            BounceInUp(
              duration: Utils.fadeInDuration,
              child: Column(
                children: [
                  Switch(
                    value: mainProvider.theme == ETheme.azul,
                    onChanged: (value) {
                      setState(() {
                        mainProvider.theme = ETheme.azul;
                        Preferences.theme = 2;
                      });
                    },
                  ),
                  GestureDetector(
                    onTap: () => setState(() {
                      mainProvider.theme = ETheme.azul;
                      Preferences.theme = 2;
                    }),
                    child: Container(
                      width: 80,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Utils.cAzulClaro,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            BounceInRight(
              duration: Utils.fadeInDuration,
              child: Column(
                children: [
                  Switch(
                    value: mainProvider.theme == ETheme.dark,
                    onChanged: (value) {
                      setState(() {
                        mainProvider.theme = ETheme.dark;
                        Preferences.theme = 3;
                      });
                    },
                  ),
                  GestureDetector(
                    onTap: () => setState(() {
                      mainProvider.theme = ETheme.dark;
                      Preferences.theme = 3;
                    }),
                    child: Container(
                      width: 80,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _orderShops() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Ordenar tiendas', style: mainProvider.titleStyle.copyWith(fontSize: 20)),
        SizedBox(
          width: 130,
          child: DropdownButton(
            isExpanded: true,
            elevation: 16,
            style: TextStyle(fontSize: 20, color: Utils.oscuro),
            dropdownColor: Utils.oscuro,
            borderRadius: BorderRadius.circular(20),
            underline: Container(height: 2),
            value: Preferences.isOrderShopByName ? EOrderShop.name : EOrderShop.use,
            items: EOrderShop.values
                .map((o) => DropdownMenuItem(
                    value: o,
                    child: Text(
                      o.displayName(),
                      style: TextStyle(color: Utils.claro),
                    )))
                .toList(),
            onChanged: (value) {
              setState(() {
                Preferences.isOrderShopByName = value == EOrderShop.name;
                if (Preferences.isOrderShopByName) {
                  mainProvider.shops.sort((a, b) => a.name.compareTo(b.name));
                }
              });
            },
            selectedItemBuilder: (context) {
              return EOrderShop.values.map((p) {
                return DropdownMenuItem(
                  value: p,
                  child: Container(
                    width: 150,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Utils.claro,
                    ),
                    child: Center(
                      child: Text(
                        p.displayName(),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              }).toList();
            },
          ),
        )
      ],
    );
  }

  Widget _forecast() {
    return _settingsContainer(
      title: 'Previsión',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _forecastDays(),
          Divider(color: Utils.oscuro),
          _mostrarPrevision(),
        ],
      ),
    );
  }

  Widget _forecastDays() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Días de previsión', style: mainProvider.titleStyle.copyWith(fontSize: 20)),
        SizedBox(
          width: 100,
          child: DropdownButton(
            isExpanded: true,
            elevation: 16,
            style: TextStyle(fontSize: 20, color: Utils.oscuro),
            dropdownColor: Utils.oscuro,
            borderRadius: BorderRadius.circular(20),
            underline: Container(height: 2),
            value: Preferences.forecastDays,
            items: [0, 1, 2, 3, 4, 5, 6, 7]
                .map(
                  (o) => DropdownMenuItem(
                    value: o,
                    child: Text(
                      o.toString(),
                      style: TextStyle(color: Utils.claro),
                    ),
                  ),
                )
                .toList(),
            onChanged: <int>(value) {
              setState(() {
                Preferences.forecastDays = value;
              });
            },
            selectedItemBuilder: (context) {
              return [0, 1, 2, 3, 4, 5, 6, 7].map((p) {
                return DropdownMenuItem(
                    value: p,
                    child: Container(
                      width: 150,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Utils.claro,
                      ),
                      child: Center(
                        child: Text(
                          p.toString(),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ));
              }).toList();
            },
          ),
        )
      ],
    );
  }

  Widget _mostrarPrevision() {
    return FadeIn(
      duration: Utils.fadeInDuration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Previsión al iniciar', style: mainProvider.titleStyle.copyWith(fontSize: 20)),
          Switch(
            value: Preferences.showForecastOnRun,
            onChanged: (value) {
              setState(() {
                Preferences.showForecastOnRun = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _products() {
    return _settingsContainer(
      title: 'Productos',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _deshacer(),
          Divider(color: Utils.oscuro),
          avisoBarato(),
          Divider(color: Utils.oscuro),
          borrarBusqueda(),
        ],
      ),
    );
  }

  Widget _deshacer() {
    return FadeIn(
      duration: Utils.fadeInDuration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Deshacer carrito', style: mainProvider.titleStyle.copyWith(fontSize: 20)),
          Switch(
            value: Preferences.deshacer,
            onChanged: (value) {
              setState(() {
                Preferences.deshacer = !Preferences.deshacer;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget avisoBarato() {
    return FadeIn(
      duration: Utils.fadeInDuration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Avisar precio más barato', style: mainProvider.titleStyle.copyWith(fontSize: 20)),
          Switch(
            value: mainProvider.avisoBarato,
            onChanged: (value) {
              setState(() {
                mainProvider.avisoBarato = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget borrarBusqueda() {
    return FadeIn(
      duration: Utils.fadeInDuration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Al añadir, borrar busqueda', style: mainProvider.titleStyle.copyWith(fontSize: 20)),
          Switch(
            value: mainProvider.borrarBusqueda,
            onChanged: (value) {
              setState(() {
                mainProvider.borrarBusqueda = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _data() {
    return _settingsContainer(
      title: 'Datos',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _borrarTodo(),
        ],
      ),
    );
  }

  Widget _borrarTodo() {
    return FadeIn(
        duration: Utils.fadeInDuration,
        child: ExpansionTile(
          title: Text('Borrar datos', style: mainProvider.titleStyle),
          backgroundColor: Utils.claro,
          childrenPadding: const EdgeInsets.all(20),
          collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          collapsedIconColor: Utils.oscuro,
          iconColor: Utils.oscuro,
          collapsedBackgroundColor: Utils.claro,
          children: [
            ZoomIn(
              delay: const Duration(milliseconds: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Borrar carrito', style: mainProvider.titleStyle.copyWith(fontSize: 20)),
                  GestureDetector(
                    onTap: () => _deleteCart(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Utils.oscuro,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.delete,
                          color: Utils.claro,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            ZoomIn(
              delay: const Duration(milliseconds: 100),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Borrar precios', style: mainProvider.titleStyle.copyWith(fontSize: 20)),
                  GestureDetector(
                    onTap: () => _deletePrices(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Utils.oscuro,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.delete,
                          color: Utils.claro,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            ZoomIn(
              delay: const Duration(milliseconds: 200),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Borrar histórico', style: mainProvider.titleStyle.copyWith(fontSize: 20)),
                  GestureDetector(
                    onTap: () => _deleteHistory(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Utils.oscuro,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.delete,
                          color: Utils.claro,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            ZoomIn(
              delay: const Duration(milliseconds: 300),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Borrar todos los datos',
                      style: mainProvider.titleStyle.copyWith(fontSize: 20)),
                  GestureDetector(
                    onTap: () => _deleteAll(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Utils.oscuro,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.delete,
                          color: Utils.claro,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  Widget _aplication() {
    return _settingsContainer(
      title: 'Aplicación',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Licencia: ${Preferences.license}', style: mainProvider.itemStyle),
          Divider(color: Utils.oscuro),
          _version(),
        ],
      ),
    );
  }

  Widget _version() {
    return FutureBuilder(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          PackageInfo packageInfo = snapshot.data as PackageInfo;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Versión: ${packageInfo.version}', style: mainProvider.itemStyle),
              Text('Actualizada el 26/05/2025', style: mainProvider.itemStyle),
            ],
          );
        } else {
          return Text('Versión:', style: mainProvider.titleStyle);
        }
      },
    );
  }

  Widget _settingsContainer({required String title, required Widget child}) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: mainProvider.titleStyle.copyWith(fontSize: 25)),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Utils.claro,
                borderRadius: BorderRadius.circular(20),
              ),
              child: child,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteAll(BuildContext context) async {
    final confirmed = await confirmDeleteAll(context);
    if (confirmed && context.mounted) {
      final unlock =
          await showSlideToUnlock(context, backColor: Utils.medio, slideColor: Utils.oscuro);
      if (unlock && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(Utils.snackBar('Borrado . . .', isGood: false));
        mainProvider.cart.clear();
        mainProvider.productsShops.clear();
        mainProvider.shops.clear();
        mainProvider.products.clear();
        mainProvider.filter.clear();
        mainProvider.filterShops.clear();
        mainProvider.shoppingHistory.clear();
        mainProvider.pricesHistory.clear();

        Utils.boxProducts.deleteAll(Utils.boxProducts.keys);
        Utils.boxShops.deleteAll(Utils.boxShops.keys);
        Utils.boxPrices.deleteAll(Utils.boxPrices.keys);
        Utils.boxCart.deleteAll(Utils.boxCart.keys);
        Utils.boxShoppingHistory.deleteAll(Utils.boxShoppingHistory.keys);
        Utils.boxHistoryPrice.deleteAll(Utils.boxHistoryPrice.keys);

        mainProvider.updateMainProvider();
      }
    }
  }

  Future<void> _deletePrices(BuildContext context) async {
    final confirmed = await confirmDeleteAll(context);
    if (confirmed && context.mounted) {
      final unlock =
          await showSlideToUnlock(context, backColor: Utils.medio, slideColor: Utils.oscuro);
      if (unlock && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(Utils.snackBar('Borrado . . .', isGood: false));
        mainProvider.productsShops.clear();
        mainProvider.pricesHistory.clear();
        Utils.boxPrices.deleteAll(Utils.boxPrices.keys);
        Utils.boxHistoryPrice.deleteAll(Utils.boxHistoryPrice.keys);
        mainProvider.updateMainProvider();
      }
    }
  }

  Future<void> _deleteHistory(BuildContext context) async {
    final confirmed = await confirmDeleteAll(context);
    if (confirmed && context.mounted) {
      final unlock =
          await showSlideToUnlock(context, backColor: Utils.medio, slideColor: Utils.oscuro);
      if (unlock && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(Utils.snackBar('Borrado . . .', isGood: false));
        mainProvider.shoppingHistory.clear();
        Utils.boxShoppingHistory.deleteAll(Utils.boxShoppingHistory.keys);
        mainProvider.updateMainProvider();
      }
    }
  }

  Future<void> _deleteCart(BuildContext context) async {
    final confirmed = await confirmDeleteAll(context);
    if (confirmed && context.mounted) {
      final unlock =
          await showSlideToUnlock(context, backColor: Utils.medio, slideColor: Utils.oscuro);
      if (unlock && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(Utils.snackBar('Borrado . . .', isGood: false));
        mainProvider.cart.clear();
        Utils.boxCart.deleteAll(Utils.boxCart.keys);
        mainProvider.updateMainProvider();
      }
    }
  }
}
