enum InstallmentOption {
  single(1, 'Tek Çekim'),
  installment3(3, '3 Taksit'),
  installment6(6, '6 Taksit');

  final int count;
  final String label;

  const InstallmentOption(this.count, this.label);
}

enum VirtualPosStatus { initial, calculating, processing, success, failure }

class VirtualPosState {
  final VirtualPosStatus status;
  final String amountInput;
  final int grossAmountKurus;
  final InstallmentOption selectedInstallment;
  final double commissionRate; // %1,39 (0.0139)
  final String? errorMessage;
  final String? successMessage;
  final String? transactionRef;

  const VirtualPosState({
    this.status = VirtualPosStatus.initial,
    this.amountInput = '3.750,00',
    this.grossAmountKurus = 375000, // ₺3.750,00
    this.selectedInstallment = InstallmentOption.single,
    this.commissionRate = 0.0139,   // %1,39
    this.errorMessage,
    this.successMessage,
    this.transactionRef,
  });

  bool get isProcessing => status == VirtualPosStatus.processing;

  /// Kuruş bazında komisyon kesintisi
  int get commissionAmountKurus {
    if (grossAmountKurus <= 0) return 0;
    // Kuruş kaybı olmadan hesaplama:
    return ((grossAmountKurus * 139) / 10000).round();
  }

  /// logic.md: Net Hesaba Geçecek tutar (Örn: ₺3.697,88)
  int get netAmountKurus => grossAmountKurus - commissionAmountKurus;

  double get grossInLira => grossAmountKurus / 100.0;
  double get commissionInLira => commissionAmountKurus / 100.0;
  double get netInLira => netAmountKurus / 100.0;

  /// Taksit başına düşen tutar (kuruş)
  int get installmentMonthlyKurus {
    if (selectedInstallment.count <= 1) return grossAmountKurus;
    return (grossAmountKurus / selectedInstallment.count).round();
  }

  double get installmentMonthlyInLira => installmentMonthlyKurus / 100.0;

  VirtualPosState copyWith({
    VirtualPosStatus? status,
    String? amountInput,
    int? grossAmountKurus,
    InstallmentOption? selectedInstallment,
    double? commissionRate,
    String? errorMessage,
    String? successMessage,
    String? transactionRef,
    bool clearError = false,
  }) {
    return VirtualPosState(
      status: status ?? this.status,
      amountInput: amountInput ?? this.amountInput,
      grossAmountKurus: grossAmountKurus ?? this.grossAmountKurus,
      selectedInstallment: selectedInstallment ?? this.selectedInstallment,
      commissionRate: commissionRate ?? this.commissionRate,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: successMessage ?? this.successMessage,
      transactionRef: transactionRef ?? this.transactionRef,
    );
  }
}

