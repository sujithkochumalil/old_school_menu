import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(color: AppColors.chipBg, shape: BoxShape.circle),
                child: const Icon(Icons.qr_code_2_rounded, size: 48, color: AppColors.brown),
              ),
              const SizedBox(height: 24),
              Text('Menu not found', style: titleStyle(26)),
              const SizedBox(height: 10),
              Text(
                'This QR code may be old or incomplete.\nPlease ask the staff for help.',
                textAlign: TextAlign.center,
                style: textStyle(14, color: AppColors.muted, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
