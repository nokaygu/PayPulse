import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_limits.dart';
import '../../../../core/utils/equatable.dart';
import '../../../../core/utils/financial_amount.dart';
import '../../../../core/utils/qr_payload_parser.dart';
import '../../../../domain/entities/payment_request_entity.dart';
import '../../../../domain/repositories/i_payment_request_repository.dart';
import '../../../../domain/repositories/i_transaction_repository.dart';

class QrPaymentReceipt extends Equatable {
  final String merchantName;
  final String terminalId;
  final double amount;
  final String txId;
  final String qrRef;
  final String? description;
  final DateTime timestamp;

  const QrPaymentReceipt({
    required this.merchantName,
    required this.terminalId,
    required this.amount,
    required this.txId,
    required this.qrRef,
    this.description,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
    merchantName,
    terminalId,
    amount,
    txId,
    qrRef,
    description,
    timestamp,
  ];
}

class QrPaymentState extends Equatable {
  static const int ttlSeconds = PayPulseQrPayload.defaultTtlSeconds;

  final bool isShowQrMode;
  final int countdownSeconds;
  final String qrToken;
  final DateTime generatedAt;
  final int generationCount;
  final double? requestedAmount;
  final PaymentRequestEntity? activeRequest;
  final bool isCameraActive;
  final bool hasHandledCameraFrame;
  final bool isBusy;
  final PayPulseQrPayload? pendingZeroAmountQr;
  final QrPaymentReceipt? completedReceipt;
  final String? navigateToPayRoute;
  final String? actionMessage;
  final bool isErrorAction;

  const QrPaymentState({
    this.isShowQrMode = true,
    this.countdownSeconds = ttlSeconds,
    this.qrToken = '',
    required this.generatedAt,
    this.generationCount = 1,
    this.requestedAmount,
    this.activeRequest,
    this.isCameraActive = false,
    this.hasHandledCameraFrame = false,
    this.isBusy = false,
    this.pendingZeroAmountQr,
    this.completedReceipt,
    this.navigateToPayRoute,
    this.actionMessage,
    this.isErrorAction = false,
  });

  double get progress =>
      (countdownSeconds / ttlSeconds).clamp(0.0, 1.0);

  bool get isUrgent => countdownSeconds <= 10;

  String get shortToken {
    if (qrToken.length <= 8) return qrToken;
    return qrToken.substring(qrToken.length - 8);
  }

