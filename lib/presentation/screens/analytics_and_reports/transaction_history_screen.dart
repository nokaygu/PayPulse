import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/datasources/remote/firebase_firestore_datasource.dart';
import '../../../data/models/transaction_model.dart';
import '../../widgets/role_switch_app_bar.dart';
import '../../widgets/transaction_list_tile_widget.dart';
import '../auth/bloc/auth_bloc.dart';

/// Görsel 3: İşlem Geçmişi Ekranı
class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String _selectedFilter = 'Tümü';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authUser = context.watch<AuthBloc>().state.user;
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final String currentUserId =
        authUser?.uid ?? firebaseUser?.uid ?? 'user_b2c_001';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const RoleSwitchAppBar(isBusinessMode: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık Satırı
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE2E8F0),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    size: 18,
                    color: AppColors.darkNavy,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'İşlem Geçmişi',
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: AppColors.darkNavy,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Tüm Cüzdan Hareketleri',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0).withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.calendar_today_outlined,
                    size: 17,
                    color: AppColors.darkNavy,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0).withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.file_download_outlined,
                    size: 19,
                    color: AppColors.darkNavy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 1. Aylık Net Bakiye Değişimi Koyu Kartı (+₺23.350,00)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.heroCardGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.darkNavy.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AYLIK NET BAKİYE DEĞİŞİMİ',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: const Color(0xFF94A3B8),
                            fontSize: 9.5,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '+₺23.350,00',
                          style: AppTextStyles.numericBalance.copyWith(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Kasım 2026 • 42 Başarılı İşlem',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: const Color(0xFF94A3B8),
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 5,
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.south_west_rounded,
                                      size: 12,
                                      color: AppColors.primaryGreen,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Gelen',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: const Color(0xFF94A3B8),
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '+₺34.250',
                                  style: AppTextStyles.labelLarge.copyWith(
                                    color: AppColors.primaryGreen,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.north_east_rounded,
                                      size: 12,
                                      color: Color(0xFFF87171),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Giden',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: const Color(0xFF94A3B8),
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '-₺10.900',
                                  style: AppTextStyles.labelLarge.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 2. Arama Çubuğu + Filtre Butonu
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: 'İsim, IBAN, açıklama veya tutar ara...',
                        hintStyle: AppTextStyles.bodySmall.copyWith(
                          color: const Color(0xFF94A3B8),
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: Color(0xFF64748B),
                          size: 20,
                        ),
                        fillColor: Colors.transparent,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    color: AppColors.darkNavy,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 3. Filtre Çipleri (Tümü | ↓ Gelen (+) | ↑ Giden (-) | QR Ödemeleri)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterPill('Tümü'),
                  const SizedBox(width: 8),
                  _buildFilterPill('↓ Gelen (+)'),
                  const SizedBox(width: 8),
                  _buildFilterPill('↑ Giden (-)'),
                  const SizedBox(width: 8),
                  _buildFilterPill('QR Ödemeleri'),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 4. Vurgulu Son FAST Gönderimi Kartı (Zeynep Kaya -₺1.500,00)
            InkWell(
              onTap: () => context.push(
                '/home/transfer/receipt/PP-FAST-20261111-849201',
              ),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryGreen, width: 1.4),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1FAE5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.bolt_rounded,
                        color: AppColors.primaryTeal,
                        size: 24,
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
                                'SON FAST GÖNDERİMİ',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.primaryTeal,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1.5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD1FAE5),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Az Önce',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: const Color(0xFF065F46),
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Zeynep Kaya',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkNavy,
                            ),
                          ),
                          Text(
                            'Hafta sonu kahvaltı payı 🥐 • Garanti BBVA',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: const Color(0xFF64748B),
                              fontSize: 11.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '-₺1.500,00',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.darkNavy,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Dekont >',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primaryTeal,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Canlı Firestore İşlem Geçmişi
            StreamBuilder<List<TransactionModel>>(
              stream: FirebaseFirestoreDatasource()
                  .watchUserTransactions(currentUserId),
              builder: (context, snapshot) {
                final liveTxs = snapshot.data ?? [];
                if (liveTxs.isEmpty) return const SizedBox.shrink();

                final filtered = liveTxs.where((tx) {
                  if (_selectedFilter == '↓ Gelen (+)') return !tx.isExpense;
                  if (_selectedFilter == '↑ Giden (-)') return tx.isExpense;
                  if (_selectedFilter == 'QR Ödemeleri') {
                    return tx.type.toLowerCase().contains('qr');
                  }
                  return true;
                }).where((tx) {
                  if (_searchQuery.isEmpty) return true;
                  final q = _searchQuery.toLowerCase();
                  return tx.title.toLowerCase().contains(q) ||
                      (tx.targetIban?.toLowerCase().contains(q) ?? false) ||
                      tx.category.toLowerCase().contains(q);
                }).toList();

                if (filtered.isEmpty) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGroupHeader(
                      'CANLI FİRESTORE İŞLEMLERİ',
                      '${filtered.length} İşlem',
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          for (int i = 0; i < filtered.length; i++) ...[
                            if (i > 0)
                              const Divider(
                                height: 1,
                                color: Color(0xFFF1F5F9),
                              ),
                            _buildLiveTile(filtered[i]),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                );
              },
            ),

            // ================= GRUP 1: BUGÜN, 11 KASIM =================
            if (_shouldShowGroup(
              hasIncome: false,
              hasExpense: true,
              hasQr: true,
            )) ...[
              _buildGroupHeader('BUGÜN, 11 KASIM', '-₺1.685,00'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    if (_matchesFilter(
                      isIncome: false,
                      isQr: false,
                      title: 'Zeynep Kaya',
                    ))
                      TransactionListTileWidget(
                        title: 'Zeynep Kaya',
                        badgeText: 'FAST',
                        badgeBgColor: const Color(0xFFD1FAE5),
                        badgeTextColor: const Color(0xFF065F46),
                        subtitle: 'Para Transferi • 15:42',
                        amountText: '-₺1.500,00',
                        isIncome: false,
                        statusOrNoteText: 'Tamamlandı',
                        icon: Icons.north_east_rounded,
                        onTap: () => context.push(
                          '/home/transfer/receipt/PP-FAST-20261111-849201',
                        ),
                      ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    if (_matchesFilter(
                      isIncome: false,
                      isQr: true,
                      title: 'Espresso Lab',
                    ))
                      TransactionListTileWidget(
                        title: 'Espresso Lab',
                        badgeText: 'QR Ödeme',
                        badgeBgColor: const Color(0xFFF1F5F9),
                        badgeTextColor: AppColors.darkNavy,
                        subtitle: 'Yeme & İçme • 11:20',
                        amountText: '-₺185,00',
                        isIncome: false,
                        statusOrNoteText: '₺9,25 Cashback',
                        statusTextColor: AppColors.primaryTeal,
                        icon: Icons.coffee_outlined,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ================= GRUP 2: DÜN, 10 KASIM =================
            if (_shouldShowGroup(
              hasIncome: true,
              hasExpense: true,
              hasQr: false,
            )) ...[
              _buildGroupHeader('DÜN, 10 KASIM', '+₺369,50'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    if (_matchesFilter(
                      isIncome: true,
                      isQr: false,
                      title: 'Mert Can',
                    ))
                      TransactionListTileWidget(
                        title: 'Mert Can',
                        badgeText: 'FAST',
                        badgeBgColor: const Color(0xFFD1FAE5),
                        badgeTextColor: const Color(0xFF065F46),
                        subtitle: 'Gelen Transfer • 19:15',
                        amountText: '+₺850,00',
                        isIncome: true,
                        statusOrNoteText: 'Hesaba Geçti',
                        icon: Icons.south_west_rounded,
                        iconBgColor: const Color(0xFFD1FAE5),
                        iconColor: AppColors.primaryTeal,
                      ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    if (_matchesFilter(
                      isIncome: false,
                      isQr: false,
                      title: 'Getir Perakende',
                    ))
                      TransactionListTileWidget(
                        title: 'Getir Perakende',
                        badgeText: 'Sanal Kart',
                        badgeBgColor: const Color(0xFFF1F5F9),
                        badgeTextColor: const Color(0xFF475569),
                        subtitle: 'Market & Alışveriş • 14:05',
                        amountText: '-₺480,50',
                        isIncome: false,
                        statusOrNoteText: '•• 4829',
                        icon: Icons.shopping_bag_outlined,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ================= GRUP 3: GEÇEN HAFTA =================
            if (_shouldShowGroup(
              hasIncome: true,
              hasExpense: true,
              hasQr: false,
            )) ...[
              _buildGroupHeader('GEÇEN HAFTA', '+₺31.330,01'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    if (_matchesFilter(
                      isIncome: true,
                      isQr: false,
                      title: 'TechSolutions A.Ş.',
                    ))
                      TransactionListTileWidget(
                        title: 'TechSolutions A.Ş.',
                        badgeText: 'Maaş / EFT',
                        badgeBgColor: const Color(0xFFD1FAE5),
                        badgeTextColor: const Color(0xFF065F46),
                        subtitle: 'Kurumsal Ödeme • 05 Kas',
                        amountText: '+₺32.150,00',
                        isIncome: true,
                        statusOrNoteText: 'Onaylandı',
                        icon: Icons.business_rounded,
                        iconBgColor: const Color(0xFFD1FAE5),
                        iconColor: AppColors.primaryTeal,
                      ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    if (_matchesFilter(
                      isIncome: false,
                      isQr: false,
                      title: 'Enerjisa İstanbul',
                    ))
                      TransactionListTileWidget(
                        title: 'Enerjisa İstanbul',
                        badgeText: 'Otomatik',
                        badgeBgColor: const Color(0xFFF1F5F9),
                        badgeTextColor: const Color(0xFF475569),
                        subtitle: 'Fatura Ödemesi • 03 Kas',
                        amountText: '-₺620,00',
                        isIncome: false,
                        statusOrNoteText: 'Fatura No: #9941',
                        icon: Icons.bolt_outlined,
                      ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    if (_matchesFilter(
                      isIncome: false,
                      isQr: false,
                      title: 'Netflix.com',
                    ))
                      TransactionListTileWidget(
                        title: 'Netflix.com',
                        badgeText: 'Abonelik',
                        badgeBgColor: const Color(0xFFFEE2E2),
                        badgeTextColor: const Color(0xFF991B1B),
                        subtitle: 'Dijital Platform • 01 Kas',
                        amountText: '-₺199,99',
                        isIncome: false,
                        statusOrNoteText: 'Sanal Kart',
                        icon: Icons.tv_rounded,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
            ],

            // Resmi Hesap Ekstresi İndir Butonu
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.darkNavy,
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Resmi Hesap Ekstresi (PDF / Excel) başarıyla oluşturuldu.',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.description_outlined, size: 18),
                label: Text(
                  'Resmi Hesap Ekstresi İndir (PDF / Excel)',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.darkNavy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  bool _shouldShowGroup({
    required bool hasIncome,
    required bool hasExpense,
    required bool hasQr,
  }) {
    if (_selectedFilter == '↓ Gelen (+)') return hasIncome;
    if (_selectedFilter == '↑ Giden (-)') return hasExpense;
    if (_selectedFilter == 'QR Ödemeleri') return hasQr;
    return true;
  }

  bool _matchesFilter({
    required bool isIncome,
    required bool isQr,
    required String title,
  }) {
    if (_selectedFilter == '↓ Gelen (+)' && !isIncome) return false;
    if (_selectedFilter == '↑ Giden (-)' && isIncome) return false;
    if (_selectedFilter == 'QR Ödemeleri' && !isQr) return false;
    if (_searchQuery.trim().isNotEmpty) {
      return title.toLowerCase().contains(_searchQuery.toLowerCase());
    }
    return true;
  }

  Widget _buildFilterPill(String label) {
    final bool isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkNavy : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.darkNavy : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? Colors.white : const Color(0xFF475569),
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildGroupHeader(String dateLabel, String sumLabel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          dateLabel,
          style: AppTextStyles.labelSmall.copyWith(
            color: const Color(0xFF64748B),
            letterSpacing: 0.7,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          sumLabel,
          style: AppTextStyles.labelSmall.copyWith(
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildLiveTile(TransactionModel tx) {
    final bool isIncome = !tx.isExpense;
    final String amountFormatted = isIncome
        ? '+₺${(tx.amount / 100.0).toStringAsFixed(2).replaceAll('.', ',')}'
        : '-₺${(tx.amount / 100.0).toStringAsFixed(2).replaceAll('.', ',')}';

    return TransactionListTileWidget(
      title:
          tx.title.isNotEmpty ? tx.title : (tx.targetIban ?? 'FAST Transferi'),
      badgeText: tx.type.toUpperCase(),
      badgeBgColor:
          isIncome ? const Color(0xFFD1FAE5) : const Color(0xFFE0F2FE),
      badgeTextColor:
          isIncome ? const Color(0xFF065F46) : const Color(0xFF0369A1),
      subtitle:
          '${tx.category} • ${tx.timestamp.hour.toString().padLeft(2, '0')}:${tx.timestamp.minute.toString().padLeft(2, '0')}',
      amountText: amountFormatted,
      isIncome: isIncome,
      statusOrNoteText: tx.status,
      icon: isIncome ? Icons.south_west_rounded : Icons.north_east_rounded,
      iconBgColor:
          isIncome ? const Color(0xFFD1FAE5) : const Color(0xFFF1F5F9),
      iconColor: isIncome ? AppColors.primaryGreen : AppColors.darkNavy,
      onTap: () => context.push('/home/transfer/receipt/${tx.txId}'),
    );
  }
}
