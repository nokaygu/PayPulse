import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_limits.dart';
import '../../../../core/utils/equatable.dart';
import '../../../../core/utils/financial_amount.dart';
import '../../../../core/validators/financial_validators.dart';
import '../../../../domain/entities/pos_transaction_entity.dart';
import '../../../../domain/entities/transaction_entity.dart';
import '../../../../domain/entities/user_entity.dart';
import '../../../../domain/repositories/i_transaction_repository.dart';
import '../../../../domain/use_cases/execute_pos_payment_use_case.dart';

class VirtualPosState extends Equatable {
  final bool isCardTab;
  final int amountKurus;
  final int selectedInstallment;
  final bool isProcessing;
  final bool isLoadingZReport;
  final List<PosTransactionEntity> posTransactions;
  final String cardHolderPreview;
  final String cardNumberPreview;
  final String expiryPreview;
  final bool isCardLuhnValid;
  final TransactionEntity? completedTransaction;
  final String? errorMessage;

  const VirtualPosState({
    this.isCardTab = true,
    this.amountKurus = 375000, // Varsayılan: ₺3.750,00
    this.selectedInstallment = 1,
    this.isProcessing = false,
    this.isLoadingZReport = false,
    this.posTransactions = const [],
    this.cardHolderPreview = 'KART SAHİBİ',
    this.cardNumberPreview = '••••  ••••  ••••  ••••',
    this.expiryPreview = 'AA/YY',
    this.isCardLuhnValid = false,
    this.completedTransaction,
    this.errorMessage,
  });

  int get commissionKurus => FinancialAmount.posCommission(amountKurus);

  int get netAmountKurus =>
      amountKurus > commissionKurus ? amountKurus - commissionKurus : 0;

  double get commissionRatePercent => AppLimits.posCommissionBps / 100.0;

  String get formattedAmount => FinancialAmount.format(amountKurus);

  String get formattedCommission => FinancialAmount.format(commissionKurus);

  String get formattedNetAmount => FinancialAmount.format(netAmountKurus);

  int installmentAmountKurus(int count) =>
      count > 0 ? (amountKurus / count).round() : amountKurus;

  double get zReportTotalTl =>
      posTransactions.fold<double>(0.0, (sum, tx) => sum + tx.grossAmount);

  double get zReportNetTl =>
      posTransactions.fold<double>(0.0, (sum, tx) => sum + tx.netAmount);

  String qrPayload(String companyId) =>
      'paypulse://pos/$companyId?amount=$amountKurus&currency=TRY&inst=$selectedInstallment';

