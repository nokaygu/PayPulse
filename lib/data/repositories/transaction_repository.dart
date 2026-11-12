import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_collections.dart';
import '../../domain/repositories/i_transaction_repository.dart';
import '../datasources/remote/firebase_firestore_datasource.dart';
import '../models/transaction_model.dart';

class TransactionRepository implements ITransActionRepository {
  final FirebaseFirestoreDatasource _firestoreDatasource;
  final FirebaseFirestore _firestore;

  TransactionRepository({
    FirebaseFirestoreDatasource? firestoreDatasource,
    FirebaseFirestore? firestore,
  }) : _firestoreDatasource =
           firestoreDatasource ?? FirebaseFirestoreDatasource(),
       _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<TransactionModel?>> getAllTransactions() async {
    try {
      final snapshot = await _firestore
          .collection(FirestoreCollections.transactions)
          .get();
      return snapshot.docs
          .map((doc) => TransactionModel.fromJson(doc.data()))
          .toList();
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<TransactionModel?> getTransactionById(String txId) async {
    try {
      return await _firestoreDatasource.getTransaction(txId);
    } catch (_) {
      return null;
    }
  }
}
