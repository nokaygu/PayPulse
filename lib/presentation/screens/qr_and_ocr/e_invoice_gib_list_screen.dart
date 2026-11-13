import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../widgets/role_switch_app_bar.dart';

class _InvoiceItemData {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String vkn;
  final String gibNo;
  final String docType;
  final double amount;
  final double vatAmount;
  final String status;
  final String tag1;
  final Color tag1Bg;
  final Color tag1Fg;
  final String? tag2;
  final Color? tag2Bg;
  final Color? tag2Fg;
  final String dateText;
  final String? btn1Label;
  final String? btn2Label;
  final String? rightLabel;
  final bool hasLeftAmberAccent;

  const _InvoiceItemData({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.vkn,
    required this.gibNo,
    required this.docType,
    required this.amount,
    required this.vatAmount,
    required this.status,
    required this.tag1,
    required this.tag1Bg,
    required this.tag1Fg,
    this.tag2,
    this.tag2Bg,
    this.tag2Fg,
    this.dateText = 'Bugün 14:32',
    this.btn1Label,
    this.btn2Label,
    this.rightLabel,
    this.hasLeftAmberAccent = false,
  });
}

/// Görsel 10 (Görsel 7): E-Fatura & E-Arşiv (GİB Canlı Entegrasyonu) Ekranı
class EInvoiceGibListScreen extends StatefulWidget {
  const EInvoiceGibListScreen({super.key});

  @override
  State<EInvoiceGibListScreen> createState() => _EInvoiceGibListScreenState();
}

class _EInvoiceGibListScreenState extends State<EInvoiceGibListScreen> {
  bool _isIncomingTab = true;
  String _selectedStatusFilter = 'Tümü';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedDocType = 'Tümü';

  final List<_InvoiceItemData> _incomingInvoices = [
    const _InvoiceItemData(
      icon: Icons.cloud_outlined,
      iconBg: Color(0xFFFFF7ED),
      iconColor: Color(0xFFD97706),
      title: 'Amazon Web Services',
      vkn: '1029384756',
      gibNo: 'GIB2026000004812',
      docType: 'E-Fatura',
      amount: 34820.00,
      vatAmount: 5803.33,
      status: 'approved',
      tag1: "✓ Onaylandı & ERP'de",
      tag1Bg: Color(0xFFD1FAE5),
      tag1Fg: Color(0xFF065F46),
      tag2: 'Tevkifat (5/10)',
      tag2Bg: Color(0xFFE0F2FE),
      tag2Fg: Color(0xFF0369A1),
      dateText: '10 Kas 2026',
    ),
    const _InvoiceItemData(
      icon: Icons.devices_rounded,
      iconBg: Color(0xFFF1F5F9),
      iconColor: AppColors.darkNavy,
      title: 'Apple Teknoloji A.Ş.',
      vkn: '0700084920',
      gibNo: 'APL2026000019402',
      docType: 'E-Fatura',
      amount: 78900.00,
      vatAmount: 13150.00,
      status: 'approved',
      tag1: '🗓️ Demirbaş / Varlık',
      tag1Bg: Color(0xFFE0F2FE),
      tag1Fg: Color(0xFF1E40AF),
      tag2: 'KDV İndirimi Sağlandı',
      tag2Bg: Color(0xFFD1FAE5),
      tag2Fg: Color(0xFF065F46),
      dateText: '08 Kas 2026',
      btn1Label: 'PDF İndir',
      btn2Label: '✓ GİB Doğrula',
      rightLabel: 'Detay >',
    ),
    const _InvoiceItemData(
      icon: Icons.gavel_rounded,
      iconBg: Color(0xFFFEF3C7),
      iconColor: Color(0xFFB45309),
      title: 'Aydın Hukuk & Danışmanlık',
      vkn: '2938475019',
      gibNo: 'AYD202600000319',
      docType: 'E-SMM',
      amount: 15000.00,
      vatAmount: 2700.00,
      status: 'pending',
      tag1: '🕒 Ödeme Bekliyor (Vade: 2 Gün)',
      tag1Bg: Color(0xFFFEF3C7),
      tag1Fg: Color(0xFFB45309),
      tag2: 'Stopaj %20',
      tag2Bg: Color(0xFFF1F5F9),
      tag2Fg: Color(0xFF475569),
      dateText: '05 Kas 2026',
      btn1Label: 'Makbuz',
      hasLeftAmberAccent: true,
    ),
    const _InvoiceItemData(
      icon: Icons.ads_click_rounded,
      iconBg: Color(0xFFE0F2FE),
      iconColor: Color(0xFF0284C7),
      title: 'Google Ireland Limited',
      vkn: '4629103857',
      gibNo: 'GOOG-TR-2026-99',
      docType: 'E-Arşiv',
      amount: 26400.00,
      vatAmount: 5280.00,
      status: 'paid',
      tag1: '👁️ İncelendi & Ödendi',
      tag1Bg: Color(0xFFF1F5F9),
      tag1Fg: AppColors.darkNavy,
      tag2: 'KDV-2 Sorumlu Sıfatıyla',
      tag2Bg: Color(0xFFFEF3C7),
      tag2Fg: Color(0xFFB45309),
      dateText: '03 Kas 2026',
    ),
    const _InvoiceItemData(
      icon: Icons.cell_tower_rounded,
      iconBg: Color(0xFFE0F2FE),
      iconColor: Color(0xFF0369A1),
      title: 'Turkcell İletişim Hizmetleri',
      vkn: '8790012481',
      gibNo: 'TRK20260008412',
      docType: 'E-Fatura',
      amount: 8450.00,
      vatAmount: 1408.33,
      status: 'paid',
      tag1: '✓ Ödendi / Kapandı',
      tag1Bg: Color(0xFFD1FAE5),
      tag1Fg: Color(0xFF065F46),
      tag2: 'Haberleşme Vergisi',
      tag2Bg: Color(0xFFF1F5F9),
      tag2Fg: Color(0xFF475569),
      dateText: '01 Kas 2026',
    ),
  ];

