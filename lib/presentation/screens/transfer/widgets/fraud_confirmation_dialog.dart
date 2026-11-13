import 'package:flutter/material.dart';

import '../../../../core/constants/app_limits.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/financial_amount.dart';

/// Yüksek tutarlı transferler için güvenlik onay diyalogu (`StatelessWidget`).
class FraudConfirmationDialog extends StatelessWidget {
  final int amountInKurus;

  const FraudConfirmationDialog({super.key, required this.amountInKurus});

  static Future<bool?> show(BuildContext context, int amountInKurus) {
    return showDialog<bool>(
      context: context,
      builder: (_) => FraudConfirmationDialog(amountInKurus: amountInKurus),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const Row(
        children: [
          Icon(Icons.shield_outlined, color: AppColors.warningOrange),
          SizedBox(width: 8),
          Expanded(child: Text('Yüksek Tutar Güvenlik Kontrolü')),
        ],
      ),
      content: Text(
        '${FinancialAmount.format(amountInKurus)} tutarındaki işleminiz '
        '${FinancialAmount.format(AppLimits.fraudLimitInKurus)} güvenlik eşiği üzerindedir.\n\n'
        'Alıcı ve tutar bilgilerinin doğruluğunu onaylıyor musunuz?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Vazgeç'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkNavy,
            foregroundColor: Colors.white,
            minimumSize: const Size(0, 44),
          ),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Güvenle Onayla'),
        ),
      ],
    );
  }
}

