import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/company_model.dart';

import 'i_company_repository.dart';

class CompanyRepository implements ICompanyRepository {
  static const String _baseUrl = 'https://url';
  static const Duration _timeOut = Duration(seconds: 10);

 
  @override

  Future<List<CompanyModel?>> getAllCompanies() async {
    
    try {
      
      final uri = Uri.parse('$_baseUrl/companies');
      
      final response = await http.get(uri).timeout(_timeOut);

      if (response.statusCode == 200) {
       
        final solvedResponse = utf8.decode(response.bodyBytes);
        final List<dynamic> jsonList = jsonDecode(solvedResponse) as List<dynamic>;

        return jsonList
           
            .map((item) => CompanyModel.fromJson(item as Map<String, dynamic>))
            
            .toList();
     
      } else {
        
        throw Exception('Server error: HTTP ${response.statusCode}');
      
      }
    
    } catch (error) {
      print("$error");
      rethrow;
    
    }
 
  }
  @override
  Future<CompanyModel?> getCompanyById(String companyId) async {
    try {
      
      final uri = Uri.parse('$_baseUrl/companies/$id');
      final response = await http.get(uri).timeout(_timeOut);

      if (response.statusCode == 200) {
        
        final solvedResponse = utf8.decode(response.bodyBytes);
        
        final Map<String, dynamic> jsonMap = jsonDecode(solvedResponse) as Map<String, dynamic>;
        
        return CompanyModel.fromJson(jsonMap);
      } else {
        return null;
      }
    } catch (error) {
      print("$error");
      return null;
    }
  }
}