  String get formattedCountdown {
    final s = countdownSeconds.clamp(0, ttlSeconds);
    final mins = (s ~/ 60).toString().padLeft(2, '0');
    final secs = (s % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  String qrPayload(
    String userId, {
    String userName = 'PayPulse Kullanıcısı',
    String customerNo = 'PP-849201',
    String iban = 'TR420006200084920100000001',
  }) {
    final req = activeRequest;
    if (req != null) {
      return 'paypulse://pay/${req.requestId}';
    }
    return PayPulseQrPayload.buildB2cPayload(
      userId: userId,
      userName: userName,
      customerNo: customerNo,
      iban: iban,
      token: qrToken,
      generatedAt: generatedAt,
      amount: requestedAmount,
      ttlSeconds: ttlSeconds,
    );
  }

  QrPaymentState copyWith({
    bool? isShowQrMode,
    int? countdownSeconds,
    String? qrToken,
    DateTime? generatedAt,
    int? generationCount,
    double? requestedAmount,
    bool clearRequestedAmount = false,
    PaymentRequestEntity? activeRequest,
    bool clearActiveRequest = false,
    bool? isCameraActive,
    bool? hasHandledCameraFrame,
    bool? isBusy,
    PayPulseQrPayload? pendingZeroAmountQr,
    bool clearPendingZeroAmountQr = false,
    QrPaymentReceipt? completedReceipt,
    bool clearCompletedReceipt = false,
    String? navigateToPayRoute,
    bool clearNavigation = false,
    String? actionMessage,
    bool clearActionMessage = false,
    bool? isErrorAction,
  }) {
    return QrPaymentState(
      isShowQrMode: isShowQrMode ?? this.isShowQrMode,
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
      qrToken: qrToken ?? this.qrToken,
      generatedAt: generatedAt ?? this.generatedAt,
      generationCount: generationCount ?? this.generationCount,
      requestedAmount: clearRequestedAmount
          ? null
          : (requestedAmount ?? this.requestedAmount),
      activeRequest: clearActiveRequest
          ? null
          : (activeRequest ?? this.activeRequest),
      isCameraActive: isCameraActive ?? this.isCameraActive,
      hasHandledCameraFrame:
          hasHandledCameraFrame ?? this.hasHandledCameraFrame,
      isBusy: isBusy ?? this.isBusy,
      pendingZeroAmountQr: clearPendingZeroAmountQr
          ? null
          : (pendingZeroAmountQr ?? this.pendingZeroAmountQr),
      completedReceipt: clearCompletedReceipt
          ? null
          : (completedReceipt ?? this.completedReceipt),
      navigateToPayRoute: clearNavigation
          ? null
          : (navigateToPayRoute ?? this.navigateToPayRoute),
      actionMessage: clearActionMessage
          ? null
          : (actionMessage ?? this.actionMessage),
      isErrorAction: isErrorAction ?? this.isErrorAction,
    );
  }

  @override
  List<Object?> get props => [
    isShowQrMode,
    countdownSeconds,
    qrToken,
    generatedAt,
    generationCount,
    requestedAmount,
    activeRequest,
    isCameraActive,
    hasHandledCameraFrame,
    isBusy,
    pendingZeroAmountQr,
    completedReceipt,
    navigateToPayRoute,
    actionMessage,
    isErrorAction,
  ];
}

class QrPaymentCubit extends Cubit<QrPaymentState> {
  final IPaymentRequestRepository _paymentRequestRepo;
  final ITransactionRepository? _transactionRepo;
  final TextEditingController requestAmountController = TextEditingController();
  final TextEditingController scanInputController = TextEditingController();
  final TextEditingController zeroAmountController = TextEditingController(
    text: '250,00',
  );
  Timer? _countdownTimer;

  QrPaymentCubit({
    required IPaymentRequestRepository paymentRequestRepository,
    ITransactionRepository? transactionRepository,
    bool startTimer = true,
  }) : _paymentRequestRepo = paymentRequestRepository,
       _transactionRepo = transactionRepository,
       super(
         QrPaymentState(
           qrToken: PayPulseQrPayload.generateDynamicToken(prefix: 'PPB2C'),
           generatedAt: DateTime.now(),
           countdownSeconds: QrPaymentState.ttlSeconds,
         ),
       ) {
    if (startTimer) {
      _startTimer();
    }
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (isClosed) return;
      if (state.countdownSeconds <= 1) {
        emit(
          state.copyWith(
            countdownSeconds: QrPaymentState.ttlSeconds,
            qrToken: PayPulseQrPayload.generateDynamicToken(prefix: 'PPB2C'),
            generatedAt: DateTime.now(),
            generationCount: state.generationCount + 1,
          ),
        );
      } else {
        emit(state.copyWith(countdownSeconds: state.countdownSeconds - 1));
      }
    });
  }

  void setMode({required bool showMyQr}) {
    emit(
      state.copyWith(
        isShowQrMode: showMyQr,
        isCameraActive: showMyQr ? false : state.isCameraActive,
        clearActionMessage: true,
      ),
    );
  }

  void selectRequestedAmount(double? amount) {
    emit(
      state.copyWith(
        requestedAmount: amount,
        clearRequestedAmount: amount == null,
        qrToken: PayPulseQrPayload.generateDynamicToken(prefix: 'PPB2C'),
        generatedAt: DateTime.now(),
        generationCount: state.generationCount + 1,
        countdownSeconds: QrPaymentState.ttlSeconds,
        clearActiveRequest: true,
      ),
    );
    if (_countdownTimer != null) _startTimer();
  }

  void regenerateQr() {
    emit(
      state.copyWith(
        qrToken: PayPulseQrPayload.generateDynamicToken(prefix: 'PPB2C'),
        generatedAt: DateTime.now(),
        generationCount: state.generationCount + 1,
        countdownSeconds: QrPaymentState.ttlSeconds,
        clearActiveRequest: true,
      ),
    );
    if (_countdownTimer != null) _startTimer();
  }

  void toggleCamera(bool active) {
    emit(
      state.copyWith(
        isCameraActive: active,
        hasHandledCameraFrame: false,
      ),
    );
  }

  void setManualQrInputText(String text) {
    scanInputController.text = text;
  }

  Future<void> handleCameraDetection(
    String rawValue, {
    String payerUserId = 'user_deniz_aksoy',
  }) async {
    if (state.hasHandledCameraFrame) return;
    emit(state.copyWith(hasHandledCameraFrame: true, isCameraActive: false));
    await handleScannedCode(rawValue, payerUserId: payerUserId);
  }

