import '../../../../domain/entities/fast_receipt.dart';

enum TransferStep {
  step1Recipient, // 1. Adım: Alıcı Bilgileri & IBAN
  step2Amount,    // 2. Adım: Tutar Belirleme (+100, +250, Tüm Bakiye)
  step3Summary,   // 3. Adım: Özet & Onay
  step4Receipt,   // 4. Adım: Başarılı Dekont
}

enum FastTransferStatus {
  initial,
  loading,
  success,
  failure,
}

class FastTransferState {
  final TransferStep currentStep;
  final FastTransferStatus status;
  final String recipientName;
  final String recipientIban;
  final String amountInput;
  final int amountKurus;
  final String description;
  final int dailySpentKurus;
  final int monthlySpentKurus;
  final String? recipientError;
  final String? ibanError;
  final String? amountError;
  final String? limitError;
  final String? generalError;
  final FastReceipt? receipt;

  const FastTransferState({
    this.currentStep = TransferStep.step1Recipient,
    this.status = FastTransferStatus.initial,
    this.recipientName = '',
    this.recipientIban = '',
    this.amountInput = '',
    this.amountKurus = 0,
    this.description = '',
    this.dailySpentKurus = 1450000,   // 14.500 TL bugün kullanıldı
    this.monthlySpentKurus = 6500000, // 65.000 TL bu ay kullanıldı
    this.recipientError,
    this.ibanError,
    this.amountError,
    this.limitError,
    this.generalError,
    this.receipt,
  });

  bool get isLoading => status == FastTransferStatus.loading;
  bool get isSuccess => status == FastTransferStatus.success;

  bool get canProceedStep1 =>
      recipientName.trim().length >= 3 &&
      recipientIban.trim().isNotEmpty &&
      recipientError == null &&
      ibanError == null;

  bool get canProceedStep2 =>
      amountKurus > 0 &&
      amountError == null &&
      limitError == null;

  FastTransferState copyWith({
    TransferStep? currentStep,
    FastTransferStatus? status,
    String? recipientName,
    String? recipientIban,
    String? amountInput,
    int? amountKurus,
    String? description,
    int? dailySpentKurus,
    int? monthlySpentKurus,
    String? recipientError,
    String? ibanError,
    String? amountError,
    String? limitError,
    String? generalError,
    FastReceipt? receipt,
    bool clearRecipientError = false,
    bool clearIbanError = false,
    bool clearAmountError = false,
    bool clearLimitError = false,
    bool clearGeneralError = false,
  }) {
    return FastTransferState(
      currentStep: currentStep ?? this.currentStep,
      status: status ?? this.status,
      recipientName: recipientName ?? this.recipientName,
      recipientIban: recipientIban ?? this.recipientIban,
      amountInput: amountInput ?? this.amountInput,
      amountKurus: amountKurus ?? this.amountKurus,
      description: description ?? this.description,
      dailySpentKurus: dailySpentKurus ?? this.dailySpentKurus,
      monthlySpentKurus: monthlySpentKurus ?? this.monthlySpentKurus,
      recipientError: clearRecipientError
          ? null
          : (recipientError ?? this.recipientError),
      ibanError: clearIbanError ? null : (ibanError ?? this.ibanError),
      amountError: clearAmountError ? null : (amountError ?? this.amountError),
      limitError: clearLimitError ? null : (limitError ?? this.limitError),
      generalError: clearGeneralError
          ? null
          : (generalError ?? this.generalError),
      receipt: receipt ?? this.receipt,
    );
  }
}

