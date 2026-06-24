import 'package:flutter/material.dart';
import 'package:shoppinglist/utils/utils.dart';

class HistoryLevel3Widget extends StatelessWidget {
  final Widget expansionTitle;
  final List<Widget> children;
  const HistoryLevel3Widget({super.key, required this.expansionTitle, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Utils.claro,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 12,
      shadowColor: Utils.medio,
      child: ExpansionTile(
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        iconColor: Utils.medio,
        collapsedIconColor: Utils.medio,
        childrenPadding: const EdgeInsets.all(10),
        title: expansionTitle,
        children: children,
      ),
    );
  }
}
