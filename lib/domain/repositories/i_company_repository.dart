import '../entities/company_entity.dart';

/// Clean Architecture Domain Katmanı: B2B Şirket Veri Sözleşmesi
abstract class ICompanyRepository {
  Future<List<CompanyEntity>> getAllCompanies();
  Future<CompanyEntity?> getCompanyById(String companyId);
  Future<void> createCompany(CompanyEntity company);
}
