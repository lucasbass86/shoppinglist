import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shoppinglist/pages/_pages.dart';
import 'package:shoppinglist/sharedpreferences/preferences.dart';
import 'package:shoppinglist/utils/utils.dart';

class WelcomePage extends StatefulWidget {
  static const String routeName = 'WelcomePage';
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  PageController pageController = PageController();
  int indexPage = 0;
  final int numPags = 4;
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
                          Expanded(child: SvgPicture.asset('assets/svg/idea.svg')),
                          texto('Vamos a organizar nuestro carro de la compra!'),
                        ],
                      ),
                      Column(
                        children: [
                          Expanded(child: SvgPicture.asset('assets/svg/shopping.svg')),
                          texto('Podrás guardar los precios de cada tienda.'),
                        ],
                      ),
                      Column(
                        children: [
                          Expanded(child: SvgPicture.asset('assets/svg/checklist.svg')),
                          texto('Saber qúe y dónde comprar'),
                        ],
                      ),
                      Column(
                        children: [
                          Expanded(child: SvgPicture.asset('assets/svg/completed.svg')),
                          texto('Empecemos!'),
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
                child: Text('Omitir', style: TextStyle(fontWeight: FontWeight.bold, color: Utils.claro)),
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
    String msg = '';
    switch (indexPage) {
      case 0:
        msg = 'Iniciar';
        break;
      case 1:
        msg = 'Continuar';
        break;
      case 2:
        msg = 'Avanzar';
        break;
      case 3:
        msg = 'Terminar';
        break;
    }
    return GestureDetector(
      onTap: () {
        if (indexPage < numPags - 1) {
          setState(() {
            indexPage++;
            pageController.animateToPage(indexPage, duration: const Duration(milliseconds: 500), curve: Curves.easeInCubic);
          });
        } else {
          avanzar();
        }
      },
      child: Container(
        height: 50,
        margin: const EdgeInsets.only(left: 40, right: 40, bottom: 20),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Utils.medio,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Center(
          child: Text(msg),
        ),
      ),
    );
  }

  void avanzar() {
    Preferences.welcomePage = true;
    Navigator.popAndPushNamed(context, TutorialPage.routeName);
  }
}
