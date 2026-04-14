import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SettingsOptionTile extends StatelessWidget {
  const SettingsOptionTile({
    super.key,
    required this.title,
    required this.onTap,
    this.textColor = const Color(0xFF313131),
  });

  final String title;
  final VoidCallback onTap;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Color(0xFFEBEBEB)),
            borderRadius: BorderRadius.circular(12),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 24,
              offset: Offset(0, 0),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.1,
              ),
            ),
            SvgPicture.asset(
              'icon/Arrow.svg',
              width: 24,
              height: 24,
            ),
          ],
        ),
      ),
    );
  }
}
