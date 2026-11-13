import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/financial_amount.dart';
import '../../../widgets/status_badge_widget.dart';
import '../bloc/tax_report_cubit.dart';

/// Ödenecek veya devreden net KDV bakiyesi hero kartı (`StatelessWidget`).
class NetVatHeroCard extends StatelessWidget {
  final TaxReportState state;

  const NetVatHeroCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final isDeferred = state.summary.hasDeferredVat;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.heroCardGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkNavy.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _NetVatHeaderRow(isDeferred: isDeferred),
          const SizedBox(height: 6),
          Text(
            state.formattedNetVat,
            style: AppTextStyles.numericBalance.copyWith(
              color: Colors.white,
              fontSize: 32,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isDeferred
                ? 'İndirilecek KDV toplamı hesaplanan satış KDV tutarını aştı.'
                : 'Matrah mahsubu sonrası devlete ödenecek net vergi bakiyesi',
            style: AppTextStyles.bodySmall.copyWith(
              color: const Color(0xFF94A3B8),
              fontSize: 11.5,
            ),
          ),
          const SizedBox(height: 16),
          _VatComparisonRow(state: state),
          const SizedBox(height: 12),
          _DeductibleVatNote(
            formattedDeductibleVat: state.formattedDeductibleVat,
            approvedExpenseCount: state.summary.approvedExpenseCount,
          ),
        ],
      ),
    );
  }
}

class _NetVatHeaderRow extends StatelessWidget {
  final bool isDeferred;

  const _NetVatHeaderRow({required this.isDeferred});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          isDeferred
              ? 'SONRAKİ DÖNEME DEVREDEN KDV'
              : 'TAHMİNİ ÖDENECEK NET KDV',
          style: AppTextStyles.labelSmall.copyWith(
            color: const Color(0xFF94A3B8),
            letterSpacing: 0.8,
          ),
        ),
        StatusBadgeWidget(
          label: isDeferred ? 'Devreden KDV' : 'Ödenecek Vergi',
          type: isDeferred ? BadgeType.success : BadgeType.warning,
        ),
      ],
    );
  }
}

class _VatComparisonRow extends StatelessWidget {
  final TaxReportState state;

  const _VatComparisonRow({required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hesaplanan KDV\n(Satış)',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF94A3B8),
                    fontSize: 11,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  state.formattedOutputVat,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Matrah: ${FinancialAmount.format(state.summary.salesBaseKurus)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF94A3B8),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryTeal.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.primaryGreen.withValues(alpha: 0.25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'İndirilecek KDV\n(Gider & Fatura)',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF5EEAD4),
                    fontSize: 11,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '-${state.formattedDeductibleVat}',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: const Color(0xFF5EEAD4),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '%${state.offsetRatioPercent} Mahsup Oranı',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primaryGreen,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DeductibleVatNote extends StatelessWidget {
  final String formattedDeductibleVat;
  final int approvedExpenseCount;

  const _DeductibleVatNote({
    required this.formattedDeductibleVat,
    required this.approvedExpenseCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryTeal.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.savings_outlined, color: Color(0xFF5EEAD4), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$formattedDeductibleVat fatura ve $approvedExpenseCount onaylı masraf fişinden düşüldü.',
              style: AppTextStyles.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

