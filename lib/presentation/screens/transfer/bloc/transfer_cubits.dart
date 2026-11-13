import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_limits.dart';
import '../../../../core/utils/equatable.dart';
import '../../../../core/utils/financial_amount.dart';
import '../../../../core/validators/financial_validators.dart';
import '../../../../domain/entities/payment_request_entity.dart';
import '../../../../domain/entities/safe_recipient_entity.dart';
import '../../../../domain/entities/transaction_entity.dart';
import '../../../../domain/entities/wallet_entity.dart';
import '../../../../domain/repositories/i_payment_request_repository.dart';
import '../../../../domain/repositories/i_transaction_repository.dart';
import '../../../../domain/repositories/i_wallet_repository.dart';
import '../../../../domain/use_cases/execute_fast_transfer_use_case.dart';
import '../../../../domain/use_cases/pay_payment_request_use_case.dart';
import '../../../widgets/four_state_view.dart';

// =============================================================================
// 1. ALICI SEÇİMİ CUBIT (TransferRecipientScreen)
// =============================================================================
class TransferRecipientState extends Equatable {
  final ViewStatus status;
  final List<SafeRecipientEntity> savedRecipients;
  final SafeRecipientEntity? lookedUpRecipient;
  final String searchQuery;
  final String? errorMessage;

  const TransferRecipientState({
    this.status = ViewStatus.loading,
    this.savedRecipients = const [],
    this.lookedUpRecipient,
    this.searchQuery = '',
    this.errorMessage,
  });

