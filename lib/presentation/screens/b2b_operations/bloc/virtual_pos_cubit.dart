import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_limits.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/equatable.dart';
import '../../../../core/utils/financial_amount.dart';
import '../../../../core/utils/qr_payload_parser.dart';
import '../../../../core/validators/financial_validators.dart';
import '../../../../domain/entities/pos_transaction_entity.dart';
import '../../../../domain/entities/transaction_entity.dart';
import '../../../../domain/entities/user_entity.dart';
import '../../../../domain/repositories/i_transaction_repository.dart';
import '../../../../domain/use_cases/execute_pos_payment_use_case.dart';

class VirtualPosState extends Equatable {
  static const int qrTtlSeconds = PayPulseQrPayload.defaultTtlSeconds;

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
  final String qrToken;
  final DateTime qrGeneratedAt;
  final int qrGenerationCount;
  final int remainingQrSeconds;
  final TransactionEntity? completedTransaction;
  final String? completedQrShortToken;
  final String? errorMessage;
  final String? infoMessage;

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
    this.qrToken = '',
    required this.qrGeneratedAt,
    this.qrGenerationCount = 1,
    this.remainingQrSeconds = qrTtlSeconds,
    this.completedTransaction,
    this.completedQrShortToken,
    this.errorMessage,
    this.infoMessage,
  });

  int get commissionKurus => FinancialAmount.posCommission(amountKurus);

  int get netAmountKurus =>
      amountKurus > commissionKurus ? amountKurus - commissionKurus : 0;

  double get commissionRatePercent => AppLimits.posCommissionBps / 100.0;

  String get formattedAmount => FinancialAmount.format(amountKurus);

  String get formattedCommission => FinancialAmount.format(commissionKurus);

  String get formattedNetAmount => FinancialAmount.format(netAmountKurus);

  double get qrProgress =>
      (remainingQrSeconds / qrTtlSeconds).clamp(0.0, 1.0);

  bool get isQrUrgent => remainingQrSeconds <= 10;

  String get shortQrToken {
    if (qrToken.length <= 8) return qrToken;
    return qrToken.substring(qrToken.length - 8);
  }

  String get formattedQrCountdown {
    final s = remainingQrSeconds.clamp(0, qrTtlSeconds);
    final mins = (s ~/ 60).toString().padLeft(2, '0');
    final secs = (s % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  int installmentAmountKurus(int count) =>
      count > 0 ? (amountKurus / count).round() : amountKurus;

  double get zReportTotalTl =>
      posTransactions.fold<double>(0.0, (sum, tx) => sum + tx.grossAmount);

  double get zReportNetTl =>
      posTransactions.fold<double>(0.0, (sum, tx) => sum + tx.netAmount);

  String qrPayload(
    String companyId, {
    String merchantName = 'Nova Tasarım Ltd.',
    String terminalId = 'POS-TR-8492',
    String description = 'Kurumsal Hizmet Tahsilatı',
  }) {
    return PayPulseQrPayload.buildB2bPosPayload(
      merchantName: merchantName,
      companyId: companyId,
      terminalId: terminalId,
      amount: amountKurus / 100.0,
      installment: selectedInstallment,
      description: description,
      token: qrToken,
      generatedAt: qrGeneratedAt,
      ttlSeconds: qrTtlSeconds,
    );
  }

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
    String? qrToken,
    DateTime? qrGeneratedAt,
    int? qrGenerationCount,
    int? remainingQrSeconds,
    TransactionEntity? completedTransaction,
    bool clearCompleted = false,
    String? completedQrShortToken,
    String? errorMessage,
    bool clearError = false,
    String? infoMessage,
    bool clearInfo = false,
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
      qrToken: qrToken ?? this.qrToken,
      qrGeneratedAt: qrGeneratedAt ?? this.qrGeneratedAt,
      qrGenerationCount: qrGenerationCount ?? this.qrGenerationCount,
      remainingQrSeconds: remainingQrSeconds ?? this.remainingQrSeconds,
      completedTransaction: clearCompleted
          ? null
          : (completedTransaction ?? this.completedTransaction),
      completedQrShortToken: clearCompleted
          ? null
          : (completedQrShortToken ?? this.completedQrShortToken),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
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
    qrToken,
    qrGeneratedAt,
    qrGenerationCount,
    remainingQrSeconds,
    completedTransaction,
    completedQrShortToken,
    errorMessage,
    infoMessage,
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
  final TextEditingController customerQrPasteController =
      TextEditingController();

  Timer? _qrCountdownTimer;

  VirtualPosCubit({
    required ITransactionRepository transactionRepository,
    ExecutePosPaymentUseCase? executePosUseCase,
    bool startQrTimer = true,
  }) : _txRepo = transactionRepository,
       _executePosUseCase =
           executePosUseCase ?? ExecutePosPaymentUseCase(transactionRepository),
       super(
         VirtualPosState(
           qrToken: PayPulseQrPayload.generateDynamicToken(prefix: 'PPPOS'),
           qrGeneratedAt: DateTime.now(),
           remainingQrSeconds: VirtualPosState.qrTtlSeconds,
         ),
       ) {
    cardHolderController.addListener(_syncCardPreview);
    cardNumberController.addListener(_syncCardPreview);
    expiryController.addListener(_syncCardPreview);
    if (startQrTimer) {
      _startQrTimer();
    }
  }

  void _startQrTimer() {
    _qrCountdownTimer?.cancel();
    _qrCountdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (isClosed) return;
      if (state.remainingQrSeconds <= 1) {
        emit(
          state.copyWith(
            qrToken: PayPulseQrPayload.generateDynamicToken(prefix: 'PPPOS'),
            qrGeneratedAt: DateTime.now(),
            qrGenerationCount: state.qrGenerationCount + 1,
            remainingQrSeconds: VirtualPosState.qrTtlSeconds,
          ),
        );
      } else {
        emit(state.copyWith(remainingQrSeconds: state.remainingQrSeconds - 1));
      }
    });
  }

  void regeneratePosQr() {
    emit(
      state.copyWith(
        qrToken: PayPulseQrPayload.generateDynamicToken(prefix: 'PPPOS'),
        qrGeneratedAt: DateTime.now(),
        qrGenerationCount: state.qrGenerationCount + 1,
        remainingQrSeconds: VirtualPosState.qrTtlSeconds,
      ),
    );
    if (_qrCountdownTimer != null) _startQrTimer();
  }

  Future<void> loadPosHistory(String companyId) async {
    if (companyId.isEmpty) return;
    emit(state.copyWith(isLoadingZReport: true));
    try {
      final list = await _txRepo.getPosTransactions(companyId);
      if (isClosed) return;
      emit(state.copyWith(isLoadingZReport: false, posTransactions: list));
    } catch (_) {
      if (isClosed) return;
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
    emit(
      state.copyWith(
        amountKurus: next,
        qrToken: PayPulseQrPayload.generateDynamicToken(prefix: 'PPPOS'),
        qrGeneratedAt: DateTime.now(),
        qrGenerationCount: state.qrGenerationCount + 1,
        remainingQrSeconds: VirtualPosState.qrTtlSeconds,
        clearError: true,
      ),
    );
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
      if (isClosed) return;
      emit(
        state.copyWith(
          isProcessing: false,
          completedTransaction: tx,
          posTransactions: updatedPosList,
        ),
      );
    } catch (e) {
      if (isClosed) return;
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
    String? customQrShortToken,
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

    final activeShortToken = customQrShortToken ?? state.shortQrToken;
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
      if (isClosed) return;
      emit(
        state.copyWith(
          isProcessing: false,
          completedTransaction: tx,
          completedQrShortToken: activeShortToken,
          qrToken: PayPulseQrPayload.generateDynamicToken(prefix: 'PPPOS'),
          qrGeneratedAt: DateTime.now(),
          qrGenerationCount: state.qrGenerationCount + 1,
          remainingQrSeconds: VirtualPosState.qrTtlSeconds,
          posTransactions: updatedPosList,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          isProcessing: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> processScannedCustomerQr({
    required String rawQr,
    required String companyId,
  }) async {
    final parsed = PayPulseQrPayload.tryParse(rawQr);
    if (parsed == null) {
      emit(state.copyWith(errorMessage: 'Okutulan QR kod formatı tanınmadı.'));
      return;
    }
    if (parsed.isExpired()) {
      emit(
        state.copyWith(
          errorMessage: 'Müşterinin QR kodunun 48 saniyelik güvenlik süresi dolmuş!',
        ),
      );
      return;
    }

    if (parsed.amount > 0) {
      final parsedKurus = (parsed.amount * 100).round();
      amountController.text = FinancialAmount.input(parsedKurus);
      emit(state.copyWith(amountKurus: parsedKurus));
    }

    await submitQrPayment(
      companyId: companyId,
      payerUserId: parsed.userId ?? AppStrings.demoB2CUid,
      customQrShortToken: parsed.shortToken,
    );
  }

  void notifyQrCopied() {
    emit(
      state.copyWith(infoMessage: 'B2B POS QR tahsilat kodu panoya kopyalandı.'),
    );
  }

  void clearCompletedTransaction() {
    emit(state.copyWith(clearCompleted: true));
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  void clearInfo() {
    emit(state.copyWith(clearInfo: true));
  }

  @override
  Future<void> close() {
    _qrCountdownTimer?.cancel();
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
    customerQrPasteController.dispose();
    return super.close();
  }
}
