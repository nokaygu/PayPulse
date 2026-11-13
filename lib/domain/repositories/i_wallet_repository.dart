import '../entities/wallet_entity.dart';

/// Clean Architecture Domain Katmanı: Cüzdan Veri Sözleşmesi
abstract class IWalletRepository {
  Future<List<WalletEntity>> getAllWallets();
  Future<WalletEntity?> getWalletById(String walletId);
  Future<WalletEntity?> getUserWallet(String userId);
  Stream<WalletEntity?> watchWallet(String walletId);
  Stream<WalletEntity?> watchUserWallet(String userId);
  Future<void> createWallet(WalletEntity wallet);
  Future<void> updateWallet(WalletEntity wallet);
}
