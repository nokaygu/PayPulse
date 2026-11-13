import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/equatable.dart';
import '../../../../core/utils/financial_amount.dart';
import '../../../../domain/entities/transaction_entity.dart';
import '../../../../domain/repositories/i_transaction_repository.dart';
import '../../../widgets/four_state_view.dart';

enum TransactionFilterType { all, income, expense, qr }

extension TransactionFilterTypeLabel on TransactionFilterType {
  String get label {
    switch (this) {
      case TransactionFilterType.all:
        return 'Tümü';
      case TransactionFilterType.income:
        return '↓ Gelen (+)';
      case TransactionFilterType.expense:
        return '↑ Giden (-)';
      case TransactionFilterType.qr:
        return 'QR Ödemeleri';
    }
  }
}

enum TransactionSortOrder { newest, oldest, highestAmount, lowestAmount }

extension TransactionSortOrderLabel on TransactionSortOrder {
  String get label {
    switch (this) {
      case TransactionSortOrder.newest:
        return 'En Yeni Tarih';
      case TransactionSortOrder.oldest:
        return 'En Eski Tarih';
      case TransactionSortOrder.highestAmount:
        return 'En Yüksek Tutar';
      case TransactionSortOrder.lowestAmount:
        return 'En Düşük Tutar';
    }
  }
}

class TransactionGroup {
  final String dateLabel;
  final List<TransactionEntity> items;
  final int netKurus;

  const TransactionGroup({
    required this.dateLabel,
    required this.items,
    required this.netKurus,
  });

  String get formattedNet {
    if (netKurus >= 0) {
      return '+${FinancialAmount.format(netKurus)}';
    }
    return '-${FinancialAmount.format(netKurus.abs())}';
  }
}

class TransactionHistoryState extends Equatable {
  final ViewStatus status;
  final String activeUserId;
  final List<TransactionEntity> transactions;
  final String searchQuery;
  final TransactionFilterType selectedFilter;
  final String? selectedCategory;
  final TransactionSortOrder sortOrder;
  final String? errorMessage;

  const TransactionHistoryState({
    this.status = ViewStatus.loading,
    this.activeUserId = '',
    this.transactions = const [],
    this.searchQuery = '',
    this.selectedFilter = TransactionFilterType.all,
    this.selectedCategory,
    this.sortOrder = TransactionSortOrder.newest,
    this.errorMessage,
  });

  bool get hasActiveAdvancedFilters =>
      selectedCategory != null || sortOrder != TransactionSortOrder.newest;

  List<String> get availableCategories {
    final cats = <String>{};
    for (final tx in transactions) {
      final clean = tx.category.trim();
      if (clean.isNotEmpty) cats.add(clean);
    }
    final list = cats.toList()..sort();
    return list;
  }

  bool isIncomingTransaction(TransactionEntity tx) {
    if (activeUserId.isNotEmpty) {
      if (tx.receiverId == activeUserId && tx.senderId != activeUserId) {
        return true;
      }
      if (tx.senderId == activeUserId && tx.receiverId != activeUserId) {
        return false;
      }
    }
    return !tx.isExpense;
  }

  int get totalIncomeKurus => transactions
      .where(isIncomingTransaction)
      .fold<int>(0, (sum, tx) => sum + tx.amount);

  int get totalExpenseKurus => transactions
      .where((tx) => !isIncomingTransaction(tx))
      .fold<int>(0, (sum, tx) => sum + tx.amount);

  int get netChangeKurus => totalIncomeKurus - totalExpenseKurus;

  String get formattedNetChange {
    final prefix = netChangeKurus >= 0 ? '+' : '-';
    return '$prefix${FinancialAmount.format(netChangeKurus.abs())}';
  }

  String get formattedTotalIncome => '+${FinancialAmount.format(totalIncomeKurus)}';

  String get formattedTotalExpense => '-${FinancialAmount.format(totalExpenseKurus)}';

  List<TransactionEntity> get filteredTransactions {
    final q = searchQuery.trim().toLowerCase();
    final filtered = transactions.where((tx) {
      final isIncome = isIncomingTransaction(tx);
      final isQr =
          tx.isPosPayment ||
          tx.category.toLowerCase().contains('qr') ||
          tx.type.toLowerCase().contains('qr');

      switch (selectedFilter) {
        case TransactionFilterType.all:
          break;
        case TransactionFilterType.income:
          if (!isIncome) return false;
        case TransactionFilterType.expense:
          if (isIncome) return false;
        case TransactionFilterType.qr:
          if (!isQr) return false;
      }

      if (selectedCategory != null && tx.category.trim() != selectedCategory) {
        return false;
      }

      if (q.isEmpty) return true;

      final titleMatch = tx.title.toLowerCase().contains(q);
      final ibanMatch = (tx.targetIban ?? '').toLowerCase().contains(q);
      final categoryMatch = tx.category.toLowerCase().contains(q);
      final amountMatch = FinancialAmount.format(tx.amount).toLowerCase().contains(q);
      final txIdMatch = tx.txId.toLowerCase().contains(q);

      return titleMatch || ibanMatch || categoryMatch || amountMatch || txIdMatch;
    }).toList();

    switch (sortOrder) {
      case TransactionSortOrder.newest:
        filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      case TransactionSortOrder.oldest:
        filtered.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      case TransactionSortOrder.highestAmount:
        filtered.sort((a, b) => b.amount.compareTo(a.amount));
      case TransactionSortOrder.lowestAmount:
        filtered.sort((a, b) => a.amount.compareTo(b.amount));
    }

    return filtered;
  }

