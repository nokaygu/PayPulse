import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/equatable.dart';
import '../../../../core/utils/financial_amount.dart';
import '../../../../domain/entities/invoice_entity.dart';
import '../../../../domain/entities/safe_recipient_entity.dart';
import '../../../../domain/repositories/i_invoice_repository.dart';
import '../../../../domain/repositories/i_transaction_repository.dart';
import '../../../widgets/four_state_view.dart';

enum InvoiceStatusFilter { all, paid, pending }

extension InvoiceStatusFilterLabel on InvoiceStatusFilter {
  String get label {
    switch (this) {
      case InvoiceStatusFilter.all:
        return 'Tümü';
      case InvoiceStatusFilter.paid:
        return 'Ödendi / Kapandı';
      case InvoiceStatusFilter.pending:
        return 'Onay Bekleyenler';
    }
  }
}

class EInvoiceState extends Equatable {
  final ViewStatus status;
  final String companyId;
  final List<InvoiceEntity> invoices;
  final List<SafeRecipientEntity> savedRecipients;
  final bool isIncomingTab;
  final InvoiceStatusFilter statusFilter;
  final String selectedDocType; // 'Tümü', 'e_fatura', 'e_arsiv', 'e_smm'
  final String searchQuery;
  final bool isPaying;
  final String? payingInvoiceId;
  final String? errorMessage;
  final String? actionMessage;
  final bool isErrorAction;

  const EInvoiceState({
    this.status = ViewStatus.loading,
    this.companyId = '',
    this.invoices = const [],
    this.savedRecipients = const [],
    this.isIncomingTab = true,
    this.statusFilter = InvoiceStatusFilter.all,
    this.selectedDocType = 'Tümü',
    this.searchQuery = '',
    this.isPaying = false,
    this.payingInvoiceId,
    this.errorMessage,
    this.actionMessage,
    this.isErrorAction = false,
  });

  List<InvoiceEntity> get incomingInvoices =>
      invoices.where((i) => i.isIncoming).toList();

  List<InvoiceEntity> get outgoingInvoices =>
      invoices.where((i) => !i.isIncoming).toList();

  List<InvoiceEntity> get activeTabInvoices =>
      isIncomingTab ? incomingInvoices : outgoingInvoices;

  int get activeTabTotalKurus =>
      activeTabInvoices.fold<int>(0, (sum, i) => sum + i.totalAmount);

  int get activeTabTotalVatKurus =>
      activeTabInvoices.fold<int>(0, (sum, i) => sum + i.vatAmount);

  String get formattedActiveTabTotal =>
      FinancialAmount.format(activeTabTotalKurus);

  String get formattedActiveTabVat =>
      '+${FinancialAmount.format(activeTabTotalVatKurus)} KDV';

  String get defaultFastTargetIban =>
      savedRecipients.isNotEmpty ? savedRecipients.first.iban : '';

  List<InvoiceEntity> get filteredInvoices {
    final q = searchQuery.trim().toLowerCase();
    return activeTabInvoices.where((inv) {
      switch (statusFilter) {
        case InvoiceStatusFilter.all:
          break;
        case InvoiceStatusFilter.paid:
          if (!inv.isPaid) return false;
        case InvoiceStatusFilter.pending:
          if (inv.isPaid) return false;
      }

      if (selectedDocType != 'Tümü' && inv.documentType != selectedDocType) {
        return false;
      }

      if (q.isEmpty) return true;

      final nameMatch = inv.counterpartyName.toLowerCase().contains(q);
      final noMatch = inv.gibInvoiceNo.toLowerCase().contains(q);
      final badgeMatch = (inv.badgeText ?? '').toLowerCase().contains(q);
      final amountMatch = FinancialAmount.format(
        inv.totalAmount,
      ).toLowerCase().contains(q);
      return nameMatch || noMatch || badgeMatch || amountMatch;
    }).toList();
  }

  ViewStatus get listStatus {
    if (status == ViewStatus.loading) return ViewStatus.loading;
    if (status == ViewStatus.error) return ViewStatus.error;
    if (filteredInvoices.isEmpty) return ViewStatus.empty;
    return ViewStatus.success;
  }

