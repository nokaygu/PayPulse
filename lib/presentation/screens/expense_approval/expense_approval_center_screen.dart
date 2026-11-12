import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../auth/widgets/status_badge_widget.dart';
import 'bloc/expense_approval_bloc.dart';
import 'bloc/expense_approval_event.dart';
import 'bloc/expense_approval_state.dart';

class ExpenseApprovalCenterScreen extends StatelessWidget {
  const ExpenseApprovalCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ExpenseApprovalBloc()..add(const ExpenseApprovalLoadRequested()),
      child: const _ExpenseApprovalCenterView(),
    );
  }
}

class _ExpenseApprovalCenterView extends StatelessWidget {
  const _ExpenseApprovalCenterView();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Masraf Onay Merkezi', style: AppTextStyles.headlineSmall),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Bekleyen (3)'),
              Tab(text: 'Onaylanan'),
              Tab(text: 'Reddedilen'),
            ],
          ),
        ),
        body: BlocConsumer<ExpenseApprovalBloc, ExpenseApprovalState>(
          listener: (context, state) {
            if (state.isBatchSuccess) {
              // logic.md: Görsel 6 - Toplu Onay Protokolü ekranına yönlendir
              context.go(AppRoutes.businessBatchApproval);
            }
            if (state.successMessage != null && !state.isBatchSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.successMessage!),
                  backgroundColor: AppLightColors.primary,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final pendingItems = state.pendingItems;

            return TabBarView(
              children: [
                // 1. Sekme: Bekleyen Masraflar
                Column(
                  children: [
                    // Üst Toplu Onay Özeti Kartı
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Bekleyen Toplam Tutar',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '₺${state.totalPendingLira.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white12,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'KDV İndirimi: +₺${state.totalVatDeductionLira.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Color(0xFF4ADE80),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: pendingItems.isEmpty
                                ? null
                                : () {
                                    context
                                        .read<ExpenseApprovalBloc>()
                                        .add(const ExpenseBatchApproved());
                                  },
                            style: FilledButton.styleFrom(
                              backgroundColor: AppLightColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            icon: const Icon(Icons.done_all_rounded, size: 20),
                            label: const Text(
                              'Tümünü İncele & Toplu Onayla (₺3.890,50)',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Bekleyen Masraf Kartları Listesi
                    Expanded(
                      child: pendingItems.isEmpty
                          ? const Center(
                              child: Text('Onay bekleyen masraf kalmadı.'),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: pendingItems.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final item = pendingItems[index];
                                return _ExpenseCard(item: item);
                              },
                            ),
                    ),
                  ],
                ),

                // 2. Sekme: Onaylananlar
                const Center(child: Text('Onaylanan masraflar arşivi.')),

                // 3. Sekme: Reddedilenler
                const Center(child: Text('Reddedilen masraflar arşivi.')),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  final PendingExpenseItem item;

  const _ExpenseCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppLightColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppLightColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Çalışan ve Tutar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.employeeName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppLightColors.onSurface,
                    ),
                  ),
                  Text(
                    '${item.role} • ${item.category}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₺${item.amountInLira.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                      color: AppLightColors.onSurface,
                    ),
                  ),
                  Text(
                    'KDV: ₺${item.vatInLira.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Özel Doğrulama / Uyarı Rozeti (logic.md gereksinimi)
          _buildBadge(item),
          const SizedBox(height: 16),

          // Aksiyon Butonları (Reddet / Onayla)
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context.read<ExpenseApprovalBloc>().add(
                          ExpenseSingleRejected(expenseId: item.expenseId),
                        );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppLightColors.error,
                    side: const BorderSide(color: AppLightColors.error),
                  ),
                  child: const Text('Reddet'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    context.read<ExpenseApprovalBloc>().add(
                          ExpenseSingleApproved(item.expenseId),
                        );
                  },
                  child: const Text('Onayla'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(PendingExpenseItem item) {
    switch (item.badgeType) {
      case ApprovalBadgeType.aiOcr:
        return const StatusBadgeWidget(
          label: 'AI-OCR %98 Doğrulandı',
          type: BadgeType.success,
          icon: Icons.auto_awesome_rounded,
        );
      case ApprovalBadgeType.limitAlert:
        return const StatusBadgeWidget(
          label: 'Departman Temsil Limiti ₺2.000 Sınırında %99 Doluluk',
          type: BadgeType.warning,
          icon: Icons.warning_amber_rounded,
        );
      case ApprovalBadgeType.ctoSigned:
        return const StatusBadgeWidget(
          label: 'CTO İmzalı Ön Onaylı',
          type: BadgeType.primary,
          icon: Icons.verified_user_rounded,
        );
    }
  }
}

