import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/config/app_mode.dart';
import '../../core/constants/firestore_collections.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/i_user_repository.dart';
import '../datasources/remote/firebase_firestore_datasource.dart';
import '../datasources/remote/local_demo_data_service.dart';
import '../models/user_model.dart';

class UserRepository implements IUserRepository {
  final FirebaseFirestoreDatasource _firestoreDatasource;
  final FirebaseFirestore? _firestoreOverride;

  UserRepository({
    FirebaseFirestoreDatasource? firestoreDatasource,
    FirebaseFirestore? firestore,
  })  : _firestoreDatasource =
            firestoreDatasource ?? FirebaseFirestoreDatasource(),
        _firestoreOverride = firestore;

  FirebaseFirestore get _firestore =>
      _firestoreOverride ?? FirebaseFirestore.instance;

  @override
  Future<List<UserEntity>> getAllUsers() async {
    if (AppMode.isDemoMode) {
      return LocalDemoDataService.instance
          .getAllUsers()
          .map((m) => m.toEntity())
          .toList();
    }

    final snapshot = await _firestore
        .collection(FirestoreCollections.users)
        .get();
    return snapshot.docs
        .map((doc) => UserModel.fromJson(doc.data()).toEntity())
        .toList();
  }

  @override
  Future<UserEntity?> getUserById(String uid) async {
    try {
      final model = await _firestoreDatasource.getUserProfile(uid);
      return model?.toEntity();
    } catch (_) {
      return null;
    }
  }
}
