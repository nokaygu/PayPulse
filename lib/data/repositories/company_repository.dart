import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_collections.dart';
import '../../domain/repositories/i_company_repository.dart';
import '../datasources/remote/firebase_firestore_datasource.dart';
import '../models/company_model.dart';

class CompanyRepository implements ICompanyRepository {
  final FirebaseFirestoreDatasource _firestoreDatasource;
  final FirebaseFirestore _firestore;

  CompanyRepository({
    FirebaseFirestoreDatasource? firestoreDatasource,
    FirebaseFirestore? firestore,
  }) : _firestoreDatasource =
           firestoreDatasource ?? FirebaseFirestoreDatasource(),
       _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<CompanyModel?>> getAllCompanies() async {
    try {
      final snapshot = await _firestore
          .collection(FirestoreCollections.companies)
          .get();
      return snapshot.docs
          .map((doc) => CompanyModel.fromJson(doc.data()))
          .toList();
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<CompanyModel?> getCompanyById(String companyId) async {
    try {
      return await _firestoreDatasource.getCompany(companyId);
    } catch (_) {
      return null;
    }
  }
}
