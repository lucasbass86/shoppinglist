import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shoppinglist/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdatePage extends StatelessWidget {
  static const String routeName = 'UpdatePage';
  const UpdatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: SvgPicture.asset('assets/svg/update.svg')),
          Container(
            margin: const EdgeInsets.only(bottom: 80),
            height: 40,
            child: Center(
              child: Text(
                'Existe una versión más reciente',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Utils.medio),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              !await launchUrl(
                Uri.parse(Utils.urlUpdatePath),
                mode: LaunchMode.externalApplication,
              );
            },
            child: Container(
              height: 50,
              margin: const EdgeInsets.only(left: 40, right: 40, bottom: 40),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Utils.medio,
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Center(
                child: Text('Aceptar'),
              ),
            ),
          )
        ],
      ),
    );
  }
}
