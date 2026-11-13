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
      0; // 0: Bekleyenler 3, 1: Onaylananlar (18), 2: Reddedilenler
  final FirebaseFirestoreDatasource _firestoreDatasource =
      FirebaseFirestoreDatasource();

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
                  _buildTabPill('Bekleyenler  3', 0),
                  const SizedBox(width: 8),
                  _buildTabPill('Onaylananlar (18)', 1),
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
                    size: 20,
                    color: AppColors.darkNavy,
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

            // İnceleme Bekleyen Harcamalar Başlığı
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'İnceleme Bekleyen Harcamalar (3)',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkNavy,
                  ),
                ),
                Text(
                  'Sırala: Tarih ⌄',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primaryTeal,
                    fontWeight: FontWeight.w700,
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

                return StreamBuilder<List<ExpenseModel>>(
                  stream: _firestoreDatasource.watchCompanyExpenses(activeCompanyId),
                  builder: (context, snapshot) {
                final allExpenses = snapshot.data ?? [];
                final filteredExpenses = allExpenses.where((e) {
                  if (_selectedTab == 0) {
                    return e.status == 'pending' || e.status == 'ONAY_BEKLIYOR';
                  } else if (_selectedTab == 1) {
                    return e.status == 'approved' || e.status == 'ONAYLANDI';
                  } else {
                    return e.status == 'rejected' || e.status == 'REDDEDILDI';
                  }
                }).toList();

                if (filteredExpenses.isNotEmpty) {
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
                              ? '✓ Yönetici Tarafından Onaylandı'
                              : (exp.status == 'rejected'
                                  ? '✕ Reddedildi (${exp.rejectReason ?? 'Gerekçeli'})'
                                  : '● İnceleme Bekliyor'),
                          isPolicyWarning: exp.status == 'rejected',
                          onApprove: exp.status == 'pending' ||
                                  exp.status == 'ONAY_BEKLIYOR'
                              ? () => _handleApprove(
                                    context,
                                    exp.expenseId,
                                    exp.employeeName,
                                    '₺${(exp.amount / 100.0).toStringAsFixed(2).replaceAll('.', ',')}',
                                  )
                              : null,
                          onReject: exp.status == 'pending' ||
                                  exp.status == 'ONAY_BEKLIYOR'
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
                }

                // Canlı Firestore kaydı henüz yoksa veya boşsa önceden tanımlı demo kartları göster
                return Column(
                  children: [
                    // 1. Kart: Ahmet Yılmaz (BiTaksi ₺450,00)
                    _buildExpenseReviewCard(
                      context: context,
                      initials: 'AY',
                      employeeName: 'Ahmet Yılmaz',
                      roleDept: 'Frontend Lead • Operasyon',
                      amount: '₺450,00',
                      vatText: 'KDV %20 (₺75,00)',
                      categoryLine:
                          '🚖 Taksi / Şehir İçi Ulaşım • Bugün, 08:40',
                      descLine:
                          'Müşteri Toplantısı (Akbank Genel Müdürlük / Levent)',
                      cardAndReceiptNo:
                          '💳 Nova Business Kart •••• 4120   Fiş No: BT-889104',
                      ocrTitle: '⚡ AI-OCR %98 Doğrulandı',
                      ocrSubtitle: 'BiTaksi E-Fiş Entegrasyonu',
                      ocrActionText: 'Fişi Gör ↗',
                      policyText:
                          '✓ Harcama Politikasına Uygun (Günlük Ulaşım Limiti Altında)',
                      isPolicyWarning: false,
                      onApprove: () => _handleApprove(
                        context,
                        'exp_001',
                        'Ahmet Yılmaz',
                        '₺450,00',
                      ),
                      onReject: () => _showRejectDialog(
                        context,
                        'exp_001',
                        'Ahmet Yılmaz',
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 2. Kart: Elif Demir (Midpoint ₺1.980,50)
                    _buildExpenseReviewCard(
                      context: context,
                      initials: 'ED',
                      employeeName: 'Elif Demir',
                      roleDept: 'Ürün Tasarımcısı • Tasarım',
                      amount: '₺1.980,50',
                      vatText: 'KDV %10 (₺180,05)',
                      categoryLine:
                          '🍴 Müşteri Akşam Yemeği / Temsil • Dün, 19:15',
                      descLine: '🏪 Midpoint Levent Şubesi • Fiş No: 004819',
                      quoteNote:
                          '"Fintech mobil uygulama lansman toplantısı müşteri ağırlama masrafı."',
                      cardAndReceiptNo: 'Kart: Nova Business •••• 8831',
                      ocrTitle: '🧾 Fiş Görseli Eklendi (PNG)',
                      ocrSubtitle: 'Kart: Nova Business •••• 8831',
                      ocrActionText: 'İncele 🔍',
                      policyText:
                          '⚠️ Departman Temsil Limiti (₺2.000) Sınırında (%99 Doluluk)',
                      isPolicyWarning: true,
                      onApprove: () => _handleApprove(
                        context,
                        'exp_002',
                        'Elif Demir',
                        '₺1.980,50',
                      ),
                      onReject: () => _showRejectDialog(
                        context,
                        'exp_002',
                        'Elif Demir',
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 3. Kart: Caner Kılıç (IKEA ₺1.460,00)
                    _buildExpenseReviewCard(
                      context: context,
                      initials: 'CK',
                      employeeName: 'Caner Kılıç',
                      roleDept: 'DevOps Uzmanı • Teknoloji',
                      amount: '₺1.460,00',
                      vatText: 'KDV %20 (₺243,33)',
                      categoryLine:
                          '💻 Ofis & Donanım / Ergonomi • 09 Kas, 11:20',
                      descLine: '🏪 IKEA Maslak • E-Arşiv Fatura (#E-2026-9921)',
                      quoteNote:
                          '"Çift monitör kolu ve kablo omurgası (Ergonomik çalışma alanı düzeni)."',
                      cardAndReceiptNo: '',
                      ocrTitle: '',
                      ocrSubtitle: '',
                      ocrActionText: '',
                      policyText:
                          '✓ Ön Onaylı Talep (#ON-2026-88)   |   CTO İmzalı',
                      isPolicyWarning: false,
                      onApprove: () => _handleApprove(
                        context,
                        'exp_003',
                        'Caner Kılıç',
                        '₺1.460,00',
                      ),
                      onReject: () => _showRejectDialog(
                        context,
                        'exp_003',
                        'Caner Kılıç',
                      ),
                    ),
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
