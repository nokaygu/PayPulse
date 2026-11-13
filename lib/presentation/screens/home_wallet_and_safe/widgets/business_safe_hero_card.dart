import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/financial_amount.dart';
import '../../../widgets/dark_gradient_hero_card.dart';

class BusinessSafeHeroCard extends StatelessWidget {
  final int balanceKurus;
  final bool isAdmin;
  final String corporateIban;
  final VoidCallback onTransferToAccount;
  final VoidCallback onTopUpBalance;

  const BusinessSafeHeroCard({
    super.key,
    required this.balanceKurus,
    required this.isAdmin,
    required this.corporateIban,
    required this.onTransferToAccount,
    required this.onTopUpBalance,
  });

  @override
  Widget build(BuildContext context) {
    return DarkGradientHeroCard(
      title: 'KULLANILABİLİR İŞLETME BAKİYESİ (TRY)',
      mainAmount: FinancialAmount.format(balanceKurus),
      subtitle: isAdmin
          ? 'Yönetici Kasası • Anlık Takas Aktif'
          : 'Kurumsal Personel Görünümü',
      topRightBadge: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.primaryTeal.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          '● Aktif Hesap',
          style: AppTextStyles.labelSmall.copyWith(
            color: const Color(0xFF5EEAD4),
            fontSize: 10,
          ),
        ),
      ),
      bottomChild: Column(
        children: [
          _CorporateIbanStrip(corporateIban: corporateIban),
          if (isAdmin) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5EEAD4),
                      foregroundColor: AppColors.darkNavy,
                      minimumSize: const Size(0, 42),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: onTransferToAccount,
                    icon: const Icon(Icons.output_rounded, size: 16),
                    label: const Text(
                      'Hesaba Aktar',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                      minimumSize: const Size(0, 42),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: onTopUpBalance,
                    icon: const Icon(Icons.add_circle_outline, size: 16),
                    label: const Text(
                      'Bakiye Yükle',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _CorporateIbanStrip extends StatelessWidget {
  final String corporateIban;

  const _CorporateIbanStrip({required this.corporateIban});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ana Ticari IBAN',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF94A3B8),
                    fontSize: 10,
                  ),
                ),
                Text(
                  corporateIban,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Clipboard.setData(
                ClipboardData(text: corporateIban.replaceAll(' ', '')),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ticari IBAN kopyalandı.')),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Kopyala',
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

