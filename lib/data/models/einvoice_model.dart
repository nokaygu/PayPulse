import '../../core/utils/equatable.dart';
import '../../domain/entities/invoice_entity.dart';

/// E-Fatura ve E-Arşiv kayıtlarını temsil eden DTO modeli.
class EInvoiceModel extends Equatable {
  final String invoiceId;
  final String companyId;
  final String gibInvoiceNo;
  final String counterpartyName;
  final bool isIncoming;
  final String documentType;
  final int totalAmount; // Kuruş bazında
  final int vatAmount; // Kuruş bazında
  final double? withholdingRate;
  final String? badgeText;
  final bool isPaid;
  final bool canPayWithFast;
  final DateTime issueDate;
  final DateTime? dueDate;

  EInvoiceModel({
    required this.invoiceId,
    required this.companyId,
    required this.gibInvoiceNo,
    required this.counterpartyName,
    required this.isIncoming,
    required this.documentType,
    required this.totalAmount,
    required this.vatAmount,
    this.withholdingRate,
    this.badgeText,
    this.isPaid = false,
    this.canPayWithFast = false,
    DateTime? issueDate,
    this.dueDate,
  }) : issueDate = issueDate ?? DateTime.now();

  double get totalAmountInLira => totalAmount / 100.0;
  double get vatAmountInLira => vatAmount / 100.0;

  factory EInvoiceModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedIssue;
    if (json['issueDate'] is String) {
      parsedIssue =
          DateTime.tryParse(json['issueDate'] as String) ?? DateTime.now();
    } else {
      parsedIssue = DateTime.now();
    }

    DateTime? parsedDue;
    if (json['dueDate'] is String) {
      parsedDue = DateTime.tryParse(json['dueDate'] as String);
    }

    return EInvoiceModel(
      invoiceId: json['invoiceId'] as String? ?? '',
      companyId: json['companyId'] as String? ?? '',
      gibInvoiceNo: json['gibInvoiceNo'] as String? ?? '',
      counterpartyName: json['counterpartyName'] as String? ?? '',
      isIncoming: json['isIncoming'] as bool? ?? true,
      documentType: json['documentType'] as String? ?? 'e_fatura',
      totalAmount: (json['totalAmount'] as num?)?.toInt() ?? 0,
      vatAmount: (json['vatAmount'] as num?)?.toInt() ?? 0,
      withholdingRate: (json['withholdingRate'] as num?)?.toDouble(),
      badgeText: json['badgeText'] as String?,
      isPaid: json['isPaid'] as bool? ?? false,
      canPayWithFast: json['canPayWithFast'] as bool? ?? false,
      issueDate: parsedIssue,
      dueDate: parsedDue,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'invoiceId': invoiceId,
      'companyId': companyId,
      'gibInvoiceNo': gibInvoiceNo,
      'counterpartyName': counterpartyName,
      'isIncoming': isIncoming,
      'documentType': documentType,
      'totalAmount': totalAmount,
      'vatAmount': vatAmount,
      if (withholdingRate != null) 'withholdingRate': withholdingRate,
      if (badgeText != null) 'badgeText': badgeText,
      'isPaid': isPaid,
      'canPayWithFast': canPayWithFast,
      'issueDate': issueDate.toIso8601String(),
      if (dueDate != null) 'dueDate': dueDate!.toIso8601String(),
    };
  }

  InvoiceEntity toEntity() {
    return InvoiceEntity(
      invoiceId: invoiceId,
      companyId: companyId,
      gibInvoiceNo: gibInvoiceNo,
      counterpartyName: counterpartyName,
      isIncoming: isIncoming,
      documentType: documentType,
      totalAmount: totalAmount,
      vatAmount: vatAmount,
      withholdingRate: withholdingRate,
      badgeText: badgeText,
      isPaid: isPaid,
      canPayWithFast: canPayWithFast,
      issueDate: issueDate,
      dueDate: dueDate,
    );
  }

  factory EInvoiceModel.fromEntity(InvoiceEntity entity) {
    return EInvoiceModel(
      invoiceId: entity.invoiceId,
      companyId: entity.companyId,
      gibInvoiceNo: entity.gibInvoiceNo,
      counterpartyName: entity.counterpartyName,
      isIncoming: entity.isIncoming,
      documentType: entity.documentType,
      totalAmount: entity.totalAmount,
      vatAmount: entity.vatAmount,
      withholdingRate: entity.withholdingRate,
      badgeText: entity.badgeText,
      isPaid: entity.isPaid,
      canPayWithFast: entity.canPayWithFast,
      issueDate: entity.issueDate,
      dueDate: entity.dueDate,
    );
  }

  EInvoiceModel copyWith({
    String? invoiceId,
    String? companyId,
    String? gibInvoiceNo,
    String? counterpartyName,
    bool? isIncoming,
    String? documentType,
    int? totalAmount,
    int? vatAmount,
    double? withholdingRate,
    String? badgeText,
    bool? isPaid,
    bool? canPayWithFast,
    DateTime? issueDate,
    DateTime? dueDate,
  }) {
    return EInvoiceModel(
      invoiceId: invoiceId ?? this.invoiceId,
      companyId: companyId ?? this.companyId,
      gibInvoiceNo: gibInvoiceNo ?? this.gibInvoiceNo,
      counterpartyName: counterpartyName ?? this.counterpartyName,
      isIncoming: isIncoming ?? this.isIncoming,
      documentType: documentType ?? this.documentType,
      totalAmount: totalAmount ?? this.totalAmount,
      vatAmount: vatAmount ?? this.vatAmount,
      withholdingRate: withholdingRate ?? this.withholdingRate,
      badgeText: badgeText ?? this.badgeText,
      isPaid: isPaid ?? this.isPaid,
      canPayWithFast: canPayWithFast ?? this.canPayWithFast,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  @override
  List<Object?> get props => [
    invoiceId,
    companyId,
    gibInvoiceNo,
    counterpartyName,
    isIncoming,
    documentType,
    totalAmount,
    vatAmount,
    withholdingRate,
    badgeText,
    isPaid,
    canPayWithFast,
    issueDate,
    dueDate,
  ];
}
