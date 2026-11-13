import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_limits.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/financial_amount.dart';
import '../../../domain/repositories/i_payment_request_repository.dart';
import '../../../domain/repositories/i_transaction_repository.dart';
import '../../../domain/repositories/i_wallet_repository.dart';
import '../../widgets/four_state_view.dart';
import '../auth/bloc/auth_bloc.dart';
import 'bloc/transfer_cubits.dart';

/// 7/24 FAST Para Transferi Onay (Adım 3/4) ve /pay/:requestId Deep Link Ekranı
class TransferSummaryScreen extends StatelessWidget {
  final String recipientIban;
  final String recipientName;
  final int amountInKurus;
  final String description;
  final String? paymentRequestId;

  const TransferSummaryScreen({
    super.key,
    this.recipientIban = 'TR34 0006 2000 0001 2345 6789 01',
    this.recipientName = 'Zeynep Kaya',
    this.amountInKurus = 150000,
    this.description = 'FAST Para Transferi',
    this.paymentRequestId,
  });

  @override
  Widget build(BuildContext context) {
    final senderUserId =
        context.watch<AuthBloc>().state.user?.uid ?? AppStrings.demoB2CUid;
    final senderName =
        context.watch<AuthBloc>().state.user?.name ?? 'PayPulse Kullanıcısı';

    return BlocProvider<TransferSummaryCubit>(
      create: (ctx) => TransferSummaryCubit(
        walletRepository: ctx.read<IWalletRepository>(),
        transactionRepository: ctx.read<ITransactionRepository>(),
        paymentRequestRepository: ctx.read<IPaymentRequestRepository>(),
        recipientIban: recipientIban,
        recipientName: recipientName,
        amountInKurus: amountInKurus,
        description: description,
        paymentRequestId: paymentRequestId,
      )..initialize(senderUserId: senderUserId),
      child: _TransferSummaryView(
        senderUserId: senderUserId,
        senderName: senderName,
      ),
    );
  }
}

class _TransferSummaryView extends StatelessWidget {
  final String senderUserId;
  final String senderName;

  const _TransferSummaryView({
    required this.senderUserId,
    required this.senderName,
  });

