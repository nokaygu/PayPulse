import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_collections.dart';
import '../../domain/repositories/i_wallet_repository.dart';
import '../datasources/remote/firebase_firestore_datasource.dart';
import '../models/wallet_model.dart';

class WalletRepository implements IWalletRepository {
  final FirebaseFirestoreDatasource _firestoreDatasource;
  final FirebaseFirestore _firestore;

  WalletRepository({
    FirebaseFirestoreDatasource? firestoreDatasource,
    FirebaseFirestore? firestore,
  }) : _firestoreDatasource =
           firestoreDatasource ?? FirebaseFirestoreDatasource(),
       _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<WalletModel?>> getAllWallets() async {
    try {
      final snapshot = await _firestore
          .collection(FirestoreCollections.wallets)
          .get();
      return snapshot.docs
          .map((doc) => WalletModel.fromJson(doc.data()))
          .toList();
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<WalletModel?> getWalletById(String walletId) async {
    try {
      return await _firestoreDatasource.getWallet(walletId);
    } catch (_) {
      return null;
    }
  }
}
