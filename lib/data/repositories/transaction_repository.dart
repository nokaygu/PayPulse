import '../../domain/entities/pos_transaction_entity.dart';
import '../../domain/entities/safe_recipient_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/i_transaction_repository.dart';
import '../datasources/remote/firebase_firestore_datasource.dart';

/// Clean Architecture Data Katmanı: Finansal İşlemler Deposu ([TransactionRepository])
class TransactionRepository implements ITransactionRepository {
  final FirebaseFirestoreDatasource _firestoreDatasource;

  TransactionRepository({FirebaseFirestoreDatasource? firestoreDatasource})
    : _firestoreDatasource =
          firestoreDatasource ?? FirebaseFirestoreDatasource();

  @override
  Future<List<TransactionEntity>> getAllTransactions() async {
    final list = await _firestoreDatasource.getAllTransactions();
    return list.map((t) => t.toEntity()).toList();
  }

  @override
  Future<TransactionEntity?> getTransactionById(String txId) async {
    final model = await _firestoreDatasource.getTransaction(txId);
    return model?.toEntity();
  }

  @override
  Future<List<TransactionEntity>> getSentTransactions(String userId) async {
    final list = await _firestoreDatasource.getSentTransactions(userId);
    return list.map((t) => t.toEntity()).toList();
  }

  @override
  Stream<List<TransactionEntity>> watchUserTransactions(String userId) {
    return _firestoreDatasource
        .watchUserTransactions(userId)
        .map((list) => list.map((t) => t.toEntity()).toList());
  }

  @override
  Stream<List<TransactionEntity>> watchSentTransactions(String userId) {
    return _firestoreDatasource
        .watchSentTransactions(userId)
        .map((list) => list.map((t) => t.toEntity()).toList());
  }

  @override
  Stream<List<TransactionEntity>> watchReceivedTransactions(String userId) {
    return _firestoreDatasource
        .watchReceivedTransactions(userId)
        .map((list) => list.map((t) => t.toEntity()).toList());
  }

  @override
  Future<SafeRecipientEntity?> findRecipientByIban(String rawIban) async {
    final model = await _firestoreDatasource.findRecipientByIban(rawIban);
    return model?.toEntity();
  }

  @override
  Future<List<SafeRecipientEntity>> getSavedRecipients() async {
    final list = await _firestoreDatasource.getSavedRecipients();
    return list.map((r) => r.toEntity()).toList();
  }

  @override
  Future<TransactionEntity> executeFastTransferByIban({
    required String senderUserId,
    required String targetIban,
    required int amountKurus,
    String currency = 'TRY',
    String? title,
    String? category,
  }) async {
    final tx = await _firestoreDatasource.executeFastTransferByIban(
      senderUserId: senderUserId,
      targetIban: targetIban,
      amountKurus: amountKurus,
      currency: currency,
    );
    return tx.toEntity().copyWith(
      title: title ?? tx.title,
      category: category ?? tx.category,
    );
  }

  @override
  Future<TransactionEntity> executeQrWalletPayment({
    required String companyId,
    required String payerUserId,
    required int amountKurus,
    String currency = 'TRY',
  }) async {
    final tx = await _firestoreDatasource.executeQrWalletPayment(
      companyId: companyId,
      payerUserId: payerUserId,
      amountKurus: amountKurus,
      currency: currency,
    );
    return tx.toEntity();
  }

  @override
  Future<TransactionEntity> executeCardPosPayment({
    required String companyId,
    required String maskedCardNumber,
    required int amountKurus,
    String currency = 'TRY',
  }) async {
    final tx = await _firestoreDatasource.executeCardPosPayment(
      companyId: companyId,
      maskedCardNumber: maskedCardNumber,
      amountKurus: amountKurus,
      currency: currency,
    );
    return tx.toEntity();
  }

  @override
  Future<List<PosTransactionEntity>> getPosTransactions(String companyId) async {
    final list = await _firestoreDatasource.getPosTransactions(companyId);
    return list.map((p) => p.toEntity()).toList();
  }
}
