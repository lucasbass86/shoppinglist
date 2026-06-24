import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:shoppinglist/utils/utils.dart';

class HistoryLevel1Widget extends StatelessWidget {
  final Widget expansionTitle;
  final List<Widget> children;
  const HistoryLevel1Widget({super.key, required this.expansionTitle, required this.children});

  @override
  Widget build(BuildContext context) {
    return ZoomIn(
      child: Card(
        color: Utils.claro,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 12,
        shadowColor: Utils.medio,
        child: ExpansionTile(
          collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          iconColor: Utils.oscuro,
          collapsedIconColor: Utils.oscuro,
          title: expansionTitle,
          children: children,
        ),
      ),
    );
  }
}