  List<SafeRecipientEntity> get filteredRecipients {
    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) return savedRecipients;
    return savedRecipients
        .where(
          (r) =>
              r.maskedName.toLowerCase().contains(q) ||
              r.iban.toLowerCase().contains(q),
        )
        .toList();
  }

  TransferRecipientState copyWith({
    ViewStatus? status,
    List<SafeRecipientEntity>? savedRecipients,
    SafeRecipientEntity? lookedUpRecipient,
    bool clearLookedUp = false,
    String? searchQuery,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TransferRecipientState(
      status: status ?? this.status,
      savedRecipients: savedRecipients ?? this.savedRecipients,
      lookedUpRecipient: clearLookedUp
          ? null
          : (lookedUpRecipient ?? this.lookedUpRecipient),
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    savedRecipients,
    lookedUpRecipient,
    searchQuery,
    errorMessage,
  ];
}

class TransferRecipientCubit extends Cubit<TransferRecipientState> {
  final ITransactionRepository _txRepo;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController ibanController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  TransferRecipientCubit({required ITransactionRepository transactionRepository})
    : _txRepo = transactionRepository,
      super(const TransferRecipientState());

  Future<void> loadRecipients() async {
    emit(state.copyWith(status: ViewStatus.loading, clearError: true));
    try {
      final recipients = await _txRepo.getSavedRecipients();
      emit(
        state.copyWith(
          status: recipients.isEmpty ? ViewStatus.empty : ViewStatus.success,
          savedRecipients: recipients,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ViewStatus.error,
          errorMessage: 'Kayıtlı alıcı listesi yüklenemedi.',
        ),
      );
    }
  }

  void updateSearch(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  Future<void> lookupIban(String rawIban) async {
    final valid = FinancialValidators.iban(rawIban) == null;
    if (!valid) {
      emit(state.copyWith(clearLookedUp: true));
      return;
    }

    try {
      final found = await _txRepo.findRecipientByIban(rawIban);
      if (found != null) {
        if (nameController.text.trim().isEmpty) {
          nameController.text = found.maskedName;
        }
        emit(state.copyWith(lookedUpRecipient: found));
      } else {
        emit(state.copyWith(clearLookedUp: true));
      }
    } catch (_) {
      emit(state.copyWith(clearLookedUp: true));
    }
  }

  @override
  Future<void> close() {
    ibanController.dispose();
    nameController.dispose();
    return super.close();
  }
}

// =============================================================================
// 2. TUTAR GİRİŞİ CUBIT (TransferAmountScreen)
// =============================================================================
class TransferAmountState extends Equatable {
  final String amountText;
  final WalletEntity? senderWallet;
  final bool isWalletLoading;
  final String? validationError;

  const TransferAmountState({
    this.amountText = '1500,00',
    this.senderWallet,
    this.isWalletLoading = true,
    this.validationError,
  });

  int get balanceKurus => senderWallet?.balanceTl ?? 0;

  int get parsedAmountKurus => FinancialAmount.parse(amountText) ?? 0;

  TransferAmountState copyWith({
    String? amountText,
    WalletEntity? senderWallet,
    bool? isWalletLoading,
    String? validationError,
    bool clearError = false,
  }) {
    return TransferAmountState(
      amountText: amountText ?? this.amountText,
      senderWallet: senderWallet ?? this.senderWallet,
      isWalletLoading: isWalletLoading ?? this.isWalletLoading,
      validationError: clearError
          ? null
          : (validationError ?? this.validationError),
    );
  }

  @override
  List<Object?> get props => [
    amountText,
    senderWallet,
    isWalletLoading,
    validationError,
  ];
}

class TransferAmountCubit extends Cubit<TransferAmountState> {
  final IWalletRepository _walletRepo;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController amountController = TextEditingController(
    text: '1500,00',
  );
  final TextEditingController descriptionController = TextEditingController(
    text: 'FAST Para Transferi',
  );
  StreamSubscription<WalletEntity?>? _walletSub;

  TransferAmountCubit({required IWalletRepository walletRepository})
    : _walletRepo = walletRepository,
      super(const TransferAmountState());

  void watchSenderWallet(String userId) {
    _walletSub?.cancel();
    _walletSub = _walletRepo
        .watchUserWallet(userId)
        .listen(
          (wallet) {
            emit(
              state.copyWith(
                senderWallet: wallet,
                isWalletLoading: false,
                clearError: true,
              ),
            );
          },
          onError: (_) {
            emit(state.copyWith(isWalletLoading: false));
          },
        );
  }

  void appendDigit(String digit) {
    var current = state.amountText;
    if (digit == ',') {
      if (current.contains(',')) return;
      current = current.isEmpty ? '0,' : '$current,';
    } else {
      if (current == '0' || current == '0,00') {
        current = digit;
      } else {
        final parts = current.split(',');
        if (parts.length == 2 && parts[1].length >= 2) return;
        if (parts[0].replaceAll('.', '').length >= 8) return;
        current = '$current$digit';
      }
    }
    _syncController(current);
  }

  void backspace() {
    var current = state.amountText;
    if (current.length <= 1) {
      current = '0';
    } else {
      current = current.substring(0, current.length - 1);
    }
    _syncController(current);
  }

  void syncFromTextField(String value) {
    emit(state.copyWith(amountText: value, clearError: true));
  }

  void _syncController(String raw) {
    amountController.value = TextEditingValue(
      text: raw,
      selection: TextSelection.collapsed(offset: raw.length),
    );
    emit(state.copyWith(amountText: raw, clearError: true));
  }

  int? validateAndExtractKurus() {
    final balanceKurus = state.senderWallet != null ? state.balanceKurus : null;
    final err = FinancialValidators.amount(
      amountController.text,
      balanceKurus: balanceKurus,
    );
    if (err != null) {
      emit(state.copyWith(validationError: err));
      return null;
    }

    final parsed = FinancialAmount.parse(amountController.text);
    if (parsed == null || parsed < AppLimits.minTransferKurus) {
      emit(
        state.copyWith(
          validationError:
              'Minimum FAST tutarı ${FinancialAmount.format(AppLimits.minTransferKurus)} olmalıdır.',
        ),
      );
      return null;
    }

    emit(state.copyWith(clearError: true));
    return parsed;
  }

  @override
  Future<void> close() async {
    await _walletSub?.cancel();
    amountController.dispose();
    descriptionController.dispose();
    return super.close();
  }
}

// =============================================================================
// 3. ÖZET VE ONAY CUBIT (TransferSummaryScreen + Deep Link /pay/:requestId)
// =============================================================================
class TransferSummaryState extends Equatable {
  final ViewStatus loadStatus;
  final String recipientIban;
  final String recipientName;
  final int amountInKurus;
  final String description;
  final String? paymentRequestId;
  final PaymentRequestEntity? paymentRequest;
  final WalletEntity? senderWallet;
  final bool rulesAccepted;
  final bool isSubmitting;
  final bool requiresFraudDialog;
  final TransactionEntity? completedTransaction;
  final String? errorMessage;

  const TransferSummaryState({
    this.loadStatus = ViewStatus.success,
    required this.recipientIban,
    required this.recipientName,
    required this.amountInKurus,
    required this.description,
    this.paymentRequestId,
    this.paymentRequest,
    this.senderWallet,
    this.rulesAccepted = true,
    this.isSubmitting = false,
    this.requiresFraudDialog = false,
    this.completedTransaction,
    this.errorMessage,
  });

  bool get isPaymentRequestFlow => paymentRequestId != null;

  bool get isAboveFraudThreshold =>
      amountInKurus >= AppLimits.fraudLimitInKurus;

  TransferSummaryState copyWith({
    ViewStatus? loadStatus,
    String? recipientIban,
    String? recipientName,
    int? amountInKurus,
    String? description,
    PaymentRequestEntity? paymentRequest,
    WalletEntity? senderWallet,
    bool? rulesAccepted,
    bool? isSubmitting,
    bool? requiresFraudDialog,
    TransactionEntity? completedTransaction,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TransferSummaryState(
      loadStatus: loadStatus ?? this.loadStatus,
      recipientIban: recipientIban ?? this.recipientIban,
      recipientName: recipientName ?? this.recipientName,
      amountInKurus: amountInKurus ?? this.amountInKurus,
      description: description ?? this.description,
      paymentRequestId: paymentRequestId,
      paymentRequest: paymentRequest ?? this.paymentRequest,
      senderWallet: senderWallet ?? this.senderWallet,
      rulesAccepted: rulesAccepted ?? this.rulesAccepted,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      requiresFraudDialog: requiresFraudDialog ?? this.requiresFraudDialog,
      completedTransaction: completedTransaction ?? this.completedTransaction,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    loadStatus,
    recipientIban,
    recipientName,
    amountInKurus,
    description,
    paymentRequestId,
    paymentRequest,
    senderWallet,
    rulesAccepted,
    isSubmitting,
    requiresFraudDialog,
    completedTransaction,
    errorMessage,
  ];
}

class TransferSummaryCubit extends Cubit<TransferSummaryState> {
  final IWalletRepository _walletRepo;
  final ExecuteFastTransferUseCase _executeFastTransfer;
  final IPaymentRequestRepository _paymentRequestRepo;
  final PayPaymentRequestUseCase _payPaymentRequest;

  StreamSubscription<WalletEntity?>? _walletSub;

  TransferSummaryCubit({
    required IWalletRepository walletRepository,
    required ITransactionRepository transactionRepository,
    required IPaymentRequestRepository paymentRequestRepository,
    required String recipientIban,
    required String recipientName,
    required int amountInKurus,
    required String description,
    String? paymentRequestId,
  }) : _walletRepo = walletRepository,
       _executeFastTransfer = ExecuteFastTransferUseCase(transactionRepository),
       _paymentRequestRepo = paymentRequestRepository,
       _payPaymentRequest = PayPaymentRequestUseCase(paymentRequestRepository),
       super(
         TransferSummaryState(
           loadStatus: paymentRequestId != null
               ? ViewStatus.loading
               : ViewStatus.success,
           recipientIban: recipientIban,
           recipientName: recipientName,
           amountInKurus: amountInKurus,
           description: description,
           paymentRequestId: paymentRequestId,
         ),
       );

  Future<void> initialize({required String senderUserId}) async {
    await _walletSub?.cancel();
    _walletSub = _walletRepo.watchUserWallet(senderUserId).listen((wallet) {
      emit(state.copyWith(senderWallet: wallet));
    });

    final reqId = state.paymentRequestId;
    if (reqId == null || reqId.isEmpty) return;

    emit(state.copyWith(loadStatus: ViewStatus.loading, clearError: true));
    try {
      final request = await _paymentRequestRepo.getPaymentRequestById(reqId);
      if (request == null) {
        emit(
          state.copyWith(
            loadStatus: ViewStatus.empty,
            errorMessage: 'Ödeme talebi (#$reqId) bulunamadı.',
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          loadStatus: ViewStatus.success,
          paymentRequest: request,
          amountInKurus: request.amount,
          recipientName: request.description.isNotEmpty
              ? request.description
              : 'Kurumsal Ödeme Talebi',
          recipientIban: 'PayPulse Talep #${request.requestId}',
          description: request.description,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          loadStatus: ViewStatus.error,
          errorMessage: _cleanError(e),
        ),
      );
    }
  }

  void setRulesAccepted(bool accepted) {
    emit(state.copyWith(rulesAccepted: accepted, clearError: true));
  }

  void dismissFraudPrompt() {
    emit(state.copyWith(requiresFraudDialog: false));
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  Future<void> confirmTransfer({
    required String senderUserId,
    bool fraudConfirmed = false,
  }) async {
    if (!state.rulesAccepted) {
      emit(
        state.copyWith(
          errorMessage: 'Lütfen önce FAST transfer kurallarını onaylayın.',
        ),
      );
      return;
    }

    if (!state.isPaymentRequestFlow &&
        state.isAboveFraudThreshold &&
        !fraudConfirmed) {
      emit(state.copyWith(requiresFraudDialog: true, clearError: true));
      return;
    }

    emit(
      state.copyWith(
        isSubmitting: true,
        requiresFraudDialog: false,
        clearError: true,
      ),
    );

    try {
      final TransactionEntity tx;
      if (state.paymentRequestId != null) {
        tx = await _payPaymentRequest(
          requestId: state.paymentRequestId!,
          payerUserId: senderUserId,
          payerWallet: state.senderWallet,
        );
      } else {
        tx = await _executeFastTransfer(
          senderUserId: senderUserId,
          targetIban: state.recipientIban,
          amountKurus: state.amountInKurus,
          senderWallet: state.senderWallet,
          fraudConfirmed: fraudConfirmed,
          title: state.recipientName,
          category: state.description,
        );
      }

      emit(state.copyWith(isSubmitting: false, completedTransaction: tx));
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: _cleanError(e)));
    }
  }

  String _cleanError(Object e) {
    return e
        .toString()
        .replaceFirst('Bad state: ', '')
        .replaceFirst('Invalid argument(s): ', '')
        .replaceFirst('Exception: ', '');
  }

  @override
  Future<void> close() async {
    await _walletSub?.cancel();
    return super.close();
  }
}

// =============================================================================
// 4. DEKONT CUBIT (TransferReceiptScreen)
// =============================================================================
class TransferReceiptState extends Equatable {
  final ViewStatus status;
  final TransactionEntity? transaction;
  final String? errorMessage;

  const TransferReceiptState({
    this.status = ViewStatus.loading,
    this.transaction,
    this.errorMessage,
  });

  TransferReceiptState copyWith({
    ViewStatus? status,
    TransactionEntity? transaction,
    String? errorMessage,
  }) {
    return TransferReceiptState(
      status: status ?? this.status,
      transaction: transaction ?? this.transaction,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, transaction, errorMessage];
}

class TransferReceiptCubit extends Cubit<TransferReceiptState> {
  final ITransactionRepository _txRepo;

  TransferReceiptCubit({required ITransactionRepository transactionRepository})
    : _txRepo = transactionRepository,
      super(const TransferReceiptState());

  Future<void> loadTransaction(String txId) async {
    emit(const TransferReceiptState(status: ViewStatus.loading));
    try {
      final tx = await _txRepo.getTransactionById(txId);
      if (tx == null) {
        emit(
          const TransferReceiptState(
            status: ViewStatus.empty,
            errorMessage: 'Dekont kaydı bulunamadı.',
          ),
        );
        return;
      }
      emit(TransferReceiptState(status: ViewStatus.success, transaction: tx));
    } catch (_) {
      emit(
        const TransferReceiptState(
          status: ViewStatus.error,
          errorMessage: 'Dekont bilgisi yüklenirken hata oluştu.',
        ),
      );
    }
  }
}

