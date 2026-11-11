import '../models/company_model.dart';
abstract class ICompanyRepository {
  Future<List<CompanyModel?>> getAllCompanies();
  Future<CompanyModel?> getCompanyById(String companyId);
// IUrunServisi soyut sınıfının kapanış parantezi
}