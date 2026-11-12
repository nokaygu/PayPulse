import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../widgets/custom_numpad_widget.dart';
import '../../widgets/role_switch_app_bar.dart';
import 'transfer_summary_screen.dart';

/// FAST Para Transferi Adım 2/4: Tutar Giriş Ekranı
class TransferAmountScreen extends StatefulWidget {
  const TransferAmountScreen({super.key});

  @override
  State<TransferAmountScreen> createState() => _TransferAmountScreenState();
}

class _TransferAmountScreenState extends State<TransferAmountScreen> {
  String _amountText = '1500';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const RoleSwitchAppBar(
        isBusinessMode: false,
        showBackButton: true,
        customTitle: 'FAST Tutar Belirle',
        customSubtitle: 'Adım 2/4 • Zeynep Kaya (Garanti BBVA)',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'GÖNDERİLECEK TUTAR',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₺${_amountText.isEmpty ? '0' : _amountText},00',
                      style: AppTextStyles.numericBalance.copyWith(
                        color: AppColors.darkNavy,
                        fontSize: 42,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Kullanılabilir TRY Bakiye: ₺24.850,00',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primaryTeal,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            CustomNumpadWidget(
              onDigitPressed: (d) {
                setState(() {
                  if (_amountText.length < 7) {
                    _amountText += d;
                  }
                });
              },
              onBackspacePressed: () {
                setState(() {
                  if (_amountText.isNotEmpty) {
                    _amountText = _amountText.substring(
                      0,
                      _amountText.length - 1,
                    );
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkNavy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const TransferSummaryScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Onay Adımına Geç (Adım 3/4) →',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
