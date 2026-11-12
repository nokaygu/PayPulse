import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/financial_amount.dart';
import 'virtual_pos_state.dart';

class VirtualPosCubit extends Cubit<VirtualPosState> {
  VirtualPosCubit() : super(const VirtualPosState());

  /// Tutar girişi değiştiğinde anlık komisyon ve net tutar hesaplar
  void amountChanged(String val) {
    final kurus = FinancialAmount.parse(val) ?? 0;

    String? error;
    if (kurus <= 0) {
      error = 'Çekim tutarı 0\'dan büyük olmalıdır.';
    }

    emit(state.copyWith(
      amountInput: val,
      grossAmountKurus: kurus,
      errorMessage: error,
      clearError: error == null,
    ));
  }

  /// Taksit seçimi (Tek Çekim, 3 Taksit, 6 Taksit)
  void installmentChanged(InstallmentOption option) {
    emit(state.copyWith(selectedInstallment: option));
  }

  /// POS Tahsilatını gerçekleştir
  Future<void> submitPayment() async {
    if (state.grossAmountKurus <= 0) {
      emit(state.copyWith(
        errorMessage: 'Geçerli bir tahsilat tutarı giriniz.',
      ));
      return;
    }

    emit(state.copyWith(
      status: VirtualPosStatus.processing,
      clearError: true,
    ));

    try {
      await Future<void>.delayed(const Duration(milliseconds: 1000));

      final ref =
          'POS-TRX-${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}-${Random().nextInt(899999) + 100000}';

      emit(state.copyWith(
        status: VirtualPosStatus.success,
        transactionRef: ref,
        successMessage: 'Ödeme başarıyla tamamlandı. Net tutar hesabınıza aktarıldı.',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: VirtualPosStatus.failure,
        errorMessage: 'POS işlemi başarısız: $e',
      ));
    }
  }

  void reset() {
    emit(const VirtualPosState());
  }
}