  EInvoiceState copyWith({
    ViewStatus? status,
    String? companyId,
    List<InvoiceEntity>? invoices,
    List<SafeRecipientEntity>? savedRecipients,
    bool? isIncomingTab,
    InvoiceStatusFilter? statusFilter,
    String? selectedDocType,
    String? searchQuery,
    bool? isPaying,
    String? payingInvoiceId,
    bool clearPayingInvoice = false,
    String? errorMessage,
    bool clearError = false,
    String? actionMessage,
    bool clearActionMessage = false,
    bool? isErrorAction,
  }) {
    return EInvoiceState(
      status: status ?? this.status,
      companyId: companyId ?? this.companyId,
      invoices: invoices ?? this.invoices,
      savedRecipients: savedRecipients ?? this.savedRecipients,
      isIncomingTab: isIncomingTab ?? this.isIncomingTab,
      statusFilter: statusFilter ?? this.statusFilter,
      selectedDocType: selectedDocType ?? this.selectedDocType,
      searchQuery: searchQuery ?? this.searchQuery,
      isPaying: isPaying ?? this.isPaying,
      payingInvoiceId: clearPayingInvoice
          ? null
          : (payingInvoiceId ?? this.payingInvoiceId),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      actionMessage: clearActionMessage
          ? null
          : (actionMessage ?? this.actionMessage),
      isErrorAction: isErrorAction ?? this.isErrorAction,
    );
  }

  @override
  List<Object?> get props => [
    status,
    companyId,
    invoices,
    savedRecipients,
    isIncomingTab,
    statusFilter,
    selectedDocType,
    searchQuery,
    isPaying,
    payingInvoiceId,
    errorMessage,
    actionMessage,
    isErrorAction,
  ];
}

class EInvoiceCubit extends Cubit<EInvoiceState> {
  final IInvoiceRepository _invoiceRepo;
  final ITransactionRepository _txRepo;
  final TextEditingController searchController = TextEditingController();

  EInvoiceCubit({
    required IInvoiceRepository invoiceRepository,
    required ITransactionRepository transactionRepository,
  }) : _invoiceRepo = invoiceRepository,
       _txRepo = transactionRepository,
       super(const EInvoiceState());

  Future<void> loadInvoices({required String companyId}) async {
    if (companyId.isEmpty) return;

    emit(
      state.copyWith(
        status: ViewStatus.loading,
        companyId: companyId,
        clearError: true,
      ),
    );

    try {
      final results = await Future.wait<dynamic>([
        _invoiceRepo.getInvoices(companyId: companyId),
        _txRepo.getSavedRecipients(),
      ]);

      final invoices = results[0] as List<InvoiceEntity>;
      final recipients = results[1] as List<SafeRecipientEntity>;

      emit(
        state.copyWith(
          status: invoices.isEmpty ? ViewStatus.empty : ViewStatus.success,
          invoices: invoices,
          savedRecipients: recipients,
          clearError: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ViewStatus.error,
          errorMessage: 'E-Fatura listesi GİB entegrasyonundan yüklenemedi.',
        ),
      );
    }
  }

  void setTab({required bool isIncoming}) {
    emit(state.copyWith(isIncomingTab: isIncoming));
  }

  void setStatusFilter(InvoiceStatusFilter filter) {
    emit(state.copyWith(statusFilter: filter));
  }

  void setDocTypeFilter(String docType) {
    emit(state.copyWith(selectedDocType: docType));
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void resetFilters() {
    searchController.clear();
    emit(
      state.copyWith(
        searchQuery: '',
        statusFilter: InvoiceStatusFilter.all,
        selectedDocType: 'Tümü',
      ),
    );
  }

  Future<void> payInvoiceFast({
    required InvoiceEntity invoice,
    required String payerUserId,
    required String targetIban,
  }) async {
    if (state.isPaying) return;
    if (payerUserId.isEmpty) {
      emit(
        state.copyWith(
          actionMessage: 'Ödeme işlemi için aktif kullanıcı oturumu bulunamadı.',
          isErrorAction: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isPaying: true,
        payingInvoiceId: invoice.invoiceId,
        clearActionMessage: true,
      ),
    );

    try {
      await _invoiceRepo.payInvoiceWithFast(
        companyId: state.companyId,
        invoiceId: invoice.invoiceId,
        payerUserId: payerUserId,
        targetIban: targetIban,
      );
      final updatedInvoices = await _invoiceRepo.getInvoices(
        companyId: state.companyId,
      );
      emit(
        state.copyWith(
          status: updatedInvoices.isEmpty
              ? ViewStatus.empty
              : ViewStatus.success,
          invoices: updatedInvoices,
          isPaying: false,
          clearPayingInvoice: true,
          actionMessage:
              '${invoice.counterpartyName} faturası FAST ile ödendi ve ERP defterine işlendi.',
          isErrorAction: false,
        ),
      );
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      emit(
        state.copyWith(
          isPaying: false,
          clearPayingInvoice: true,
          actionMessage: msg.isEmpty ? 'Fatura ödemesi tamamlanamadı.' : msg,
          isErrorAction: true,
        ),
      );
    }
  }

  void notifyMessage(String message, {bool isError = false}) {
    emit(state.copyWith(actionMessage: message, isErrorAction: isError));
  }

  void clearActionMessage() {
    emit(state.copyWith(clearActionMessage: true));
  }

  Future<void> refresh() async {
    await loadInvoices(companyId: state.companyId);
  }

  @override
  Future<void> close() {
    searchController.dispose();
    return super.close();
  }
}

