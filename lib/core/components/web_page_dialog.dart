import 'package:costeira/core/components/web_dialog_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Embeds a mobile [Scaffold] page in a web dialog.
///
/// The embedded content is measured after its first layout and whenever its
/// scroll metrics actually change. There is no polling and no measurement in
/// [build], which keeps the dialog compact without creating a resize loop.
class WebPageDialog extends StatefulWidget {
  const WebPageDialog({
    super.key,
    required this.title,
    required this.child,
    this.width = 700,
    this.minHeight = 160,
    this.maxHeight = 760,
    this.preferredHeight,
    this.sizeMode = WebDialogSizeMode.constrained,
    this.footer,
  });

  final String title;
  final Widget child;
  final double width;
  final double minHeight;
  final double maxHeight;
  final double? preferredHeight;
  final WebDialogSizeMode sizeMode;
  final Widget? footer;

  @override
  State<WebPageDialog> createState() => _WebPageDialogState();
}

class _WebPageDialogState extends State<WebPageDialog> {
  final GlobalKey _hostKey = GlobalKey();
  double? _measuredHeight;
  bool _measurementScheduled = false;

  static const double _headerHeight = 67;
  static const double _footerHeight = 73;
  static const double _bottomPadding = 24;

  @override
  void initState() {
    super.initState();
    _scheduleMeasurement();
  }

  @override
  void didUpdateWidget(covariant WebPageDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child != widget.child ||
        oldWidget.maxHeight != widget.maxHeight ||
        oldWidget.minHeight != widget.minHeight ||
        oldWidget.footer != widget.footer) {
      _scheduleMeasurement();
    }
  }

  void _scheduleMeasurement() {
    if (_measurementScheduled || widget.preferredHeight != null) return;
    _measurementScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measurementScheduled = false;
      if (!mounted) return;
      _measureContent();
    });
  }

  double _availableHeight() {
    final viewport = MediaQuery.sizeOf(context);
    final inset = viewport.width < 620 ? 12.0 : 24.0;
    final viewportHeight = (viewport.height - inset * 2).clamp(
      0.0,
      double.infinity,
    );
    return widget.maxHeight < viewportHeight
        ? widget.maxHeight
        : viewportHeight;
  }

  void _measureContent() {
    final contentHeight = _embeddedContentHeight(_hostKey.currentContext);
    if (contentHeight == null) return;

    final available = _availableHeight();
    final footer = widget.footer == null ? 0.0 : _footerHeight;
    final minimum = widget.minHeight.clamp(0.0, available);
    final fitted = (_headerHeight + contentHeight + _bottomPadding + footer)
        .clamp(minimum, available);

    if (_measuredHeight != null && (_measuredHeight! - fitted).abs() <= 2) {
      return;
    }
    setState(() => _measuredHeight = fitted);
  }

  @override
  Widget build(BuildContext context) {
    return WebDialogFrame(
      title: widget.title,
      width: widget.width,
      minHeight: widget.minHeight,
      maxHeight: widget.maxHeight,
      preferredHeight: widget.preferredHeight ?? _measuredHeight,
      sizeMode: WebDialogSizeMode.constrained,
      footer: widget.footer,
      child: NotificationListener<ScrollMetricsNotification>(
        onNotification: (_) {
          _scheduleMeasurement();
          return false;
        },
        child: _EmbeddedPageBody(key: _hostKey, child: widget.child),
      ),
    );
  }
}

class _EmbeddedPageBody extends StatelessWidget {
  const _EmbeddedPageBody({super.key, required this.child});

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

double? _embeddedContentHeight(BuildContext? context) {
  if (context == null) return null;
  final root = context.findRenderObject();
  if (root == null) return null;

  final viewports = <RenderViewportBase>[];
  void collect(RenderObject object) {
    if (object is RenderViewportBase) viewports.add(object);
    object.visitChildren(collect);
  }

  collect(root);
  if (viewports.isEmpty) return null;

  var largest = 0.0;
  for (final viewport in viewports) {
    var extent = 0.0;
    viewport.visitChildren((child) {
      if (child is RenderSliver && child.geometry != null) {
        extent += child.geometry!.scrollExtent;
      }
    });
    if (extent > largest) largest = extent;
  }
  return largest > 0 ? largest : null;
}
