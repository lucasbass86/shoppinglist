import 'package:flutter/material.dart';
import 'package:shoppinglist/dialogs/dialogs.dart';
import 'package:shoppinglist/models/models.dart';
import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/utils/utils.dart';

class StatisticsProductListWidget extends StatelessWidget {
  final GroupGraphic principal;
  final ProductShop productShop;
  const StatisticsProductListWidget(
      {super.key, required this.principal, required this.productShop});

  @override
  Widget build(BuildContext context) {
    MainProvider mainProvider = Provider.of<MainProvider>(context, listen: false);

    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(left: 5, right: 5),
      // decoration: BoxDecoration(
      //   color: Utils.claro,
      //   borderRadius: BorderRadius.circular(20),
      // ),
      decoration: BoxDecoration(
        color: Utils.oscuro.withAlpha(100),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Utils.claro),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 10,
            children: [
              Image.asset(Utils.assetShop, width: 30, height: 30),
              Text(principal.shop.name, style: TextStyle(color: Utils.claro, fontSize: 21)),
            ],
          ),
          const SizedBox(height: 10),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: principal.list.length,
            shrinkWrap: true,
            itemBuilder: (context, index2) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Dismissible(
                  key: Key(principal.list[index2].historicoPrecio.id.toString()),
                  background: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red[300]),
                      Icon(Icons.edit, size: 20, color: Colors.green[300]),
                    ],
                  ),
                  confirmDismiss: (direction) async {
                    bool ret = true;

                    if (direction == DismissDirection.startToEnd) {
                      await showMessage(
                              context: context, message: '¿Borrar el precio?', cancel: true)
                          .then((value) {
                        if (value) {
                          ret = true;
                          mainProvider
                              .deleteHistoricoPrecio(principal.list[index2].historicoPrecio);
                        } else {
                          ret = false;
                        }
                      });
                    } else {
                      DateTime? date = principal.list[index2].historicoPrecio.fecha;
                      final c = await showProductPrice(context, productShop);
                      if (c[0] && context.mounted) {
                        final value = await showDate(context, initialDate: date);
                        if (value != null) {
                          date = DateTime(value.year, value.month, value.day,
                              DateTime.now().hour + 1, DateTime.now().minute);
                        }
                        mainProvider.calculateAmount();
                        principal.list[index2].historicoPrecio.fecha = date;
                        principal.list[index2].historicoPrecio.productShop.price = c[1];
                        mainProvider.updateHistoricoPrecio(principal.list[index2].historicoPrecio);
                        ret = true;
                      }
                      ret = false;
                    }
                    // setState(() {});
                    return ret;
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        Utils.dateEnglishToSpanish(
                            principal.list[index2].historicoPrecio.fecha.toString(),
                            showTime: false),
                        style: TextStyle(color: Utils.claro, fontSize: 17),
                      ),
                      Text(
                        '${principal.list[index2].historicoPrecio.productShop.price.toStringAsFixed(2)} €',
                        style: TextStyle(color: Utils.claro, fontSize: 17),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
