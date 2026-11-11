import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/payment_request_model.dart';

import 'i_payment_request_repository.dart';

class PaymentRequestRepository implements IPaymentRequestRepository {
  static const String _baseUrl = 'https://url';
  static const Duration _timeOut = Duration(seconds: 10);

 
  @override

  Future<List<PaymentRequestModel?>> getAllPaymentRequest() async {
    
    try {
      
      final uri = Uri.parse('$_baseUrl/payment_requests');
      
      final response = await http.get(uri).timeout(_timeOut);

      if (response.statusCode == 200) {
       
        final solvedResponse = utf8.decode(response.bodyBytes);
        final List<dynamic> jsonList = jsonDecode(solvedResponse) as List<dynamic>;

        return jsonList
           
            .map((item) => PaymentRequestModel.fromJson(item as Map<String, dynamic>))
            
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
  Future<PaymentRequestModel?> getPaymentRequestById(String requestId) async {
    try {
      
      final uri = Uri.parse('$_baseUrl/payment_requests/$id');
      final response = await http.get(uri).timeout(_timeOut);

      if (response.statusCode == 200) {
        
        final solvedResponse = utf8.decode(response.bodyBytes);
        
        final Map<String, dynamic> jsonMap = jsonDecode(solvedResponse) as Map<String, dynamic>;
        
        return PaymentRequestModel.fromJson(jsonMap);
      } else {
        return null;
      }
    } catch (error) {
      print("$error");
      return null;
    }
  }
}