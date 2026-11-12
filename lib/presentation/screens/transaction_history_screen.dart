import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/firestore_seeder.dart';
import '../../data/models/transaction_model.dart';
import '../widgets/dark_gradient_hero_card.dart';
import '../widgets/status_badge_widget.dart';

/// Görsel 3: İşlem Geçmişi Ekranı
/// Aylık Net Bakiye Değişimi, FAST vurgu kartı, filtreleme çipleri ve tarih gruplu liste.
class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String _selectedFilter = 'Tümü'; // 'Tümü', 'Gelen (+)', 'Giden (-)'
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final allTransactions = FirestoreSeeder.mockTransactions;

    // Filtreleme mantığı
    final filteredTransactions = allTransactions.where((tx) {
      if (_selectedFilter == 'Gelen (+)' && tx.isExpense) return false;
      if (_selectedFilter == 'Giden (-)' && !tx.isExpense) return false;
      if (_searchQuery.trim().isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesTitle = tx.title.toLowerCase().contains(query);
        final matchesCategory = tx.category.toLowerCase().contains(query);
        final matchesTxId = tx.txId.toLowerCase().contains(query);
        return matchesTitle || matchesCategory || matchesTxId;
      }
      return true;
    }).toList();

    // Tarihe göre gruplama
    final Map<String, List<TransactionModel>> grouped = {};
    for (final tx in filteredTransactions) {
      grouped.putIfAbsent(tx.dateGroup, () => []).add(tx);
    }

    // Son FAST işlemi (Zeynep Kaya)
    final recentFast = allTransactions.firstWhere(
      (tx) => tx.isFastTransfer && tx.isExpense,
      orElse: () => allTransactions.first,
    );

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'İşlem Geçmişi',
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Ekstre İndir (PDF)',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Kasım 2026 Hesap Özeti PDF olarak indirildi.'),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Aylık Net Bakiye Değişimi Kartı (Koyu Yeşil/Lacivert Gradyanlı)
            DarkGradientHeroCard(
              title: 'Aylık Net Bakiye Değişimi (Kasım)',
              mainAmount: '+₺23.350,00',
              subtitle: 'Son güncelleme: Bugün 14:30',
              topRightBadge: const StatusBadgeWidget(
                label: 'Kasım 2026',
                type: BadgeType.darkGlass,
                icon: Icons.calendar_today_rounded,
              ),
              bottomChild: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.incomeGreen.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_downward_rounded,
                                size: 14,
                                color: AppColors.incomeGreen,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Toplam Gelen',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '+₺34.250,00',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 32,
                    width: 1,
                    color: Colors.white.withOpacity(0.12),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.expenseRed.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_upward_rounded,
                                size: 14,
                                color: AppColors.expenseRed,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Toplam Giden',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '-₺10.900,00',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Vurgulu Son FAST Gönderimi Kartı (Zeynep Kaya -1.500 TL)
            InkWell(
              onTap: () {
                context.push('/home/transfer/receipt/${recentFast.txId}');
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primaryGreen.withOpacity(0.35),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.bolt_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Son FAST Gönderimi',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.primaryTeal,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const StatusBadgeWidget(
                                label: 'FAST',
                                type: BadgeType.success,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            recentFast.title,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Dekontu görüntülemek için dokunun',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '-₺1.500,00',
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: AppColors.expenseRed,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.primaryTeal,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 3. Arama Çubuğu
            TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              decoration: InputDecoration(
                hintText: 'Kişi, kurum veya işlem ara...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 4. Filtreleme Çipleri (Tümü, Gelen (+), Giden (-))
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Tümü', allTransactions.length),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Gelen (+)',
                    allTransactions.where((t) => !t.isExpense).length,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Giden (-)',
                    allTransactions.where((t) => t.isExpense).length,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 5. Tarihe Göre Gruplanmış Liste (BUGÜN, 11 KASIM / DÜN / GEÇEN HAFTA)
            if (grouped.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 48,
                        color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Kriterlere uygun işlem bulunamadı',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...grouped.entries.map((group) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        group.key,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Card(
                      margin: EdgeInsets.zero,
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: group.value.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          color: colorScheme.outlineVariant.withOpacity(0.5),
                        ),
                        itemBuilder: (context, index) {
                          final tx = group.value[index];
                          return _buildTransactionTile(context, tx);
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int count) {
    final isSelected = _selectedFilter == label;
    final colorScheme = Theme.of(context).colorScheme;

    return ChoiceChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (val) {
        if (val) {
          setState(() {
            _selectedFilter = label;
          });
        }
      },
      selectedColor: AppColors.primaryGreen,
      backgroundColor: colorScheme.surfaceContainerLow,
      labelStyle: AppTextStyles.labelMedium.copyWith(
        color: isSelected ? Colors.white : colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? AppColors.primaryGreen
              : colorScheme.outlineVariant,
        ),
      ),
    );
  }

  Widget _buildTransactionTile(BuildContext context, TransactionModel tx) {
    final colorScheme = Theme.of(context).colorScheme;

    IconData iconData;
    Color iconColor;

    if (tx.isFastTransfer) {
      iconData = Icons.bolt_rounded;
      iconColor = AppColors.primaryTeal;
    } else if (tx.type == 'salary') {
      iconData = Icons.account_balance_wallet_rounded;
      iconColor = AppColors.incomeGreen;
    } else if (tx.type == 'bill') {
      iconData = Icons.electric_bolt_rounded;
      iconColor = AppColors.warningOrange;
    } else if (tx.type == 'subscription') {
      iconData = Icons.smart_display_rounded;
      iconColor = Colors.purple;
    } else {
      iconData = Icons.shopping_bag_rounded;
      iconColor = AppColors.primaryGreen;
    }

    final String amountFormatted = tx.isExpense
        ? '-₺${tx.amountInMajorUnit.toStringAsFixed(2)}'
        : '+₺${tx.amountInMajorUnit.toStringAsFixed(2)}';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(iconData, color: iconColor, size: 22),
      ),
      title: Text(
        tx.title,
        style: AppTextStyles.bodyLarge.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Row(
        children: [
          Text(
            tx.category,
            style: AppTextStyles.bodySmall.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '• ${tx.timestamp.hour.toString().padLeft(2, '0')}:${tx.timestamp.minute.toString().padLeft(2, '0')}',
            style: AppTextStyles.bodySmall.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            amountFormatted,
            style: AppTextStyles.bodyLarge.copyWith(
              color: tx.isExpense ? AppColors.expenseRed : AppColors.incomeGreen,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            tx.status,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.incomeGreen,
            ),
          ),
        ],
      ),
      onTap: () {
        context.push('/home/transfer/receipt/${tx.txId}');
      },
    );
  }
}