  TransactionEntity? get latestFastTransaction {
    for (final tx in filteredTransactions) {
      if (tx.isFastTransfer) return tx;
    }
    return null;
  }

  List<TransactionGroup> get groupedTransactions {
    final Map<String, List<TransactionEntity>> bucket = {};
    for (final tx in filteredTransactions) {
      final key = tx.dateGroup.trim().isEmpty ? 'İŞLEMLER' : tx.dateGroup;
      bucket.putIfAbsent(key, () => <TransactionEntity>[]).add(tx);
    }

    return bucket.entries.map((entry) {
      final net = entry.value.fold<int>(0, (sum, tx) {
        return sum + (isIncomingTransaction(tx) ? tx.amount : -tx.amount);
      });
      return TransactionGroup(
        dateLabel: entry.key,
        items: entry.value,
        netKurus: net,
      );
    }).toList();
  }

  ViewStatus get listStatus {
    if (status == ViewStatus.loading) return ViewStatus.loading;
    if (status == ViewStatus.error) return ViewStatus.error;
    if (filteredTransactions.isEmpty) return ViewStatus.empty;
    return ViewStatus.success;
  }

  TransactionHistoryState copyWith({
    ViewStatus? status,
    String? activeUserId,
    List<TransactionEntity>? transactions,
    String? searchQuery,
    TransactionFilterType? selectedFilter,
    String? selectedCategory,
    bool clearCategory = false,
    TransactionSortOrder? sortOrder,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TransactionHistoryState(
      status: status ?? this.status,
      activeUserId: activeUserId ?? this.activeUserId,
      transactions: transactions ?? this.transactions,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      selectedCategory: clearCategory
          ? null
          : (selectedCategory ?? this.selectedCategory),
      sortOrder: sortOrder ?? this.sortOrder,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    activeUserId,
    transactions,
    searchQuery,
    selectedFilter,
    selectedCategory,
    sortOrder,
    errorMessage,
  ];
}

class TransactionHistoryCubit extends Cubit<TransactionHistoryState> {
  final ITransactionRepository _txRepo;
  final TextEditingController searchController = TextEditingController();
  StreamSubscription<List<TransactionEntity>>? _txSub;

  TransactionHistoryCubit({required ITransactionRepository transactionRepository})
    : _txRepo = transactionRepository,
      super(const TransactionHistoryState());

  Future<void> watchUser(String userId) async {
    if (userId.isEmpty) {
      await _txSub?.cancel();
      _txSub = null;
      emit(
        state.copyWith(
          status: ViewStatus.empty,
          activeUserId: '',
          transactions: const [],
          clearError: true,
        ),
      );
      return;
    }

    if (userId == state.activeUserId && _txSub != null) return;

    await _txSub?.cancel();
    emit(
      state.copyWith(
        status: ViewStatus.loading,
        activeUserId: userId,
        clearError: true,
      ),
    );

    _txSub = _txRepo
        .watchUserTransactions(userId)
        .listen(
          (list) {
            final sorted = List<TransactionEntity>.from(list)
              ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
            emit(
              state.copyWith(
                status: sorted.isEmpty ? ViewStatus.empty : ViewStatus.success,
                transactions: sorted,
                clearError: true,
              ),
            );
          },
          onError: (_) {
            emit(
              state.copyWith(
                status: ViewStatus.error,
                errorMessage: 'İşlem geçmişi yüklenirken bir sorun oluştu.',
              ),
            );
          },
        );
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void setFilter(TransactionFilterType filter) {
    emit(state.copyWith(selectedFilter: filter));
  }

  void setCategoryFilter(String? category) {
    emit(
      state.copyWith(
        selectedCategory: category,
        clearCategory: category == null,
      ),
    );
  }

  void setSortOrder(TransactionSortOrder order) {
    emit(state.copyWith(sortOrder: order));
  }

  void resetFilters() {
    searchController.clear();
    emit(
      state.copyWith(
        searchQuery: '',
        selectedFilter: TransactionFilterType.all,
        clearCategory: true,
        sortOrder: TransactionSortOrder.newest,
      ),
    );
  }

  Future<void> refresh() async {
    final uid = state.activeUserId;
    await _txSub?.cancel();
    _txSub = null;
    await watchUser(uid);
  }

  @override
  Future<void> close() async {
    await _txSub?.cancel();
    searchController.dispose();
    return super.close();
  }
}

