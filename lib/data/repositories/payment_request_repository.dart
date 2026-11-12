import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_collections.dart';
import '../../domain/repositories/i_payment_request_repository.dart';
import '../datasources/remote/firebase_firestore_datasource.dart';
import '../models/payment_request_model.dart';

class PaymentRequestRepository implements IPaymentRequestRepository {
  final FirebaseFirestoreDatasource _firestoreDatasource;
  final FirebaseFirestore _firestore;

  PaymentRequestRepository({
    FirebaseFirestoreDatasource? firestoreDatasource,
    FirebaseFirestore? firestore,
  }) : _firestoreDatasource =
           firestoreDatasource ?? FirebaseFirestoreDatasource(),
       _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<PaymentRequestModel?>> getAllPaymentRequest() async {
    try {
      final snapshot = await _firestore
          .collection(FirestoreCollections.paymentRequests)
          .get();
      return snapshot.docs
          .map((doc) => PaymentRequestModel.fromJson(doc.data()))
          .toList();
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<PaymentRequestModel?> getPaymentRequestById(String requestId) async {
    try {
      return await _firestoreDatasource.getPaymentRequest(requestId);
    } catch (_) {
      return null;
    }
  }
}
