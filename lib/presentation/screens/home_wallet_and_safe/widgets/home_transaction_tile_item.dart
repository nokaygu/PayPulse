import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/transaction_entity.dart';
import '../../../widgets/transaction_list_tile_widget.dart';

class HomeTransactionTileItem extends StatelessWidget {
  final TransactionEntity tx;

  const HomeTransactionTileItem({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    return TransactionListTileWidget.fromEntity(
      tx,
      onTap: () => context.push('/home/transfer/receipt/${tx.txId}'),
    );
  }
}

class WalletCurrencyChip extends StatelessWidget {
  final String currency;
  final bool isSelected;
  final VoidCallback onTap;

  const WalletCurrencyChip({
    super.key,
    required this.currency,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF5EEAD4)
              : Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          currency,
          style: AppTextStyles.labelSmall.copyWith(
            color: isSelected ? AppColors.darkNavy : Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 10.5,
          ),
        ),
      ),
    );
  }
}

