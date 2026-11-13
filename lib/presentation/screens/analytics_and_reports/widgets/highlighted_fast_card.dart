import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/financial_amount.dart';
import '../../../../domain/entities/transaction_entity.dart';

/// En güncel FAST transferini öne çıkaran etkileşimli kart (`StatelessWidget`).
class HighlightedFastCard extends StatelessWidget {
  final TransactionEntity transaction;
  final bool isIncoming;

  const HighlightedFastCard({
    super.key,
    required this.transaction,
    required this.isIncoming,
  });

  @override
  Widget build(BuildContext context) {
    final prefix = isIncoming ? '+' : '-';
    final amountText = '$prefix${FinancialAmount.format(transaction.amount)}';

    return InkWell(
      onTap: () => context.push(
        AppRoutes.fastReceipt.replaceFirst(':txId', transaction.txId),
      ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryGreen, width: 1.4),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _FastBoltIcon(),
            const SizedBox(width: 12),
            Expanded(child: _FastCardDetails(transaction: transaction)),
            _FastAmountColumn(amountText: amountText, isIncoming: isIncoming),
          ],
        ),
      ),
    );
  }
}

class _FastBoltIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFFD1FAE5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.bolt_rounded,
        color: AppColors.primaryTeal,
        size: 24,
      ),
    );
  }
}

class _FastCardDetails extends StatelessWidget {
  final TransactionEntity transaction;

  const _FastCardDetails({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'SON FAST İŞLEMİ',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primaryTeal,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
              decoration: BoxDecoration(
                color: const Color(0xFFD1FAE5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                transaction.status,
                style: AppTextStyles.labelSmall.copyWith(
                  color: const Color(0xFF065F46),
                  fontSize: 9,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          transaction.title.isEmpty ? 'FAST Transfer' : transaction.title,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.darkNavy,
          ),
        ),
        Text(
          '${transaction.category} • ${transaction.txId}',
          style: AppTextStyles.bodySmall.copyWith(
            color: const Color(0xFF64748B),
            fontSize: 11.5,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _FastAmountColumn extends StatelessWidget {
  final String amountText;
  final bool isIncoming;

  const _FastAmountColumn({required this.amountText, required this.isIncoming});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          amountText,
          style: AppTextStyles.labelLarge.copyWith(
            color: isIncoming ? AppColors.primaryTeal : AppColors.darkNavy,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Dekont >',
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.primaryTeal,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

