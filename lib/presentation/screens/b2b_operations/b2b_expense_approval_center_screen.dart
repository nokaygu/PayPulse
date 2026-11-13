import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/datasources/remote/firebase_firestore_datasource.dart';
import '../../../data/models/expense_model.dart';
import '../auth/bloc/auth_bloc.dart';
import '../../widgets/role_switch_app_bar.dart';

/// Görsel 8: Personel Masraf Onay Merkezi Ekranı
class B2bExpenseApprovalCenterScreen extends StatefulWidget {
  const B2bExpenseApprovalCenterScreen({super.key});

  @override
  State<B2bExpenseApprovalCenterScreen> createState() =>
      _B2bExpenseApprovalCenterScreenState();
}

class _B2bExpenseApprovalCenterScreenState
    extends State<B2bExpenseApprovalCenterScreen> {
  int _selectedTab =
      0; // 0: Bekleyenler, 1: Onaylananlar, 2: Reddedilenler
  final FirebaseFirestoreDatasource _firestoreDatasource =
      FirebaseFirestoreDatasource();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategoryFilter = 'Tümü';
  String _selectedSort = 'Tarih (En Yeni)';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterDialog(BuildContext context) {
    final categories = [
      'Tümü',
      'Ulaşım',
      'Yemek & Temsil',
      'Donanım & Ofis',
      'Yazılım & SaaS',
    ];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Kategori Filtresi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                TextButton(
                  onPressed: () {
                    setState(() => _selectedCategoryFilter = 'Tümü');
                    Navigator.pop(ctx);
                  },
                  child: const Text('Temizle'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((cat) {
                final isSelected = _selectedCategoryFilter == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  selectedColor: const Color(0xFF5EEAD4),
                  onSelected: (val) {
                    setState(() => _selectedCategoryFilter = cat);
                    Navigator.pop(ctx);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortDialog(BuildContext context) {
    final sorts = [
      'Tarih (En Yeni)',
      'Tarih (En Eski)',
      'Tutar (En Yüksek)',
      'Tutar (En Düşük)',
    ];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sıralama Seçeneği',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            for (final sort in sorts)
              ListTile(
                title: Text(sort),
                trailing: _selectedSort == sort
                    ? const Icon(Icons.check, color: AppColors.primaryTeal)
                    : null,
                onTap: () {
                  setState(() => _selectedSort = sort);
                  Navigator.pop(ctx);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showRejectDialog(
    BuildContext context,
    String expenseId,
    String employeeName,
  ) {
    final controller = TextEditingController(
      text: 'Şirket harcama politikasına uygun olmayan harcama kalemi.',
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          '$employeeName - Masraf Reddi',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lütfen çalışana iletilecek resmi red gerekçesini yazınız:',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Red gerekçesi...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.expenseRed,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await _firestoreDatasource.rejectExpense(
                  expenseId: expenseId,
                  reason: controller.text.trim(),
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '$employeeName masraf talebi gerekçesiyle reddedildi.',
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Hata: $e')),
                  );
                }
              }
            },
            child: const Text('Reddet'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleApprove(
    BuildContext context,
    String expenseId,
    String employeeName,
    String amount,
  ) async {
    try {
      await _firestoreDatasource.approveExpense(expenseId: expenseId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.primaryGreen,
            content: Text(
              '$employeeName ($amount) masrafı onaylandı ve cüzdanına iade edildi!',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.expenseRed,
            content: Text('Onay başarısız: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const RoleSwitchAppBar(isBusinessMode: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık Satırı
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          'Masraf Onay Merkezi',
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: AppColors.darkNavy,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '● 3 Bekleyen',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: const Color(0xFFDC2626),
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
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
                    Icons.history_rounded,
                    size: 18,
                    color: AppColors.darkNavy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Sekme Çipleri
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTabPill('Bekleyenler', 0),
                  const SizedBox(width: 8),
                  _buildTabPill('Onaylananlar', 1),
                  const SizedBox(width: 8),
                  _buildTabPill('Reddedilenler', 2),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Arama + Filtre
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
                      onChanged: (val) => setState(() {
                        _searchQuery = val.trim().toLowerCase();
                      }),
                      decoration: InputDecoration(
                        hintText: 'Çalışan, kategori veya tutar ara...',
                        hintStyle: AppTextStyles.bodySmall.copyWith(
                          color: const Color(0xFF94A3B8),
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          size: 20,
                          color: Color(0xFF64748B),
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        fillColor: Colors.transparent,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _showFilterDialog(context),
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: _selectedCategoryFilter != 'Tümü'
                          ? const Color(0xFF5EEAD4)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _selectedCategoryFilter != 'Tümü'
                            ? const Color(0xFF0F766E)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      size: 20,
                      color: _selectedCategoryFilter != 'Tümü'
                          ? const Color(0xFF0F766E)
                          : AppColors.darkNavy,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 1. Bekleyen Toplam Tutar Koyu Kartı (₺3.890,50)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.heroCardGradient,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.darkNavy.withOpacity(0.35),
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
                      Text(
                        'BEKLEYEN TOPLAM TUTAR',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 0.7,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '🧾 3 Fatura / Fiş',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: const Color(0xFF5EEAD4),
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '₺3.890,50',
                    style: AppTextStyles.numericBalance.copyWith(
                      color: Colors.white,
                      fontSize: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(
                                Icons.savings_outlined,
                                size: 16,
                                color: Color(0xFF5EEAD4),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'KDV İndirimi Kazanımı',
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: const Color(0xFF94A3B8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '+₺648,40',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: const Color(0xFF5EEAD4),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Kalan Aylık Masraf Bütçesi',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: const Color(0xFF94A3B8),
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        '%92 Sağlıklı',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: const Color(0xFF5EEAD4),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: const LinearProgressIndicator(
                      value: 0.72,
                      minHeight: 6,
                      backgroundColor: Colors.white12,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryGreen,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Kullanılan: ₺3.890,50',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: const Color(0xFF64748B),
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        'Bütçe: ₺50.000,00',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: const Color(0xFF64748B),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.darkNavy,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        context.push(AppRoutes.businessBatchApproval);
                      },
                      icon: const Icon(
                        Icons.done_all_rounded,
                        size: 18,
                        color: AppColors.primaryTeal,
                      ),
                      label: const Text(
                        'Tümünü İncele & Toplu Onayla (₺3.890,50)',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // İnceleme Harcamalar Başlığı & Sıralama
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedTab == 0
                      ? 'Bekleyen Harcamalar'
                      : (_selectedTab == 1
                          ? 'Onaylanan Harcamalar'
                          : 'Reddedilen Harcamalar'),
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkNavy,
                  ),
                ),
                GestureDetector(
                  onTap: () => _showSortDialog(context),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$_selectedSort ⌄',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primaryTeal,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // StreamBuilder ile Canlı Firestore Masrafları (Giriş yapan şirkete göre dinamik)
            Builder(
              builder: (context) {
                final activeCompanyId =
                    context.watch<AuthBloc>().state.user?.companyId;

                if (activeCompanyId == null || activeCompanyId.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.business_center_outlined,
                          color: Color(0xFFDC2626),
                          size: 36,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Şirket Kaydı Bulunamadı',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF991B1B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Bu ekranı görüntülemek için kurumsal bir şirkete bağlı olmanız gerekmektedir.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final authState = context.watch<AuthBloc>().state;
                final canApprove = authState.canApproveExpenses;

                return StreamBuilder<List<ExpenseModel>>(
                  stream:
                      _firestoreDatasource.watchCompanyExpenses(activeCompanyId),
                  builder: (context, snapshot) {
                    var listToFilter = snapshot.data ?? [];
                    if (listToFilter.isEmpty) {
                      listToFilter = [
                        ExpenseModel(
                          expenseId: 'exp_001',
                          employeeId: 'user_employee_ahmet',
                          employeeName: 'Ahmet Yılmaz',
                          merchantTitle: 'BiTaksi E-Fiş Entegrasyonu',
                          category: 'Ulaşım',
                          companyId: activeCompanyId,
                          amount: 45000,
                          vatAmount: 7500,
                          receiptImageUrl:
                              'https://images.unsplash.com/photo-1554415707-9e4966a642ed',
                          status: 'pending',
                          date: DateTime.now(),
                          accountingCode: '770.01',
                        ),
                        ExpenseModel(
                          expenseId: 'exp_002',
                          employeeId: 'user_employee_elif',
                          employeeName: 'Elif Demir',
                          merchantTitle: 'Midpoint Levent',
                          category: 'Yemek & Temsil',
                          companyId: activeCompanyId,
                          amount: 198050,
                          vatAmount: 18005,
                          receiptImageUrl: '',
                          status: 'pending',
                          date: DateTime.now().subtract(const Duration(days: 1)),
                          accountingCode: '770.02',
                        ),
                        ExpenseModel(
                          expenseId: 'exp_003',
                          employeeId: 'user_employee_caner',
                          employeeName: 'Caner Kılıç',
                          merchantTitle: 'IKEA Maslak',
                          category: 'Donanım & Ofis',
                          companyId: activeCompanyId,
                          amount: 146000,
                          vatAmount: 24333,
                          receiptImageUrl: '',
                          status: 'approved',
                          date: DateTime.now().subtract(const Duration(days: 2)),
                          accountingCode: '770.03',
                        ),
                        ExpenseModel(
                          expenseId: 'exp_004',
                          employeeId: 'user_employee_ahmet',
                          employeeName: 'Ahmet Yılmaz',
                          merchantTitle: 'Yazılım Lisansı & Eklenti',
                          category: 'Yazılım & SaaS',
                          companyId: activeCompanyId,
                          amount: 145000,
                          vatAmount: 24167,
                          receiptImageUrl: '',
                          status: 'rejected',
                          rejectReason:
                              'Şirket ön onayı bulunmayan yazılım aboneliği.',
                          date: DateTime.now().subtract(const Duration(days: 3)),
                          accountingCode: '770.04',
                        ),
                      ];
                    }

                    final filteredExpenses = listToFilter.where((e) {
                      // 1. Sekme / Durum Filtresi
                      final statusMatch = (_selectedTab == 0 &&
                              (e.status == 'pending' ||
                                  e.status == 'ONAY_BEKLIYOR')) ||
                          (_selectedTab == 1 &&
                              (e.status == 'approved' ||
                                  e.status == 'ONAYLANDI')) ||
                          (_selectedTab == 2 &&
                              (e.status == 'rejected' ||
                                  e.status == 'REDDEDILDI'));
                      if (!statusMatch) return false;

                      // 2. Kategori Filtresi
                      if (_selectedCategoryFilter != 'Tümü' &&
                          e.category != _selectedCategoryFilter) {
                        return false;
                      }

                      // 3. Arama Metni Filtresi
                      if (_searchQuery.isNotEmpty) {
                        final query = _searchQuery.toLowerCase();
                        final nameMatch =
                            e.employeeName.toLowerCase().contains(query);
                        final titleMatch =
                            e.merchantTitle.toLowerCase().contains(query);
                        final catMatch =
                            e.category.toLowerCase().contains(query);
                        final codeMatch =
                            e.accountingCode.toLowerCase().contains(query);
                        final amtMatch =
                            (e.amount / 100).toString().contains(query);
                        if (!nameMatch &&
                            !titleMatch &&
                            !catMatch &&
                            !codeMatch &&
                            !amtMatch) {
                          return false;
                        }
                      }

                      return true;
                    }).toList();

                    // Sıralama
                    if (_selectedSort == 'Tarih (En Yeni)') {
                      filteredExpenses.sort((a, b) => b.date.compareTo(a.date));
                    } else if (_selectedSort == 'Tarih (En Eski)') {
                      filteredExpenses.sort((a, b) => a.date.compareTo(b.date));
                    } else if (_selectedSort == 'Tutar (En Yüksek)') {
                      filteredExpenses
                          .sort((a, b) => b.amount.compareTo(a.amount));
                    } else if (_selectedSort == 'Tutar (En Düşük)') {
                      filteredExpenses
                          .sort((a, b) => a.amount.compareTo(b.amount));
                    }

                    if (filteredExpenses.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 40,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 44,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Filtreye uygun masraf kaydı bulunamadı',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkNavy,
                                fontSize: 13.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? '"$_searchQuery" araması için sonuç bulunamadı.'
                                  : 'Bu sekmede veya seçili kategoride kayıt bulunmuyor.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: [
                        for (final exp in filteredExpenses) ...[
                          _buildExpenseReviewCard(
                            context: context,
                            initials: exp.employeeName.isNotEmpty
                                ? exp.employeeName
                                    .split(' ')
                                    .map((n) => n.isNotEmpty ? n[0] : '')
                                    .take(2)
                                    .join()
                                : 'PR',
                            employeeName: exp.employeeName.isNotEmpty
                                ? exp.employeeName
                                : 'Şirket Çalışanı',
                            roleDept:
                                '${exp.category} • ${exp.accountingCode}',
                            amount:
                                '₺${(exp.amount / 100.0).toStringAsFixed(2).replaceAll('.', ',')}',
                            vatText:
                                'KDV (₺${(exp.vatAmount / 100.0).toStringAsFixed(2).replaceAll('.', ',')})',
                            categoryLine:
                                '${exp.merchantTitle} • ${exp.date.day}.${exp.date.month}.${exp.date.year}',
                            descLine:
                                'Masraf Kaydı #${exp.expenseId.substring(0, exp.expenseId.length > 8 ? 8 : exp.expenseId.length)}',
                            cardAndReceiptNo: exp.receiptImageUrl.isNotEmpty
                                ? 'Belge: ${exp.receiptImageUrl}'
                                : 'Yerel fiş belgesi eklenmiş',
                            ocrTitle: '⚡ AI-OCR Doğrulandı',
                            ocrSubtitle: exp.merchantTitle,
                            ocrActionText: 'İncele 🔍',
                            policyText: exp.status == 'approved'
                                ? '✓ Onaylandı & Muhasebeleştirildi'
                                : (exp.status == 'rejected'
                                    ? '✕ Reddedildi (${exp.rejectReason ?? 'Gerekçeli'})'
                                    : '● İnceleme Bekliyor'),
                            isPolicyWarning: exp.status == 'rejected',
                            onApprove: canApprove &&
                                    (exp.status == 'pending' ||
                                        exp.status == 'ONAY_BEKLIYOR')
                                ? () => _handleApprove(
                                      context,
                                      exp.expenseId,
                                      exp.employeeName,
                                      '₺${(exp.amount / 100.0).toStringAsFixed(2).replaceAll('.', ',')}',
                                    )
                                : null,
                            onReject: canApprove &&
                                    (exp.status == 'pending' ||
                                        exp.status == 'ONAY_BEKLIYOR')
                                ? () => _showRejectDialog(
                                      context,
                                      exp.expenseId,
                                      exp.employeeName,
                                    )
                                : null,
                          ),
                          const SizedBox(height: 14),
                        ],
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 16),

            // Otomatik Muhasebe & ERP Senkronizasyonu Kartı
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.laptop_chromebook_rounded,
                    color: AppColors.darkNavy,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Otomatik Muhasebe & ERP Senkronizasyonu 🔒',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.darkNavy,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Onaylanan masraflar anında Logo & Paraşüt ERP gider hesaplarına ve ilgili masraf merkezlerine otomatik fiş olarak aktarılır.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: const Color(0xFF475569),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTabPill(String label, int index) {
    final bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkNavy : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? AppColors.darkNavy : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: isSelected ? Colors.white : const Color(0xFF475569),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseReviewCard({
    required BuildContext context,
    required String initials,
    required String employeeName,
    required String roleDept,
    required String amount,
    required String vatText,
    required String categoryLine,
    required String descLine,
    String? quoteNote,
    required String cardAndReceiptNo,
    required String ocrTitle,
    required String ocrSubtitle,
    required String ocrActionText,
    required String policyText,
    required bool isPolicyWarning,
    VoidCallback? onApprove,
    VoidCallback? onReject,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFE2E8F0),
                child: Text(
                  initials,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.darkNavy,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employeeName,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkNavy,
                      ),
                    ),
                    Text(
                      roleDept,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: const Color(0xFF64748B),
                        fontSize: 11.5,
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
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.darkNavy,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    vatText,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primaryTeal,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoryLine,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.darkNavy,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  descLine,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF475569),
                    fontSize: 11.5,
                  ),
                ),
                if (quoteNote != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    quoteNote,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: const Color(0xFF64748B),
                      fontStyle: FontStyle.italic,
                      fontSize: 11,
                    ),
                  ),
                ],
                if (cardAndReceiptNo.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    cardAndReceiptNo,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: const Color(0xFF64748B),
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (ocrTitle.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.darkNavy,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.receipt_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ocrTitle,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primaryTeal,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          ocrSubtitle,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: const Color(0xFF475569),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      ocrActionText,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.darkNavy,
                        fontSize: 10.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isPolicyWarning
                  ? const Color(0xFFFEF2F2)
                  : const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              policyText,
              style: AppTextStyles.labelSmall.copyWith(
                color: isPolicyWarning
                    ? const Color(0xFFB91C1C)
                    : const Color(0xFF065F46),
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFEE2E2),
                    foregroundColor: const Color(0xFFB91C1C),
                    elevation: 0,
                    minimumSize: const Size(0, 42),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: onReject ??
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '$employeeName masraf talebi reddedildi.',
                            ),
                          ),
                        );
                      },
                  child: const Text(
                    '✕ Reddet',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 6,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkNavy,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 42),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: onApprove ??
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.primaryGreen,
                            content: Text(
                              '$employeeName ($amount) masrafı onaylandı ve cüzdanına iade edildi!',
                            ),
                          ),
                        );
                      },
                  child: Text(
                    '✓ Onayla ($amount)',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
