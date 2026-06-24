import 'package:flutter/material.dart';
import 'package:shoppinglist/dialogs/dialogs.dart';
import 'package:shoppinglist/models/models.dart';
import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/utils/enums.dart';
import 'package:shoppinglist/utils/utils.dart';
import 'package:shoppinglist/widgets/_widgets.dart';

class ForecastHiddenPage extends StatelessWidget {
  static const String routeName = 'ForecastHiddenPage';
  const ForecastHiddenPage({super.key});

  @override
  Widget build(BuildContext context) {
    MainProvider mainProvider = Provider.of(context);
    return Scaffold(
      body: Stack(
        children: [
          const BackgroundWidget(),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: TopWidget(
                  title: 'Ocultos',
                  showBack: true,
                  showCart: false,
                ),
              ),
              if (mainProvider.hiddenForecast.isEmpty) _noHidden(mainProvider),
              if (mainProvider.hiddenForecast.isNotEmpty) _sliverList(mainProvider),
            ],
          ),
        ],
      ),
    );
  }

  Widget _noHidden(MainProvider mainProvider) {
    return SliverFillRemaining(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('No hay ocultos', style: mainProvider.titleStyle),
            const SizedBox(height: 20),
            Icon(Icons.hide_source_rounded, size: 100, color: Utils.medio),
          ],
        ),
      ),
    );
  }

  Widget _sliverList(MainProvider mainProvider) {
    return SliverList.separated(
      itemCount: mainProvider.hiddenForecast.length,
      itemBuilder: (context, index) {
        Product product = mainProvider.hiddenForecast[index];
        return Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Utils.claro,
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListTile(
            leading: Image(image: product.imageType.image()),
            title: MarqueeWidget(
              child: Text(product.name, style: mainProvider.titleStyle.copyWith(fontSize: 20)),
            ),
            trailing: Material(
              color: Colors.transparent,
              child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () async {
                    final res = await showMessage(
                        context: context,
                        message: '¿Mostrar el producto en las previsiones?',
                        cancel: true);
                    if (res) {
                      mainProvider.removeHiddenForecast(product);
                    }
                  },
                  child: Icon(
                    Icons.remove_red_eye_rounded,
                    color: Utils.oscuro,
                    size: Utils.iconSizeStandar,
                  )),
            ),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 10),
    );
  }
}
