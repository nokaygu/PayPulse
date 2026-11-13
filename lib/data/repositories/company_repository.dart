import '../../domain/entities/company_entity.dart';
import '../../domain/repositories/i_company_repository.dart';
import '../datasources/remote/firebase_firestore_datasource.dart';
import '../models/company_model.dart';

class CompanyRepository implements ICompanyRepository {
  final FirebaseFirestoreDatasource _firestoreDatasource;

  CompanyRepository({FirebaseFirestoreDatasource? firestoreDatasource})
    : _firestoreDatasource =
          firestoreDatasource ?? FirebaseFirestoreDatasource();

  @override
  Future<List<CompanyEntity>> getAllCompanies() async {
    final companies = await _firestoreDatasource.getAllCompanies();
    return companies.map((c) => c.toEntity()).toList();
  }

  @override
  Future<CompanyEntity?> getCompanyById(String companyId) async {
    final model = await _firestoreDatasource.getCompany(companyId);
    return model?.toEntity();
  }

  @override
  Future<void> createCompany(CompanyEntity company) {
    return _firestoreDatasource.createCompany(CompanyModel.fromEntity(company));
  }
}
