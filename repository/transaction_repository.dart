import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/transaction_model.dart';

import 'i_transaction_repository.dart';

class TransactionRepository implements ITransactionRepository {
  static const String _baseUrl = 'https://url';
  static const Duration _timeOut = Duration(seconds: 10);

 
  @override

  Future<List<TransactionModel?>> getAllTransactions() async {
    
    try {
      
      final uri = Uri.parse('$_baseUrl/transactions');
      
      final response = await http.get(uri).timeout(_timeOut);

      if (response.statusCode == 200) {
       
        final solvedResponse = utf8.decode(response.bodyBytes);
        final List<dynamic> jsonList = jsonDecode(solvedResponse) as List<dynamic>;

        return jsonList
           
            .map((item) => TransactionModel.fromJson(item as Map<String, dynamic>))
            
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
  Future<TransactionModel?> getTransactionById(String txId) async {
    try {
      
      final uri = Uri.parse('$_baseUrl/transactions/$id');
      final response = await http.get(uri).timeout(_timeOut);

      if (response.statusCode == 200) {
        
        final solvedResponse = utf8.decode(response.bodyBytes);
        
        final Map<String, dynamic> jsonMap = jsonDecode(solvedResponse) as Map<String, dynamic>;
        
        return TransactionModel.fromJson(jsonMap);
      } else {
        return null;
      }
    } catch (error) {
      print("$error");
      return null;
    }
  }
}