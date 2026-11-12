import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_limits.dart';
import '../../../../core/utils/financial_amount.dart';
import '../../../../core/validators/financial_validators.dart';
import '../../../../domain/entities/fast_receipt.dart';
import 'fast_transfer_state.dart';

class FastTransferCubit extends Cubit<FastTransferState> {
  FastTransferCubit() : super(const FastTransferState());

  /// 1. Adım: Alıcı adı güncellemesi
  void recipientChanged(String val) {
    String? error;
    if (val.trim().isEmpty) {
      error = 'Alıcı adı gereklidir.';
    } else if (val.trim().length < 3) {
      error = 'En az 3 karakter giriniz.';
    }

    emit(state.copyWith(
      recipientName: val,
      recipientError: error,
      clearRecipientError: error == null,
      clearGeneralError: true,
    ));
  }

  /// 1. Adım: IBAN güncellemesi ve validasyonu
  void ibanChanged(String val) {
    String? error;
    if (val.trim().isEmpty) {
      error = 'IBAN numarası gereklidir.';
    } else {
      error = FinancialValidators.iban(val);
    }

    emit(state.copyWith(
      recipientIban: val,
      ibanError: error,
      clearIbanError: error == null,
      clearGeneralError: true,
    ));
  }

  /// 2. Adım: Tutar metin girişi ve limit kontrolleri
  void amountChanged(String val, int balanceKurus) {
    final kurus = FinancialAmount.parse(val) ?? 0;
    _validateAndEmitAmount(kurus, balanceKurus);
  }

  /// 2. Adım: Hızlı tutar ekleme (+100 TL, +250 TL vb.)
  void addQuickAmount(int additionalKurus, int balanceKurus) {
    final nextKurus = state.amountKurus + additionalKurus;
    _validateAndEmitAmount(nextKurus, balanceKurus);
  }

  /// 2. Adım: "Tüm Bakiye" hesaplaması
  void setAllBalance(int balanceKurus) {
    _validateAndEmitAmount(balanceKurus, balanceKurus);
  }

  /// Tutar validasyonu ve Günlük / Aylık Limit Kontrolü
  void _validateAndEmitAmount(int kurus, int balanceKurus) {
    final formatted = FinancialAmount.format(kurus);
    String? amountErr;
    String? limitErr;

    if (kurus <= 0) {
      amountErr = 'Tutar 0\'dan büyük olmalıdır.';
    } else if (kurus > balanceKurus) {
      amountErr = 'Yetersiz bakiye! Mevcut bakiyenizi aşıyor.';
    }

    // Günlük limit kontrolü (logic.md: günlük/aylık limit kontrolü)
    if (state.dailySpentKurus + kurus > AppLimits.dailyFastLimitKurus) {
      final remainingDaily = AppLimits.dailyFastLimitKurus - state.dailySpentKurus;
      final remainingTl = (remainingDaily / 100.0).toStringAsFixed(2);
      limitErr = 'Günlük FAST limitiniz aşıldı! Kalan hakkınız: ₺$remainingTl';
    } else if (state.monthlySpentKurus + kurus > AppLimits.monthlyFastLimitKurus) {
      final remainingMonthly = AppLimits.monthlyFastLimitKurus - state.monthlySpentKurus;
      final remainingTl = (remainingMonthly / 100.0).toStringAsFixed(2);
      limitErr = 'Aylık FAST limitiniz aşıldı! Kalan hakkınız: ₺$remainingTl';
    }

    emit(state.copyWith(
      amountInput: formatted,
      amountKurus: kurus,
      amountError: amountErr,
      limitError: limitErr,
      clearAmountError: amountErr == null,
      clearLimitError: limitErr == null,
      clearGeneralError: true,
    ));
  }

  /// Açıklama güncellemesi
  void descriptionChanged(String val) {
    emit(state.copyWith(description: val));
  }

  /// İleri Adıma Geçiş (4 adımlı state yönetimi)
  void nextStep() {
    switch (state.currentStep) {
      case TransferStep.step1Recipient:
        if (state.canProceedStep1) {
          emit(state.copyWith(currentStep: TransferStep.step2Amount));
        }
        break;
      case TransferStep.step2Amount:
        if (state.canProceedStep2) {
          emit(state.copyWith(currentStep: TransferStep.step3Summary));
        }
        break;
      case TransferStep.step3Summary:
        // step3'te onay verilir submitTransfer çağrılır
        break;
      case TransferStep.step4Receipt:
        break;
    }
  }

  /// Önceki Adıma Dönüş
  void previousStep() {
    switch (state.currentStep) {
      case TransferStep.step1Recipient:
        break;
      case TransferStep.step2Amount:
        emit(state.copyWith(currentStep: TransferStep.step1Recipient));
        break;
      case TransferStep.step3Summary:
        emit(state.copyWith(currentStep: TransferStep.step2Amount));
        break;
      case TransferStep.step4Receipt:
        break;
    }
  }

  /// 4. Adım: FAST Transfer Onayı ve Dekont Üretimi
  Future<void> submitTransfer(int currentBalanceKurus) async {
    emit(state.copyWith(status: FastTransferStatus.loading, clearGeneralError: true));

    try {
      await Future<void>.delayed(const Duration(milliseconds: 1000));

      final randomRef =
          'PP-FAST-${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}-${Random().nextInt(899999) + 100000}';

      final receipt = FastReceipt(
        transactionId: randomRef,
        recipientName: state.recipientName.trim(),
        recipientIban: FinancialValidators.normalizeIban(state.recipientIban),
        amountKurus: state.amountKurus,
        remainingBalanceKurus: currentBalanceKurus - state.amountKurus,
        completedAt: DateTime.now(),
        description: state.description.trim().isEmpty
            ? 'FAST Para Transferi'
            : state.description.trim(),
      );

      emit(state.copyWith(
        status: FastTransferStatus.success,
        currentStep: TransferStep.step4Receipt,
        receipt: receipt,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FastTransferStatus.failure,
        generalError: 'Transfer gerçekleştirilemedi: $e',
      ));
    }
  }

  /// Akışı sıfırlama
  void reset() {
    emit(const FastTransferState());
  }
}

