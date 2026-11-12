/// Bütçe ve Analitik ekranındaki harcama kategorisi kalemini temsil eden Domain Entity sınıfı.
class BudgetCategoryItem {
  final String categoryId;
  final String title;
  final int quotaInKurus;
  final int spentInKurus;

  const BudgetCategoryItem({
    required this.categoryId,
    required this.title,
    required this.quotaInKurus,
    required this.spentInKurus,
  });

  /// Kota kullanım oranı (0.0 - 1.0+ arası).
  double get usageRatio {
    if (quotaInKurus <= 0) return 0.0;
    return spentInKurus / quotaInKurus;
  }

  int get usagePercentage => (usageRatio * 100).round();

  /// Görseldeki %90 ve üzeri kategori limit uyarısı.
  bool get isLimitWarning => usageRatio >= 0.90;

  bool get isOverBudget => spentInKurus > quotaInKurus;
}

/// Bireysel Cüzdan aylık bütçe kotası, kategori kırılımları ve akıllı tasarruf hedefini yöneten Domain Entity sınıfı.
class BudgetEntity {
  final int monthlyQuotaInKurus;
  final int spentInKurus;
  final List<BudgetCategoryItem> categories;
  final String savingsGoalTitle;
  final int savingsTargetInKurus;
  final int savingsCurrentInKurus;

  const BudgetEntity({
    required this.monthlyQuotaInKurus,
    required this.spentInKurus,
    required this.categories,
    required this.savingsGoalTitle,
    required this.savingsTargetInKurus,
    required this.savingsCurrentInKurus,
  });

  /// Kalan harcama hakkı (Kuruş) — negatife düşmez.
  int get remainingQuotaInKurus {
    final diff = monthlyQuotaInKurus - spentInKurus;
    return diff > 0 ? diff : 0;
  }

  double get spentRatio {
    if (monthlyQuotaInKurus <= 0) return 0.0;
    return (spentInKurus / monthlyQuotaInKurus).clamp(0.0, 1.0);
  }

  int get spentPercentage => (spentRatio * 100).round();

  /// Kalan bütçe yüzdesi (Görseldeki %44 Bütçe Kaldı göstergesi).
  int get remainingPercentage => 100 - spentPercentage;

  /// Akıllı tasarruf hedefi kalan tutar (Kuruş).
  int get remainingSavingsTargetInKurus {
    final diff = savingsTargetInKurus - savingsCurrentInKurus;
    return diff > 0 ? diff : 0;
  }

  /// Akıllı tasarruf hedefi tamamlanma yüzdesi (Görseldeki %60 Tamamlandı göstergesi).
  int get savingsProgressPercentage {
    if (savingsTargetInKurus <= 0) return 0;
    final ratio = (savingsCurrentInKurus / savingsTargetInKurus).clamp(
      0.0,
      1.0,
    );
    return (ratio * 100).round();
  }

  BudgetEntity copyWith({
    int? monthlyQuotaInKurus,
    int? spentInKurus,
    List<BudgetCategoryItem>? categories,
    String? savingsGoalTitle,
    int? savingsTargetInKurus,
    int? savingsCurrentInKurus,
  }) {
    return BudgetEntity(
      monthlyQuotaInKurus: monthlyQuotaInKurus ?? this.monthlyQuotaInKurus,
      spentInKurus: spentInKurus ?? this.spentInKurus,
      categories: categories ?? this.categories,
      savingsGoalTitle: savingsGoalTitle ?? this.savingsGoalTitle,
      savingsTargetInKurus: savingsTargetInKurus ?? this.savingsTargetInKurus,
      savingsCurrentInKurus:
          savingsCurrentInKurus ?? this.savingsCurrentInKurus,
    );
  }
}