  VirtualPosState copyWith({
    bool? isCardTab,
    int? amountKurus,
    int? selectedInstallment,
    bool? isProcessing,
    bool? isLoadingZReport,
    List<PosTransactionEntity>? posTransactions,
    String? cardHolderPreview,
    String? cardNumberPreview,
    String? expiryPreview,
    bool? isCardLuhnValid,
    TransactionEntity? completedTransaction,
    bool clearCompleted = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return VirtualPosState(
      isCardTab: isCardTab ?? this.isCardTab,
      amountKurus: amountKurus ?? this.amountKurus,
      selectedInstallment: selectedInstallment ?? this.selectedInstallment,
      isProcessing: isProcessing ?? this.isProcessing,
      isLoadingZReport: isLoadingZReport ?? this.isLoadingZReport,
      posTransactions: posTransactions ?? this.posTransactions,
      cardHolderPreview: cardHolderPreview ?? this.cardHolderPreview,
      cardNumberPreview: cardNumberPreview ?? this.cardNumberPreview,
      expiryPreview: expiryPreview ?? this.expiryPreview,
      isCardLuhnValid: isCardLuhnValid ?? this.isCardLuhnValid,
      completedTransaction: clearCompleted
          ? null
          : (completedTransaction ?? this.completedTransaction),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    isCardTab,
    amountKurus,
    selectedInstallment,
    isProcessing,
    isLoadingZReport,
    posTransactions,
    cardHolderPreview,
    cardNumberPreview,
    expiryPreview,
    isCardLuhnValid,
    completedTransaction,
    errorMessage,
  ];
}

class VirtualPosCubit extends Cubit<VirtualPosState> {
  final ITransactionRepository _txRepo;
  final ExecutePosPaymentUseCase _executePosUseCase;

  final GlobalKey<FormState> cardFormKey = GlobalKey<FormState>();
  final TextEditingController amountController = TextEditingController(
    text: FinancialAmount.input(375000),
  );
  final TextEditingController descriptionController = TextEditingController(
    text: 'Kurumsal Hizmet Tahsilatı',
  );
  final TextEditingController emailController = TextEditingController();
  final TextEditingController cardHolderController = TextEditingController();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiryController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();

  VirtualPosCubit({
    required ITransactionRepository transactionRepository,
    ExecutePosPaymentUseCase? executePosUseCase,
  }) : _txRepo = transactionRepository,
       _executePosUseCase =
           executePosUseCase ?? ExecutePosPaymentUseCase(transactionRepository),
       super(const VirtualPosState()) {
    cardHolderController.addListener(_syncCardPreview);
    cardNumberController.addListener(_syncCardPreview);
    expiryController.addListener(_syncCardPreview);
  }

  Future<void> loadPosHistory(String companyId) async {
    if (companyId.isEmpty) return;
    emit(state.copyWith(isLoadingZReport: true));
    try {
      final list = await _txRepo.getPosTransactions(companyId);
      emit(state.copyWith(isLoadingZReport: false, posTransactions: list));
    } catch (_) {
      emit(state.copyWith(isLoadingZReport: false));
    }
  }

  void setTab({required bool isCard}) {
    emit(state.copyWith(isCardTab: isCard, clearError: true));
  }

  void onAmountTextChanged(String raw) {
    final parsed = FinancialAmount.parse(raw) ?? 0;
    emit(state.copyWith(amountKurus: parsed, clearError: true));
  }

  void addQuickAmountKurus(int addKurus) {
    final next = (state.amountKurus + addKurus).clamp(
      0,
      AppLimits.maxTransactionKurus,
    );
    amountController.text = next > 0 ? FinancialAmount.input(next) : '';
    emit(state.copyWith(amountKurus: next, clearError: true));
  }

  void clearAmount() {
    amountController.clear();
    emit(state.copyWith(amountKurus: 0, clearError: true));
  }

  void selectInstallment(int installment) {
    emit(state.copyWith(selectedInstallment: installment));
  }

  void _syncCardPreview() {
    final holder = cardHolderController.text.trim();
    final digits = FinancialValidators.normalizeCard(cardNumberController.text);
    final expiry = expiryController.text.trim();

    String maskedPreview = '••••  ••••  ••••  ••••';
    if (digits.length >= 4) {
      final first4 = digits.substring(0, 4);
      final last4 = digits.length >= 16
          ? digits.substring(digits.length - 4)
          : digits.substring(4).padRight(4, '•');
      maskedPreview = '$first4  ••••  ••••  $last4';
    } else if (digits.isNotEmpty) {
      maskedPreview = digits.padRight(4, '•');
    }

    final luhnOk =
        digits.length >= 13 && FinancialValidators.isLuhnValid(digits);

    emit(
      state.copyWith(
        cardHolderPreview: holder.isEmpty
            ? 'KART SAHİBİ'
            : holder.toUpperCase(),
        cardNumberPreview: maskedPreview,
        expiryPreview: expiry.isEmpty ? 'AA/YY' : expiry,
        isCardLuhnValid: luhnOk,
      ),
    );
  }

  String get _maskedSubmissionCard {
    final digits = FinancialValidators.normalizeCard(cardNumberController.text);
    final last4 = digits.length >= 4
        ? digits.substring(digits.length - 4)
        : '0000';
    return '•••• •••• •••• $last4';
  }

  Future<void> submitCardPayment({
    required UserEntity? actor,
    required String companyId,
  }) async {
    if (state.isProcessing) return;
    if (actor == null || companyId.isEmpty) {
      emit(
        state.copyWith(
          errorMessage: 'POS işlemi için yetkili bir şirket hesabı bulunamadı.',
        ),
      );
      return;
    }

    if (!(cardFormKey.currentState?.validate() ?? false)) {
      emit(
        state.copyWith(
          errorMessage: 'Lütfen kart bilgilerini eksiksiz ve geçerli giriniz.',
        ),
      );
      return;
    }

    if (state.amountKurus < AppLimits.minTransferKurus) {
      emit(
        state.copyWith(
          errorMessage:
              'Tahsilat tutarı en az ${FinancialAmount.format(AppLimits.minTransferKurus)} olmalıdır.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isProcessing: true,
        clearError: true,
        clearCompleted: true,
      ),
    );

    try {
      final tx = await _executePosUseCase.executeCard(
        actor: actor,
        companyId: companyId,
        maskedCardNumber: _maskedSubmissionCard,
        amountKurus: state.amountKurus,
      );
      final updatedPosList = await _txRepo.getPosTransactions(companyId);
      emit(
        state.copyWith(
          isProcessing: false,
          completedTransaction: tx,
          posTransactions: updatedPosList,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isProcessing: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> submitQrPayment({
    required String companyId,
    required String payerUserId,
  }) async {
    if (state.isProcessing) return;
    if (companyId.isEmpty || payerUserId.isEmpty) {
      emit(
        state.copyWith(
          errorMessage: 'QR POS tahsilatı için aktif hesap bilgisi eksik.',
        ),
      );
      return;
    }

    if (state.amountKurus < AppLimits.minTransferKurus) {
      emit(
        state.copyWith(
          errorMessage:
              'QR tahsilat tutarı en az ${FinancialAmount.format(AppLimits.minTransferKurus)} olmalıdır.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isProcessing: true,
        clearError: true,
        clearCompleted: true,
      ),
    );

    try {
      final tx = await _executePosUseCase.executeQrWallet(
        companyId: companyId,
        payerUserId: payerUserId,
        amountKurus: state.amountKurus,
      );
      final updatedPosList = await _txRepo.getPosTransactions(companyId);
      emit(
        state.copyWith(
          isProcessing: false,
          completedTransaction: tx,
          posTransactions: updatedPosList,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isProcessing: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  void clearCompletedTransaction() {
    emit(state.copyWith(clearCompleted: true));
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  @override
  Future<void> close() {
    cardHolderController.removeListener(_syncCardPreview);
    cardNumberController.removeListener(_syncCardPreview);
    expiryController.removeListener(_syncCardPreview);
    amountController.dispose();
    descriptionController.dispose();
    emailController.dispose();
    cardHolderController.dispose();
    cardNumberController.dispose();
    expiryController.dispose();
    cvvController.dispose();
    return super.close();
  }
}

