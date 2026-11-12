import '../../../../domain/entities/fast_receipt.dart';

enum TransferStatus {
  initial,
  editing,
  submitting,
  success,
  failure,
}

class TransferState {
  final TransferStatus status;
  final String recipientName;
  final String recipientIban;
  final String amountInput;
  final int amountKurus;
  final String description;
  final String? recipientError;
  final String? ibanError;
  final String? amountError;
  final String? generalError;
  final FastReceipt? receipt;

  const TransferState({
    this.status = TransferStatus.initial,
    this.recipientName = '',
    this.recipientIban = '',
    this.amountInput = '',
    this.amountKurus = 0,
    this.description = '',
    this.recipientError,
    this.ibanError,
    this.amountError,
    this.generalError,
    this.receipt,
  });

  bool get isSubmitting => status == TransferStatus.submitting;
  bool get isSuccess => status == TransferStatus.success;

  bool get isValid =>
      recipientName.trim().isNotEmpty &&
      recipientIban.trim().isNotEmpty &&
      amountKurus > 0 &&
      recipientError == null &&
      ibanError == null &&
      amountError == null;

  TransferState copyWith({
    TransferStatus? status,
    String? recipientName,
    String? recipientIban,
    String? amountInput,
    int? amountKurus,
    String? description,
    String? recipientError,
    String? ibanError,
    String? amountError,
    String? generalError,
    FastReceipt? receipt,
    bool clearRecipientError = false,
    bool clearIbanError = false,
    bool clearAmountError = false,
    bool clearGeneralError = false,
  }) {
    return TransferState(
      status: status ?? this.status,
      recipientName: recipientName ?? this.recipientName,
      recipientIban: recipientIban ?? this.recipientIban,
      amountInput: amountInput ?? this.amountInput,
      amountKurus: amountKurus ?? this.amountKurus,
      description: description ?? this.description,
      recipientError: clearRecipientError
          ? null
          : (recipientError ?? this.recipientError),
      ibanError: clearIbanError ? null : (ibanError ?? this.ibanError),
      amountError: clearAmountError ? null : (amountError ?? this.amountError),
      generalError: clearGeneralError
          ? null
          : (generalError ?? this.generalError),
      receipt: receipt ?? this.receipt,
    );
  }
}

