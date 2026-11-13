import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/config/app_mode.dart';
import '../../core/constants/firestore_collections.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/repositories/i_expense_repository.dart';
import '../datasources/remote/firebase_firestore_datasource.dart';
import '../datasources/remote/local_demo_data_service.dart';
import '../models/expense_model.dart';

/// Clean Architecture Data Katmanı: Personel Masraf Yönetim Deposu (ExpenseRepository)
/// Çalışanların masraf taleplerini, onay/red döngülerini ve muhasebe kayıtlarını yönetir.
class ExpenseRepository implements IExpenseRepository {
  final FirebaseFirestoreDatasource _firestoreDatasource;
  final FirebaseFirestore? _firestoreOverride;

  ExpenseRepository({
    FirebaseFirestoreDatasource? firestoreDatasource,
    FirebaseFirestore? firestore,
  })  : _firestoreDatasource =
            firestoreDatasource ?? FirebaseFirestoreDatasource(),
        _firestoreOverride = firestore;

  FirebaseFirestore get _firestore =>
      _firestoreOverride ?? FirebaseFirestore.instance;

  /// Sistemdeki tüm masraf kayıtlarını listeler
  @override
  Future<List<ExpenseEntity>> getAllExpenses() async {
    if (AppMode.isDemoMode) {
      return LocalDemoDataService.instance
          .getAllExpenses()
          .map((m) => m.toEntity())
          .toList();
    }

    final snapshot = await _firestore
        .collection(FirestoreCollections.expenses)
        .get();
    return snapshot.docs
        .map((doc) => ExpenseModel.fromJson(doc.data()).toEntity())
        .toList();
  }

  /// Masraf ID'sine göre fiş, tutar, KDV ve onay durumunu getirir
  @override
  Future<ExpenseEntity?> getExpenseById(String expenseId) async {
    try {
      final model = await _firestoreDatasource.getExpense(expenseId);
      return model?.toEntity();
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<List<ExpenseEntity>> watchEmployeeExpenses(String employeeId) {
    return _firestoreDatasource
        .watchEmployeeExpenses(employeeId)
        .map((list) => list.map((m) => m.toEntity()).toList());
  }

  @override
  Stream<List<ExpenseEntity>> watchCompanyExpenses(String companyId) {
    return _firestoreDatasource
        .watchCompanyExpenses(companyId)
        .map((list) => list.map((m) => m.toEntity()).toList());
  }

  @override
  Future<void> createExpense(ExpenseEntity expense) {
    return _firestoreDatasource.createExpense(ExpenseModel.fromEntity(expense));
  }

  @override
  Future<void> approveExpense({
    required String expenseId,
    String? accountingCode,
  }) {
    return _firestoreDatasource.approveExpense(
      expenseId: expenseId,
      accountingCode: accountingCode,
    );
  }

  @override
  Future<void> rejectExpense({
    required String expenseId,
    required String reason,
  }) {
    return _firestoreDatasource.rejectExpense(
      expenseId: expenseId,
      reason: reason,
    );
  }
}
