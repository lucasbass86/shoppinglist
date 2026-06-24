import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/utils/utils.dart';

class HelpCardWidget extends StatefulWidget {
  final String titulo;
  final Widget info;
  final double infoHeight;
  const HelpCardWidget(
      {super.key, required this.titulo, required this.info, required this.infoHeight});

  @override
  State<HelpCardWidget> createState() => _HelpCardWidgetState();
}

class _HelpCardWidgetState extends State<HelpCardWidget> {
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    MainProvider mainProvider = Provider.of<MainProvider>(context);
    return GestureDetector(
      onTap: () => setState(() {
        isExpanded = !isExpanded;
        if (widget.titulo == 'Cambios en la actualización') {
          mainProvider.updateView = true;
        }
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: isExpanded ? widget.infoHeight : 70,
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Utils.medio,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Utils.oscuro,
            width: 2,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(widget.titulo, style: mainProvider.titleStyle.copyWith(fontSize: 20)),
                      Icon(!isExpanded ? Icons.arrow_drop_down_sharp : Icons.arrow_drop_up_sharp,
                          size: 40, color: Utils.oscuro),
                    ],
                  ),
                  if (!mainProvider.updateView && widget.titulo == 'Cambios en la actualización')
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
                            child: Text('!', style: mainProvider.itemStyle.copyWith(fontSize: 13)),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              if (isExpanded) widget.info,
            ],
          ),
        ),
      ),
    );
  }
}
