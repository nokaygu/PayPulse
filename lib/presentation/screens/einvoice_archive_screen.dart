import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/firestore_seeder.dart';
import '../../data/models/einvoice_model.dart';
import '../widgets/dark_gradient_hero_card.dart';
import '../widgets/status_badge_widget.dart';

/// Görsel 7: E-Fatura & E-Arşiv Ekranı
/// Toplam Gelen Fatura hacmi, Gelen/Giden sekmeleri, tevkifat/demirbaş rozetleri,
/// FAST ile anında öde butonu ve Mali Müşavir Portalı paylaşım kartı.
class EInvoiceArchiveScreen extends StatefulWidget {
  const EInvoiceArchiveScreen({super.key});

  @override
  State<EInvoiceArchiveScreen> createState() => _EInvoiceArchiveScreenState();
}

class _EInvoiceArchiveScreenState extends State<EInvoiceArchiveScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final allInvoices = FirestoreSeeder.mockInvoices;

    final incomingInvoices = allInvoices.where((i) => i.isIncoming).toList();
    final outgoingInvoices = allInvoices.where((i) => !i.isIncoming).toList();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'E-Fatura & E-Arşiv Portalı',
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_rounded),
            tooltip: 'GİB Entegrasyonunu Yenile',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('GİB Portalı ile senkronizasyon tamamlandı (Kasım 2026).'),
                ),
              );
            },
          ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    // 1. ₺184.650,00 Toplam Gelen Fatura Hacmi Kartı (Koyu Gradyanlı)
                    DarkGradientHeroCard(
                      title: 'Toplam Gelen Fatura Hacmi (Kasım 2026)',
                      mainAmount: '₺184.650,00',
                      subtitle: '%100 GİB ve Gelir İdaresi Uyumlu',
                      topRightBadge: const StatusBadgeWidget(
                        label: '%100 GİB Uyumlu',
                        type: BadgeType.darkGlass,
                        icon: Icons.verified_rounded,
                      ),
                      bottomChild: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreen.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.call_received_rounded,
                                  color: AppColors.primaryGreen,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '24 Gelen (Alış)',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            height: 20,
                            width: 1,
                            color: Colors.white.withOpacity(0.15),
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.infoBlue.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.call_made_rounded,
                                  color: AppColors.infoBlue,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '42 Giden (Satış)',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 2. Mali Müşavir Portalı Paylaşım Kartı
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.outlineVariant,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primaryTeal.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.share_outlined,
                              color: AppColors.primaryTeal,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Mali Müşavir Portalı',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'Kasım ayı tüm e-fatura dökümünü tek tıkla muhasebeye aktarın.',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryTeal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              minimumSize: Size.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Kasım 2026 E-Fatura & E-SMM paketi Mali Müşavir sistemine iletildi.',
                                  ),
                                ),
                              );
                            },
                            child: const Text('Paylaş'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 3. Sekmeler: Gelen (Alış) & Giden (Satış)
                    TabBar(
                      controller: _tabController,
                      indicatorColor: AppColors.primaryGreen,
                      labelColor: AppColors.primaryGreen,
                      unselectedLabelColor: colorScheme.onSurfaceVariant,
                      labelStyle: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      tabs: [
                        Tab(text: 'Gelen (Alış) • ${incomingInvoices.length}'),
                        Tab(text: 'Giden (Satış) • ${outgoingInvoices.length}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Gelen Fatura Listesi
            _buildInvoiceList(incomingInvoices, isIncoming: true),
            // Giden Fatura Listesi
            _buildInvoiceList(outgoingInvoices, isIncoming: false),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceList(List<EInvoiceModel> invoices, {required bool isIncoming}) {
    if (invoices.isEmpty) {
      return const Center(child: Text('Kayıtlı fatura bulunmuyor.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: invoices.length,
      itemBuilder: (context, index) {
        final invoice = invoices[index];
        return _buildInvoiceCard(invoice);
      },
    );
  }

  Widget _buildInvoiceCard(EInvoiceModel inv) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withOpacity(0.6),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst Satır: Fatura No & Rozet
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  inv.gibInvoiceNo,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                ),
                if (inv.badgeText != null)
                  StatusBadgeWidget(
                    label: inv.badgeText!,
                    type: inv.badgeText!.contains('Tevkifat')
                        ? BadgeType.warning
                        : (inv.badgeText!.contains('Demirbaş')
                            ? BadgeType.info
                            : BadgeType.success),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Firma Adı & Tutar
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        inv.counterpartyName,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'KDV: ₺${(inv.vatAmount / 100.0).toStringAsFixed(2)} • Tarih: ${inv.issueDate.day}.${inv.issueDate.month}.${inv.issueDate.year}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₺${inv.totalAmountInLira.toStringAsFixed(2)}',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.darkNavy,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),

            // Aksiyon Alanı: "Anında Öde (FAST)" butonu (Aydın Hukuk örneği)
            if (inv.canPayWithFast) ...[
              const SizedBox(height: 12),
              Divider(height: 1, color: colorScheme.outlineVariant),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: AppColors.warningOrange,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Ödeme Bekliyor',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.warningOrange,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      _showFastPaymentDialog(inv);
                    },
                    icon: const Icon(Icons.bolt_rounded, size: 16),
                    label: const Text('Anında Öde (FAST)'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showFastPaymentDialog(EInvoiceModel invoice) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.bolt_rounded, color: AppColors.primaryGreen),
            SizedBox(width: 8),
            Text('FAST Fatura Ödemesi'),
          ],
        ),
        content: Text(
          '${invoice.counterpartyName} adına kayıtlı ${invoice.gibInvoiceNo} numaralı '
          '₺${invoice.totalAmountInLira.toStringAsFixed(2)} tutarındaki fatura '
          'PayPulse ana cüzdanınızdan 7/24 FAST ile ödenecektir. Onaylıyor musunuz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.incomeGreen,
                  content: Text(
                    '${invoice.counterpartyName} faturası başarıyla ödendi! Dekont oluşturuldu.',
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

