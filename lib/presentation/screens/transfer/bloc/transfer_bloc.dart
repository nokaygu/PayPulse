import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/financial_amount.dart';
import '../../../../core/validators/financial_validators.dart';
import '../../../../domain/entities/fast_receipt.dart';
import 'transfer_event.dart';
import 'transfer_state.dart';

class TransferBloc extends Bloc<TransferEvent, TransferState> {
  TransferBloc() : super(const TransferState()) {
    on<TransferRecipientChanged>(_onRecipientChanged);
    on<TransferIbanChanged>(_onIbanChanged);
    on<TransferAmountChanged>(_onAmountChanged);
    on<TransferQuickAmountSelected>(_onQuickAmountSelected);
    on<TransferDescriptionChanged>(_onDescriptionChanged);
    on<TransferSubmitted>(_onSubmitted);
    on<TransferReset>(_onReset);
  }

  void _onRecipientChanged(
    TransferRecipientChanged event,
    Emitter<TransferState> emit,
  ) {
    final name = event.recipientName;
    String? error;
    if (name.trim().isEmpty) {
      error = 'Alıcı adı ve soyadı gereklidir.';
    } else if (name.trim().length < 3) {
      error = 'En az 3 karakter giriniz.';
    }

    emit(state.copyWith(
      status: TransferStatus.editing,
      recipientName: name,
      recipientError: error,
      clearRecipientError: error == null,
      clearGeneralError: true,
    ));
  }

  void _onIbanChanged(
    TransferIbanChanged event,
    Emitter<TransferState> emit,
  ) {
    final iban = event.iban;
    String? error;

    if (iban.trim().isEmpty) {
      error = 'IBAN numarası gereklidir.';
    } else {
      error = FinancialValidators.iban(iban);
    }

    emit(state.copyWith(
      status: TransferStatus.editing,
      recipientIban: iban,
      ibanError: error,
      clearIbanError: error == null,
      clearGeneralError: true,
    ));
  }

  void _onAmountChanged(
    TransferAmountChanged event,
    Emitter<TransferState> emit,
  ) {
    final input = event.amount;
    final kurus = FinancialAmount.parse(input) ?? 0;
    final error = FinancialValidators.amount(input);

    emit(state.copyWith(
      status: TransferStatus.editing,
      amountInput: input,
      amountKurus: kurus,
      amountError: error,
      clearAmountError: error == null,
      clearGeneralError: true,
    ));
  }

  void _onQuickAmountSelected(
    TransferQuickAmountSelected event,
    Emitter<TransferState> emit,
  ) {
    final kurus = event.amountKurus;
    final formatted = FinancialAmount.format(kurus);

    emit(state.copyWith(
      status: TransferStatus.editing,
      amountInput: formatted,
      amountKurus: kurus,
      amountError: null,
      clearAmountError: true,
      clearGeneralError: true,
    ));
  }

  void _onDescriptionChanged(
    TransferDescriptionChanged event,
    Emitter<TransferState> emit,
  ) {
    emit(state.copyWith(
      status: TransferStatus.editing,
      description: event.description,
      clearGeneralError: true,
    ));
  }

  Future<void> _onSubmitted(
    TransferSubmitted event,
    Emitter<TransferState> emit,
  ) async {
    // 1. Son validasyon kontrolleri
    final recipientErr = state.recipientName.trim().length < 3
        ? 'Geçerli bir alıcı adı giriniz.'
        : null;
    final ibanErr = FinancialValidators.iban(state.recipientIban);
    final amountErr = FinancialValidators.amount(
      state.amountInput,
      balanceKurus: event.currentBalanceKurus,
    );

    if (recipientErr != null || ibanErr != null || amountErr != null) {
      emit(state.copyWith(
        status: TransferStatus.editing,
        recipientError: recipientErr,
        ibanError: ibanErr,
        amountError: amountErr,
      ));
      return;
    }

    // 2. Yetersiz Bakiye Kontrolü
    if (state.amountKurus > event.currentBalanceKurus) {
      emit(state.copyWith(
        status: TransferStatus.failure,
        generalError: 'Yetersiz bakiye! Transfer tutarı mevcut bakiyenizi aşıyor.',
      ));
      return;
    }

    emit(state.copyWith(status: TransferStatus.submitting, clearGeneralError: true));

    try {
      // FAST ağ simülasyonu
      await Future<void>.delayed(const Duration(milliseconds: 1200));

      final randomRef =
          'PP-FAST-${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}-${Random().nextInt(899999) + 100000}';

      final receipt = FastReceipt(
        transactionId: randomRef,
        recipientName: state.recipientName.trim(),
        recipientIban: FinancialValidators.normalizeIban(state.recipientIban),
        amountKurus: state.amountKurus,
        remainingBalanceKurus: event.currentBalanceKurus - state.amountKurus,
        completedAt: DateTime.now(),
        description: state.description.trim().isEmpty
            ? 'FAST Para Transferi'
            : state.description.trim(),
      );

      emit(state.copyWith(
        status: TransferStatus.success,
        receipt: receipt,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TransferStatus.failure,
        generalError: 'Transfer gerçekleştirilemedi: $e',
      ));
    }
  }

  void _onReset(
    TransferReset event,
    Emitter<TransferState> emit,
  ) {
    emit(const TransferState());
  }
}

