import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/formatters/currency_and_card_formatters.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/repositories/i_payment_request_repository.dart';
import '../../widgets/role_switch_app_bar.dart';
import '../../widgets/status_badge_widget.dart';
import '../auth/bloc/auth_bloc.dart';
import 'bloc/qr_payment_cubit.dart';

/// B2C Dinamik QR Kod ile Öde & Tahsil Et Ekranı (Stateless + QrPaymentCubit + qr_flutter + mobile_scanner)
class QrPaymentCenterScreen extends StatelessWidget {
  const QrPaymentCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<QrPaymentCubit>(
      create: (ctx) => QrPaymentCubit(
        paymentRequestRepository: ctx.read<IPaymentRequestRepository>(),
      ),
      child: const _QrPaymentCenterBody(),
    );
  }
}

class _QrPaymentCenterBody extends StatelessWidget {
  const _QrPaymentCenterBody();

  bool get _supportsLiveCamera =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<QrPaymentCubit>();

    return MultiBlocListener(
      listeners: [
        BlocListener<QrPaymentCubit, QrPaymentState>(
          listenWhen: (prev, curr) =>
              curr.navigateToPayRoute != null &&
              prev.navigateToPayRoute != curr.navigateToPayRoute,
          listener: (ctx, state) {
            final route = state.navigateToPayRoute;
            if (route == null) return;
            ctx.read<QrPaymentCubit>().clearNavigation();
            ctx.push(route);
          },
        ),
        BlocListener<QrPaymentCubit, QrPaymentState>(
          listenWhen: (prev, curr) =>
              curr.actionMessage != null &&
              prev.actionMessage != curr.actionMessage,
          listener: (ctx, state) {
            final msg = state.actionMessage;
            if (msg == null) return;
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text(msg),
                backgroundColor: state.isErrorAction
                    ? AppColors.expenseRed
                    : AppColors.primaryTeal,
              ),
            );
            ctx.read<QrPaymentCubit>().clearActionMessage();
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: const RoleSwitchAppBar(isBusinessMode: false),
        body: BlocBuilder<QrPaymentCubit, QrPaymentState>(
          builder: (context, state) {
            final user = context.watch<AuthBloc>().state.user;
            final userId = user?.uid ?? '';
            final userName = user?.name ?? 'PayPulse Kullanıcısı';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Üst Sekme Seçici
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0).withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        _ModeTab(
                          label: 'QR Kodumu Göster',
                          selected: state.isShowQrMode,
                          onTap: () => cubit.setMode(showMyQr: true),
                        ),
                        _ModeTab(
                          label: 'QR Okut ve Öde',
                          selected: !state.isShowQrMode,
                          onTap: () => cubit.setMode(showMyQr: false),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (state.isShowQrMode)
                    _ShowMyQrCard(
                      cubit: cubit,
                      state: state,
                      userId: userId,
                      userName: userName,
                    )
                  else
                    _ScanQrCard(
                      cubit: cubit,
                      state: state,
                      supportsCamera: _supportsLiveCamera,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModeTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: selected ? AppColors.darkNavy : const Color(0xFF64748B),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _ShowMyQrCard extends StatelessWidget {
  final QrPaymentCubit cubit;
  final QrPaymentState state;
  final String userId;
  final String userName;

  const _ShowMyQrCard({
    required this.cubit,
    required this.state,
    required this.userId,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          const StatusBadgeWidget(
            label: 'TCMB TR Karekod Uyumlu',
            type: BadgeType.success,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primaryGreen, width: 2),
            ),
            child: QrImageView(
              data: state.qrPayload(userId),
              version: QrVersions.auto,
              size: 190,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '$userName • ${state.qrToken}',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.darkNavy,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Güvenlik için kod ${state.formattedCountdown} saniye içinde yenilenir',
            style: AppTextStyles.bodySmall.copyWith(
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: cubit.regenerateQr,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Kodu Şimdi Yenile'),
          ),
          const Divider(height: 24),
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
                  controller: cubit.requestAmountController,
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
                onPressed: state.isBusy
                    ? null
                    : () => cubit.createPaymentRequestQr(
                        userId: userId,
                        userName: userName,
                      ),
                child: Text(state.isBusy ? '...' : 'QR Oluştur'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScanQrCard extends StatelessWidget {
  final QrPaymentCubit cubit;
  final QrPaymentState state;
  final bool supportsCamera;

  const _ScanQrCard({
    required this.cubit,
    required this.state,
    required this.supportsCamera,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Text(
            'Ödeme QR Kodu Okut',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.darkNavy,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 230,
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.primaryTeal, width: 2),
            ),
            child: supportsCamera
                ? MobileScanner(
                    onDetect: (capture) {
                      for (final barcode in capture.barcodes) {
                        final raw = barcode.rawValue;
                        if (raw != null && raw.isNotEmpty) {
                          cubit.handleScannedCode(raw);
                          break;
                        }
                      }
                    },
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.qr_code_scanner_rounded,
                        size: 56,
                        color: Color(0xFF5EEAD4),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Canlı kamera mobil cihazda otomatik açılır.\nAşağıdan QR bağlantısı / talep kodu girebilirsiniz.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: cubit.scanInputController,
            decoration: const InputDecoration(
              labelText: 'QR İçeriği veya Ödeme Talebi Kodu',
              hintText: 'Örn: paypulse://pay/req_001 veya req_001',
              prefixIcon: Icon(Icons.qr_code_rounded),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: state.isBusy
                  ? null
                  : () => cubit.handleScannedCode(
                      cubit.scanInputController.text,
                    ),
              icon: const Icon(Icons.bolt_rounded),
              label: Text(
                state.isBusy
                    ? 'Ödeme Talebi Kontrol Ediliyor...'
                    : 'QR Kodunu Doğrula ve Ödemeye Geç',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
