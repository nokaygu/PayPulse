import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/financial_amount.dart';
import '../../../data/repositories/expense_repository.dart';
import '../../../domain/entities/expense_entity.dart';
import '../../../domain/repositories/i_expense_repository.dart';
import '../auth/bloc/auth_bloc.dart';
import '../../widgets/role_switch_app_bar.dart';

/// Görsel 7: Fatura & Fiş Tarama (AI-OCR) Ekranı
class OcrCameraScannerScreen extends StatefulWidget {
  const OcrCameraScannerScreen({super.key});

  @override
  State<OcrCameraScannerScreen> createState() => _OcrCameraScannerScreenState();
}

class _OcrCameraScannerScreenState extends State<OcrCameraScannerScreen> {
  final IExpenseRepository _expenseRepository = ExpenseRepository();
  int _selectedDocMode =
      1; // 0: Fatura (A4), 1: Gider Fişi, 2: E-Arşiv, 3: Sözleşme

  Future<void> _submitExpense({
    required BuildContext dialogContext,
    required String title,
    required String category,
    required double amountLira,
    required double vatLira,
    String? receiptImageUrl,
    required String successSuffix,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(dialogContext);
    final authState = context.read<AuthBloc>().state;
    final employeeId = authState.user?.uid ?? 'user_employee_ahmet';
    final employeeName = authState.user?.name ?? 'Ahmet Yılmaz';
    final companyId = authState.user?.companyId ?? 'comp_techsolutions_01';

    final expense = ExpenseEntity(
      expenseId: 'exp_${DateTime.now().millisecondsSinceEpoch}',
      employeeId: employeeId,
      employeeName: employeeName,
      merchantTitle: title,
      category: category,
      companyId: companyId,
      amount: (amountLira * 100).round(),
      vatAmount: (vatLira * 100).round(),
      receiptImageUrl:
          receiptImageUrl ?? 'https://images.unsplash.com/photo-1554415707-9e4966a642ed',
      status: 'pending',
      date: DateTime.now(),
      accountingCode: '770.01',
    );

    try {
      await _expenseRepository.createExpense(expense);
      if (!mounted) return;
      nav.pop();
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primaryTeal,
          content: Text(
            '$title (${FinancialAmount.formatLira(amountLira)}) $successSuffix',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: AppColors.expenseRed,
          content: Text('Masraf gönderilemedi: $e'),
        ),
      );
    }
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: const Color(0xFF64748B),
              fontSize: 11.5,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.darkNavy,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }

