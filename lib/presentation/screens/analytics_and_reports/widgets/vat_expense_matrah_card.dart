import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/financial_amount.dart';
import '../bloc/tax_report_cubit.dart';

/// Onaylı masraf & alış matrahı kategori dağılımı kartı (`StatelessWidget`).
class VatExpenseMatrahCard extends StatelessWidget {
  final TaxReportState state;

  const VatExpenseMatrahCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final breakdowns = state.categoryBreakdowns;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MatrahHeaderRow(
            purchaseBaseKurus: state.summary.purchaseBaseKurus,
            categoryCount: breakdowns.length,
          ),
          const SizedBox(height: 14),
          if (breakdowns.isEmpty)
            Text(
              'Bu dönem için onaylanmış personel masraf kalemi bulunmuyor; yalnızca GİB faturaları hesaplamaya dahil edildi.',
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFF64748B),
              ),
            )
          else
            ...breakdowns.map(
              (b) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _MatrahCategoryRow(
                  category: b.category,
                  itemCount: b.itemCount,
                  totalVatKurus: b.totalVatKurus,
                  totalAmountKurus: b.totalAmountKurus,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MatrahHeaderRow extends StatelessWidget {
  final int purchaseBaseKurus;
  final int categoryCount;

  const _MatrahHeaderRow({
    required this.purchaseBaseKurus,
    required this.categoryCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Onaylı Masraf & Matrah Analizi',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.darkNavy,
              ),
            ),
            Text(
              'Alış Matrahı: ${FinancialAmount.format(purchaseBaseKurus)}',
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$categoryCount Kategori',
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.darkNavy),
          ),
        ),
      ],
    );
  }
}

class _MatrahCategoryRow extends StatelessWidget {
  final String category;
  final int itemCount;
  final int totalVatKurus;
  final int totalAmountKurus;

  const _MatrahCategoryRow({
    required this.category,
    required this.itemCount,
    required this.totalVatKurus,
    required this.totalAmountKurus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: AppColors.primaryTeal,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkNavy,
                  ),
                ),
                Text(
                  '$itemCount onaylı belge • KDV: ${FinancialAmount.format(totalVatKurus)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF64748B),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            FinancialAmount.format(totalAmountKurus),
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.darkNavy,
            ),
          ),
        ],
      ),
    );
  }
}

