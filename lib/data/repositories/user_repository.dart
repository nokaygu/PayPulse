import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_collections.dart';
import '../../domain/repositories/i_user_repository.dart';
import '../datasources/remote/firebase_firestore_datasource.dart';
import '../models/user_model.dart';

class UserRepository implements IUserRepository {
  final FirebaseFirestoreDatasource _firestoreDatasource;
  final FirebaseFirestore _firestore;

  UserRepository({
    FirebaseFirestoreDatasource? firestoreDatasource,
    FirebaseFirestore? firestore,
  }) : _firestoreDatasource =
           firestoreDatasource ?? FirebaseFirestoreDatasource(),
       _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<UserModel?>> getAllUsers() async {
    try {
      final snapshot = await _firestore
          .collection(FirestoreCollections.users)
          .get();
      return snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .toList();
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<UserModel?> getUserById(String uid) async {
    try {
      return await _firestoreDatasource.getUserProfile(uid);
    } catch (_) {
      return null;
    }
  }
}
