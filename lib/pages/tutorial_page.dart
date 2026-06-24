import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shoppinglist/pages/_pages.dart';
import 'package:shoppinglist/sharedpreferences/preferences.dart';
import 'package:shoppinglist/utils/utils.dart';

class TutorialPage extends StatefulWidget {
  static const String routeName = 'TutorialPage';
  const TutorialPage({super.key});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  PageController pageController = PageController();
  int indexPage = 0;
  final int numPags = 4;
  double iconSize = 80;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: PageView(
                    physics: const BouncingScrollPhysics(),
                    controller: pageController,
                    onPageChanged: (value) {
                      if (value == numPags) {
                        avanzar();
                      } else {
                        setState(() {
                          indexPage = value;
                        });
                      }
                    },
                    children: [
                      Column(
                        children: [
                          Expanded(
                            child: SvgPicture.asset('assets/svg/tutorial2.svg'),
                          ),
                          texto('1º - Indicaremos algunos productos'),
                        ],
                      ),
                      Column(
                        children: [
                          Expanded(
                            child: SvgPicture.asset('assets/svg/tutorial1.svg'),
                          ),
                          texto('2º - Daremos de alta alguna tienda.'),
                        ],
                      ),
                      Column(
                        children: [
                          Expanded(
                            child: SvgPicture.asset('assets/svg/tutorial3.svg'),
                          ),
                          texto('3º - Podremos echar un vistazo a nuestro carrito'),
                        ],
                      ),
                      Column(
                        children: [
                          Expanded(
                            child: SvgPicture.asset('assets/svg/tutorial4.svg'),
                          ),
                          texto('4º - Configuraremos nuestra App'),
                        ],
                      ),
                      Container(),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                puntitos(),
                button(),
              ],
            ),
            Positioned(
              right: 10,
              top: 10,
              child: GestureDetector(
                onTap: () => avanzar(),
                child: Text('Omitir tutorial', style: TextStyle(fontWeight: FontWeight.bold, color: Utils.claro)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget texto(String msg) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(),
      child: Center(
        child: Text(msg, style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Utils.medio), textAlign: TextAlign.center),
      ),
    );
  }

  Widget puntitos() {
    return Center(
      child: Container(
        height: 15,
        margin: const EdgeInsets.only(bottom: 40),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: numPags,
          itemBuilder: (context, index) {
            return Container(
              width: indexPage == index ? 30 : 15,
              height: 15,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: Utils.claro,
                borderRadius: BorderRadius.circular(20),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget button() {
    return GestureDetector(
      onTap: changePage,
      child: Container(
        height: 50,
        margin: const EdgeInsets.only(left: 40, right: 40, bottom: 20),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Utils.medio,
          borderRadius: BorderRadius.circular(40),
        ),
        child: const Center(
          child: Text('Siguiente'),
        ),
      ),
    );
  }

  void changePage() {
    if (indexPage == 0 && !Preferences.tutorialCrearProducto) {
      Navigator.pushNamed(context, ProductsPage.routeName);
    } else if (indexPage == 1 && !Preferences.tutorialCrearTienda) {
      Navigator.pushNamed(context, ShopsPage.routeName);
    } else if (indexPage == 2 && !Preferences.tutorialVisitarCarrito) {
      Navigator.pushNamed(context, CartPage.routeName);
    } else if (indexPage == 3 && !Preferences.tutorialVisitarConfiguracion) {
      Navigator.pushNamed(context, SettingsPage.routeName);
    } else {
      if (indexPage < numPags - 1) {
        setState(() {
          indexPage++;
          pageController.animateToPage(indexPage, duration: const Duration(milliseconds: 500), curve: Curves.easeInCubic);
        });
      } else {
        avanzar();
      }
    }
  }

  void avanzar() {
    Preferences.tutorialPage = true;
    Navigator.popAndPushNamed(context, HomePage.routeName);
  }
}
