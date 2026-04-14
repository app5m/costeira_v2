import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppFormField extends StatelessWidget {
  const AppFormField({
    super.key,
    required this.label,
    required this.hintText,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.obscureText = false,
    this.suffixIcon,
    this.maxLength,
    this.onChanged,
    this.inputFormatters,
    this.autofillHints,
  });

  final String label;
  final String hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final Widget? suffixIcon;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
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
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          maxLength: maxLength,
          onChanged: onChanged,
          inputFormatters: inputFormatters,
          autofillHints: autofillHints,
          style: const TextStyle(
            color: Color(0xFF313131),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            suffixIcon: suffixIcon,
            counterText: maxLength == null ? null : '',
            hintStyle: const TextStyle(
              color: Color(0xFF8C8C8C),
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.5,
              letterSpacing: 0.1,
            ),
          ),
        ),
      ],
    );
  }
}
