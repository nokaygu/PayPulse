import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Gönderen, alıcı ve açıklama ayrıntılarını gösteren beyaz özet kartı (`StatelessWidget`).
class TransferSummaryDetailsCard extends StatelessWidget {
  final String senderName;
  final String senderBalanceText;
  final String recipientName;
  final String recipientIban;
  final String description;

  const TransferSummaryDetailsCard({
    super.key,
    required this.senderName,
    required this.senderBalanceText,
    required this.recipientName,
    required this.recipientIban,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
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
          const _DetailsHeader(),
          const SizedBox(height: 16),
          _SenderRow(
            senderName: senderName,
            senderBalanceText: senderBalanceText,
          ),
          const SizedBox(height: 16),
          _RecipientRow(
            recipientName: recipientName,
            recipientIban: recipientIban,
          ),
          const SizedBox(height: 12),
          _DescriptionBox(description: description),
        ],
      ),
    );
  }
}

class _DetailsHeader extends StatelessWidget {
  const _DetailsHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Transfer Ayrıntıları',
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.darkNavy,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF99F6E4),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            'TCMB Güvencesi',
            style: AppTextStyles.labelSmall.copyWith(
              color: const Color(0xFF065F46),
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _SenderRow extends StatelessWidget {
  final String senderName;
  final String senderBalanceText;

  const _SenderRow({
    required this.senderName,
    required this.senderBalanceText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.account_balance_wallet_outlined,
            color: AppColors.darkNavy,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gönderen Hesap',
                style: AppTextStyles.bodySmall.copyWith(
                  color: const Color(0xFF64748B),
                  fontSize: 11,
                ),
              ),
              Text(
                '$senderName - PayPulse TRY Cüzdan',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkNavy,
                ),
              ),
              Text(
                'Kullanılabilir Bakiye: $senderBalanceText',
                style: AppTextStyles.bodySmall.copyWith(
                  color: const Color(0xFF64748B),
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecipientRow extends StatelessWidget {
  final String recipientName;
  final String recipientIban;

  const _RecipientRow({
    required this.recipientName,
    required this.recipientIban,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.person_outline_rounded,
            color: AppColors.primaryTeal,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Alıcı',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: const Color(0xFF64748B),
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    '✓ FAST Doğrulandı',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primaryTeal,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Text(
                recipientName,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkNavy,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                recipientIban,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.darkNavy,
                  fontFamily: 'monospace',
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DescriptionBox extends StatelessWidget {
  final String description;

  const _DescriptionBox({required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.chat_bubble_outline_rounded,
            size: 18,
            color: AppColors.darkNavy,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Açıklama',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF64748B),
                    fontSize: 10.5,
                  ),
                ),
                Text(
                  description,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.darkNavy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

