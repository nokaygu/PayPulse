import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/expense_approval_cubit.dart';

/// Onay bekleyen masrafların toplam tutarı, KDV indirimi ve toplu onay hero kartı.
class PendingSummaryHeroCard extends StatelessWidget {
  final ExpenseApprovalState state;
  final bool canApprove;
  final VoidCallback onBulkApprove;

  const PendingSummaryHeroCard({
    super.key,
    required this.state,
    required this.canApprove,
    required this.onBulkApprove,
  });

  @override
  Widget build(BuildContext context) {
    final pendingCount = state.pendingExpenses.length;

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
          _SummaryHeader(pendingCount: pendingCount),
          const SizedBox(height: 6),
          Text(
            state.formattedPendingTotal,
            style: AppTextStyles.numericBalance.copyWith(
              color: Colors.white,
              fontSize: 32,
            ),
          ),
          const SizedBox(height: 12),
          _VatSavingsStrip(formattedVat: state.formattedPendingVat),
          if (canApprove && pendingCount > 0) ...[
            const SizedBox(height: 14),
            _BulkApproveButton(
              isSubmitting: state.isSubmitting,
              formattedTotal: state.formattedPendingTotal,
              onPressed: onBulkApprove,
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  final int pendingCount;

  const _SummaryHeader({required this.pendingCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'BEKLEYEN TOPLAM TUTAR',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.labelSmall.copyWith(
              color: const Color(0xFF94A3B8),
              letterSpacing: 0.7,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$pendingCount Fatura / Fiş',
            style: AppTextStyles.labelSmall.copyWith(
              color: const Color(0xFF5EEAD4),
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }
}

class _VatSavingsStrip extends StatelessWidget {
  final String formattedVat;

  const _VatSavingsStrip({required this.formattedVat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                const Icon(
                  Icons.savings_outlined,
                  size: 16,
                  color: Color(0xFF5EEAD4),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'KDV İndirimi Kazanımı',
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formattedVat,
            style: AppTextStyles.labelMedium.copyWith(
              color: const Color(0xFF5EEAD4),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _BulkApproveButton extends StatelessWidget {
  final bool isSubmitting;
  final String formattedTotal;
  final VoidCallback onPressed;

  const _BulkApproveButton({
    required this.isSubmitting,
    required this.formattedTotal,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.darkNavy,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: isSubmitting ? null : onPressed,
        icon: const Icon(
          Icons.done_all_rounded,
          size: 18,
          color: AppColors.primaryTeal,
        ),
        label: Text(
          isSubmitting
              ? 'Toplu Onay İşleniyor...'
              : 'Tümünü İncele & Toplu Onayla ($formattedTotal)',
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

