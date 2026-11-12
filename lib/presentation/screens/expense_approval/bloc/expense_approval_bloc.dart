import 'package:flutter_bloc/flutter_bloc.dart';

import 'expense_approval_event.dart';
import 'expense_approval_state.dart';

class ExpenseApprovalBloc
    extends Bloc<ExpenseApprovalEvent, ExpenseApprovalState> {
  ExpenseApprovalBloc() : super(const ExpenseApprovalState()) {
    on<ExpenseApprovalLoadRequested>(_onLoadRequested);
    on<ExpenseSingleApproved>(_onSingleApproved);
    on<ExpenseSingleRejected>(_onSingleRejected);
    on<ExpenseBatchApproved>(_onBatchApproved);
  }

  void _onLoadRequested(
    ExpenseApprovalLoadRequested event,
    Emitter<ExpenseApprovalState> emit,
  ) {
    emit(state.copyWith(status: ExpenseApprovalStatus.loading));

    // logic.md: Görsel 8 ve 6'daki 3 bekleyen masraf kalemi
    final defaultExpenses = [
      const PendingExpenseItem(
        expenseId: 'exp_001',
        employeeName: 'Ahmet Yılmaz',
        role: 'Kıdemli Satış Temsilcisi',
        category: 'Temsil & Ağırlama',
        amountKurus: 125050, // ₺1.250,50
        vatAmountKurus: 20840, // ₺208,40 (%20 KDV)
        date: '12 Kasım 2026',
        badgeType: ApprovalBadgeType.aiOcr,
        badgeText: 'AI-OCR %98 Doğrulandı',
      ),
      const PendingExpenseItem(
        expenseId: 'exp_002',
        employeeName: 'Elif Demir',
        role: 'Pazarlama Yöneticisi',
        category: 'Ulaşım & Seyahat',
        amountKurus: 198000, // ₺1.980,00
        vatAmountKurus: 33000, // ₺330,00 (%20 KDV)
        date: '11 Kasım 2026',
        badgeType: ApprovalBadgeType.limitAlert,
        badgeText: 'Departman Temsil Limiti ₺2.000 Sınırında %99 Doluluk',
      ),
      const PendingExpenseItem(
        expenseId: 'exp_003',
        employeeName: 'Caner Kılıç',
        role: 'Yazılım Mimarı',
        category: 'Yazılım & Bulut Lisansı',
        amountKurus: 66000, // ₺660,00
        vatAmountKurus: 11000, // ₺110,00 (%20 KDV)
        date: '10 Kasım 2026',
        badgeType: ApprovalBadgeType.ctoSigned,
        badgeText: 'CTO İmzalı Ön Onaylı',
      ),
    ];

    emit(state.copyWith(
      status: ExpenseApprovalStatus.success,
      expenses: defaultExpenses,
    ));
  }

  void _onSingleApproved(
    ExpenseSingleApproved event,
    Emitter<ExpenseApprovalState> emit,
  ) {
    final updatedList = state.expenses.map((e) {
      if (e.expenseId == event.expenseId) {
        return e.copyWith(isApproved: true);
      }
      return e;
    }).toList();

    emit(state.copyWith(
      expenses: updatedList,
      successMessage: 'Masraf talebi başarıyla onaylandı.',
    ));
  }

  void _onSingleRejected(
    ExpenseSingleRejected event,
    Emitter<ExpenseApprovalState> emit,
  ) {
    final updatedList = state.expenses.map((e) {
      if (e.expenseId == event.expenseId) {
        return e.copyWith(isRejected: true);
      }
      return e;
    }).toList();

    emit(state.copyWith(
      expenses: updatedList,
      successMessage: 'Masraf talebi reddedildi.',
    ));
  }

  /// logic.md: Tümünü İncele & Toplu Onayla (₺3.890,50)
  Future<void> _onBatchApproved(
    ExpenseBatchApproved event,
    Emitter<ExpenseApprovalState> emit,
  ) async {
    emit(state.copyWith(status: ExpenseApprovalStatus.loading));

    await Future<void>.delayed(const Duration(milliseconds: 1000));

    final approvedAll = state.expenses.map((e) {
      return e.copyWith(isApproved: true);
    }).toList();

    emit(state.copyWith(
      status: ExpenseApprovalStatus.batchSuccess,
      expenses: approvedAll,
      batchReferenceNo: 'BATCH-EXP-2026-9941',
      erpIntegrationNo: 'Logo & Paraşüt - #MSF-88410',
      blockchainTimestampHash:
          '0x8f7a93c4e12d45b76810cba483910fbc28d3617e9204c3821049581726a4bc2e',
      successMessage: '3 Masraf Kalemi Başarıyla Toplu Onaylandı!',
    ));
  }
}

