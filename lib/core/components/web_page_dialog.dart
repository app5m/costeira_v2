import 'package:costeira/core/components/web_dialog_frame.dart';
import 'package:flutter/material.dart';

class WebPageDialog extends StatelessWidget {
  const WebPageDialog({
    super.key,
    required this.title,
    required this.child,
    this.width = 700,
    this.maxHeight = 760,
  });

  final String title;
  final Widget child;
  final double width;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    return WebDialogFrame(
      title: title,
      width: width,
      maxHeight: maxHeight,
      child: _EmbeddedPageBody(child: child),
    );
  }
}

class _EmbeddedPageBody extends StatelessWidget {
  const _EmbeddedPageBody({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final embeddedHeight = constraints.maxHeight + kToolbarHeight;
        return ClipRect(
          child: OverflowBox(
            alignment: Alignment.topCenter,
            minWidth: constraints.maxWidth,
            maxWidth: constraints.maxWidth,
            minHeight: embeddedHeight,
            maxHeight: embeddedHeight,
            child: Transform.translate(
              offset: const Offset(0, -kToolbarHeight),
              child: SizedBox(
                width: constraints.maxWidth,
                height: embeddedHeight,
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}
