import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/transaction_entity.dart';
import '../../../widgets/four_state_view.dart';
import 'home_transaction_tile_item.dart';

class RecentTransactionsCard extends StatelessWidget {
  final ViewStatus status;
  final List<TransactionEntity> transactions;
  final VoidCallback onRetry;

  const RecentTransactionsCard({
    super.key,
    required this.status,
    required this.transactions,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final visibleList = transactions.take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Son Cüzdan Hareketleri',
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkNavy,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => context.go(AppRoutes.transactions),
              child: Text(
                'Tümünü Gör >',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primaryTeal,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: FourStateView(
            status: status,
            emptyMessage: 'Henüz kayıtlı cüzdan hareketi bulunmuyor.',
            onRetry: onRetry,
            child: Column(
              children: [
                for (int i = 0; i < visibleList.length; i++) ...[
                  if (i > 0)
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  HomeTransactionTileItem(tx: visibleList[i]),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

