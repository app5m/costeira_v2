import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class AppSelectOption<T> {
  const AppSelectOption({required this.value, required this.label});

  final T value;
  final String label;
}

class AppSelectOverlay<T> extends StatefulWidget {
  const AppSelectOverlay({
    super.key,
    required this.options,
    required this.onChanged,
    this.value,
    this.placeholder = 'Selecionar',
    this.enabled = true,
  });

  final List<AppSelectOption<T>> options;
  final T? value;
  final ValueChanged<T?> onChanged;
  final String placeholder;
  final bool enabled;

  @override
  State<AppSelectOverlay<T>> createState() => _AppSelectOverlayState<T>();
}

class _AppSelectOverlayState<T> extends State<AppSelectOverlay<T>> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isDisposing = false;

  bool get _isOpen => _overlayEntry != null;

  @override
  void dispose() {
    _isDisposing = true;
    _removeOverlay(notify: false);
    super.dispose();
  }

  @override
  void deactivate() {
    _removeOverlay(notify: false);
    super.deactivate();
  }

  void _toggleDropdown() {
    if (!widget.enabled || widget.options.isEmpty) {
      return;
    }

    if (_isOpen) {
      _removeOverlay();
      return;
    }

    _overlayEntry = _createOverlay();
    Overlay.of(context).insert(_overlayEntry!);
    _safeSetState();
  }

  void _removeOverlay({bool notify = true}) {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (notify) {
      _safeSetState();
    }
  }

  void _safeSetState() {
    if (!mounted || _isDisposing) {
      return;
    }

    final phase = WidgetsBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isDisposing) {
          setState(() {});
        }
      });
      return;
    }

    setState(() {});
  }

  OverlayEntry _createOverlay() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _removeOverlay,
              child: const SizedBox.expand(),
            ),
          ),
          CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, size.height + 6),
            child: Material(
              color: Colors.transparent,
              child: SizedBox(
                width: size.width,
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 260),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBEBEB),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    shrinkWrap: true,
                    itemCount: widget.options.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: Color(0xFFDCDCDC)),
                    itemBuilder: (context, index) {
                      final option = widget.options[index];
                      final isSelected = option.value == widget.value;

                      return InkWell(
                        onTap: () {
                          widget.onChanged(option.value);
                          _removeOverlay();
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          child: Text(
                            option.label,
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Montserrat',
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: const Color(0xFF232323),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedOption = widget.options
        .cast<AppSelectOption<T>?>()
        .firstWhere(
          (option) => option?.value == widget.value,
          orElse: () => null,
        );
    final displayText = selectedOption?.label ?? widget.placeholder;
    final isPlaceholder = selectedOption == null;
    final isEnabled = widget.enabled && widget.options.isNotEmpty;

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: isEnabled ? _toggleDropdown : null,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: isEnabled ? 1 : 0.65,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFEBEBEB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    displayText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Montserrat',
                      color: isPlaceholder
                          ? const Color(0xFF8C8C8C)
                          : const Color(0xFF232323),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  _isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: const Color(0xFF232323),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
