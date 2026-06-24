// ignore_for_file: use_build_context_synchronously

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shoppinglist/dialogs/dialogs.dart';
import 'package:shoppinglist/models/versiones_model.dart';
import 'package:shoppinglist/pages/_pages.dart';
import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/services/license_service.dart';
import 'package:shoppinglist/services/update_service.dart';
import 'package:shoppinglist/sharedpreferences/preferences.dart';
import 'package:shoppinglist/utils/utils.dart';
import 'package:shoppinglist/widgets/_widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';

class HomePage extends StatefulWidget {
  static const String routeName = 'HomePage';
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _heartController;
  bool _hasRun = false;

  @override
  void initState() {
    super.initState();
    if (!_hasRun) {
      _hasRun = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(seconds: 1), () async {
          if (context.mounted) {
            await _checkLicense(context);
            await _checkUpdates(context);
            await _checkBackUp(context);
          }
        });
      });
      Future.delayed(const Duration(milliseconds: 1500)).then((_) => _showForecast());
    }

    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  int counter = 0;
  bool canTap = true;
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    Utils.homeIconImageSize = screenWidth * 110 ~/ 411;
    // Utils.productImageSize = screenWidth * 100 ~/ 411; //800 tablet
    Utils.productImageSize = screenWidth * (screenWidth > 450 ? 100 : 70) ~/ 411; //800 tablet
    Utils.iconSizeSelected = screenWidth < 500 ? Utils.iconSizeStandar : Utils.iconSizeBig;
    return Scaffold(
      body: Stack(
        children: [
          const BackgroundWidget(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  const TopWidget(
                      title: 'Hola de nuevo!', showBack: false, showCart: false, showExit: true),
                  Container(
                    margin: const EdgeInsets.only(right: 80),
                    width: 300,
                    height: 60,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (canTap) {
                          setState(() {
                            counter++;
                            if (counter == 7) {
                              canTap = false;
                            }
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: Stack(
                    children: [
                      GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: 2,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          FadeIn(
                            duration: Utils.fadeInDuration,
                            child: const MenuHomeWidget(
                                name: 'Productos',
                                asset: 'assets/genericos/genProducto.png',
                                route: ProductsPage.routeName),
                          ),
                          FadeIn(
                            duration: Utils.fadeInDuration,
                            child: const MenuHomeWidget(
                                name: 'Tiendas',
                                asset: Utils.assetShop,
                                route: ShopsPage.routeName),
                          ),
                          FadeIn(
                            duration: Utils.fadeInDuration,
                            child: const MenuHomeWidget(
                                name: 'Cesta',
                                asset: 'assets/cesta.png',
                                route: CartPage.routeName),
                          ),
                          FadeIn(
                            duration: Utils.fadeInDuration,
                            child: const MenuHomeWidget(
                                name: 'Historial',
                                asset: 'assets/graphic.png',
                                route: HistoryPage.routeName),
                          ),
                          FadeIn(
                            duration: Utils.fadeInDuration,
                            child: const MenuHomeWidget(
                                name: 'Usuario',
                                asset: 'assets/dinosaurio.png',
                                route: UserPage.routeName),
                          ),
                          FadeIn(
                            duration: Utils.fadeInDuration,
                            child: const MenuHomeWidget(
                                name: 'Configuración',
                                asset: 'assets/configuracion.png',
                                route: SettingsPage.routeName),
                          ),
                        ],
                      ),
                      if (counter == 7)
                        GestureDetector(
                          onLongPress: () {
                            setState(() {
                              counter = 0;
                              canTap = true;
                            });
                          },
                          child: ZoomIn(
                            child: RotationTransition(
                              turns: _heartController,
                              child: const Icon(
                                Icons.favorite,
                                size: 400,
                                color: Colors.red,
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
        ],
      ),
    );
  }

  void _showForecast() {
    if (Preferences.showForecastOnRun) {
      showModalBottomSheet(
          backgroundColor: Utils.medio,
          context: context,
          builder: (context) => BottomForecastWidget());
    }
  }

  Future<void> _checkLicense(BuildContext context) async {
    final cnx = await Utils.checkConnection();
    // Preferences.license = '';
    if (cnx && Preferences.license.isEmpty) {
      if (context.mounted) {
        final em = await showDialogInput(context,
            subtitle: 'Se envía un código de verificación para registrarse.',
            label: 'Email',
            inputType: TextInputType.emailAddress);
        if (em[0]) {
          final GetLicenseCodeResponse r = await LicenseService.obtainLicense(em[1]);
          if (r.status == LicenseService.success && context.mounted) {
            final code = await showDialogInput(context,
                label: 'Código', subtitle: 'Introduce el código de verificación', maxLength: 13);
            if (code[0]) {
              final GetLicenseCodeResponse r2 = await LicenseService.setLicenseCode(code[1], em[1]);
              if (r2.status == LicenseService.success && context.mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(Utils.snackBar('Registrado correctamente'));
                Preferences.license = code[1];
                Preferences.email = em[1];
              }
            } else {
              SystemNavigator.pop();
            }
          }
        } else {
          SystemNavigator.pop();
        }
      }
    } else if (cnx && Preferences.license.isNotEmpty) {
      final GetLicenseCodeResponse r = await LicenseService.checkLicenseCode(Preferences.license);
      if (r.status == LicenseService.success) {
        MapData licenseData = r.data as MapData;
        if (licenseData.license != null) {
          if (licenseData.license!.locked == 1) {
            if (context.mounted) {
              await showMessage(
                      context: context,
                      message:
                          'Esta licencia está bloqueada. Contacta con ${LicenseService.emailDev}')
                  .then((_) {
                SystemNavigator.pop();
              });
            }
          }
          if (licenseData.license!.message.isNotEmpty) {
            if (context.mounted) {
              await showMessage(context: context, message: licenseData.license!.message);
            }
          }
        }
      } else {
        if (context.mounted) {
          await showMessage(
                  context: context,
                  message:
                      'Ha habido un problema con la licencia. Contacta con ${LicenseService.emailDev}')
              .then((_) {
            SystemNavigator.pop();
          });
        }
      }
    } else if (!cnx && Preferences.license.isEmpty) {
      if (context.mounted) {
        await showMessage(
                context: context, message: 'Necesita tener conexión para verificar la licencia')
            .then((_) {
          SystemNavigator.pop();
        });
      }
    }
  }

  Future<void> _checkBackUp(BuildContext context) async {
    final navigator = Navigator.of(context);
    if (Preferences.backUp.isNotEmpty && Utils.boxProducts.values.isNotEmpty) {
      if (DateTime.now().difference(DateTime.parse(Preferences.backUp)).inDays >= 15) {
        final resp = await showMessage(
            context: context,
            message: 'Llevas ciertos días sin hacer copia de seguridad. ¿Hacer copia?',
            cancel: true);
        if (resp) {
          navigator.pushNamed(UserPage.routeName);
        }
      }
    }
  }

  // Future<void> _checkUpdates(BuildContext context) async {
  //   late PackageInfo packageInfo;
  //   final hasConnected = await Utils.checkConnection();
  //   if (hasConnected) {
  //     PackageInfo.fromPlatform().then((value) async {
  //       packageInfo = value;
  //       if (!context.mounted) return;
  //       final version = await Provider.of<UpdateService>(context, listen: false).getVersiones();
  //       if (version.isNotEmpty) {
  //         if (version
  //                 .firstWhere((v) => v.appname == 'shoppinglist')
  //                 .appversion
  //                 .compareTo(packageInfo.version) !=
  //             0) {
  //           if (context.mounted) {
  //             Navigator.pushNamed(context, UpdatePage.routeName);
  //             Provider.of<MainProvider>(context, listen: false).updateView = false;
  //           }
  //         }
  //       }
  //     });
  //   }
  // }
  Future<void> _checkUpdates(BuildContext context) async {
    late PackageInfo packageInfo;
    final hasConnected = await Utils.checkConnection();
    if (hasConnected) {
      PackageInfo.fromPlatform().then((value) async {
        packageInfo = value;
        if (!context.mounted) return;
        final version = await Provider.of<UpdateService>(context, listen: false).getVersiones();
        if (version.isNotEmpty) {
          Versiones v = version
              .firstWhere((v) => v.appname.toUpperCase() == UpdateService.appName.toUpperCase());
          UpdateService.urlUpdatePath = v.appurl;
          if (int.parse(packageInfo.version.replaceAll('.', '')) <
              int.parse(v.appversion.replaceAll('.', ''))) {
            if (context.mounted) {
              Navigator.pushNamed(context, UpdatePage.routeName);
            }
          }
        }
      });
    }
  }
}
