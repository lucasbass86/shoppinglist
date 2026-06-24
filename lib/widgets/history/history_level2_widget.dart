import 'package:flutter/material.dart';
import 'package:shoppinglist/utils/utils.dart';

class HistoryLevel2Widget extends StatelessWidget {
  final Widget expansionTitle;
  final List<Widget> children;
  const HistoryLevel2Widget({super.key, required this.expansionTitle, required this.children});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: ExpansionTile(
        iconColor: Utils.medio,
        collapsedIconColor: Utils.medio,
        backgroundColor: Utils.medio.withAlpha(100),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        title: expansionTitle,
        children: children,
      ),
    );
  }
}
