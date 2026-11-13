import '../entities/transaction_entity.dart';

abstract class ITransactionRepository {
  Future<List<TransactionEntity>> getAllTransactions();
  Future<TransactionEntity?> getTransactionById(String txId);
  Stream<List<TransactionEntity>> watchUserTransactions(String userId);
  Stream<List<TransactionEntity>> watchSentTransactions(String userId);
  Stream<List<TransactionEntity>> watchReceivedTransactions(String userId);
  Future<TransactionEntity> executeFastTransfer({
    required String senderUserId,
    required String receiverUserId,
    required int amountKurus,
    String currency = 'TRY',
    String? targetIban,
  });
  Future<TransactionEntity> executeFastTransferByIban({
    required String senderUserId,
    required String targetIban,
    required int amountKurus,
    String currency = 'TRY',
  });
  Future<TransactionEntity> executeQrWalletPayment({
    required String companyId,
    required String payerUserId,
    required int amountKurus,
    String currency = 'TRY',
  });
  Future<TransactionEntity> executeCardPosPayment({
    required String companyId,
    required String maskedCardNumber,
    required int amountKurus,
    String currency = 'TRY',
  });
}