  void _showReceiptInspectAndSaveSheet({
    required String title,
    required double amount,
    required double vat,
    required String category,
    required String dateStr,
    required double confidence,
    String? receiptImage,
  }) {
    final noteController = TextEditingController(text: '$title fiş harcaması');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
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
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1FAE5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.document_scanner_rounded,
                        color: Color(0xFF065F46),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI-OCR Fiş Doğrulama',
                          style: AppTextStyles.labelLarge.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkNavy,
                          ),
                        ),
                        Text(
                          'Yapay zeka verileri çıkardı',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: const Color(0xFF64748B),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5EEAD4).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '✓ %${(confidence * 100).toInt()} Güven',
                    style: const TextStyle(
                      color: Color(0xFF0F766E),
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Tedarikçi / İşyeri:', title, isBold: true),
                  _buildDetailRow('Tarih & Saat:', dateStr),
                  _buildDetailRow('Kategori:', category),
                  _buildDetailRow('KDV Tutarı:', '${FinancialAmount.formatLira(vat)} (%20)'),
                  const Divider(height: 16, color: Color(0xFFE2E8F0)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TOPLAM TUTAR:',
                        style: AppTextStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkNavy,
                        ),
                      ),
                      Text(
                        FinancialAmount.formatLira(amount),
                        style: AppTextStyles.headlineSmall.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryTeal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Açıklama / Not',
              style: AppTextStyles.labelSmall.copyWith(
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF64748B),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Vazgeç', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryTeal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _submitExpense(
                      dialogContext: ctx,
                      title: title,
                      category: category,
                      amountLira: amount,
                      vatLira: vat,
                      receiptImageUrl: receiptImage,
                      successSuffix: 'masrafı başarıyla onaya iletildi!',
                    ),
                    icon: const Icon(Icons.check_circle_rounded, size: 18),
                    label: const Text(
                      'Masrafı Onaya Gönder',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showGalleryPickerSheet(BuildContext context) {
    final sampleReceipts = [
      {
        'title': 'BiTaksi Fişi (Levent-Havalimanı)',
        'amount': 650.00,
        'vat': 108.33,
        'category': 'Ulaşım / Taksi',
        'dateStr': '12.11.2026 • 09:15',
        'icon': Icons.local_taxi_rounded,
        'iconColor': const Color(0xFFF59E0B),
      },
      {
        'title': 'Nusr-Et / Midpoint İş Yemeği',
        'amount': 2850.00,
        'vat': 285.00,
        'category': 'Yemek & Temsil',
        'dateStr': '10.11.2026 • 20:30',
        'icon': Icons.restaurant_rounded,
        'iconColor': const Color(0xFFEF4444),
      },
      {
        'title': 'D&R Ofis Kırtasiye & Sarf',
        'amount': 480.00,
        'vat': 80.00,
        'category': 'Ofis & Sarf',
        'dateStr': '09.11.2026 • 11:20',
        'icon': Icons.menu_book_rounded,
        'iconColor': const Color(0xFF3B82F6),
      },
      {
        'title': 'Petrol Ofisi Mazot Fişi',
        'amount': 1420.50,
        'vat': 236.75,
        'category': 'Akaryakıt & Ulaşım',
        'dateStr': '11.11.2026 • 14:32',
        'icon': Icons.local_gas_station_rounded,
        'iconColor': const Color(0xFF10B981),
      },
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.photo_library_rounded,
                  color: AppColors.darkNavy,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(
                  'Galeriden Fiş / Fatura Seçin',
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkNavy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Cihazınızdaki fotoğraflardan bir fiş seçin, AI otomatik ayrıştırsın.',
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFF64748B),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 16),
            ...sampleReceipts.map((rec) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(ctx);
                      _showReceiptInspectAndSaveSheet(
                        title: rec['title'] as String,
                        amount: rec['amount'] as double,
                        vat: rec['vat'] as double,
                        category: rec['category'] as String,
                        dateStr: rec['dateStr'] as String,
                        confidence: 0.98,
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              rec['icon'] as IconData,
                              color: rec['iconColor'] as Color,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  rec['title'] as String,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.darkNavy,
                                  ),
                                ),
                                Text(
                                  '${rec['category']} • ${rec['dateStr']}',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: const Color(0xFF64748B),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            FinancialAmount.formatLira(rec['amount'] as double),
                            style: AppTextStyles.labelMedium.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkNavy,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  void _showManualExpenseEntrySheet(BuildContext context) {
    final titleController = TextEditingController(text: 'Starbucks Coffee');
    final amountController = TextEditingController(text: '245.00');
    final descController = TextEditingController(text: 'Müşteri toplantısı kahve harcaması');
    String selectedCat = 'Yemek & Temsil';
    int selectedVatRate = 20;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
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
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.edit_note_rounded,
                      color: Color(0xFF2563EB),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Manuel Masraf Girişi',
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkNavy,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Tedarikçi / İşyeri Adı',
                style: AppTextStyles.labelSmall.copyWith(
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: 'Örn: Petrol Ofisi, Migros',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Toplam Tutar (₺)',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            hintText: '0,00',
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'KDV',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<int>(
                          initialValue: selectedVatRate,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          ),
                          items: const [
                            DropdownMenuItem(value: 1, child: Text('%1')),
                            DropdownMenuItem(value: 10, child: Text('%10')),
                            DropdownMenuItem(value: 20, child: Text('%20')),
                          ],
                          onChanged: (val) {
                            if (val != null) setModalState(() => selectedVatRate = val);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Kategori',
                style: AppTextStyles.labelSmall.copyWith(
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: selectedCat,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                items: const [
                  DropdownMenuItem(value: 'Yemek & Temsil', child: Text('Yemek & Temsil')),
                  DropdownMenuItem(value: 'Ulaşım / Taksi', child: Text('Ulaşım / Taksi')),
                  DropdownMenuItem(value: 'Akaryakıt & Ulaşım', child: Text('Akaryakıt & Ulaşım')),
                  DropdownMenuItem(value: 'Ofis & Sarf', child: Text('Ofis & Sarf')),
                  DropdownMenuItem(value: 'Konaklama & Seyahat', child: Text('Konaklama & Seyahat')),
                ],
                onChanged: (val) {
                  if (val != null) setModalState(() => selectedCat = val);
                },
              ),
              const SizedBox(height: 12),
              Text(
                'Açıklama',
                style: AppTextStyles.labelSmall.copyWith(
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: descController,
                decoration: InputDecoration(
                  hintText: 'Harcama gerekçesi...',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkNavy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final title = titleController.text.trim();
                    final parsed = double.tryParse(amountController.text.replaceAll(',', '.'));
                    if (title.isEmpty || parsed == null || parsed <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Lütfen geçerli bir işyeri ve tutar girin.'),
                          backgroundColor: AppColors.expenseRed,
                        ),
                      );
                      return;
                    }

                    final vat = parsed * (selectedVatRate / 100.0);
                    await _submitExpense(
                      dialogContext: ctx,
                      title: title,
                      category: selectedCat,
                      amountLira: parsed,
                      vatLira: vat,
                      successSuffix: 'masrafı kaydedildi ve onaya iletildi!',
                    );
                  },
                  icon: const Icon(Icons.check_circle_rounded, size: 18),
                  label: const Text('Masrafı Kaydet & Onaya Gönder', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
              children: [
                GestureDetector(
                  onTap: () {
                    if (context.canPop()) context.pop();
                  },
                  child: Container(
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
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Fatura & Fiş Tara',
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkNavy,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF5EEAD4),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'AI-OCR',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.darkNavy,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Yapay Zeka Destekli Belge Okuyucu',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: const Color(0xFF64748B),
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0).withOpacity(0.6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.flash_on_outlined,
                    size: 18,
                    color: AppColors.darkNavy,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryTeal,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Oto Yakala',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: const Color(0xFF065F46),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Sekmeler: Fatura (A4) | Gider Fişi | E-Arşiv | Sözleşme
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0).withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildDocTab('Fatura (A4)', 0),
                  _buildDocTab('🧾 Gider Fişi', 1),
                  _buildDocTab('E-Arşiv', 2),
                  _buildDocTab('Sözleşme', 3),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 1. Kamera Vizörü ve AI-OCR Algılama Kartı
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0B1924),
                    Color(0xFF12353C),
                    Color(0xFF071318),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.darkNavy.withOpacity(0.4),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Üst Vizör Durum Satırı
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.45),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: Color(0xFF5EEAD4),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'OCR Motoru v4.2 Hazır',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: Colors.white,
                                fontSize: 10,
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
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '30 FPS • HD',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Fiş Simülasyonu ve AI Bounding Box'ları
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF64748B).withOpacity(0.25),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF5EEAD4).withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tedarikçi Kutusu
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.darkNavy.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'PETROL OFİSİ A.Ş.',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF065F46),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '✓ %99 Tedarikçi',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: const Color(0xFF5EEAD4),
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Center(
                          child: Text(
                            '[SHELL / PETROL OFİSİ]\nTAŞITMATİK İSTASYONU - İSTANBUL',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Tarih Algılama Kutusu
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F766E).withOpacity(0.75),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 12,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '11.11.2026 • 14:32  ✓ Tarih',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontSize: 10.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // KDV Algılama Kutusu
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E3A8A).withOpacity(0.85),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '%20 KDV: ₺236,75   Vergi',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: Colors.white,
                                fontSize: 10.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Algılanan Toplam Tutar Cam Kutusu
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F766E).withOpacity(0.55),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFF5EEAD4).withOpacity(0.6),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ALGILANAN TOPLAM TUTAR',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: const Color(0xFF5EEAD4),
                                      fontSize: 9.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '₺1.420,50',
                                    style: AppTextStyles.numericBalance
                                        .copyWith(
                                          color: Colors.white,
                                          fontSize: 26,
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
                                  color: const Color(0xFF5EEAD4),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '✓ Eşleşti',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.darkNavy,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Alt Hizalama Durum Hapı
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryTeal,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '⚡ Fiş başarıyla hizalandı. Sabit tutun...',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.darkNavy,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. Deklanşör ve Kamera Butonları
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () => _showGalleryPickerSheet(context),
                  child: Column(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0).withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.photo_library_outlined,
                          color: AppColors.darkNavy,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Galeriden Seç',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: const Color(0xFF475569),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _showReceiptInspectAndSaveSheet(
                    title: 'Petrol Ofisi A.Ş.',
                    amount: 1420.50,
                    vat: 236.75,
                    category: 'Akaryakıt & Ulaşım',
                    dateStr: '11.11.2026 • 14:32',
                    confidence: 0.99,
                  ),
                  child: Container(
                    width: 74,
                    height: 74,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF99F6E4),
                        width: 4,
                      ),
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF0D9488)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.document_scanner_outlined,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _showManualExpenseEntrySheet(context),
                  child: Column(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0).withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.edit_note_rounded,
                          color: AppColors.darkNavy,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Manuel Giriş',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: const Color(0xFF475569),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Çoklu Tarama & Kenar Düzeltme Rozetleri
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0).withOpacity(0.7),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '◇ Çoklu Tarama (Seri Mod)',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.darkNavy,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1FAE5),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '[ ] Kenar Düzeltme: Açık',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: const Color(0xFF065F46),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Akıllı Fiş İpucu Kartı
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFDBEAFE)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lightbulb_outline_rounded,
                    color: AppColors.primaryTeal,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Akıllı Fiş İpucu',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.darkNavy,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'İyi aydınlatılmış ortamda fişin 4 köşesini vizörde tutun. Yakıt, yemek ve konaklama harcamaları otomatik muhasebeleştirilir.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: const Color(0xFF475569),
                            fontSize: 11.5,
                            height: 1.35,
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

  Widget _buildDocTab(String label, int index) {
    final bool isSelected = _selectedDocMode == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedDocMode = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: isSelected ? AppColors.darkNavy : const Color(0xFF64748B),
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              fontSize: 10.5,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
