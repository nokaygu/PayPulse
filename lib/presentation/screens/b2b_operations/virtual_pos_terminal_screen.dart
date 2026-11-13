import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/datasources/remote/firebase_firestore_datasource.dart';
import '../../../data/models/transaction_model.dart';
import '../auth/bloc/auth_bloc.dart';
import '../../widgets/role_switch_app_bar.dart';

/// Görsel 6: Sanal POS Terminali Ekranı
class VirtualPosTerminalScreen extends StatefulWidget {
  const VirtualPosTerminalScreen({super.key});

  @override
  State<VirtualPosTerminalScreen> createState() =>
      _VirtualPosTerminalScreenState();
}

class _VirtualPosTerminalScreenState extends State<VirtualPosTerminalScreen> {
  bool _isCardTab = true;
  double _amount = 3750.00;
  int _selectedInstallment = 1; // 1: Tek Çekim, 3: 3 Taksit, 6: 6 Taksit
  bool _isProcessing = false;

  void _showSlipDialog(TransactionModel tx) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.primaryGreen,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'POS Satış Slipi (Eğitim Amaçlı POS Simülasyonu)',
              style: AppTextStyles.labelLarge.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.darkNavy,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Text(
                    'TAHSİLAT TUTARI',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₺${(tx.amount / 100.0).toStringAsFixed(2).replaceAll('.', ',')}',
                    style: AppTextStyles.numericBalance.copyWith(
                      color: AppColors.darkNavy,
                      fontSize: 28,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildSlipRow('Terminal No:', 'POS-NOVA-8821'),
            _buildSlipRow('İşlem No:', tx.txId),
            _buildSlipRow('Kart Sahibi:', 'Mehmet Can Özkan'),
            _buildSlipRow('Kart No:', '•••• •••• •••• 9012'),
            _buildSlipRow(
              'Taksit:',
              _selectedInstallment == 1
                  ? 'Tek Çekim'
                  : '$_selectedInstallment Taksit',
            ),
            _buildSlipRow(
              'Tarih & Saat:',
              '${tx.timestamp.day}.${tx.timestamp.month}.${tx.timestamp.year} ${tx.timestamp.hour.toString().padLeft(2, '0')}:${tx.timestamp.minute.toString().padLeft(2, '0')}',
            ),
            _buildSlipRow(
              'Onay Kodu:',
              'AUTH-${tx.txId.hashCode.abs().toString().padLeft(6, '0').substring(0, 6)}',
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkNavy,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  Widget _buildSlipRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: const Color(0xFF64748B),
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.darkNavy,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showZReportDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    color: AppColors.darkNavy,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'POS GÜN SONU Z RAPORU',
                        style: AppTextStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkNavy,
                        ),
                      ),
                      Text(
                        'Mali Değeri Vardır • VUK Md. 227 Uyarınca',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: const Color(0xFF64748B),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Z NO: 0048',
                    style: TextStyle(
                      color: Color(0xFF065F46),
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
                  _buildSlipRow('Terminal No:', 'POS-TR-8492'),
                  _buildSlipRow('Üye İşyeri:', 'Nova Tasarım & Yazılım A.Ş.'),
                  _buildSlipRow('VKN / TCKN:', '6320984112'),
                  _buildSlipRow('Tarih & Saat:', '13 Kas 2026 18:00:22'),
                  const Divider(height: 16, color: Color(0xFFE2E8F0)),
                  _buildSlipRow('Tek Çekim Satış (9):', '₺34.800,00'),
                  _buildSlipRow('Taksitli Satış (3):', '₺12.500,00'),
                  _buildSlipRow('PayPulse QR / FAST (2):', '₺5.000,00'),
                  _buildSlipRow('İptal / İade (0):', '₺0,00'),
                  const Divider(height: 16, color: Color(0xFFE2E8F0)),
                  _buildSlipRow('Toplam Brüt Ciro (14):', '₺52.300,00'),
                  _buildSlipRow('POS Komisyonu (%1,39):', '-₺726,97'),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'NET AKTARILACAK:',
                          style: AppTextStyles.labelMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryTeal,
                          ),
                        ),
                        Text(
                          '₺51.573,03',
                          style: AppTextStyles.headlineSmall.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryTeal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildSlipRow('Hesaba Geçiş:', 'Yarın 10:00 (Garanti BBVA)'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.darkNavy,
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Z Raporu PDF formatında indirildi ve yazıcıya gönderildi.'),
                          backgroundColor: AppColors.primaryTeal,
                        ),
                      );
                    },
                    icon: const Icon(Icons.print_outlined, size: 18),
                    label: const Text('Yazdır / PDF', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkNavy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Kapat', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommissionCard(double commission, double netAmount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '%  İşlem Komisyonu (%1,39)',
                style: AppTextStyles.bodySmall.copyWith(
                  color: const Color(0xFF475569),
                ),
              ),
              Text(
                '₺${commission.toStringAsFixed(2).replaceAll('.', ',')}',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.darkNavy,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🏦  Net Hesaba Geçecek',
                style: AppTextStyles.bodySmall.copyWith(
                  color: const Color(0xFF475569),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₺${netAmount.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.primaryTeal,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Ertesi Gün 10:00 Transfer',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: const Color(0xFF64748B),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '🔒 3D Secure 2.0 Korumalı  •  256-Bit SSL Şifreleme',
            style: AppTextStyles.bodySmall.copyWith(
              color: const Color(0xFF64748B),
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrPaymentSection(double commission, double netAmount) {
    return Column(
      children: [
        // QR Kod Kartı
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
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
                          Icons.qr_code_2_rounded,
                          size: 18,
                          color: Color(0xFF065F46),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Karekod ile Tahsilat',
                        style: AppTextStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkNavy,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '● Tarama Bekleniyor',
                      style: TextStyle(
                        color: Color(0xFFB45309),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: 200,
                height: 200,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.qr_code_2_rounded,
                      size: 170,
                      color: AppColors.darkNavy,
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.bolt_rounded,
                          color: AppColors.primaryTeal,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Müşteriye bu QR kodu okutun',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkNavy,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'PayPulse Cüzdan, BKM Karekod veya tüm banka uygulamaları ile uyumludur.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: const Color(0xFF64748B),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      size: 14,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Geçerlilik Süresi: 04:52 dk',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: const Color(0xFF475569),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.darkNavy,
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tahsilat bağlantısı panoya kopyalandı: https://paypulse.app/pay/pos-8492'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      label: const Text('Linki Kopyala', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF166534),
                        backgroundColor: const Color(0xFFF0FDF4),
                        side: const BorderSide(color: Color(0xFFBBF7D0)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Ödeme linki müşterinin WhatsApp numarasına iletildi.'),
                            backgroundColor: Color(0xFF166534),
                          ),
                        );
                      },
                      icon: const Icon(Icons.send_rounded, size: 16),
                      label: const Text('WhatsApp', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Komisyon ve Net Tutar
        _buildCommissionCard(commission, netAmount),
        const SizedBox(height: 14),

        // Buton: Müşteri Ödemesini Tamamla (Simüle Et)
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryTeal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: _isProcessing ? null : _handleCompletePayment,
            icon: _isProcessing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check_circle_rounded, size: 18),
            label: Text(
              _isProcessing
                  ? 'QR Ödeme Doğrulanıyor...'
                  : 'Müşteri Ödemesini Tamamla (₺${_amount.toStringAsFixed(2).replaceAll('.', ',')})',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Buton: Kart ile Tahsilata Dön
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
            onPressed: () => setState(() => _isCardTab = true),
            icon: const Icon(
              Icons.credit_card_rounded,
              size: 18,
              color: AppColors.darkNavy,
            ),
            label: const Text(
              'Kart ile Çekim Ekranına Dön',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleCompletePayment() async {
    if (_isProcessing) return;

    final companyId = context.read<AuthBloc>().state.user?.companyId;
    if (companyId == null || companyId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('POS işlemi için yetkili bir şirket kaydı bulunamadı.'),
          backgroundColor: AppColors.expenseRed,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final tx = await FirebaseFirestoreDatasource().executeCardPosPayment(
        companyId: companyId,
        maskedCardNumber: '•••• •••• •••• 9012',
        amountKurus: (_amount * 100).toInt(),
      );

      if (!mounted) return;
      _showSlipDialog(tx);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('POS Tahsilat Hatası: $e'),
          backgroundColor: AppColors.expenseRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double commission = _amount * 0.0139;
    final double netAmount = _amount - commission;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const RoleSwitchAppBar(isBusinessMode: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık Kutusu
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryTeal,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Sanal POS Terminali',
                              style: AppTextStyles.headlineSmall.copyWith(
                                color: AppColors.darkNavy,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Kart ile Çekim & QR Tahsilat Merkezi',
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'ID: POS-TR-8492',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.darkNavy,
                            fontSize: 9.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '✓ TCMB & BDDK',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primaryTeal,
                          fontSize: 9.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Sekmeler: Kredi / Banka Kartı | PayPulse QR Tahsilat
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0).withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isCardTab = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _isCardTab ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.credit_card_rounded,
                              size: 16,
                              color: _isCardTab
                                  ? AppColors.primaryTeal
                                  : const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Kredi / Banka\nKartı',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: _isCardTab
                                    ? AppColors.darkNavy
                                    : const Color(0xFF64748B),
                                fontWeight: _isCardTab
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                height: 1.15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isCardTab = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: !_isCardTab
                              ? Colors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.qr_code_rounded,
                              size: 16,
                              color: !_isCardTab
                                  ? AppColors.primaryTeal
                                  : const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'PayPulse QR\nTahsilat',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: !_isCardTab
                                    ? AppColors.darkNavy
                                    : const Color(0xFF64748B),
                                fontWeight: !_isCardTab
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                height: 1.15,
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
            const SizedBox(height: 14),

            // 1. Tahsil Edilecek Tutar Kartı (₺3.750,00)
            Container(
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tahsil Edilecek Tutar',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1FAE5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '⚡ Anında Bloke Çözümü',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: const Color(0xFF065F46),
                            fontSize: 9.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '₺',
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _amount.toStringAsFixed(2).replaceAll('.', ','),
                          style: AppTextStyles.numericBalance.copyWith(
                            color: AppColors.darkNavy,
                            fontSize: 34,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildQuickAddChip('+₺250', 250),
                        const SizedBox(width: 6),
                        _buildQuickAddChip('+₺500', 500),
                        const SizedBox(width: 6),
                        _buildQuickAddChip('+₺1.000', 1000),
                        const SizedBox(width: 6),
                        _buildQuickAddChip('+₺2.500', 2500),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => setState(() => _amount = 3750.00),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '↺ Temizle',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: const Color(0xFFB91C1C),
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.description_outlined,
                          size: 16,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Web Tasarım Hizmet Bedeli - FTR-2026-08',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.darkNavy,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.email_outlined,
                          size: 16,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'mehmet.can@ozkanajans.com',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.darkNavy,
                              fontWeight: FontWeight.w600,
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

            if (_isCardTab) ...[
              // 2. Koyu NOVA TASARIM POS Kart Önizlemesi
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.heroCardGradient,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.darkNavy.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
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
                            width: 24,
                            height: 18,
                            decoration: BoxDecoration(
                              color: const Color(0xFF5EEAD4).withOpacity(0.7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'NOVA TASARIM POS',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: const Color(0xFF94A3B8),
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '● Aktif Terminal',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: const Color(0xFF5EEAD4),
                            fontSize: 9.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '5400  ••••  ••••  8912',
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: Colors.white,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 18,
                            height: 18,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEA580C),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Transform.translate(
                            offset: const Offset(-6, 0),
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: const BoxDecoration(
                                color: Color(0xFF5EEAD4),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'KART SAHİBİ',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: const Color(0xFF94A3B8),
                              fontSize: 9,
                            ),
                          ),
                          Text(
                            'Mehmet Can Özkan',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'TUTAR',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: const Color(0xFF94A3B8),
                              fontSize: 9,
                            ),
                          ),
                          Text(
                            '₺${_amount.toStringAsFixed(2).replaceAll('.', ',')}',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: const Color(0xFF5EEAD4),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Kart Bilgileri Formu (Luhn Geçerli)
            Container(
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Kart Bilgileri',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkNavy,
                        ),
                      ),
                      Text(
                        '✓ Luhn Geçerli',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primaryTeal,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Kart Sahibi Adı Soyadı',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: const Color(0xFF64748B),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Mehmet Can Özkan',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkNavy,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Kart Numarası',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: const Color(0xFF64748B),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '5400  8291  3847  8912',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkNavy,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Text(
                          'MC',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Son Kullanma (AA/YY)',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: const Color(0xFF64748B),
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.all(12),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '08 / 28',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.darkNavy,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CVV / CVC',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: const Color(0xFF64748B),
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.all(12),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '•••',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.darkNavy,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Taksit Seçimi',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        'Vade Farksız',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.darkNavy,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildInstallmentBox('Tek Çekim', '₺3.750,00', 1),
                      const SizedBox(width: 8),
                      _buildInstallmentBox('3 Taksit', '3x ₺1.285,00', 3),
                      const SizedBox(width: 8),
                      _buildInstallmentBox('6 Taksit', '6x ₺662,50', 6),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 4. Komisyon ve Net Tutar
            _buildCommissionCard(commission, netAmount),
            const SizedBox(height: 14),

            // 5. Tahsilatı Tamamla Butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkNavy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _isProcessing ? null : _handleCompletePayment,
                icon: _isProcessing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.lock_outline_rounded, size: 18),
                label: Text(
                  _isProcessing
                      ? 'POS Tahsilatı Yapılıyor...'
                      : 'Tahsilatı Tamamla (₺${_amount.toStringAsFixed(2).replaceAll('.', ',')})  →',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // QR ile Müşteriye Ödet Butonu
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
                onPressed: () => setState(() => _isCardTab = false),
                icon: const Icon(
                  Icons.qr_code_scanner_rounded,
                  size: 18,
                  color: AppColors.primaryTeal,
                ),
                label: const Text(
                  'QR ile Müşteriye Ödet',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ] else ...[
            _buildQrPaymentSection(commission, netAmount),
          ],
          const SizedBox(height: 12),

          // Bugünkü POS İşlemleri / Z Raporu
          GestureDetector(
            onTap: () => _showZReportDialog(context),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.receipt_long_rounded,
                    color: AppColors.darkNavy,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bugünkü POS İşlemleri',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.darkNavy,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '14 Adet • ₺52.300,00',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: const Color(0xFF64748B),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Z Raporu >',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primaryTeal,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAddChip(String label, double addVal) {
    return GestureDetector(
      onTap: () => setState(() => _amount += addVal),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.darkNavy,
            fontSize: 10,
          ),
        ),
      ),
    );
  }

  Widget _buildInstallmentBox(String title, String sub, int count) {
    final bool isSelected = _selectedInstallment == count;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedInstallment = count),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.darkNavy : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.darkNavy : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: AppTextStyles.labelSmall.copyWith(
                  color: isSelected ? Colors.white : AppColors.darkNavy,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sub,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isSelected
                      ? const Color(0xFF5EEAD4)
                      : const Color(0xFF64748B),
                  fontSize: 9.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
