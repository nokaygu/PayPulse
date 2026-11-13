import '../entities/pos_transaction_entity.dart';
import '../entities/safe_recipient_entity.dart';
import '../entities/transaction_entity.dart';

/// Clean Architecture Domain Katmanı: Finansal İşlem & Transfer Sözleşmesi
abstract class ITransactionRepository {
  Future<List<TransactionEntity>> getAllTransactions();
  Future<TransactionEntity?> getTransactionById(String txId);
  Future<List<TransactionEntity>> getSentTransactions(String userId);
  Stream<List<TransactionEntity>> watchUserTransactions(String userId);
  Stream<List<TransactionEntity>> watchSentTransactions(String userId);
  Stream<List<TransactionEntity>> watchReceivedTransactions(String userId);
  Future<SafeRecipientEntity?> findRecipientByIban(String rawIban);
  Future<List<SafeRecipientEntity>> getSavedRecipients();
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
    String? title,
    String? category,
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
  Future<List<PosTransactionEntity>> getPosTransactions(String companyId);
}
