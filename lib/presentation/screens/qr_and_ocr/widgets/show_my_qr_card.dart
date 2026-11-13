import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/formatters/currency_and_card_formatters.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/financial_amount.dart';
import '../../../widgets/status_badge_widget.dart';
import '../bloc/qr_payment_cubit.dart';

/// B2C Dinamik 48 saniyelik TR Karekod gösterim, tutar seçimi ve talep oluşturma kartı.
class ShowMyQrCard extends StatelessWidget {
  final QrPaymentCubit cubit;
  final QrPaymentState state;
  final String userId;
  final String userName;

  const ShowMyQrCard({
    super.key,
    required this.cubit,
    required this.state,
    required this.userId,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final payload = state.qrPayload(
      userId,
      userName: userName,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkNavy.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _QrHeaderRow(generationCount: state.generationCount),
          const SizedBox(height: 18),
          _QrMatrixFrame(
            qrPayload: payload,
            isUrgent: state.isUrgent,
          ),
          const SizedBox(height: 14),
          if (state.requestedAmount != null) ...[
            _SelectedAmountBadge(amount: state.requestedAmount!),
            const SizedBox(height: 10),
          ],
          Text(
            '$userName • PP-849201',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.darkNavy,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Dinamik Anahtar: ${state.shortToken}',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.primaryTeal,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _QrCountdownBox(
            formattedCountdown: state.formattedCountdown,
            progress: state.progress,
            isUrgent: state.isUrgent,
          ),
          const SizedBox(height: 14),
          _QuickAmountPickerRow(
            selectedAmount: state.requestedAmount,
            onSelected: cubit.selectRequestedAmount,
          ),
          const SizedBox(height: 16),
          _QrPrimaryActionsRow(
            onRegenerate: cubit.regenerateQr,
            onCopy: () {
              Clipboard.setData(ClipboardData(text: payload));
              cubit.notifyCopiedPayload();
            },
          ),
          const Divider(height: 28),
          _PaymentRequestAmountRow(
            controller: cubit.requestAmountController,
            isBusy: state.isBusy,
            onCreateRequest: () => cubit.createPaymentRequestQr(
              userId: userId,
              userName: userName,
            ),
          ),
        ],
      ),
    );
  }
}

class _QrHeaderRow extends StatelessWidget {
  final int generationCount;

  const _QrHeaderRow({required this.generationCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const StatusBadgeWidget(
          label: 'TCMB TR Karekod Uyumlu',
          type: BadgeType.success,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            'Kod #$generationCount',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.darkNavy,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _QrMatrixFrame extends StatelessWidget {
  final String qrPayload;
  final bool isUrgent;

  const _QrMatrixFrame({
    required this.qrPayload,
    required this.isUrgent,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      child: Container(
        key: ValueKey<String>(qrPayload),
        width: 236,
        height: 236,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isUrgent ? AppColors.warningOrange : AppColors.primaryGreen,
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withValues(alpha: 0.12),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: QrImageView(
          data: qrPayload,
          version: QrVersions.auto,
          errorCorrectionLevel: QrErrorCorrectLevel.M,
          size: 204,
          gapless: true,
          backgroundColor: Colors.white,
          eyeStyle: const QrEyeStyle(
            eyeShape: QrEyeShape.square,
            color: AppColors.darkNavy,
          ),
          dataModuleStyle: const QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.square,
            color: AppColors.darkNavy,
          ),
        ),
      ),
    );
  }
}

class _SelectedAmountBadge extends StatelessWidget {
  final double amount;

  const _SelectedAmountBadge({required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFD1FAE5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'Sabit Tahsilat/Ödeme Tutarı: ${FinancialAmount.formatLira(amount)}',
        style: AppTextStyles.labelSmall.copyWith(
          color: const Color(0xFF065F46),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _QrCountdownBox extends StatelessWidget {
  final String formattedCountdown;
  final double progress;
  final bool isUrgent;

  const _QrCountdownBox({
    required this.formattedCountdown,
    required this.progress,
    required this.isUrgent,
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.timer_outlined,
                size: 16,
                color: isUrgent ? AppColors.expenseRed : AppColors.primaryTeal,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Güvenlik için kod $formattedCountdown saniye içinde yenilenir',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isUrgent
                        ? AppColors.expenseRed
                        : const Color(0xFF475569),
                    fontWeight: FontWeight.w700,
                    fontSize: 11.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(
                isUrgent ? AppColors.expenseRed : AppColors.primaryGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAmountPickerRow extends StatelessWidget {
  final double? selectedAmount;
  final ValueChanged<double?> onSelected;

  const _QuickAmountPickerRow({
    required this.selectedAmount,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    const presets = <(String, double?)>[
      ('Limitsiz / Kasada Belirle', null),
      ('₺100', 100),
      ('₺250', 250),
      ('₺500', 500),
      ('₺1.250', 1250),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'QR Tutar Seçimi (İsteğe Bağlı)',
          style: AppTextStyles.labelSmall.copyWith(
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (int i = 0; i < presets.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                _AmountChip(
                  label: presets[i].$1,
                  selected: selectedAmount == presets[i].$2,
                  onTap: () => onSelected(presets[i].$2),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _AmountChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _AmountChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.darkNavy : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.darkNavy : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: selected ? Colors.white : AppColors.darkNavy,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _QrPrimaryActionsRow extends StatelessWidget {
  final VoidCallback onRegenerate;
  final VoidCallback onCopy;

  const _QrPrimaryActionsRow({
    required this.onRegenerate,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.darkNavy,
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: onRegenerate,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text(
              'Şimdi Yenile (48sn)',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkNavy,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 46),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: onCopy,
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: const Text(
              'QR Verisini Kopyala',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}

class _PaymentRequestAmountRow extends StatelessWidget {
  final TextEditingController controller;
  final bool isBusy;
  final VoidCallback onCreateRequest;

  const _PaymentRequestAmountRow({
    required this.controller,
    required this.isBusy,
    required this.onCreateRequest,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tutara Bağlı Tahsilat QR Talebi Oluştur',
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.darkNavy,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [TurkishCurrencyInputFormatter()],
                decoration: const InputDecoration(
                  labelText: 'Tutar (TL)',
                  prefixText: '₺ ',
                  hintText: '250,00',
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(116, 52),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onPressed: isBusy ? null : onCreateRequest,
              child: Text(isBusy ? '...' : 'QR Oluştur'),
            ),
          ],
        ),
      ],
    );
  }
}

