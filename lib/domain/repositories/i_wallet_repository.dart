import '../entities/wallet_entity.dart';

abstract class IWalletRepository {
  Future<List<WalletEntity>> getAllWallets();
  Future<WalletEntity?> getWalletById(String walletId);
  Stream<WalletEntity?> watchWallet(String walletId);
  Stream<WalletEntity?> watchUserWallet(String userId);
}
