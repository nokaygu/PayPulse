import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/formatters/currency_and_card_formatters.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/validators/financial_validators.dart';
import '../../../data/datasources/remote/firebase_firestore_datasource.dart';
import '../../../data/models/payment_request_model.dart';
import '../../../data/models/transaction_model.dart';
import '../../widgets/role_switch_app_bar.dart';
import '../../widgets/status_badge_widget.dart';
import '../auth/bloc/auth_bloc.dart';

/// Görsel 6: B2B Sanal POS Terminali & PayPulse QR Tahsilat Merkezi
/// - Kasadan müşteriden Kredi/Banka Kartı veya PayPulse Dinamik QR ile ödeme alma
/// - Gerçek QR Kod (qr_flutter) ve 48 saniyede bir otomatik QR yenileme
/// - Başarılı İşlem Simülatörü (Kart & PayPulse QR Slip ve Canlı Z-Raporu Güncellemesi)
class VirtualPosTerminalScreen extends StatefulWidget {
  const VirtualPosTerminalScreen({super.key});

  @override
  State<VirtualPosTerminalScreen> createState() =>
      _VirtualPosTerminalScreenState();
}

class _VirtualPosTerminalScreenState extends State<VirtualPosTerminalScreen> {
  static const int _qrRefreshIntervalSeconds = 48;

  bool _isCardTab = true;
  double _amount = 3750.00;
  int _selectedInstallment = 1; // 1: Tek Çekim, 3: 3 Taksit, 6: 6 Taksit
  bool _isProcessing = false;

  // 48 Saniye Dinamik QR Durumu
  int _remainingQrSeconds = _qrRefreshIntervalSeconds;
  Timer? _qrCountdownTimer;
  late String _b2bQrToken;
  late DateTime _qrGeneratedAt;
  int _qrGenerationCount = 1;

  // Kart Formu Controller'ları (Varsayılan Luhn Geçerli Test Kartı)
  late final TextEditingController _cardHolderController;
  late final TextEditingController _cardNumberController;
  late final TextEditingController _expiryController;
  late final TextEditingController _cvvController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _customerEmailController;

