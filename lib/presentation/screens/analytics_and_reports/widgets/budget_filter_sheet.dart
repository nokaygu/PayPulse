import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/budget_analytics_cubit.dart';

/// Bütçe ve Analitik ekranı görünüm ve kategori filtresi alt penceresi (`StatelessWidget`).
class BudgetFilterSheet extends StatelessWidget {
  const BudgetFilterSheet({super.key});

  static Future<void> show(
    BuildContext context, {
    required BudgetAnalyticsCubit cubit,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider<BudgetAnalyticsCubit>.value(
        value: cubit,
        child: const BudgetFilterSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BudgetAnalyticsCubit>();

    return BlocBuilder<BudgetAnalyticsCubit, BudgetAnalyticsState>(
      builder: (context, state) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Bütçe Görünümü ve Filtreler',
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: AppColors.darkNavy,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        cubit.resetFiltersAndPeriod();
                        Navigator.pop(context);
                      },
                      child: const Text('Sıfırla'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  activeTrackColor: AppColors.primaryTeal,
                  title: Text(
                    'Yalnızca Limit Uyarısı (%80+)',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.darkNavy,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    'Sadece bütçe kotasına yaklaşan kategorileri listele',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  value: state.onlyWarningsFilter,
                  onChanged: cubit.setOnlyWarningsFilter,
                ),
                const Divider(height: 12),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  activeTrackColor: AppColors.primaryTeal,
                  title: Text(
                    'En Yüksek Harcamaya Göre Sırala',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.darkNavy,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    'Kategorileri harcanan tutara göre büyükten küçüğe sırala',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  value: state.sortDescendingBySpent,
                  onChanged: cubit.setSortDescendingBySpent,
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkNavy,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Uygula',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

