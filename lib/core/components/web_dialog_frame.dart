import 'package:flutter/material.dart';

class WebDialogFrame extends StatelessWidget {
  const WebDialogFrame({
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
    final viewport = MediaQuery.sizeOf(context);
    final availableHeight = (viewport.height - 48).clamp(320.0, maxHeight);
    final narrow = viewport.width < 620;

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.all(narrow ? 12 : 24),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Semantics(
        label: title,
        namesRoute: true,
        child: SizedBox(
          width: width,
          height: availableHeight,
          child: Column(
            children: [
              SizedBox(
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
                      IconButton(
                        tooltip: 'Fechar',
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE7E4DD)),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}
