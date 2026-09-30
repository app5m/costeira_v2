import 'package:costeira/core/storage/session_storage.dart';
import 'package:flutter/material.dart';

class SubUserFlag extends StatelessWidget {
  const SubUserFlag({super.key, this.nome});

  final String? nome;

  @override
  Widget build(BuildContext context) {
    final label = nome?.trim() ?? '';
    if (label.isEmpty || SessionStorage.cachedSubUserId != null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF166534),
            fontSize: 11,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
