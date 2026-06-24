import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ScrollVisibilityWidget extends StatefulWidget {
  final Widget child;
  final ScrollController controller;
  final bool isFromUp;

  const ScrollVisibilityWidget({super.key, required this.child, required this.controller, this.isFromUp = true});

  @override
  State<ScrollVisibilityWidget> createState() => _ScrollVisibilityWidgetState();
}

class _ScrollVisibilityWidgetState extends State<ScrollVisibilityWidget> {
  bool isVisible = true;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(listen);
  }

  @override
  void dispose() {
    widget.controller.removeListener(listen);
    super.dispose();
  }

  void listen() {
    final ScrollDirection direction = widget.controller.position.userScrollDirection;
    if (direction == ScrollDirection.forward) {
      show();
    } else if (direction == ScrollDirection.reverse) {
      hide();
    }
  }

  void show() {
    if (!isVisible) {
      setState(() {
        isVisible = true;
      });
    }
  }

  void hide() {
    if (isVisible) {
      setState(() {
        isVisible = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 300),
      offset: isVisible ? Offset.zero : Offset(0, widget.isFromUp ? -1 : 1),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isVisible ? 1 : 0,
        child: Wrap(
          children: [widget.child],
        ),
      ),
    );
  }
}
