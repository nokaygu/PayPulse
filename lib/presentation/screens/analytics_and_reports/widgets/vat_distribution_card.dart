import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/financial_amount.dart';
import '../bloc/tax_report_cubit.dart';

/// İndirilecek KDV kaynak dağılımı kartı (`StatelessWidget`).
class VatDistributionCard extends StatelessWidget {
  final TaxReportState state;

  const VatDistributionCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final invShare = state.invoiceDeductibleShareFlex;
    final expShare = state.expenseDeductibleShareFlex;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'İndirilecek KDV Kaynak Dağılımı',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkNavy,
                    ),
                  ),
                  Text(
                    '${state.selectedPeriod.label} gelen fatura & onaylı fiş kırılımı',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const Icon(Icons.donut_large_rounded, color: AppColors.darkNavy),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 10,
              child: Row(
                children: [
                  Expanded(
                    flex: invShare,
                    child: Container(color: AppColors.darkNavy),
                  ),
                  Expanded(
                    flex: expShare,
                    child: Container(color: const Color(0xFF0F766E)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _VatSourceColumn(
                  dotColor: AppColors.darkNavy,
                  label: 'Gelen E-Faturalar',
                  amount: FinancialAmount.format(
                    state.summary.deductibleInvoiceVatKurus,
                  ),
                  share: '%$invShare pay (${state.periodInvoices.length} belge)',
                ),
              ),
              Expanded(
                child: _VatSourceColumn(
                  dotColor: const Color(0xFF0F766E),
                  label: 'Onaylı Personel Masrafı',
                  amount: FinancialAmount.format(
                    state.summary.deductibleExpenseVatKurus,
                  ),
                  share:
                      '%$expShare pay (${state.summary.approvedExpenseCount} fiş)',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VatSourceColumn extends StatelessWidget {
  final Color dotColor;
  final String label;
  final String amount;
  final String share;

  const _VatSourceColumn({
    required this.dotColor,
    required this.label,
    required this.amount,
    required this.share,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: const Color(0xFF475569),
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.darkNavy,
          ),
        ),
        Text(
          share,
          style: AppTextStyles.bodySmall.copyWith(
            color: const Color(0xFF64748B),
            fontSize: 10.5,
          ),
        ),
      ],
    );
  }
}

