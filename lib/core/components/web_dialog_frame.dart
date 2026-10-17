import 'package:flutter/material.dart';

enum WebDialogSizeMode {
  /// Sizes to content up to the viewport cap; scroll only on overflow.
  fitContent,

  /// Fills up to the viewport/maxHeight cap (for embedded Scaffold pages).
  constrained,
}

class WebDialogFrame extends StatelessWidget {
  const WebDialogFrame({
    super.key,
    required this.title,
    required this.child,
    this.width = 700,
    this.minHeight = 0,
    this.maxHeight = 760,
    this.preferredHeight,
    this.sizeMode = WebDialogSizeMode.fitContent,
    this.footer,
    this.headerActions,
    this.bodyPadding = EdgeInsets.zero,
    this.scrollableBody = true,
  });

  final String title;
  final Widget child;
  final double width;
  final double minHeight;
  final double maxHeight;
  final double? preferredHeight;
  final WebDialogSizeMode sizeMode;
  final Widget? footer;
  final Widget? headerActions;
  final EdgeInsetsGeometry bodyPadding;

  /// When true (default), fitContent wraps the body so it shrinks to content
  /// and scrolls only on overflow. Set false when the child manages its own
  /// Flexible/ListView layout (e.g. selection sheets).
  final bool scrollableBody;

  @override
  Widget build(BuildContext context) {
    final viewport = MediaQuery.sizeOf(context);
    final narrow = viewport.width < 620;
    final inset = narrow ? 12.0 : 24.0;
    final maxDialogHeight = (viewport.height - inset * 2).clamp(0.0, double.infinity);
    final effectiveMaxHeight = maxHeight < maxDialogHeight
        ? maxHeight
        : maxDialogHeight;

    final usePreferred =
        preferredHeight != null && sizeMode == WebDialogSizeMode.fitContent;
    final preferredClamped = preferredHeight?.clamp(
      minHeight,
      effectiveMaxHeight,
    );

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.all(inset),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Semantics(
        label: title,
        namesRoute: true,
        child: sizeMode == WebDialogSizeMode.constrained
            ? _ConstrainedShell(
                title: title,
                width: width,
                height: () {
                  if (preferredHeight != null) {
                    final lo = minHeight < effectiveMaxHeight
                        ? minHeight
                        : 0.0;
                    return preferredHeight!.clamp(lo, effectiveMaxHeight);
                  }
                  return effectiveMaxHeight;
                }(),
                footer: footer,
                headerActions: headerActions,
                bodyPadding: bodyPadding,
                child: child,
              )
            : _FitContentShell(
                title: title,
                width: width,
                minHeight: minHeight,
                maxHeight: effectiveMaxHeight,
                preferredHeight: usePreferred ? preferredClamped : null,
                footer: footer,
                headerActions: headerActions,
                bodyPadding: bodyPadding,
                scrollableBody: scrollableBody,
                child: child,
              ),
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.title, this.headerActions});

  final String title;
  final Widget? headerActions;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 66,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF252525),
                ),
              ),
            ),
            if (headerActions != null) ...[
              headerActions!,
              const SizedBox(width: 4),
            ],
            IconButton(
              tooltip: 'Fechar',
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _FitContentShell extends StatelessWidget {
  const _FitContentShell({
    required this.title,
    required this.width,
    required this.minHeight,
    required this.maxHeight,
    required this.child,
    this.preferredHeight,
    this.footer,
    this.headerActions,
    this.bodyPadding = EdgeInsets.zero,
    this.scrollableBody = true,
  });

  final String title;
  final double width;
  final double minHeight;
  final double maxHeight;
  final double? preferredHeight;
  final Widget child;
  final Widget? footer;
  final Widget? headerActions;
  final EdgeInsetsGeometry bodyPadding;
  final bool scrollableBody;

  @override
  Widget build(BuildContext context) {
    final body = scrollableBody
        ? ListView(
            shrinkWrap: true,
            primary: false,
            padding: bodyPadding.resolve(TextDirection.ltr),
            children: [child],
          )
        : Padding(
            padding: bodyPadding,
            child: child,
          );

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _DialogHeader(title: title, headerActions: headerActions),
        const Divider(height: 1, color: Color(0xFFE7E4DD)),
        Flexible(child: body),
        if (footer != null) ...[
          const Divider(height: 1, color: Color(0xFFE7E4DD)),
          footer!,
        ],
      ],
    );

    if (preferredHeight != null) {
      return SizedBox(
        width: width,
        height: preferredHeight,
        child: content,
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: width,
        minWidth: width,
        minHeight: minHeight,
        maxHeight: maxHeight,
      ),
      child: content,
    );
  }
}

class _ConstrainedShell extends StatelessWidget {
  const _ConstrainedShell({
    required this.title,
    required this.width,
    required this.height,
    required this.child,
    this.footer,
    this.headerActions,
    this.bodyPadding = EdgeInsets.zero,
  });

  final String title;
  final double width;
  final double height;
  final Widget child;
  final Widget? footer;
  final Widget? headerActions;
  final EdgeInsetsGeometry bodyPadding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Column(
        children: [
          _DialogHeader(title: title, headerActions: headerActions),
          const Divider(height: 1, color: Color(0xFFE7E4DD)),
          Expanded(
            child: Padding(
              padding: bodyPadding,
              child: child,
            ),
          ),
          if (footer != null) ...[
            const Divider(height: 1, color: Color(0xFFE7E4DD)),
            footer!,
          ],
        ],
      ),
    );
  }
}