  final List<_InvoiceItemData> _outgoingInvoices = [
    const _InvoiceItemData(
      icon: Icons.business_rounded,
      iconBg: Color(0xFFD1FAE5),
      iconColor: Color(0xFF065F46),
      title: 'Mega Kurumsal Yazılım A.Ş.',
      vkn: '6320984112',
      gibNo: 'NVA202600000101',
      docType: 'E-Fatura',
      amount: 120000.00,
      vatAmount: 20000.00,
      status: 'paid',
      tag1: '✓ Tahsil Edildi',
      tag1Bg: Color(0xFFD1FAE5),
      tag1Fg: Color(0xFF065F46),
      tag2: 'Tasarım Hizmet Bedeli',
      tag2Bg: Color(0xFFE0F2FE),
      tag2Fg: Color(0xFF0369A1),
      dateText: '11 Kas 2026',
    ),
    const _InvoiceItemData(
      icon: Icons.account_balance_rounded,
      iconBg: Color(0xFFE0F2FE),
      iconColor: Color(0xFF1E40AF),
      title: 'Akbank Türk A.Ş.',
      vkn: '0150015000',
      gibNo: 'NVA202600000102',
      docType: 'E-Fatura',
      amount: 85000.00,
      vatAmount: 14166.67,
      status: 'pending',
      tag1: '🕒 Tahsilat Bekliyor',
      tag1Bg: Color(0xFFFEF3C7),
      tag1Fg: Color(0xFFB45309),
      tag2: 'Fintech UI Danışmanlığı',
      tag2Bg: Color(0xFFF1F5F9),
      tag2Fg: Color(0xFF475569),
      dateText: '09 Kas 2026',
    ),
    const _InvoiceItemData(
      icon: Icons.shopping_bag_outlined,
      iconBg: Color(0xFFFFF7ED),
      iconColor: Color(0xFFD97706),
      title: 'Trendyol Pazaryeri A.Ş.',
      vkn: '9283746152',
      gibNo: 'NVA202600000103',
      docType: 'E-Arşiv',
      amount: 42500.00,
      vatAmount: 7083.33,
      status: 'paid',
      tag1: '✓ Ödendi / Kapandı',
      tag1Bg: Color(0xFFD1FAE5),
      tag1Fg: Color(0xFF065F46),
      tag2: 'Mobil Deneyim Tasarımı',
      tag2Bg: Color(0xFFD1FAE5),
      tag2Fg: Color(0xFF065F46),
      dateText: '06 Kas 2026',
    ),
    const _InvoiceItemData(
      icon: Icons.local_shipping_outlined,
      iconBg: Color(0xFFFEF3C7),
      iconColor: Color(0xFFB45309),
      title: 'Getir Perakende Lojistik',
      vkn: '5482910384',
      gibNo: 'NVA202600000104',
      docType: 'E-Fatura',
      amount: 28750.00,
      vatAmount: 4791.67,
      status: 'pending',
      tag1: '● Onay Bekliyor',
      tag1Bg: Color(0xFFFEF3C7),
      tag1Fg: Color(0xFFB45309),
      tag2: 'UX Denetim Hizmeti',
      tag2Bg: Color(0xFFE0F2FE),
      tag2Fg: Color(0xFF0369A1),
      dateText: '04 Kas 2026',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showNewInvoiceSheet(BuildContext context) {
    final titleController = TextEditingController();
    final vknController = TextEditingController();
    final amountController = TextEditingController();
    final descController = TextEditingController();
    String docType = 'E-Fatura';
    int vatRate = 20;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Yeni E-Fatura Kes / Oluştur',
                      style: AppTextStyles.headlineSmall.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkNavy,
                        fontSize: 18,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Gelir İdaresi Başkanlığı GİB sistemine entegre resmi e-Fatura oluşturun.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Alıcı Firma / Müşteri Ünvanı *',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: 'Örn: Türk Telekom A.Ş.',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'VKN / TCKN *',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: vknController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: '10 haneli VKN',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Belge Türü',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: docType,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'E-Fatura',
                                child: Text('E-Fatura'),
                              ),
                              DropdownMenuItem(
                                value: 'E-Arşiv',
                                child: Text('E-Arşiv'),
                              ),
                              DropdownMenuItem(
                                value: 'E-SMM',
                                child: Text('E-SMM'),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setModalState(() => docType = val);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Fatura Tutarı (₺) *',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: amountController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              prefixText: '₺ ',
                              hintText: '0,00',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'KDV Oranı',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<int>(
                            initialValue: vatRate,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 20,
                                child: Text('%20'),
                              ),
                              DropdownMenuItem(
                                value: 10,
                                child: Text('%10'),
                              ),
                              DropdownMenuItem(
                                value: 1,
                                child: Text('%1'),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setModalState(() => vatRate = val);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Hizmet / Açıklama Notu',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(
                    hintText: 'Örn: Yazılım & Arayüz Geliştirme Hizmeti',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F766E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      final title = titleController.text.trim();
                      final amount =
                          double.tryParse(amountController.text.trim()) ?? 0;
                      if (title.isEmpty || amount <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Lütfen geçerli bir alıcı ve tutar giriniz.',
                            ),
                            backgroundColor: AppColors.expenseRed,
                          ),
                        );
                        return;
                      }
                      final vat = amount * (vatRate / 100.0);
                      final newInv = _InvoiceItemData(
                        icon: Icons.description_rounded,
                        iconBg: const Color(0xFFD1FAE5),
                        iconColor: const Color(0xFF065F46),
                        title: title,
                        vkn: vknController.text.trim().isEmpty
                            ? '1234567890'
                            : vknController.text.trim(),
                        gibNo:
                            'NVA2026${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
                        docType: docType,
                        amount: amount,
                        vatAmount: vat,
                        status: 'pending',
                        tag1: '● GİB Onay Bekliyor',
                        tag1Bg: const Color(0xFFFEF3C7),
                        tag1Fg: const Color(0xFFB45309),
                        tag2: 'KDV %$vatRate',
                        tag2Bg: const Color(0xFFE0F2FE),
                        tag2Fg: const Color(0xFF0369A1),
                        dateText: 'Bugün, 11 Kas',
                      );
                      setState(() {
                        _outgoingInvoices.insert(0, newInv);
                        _isIncomingTab = false;
                      });
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.primaryGreen,
                          content: Text(
                            '$title adına ${newInv.gibNo} numaralı $docType başarıyla kesildi ve GİB\'e iletildi!',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: const Text(
                      'Faturayı Kes & GİB\'e Gönder',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleBulkXmlExport(BuildContext context) {
    final activeInvoices =
        _isIncomingTab ? _incomingInvoices : _outgoingInvoices;
    final total =
        activeInvoices.fold<double>(0, (sum, item) => sum + item.amount);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.folder_zip_outlined,
                    color: AppColors.primaryTeal,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Toplu UBL-TR XML Dışa Aktar',
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkNavy,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      'GİB UBL 2.1 e-Fatura Paketi (.ZIP)',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: const Color(0xFF64748B),
                        fontSize: 11,
                      ),
                    ),
                  ],
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Dönem & Kapsam:',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        _isIncomingTab
                            ? 'Gelen (Alış) Faturaları'
                            : 'Giden (Satış) Faturaları',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkNavy,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Toplam Belge Adedi:',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        '${activeInvoices.length} Adet XML Belgesi',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkNavy,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Toplam Matrah Tutarı:',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        '₺${total.toStringAsFixed(2).replaceAll('.', ',')}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryTeal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: AppColors.primaryGreen,
                          content: Text(
                            'XML arşivi mali müşavir portalına aktarıldı (Luca Entegrasyonu).',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.send_rounded, size: 16),
                    label: const Text(
                      'Müşavire İlet',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkNavy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.primaryGreen,
                          content: Text(
                            '${activeInvoices.length} adet UBL-TR XML içeren ZIP arşivi başarıyla indirildi!',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.download_rounded, size: 16),
                    label: const Text(
                      'ZIP İndir',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
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

  void _showFilterSheet(BuildContext context) {
    final docTypes = ['Tümü', 'E-Fatura', 'E-Arşiv', 'E-SMM'];
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
                  'Fatura Belge Türü Filtresi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                TextButton(
                  onPressed: () {
                    setState(() => _selectedDocType = 'Tümü');
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
              children: docTypes.map((dt) {
                final isSelected = _selectedDocType == dt;
                return ChoiceChip(
                  label: Text(dt),
                  selected: isSelected,
                  selectedColor: const Color(0xFF5EEAD4),
                  onSelected: (val) {
                    setState(() => _selectedDocType = dt);
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
                Row(
                  children: [
                    Text(
                      'E-Fatura & E-Arşiv',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppColors.darkNavy,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1FAE5),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'GİB Canlı',
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
                Row(
                  children: [
                    const Icon(
                      Icons.sync_rounded,
                      size: 16,
                      color: AppColors.primaryTeal,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '14:15',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'Gelir İdaresi Başkanlığı resmi e-Fatura entegrasyonu',
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 14),

            // 1. Kasım 2026 E-Fatura Hacmi Hero Kartı (₺184.650,00)
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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.account_balance_rounded,
                              color: Color(0xFF5EEAD4),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Kasım 2026 E-Fatura\nHacmi',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: const Color(0xFF94A3B8),
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryTeal.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '%100 GİB\nUyumlu',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: const Color(0xFF5EEAD4),
                            fontSize: 10,
                            height: 1.15,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _isIncomingTab
                        ? 'Toplam Gelen Fatura Tutarı'
                        : 'Toplam Giden (Satış) Fatura Tutarı',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        _isIncomingTab ? '₺184.650,00' : '₺276.250,00',
                        style: AppTextStyles.numericBalance.copyWith(
                          color: Colors.white,
                          fontSize: 30,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isIncomingTab ? '+₺30.775 KDV' : '+₺46.041 KDV',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: const Color(0xFF5EEAD4),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryGreen,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Gelen Faturalar',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: const Color(0xFF94A3B8),
                                    fontSize: 11,
                                  ),
                                ),
                                Text(
                                  '${_incomingInvoices.length} Adet',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF94A3B8),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Giden Faturalar',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: const Color(0xFF94A3B8),
                                    fontSize: 11,
                                  ),
                                ),
                                Text(
                                  '${_outgoingInvoices.length} Adet',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F766E),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 42),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => _showNewInvoiceSheet(context),
                          icon: const Icon(Icons.add_circle_outline, size: 16),
                          label: const Text(
                            'Yeni E-Fatura Kes',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 4,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.white.withOpacity(0.08),
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.15),
                            ),
                            minimumSize: const Size(0, 42),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => _handleBulkXmlExport(context),
                          icon: const Icon(
                            Icons.download_for_offline_outlined,
                            size: 16,
                          ),
                          label: const Text(
                            'Toplu XML',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 2. Gelen (Alış) | Giden (Satış) Sekmeleri
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0).withOpacity(0.6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isIncomingTab = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _isIncomingTab
                              ? Colors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.arrow_downward_rounded,
                              size: 14,
                              color: AppColors.primaryTeal,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Gelen (Alış)  ${_incomingInvoices.length}',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: _isIncomingTab
                                    ? AppColors.darkNavy
                                    : const Color(0xFF64748B),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isIncomingTab = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: !_isIncomingTab
                              ? Colors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.arrow_upward_rounded,
                              size: 14,
                              color: Color(0xFF64748B),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Giden (Satış)  ${_outgoingInvoices.length}',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: !_isIncomingTab
                                    ? AppColors.darkNavy
                                    : const Color(0xFF64748B),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 3. Arama Kutusu + Filtre
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
                        hintText: 'Fatura No, Tedarikçi veya VKN ara...',
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
                  onTap: () => _showFilterSheet(context),
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: _selectedDocType != 'Tümü'
                          ? const Color(0xFF5EEAD4)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _selectedDocType != 'Tümü'
                            ? const Color(0xFF0F766E)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      size: 20,
                      color: _selectedDocType != 'Tümü'
                          ? const Color(0xFF0F766E)
                          : AppColors.darkNavy,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 4. Durum Filtre Çipleri
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildStatusPill('Tümü'),
                  const SizedBox(width: 8),
                  _buildStatusPill('Ödendi / Kapandı'),
                  const SizedBox(width: 8),
                  _buildStatusPill('● Onay Bekleyenler', isWarning: true),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 5. Fatura Kayıtları Başlığı
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkNavy,
                    ),
                    children: [
                      TextSpan(
                        text: _isIncomingTab
                            ? 'Gelen Fatura Kayıtları  '
                            : 'Giden Fatura Kayıtları  ',
                      ),
                      const TextSpan(
                        text: 'GİB Posta Kutusu',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Tarihe Göre ⌄',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primaryTeal,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ================= DİNAMİK FATURA KARTLARI =================
            Builder(
              builder: (context) {
                final activeInvoices =
                    _isIncomingTab ? _incomingInvoices : _outgoingInvoices;
                final filtered = activeInvoices.where((inv) {
                  // Status filter
                  if (_selectedStatusFilter == 'Ödendi / Kapandı' &&
                      inv.status != 'paid') {
                    return false;
                  }
                  if (_selectedStatusFilter.contains('Onay Bekleyenler') &&
                      inv.status != 'pending') {
                    return false;
                  }

                  // Doc type
                  if (_selectedDocType != 'Tümü' &&
                      inv.docType != _selectedDocType) {
                    return false;
                  }

                  // Search text
                  if (_searchQuery.isNotEmpty) {
                    final q = _searchQuery.toLowerCase();
                    final m1 = inv.title.toLowerCase().contains(q);
                    final m2 = inv.gibNo.toLowerCase().contains(q);
                    final m3 = inv.vkn.toLowerCase().contains(q);
                    final m4 = inv.amount.toString().contains(q);
                    if (!m1 && !m2 && !m3 && !m4) return false;
                  }
                  return true;
                }).toList();

                if (filtered.isEmpty) {
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
                          'Filtreye uygun fatura kaydı bulunamadı',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkNavy,
                            fontSize: 13.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _searchQuery.isNotEmpty
                              ? '"$_searchQuery" araması için kayıt bulunamadı.'
                              : 'Seçili sekmede veya kriterlere uygun fatura bulunmuyor.',
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
                    for (final inv in filtered) ...[
                      _buildDetailedInvoiceCard(
                        icon: inv.icon,
                        iconBg: inv.iconBg,
                        iconColor: inv.iconColor,
                        title: inv.title,
                        gibNo: inv.gibNo,
                        docType: inv.docType,
                        amount:
                            '₺${inv.amount.toStringAsFixed(2).replaceAll('.', ',')}',
                        subAmount:
                            'KDV %20: ₺${inv.vatAmount.toStringAsFixed(2).replaceAll('.', ',')}',
                        tag1: inv.tag1,
                        tag1Bg: inv.tag1Bg,
                        tag1Fg: inv.tag1Fg,
                        tag2: inv.tag2,
                        tag2Bg: inv.tag2Bg,
                        tag2Fg: inv.tag2Fg,
                        dateText: inv.dateText,
                        btn1Label: inv.btn1Label,
                        btn2Label: inv.btn2Label,
                        rightLabel: inv.rightLabel,
                        hasLeftAmberAccent: inv.hasLeftAmberAccent,
                        fastActionCallback: inv.hasLeftAmberAccent
                            ? () => _showFastPaymentDialog(context)
                            : null,
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // 6. Mali Müşavir Portalı Paylaşım Kartı
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.business_center_outlined,
                      color: AppColors.darkNavy,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mali Müşavir Portalı',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkNavy,
                          ),
                        ),
                        Text(
                          'Otomatik Luca & Zirve Entegrasyonu',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: const Color(0xFF64748B),
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkNavy,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Kasım 2026 E-Fatura paketi Luca & Zirve Mali Müşavir Portalına aktarıldı.',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.send_rounded, size: 14),
                    label: const Text(
                      'Paylaş',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 7. GİB Portal ile Şimdi Senkronize Et
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
                        'GİB Portal senkronizasyonu başarıyla tamamlandı.',
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.sync_rounded,
                  size: 18,
                  color: AppColors.primaryTeal,
                ),
                label: const Text(
                  'GİB Portal ile Şimdi Senkronize Et',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPill(String label, {bool isWarning = false}) {
    final bool isSelected = _selectedStatusFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedStatusFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.darkNavy
              : (isWarning ? const Color(0xFFFFFBEB) : Colors.white),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? AppColors.darkNavy : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: isSelected
                ? Colors.white
                : (isWarning
                      ? const Color(0xFFB45309)
                      : const Color(0xFF475569)),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailedInvoiceCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String gibNo,
    required String docType,
    required String amount,
    required String subAmount,
    required String tag1,
    required Color tag1Bg,
    required Color tag1Fg,
    String? tag2,
    Color? tag2Bg,
    Color? tag2Fg,
    required String dateText,
    String? btn1Label,
    String? btn2Label,
    String? rightLabel,
    bool hasLeftAmberAccent = false,
    VoidCallback? fastActionCallback,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: hasLeftAmberAccent
              ? const Color(0xFFF59E0B).withValues(alpha: 0.4)
              : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: hasLeftAmberAccent
                    ? const Color(0xFFF59E0B)
                    : Colors.transparent,
                width: hasLeftAmberAccent ? 4 : 0,
              ),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkNavy,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$gibNo ⧉',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: const Color(0xFF64748B),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        docType,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: const Color(0xFF1D4ED8),
                          fontSize: 9.5,
                        ),
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
                  const SizedBox(height: 2),
                  Text(
                    subAmount,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: const Color(0xFF64748B),
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: tag1Bg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tag1,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: tag1Fg,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    if (tag2 != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: tag2Bg ?? const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tag2,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: tag2Fg ?? const Color(0xFF475569),
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                dateText,
                style: AppTextStyles.bodySmall.copyWith(
                  color: const Color(0xFF64748B),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.picture_as_pdf_outlined,
                          size: 14,
                          color: Color(0xFFDC2626),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          btn1Label ?? 'PDF İndir',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.darkNavy,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (btn2Label != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        btn2Label,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.darkNavy,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (fastActionCallback != null)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F766E),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: fastActionCallback,
                  icon: const Icon(Icons.bolt_rounded, size: 15),
                  label: const Text(
                    'Anında Öde (FAST)',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                )
              else if (rightLabel != null)
                Text(
                  rightLabel,
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
);
  }

  void _showFastPaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('TCMB FAST ile E-SMM Ödemesi'),
        content: const Text(
          'Aydın Hukuk & Danışmanlık adına kayıtlı AYD202600000319 numaralı '
          '₺15.000,00 (Stopaj sonrası Net: ₺12.300,00) tutarındaki makbuz '
          'Nova Tasarım Ltd. ticari hesabınızdan 7/24 FAST ile ödenecektir.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F766E),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: AppColors.primaryGreen,
                  content: Text(
                    'Aydın Hukuk E-SMM ödemesi FAST ile tamamlandı ve ERP defterine işlendi!',
                  ),
                ),
              );
            },
            child: const Text('Onayla ve Öde'),
          ),
        ],
      ),
    );
  }
}

typedef EInvoiceArchiveScreen = EInvoiceGibListScreen;
