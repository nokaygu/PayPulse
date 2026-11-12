import '../../core/utils/equatable.dart';

/// Harcama kategorisi kalemi (Market, Ulaşım, Faturalar, Yeme & İçme, Diğer).
class BudgetCategoryEntity extends Equatable {
  final String categoryId;
  final String title;
  final double spentAmount; // TL cinsinden (örn: 3536.40)
  final double allocatedAmount; // Kota
  final double percentage; // Yüzde oranı (örn: 42.0)
  final String colorHex;
  final String iconName;

  const BudgetCategoryEntity({
    required this.categoryId,
    required this.title,
    required this.spentAmount,
    this.allocatedAmount = 5000.0,
    required this.percentage,
    this.colorHex = '#10B981',
    this.iconName = 'shopping_cart',
  });

  bool get isLimitWarning => (spentAmount / (allocatedAmount > 0 ? allocatedAmount : 1)) >= 0.90;

  BudgetCategoryEntity copyWith({
    String? categoryId,
    String? title,
    double? spentAmount,
    double? allocatedAmount,
    double? percentage,
    String? colorHex,
    String? iconName,
  }) {
    return BudgetCategoryEntity(
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

/// Akıllı tasarruf ve birikim hedefi modeli (örn: Yeni Laptop M4 Pro 21.000 / 35.000 TL).
class SavingsGoalEntity extends Equatable {
  final String id;
  final String title;
  final double targetAmount; // örn: 35000.0
  final double currentAmount; // örn: 21000.0
  final String deadline; // örn: '15 Ocak 2027'
  final String iconName;

  const SavingsGoalEntity({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    this.deadline = '15 Ocak 2027',
    this.iconName = 'laptop_mac',
  });

  double get progressRatio => targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;
  int get progressPercentage => (progressRatio * 100).round();
  double get remainingAmount => (targetAmount - currentAmount).clamp(0.0, targetAmount);

  SavingsGoalEntity copyWith({
    String? id,
    String? title,
    double? targetAmount,
    double? currentAmount,
    String? deadline,
    String? iconName,
  }) {
    return SavingsGoalEntity(
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

/// Bireysel Cüzdan aylık bütçe kotasını ve genel analitik durumunu tutan Domain Entity.
class BudgetEntity extends Equatable {
  final double monthlyQuota; // 25.000,00 TL
  final double totalSpent; // 18.420,00 TL
  final List<BudgetCategoryEntity> categories;
  final SavingsGoalEntity savingsGoal;

  const BudgetEntity({
    this.monthlyQuota = 25000.0,
    this.totalSpent = 18420.0,
    required this.categories,
    required this.savingsGoal,
  });

  double get remainingQuota => (monthlyQuota - totalSpent).clamp(0.0, monthlyQuota);
  double get usageRatio => monthlyQuota > 0 ? (totalSpent / monthlyQuota).clamp(0.0, 1.0) : 0.0;
  int get usagePercentage => (usageRatio * 100).round();

  @override
  List<Object?> get props => [
        monthlyQuota,
        totalSpent,
        categories,
        savingsGoal,
      ];
}
