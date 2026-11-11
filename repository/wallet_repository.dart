import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/wallet_model.dart';

import 'i_wallet_repository.dart';

class WalletRepository implements IWalletRepository {
  static const String _baseUrl = 'https://url';
  static const Duration _timeOut = Duration(seconds: 10);

 
  @override

  Future<List<WalletModel?>> getAllWallets() async {
    
    try {
      
      final uri = Uri.parse('$_baseUrl/wallets');
      
      final response = await http.get(uri).timeout(_timeOut);

      if (response.statusCode == 200) {
       
        final solvedResponse = utf8.decode(response.bodyBytes);
        final List<dynamic> jsonList = jsonDecode(solvedResponse) as List<dynamic>;

        return jsonList
           
            .map((item) => WalletModel.fromJson(item as Map<String, dynamic>))
            
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
  Future<WalletModel?> getExpenseById(String walletId) async {
    try {
      
      final uri = Uri.parse('$_baseUrl/wallets/$id');
      final response = await http.get(uri).timeout(_timeOut);

      if (response.statusCode == 200) {
        
        final solvedResponse = utf8.decode(response.bodyBytes);
        
        final Map<String, dynamic> jsonMap = jsonDecode(solvedResponse) as Map<String, dynamic>;
        
        return WalletModel.fromJson(jsonMap);
      } else {
        return null;
      }
    } catch (error) {
      print("$error");
      return null;
    }
  }
}