import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/budget_entity.dart';
import '../../../domain/repositories/i_budget_repository.dart';
import '../../widgets/budget_donut_chart.dart';
import '../../widgets/four_state_view.dart';
import '../../widgets/role_switch_app_bar.dart';
import '../../widgets/status_badge_widget.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_state.dart';
import 'bloc/budget_analytics_cubit.dart';

/// Bütçe ve Analitik Ekranı (Stateless + BudgetAnalyticsCubit)
class BudgetAnalyticsScreen extends StatelessWidget {
  const BudgetAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BudgetAnalyticsCubit>(
      create: (ctx) {
        final uid = ctx.read<AuthBloc>().state.user?.uid ?? '';
        return BudgetAnalyticsCubit(
          budgetRepository: ctx.read<IBudgetRepository>(),
        )..load(userId: uid);
      },
      child: const _BudgetAnalyticsBody(),
    );
  }
}

class _BudgetAnalyticsBody extends StatelessWidget {
  const _BudgetAnalyticsBody();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BudgetAnalyticsCubit>();

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) => prev.user?.uid != curr.user?.uid,
      listener: (ctx, authState) {
        ctx.read<BudgetAnalyticsCubit>().load(
          userId: authState.user?.uid ?? '',
        );
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: const RoleSwitchAppBar(isBusinessMode: false),
        body: BlocBuilder<BudgetAnalyticsCubit, BudgetAnalyticsState>(
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: cubit.refresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Başlık Satırı
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'FİNANSAL SAĞLIK',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: const Color(0xFF64748B),
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Bütçe ve Analitik',
                              style: AppTextStyles.headlineMedium.copyWith(
                                color: AppColors.darkNavy,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: cubit.refresh,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFE2E8F0,
                              ).withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.tune_rounded,
                              size: 20,
                              color: AppColors.darkNavy,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Haftalık | Aylık | Yıllık Segmented Bar
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0).withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: List.generate(
                          BudgetAnalyticsState.periodLabels.length,
                          (index) => _PeriodTab(
                            title: BudgetAnalyticsState.periodLabels[index],
                            isSelected: state.selectedPeriodIndex == index,
                            onTap: () => cubit.selectPeriod(index),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Dönem Göstergesi
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(
                          Icons.chevron_left_rounded,
                          color: Color(0xFF64748B),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 15,
                              color: AppColors.darkNavy,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Kasım 2026 (${state.selectedPeriodLabel})',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.darkNavy,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const StatusBadgeWidget(
                              label: 'Aktif',
                              type: BadgeType.success,
                            ),
                          ],
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Color(0xFF64748B),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    FourStateView(
                      status: state.status,
                      errorMessage:
                          state.errorMessage ?? 'Bütçe verileri yüklenemedi.',
                      emptyMessage: 'Henüz tanımlı bütçe kategorisi bulunmuyor.',
                      onRetry: cubit.refresh,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Ana Cüzdan Kotası Hero Kartı
                          _QuotaHeroCard(state: state),
                          const SizedBox(height: 16),

                          // 2. Harcama Trendi Özeti
                          _WeeklyTrendCard(state: state),
                          const SizedBox(height: 16),

                          // 3. Harcama Kategorileri (Donut Chart + Dinamik Liste)
                          _CategoryBreakdownCard(state: state),
                          const SizedBox(height: 16),

                          // 4. Akıllı Hedef ve Tasarruf
                          if (state.savingsGoal != null) ...[
                            _SavingsGoalCard(goal: state.savingsGoal!),
                            const SizedBox(height: 16),
                          ],

                          // 5. PayPulse Bütçe Tavsiyesi Kartı
                          _BudgetAdviceCard(state: state),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PeriodTab extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodTab({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: AppTextStyles.labelMedium.copyWith(
              color: isSelected ? AppColors.darkNavy : const Color(0xFF64748B),
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _QuotaHeroCard extends StatelessWidget {
  final BudgetAnalyticsState state;

  const _QuotaHeroCard({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.heroCardGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkNavy.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_outlined,
                      color: AppColors.primaryGreen,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ANA CÜZDAN KOTASI',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: const Color(0xFF94A3B8),
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              StatusBadgeWidget(
                label: '%${state.remainingPercent} Bütçe Kaldı',
                type: BadgeType.darkGlass,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Kalan Harcama Hakkı',
            style: AppTextStyles.bodySmall.copyWith(
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            state.formattedRemainingTl,
            style: AppTextStyles.numericBalance.copyWith(
              color: Colors.white,
              fontSize: 32,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Harcanan: ${state.formattedTotalSpentTl}',
                style: AppTextStyles.labelSmall.copyWith(color: Colors.white),
              ),
              Text(
                'Hedef: ${state.formattedTotalAllocatedTl}',
                style: AppTextStyles.labelSmall.copyWith(
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: state.spentRatio,
              minHeight: 8,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primaryGreen,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  color: AppColors.primaryGreen,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    state.warningCategories.isEmpty
                        ? 'Harika gidiyorsunuz! Tüm harcamalar planlanan bütçe limitleri içinde.'
                        : '${state.warningCategories.length} kategoride %90 limit eşiğine yaklaşıldı.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white,
                      fontSize: 11.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyTrendCard extends StatelessWidget {
  final BudgetAnalyticsState state;

  const _WeeklyTrendCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final avgWeekly = state.totalSpentTl / 4;
    final formattedAvg = BudgetAnalyticsState.formatTl(avgWeekly);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.bar_chart_rounded,
                      size: 18,
                      color: AppColors.darkNavy,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Dönemsel Harcama\nTrendi',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkNavy,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
              const StatusBadgeWidget(
                label: 'Dengeli Seyir',
                type: BadgeType.success,
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 135,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                _TrendWeekBar(
                  label: '1. Hafta',
                  heightFactor: 0.72,
                  isActive: false,
                ),
                SizedBox(width: 10),
                _TrendWeekBar(
                  label: '2. Hafta',
                  heightFactor: 0.75,
                  isActive: false,
                ),
                SizedBox(width: 10),
                _TrendWeekBar(
                  label: '3. Hafta',
                  heightFactor: 0.78,
                  isActive: false,
                ),
                SizedBox(width: 10),
                _TrendWeekBar(
                  label: '4. Hafta',
                  heightFactor: 0.74,
                  isActive: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFF1F5F9)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Haftalık Ortalama: $formattedAvg',
                style: AppTextStyles.bodySmall.copyWith(
                  color: const Color(0xFF64748B),
                ),
              ),
              Text(
                'Toplam: ${state.formattedTotalSpentTl}',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primaryTeal,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrendWeekBar extends StatelessWidget {
  final String label;
  final double heightFactor;
  final bool isActive;

  const _TrendWeekBar({
    required this.label,
    required this.heightFactor,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (isActive)
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF065F46),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'AKTİF',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: heightFactor,
                widthFactor: 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: isActive
                        ? const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFF34D399), Color(0xFF0D9488)],
                          )
                        : null,
                    color: isActive ? null : const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: isActive ? AppColors.darkNavy : const Color(0xFF64748B),
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBreakdownCard extends StatelessWidget {
  final BudgetAnalyticsState state;

  const _CategoryBreakdownCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final donutItems = state.donutItems;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.pie_chart_outline_rounded,
                      size: 18,
                      color: AppColors.darkNavy,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Harcama Kategorileri',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkNavy,
                    ),
                  ),
                ],
              ),
              Text(
                '${state.categories.length} Kategori',
                style: AppTextStyles.labelSmall.copyWith(
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              BudgetDonutChart(
                items: donutItems,
                centerTitle: state.compactCenterSpent,
                centerSubtitle: state.selectedPeriodLabel,
                size: 135,
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: donutItems.map((c) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: c.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              c.label,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.darkNavy,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          ...state.categories.map((cat) {
            final color = BudgetAnalyticsState.parseHexColor(cat.colorHex);
            final progress = cat.allocatedAmount > 0
                ? (cat.spentAmount / cat.allocatedAmount).clamp(0.0, 1.0)
                : 0.0;
            final pct = (progress * 100).round();
            final statusText = cat.isLimitWarning
                ? 'Limit uyarısı (%$pct)'
                : '%$pct kullanıldı';

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _CategoryBox(
                icon: _iconForCategory(cat.iconName),
                iconBg: color,
                title: cat.title,
                quota:
                    'Kota: ${BudgetAnalyticsState.formatTl(cat.allocatedAmount)}',
                amount: BudgetAnalyticsState.formatTl(cat.spentAmount),
                statusText: statusText,
                statusColor: cat.isLimitWarning
                    ? AppColors.expenseRed
                    : AppColors.primaryTeal,
                progress: progress,
                barColor: color,
              ),
            );
          }),
        ],
      ),
    );
  }

  IconData _iconForCategory(String iconName) {
    switch (iconName) {
      case 'shopping_cart':
        return Icons.shopping_cart_outlined;
      case 'directions_car':
      case 'local_gas_station':
        return Icons.local_gas_station_outlined;
      case 'receipt_long':
        return Icons.receipt_long_outlined;
      case 'restaurant':
        return Icons.restaurant_outlined;
      default:
        return Icons.category_outlined;
    }
  }
}

class _CategoryBox extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String title;
  final String quota;
  final String amount;
  final String statusText;
  final Color statusColor;
  final double progress;
  final Color barColor;

  const _CategoryBox({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.quota,
    required this.amount,
    required this.statusText,
    required this.statusColor,
    required this.progress,
    required this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkNavy,
                      ),
                    ),
                    Text(
                      quota,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: const Color(0xFF64748B),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amount,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkNavy,
                    ),
                  ),
                  Text(
                    statusText,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _SavingsGoalCard extends StatelessWidget {
  final SavingsGoalEntity goal;

  const _SavingsGoalCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    final targetText = BudgetAnalyticsState.formatTl(goal.targetAmount);
    final currentText = BudgetAnalyticsState.formatTl(goal.currentAmount);
    final remainingText = BudgetAnalyticsState.formatTl(goal.remainingAmount);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1FAE5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.savings_outlined,
                      size: 18,
                      color: AppColors.primaryTeal,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Akıllı Hedef ve\nTasarruf',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkNavy,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
              StatusBadgeWidget(
                label: '%${goal.progressPercentage} Tamamlandı',
                type: BadgeType.success,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.darkNavy,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.laptop_mac_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkNavy,
                        ),
                      ),
                      Text(
                        'Hedef: $targetText',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Bitiş Hedefi: ${goal.deadline}',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primaryTeal,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Biriken Fon',
                style: AppTextStyles.bodySmall.copyWith(
                  color: const Color(0xFF64748B),
                ),
              ),
              Text(
                '$currentText / $targetText',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.darkNavy,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: goal.progressRatio,
              minHeight: 8,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primaryGreen,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tahmini Bitiş: ${goal.deadline}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: const Color(0xFF64748B),
                  fontSize: 11,
                ),
              ),
              Text(
                'Hedefe $remainingText kaldı',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primaryTeal,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkNavy,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 46),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${goal.title} birikim hedefi güncellenmeye hazır.',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.edit_outlined, size: 16),
            label: const Text('Bütçe Hedefini Düzenle'),
          ),
        ],
      ),
    );
  }
}

class _BudgetAdviceCard extends StatelessWidget {
  final BudgetAnalyticsState state;

  const _BudgetAdviceCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final warnings = state.warningCategories;
    final adviceBody = warnings.isNotEmpty
        ? '${warnings.map((w) => w.title).join(', ')} kategorileriniz %90 limit eşiğine ulaştı. Sabit aboneliklerinizi gözden geçirerek aylık tasarrufunuzu artırabilirsiniz.'
        : 'Harcama dağılımınız planladığınız kotalarla uyumlu ilerliyor. Kalan bütçenizin bir kısmını akıllı hedef fonuna aktarabilirsiniz.';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFD1FAE5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lightbulb_outline_rounded,
              color: AppColors.primaryTeal,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PayPulse Bütçe Tavsiyesi',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.darkNavy,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  adviceBody,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF475569),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