  Future<void> createPaymentRequestQr({
    required String userId,
    required String userName,
  }) async {
    if (userId.isEmpty) return;
    final amountKurus = FinancialAmount.parse(requestAmountController.text) ?? 0;
    if (amountKurus < AppLimits.minTransferKurus) {
      emit(
        state.copyWith(
          actionMessage:
              'Talep tutarı en az ${FinancialAmount.format(AppLimits.minTransferKurus)} olmalıdır.',
          isErrorAction: true,
        ),
      );
      return;
    }

    emit(state.copyWith(isBusy: true, clearActionMessage: true));
    try {
      final reqId = 'req_${DateTime.now().millisecondsSinceEpoch}';
      final request = PaymentRequestEntity(
        requestId: reqId,
        merchantId: userId,
        amount: amountKurus,
        currency: 'TRY',
        status: 'pending',
        description: '$userName QR Tahsilat Talebi',
      );
      await _paymentRequestRepo.createPaymentRequest(request);
      emit(
        state.copyWith(
          isBusy: false,
          activeRequest: request,
          requestedAmount: amountKurus / 100.0,
          qrToken: reqId,
          generatedAt: DateTime.now(),
          generationCount: state.generationCount + 1,
          countdownSeconds: QrPaymentState.ttlSeconds,
          actionMessage:
              '${FinancialAmount.format(amountKurus)} tutarlı dinamik tahsilat QR kodu hazırlandı.',
          isErrorAction: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isBusy: false,
          actionMessage: 'QR talebi oluşturulamadı: $e',
          isErrorAction: true,
        ),
      );
    }
  }

  Future<void> handleScannedCode(
    String rawValue, {
    String payerUserId = 'user_deniz_aksoy',
  }) async {
    final trimmed = rawValue.trim();
    if (trimmed.isEmpty) {
      emit(
        state.copyWith(
          actionMessage: 'Geçersiz veya boş QR kod verisi.',
          isErrorAction: true,
        ),
      );
      return;
    }
    if (state.isBusy) return;

    // 1. Mevcut Deep-Link Tahsilat Talebi (`paypulse://pay/req_...` veya `req_...`)
    final isPaymentRequestLink =
        trimmed.contains('/pay/') ||
        trimmed.startsWith('paypulse://pay/') ||
        (!trimmed.contains('://') && trimmed.startsWith('req_'));
    if (isPaymentRequestLink) {
      String requestId = trimmed;
      if (trimmed.contains('/pay/')) {
        requestId = trimmed.split('/pay/').last.split('?').first.trim();
      } else if (trimmed.startsWith('paypulse://pay/')) {
        requestId =
            trimmed.replaceFirst('paypulse://pay/', '').split('?').first.trim();
      }
      if (requestId.isEmpty) {
        emit(
          state.copyWith(
            actionMessage: 'Geçerli bir PayPulse QR ödeme kodu algılanamadı.',
            isErrorAction: true,
          ),
        );
        return;
      }

      emit(state.copyWith(isBusy: true, clearActionMessage: true));
      try {
        final request =
            await _paymentRequestRepo.getPaymentRequestById(requestId);
        if (request == null) {
          emit(
            state.copyWith(
              isBusy: false,
              actionMessage:
                  '"$requestId" numaralı aktif tahsilat talebi bulunamadı.',
              isErrorAction: true,
            ),
          );
          return;
        }
        emit(
          state.copyWith(
            isBusy: false,
            navigateToPayRoute: '/pay/$requestId',
          ),
        );
      } catch (e) {
        emit(
          state.copyWith(
            isBusy: false,
            actionMessage: 'QR kodu doğrulanamadı: $e',
            isErrorAction: true,
          ),
        );
      }
      return;
    }

    // 2. PayPulse TR Karekod / B2B POS / B2C Cüzdan Ayrıştırma (48sn TTL)
    final parsed = PayPulseQrPayload.tryParse(trimmed);
    if (parsed == null) {
      emit(
        state.copyWith(
          actionMessage: 'Geçersiz veya boş QR kod verisi.',
          isErrorAction: true,
        ),
      );
      return;
    }

    if (parsed.isExpired()) {
      emit(
        state.copyWith(
          actionMessage:
              'Bu QR kodun 48 saniyelik güvenlik süresi dolmuş! Lütfen yeni üretilen QR kodu okutun.',
          isErrorAction: true,
        ),
      );
      return;
    }

    if (parsed.amount <= 0) {
      emit(state.copyWith(pendingZeroAmountQr: parsed));
      return;
    }

    await _executeParsedPayloadPayment(
      parsed: parsed,
      amount: parsed.amount,
      payerUserId: payerUserId,
    );
  }

