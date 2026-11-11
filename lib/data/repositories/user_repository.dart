import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/user_model.dart';

import 'i_user_repository.dart';

class UserRepository implements IUserRepository {
  static const String _baseUrl = 'https://url';
  static const Duration _timeOut = Duration(seconds: 10);

 
  @override

  Future<List<UserModel?>> getAllUsers() async {
    
    try {
      
      final uri = Uri.parse('$_baseUrl/users');
      
      final response = await http.get(uri).timeout(_timeOut);

      if (response.statusCode == 200) {
       
        final solvedResponse = utf8.decode(response.bodyBytes);
        final List<dynamic> jsonList = jsonDecode(solvedResponse) as List<dynamic>;

        return jsonList
           
            .map((item) => UserModel.fromJson(item as Map<String, dynamic>))
            
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
  Future<UserModel?> getUserById(String uid) async {
    try {
      
      final uri = Uri.parse('$_baseUrl/users/$id');
      final response = await http.get(uri).timeout(_timeOut);

      if (response.statusCode == 200) {
        
        final solvedResponse = utf8.decode(response.bodyBytes);
        
        final Map<String, dynamic> jsonMap = jsonDecode(solvedResponse) as Map<String, dynamic>;
        
        return UserModel.fromJson(jsonMap);
      } else {
        return null;
      }
    } catch (error) {
      print("$error");
      return null;
    }
  }
}