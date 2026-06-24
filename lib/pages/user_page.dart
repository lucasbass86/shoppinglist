import 'dart:convert';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:shoppinglist/dialogs/dialogs.dart';
import 'package:shoppinglist/models/models.dart';
import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/services/backup_service.dart';
import 'package:shoppinglist/sharedpreferences/preferences.dart';
import 'package:shoppinglist/utils/utils.dart';
import 'package:shoppinglist/widgets/_widgets.dart';

class UserPage extends StatefulWidget {
  static const String routeName = 'UserPage';
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late MainProvider mainProvider;
  late TextEditingController emailController;

  @override
  Widget build(BuildContext context) {
    emailController = TextEditingController(text: Preferences.email);
    mainProvider = Provider.of<MainProvider>(context, listen: false);
    return Scaffold(
      body: Stack(
        children: [
          BackgroundWidget(),
          CustomScrollView(physics: const BouncingScrollPhysics(), slivers: [
            SliverAppBar(
              pinned: false,
              expandedHeight: 60,
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                background:
                    TopWidget(showBack: true, title: 'Usuario', showCart: false, showExit: true),
              ),
            ),
            FutureBuilder(
              future: Utils.checkConnection(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  bool resp = snapshot.data as bool;
                  if (resp) {
                    return _backUp(context);
                  } else {
                    return _noConnection();
                  }
                } else {
                  return SliverToBoxAdapter(child: CircularProgressIndicator());
                }
              },
            ),
            _localData(),
          ]),
        ],
      ),
    );
  }

  Widget _noConnection() {
    return SliverToBoxAdapter(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, size: Utils.iconSizeBig, color: Utils.medio),
          Text('No hay conexión', style: mainProvider.titleStyle),
        ],
      ),
    );
  }

  Widget _backUp(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Datos Internet', style: mainProvider.titleStyle.copyWith(fontSize: 25)),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Utils.medio,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Email para las copias', style: mainProvider.itemStyle),
                  SizedBox(height: 20),
                  ZoomIn(
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 45,
                            margin: const EdgeInsets.only(right: 40),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: TextFormField(
                              cursorColor: Utils.oscuro,
                              controller: emailController,
                              enabled: Preferences.email.isEmpty,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.email),
                                border: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                hintText: 'Email . . .',
                                hintStyle: TextStyle(fontSize: 15.0, color: Utils.medio),
                                isCollapsed: true,
                              ),
                              keyboardType: TextInputType.emailAddress,
                              style: mainProvider.itemStyle,
                            ),
                          ),
                        ),
                        if (Preferences.email.isEmpty)
                          GestureDetector(
                            onTap: () async {
                              if (emailController.text.isEmpty) {
                                _showSnackBar('Introduce el email');
                              } else {
                                final pass = await password(context);

                                if (!pass[0]) return;

                                if (!context.mounted) return;

                                final pass2 = await password(context, title: 'Repite password');

                                if (!context.mounted || pass == null || pass.isEmpty || !pass[0]) {
                                  return;
                                }

                                if (pass[1] != pass2[1]) {
                                  _showSnackBar('Las contraseñas no coinciden', isGood: false);
                                  return;
                                }

                                _showSnackBar('Email guardado');
                                Preferences.email = emailController.text;
                                Preferences.passBackUp = pass[1];
                                FocusManager.instance.primaryFocus?.unfocus();
                                setState(() {});
                              }
                            },
                            child:
                                Icon(Icons.save, size: Utils.iconSizeStandar, color: Utils.oscuro),
                          ),
                        if (Preferences.email.isNotEmpty)
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () async {
                                  final resp = await showMessage(
                                      context: context, message: '¿Quitar el email?', cancel: true);
                                  if (resp) {
                                    Preferences.email = '';
                                    Preferences.backUp = '';
                                    Preferences.passBackUp = '';
                                    setState(() {});
                                  }
                                },
                                child: Icon(
                                  Icons.emergency_rounded,
                                  size: Utils.iconSizeStandar,
                                  color: Utils.oscuro,
                                  semanticLabel: 'Eliminar el email',
                                )),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40),
                  if (Preferences.email.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _uploadDataToInternet(context),
                        _downloadFromInternet(context),
                        FadeInRight(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () async {
                                await showMessage(
                                        context: context,
                                        message: '¿Borrar todos los datos de la copia?',
                                        cancel: true)
                                    .then(
                                  (value) {
                                    if (value && context.mounted) {
                                      showSlideToUnlock(context,
                                              backColor: Utils.medio, slideColor: Utils.oscuro)
                                          .then((unlock) {
                                        if (unlock) {
                                          BackupService.deleteBackUp(emailController.text)
                                              .then((_) {
                                            Preferences.email = '';
                                            Preferences.backUp = '';
                                            Preferences.passBackUp = '';
                                            setState(() {});
                                            _showSnackBar('Datos borrados');
                                          });
                                        }
                                      });
                                    }
                                  },
                                );
                              },
                              child: Icon(Icons.delete,
                                  size: Utils.iconSizeStandar, color: Utils.oscuro),
                            ),
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: 40),
                  Text(
                    'Última copia: ${Preferences.backUp.isEmpty ? '--/--/----' : Utils.dateEnglishToSpanish(Preferences.backUp)}',
                    style: mainProvider.titleStyle.copyWith(fontSize: 17),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _uploadDataToInternet(BuildContext context) {
    return FadeInLeft(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            showSlideToUnlock(context, backColor: Utils.medio, slideColor: Utils.oscuro)
                .then((res) {
              if (res) {
                User user = User(
                  email: emailController.text,
                  password: Preferences.passBackUp,
                  products: mainProvider.products,
                  shops: mainProvider.shops,
                  shoppingHistory: mainProvider.shoppingHistory,
                  priceHistory: mainProvider.pricesHistory,
                  productShops: mainProvider.productsShops,
                );
                BackupService.addBackUp(user).then((onValue) {
                  _showSnackBar('Copia subida');
                  Preferences.backUp = DateTime.now().toString();
                  setState(() {});
                });
              }
            });
          },
          child: Ink(
            width: 140,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Utils.claro,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text('Subir datos', style: mainProvider.itemStyle),
                const SizedBox(height: 5),
                Icon(
                  Icons.backup_sharp,
                  size: Utils.iconSizeStandar,
                  color: Utils.medio,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _downloadFromInternet(BuildContext context) {
    return FadeInRight(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            if (emailController.text.isNotEmpty) {
              User? user = await BackupService.getBackUp(emailController.text);
              if (!context.mounted) return;
              final passResult = await password(context);
              if (passResult[1] != Preferences.passBackUp && passResult[1] != user!.password) {
                _showSnackBar('Contraseña incorrecta', isGood: false);
                return;
              }

              if (context.mounted) {
                final confirmed = await showMessage(
                    context: context,
                    message: 'Si hay datos, estos se sustituirán. ¿Sustituir?',
                    cancel: true);
                if (confirmed && context.mounted) {
                  final unlock = await showSlideToUnlock(context,
                      backColor: Utils.medio, slideColor: Utils.oscuro);
                  if (unlock && context.mounted) {
                    _setData(context, user!);
                  }
                } else {
                  _showSnackBar('Proceso omitido');
                }
              } else {
                _showSnackBar('Email no encontrado', isGood: false);
              }
            } else {
              _showSnackBar('Introduce el correo', isGood: false);
            }
          },
          child: Ink(
            width: 140,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Utils.claro,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text('Cargar datos', style: mainProvider.itemStyle),
                const SizedBox(height: 5),
                Icon(
                  Icons.restore,
                  size: Utils.iconSizeStandar,
                  color: Utils.medio,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _localData() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Datos Locales', style: mainProvider.titleStyle.copyWith(fontSize: 25)),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Utils.medio,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _saveButton(context),
                  _loadButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _saveButton(BuildContext context) {
    return FadeInDown(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            User user = User(
              email: emailController.text,
              password: Preferences.passBackUp,
              products: mainProvider.products,
              shops: mainProvider.shops,
              shoppingHistory: mainProvider.shoppingHistory,
              priceHistory: mainProvider.pricesHistory,
              productShops: mainProvider.productsShops,
            );
            final contenido = json.encode(user.toJson());
            Utils.guardarArchivoEnDescargas(
                    'ShoppingList save ${Utils.dateEnglishToSpanish(DateTime.now().toString(), showTime: false)}.json',
                    contenido)
                .then((onValue) {
              if (onValue) {
                _showSnackBar('Archivo descargado');
              } else {
                _showSnackBar('Algo ha fallado . . .', isGood: false);
              }
            });
          },
          child: Ink(
            width: 140,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Utils.claro,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text('Guardar', style: mainProvider.itemStyle),
                const SizedBox(height: 5),
                Icon(
                  Icons.save_alt_rounded,
                  size: Utils.iconSizeStandar,
                  color: Utils.medio,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _loadButton(BuildContext context) {
    return FadeInUp(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Utils.seleccionarArchivo().then((onValue) async {
              if (onValue.isNotEmpty && context.mounted) {
                await showMessage(context: context, message: '¿Restaurar archivo?').then((res) {
                  if (res && context.mounted) {
                    showSlideToUnlock(context, backColor: Utils.medio, slideColor: Utils.oscuro)
                        .then((unlock) async {
                      if (unlock) {
                        final Map<String, dynamic> dataJson = json.decode(onValue);
                        User user = User.fromJson(dataJson);
                        if (context.mounted) {
                          _setData(context, user);
                        }
                      }
                    });
                  } else {
                    _showSnackBar('Algo ha fallado . . .', isGood: false);
                  }
                });
              }
            });
          },
          child: Ink(
            width: 140,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Utils.claro,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text('Cargar', style: mainProvider.itemStyle),
                const SizedBox(height: 5),
                Icon(
                  Icons.restart_alt_rounded,
                  size: Utils.iconSizeStandar,
                  color: Utils.medio,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _setData(BuildContext context, User user) async {
    mainProvider.products = user.products;
    mainProvider.shops = user.shops;
    mainProvider.productsShops = user.productShops;
    mainProvider.shoppingHistory = user.shoppingHistory;
    mainProvider.pricesHistory = user.priceHistory;

    await Utils.boxProducts.deleteAll(Utils.boxProducts.keys);
    await Utils.boxShops.deleteAll(Utils.boxShops.keys);
    await Utils.boxPrices.deleteAll(Utils.boxPrices.keys);
    await Utils.boxCart.deleteAll(Utils.boxCart.keys);
    await Utils.boxShoppingHistory.deleteAll(Utils.boxShoppingHistory.keys);
    await Utils.boxHistoryPrice.deleteAll(Utils.boxHistoryPrice.keys);

    for (Product p in user.products) {
      await Utils.boxProducts.put(p.id, p.toJson());
    }
    for (Shop s in user.shops) {
      await Utils.boxShops.put(s.id, s.toJson());
    }
    for (ProductShop s in user.productShops) {
      await Utils.boxPrices.put(s.id, s.toJson());
    }
    for (PriceHistory s in user.priceHistory) {
      await Utils.boxHistoryPrice.put(s.id, s.toJson());
    }
    for (ShoppingHistory s in user.shoppingHistory) {
      await Utils.boxShoppingHistory.put(s.id, s.toJson());
    }

    _showSnackBar('Datos cargados');
  }

  void _showSnackBar(String message, {bool isGood = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(Utils.snackBar(message, isGood: isGood));
  }
}