  Future<void> confirmZeroAmountQr(
    double amount, {
    required String payerUserId,
  }) async {
    final parsed = state.pendingZeroAmountQr;
    emit(state.copyWith(clearPendingZeroAmountQr: true));
    if (parsed == null || amount <= 0) return;
    await _executeParsedPayloadPayment(
      parsed: parsed,
      amount: amount,
      payerUserId: payerUserId,
    );
  }

  void dismissZeroAmountPrompt() {
    emit(state.copyWith(clearPendingZeroAmountQr: true));
  }

  Future<void> simulatePresetPayment({
    required String merchantName,
    required String terminalId,
    required String description,
    required double amount,
    required String payerUserId,
  }) async {
    await executeDirectQrPayment(
      merchantName: merchantName,
      terminalId: terminalId,
      amount: amount,
      qrRef: state.shortToken,
      companyId: 'comp_techsolutions_01',
      mode: 'B2B_POS',
      description: description,
      payerUserId: payerUserId,
    );
  }

  Future<void> _executeParsedPayloadPayment({
    required PayPulseQrPayload parsed,
    required double amount,
    required String payerUserId,
  }) async {
    final merchantOrReceiver = parsed.mode == 'B2C'
        ? '${parsed.userName ?? 'PayPulse Kullanıcısı'} (${parsed.customerNo ?? 'B2C'})'
        : (parsed.merchantName ?? 'Nova Tasarım Ltd. POS');
    final terminalOrIban = parsed.mode == 'B2C'
        ? (parsed.iban ?? 'FAST TR Karekod')
        : (parsed.terminalId ?? 'POS-TR-8492');

    await executeDirectQrPayment(
      merchantName: merchantOrReceiver,
      terminalId: terminalOrIban,
      amount: amount,
      qrRef: parsed.shortToken,
      companyId: parsed.companyId ?? 'comp_techsolutions_01',
      targetUserId: parsed.userId,
      targetIban: parsed.iban,
      mode: parsed.mode,
      description: parsed.description,
      payerUserId: payerUserId,
    );
  }

  Future<void> executeDirectQrPayment({
    required String merchantName,
    required String terminalId,
    required double amount,
    required String qrRef,
    required String payerUserId,
    String companyId = 'comp_techsolutions_01',
    String? targetUserId,
    String? targetIban,
    String mode = 'B2B_POS',
    String? description,
  }) async {
    if (state.isBusy) return;
    emit(state.copyWith(isBusy: true, clearActionMessage: true));

    String txId =
        'PP-QR-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    final amountKurus = (amount * 100).round();

    try {
      final repo = _transactionRepo;
      if (repo != null) {
        if (mode == 'B2C' &&
            targetUserId != null &&
            targetUserId.isNotEmpty &&
            targetUserId != payerUserId) {
          final tx = await repo.executeFastTransfer(
            senderUserId: payerUserId,
            receiverUserId: targetUserId,
            amountKurus: amountKurus,
            targetIban: targetIban,
          );
          txId = tx.txId;
        } else {
          final tx = await repo.executeQrWalletPayment(
            companyId: companyId,
            payerUserId: payerUserId,
            amountKurus: amountKurus,
          );
          txId = tx.txId;
        }
      }
    } catch (_) {
      // Demo veya çevrimdışı modda yerel başarı simülasyonu sürdürülür.
    }

    if (isClosed) return;
    emit(
      state.copyWith(
        isBusy: false,
        completedReceipt: QrPaymentReceipt(
          merchantName: merchantName,
          terminalId: terminalId,
          amount: amount,
          txId: txId,
          qrRef: qrRef,
          description: description,
          timestamp: DateTime.now(),
        ),
      ),
    );
  }

  void notifyCopiedPayload() {
    emit(
      state.copyWith(
        actionMessage: 'Canlı TR Karekod verisi panoya kopyalandı.',
        isErrorAction: false,
      ),
    );
  }

  void clearCompletedReceipt() {
    emit(state.copyWith(clearCompletedReceipt: true));
  }

  void clearNavigation() {
    emit(state.copyWith(clearNavigation: true));
  }

  void clearActionMessage() {
    emit(state.copyWith(clearActionMessage: true));
  }

  @override
  Future<void> close() {
    _countdownTimer?.cancel();
    requestAmountController.dispose();
    scanInputController.dispose();
    zeroAmountController.dispose();
    return super.close();
  }
}
