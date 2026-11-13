import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../widgets/status_badge_widget.dart';
import '../bloc/virtual_pos_cubit.dart';
import 'pos_commission_summary_card.dart';

/// B2B Sanal POS 48 saniyede yenilenen dinamik QR Tahsilat sekmesi içeriği.
class PosQrPaymentCard extends StatelessWidget {
  final String companyId;
  final VirtualPosCubit cubit;
  final VirtualPosState state;
  final VoidCallback? onSimulateQrPay;
  final VoidCallback onOpenCustomerScanner;
  final VoidCallback onBackToCard;

  const PosQrPaymentCard({
    super.key,
    required this.companyId,
    required this.cubit,
    required this.state,
    required this.onSimulateQrPay,
    required this.onOpenCustomerScanner,
    required this.onBackToCard,
  });

  @override
  Widget build(BuildContext context) {
    final description = cubit.descriptionController.text.trim().isEmpty
        ? 'Kurumsal Hizmet Tahsilatı'
        : cubit.descriptionController.text.trim();
    final payload = state.qrPayload(companyId, description: description);

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
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
              _PosQrHeaderRow(generationCount: state.qrGenerationCount),
              const SizedBox(height: 16),
              _PosQrCodeFrame(
                payload: payload,
                isUrgent: state.isQrUrgent,
              ),
              const SizedBox(height: 14),
              Text(
                'Nova Tasarım Ltd. • Kasa Terminali (POS-TR-8492)',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkNavy,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Tahsilat Tutarı: ${state.formattedAmount} • Ref: #${state.shortQrToken}',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primaryTeal,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              _PosQrCountdownBanner(state: state),
              const SizedBox(height: 12),
              _PosQrControlButtonsRow(
                onRegenerate: cubit.regeneratePosQr,
                onCopy: () {
                  Clipboard.setData(ClipboardData(text: payload));
                  cubit.notifyQrCopied();
                },
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.darkNavy,
                    backgroundColor: const Color(0xFFF8FAFC),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: state.isProcessing ? null : onOpenCustomerScanner,
                  icon: const Icon(
                    Icons.qr_code_scanner_rounded,
                    size: 16,
                    color: AppColors.primaryTeal,
                  ),
                  label: const Text(
                    'Müşterinin B2C QR Kodunu Okutarak Tahsil Et',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        PosCommissionSummaryCard(state: state),
        const SizedBox(height: 14),
        if (onSimulateQrPay != null) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryTeal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: state.isProcessing ? null : onSimulateQrPay,
              icon: const Icon(Icons.check_circle_rounded, size: 18),
              label: Text(
                state.isProcessing
                    ? 'QR Ödeme Doğrulanıyor...'
                    : 'Müşteri Ödemesini Tamamla (${state.formattedAmount})',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.darkNavy,
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFE2E8F0)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: onBackToCard,
            icon: const Icon(Icons.credit_card_rounded, size: 18),
            label: const Text(
              'Kart ile Çekim Ekranına Dön',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}

class _PosQrHeaderRow extends StatelessWidget {
  final int generationCount;

  const _PosQrHeaderRow({required this.generationCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Flexible(
          child: StatusBadgeWidget(
            label: 'PayPulse POS • TR Karekod',
            type: BadgeType.success,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            'Kasa QR #$generationCount',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.darkNavy,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _PosQrCodeFrame extends StatelessWidget {
  final String payload;
  final bool isUrgent;

  const _PosQrCodeFrame({
    required this.payload,
    required this.isUrgent,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      child: Container(
        key: ValueKey<String>(payload),
        width: 224,
        height: 224,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isUrgent ? AppColors.warningOrange : AppColors.primaryTeal,
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryTeal.withValues(alpha: 0.14),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: QrImageView(
          data: payload,
          version: QrVersions.auto,
          errorCorrectionLevel: QrErrorCorrectLevel.M,
          size: 194,
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

class _PosQrCountdownBanner extends StatelessWidget {
  final VirtualPosState state;

  const _PosQrCountdownBanner({required this.state});

  @override
  Widget build(BuildContext context) {
    final isUrgent = state.isQrUrgent;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.timer_outlined,
                size: 15,
                color: isUrgent ? AppColors.expenseRed : AppColors.primaryTeal,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Güvenlik için POS QR kodu ${state.formattedQrCountdown} saniye içinde yenilenir',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isUrgent
                        ? AppColors.expenseRed
                        : const Color(0xFF475569),
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: state.qrProgress,
              minHeight: 5,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(
                isUrgent ? AppColors.expenseRed : AppColors.primaryTeal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PosQrControlButtonsRow extends StatelessWidget {
  final VoidCallback onRegenerate;
  final VoidCallback onCopy;

  const _PosQrControlButtonsRow({
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
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: onRegenerate,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text(
              'Yeni QR Üret (48sn)',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryTeal,
              side: const BorderSide(color: AppColors.primaryTeal),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: onCopy,
            icon: const Icon(Icons.copy_rounded, size: 15),
            label: const Text(
              'QR Kodu Kopyala',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}
