import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/formatters/currency_and_card_formatters.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/financial_amount.dart';
import '../../../core/validators/financial_validators.dart';
import '../../../domain/repositories/i_expense_repository.dart';
import '../../widgets/role_switch_app_bar.dart';
import '../../widgets/status_badge_widget.dart';
import '../auth/bloc/auth_bloc.dart';
import 'bloc/ocr_verification_cubit.dart';

/// AI-OCR Fiş Veri Doğrulama ve Muhasebeleştirme Ekranı (Stateless + OcrVerificationCubit)
class OcrDataVerificationScreen extends StatelessWidget {
  final OcrExtractedData? initialData;

  const OcrDataVerificationScreen({super.key, this.initialData});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OcrVerificationCubit>(
      create: (ctx) => OcrVerificationCubit(
        expenseRepository: ctx.read<IExpenseRepository>(),
        initialData: initialData,
      ),
      child: const _OcrDataVerificationBody(),
    );
  }
}

class _OcrDataVerificationBody extends StatelessWidget {
  const _OcrDataVerificationBody();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OcrVerificationCubit>();

    return MultiBlocListener(
      listeners: [
        BlocListener<OcrVerificationCubit, OcrVerificationState>(
          listenWhen: (prev, curr) => !prev.isSubmitted && curr.isSubmitted,
          listener: (ctx, _) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              const SnackBar(
                content: Text(
                  'Masraf kaydı ve fiş görseli başarıyla onaya gönderildi.',
                ),
                backgroundColor: AppColors.primaryTeal,
              ),
            );
            ctx.pop();
          },
        ),
        BlocListener<OcrVerificationCubit, OcrVerificationState>(
          listenWhen: (prev, curr) =>
              curr.errorMessage != null &&
              prev.errorMessage != curr.errorMessage,
          listener: (ctx, state) {
            final msg = state.errorMessage;
            if (msg == null) return;
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text(msg),
                backgroundColor: AppColors.expenseRed,
              ),
            );
            ctx.read<OcrVerificationCubit>().clearError();
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: const RoleSwitchAppBar(
          isBusinessMode: true,
          showBackButton: true,
          customTitle: 'OCR Veri Doğrulama',
          customSubtitle: 'Fiş Matrah & KDV Kontrolü',
        ),
        body: BlocBuilder<OcrVerificationCubit, OcrVerificationState>(
          builder: (context, state) {
            final actor = context.watch<AuthBloc>().state.user;
            final confidencePct = (state.confidence * 100).round();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: cubit.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Özet Kartı
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('AI-OCR Ayrıştırma Sonucu'),
                              StatusBadgeWidget(
                                label: '%$confidencePct Güven Skoru',
                                type: BadgeType.success,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: cubit.merchantController,
                            decoration: const InputDecoration(
                              labelText: 'Tedarikçi / İşyeri Ünvanı',
                              hintText: 'Örn: Petrol Ofisi A.Ş.',
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'İşyeri ünvanı zorunludur.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: cubit.amountController,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                            inputFormatters: [TurkishCurrencyInputFormatter()],
                            onChanged: cubit.onAmountChanged,
                            decoration: const InputDecoration(
                              labelText: 'Toplam Tutar (KDV Dahil)',
                              prefixText: '₺ ',
                              hintText: '0,00',
                            ),
                            validator: FinancialValidators.amount,
                          ),
                          const SizedBox(height: 12),

                          // KDV Oran Çipleri
                          Text(
                            'KDV Oranı',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: OcrVerificationState.vatRates.map((rate) {
                              final selected = state.selectedVatRate == rate;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text('%$rate'),
                                  selected: selected,
                                  onSelected: (_) => cubit.selectVatRate(rate),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: cubit.vatController,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                            inputFormatters: [TurkishCurrencyInputFormatter()],
                            decoration: const InputDecoration(
                              labelText: 'Ayrıştırılan KDV Tutarı',
                              prefixText: '₺ ',
                            ),
                            validator: (v) {
                              final vatKurus = FinancialAmount.parse(v) ?? 0;
                              final totalKurus =
                                  FinancialAmount.parse(
                                    cubit.amountController.text,
                                  ) ??
                                  0;
                              if (vatKurus < 0 || vatKurus > totalKurus) {
                                return 'KDV toplam tutarı aşamaz.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Kategori Çipleri
                          Text(
                            'Masraf Kategorisi',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: OcrVerificationState.categories.map((cat) {
                              final selected = state.selectedCategory == cat;
                              return ChoiceChip(
                                label: Text(cat),
                                selected: selected,
                                selectedColor: const Color(0xFFD1FAE5),
                                onSelected: (_) => cubit.selectCategory(cat),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: cubit.accountingCodeController,
                                  decoration: const InputDecoration(
                                    labelText: 'Hesap Planı Kodu',
                                    hintText: '770.01',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  controller: cubit.noteController,
                                  decoration: const InputDecoration(
                                    labelText: 'Açıklama (Opsiyonel)',
                                  ),
                                ),
                              ),
                            ],
                          ),

                          if (state.receiptImagePath.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.image_outlined,
                                    color: AppColors.primaryTeal,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Fiş Belgesi: ${state.receiptImagePath}',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: const Color(0xFF475569),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
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
                        onPressed: state.isSubmitting
                            ? null
                            : () => cubit.submitExpense(actor: actor),
                        icon: state.isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.check_circle_rounded),
                        label: Text(
                          state.isSubmitting
                              ? 'Fiş Yükleniyor ve Kaydediliyor...'
                              : 'Doğrula ve Masrafı Onaya Gönder',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
