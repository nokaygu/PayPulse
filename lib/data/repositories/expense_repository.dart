import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_collections.dart';
import '../../domain/repositories/i_expense_repository.dart';
import '../datasources/remote/firebase_firestore_datasource.dart';
import '../models/expense_model.dart';

class ExpenseRepository implements IExpenseRepository {
  final FirebaseFirestoreDatasource _firestoreDatasource;
  final FirebaseFirestore _firestore;

  ExpenseRepository({
    FirebaseFirestoreDatasource? firestoreDatasource,
    FirebaseFirestore? firestore,
  }) : _firestoreDatasource =
           firestoreDatasource ?? FirebaseFirestoreDatasource(),
       _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<ExpenseModel?>> getAllExpenses() async {
    try {
      final snapshot = await _firestore
          .collection(FirestoreCollections.expenses)
          .get();
      return snapshot.docs
          .map((doc) => ExpenseModel.fromJson(doc.data()))
          .toList();
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<ExpenseModel?> getExpenseById(String expenseId) async {
    try {
      return await _firestoreDatasource.getExpense(expenseId);
    } catch (_) {
      return null;
    }
  }
}
