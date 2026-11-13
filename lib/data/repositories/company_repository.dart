import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/config/app_mode.dart';
import '../../core/constants/firestore_collections.dart';
import '../../domain/repositories/i_company_repository.dart';
import '../datasources/remote/firebase_firestore_datasource.dart';
import '../datasources/remote/local_demo_data_service.dart';
import '../models/company_model.dart';

class CompanyRepository implements ICompanyRepository {
  final FirebaseFirestoreDatasource _firestoreDatasource;
  final FirebaseFirestore? _firestoreOverride;

  CompanyRepository({
    FirebaseFirestoreDatasource? firestoreDatasource,
    FirebaseFirestore? firestore,
  })  : _firestoreDatasource =
            firestoreDatasource ?? FirebaseFirestoreDatasource(),
        _firestoreOverride = firestore;

  FirebaseFirestore get _firestore =>
      _firestoreOverride ?? FirebaseFirestore.instance;

  @override
  Future<List<CompanyModel>> getAllCompanies() async {
    if (AppMode.isDemoMode) {
      return LocalDemoDataService.instance.getAllCompanies();
    }

    final snapshot = await _firestore
        .collection(FirestoreCollections.companies)
        .get();
    return snapshot.docs
        .map((doc) => CompanyModel.fromJson(doc.data()))
        .toList();
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
