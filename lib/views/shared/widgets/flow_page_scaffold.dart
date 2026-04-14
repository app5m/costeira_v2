import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';

class FlowPageScaffold extends StatelessWidget {
  const FlowPageScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.body,
    this.footer,
  });

  final String title;
  final String subtitle;
  final Widget body;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.colorPrimary,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.arrow_back_ios, size: 20),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              title,
                              style: const TextStyle(
                                color: Color(0xFF313131),
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                color: Color(0xFF8C8C8C),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                height: 1.5,
                                letterSpacing: 0.1,
                              ),
                            ),
                            const SizedBox(height: 24),
                            body,
                          ],
                        ),
                      ),
                    ),
                    if (footer != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                        child: footer,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
