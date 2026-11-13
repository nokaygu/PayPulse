import '../../core/utils/equatable.dart';

/// KVKK veri minimizasyonu uyarınca yalnızca maskeli ad ve IBAN taşıyan saf Domain Entity.
class SafeRecipientEntity extends Equatable {
  final String userId;
  final String maskedName;
  final String iban;

  const SafeRecipientEntity({
    required this.userId,
    required this.maskedName,
    required this.iban,
  });

  @override
  List<Object?> get props => [userId, maskedName, iban];
}