  Future<void> _showFraudConfirmationDialog(
    BuildContext context,
    TransferSummaryCubit cubit,
    int amountInKurus,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.shield_outlined, color: AppColors.warningOrange),
            SizedBox(width: 8),
            Expanded(child: Text('Yüksek Tutar Güvenlik Kontrolü')),
          ],
        ),
        content: Text(
          '${FinancialAmount.format(amountInKurus)} tutarındaki işleminiz '
          '${FinancialAmount.format(AppLimits.fraudLimitInKurus)} güvenlik eşiği üzerindedir.\n\n'
          'Alıcı ve tutar bilgilerinin doğruluğunu onaylıyor musunuz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkNavy,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Güvenle Onayla'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await cubit.confirmTransfer(
        senderUserId: senderUserId,
        fraudConfirmed: true,
      );
    } else {
      cubit.dismissFraudPrompt();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TransferSummaryCubit>();

    return BlocConsumer<TransferSummaryCubit, TransferSummaryState>(
      listener: (context, state) {
        if (state.requiresFraudDialog) {
          _showFraudConfirmationDialog(context, cubit, state.amountInKurus);
        } else if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.expenseRed,
              content: Text(state.errorMessage!),
            ),
          );
          cubit.clearError();
        } else if (state.completedTransaction != null) {
          final tx = state.completedTransaction!;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.primaryGreen,
              content: Text('TCMB FAST transferi anında tamamlandı!'),
            ),
          );
          context.go('/home/transfer/receipt/${tx.txId}');
        }
      },
      builder: (context, state) {
        final senderBalanceText = state.senderWallet != null
            ? FinancialAmount.format(state.senderWallet!.balanceTl)
            : 'Bakiye doğrulanıyor...';

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SafeArea(
            child: FourStateView(
              status: state.loadStatus,
              errorMessage:
                  state.errorMessage ?? 'Transfer özeti yüklenemedi.',
              emptyMessage: 'Ödeme talebi bulunamadı veya süresi doldu.',
              onRetry: () => cubit.initialize(senderUserId: senderUserId),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Üst Geri ve Başlık Satırı
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go(AppRoutes.home);
                            }
                          },
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE2E8F0),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              size: 18,
                              color: AppColors.darkNavy,
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              state.isPaymentRequestFlow
                                  ? 'Ödeme Talebi Onayı'
                                  : 'Transfer Özeti',
                              style: AppTextStyles.headlineSmall.copyWith(
                                color: AppColors.darkNavy,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.lock_outline_rounded,
                                  size: 12,
                                  color: AppColors.primaryTeal,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '256-Bit SSL Uçtan Uca Şifreli',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.primaryTeal,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: const Icon(
                            Icons.verified_user_outlined,
                            size: 18,
                            color: AppColors.primaryTeal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 4 Adımlı Stepper
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StepCircle('1. Alıcı', stepNum: 1, isCompleted: true),
                          _StepCircle('2. Tutar', stepNum: 2, isCompleted: true),
                          _StepCircle('3. Onay', stepNum: 3, isCurrent: true),
                          _StepCircle('4. Sonuç', stepNum: 4),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Toplam Gönderilecek Tutar Koyu Kartı
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 22,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.heroCardGradient,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.darkNavy.withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'TOPLAM GÖNDERİLECEK TUTAR',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: const Color(0xFF94A3B8),
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            FinancialAmount.format(state.amountInKurus),
                            style: AppTextStyles.numericBalance.copyWith(
                              color: Colors.white,
                              fontSize: 36,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF5EEAD4),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'TCMB FAST • 7/24 Anında Transfer',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: const Color(0xFF5EEAD4),
                                    fontSize: 10.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Transfer Ayrıntıları Beyaz Kartı
                    Container(
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
                              Text(
                                'Transfer Ayrıntıları',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.darkNavy,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
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
                          ),
                          const SizedBox(height: 16),

                          // Gönderen Hesap (Dinamik Auth & Wallet)
                          Row(
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
                          ),
                          const SizedBox(height: 16),

                          // Alıcı
                          Row(
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Alıcı',
                                          style: AppTextStyles.bodySmall
                                              .copyWith(
                                                color: const Color(0xFF64748B),
                                                fontSize: 11,
                                              ),
                                        ),
                                        Text(
                                          '✓ FAST Doğrulandı',
                                          style: AppTextStyles.labelSmall
                                              .copyWith(
                                                color: AppColors.primaryTeal,
                                                fontWeight: FontWeight.w800,
                                              ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      state.recipientName,
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.darkNavy,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      state.recipientIban,
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
                          ),
                          const SizedBox(height: 12),

                          // Açıklama Kutusu
                          Container(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Açıklama',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: const Color(0xFF64748B),
                                          fontSize: 10.5,
                                        ),
                                      ),
                                      Text(
                                        state.description,
                                        style: AppTextStyles.labelMedium
                                            .copyWith(
                                              color: AppColors.darkNavy,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    if (state.isAboveFraudThreshold)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFF59E0B)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: Color(0xFFB45309),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                AppStrings.fraudWarningMessage,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: const Color(0xFF92400E),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Onay Checkbox Kutusu
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: state.rulesAccepted,
                            activeColor: AppColors.primaryTeal,
                            onChanged: (v) =>
                                cubit.setRulesAccepted(v ?? true),
                          ),
                          Expanded(
                            child: Text(
                              'TCMB FAST transfer kurallarını, alıcı IBAN doğruluğunu ve işlem detaylarını kontrol ederek onaylıyorum.',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.darkNavy,
                                fontSize: 11.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Transferi Onayla Butonu
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkNavy,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: state.isSubmitting
                            ? null
                            : () => cubit.confirmTransfer(
                                senderUserId: senderUserId,
                              ),
                        icon: state.isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.face_unlock_outlined, size: 20),
                        label: Text(
                          state.isSubmitting
                              ? 'FAST İşlemi Yapılıyor...'
                              : 'Transferi Onayla (Biyometrik / PIN Simülasyonu)',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        onPressed: () => context.go(AppRoutes.home),
                        child: Text(
                          'Vazgeç ve İptal Et',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: const Color(0xFF475569),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StepCircle extends StatelessWidget {
  final String label;
  final int stepNum;
  final bool isCompleted;
  final bool isCurrent;

  const _StepCircle(
    this.label, {
    required this.stepNum,
    this.isCompleted = false,
    this.isCurrent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: isCompleted
                ? AppColors.primaryTeal
                : (isCurrent ? AppColors.darkNavy : const Color(0xFFF1F5F9)),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: isCompleted
              ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
              : Text(
                  '$stepNum',
                  style: TextStyle(
                    color: isCurrent ? Colors.white : const Color(0xFF64748B),
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: isCurrent ? AppColors.darkNavy : const Color(0xFF64748B),
            fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
            fontSize: 10.5,
          ),
        ),
      ],
    );
  }
}
