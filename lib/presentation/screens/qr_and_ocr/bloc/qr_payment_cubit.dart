import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_limits.dart';
import '../../../../core/utils/equatable.dart';
import '../../../../core/utils/financial_amount.dart';
import '../../../../domain/entities/payment_request_entity.dart';
import '../../../../domain/repositories/i_payment_request_repository.dart';

class QrPaymentState extends Equatable {
  final bool isShowQrMode;
  final int countdownSeconds;
  final String qrToken;
  final PaymentRequestEntity? activeRequest;
  final bool isBusy;
  final String? navigateToPayRoute;
  final String? actionMessage;
  final bool isErrorAction;

  const QrPaymentState({
    this.isShowQrMode = true,
    this.countdownSeconds = AppLimits.qrCountdownSeconds,
    this.qrToken = '',
    this.activeRequest,
    this.isBusy = false,
    this.navigateToPayRoute,
    this.actionMessage,
    this.isErrorAction = false,
  });

  String get formattedCountdown {
    final s = countdownSeconds.clamp(0, AppLimits.qrCountdownSeconds);
    return '00:${s.toString().padLeft(2, '0')}';
  }

  String qrPayload(String userId) {
    final req = activeRequest;
    if (req != null) {
      return 'paypulse://pay/${req.requestId}';
    }
    return 'paypulse://wallet/$userId?token=$qrToken';
  }

  QrPaymentState copyWith({
    bool? isShowQrMode,
    int? countdownSeconds,
    String? qrToken,
    PaymentRequestEntity? activeRequest,
    bool clearActiveRequest = false,
    bool? isBusy,
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
      activeRequest: clearActiveRequest
          ? null
          : (activeRequest ?? this.activeRequest),
      isBusy: isBusy ?? this.isBusy,
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
    activeRequest,
    isBusy,
    navigateToPayRoute,
    actionMessage,
    isErrorAction,
  ];
}

class QrPaymentCubit extends Cubit<QrPaymentState> {
  final IPaymentRequestRepository _paymentRequestRepo;
  final TextEditingController requestAmountController = TextEditingController();
  final TextEditingController scanInputController = TextEditingController();
  Timer? _countdownTimer;

  QrPaymentCubit({
    required IPaymentRequestRepository paymentRequestRepository,
    bool startTimer = true,
  }) : _paymentRequestRepo = paymentRequestRepository,
       super(
         QrPaymentState(
           qrToken: _generateToken(),
           countdownSeconds: AppLimits.qrCountdownSeconds,
         ),
       ) {
    if (startTimer) {
      _startTimer();
    }
  }

  static String _generateToken() =>
      'QR-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

  void _startTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (isClosed) return;
      if (state.countdownSeconds <= 1) {
        emit(
          state.copyWith(
            countdownSeconds: AppLimits.qrCountdownSeconds,
            qrToken: _generateToken(),
          ),
        );
      } else {
        emit(state.copyWith(countdownSeconds: state.countdownSeconds - 1));
      }
    });
  }

  void setMode({required bool showMyQr}) {
    emit(state.copyWith(isShowQrMode: showMyQr, clearActionMessage: true));
  }

  void regenerateQr() {
    emit(
      state.copyWith(
        qrToken: _generateToken(),
        countdownSeconds: AppLimits.qrCountdownSeconds,
        clearActiveRequest: true,
      ),
    );
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
          qrToken: reqId,
          countdownSeconds: AppLimits.qrCountdownSeconds,
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

  Future<void> handleScannedCode(String rawValue) async {
    final trimmed = rawValue.trim();
    if (trimmed.isEmpty || state.isBusy) return;

    String requestId = trimmed;
    if (trimmed.contains('/pay/')) {
      requestId = trimmed.split('/pay/').last.split('?').first.trim();
    } else if (trimmed.startsWith('paypulse://pay/')) {
      requestId = trimmed.replaceFirst('paypulse://pay/', '').split('?').first.trim();
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
      final request = await _paymentRequestRepo.getPaymentRequestById(requestId);
      if (request == null) {
        emit(
          state.copyWith(
            isBusy: false,
            actionMessage: '"$requestId" numaralı aktif tahsilat talebi bulunamadı.',
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
    return super.close();
  }
}

