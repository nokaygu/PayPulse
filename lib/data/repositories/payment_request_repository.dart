import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/config/app_mode.dart';
import '../../core/constants/firestore_collections.dart';
import '../../domain/repositories/i_payment_request_repository.dart';
import '../datasources/remote/firebase_firestore_datasource.dart';
import '../datasources/remote/local_demo_data_service.dart';
import '../models/payment_request_model.dart';

class PaymentRequestRepository implements IPaymentRequestRepository {
  final FirebaseFirestoreDatasource _firestoreDatasource;
  final FirebaseFirestore? _firestoreOverride;

  PaymentRequestRepository({
    FirebaseFirestoreDatasource? firestoreDatasource,
    FirebaseFirestore? firestore,
  })  : _firestoreDatasource =
            firestoreDatasource ?? FirebaseFirestoreDatasource(),
        _firestoreOverride = firestore;

  FirebaseFirestore get _firestore =>
      _firestoreOverride ?? FirebaseFirestore.instance;

  @override
  Future<List<PaymentRequestModel>> getAllPaymentRequests() async {
    if (AppMode.isDemoMode) {
      return LocalDemoDataService.instance.getAllPaymentRequests();
    }

    final snapshot = await _firestore
        .collection(FirestoreCollections.paymentRequests)
        .get();
    return snapshot.docs
        .map((doc) => PaymentRequestModel.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<PaymentRequestModel?> getPaymentRequestById(String requestId) async {
    try {
      return await _firestoreDatasource.getPaymentRequest(requestId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> createPaymentRequest(PaymentRequestModel request) {
    return _firestoreDatasource.createPaymentRequest(request);
  }
}
