import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.enabled = true,
    this.isLoading = false,
    this.backgroundColor = MyColors.colorPrimary,
    this.disabledColor = MyColors.grayLite,
    this.textColor = Colors.white,
    this.disabledTextColor = MyColors.gray,
    this.borderColor,
    this.height = 50,
    this.borderRadius = 8,
    this.textStyle,
    this.loaderColor,
  });

  final VoidCallback? onPressed;
  final String text;
  final bool enabled;
  final bool isLoading;
  final Color backgroundColor;
  final Color disabledColor;
  final Color textColor;
  final Color disabledTextColor;
  final Color? borderColor;
  final double height;
  final double borderRadius;
  final TextStyle? textStyle;
  final Color? loaderColor;

  @override
  Widget build(BuildContext context) {
    final isInteractive = enabled && !isLoading;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isInteractive ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          disabledBackgroundColor: disabledColor,
          elevation: 0,
          side: borderColor != null ? BorderSide(color: borderColor!) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: loaderColor ?? textColor,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                textAlign: TextAlign.center,
                style:
                    textStyle ??
                    TextStyle(
                      color: isInteractive ? textColor : disabledTextColor,
                      fontSize: 14,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                      height: 1.29,
                    ),
              ),
      ),
    );
  }
}
