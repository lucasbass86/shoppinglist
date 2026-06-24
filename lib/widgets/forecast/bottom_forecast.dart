import 'package:flutter/material.dart';
import 'package:shoppinglist/models/models.dart';
import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/utils/utils.dart';
import 'package:shoppinglist/widgets/_widgets.dart';

class BottomForecastWidget extends StatelessWidget {
  const BottomForecastWidget({super.key});

  @override
  Widget build(BuildContext context) {
    MainProvider mainProvider = Provider.of<MainProvider>(context, listen: false);
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
    return ClipRRect(
      borderRadius: BorderRadiusGeometry.circular(40),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          children: [
            Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Utils.oscuro),
                ),
                child: Text('Previsión de compra', style: mainProvider.titleStyle)),
            const SizedBox(height: 20),
            ListView.separated(
              physics: const ClampingScrollPhysics(),
              shrinkWrap: true,
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
                  child: ForecastWidget(entry: entry),
                );
              },
              separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 10),
            ),
          ],
        ),
      ),
    );
  }
}
