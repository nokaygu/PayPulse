import '../../data/models/transaction_model.dart';

abstract class ITransActionRepository {
  Future<List<TransactionModel?>> getAllTransactions();
  Future<TransactionModel?> getTransactionById(String txId);
}
