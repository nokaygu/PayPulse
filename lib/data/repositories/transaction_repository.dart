import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/config/app_mode.dart';
import '../../core/constants/firestore_collections.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/i_transaction_repository.dart';
import '../datasources/remote/firebase_firestore_datasource.dart';
import '../datasources/remote/local_demo_data_service.dart';
import '../models/transaction_model.dart';

/// Clean Architecture Data Katmanı: Finansal İşlemler Deposu (TransactionRepository)
/// FAST, POS ve Cüzdan hareketlerinin sorgulanmasını ve raporlanmasını yönetir.
class TransactionRepository implements ITransactionRepository {
  final FirebaseFirestoreDatasource _firestoreDatasource;
  final FirebaseFirestore? _firestoreOverride;

  TransactionRepository({
    FirebaseFirestoreDatasource? firestoreDatasource,
    FirebaseFirestore? firestore,
  })  : _firestoreDatasource =
            firestoreDatasource ?? FirebaseFirestoreDatasource(),
        _firestoreOverride = firestore;

  FirebaseFirestore get _firestore =>
      _firestoreOverride ?? FirebaseFirestore.instance;

  /// Değiştirilemez finansal hareket defterindeki (ledger) tüm kayıtları getirir
  @override
  Future<List<TransactionEntity>> getAllTransactions() async {
    if (AppMode.isDemoMode) {
      return LocalDemoDataService.instance
          .getAllTransactions()
          .map((m) => m.toEntity())
          .toList();
    }

    final snapshot = await _firestore
        .collection(FirestoreCollections.transactions)
        .get();
    return snapshot.docs
        .map((doc) => TransactionModel.fromJson(doc.data()).toEntity())
        .toList();
  }

  /// Benzersiz işlem referans numarasına (txId) göre işlem detayını getirir
  @override
  Future<TransactionEntity?> getTransactionById(String txId) async {
    try {
      final model = await _firestoreDatasource.getTransaction(txId);
      return model?.toEntity();
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<List<TransactionEntity>> watchUserTransactions(String userId) {
    return _firestoreDatasource
        .watchUserTransactions(userId)
        .map((list) => list.map((m) => m.toEntity()).toList());
  }

  @override
  Stream<List<TransactionEntity>> watchSentTransactions(String userId) {
    return _firestoreDatasource
        .watchSentTransactions(userId)
        .map((list) => list.map((m) => m.toEntity()).toList());
  }

  @override
  Stream<List<TransactionEntity>> watchReceivedTransactions(String userId) {
    return _firestoreDatasource
        .watchReceivedTransactions(userId)
        .map((list) => list.map((m) => m.toEntity()).toList());
  }

  @override
  Future<TransactionEntity> executeFastTransfer({
    required String senderUserId,
    required String receiverUserId,
    required int amountKurus,
    String currency = 'TRY',
    String? targetIban,
  }) async {
    final model = await _firestoreDatasource.executeFastTransfer(
      senderUserId: senderUserId,
      receiverUserId: receiverUserId,
      amountKurus: amountKurus,
      currency: currency,
      targetIban: targetIban,
    );
    return model.toEntity();
  }

  @override
  Future<TransactionEntity> executeFastTransferByIban({
    required String senderUserId,
    required String targetIban,
    required int amountKurus,
    String currency = 'TRY',
  }) async {
    final model = await _firestoreDatasource.executeFastTransferByIban(
      senderUserId: senderUserId,
      targetIban: targetIban,
      amountKurus: amountKurus,
      currency: currency,
    );
    return model.toEntity();
  }

  @override
  Future<TransactionEntity> executeQrWalletPayment({
    required String companyId,
    required String payerUserId,
    required int amountKurus,
    String currency = 'TRY',
  }) async {
    final model = await _firestoreDatasource.executeQrWalletPayment(
      companyId: companyId,
      payerUserId: payerUserId,
      amountKurus: amountKurus,
      currency: currency,
    );
    return model.toEntity();
  }

  @override
  Future<TransactionEntity> executeCardPosPayment({
    required String companyId,
    required String maskedCardNumber,
    required int amountKurus,
    String currency = 'TRY',
  }) async {
    final model = await _firestoreDatasource.executeCardPosPayment(
      companyId: companyId,
      maskedCardNumber: maskedCardNumber,
      amountKurus: amountKurus,
      currency: currency,
    );
    return model.toEntity();
  }
}
