import 'package:flutter/material.dart';
import 'package:shoppinglist/providers/main_provider.dart';
import 'package:shoppinglist/utils/utils.dart';

class HistoryLevelTotalWidget extends StatelessWidget {
  final String title;
  final int uds;
  final double amount;
  final bool isLastTotal;
  final Widget? action;
  const HistoryLevelTotalWidget(
      {super.key,
      required this.uds,
      required this.amount,
      required this.title,
      this.isLastTotal = false,
      this.action});

  @override
  Widget build(BuildContext context) {
    MainProvider mainProvider = Provider.of<MainProvider>(context, listen: false);

    return Container(
      padding: isLastTotal
          ? const EdgeInsets.all(18)
          : const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      margin: isLastTotal ? const EdgeInsets.all(16) : null,
      decoration: BoxDecoration(
        color: isLastTotal ? Utils.claro : Utils.medio.withAlpha((255 * 0.1).toInt()),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Utils.medio.withAlpha((255 * 0.5).toInt()), width: 2),
        boxShadow: [
          if (isLastTotal)
            BoxShadow(
              color: Utils.oscuro.withAlpha(0.3.toOpacity),
              offset: Offset(2, 2),
              spreadRadius: 3,
              blurRadius: 3,
            )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (action != null)
                Row(
                  children: [
                    action!,
                    const SizedBox(width: 10),
                  ],
                ),
              Text(
                title,
                style: mainProvider.mainTitleStyle.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Utils.oscuro,
                ),
              ),
            ],
          ),
          Row(
            spacing: 20,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${uds.toStringAsFixed(0)} uds',
                style: mainProvider.itemStyle,
              ),
              Text(
                '${amount.toStringAsFixed(2)}€',
                style: mainProvider.itemStyle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
