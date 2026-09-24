import 'dart:async';

import 'package:costeira/core/services/places_service.dart';
import 'package:flutter/material.dart';

class AddressAutocompleteField extends StatefulWidget {
  const AddressAutocompleteField({
    super.key,
    required this.controller,
    required this.placesService,
    this.label = 'Endereço',
    this.hintText = 'Digite o endereço',
  });

  final TextEditingController controller;
  final PlacesService placesService;
  final String label;
  final String hintText;

  @override
  State<AddressAutocompleteField> createState() =>
      _AddressAutocompleteFieldState();
}

class _AddressAutocompleteFieldState extends State<AddressAutocompleteField> {
  Timer? _debounce;
  int _seq = 0;
  bool _searching = false;
  bool _suppress = false;
  List<PlaceSuggestion> _suggestions = const [];

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (_suppress) {
      return;
    }
    _debounce?.cancel();
    final query = widget.controller.text.trim();
    if (query.length < 3) {
      if (_suggestions.isNotEmpty || _searching) {
        setState(() {
          _suggestions = const [];
          _searching = false;
        });
      }
      return;
    }

    setState(() => _searching = true);
    _debounce = Timer(const Duration(milliseconds: 450), () async {
      final seq = ++_seq;
      final results = await widget.placesService.autocomplete(query);
      if (!mounted || seq != _seq) {
        return;
      }
      setState(() {
        _suggestions = results;
        _searching = false;
      });
    });
  }

  Future<void> _select(PlaceSuggestion suggestion) async {
    _debounce?.cancel();
    _seq++;
    _suppress = true;
    widget.controller.text = suggestion.description;
    _suppress = false;
    if (!mounted) {
      return;
    }
    setState(() {
      _suggestions = const [];
      _searching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            color: Color(0xFF313131),
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.5,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: const TextStyle(
              color: Color(0xFF8C8C8C),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            suffixIcon: _searching
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : const Icon(Icons.place_outlined, color: Color(0xFF8C8C8C)),
          ),
        ),
        if (_suggestions.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFEBEBEB)),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _suggestions.length.clamp(0, 6),
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: Color(0xFFEBEBEB)),
              itemBuilder: (context, index) {
                final item = _suggestions[index];
                final distance = item.distanceMeters;
                return ListTile(
                  dense: true,
                  title: Text(
                    item.description,
                    style: const TextStyle(fontSize: 13),
                  ),
                  subtitle: distance == null
                      ? null
                      : Text(
                          '${distance.toStringAsFixed(1)} km',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF8C8C8C),
                          ),
                        ),
                  onTap: () => _select(item),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
