import '../../core/utils/equatable.dart';
import '../../domain/entities/budget_entity.dart';

/// Birikim / Tasarruf hedefi DTO modeli.
class SavingsGoalModel extends Equatable {
  final String id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final String deadline;
  final String iconName;

  const SavingsGoalModel({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    this.deadline = '15 Ocak 2027',
    this.iconName = 'laptop_mac',
  });

  factory SavingsGoalModel.fromJson(Map<String, dynamic> json) {
    return SavingsGoalModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      targetAmount: (json['targetAmount'] as num?)?.toDouble() ?? 0.0,
      currentAmount: (json['currentAmount'] as num?)?.toDouble() ?? 0.0,
      deadline: json['deadline'] as String? ?? '15 Ocak 2027',
      iconName: json['iconName'] as String? ?? 'laptop_mac',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'deadline': deadline,
      'iconName': iconName,
    };
  }

  SavingsGoalEntity toEntity() {
    return SavingsGoalEntity(
      id: id,
      title: title,
      targetAmount: targetAmount,
      currentAmount: currentAmount,
      deadline: deadline,
      iconName: iconName,
    );
  }

  factory SavingsGoalModel.fromEntity(SavingsGoalEntity entity) {
    return SavingsGoalModel(
      id: entity.id,
      title: entity.title,
      targetAmount: entity.targetAmount,
      currentAmount: entity.currentAmount,
      deadline: entity.deadline,
      iconName: entity.iconName,
    );
  }

  SavingsGoalModel copyWith({
    String? id,
    String? title,
    double? targetAmount,
    double? currentAmount,
    String? deadline,
    String? iconName,
  }) {
    return SavingsGoalModel(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: deadline ?? this.deadline,
      iconName: iconName ?? this.iconName,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        targetAmount,
        currentAmount,
        deadline,
        iconName,
      ];
}

