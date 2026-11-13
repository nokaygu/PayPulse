import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/financial_amount.dart';
import '../bloc/virtual_pos_cubit.dart';

/// Sanal POS Gün Sonu Z Raporu alt penceresi ve bugünkü işlemler özet kartı.
class PosZReportSummaryTile extends StatelessWidget {
  final VirtualPosState state;
  final VoidCallback onOpenSheet;

  const PosZReportSummaryTile({
    super.key,
    required this.state,
    required this.onOpenSheet,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onOpenSheet,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            const Icon(Icons.receipt_long_rounded, color: AppColors.darkNavy),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bugünkü POS İşlemleri (Kart & QR)',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.darkNavy,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '${state.posTransactions.length} İşlem • ${FinancialAmount.format((state.zReportTotalTl * 100).round())}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: const Color(0xFF64748B),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'Z Raporu >',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primaryTeal,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PosZReportBottomSheet extends StatelessWidget {
  final VirtualPosState state;

  const PosZReportBottomSheet({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'POS GÜN SONU Z RAPORU',
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.darkNavy,
            ),
          ),
          Text(
            'Toplam ${state.posTransactions.length} POS İşlemi • Net Hesaba Geçen: ${FinancialAmount.format((state.zReportNetTl * 100).round())}',
            style: AppTextStyles.bodySmall.copyWith(
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 12),
          if (state.posTransactions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text('Bugün henüz POS tahsilatı gerçekleşmedi.'),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: state.posTransactions.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (_, index) {
                  final item = state.posTransactions[index];
                  final isQr = item.cardMasked.toUpperCase().contains('QR');
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      isQr ? Icons.qr_code_2_rounded : Icons.credit_card_rounded,
                      color: isQr ? AppColors.primaryTeal : AppColors.darkNavy,
                    ),
                    title: Text(
                      item.customerName,
                      style: AppTextStyles.labelLarge,
                    ),
                    subtitle: Text('${item.posTxId} • ${item.cardMasked}'),
                    trailing: Text(
                      FinancialAmount.format((item.grossAmount * 100).round()),
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.primaryTeal,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