  // Günlük POS İşlemleri (Canlı Simülatör Listesi)
  int _todayTxCount = 14;
  double _todayTotalAmount = 52300.00;
  final List<_PosSlipEntry> _recentPosSlips = [
    _PosSlipEntry(
      txId: 'POS-TX-99401',
      method: 'Kredi Kartı (MC •••• 8913)',
      customerName: 'Mehmet Can Özkan',
      amount: 3750.00,
      installmentLabel: 'Tek Çekim',
      timestamp: DateTime(2026, 11, 13, 10, 42),
      qrToken: null,
    ),
    _PosSlipEntry(
      txId: 'POS-QR-99402',
      method: 'PayPulse TR Karekod',
      customerName: 'Deniz Aksoy (PP-849201)',
      amount: 1850.00,
      installmentLabel: 'Tek Çekim (QR)',
      timestamp: DateTime(2026, 11, 13, 09, 55),
      qrToken: 'PPB2B-9482A1',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _cardHolderController = TextEditingController(text: 'Mehmet Can Özkan');
    // 5400 8291 3847 8913 Luhn algoritmasını tam geçer
    _cardNumberController = TextEditingController(
      text: '5400 8291 3847 8913',
    );
    _expiryController = TextEditingController(text: '08 / 28');
    _cvvController = TextEditingController(text: '482');
    _descriptionController = TextEditingController(
      text: 'Web Tasarım Hizmet Bedeli - FTR-2026-08',
    );
    _customerEmailController = TextEditingController(
      text: 'mehmet.can@ozkanajans.com',
    );

    _generateNewPosQrCode(resetTimer: true);
    _startQrCountdownTimer();
  }

  @override
  void dispose() {
    _qrCountdownTimer?.cancel();
    _cardHolderController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _descriptionController.dispose();
    _customerEmailController.dispose();
    super.dispose();
  }

  void _startQrCountdownTimer() {
    _qrCountdownTimer?.cancel();
    _qrCountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_remainingQrSeconds <= 1) {
          _qrGenerationCount++;
          _generateNewPosQrCode(resetTimer: true);
        } else {
          _remainingQrSeconds--;
        }
      });
    });
  }

  void _generateNewPosQrCode({bool resetTimer = true}) {
    final random = Random();
    final randomHex = List.generate(
      8,
      (_) => random.nextInt(16).toRadixString(16).toUpperCase(),
    ).join();
    final epochSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    _b2bQrToken = 'PPPOS-$epochSec-$randomHex';
    _qrGeneratedAt = DateTime.now();
    if (resetTimer) {
      _remainingQrSeconds = _qrRefreshIntervalSeconds;
    }
  }

  String _buildB2bPosQrPayload(String companyId) {
    final expiresAt = _qrGeneratedAt.add(
      const Duration(seconds: _qrRefreshIntervalSeconds),
    );
    return 'PAYPULSE://TRKAREKOD/B2B_POS'
        '?v=1'
        '&merchant=${Uri.encodeComponent('Nova Tasarım Ltd.')}'
        '&companyId=${Uri.encodeComponent(companyId)}'
        '&terminal=POS-TR-8492'
        '&amt=${_amount.toStringAsFixed(2)}'
        '&curr=TRY'
        '&inst=$_selectedInstallment'
        '&desc=${Uri.encodeComponent(_descriptionController.text.trim())}'
        '&token=$_b2bQrToken'
        '&exp=${expiresAt.millisecondsSinceEpoch}';
  }

  String _formatCountdown(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  String _formatCurrency(double value) {
    final parts = value.toStringAsFixed(2).split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return '₺$intPart,${parts[1]}';
  }

  String _getMaskedCardPreview() {
    final raw = FinancialValidators.normalizeCard(_cardNumberController.text);
    if (raw.length >= 8) {
      final first4 = raw.substring(0, 4);
      final last4 = raw.substring(raw.length - 4);
      return '$first4  ••••  ••••  $last4';
    }
    return '5400  ••••  ••••  8913';
  }

  Future<void> _showCustomAmountDialog() async {
    final controller = TextEditingController(
      text: _amount.toStringAsFixed(2).replaceAll('.', ','),
    );
    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Tahsilat Tutarı Girin',
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.darkNavy,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            prefixText: '₺ ',
            hintText: '3750,00',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkNavy,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final cleaned = controller.text
                  .trim()
                  .replaceAll('.', '')
                  .replaceAll(',', '.');
              final parsed = double.tryParse(cleaned);
              if (parsed != null && parsed > 0) {
                Navigator.of(ctx).pop(parsed);
              }
            },
            child: const Text('Uygula'),
          ),
        ],
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _amount = result;
        _qrGenerationCount++;
        _generateNewPosQrCode(resetTimer: true);
      });
      _startQrCountdownTimer();
    }
  }

  /// Kredi Kartı veya PayPulse QR ile Ödeme Alma & Başarılı İşlem Simülatörü
  Future<void> _handleCompletePayment({required bool isQrPayment}) async {
    if (_isProcessing) return;

    if (!isQrPayment) {
      final cardErr = FinancialValidators.cardNumber(
        _cardNumberController.text,
      );
      if (cardErr != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(cardErr),
            backgroundColor: AppColors.expenseRed,
          ),
        );
        return;
      }
    }

    final authState = context.read<AuthBloc>().state;
    final companyId =
        (authState.user?.companyId != null &&
            authState.user!.companyId!.isNotEmpty)
        ? authState.user!.companyId!
        : 'comp_techsolutions_01';

    setState(() => _isProcessing = true);

    final amountKurus = (_amount * 100).round();
    final maskedCard = _getMaskedCardPreview();
    final activeQrShort = _b2bQrToken.substring(_b2bQrToken.length - 8);

    try {
      TransactionModel tx;
      if (isQrPayment) {
        // QR ödeme talebini Firestore'a kaydetmeyi dene ve başarılı QR POS işlemi üret
        final reqId =
            'payreq_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999)}';
        try {
          await FirebaseFirestoreDatasource().createPaymentRequest(
            PaymentRequestModel(
              requestId: reqId,
              merchantId: companyId,
              amount: amountKurus,
              currency: 'TRY',
              status: 'pending',
              description: _descriptionController.text.trim(),
            ),
          );
        } catch (_) {
          // Offline veya demo oturumunda yerel simülasyon devam eder.
        }

        await Future<void>.delayed(const Duration(milliseconds: 450));
        tx = TransactionModel(
          txId:
              'tx_pos_qr_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999)}',
          senderId: 'QR:PP-849201',
          receiverId: companyId,
          amount: amountKurus,
          currency: 'TRY',
          timestamp: DateTime.now(),
          type: 'qr_pos_payment',
          title: 'PayPulse QR Kasa Tahsilatı',
          category: 'POS QR Tahsilat',
          isExpense: false,
          status: 'Başarılı',
        );
      } else {
        tx = await FirebaseFirestoreDatasource().executeCardPosPayment(
          companyId: companyId,
          maskedCardNumber: maskedCard,
          amountKurus: amountKurus,
        );
      }

      if (!mounted) return;

      final customerDisplay = isQrPayment
          ? 'Deniz Aksoy (PayPulse Cüzdan • PP-849201)'
          : (_cardHolderController.text.trim().isEmpty
                ? 'Mehmet Can Özkan'
                : _cardHolderController.text.trim());

      final methodDisplay = isQrPayment
          ? 'PayPulse QR (TR Karekod #$activeQrShort)'
          : 'Kredi Kartı ($maskedCard)';

      final installmentDisplay = isQrPayment
          ? 'Tek Çekim (Anında Cüzdan Transferi)'
          : (_selectedInstallment == 1
                ? 'Tek Çekim'
                : '$_selectedInstallment Taksit');

      setState(() {
        _todayTxCount++;
        _todayTotalAmount += _amount;
        _recentPosSlips.insert(
          0,
          _PosSlipEntry(
            txId: tx.txId,
            method: methodDisplay,
            customerName: customerDisplay,
            amount: _amount,
            installmentLabel: installmentDisplay,
            timestamp: tx.timestamp,
            qrToken: isQrPayment ? activeQrShort : null,
          ),
        );
        if (isQrPayment) {
          // Ödeme alındığında güvenlik gereği hemen yeni bir 48sn QR üretilir
          _qrGenerationCount++;
          _generateNewPosQrCode(resetTimer: true);
        }
      });

      _showSlipDialog(
        tx: tx,
        isQrPayment: isQrPayment,
        customerName: customerDisplay,
        maskedCard: maskedCard,
        qrShortToken: activeQrShort,
      );
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

  void _showSlipDialog({
    required TransactionModel tx,
    required bool isQrPayment,
    required String customerName,
    required String maskedCard,
    required String qrShortToken,
  }) {
    final double commission = _amount * 0.0139;
    final double netAmount = _amount - commission;

    showDialog<void>(
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
            Expanded(
              child: Text(
                isQrPayment
                    ? 'PayPulse QR Tahsilat Slipi (Başarılı İşlem)'
                    : 'POS Satış Slipi (Başarılı İşlem Simülatörü)',
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkNavy,
                ),
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
                    isQrPayment
                        ? 'QR İLE TAHSİL EDİLEN TUTAR'
                        : 'KART İLE TAHSİL EDİLEN TUTAR',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatCurrency(tx.amount / 100.0),
                    style: AppTextStyles.numericBalance.copyWith(
                      color: AppColors.darkNavy,
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1FAE5),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '✓ ONAYLANDI • KASAYA İŞLENDİ',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: const Color(0xFF065F46),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildSlipRow('Üye İşyeri:', 'Nova Tasarım Ltd.'),
            _buildSlipRow('Terminal No:', 'POS-TR-8492'),
            _buildSlipRow(
              'Ödeme Yöntemi:',
              isQrPayment
                  ? 'PayPulse Dinamik QR (TR Karekod)'
                  : 'Kredi / Banka Kartı (3D Secure)',
            ),
            if (isQrPayment)
              _buildSlipRow('QR Güvenlik Kodu:', '#$qrShortToken (48sn Dinamik)')
            else
              _buildSlipRow('Kart No:', maskedCard),
            _buildSlipRow('Müşteri:', customerName),
            _buildSlipRow(
              'Taksit / Vade:',
              isQrPayment
                  ? 'Tek Çekim (Anında Transfer)'
                  : (_selectedInstallment == 1
                        ? 'Tek Çekim'
                        : '$_selectedInstallment Taksit'),
            ),
            _buildSlipRow('Net Kasa Girişi:', _formatCurrency(netAmount)),
            _buildSlipRow('İşlem No:', tx.txId),
            _buildSlipRow(
              'Tarih & Saat:',
              '${tx.timestamp.day.toString().padLeft(2, '0')}.${tx.timestamp.month.toString().padLeft(2, '0')}.${tx.timestamp.year} '
              '${tx.timestamp.hour.toString().padLeft(2, '0')}:${tx.timestamp.minute.toString().padLeft(2, '0')}',
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

  void _showZReportBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Gün Sonu POS Hareketleri (Z-Raporu)',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkNavy,
                  ),
                ),
                const StatusBadgeWidget(
                  label: 'Canlı Kasa',
                  type: BadgeType.success,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Toplam $_todayTxCount İşlem • Brüt Ciro: ${_formatCurrency(_todayTotalAmount)}',
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _recentPosSlips.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                itemBuilder: (context, index) {
                  final item = _recentPosSlips[index];
                  final isQr = item.qrToken != null;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isQr
                            ? const Color(0xFFD1FAE5)
                            : const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isQr
                            ? Icons.qr_code_2_rounded
                            : Icons.credit_card_rounded,
                        color: isQr
                            ? const Color(0xFF065F46)
                            : const Color(0xFF0369A1),
                        size: 20,
                      ),
                    ),
                    title: Text(
                      item.customerName,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.darkNavy,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    subtitle: Text(
                      '${item.method} • ${item.installmentLabel}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: const Color(0xFF64748B),
                        fontSize: 11,
                      ),
                    ),
                    trailing: Text(
                      '+${_formatCurrency(item.amount)}',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkNavy,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Kapat'),
              ),
            ),
          ],
        ),
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
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
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

  @override
  Widget build(BuildContext context) {
    final double commission = _amount * 0.0139;
    final double netAmount = _amount - commission;
    final companyId =
        context.watch<AuthBloc>().state.user?.companyId ??
        'comp_techsolutions_01';
    final b2bQrPayload = _buildB2bPosQrPayload(companyId);
    final isLuhnOk = FinancialValidators.isLuhnValid(
      _cardNumberController.text,
    );

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
                          'Kart ile Çekim & PayPulse QR Tahsilat Merkezi',
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
                                fontWeight: FontWeight.w800,
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
                              Icons.qr_code_2_rounded,
                              size: 18,
                              color: !_isCardTab
                                  ? AppColors.primaryTeal
                                  : const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'PayPulse QR\nTahsilat (48sn)',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: !_isCardTab
                                    ? AppColors.darkNavy
                                    : const Color(0xFF64748B),
                                fontWeight: FontWeight.w800,
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

            // 1. Tahsil Edilecek Tutar Kartı (Ortak)
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
                      GestureDetector(
                        onTap: _showCustomAmountDialog,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1FAE5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '✎ Tutar Değiştir / ⚡ Anında Tahsilat',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: const Color(0xFF065F46),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _showCustomAmountDialog,
                    child: Center(
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
                          const SizedBox(width: 8),
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
                          onTap: () {
                            setState(() {
                              _amount = 3750.00;
                              _qrGenerationCount++;
                              _generateNewPosQrCode(resetTimer: true);
                            });
                            _startQrCountdownTimer();
                          },
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
                              '↺ Sıfırla (₺3.750)',
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
                  TextField(
                    controller: _descriptionController,
                    onChanged: (_) => setState(() {}),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.darkNavy,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      prefixIcon: const Icon(
                        Icons.description_outlined,
                        size: 16,
                        color: Color(0xFF64748B),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // SEKMELERE GÖRE İÇERİK: KREDİ KARTI VEYA PAYPULSE DİNAMİK QR
            if (_isCardTab)
              _buildCardCollectionSection(isLuhnOk: isLuhnOk)
            else
              _buildQrCollectionSection(b2bQrPayload: b2bQrPayload),

            const SizedBox(height: 14),

            // Komisyon (%1,39) ve Net Hesaba Geçecek Tutar Kartı
            Container(
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
                        _formatCurrency(commission),
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
                        '🏦  Net İşletme Kasasına Geçecek',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: const Color(0xFF475569),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatCurrency(netAmount),
                            style: AppTextStyles.headlineSmall.copyWith(
                              color: AppColors.primaryTeal,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            _isCardTab
                                ? 'Ertesi Gün 10:00 Transfer'
                                : 'PayPulse QR • Anında Kasada',
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
                    '🔒 3D Secure 2.0 & TCMB TR Karekod  •  256-Bit SSL Şifreleme',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: const Color(0xFF64748B),
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Ana Tahsilat Butonu (Seçili Sekmeye Göre Kart veya QR)
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
                onPressed: _isProcessing
                    ? null
                    : () => _handleCompletePayment(isQrPayment: !_isCardTab),
                icon: _isProcessing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        _isCardTab
                            ? Icons.lock_outline_rounded
                            : Icons.qr_code_scanner_rounded,
                        size: 18,
                      ),
                label: Text(
                  _isProcessing
                      ? 'POS Tahsilatı İşleniyor...'
                      : (_isCardTab
                            ? 'Kart ile Tahsilatı Tamamla (${_formatCurrency(_amount)})  →'
                            : 'PayPulse QR Ödemesini Onayla / Simüle Et (${_formatCurrency(_amount)})  →'),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Alternatif Ödeme Yöntemi Geçiş Butonu
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
                  setState(() {
                    _isCardTab = !_isCardTab;
                  });
                },
                icon: Icon(
                  _isCardTab
                      ? Icons.qr_code_2_rounded
                      : Icons.credit_card_rounded,
                  size: 18,
                  color: AppColors.primaryTeal,
                ),
                label: Text(
                  _isCardTab
                      ? 'PayPulse QR ile Müşteriye Ödet (48sn Dinamik QR)'
                      : 'Kredi / Banka Kartı ile Tahsilata Geç',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // BAŞARILI İŞLEM SİMÜLATÖRÜ PANELİ (Jüri & Kasa Test Merkezi)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.verified_rounded,
                        color: Color(0xFF065F46),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Kasa Başarılı İşlem Simülatörü (Hızlı Test)',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: const Color(0xFF065F46),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kasadan müşteri kredi kartı veya 48sn dinamik PayPulse QR ile başarılı tahsilatı tek tıkla simüle edin:',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: const Color(0xFF047857),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.darkNavy,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: Color(0xFF6EE7B7)),
                            ),
                          ),
                          onPressed: _isProcessing
                              ? null
                              : () =>
                                    _handleCompletePayment(isQrPayment: false),
                          icon: const Icon(
                            Icons.credit_card_rounded,
                            size: 15,
                            color: AppColors.primaryTeal,
                          ),
                          label: const Text(
                            'Kart Simüle Et',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF065F46),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _isProcessing
                              ? null
                              : () => _handleCompletePayment(isQrPayment: true),
                          icon: const Icon(Icons.qr_code_2_rounded, size: 16),
                          label: const Text(
                            'PayPulse QR Simüle Et',
                            style: TextStyle(
                              fontSize: 11.5,
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
            const SizedBox(height: 12),

            // Bugünkü POS İşlemleri / Z Raporu
            GestureDetector(
              onTap: _showZReportBottomSheet,
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
                            'Bugünkü POS İşlemleri (Kart & QR)',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.darkNavy,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '$_todayTxCount Adet • ${_formatCurrency(_todayTotalAmount)}',
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

  /// SEKME 1: KREDİ / BANKA KARTI İLE TAHSİLAT BÖLÜMÜ
  Widget _buildCardCollectionSection({required bool isLuhnOk}) {
    final installment3 = (_amount / 3).toStringAsFixed(2).replaceAll('.', ',');
    final installment6 = (_amount / 6).toStringAsFixed(2).replaceAll('.', ',');

    return Column(
      children: [
        // Koyu NOVA TASARIM POS Kart Önizlemesi
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.heroCardGradient,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors.darkNavy.withValues(alpha: 0.35),
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
                          color: const Color(0xFF5EEAD4).withValues(alpha: 0.7),
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
                      color: Colors.white.withValues(alpha: 0.1),
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
                    _getMaskedCardPreview(),
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
                        _cardHolderController.text.isEmpty
                            ? 'Mehmet Can Özkan'
                            : _cardHolderController.text,
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
                        _formatCurrency(_amount),
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

        // Kart Bilgileri Formu (Luhn Doğrulamalı)
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
                    'Müşteri Kart Bilgileri',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkNavy,
                    ),
                  ),
                  Text(
                    isLuhnOk ? '✓ Luhn Geçerli' : '✕ Luhn Kontrolü',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isLuhnOk
                          ? AppColors.primaryTeal
                          : AppColors.expenseRed,
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
              TextField(
                controller: _cardHolderController,
                onChanged: (_) => setState(() {}),
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkNavy,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Kart Numarası (16 Hane)',
                style: AppTextStyles.bodySmall.copyWith(
                  color: const Color(0xFF64748B),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                inputFormatters: [CardNumberInputFormatter()],
                onChanged: (_) => setState(() {}),
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkNavy,
                  letterSpacing: 1.0,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.all(12),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Center(
                      widthFactor: 1,
                      child: Text(
                        'MC/VISA',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
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
                        TextField(
                          controller: _expiryController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [ExpiryDateInputFormatter()],
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkNavy,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            contentPadding: const EdgeInsets.all(12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
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
                        TextField(
                          controller: _cvvController,
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          maxLength: 3,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkNavy,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            isDense: true,
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            contentPadding: const EdgeInsets.all(12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
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
                  _buildInstallmentBox(
                    'Tek Çekim',
                    _formatCurrency(_amount),
                    1,
                  ),
                  const SizedBox(width: 8),
                  _buildInstallmentBox('3 Taksit', '3x ₺$installment3', 3),
                  const SizedBox(width: 8),
                  _buildInstallmentBox('6 Taksit', '6x ₺$installment6', 6),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// SEKME 2: PAYPULSE DİNAMİK QR İLE KASADAN ÖDEME ALMA BÖLÜMÜ (48 Saniyede Yenilenen Gerçek QR)
  Widget _buildQrCollectionSection({required String b2bQrPayload}) {
    final progress = _remainingQrSeconds / _qrRefreshIntervalSeconds;
    final isUrgent = _remainingQrSeconds <= 10;
    final shortToken = _b2bQrToken.substring(_b2bQrToken.length - 8);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkNavy.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const StatusBadgeWidget(
                label: 'PayPulse POS • TR Karekod',
                type: BadgeType.success,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Kasa QR #$_qrGenerationCount',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.darkNavy,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Gerçek Dinamik POS QR Kodu (qr_flutter)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            child: Container(
              key: ValueKey<String>(b2bQrPayload),
              width: 230,
              height: 230,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isUrgent
                      ? AppColors.warningOrange
                      : AppColors.primaryTeal,
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryTeal.withValues(alpha: 0.14),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: QrImageView(
                data: b2bQrPayload,
                version: QrVersions.auto,
                size: 200,
                backgroundColor: Colors.white,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: AppColors.darkNavy,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: AppColors.darkNavy,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          Text(
            'Nova Tasarım Ltd. • Kasa Terminali (POS-TR-8492)',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.darkNavy,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Tahsilat Tutarı: ${_formatCurrency(_amount)}  •  Ref: #$shortToken',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.primaryTeal,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),

          // 48 Saniye Geri Sayım ve Otomatik Yenileme Göstergesi
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 16,
                      color: isUrgent
                          ? AppColors.expenseRed
                          : AppColors.primaryTeal,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Güvenlik için POS QR kodu ${_formatCountdown(_remainingQrSeconds)} saniye içinde yenilenir',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isUrgent
                              ? AppColors.expenseRed
                              : const Color(0xFF475569),
                          fontWeight: FontWeight.w700,
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isUrgent ? AppColors.expenseRed : AppColors.primaryTeal,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

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
                    setState(() {
                      _qrGenerationCount++;
                      _generateNewPosQrCode(resetTimer: true);
                    });
                    _startQrCountdownTimer();
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text(
                    'Yeni QR Üret (48sn)',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryTeal,
                    side: const BorderSide(color: AppColors.primaryTeal),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: b2bQrPayload));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: AppColors.primaryGreen,
                        content: Text(
                          'B2B POS QR tahsilat kodu panoya kopyalandı.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, size: 15),
                  label: const Text(
                    'QR Kodu Kopyala',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAddChip(String label, double addVal) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _amount += addVal;
          _qrGenerationCount++;
          _generateNewPosQrCode(resetTimer: true);
        });
        _startQrCountdownTimer();
      },
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

class _PosSlipEntry {
  final String txId;
  final String method;
  final String customerName;
  final double amount;
  final String installmentLabel;
  final DateTime timestamp;
  final String? qrToken;

  const _PosSlipEntry({
    required this.txId,
    required this.method,
    required this.customerName,
    required this.amount,
    required this.installmentLabel,
    required this.timestamp,
    this.qrToken,
  });
}
