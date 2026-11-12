import '../../core/utils/equatable.dart';
import '../../domain/entities/budget_entity.dart';

/// Bütçe harcama kategorisi DTO modeli.
class BudgetCategoryModel extends Equatable {
  final String categoryId;
  final String title;
  final double spentAmount;
  final double allocatedAmount;
  final double percentage;
  final String colorHex;
  final String iconName;

  const BudgetCategoryModel({
    required this.categoryId,
    required this.title,
    required this.spentAmount,
    this.allocatedAmount = 5000.0,
    required this.percentage,
    this.colorHex = '#10B981',
    this.iconName = 'shopping_cart',
  });

  factory BudgetCategoryModel.fromJson(Map<String, dynamic> json) {
    return BudgetCategoryModel(
      categoryId: json['categoryId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      spentAmount: (json['spentAmount'] as num?)?.toDouble() ?? 0.0,
      allocatedAmount: (json['allocatedAmount'] as num?)?.toDouble() ?? 5000.0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      colorHex: json['colorHex'] as String? ?? '#10B981',
      iconName: json['iconName'] as String? ?? 'shopping_cart',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'title': title,
      'spentAmount': spentAmount,
      'allocatedAmount': allocatedAmount,
      'percentage': percentage,
      'colorHex': colorHex,
      'iconName': iconName,
    };
  }

  BudgetCategoryEntity toEntity() {
    return BudgetCategoryEntity(
      categoryId: categoryId,
      title: title,
      spentAmount: spentAmount,
      allocatedAmount: allocatedAmount,
      percentage: percentage,
      colorHex: colorHex,
      iconName: iconName,
    );
  }

  factory BudgetCategoryModel.fromEntity(BudgetCategoryEntity entity) {
    return BudgetCategoryModel(
      categoryId: entity.categoryId,
      title: entity.title,
      spentAmount: entity.spentAmount,
      allocatedAmount: entity.allocatedAmount,
      percentage: entity.percentage,
      colorHex: entity.colorHex,
      iconName: entity.iconName,
    );
  }

  BudgetCategoryModel copyWith({
    String? categoryId,
    String? title,
    double? spentAmount,
    double? allocatedAmount,
    double? percentage,
    String? colorHex,
    String? iconName,
  }) {
    return BudgetCategoryModel(
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      spentAmount: spentAmount ?? this.spentAmount,
      allocatedAmount: allocatedAmount ?? this.allocatedAmount,
      percentage: percentage ?? this.percentage,
      colorHex: colorHex ?? this.colorHex,
      iconName: iconName ?? this.iconName,
    );
  }

  @override
  List<Object?> get props => [
        categoryId,
        title,
        spentAmount,
        allocatedAmount,
        percentage,
        colorHex,
        iconName,
      ];
}

