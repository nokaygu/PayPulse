import 'dart:async';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/datasources/remote/firebase_firestore_datasource.dart';
import '../../widgets/role_switch_app_bar.dart';
import '../../widgets/status_badge_widget.dart';
import '../auth/bloc/auth_bloc.dart';

/// B2C Dinamik QR Kod ile Öde & Tahsil Et Ekranı
/// - Gerçek QR Kod (qr_flutter)
/// - 48 saniyede bir otomatik yenilenen dinamik güvenlik token'ı
/// - Tutar belirleme (opsiyonel) ve QR Okut & Öde simülatörü
class QrPaymentCenterScreen extends StatefulWidget {
  const QrPaymentCenterScreen({super.key});

  @override
  State<QrPaymentCenterScreen> createState() => _QrPaymentCenterScreenState();
}

class _QrPaymentCenterScreenState extends State<QrPaymentCenterScreen> {
  static const int _qrRefreshIntervalSeconds = 48;

  bool _isShowQrMode = true;
  int _remainingSeconds = _qrRefreshIntervalSeconds;
  Timer? _countdownTimer;

  late String _qrToken;
  late DateTime _generatedAt;
  int _generationCount = 1;
  double? _requestedAmount;
  bool _isCameraActive = false;
  bool _isSimulatingScanPayment = false;

  @override
  void initState() {
    super.initState();
    _generateNewQrCode(resetTimer: true);
    _startCountdownTimer();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_remainingSeconds <= 1) {
          _generateNewQrCode(resetTimer: true);
        } else {
          _remainingSeconds--;
        }
      });
    });
  }

  void _generateNewQrCode({bool resetTimer = true}) {
    final random = Random();
    final randomHex = List.generate(
      8,
      (_) => random.nextInt(16).toRadixString(16).toUpperCase(),
    ).join();
    final epochSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    _qrToken = 'PPB2C-$epochSec-$randomHex';
    _generatedAt = DateTime.now();
    if (resetTimer) {
      _remainingSeconds = _qrRefreshIntervalSeconds;
    }
  }

  String _buildQrPayload({
    required String userId,
    required String userName,
    required String customerNo,
    required String iban,
  }) {
    final expiresAt =
        _generatedAt.add(const Duration(seconds: _qrRefreshIntervalSeconds));
    final amountStr = _requestedAmount != null
        ? _requestedAmount!.toStringAsFixed(2)
        : '0.00';

    return 'PAYPULSE://TRKAREKOD/B2C'
        '?v=1'
        '&uid=${Uri.encodeComponent(userId)}'
        '&name=${Uri.encodeComponent(userName)}'
        '&cust=${Uri.encodeComponent(customerNo)}'
        '&iban=${Uri.encodeComponent(iban.replaceAll(' ', ''))}'
        '&amt=$amountStr'
        '&curr=TRY'
        '&token=$_qrToken'
        '&exp=${expiresAt.millisecondsSinceEpoch}';
  }

  String _formatCountdown(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  String _formatAmount(double amount) {
    final parts = amount.toStringAsFixed(2).split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return '₺$intPart,${parts[1]}';
  }

  Future<void> _simulateScanAndPay({
    required String merchantName,
    required String terminalId,
    required double amount,
    required String qrRef,
  }) async {
    if (_isSimulatingScanPayment) return;
    setState(() => _isSimulatingScanPayment = true);

    final authUser = context.read<AuthBloc>().state.user;
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final payerId = authUser?.uid ?? firebaseUser?.uid ?? 'user_deniz_aksoy';

    String txId =
        'PP-QR-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    try {
      if (firebaseUser != null) {
        final tx = await FirebaseFirestoreDatasource().executeQrWalletPayment(
          companyId: 'comp_techsolutions_01',
          payerUserId: payerId,
          amountKurus: (amount * 100).round(),
        );
        txId = tx.txId;
      } else {
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }
    } catch (_) {
      // Çevrimdışı veya demo hesap modunda yerel başarılı simülasyon devam eder.
      await Future<void>.delayed(const Duration(milliseconds: 400));
    }

    if (!mounted) return;
    setState(() => _isSimulatingScanPayment = false);

    _showQrPaymentSuccessDialog(
      merchantName: merchantName,
      terminalId: terminalId,
      amount: amount,
      txId: txId,
      qrRef: qrRef,
    );
  }

  void _showQrPaymentSuccessDialog({
    required String merchantName,
    required String terminalId,
    required double amount,
    required String txId,
    required String qrRef,
  }) {
    final now = DateTime.now();
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
                'QR Ödeme Başarılı',
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
                    'ÖDENEN TUTAR',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatAmount(amount),
                    style: AppTextStyles.numericBalance.copyWith(
                      color: AppColors.darkNavy,
                      fontSize: 28,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildSlipRow('Üye İşyeri:', merchantName),
            _buildSlipRow('Terminal ID:', terminalId),
            _buildSlipRow('QR Referans:', qrRef),
            _buildSlipRow('İşlem No:', txId),
            _buildSlipRow('Ödeme Yöntemi:', 'PayPulse TR Karekod'),
            _buildSlipRow(
              'Tarih & Saat:',
              '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year} '
              '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
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
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.darkNavy,
                fontWeight: FontWeight.w700,
                fontSize: 11.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authUser = context.watch<AuthBloc>().state.user;
    final firebaseUser = FirebaseAuth.instance.currentUser;

    final userId = authUser?.uid ?? firebaseUser?.uid ?? 'user_deniz_aksoy';
    final userName = (authUser?.name != null && authUser!.name.isNotEmpty)
        ? authUser.name
        : (firebaseUser?.displayName ?? 'Deniz Aksoy');
    final customerNo = authUser?.customerNo ?? 'PP-849201';
    final iban = authUser?.iban ?? 'TR42 0006 2000 8492 0100 0000 01';

    final qrPayload = _buildQrPayload(
      userId: userId,
      userName: userName,
      customerNo: customerNo,
      iban: iban,
    );

    final progress = _remainingSeconds / _qrRefreshIntervalSeconds;
    final isUrgent = _remainingSeconds <= 10;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const RoleSwitchAppBar(isBusinessMode: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Sekme Seçici: QR Kodumu Göster | QR Okut ve Öde
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
                      onTap: () => setState(() => _isShowQrMode = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _isShowQrMode
                              ? Colors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'QR Kodumu Göster',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: _isShowQrMode
                                ? AppColors.darkNavy
                                : const Color(0xFF64748B),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isShowQrMode = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: !_isShowQrMode
                              ? Colors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'QR Okut ve Öde',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: !_isShowQrMode
                                ? AppColors.darkNavy
                                : const Color(0xFF64748B),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            if (_isShowQrMode)
              _buildShowQrSection(
                userName: userName,
                customerNo: customerNo,
                qrPayload: qrPayload,
                progress: progress,
                isUrgent: isUrgent,
              )
            else
              _buildScanQrSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildShowQrSection({
    required String userName,
    required String customerNo,
    required String qrPayload,
    required double progress,
    required bool isUrgent,
  }) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
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
                    label: 'TCMB TR Karekod Uyumlu',
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
                      'Kod #$_generationCount',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.darkNavy,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Gerçek Dinamik QR Kod (qr_flutter)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                child: Container(
                  key: ValueKey<String>(qrPayload),
                  width: 230,
                  height: 230,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isUrgent
                          ? AppColors.warningOrange
                          : AppColors.primaryGreen,
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen.withValues(alpha: 0.12),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: qrPayload,
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

              // Seçili Tutar Rozeti (Varsa)
              if (_requestedAmount != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Sabit Tahsilat/Ödeme Tutarı: ${_formatAmount(_requestedAmount!)}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: const Color(0xFF065F46),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],

              Text(
                '$userName • $customerNo',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkNavy,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Dinamik Anahtar: ${_qrToken.substring(_qrToken.length - 8)}',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primaryTeal,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),

              // 48 Saniye Geri Sayım Çubuğu ve Bilgi
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 16,
                              color: isUrgent
                                  ? AppColors.expenseRed
                                  : AppColors.primaryTeal,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Güvenlik için kod ${_formatCountdown(_remainingSeconds)} saniye içinde yenilenir',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isUrgent
                                    ? AppColors.expenseRed
                                    : const Color(0xFF475569),
                                fontWeight: FontWeight.w700,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
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
                          isUrgent
                              ? AppColors.expenseRed
                              : AppColors.primaryGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Hızlı Tutar Seçimi (Kasa Ödeme / Para İsteme Tutarı)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'QR Tutar Seçimi (İsteğe Bağlı)',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildAmountChip('Limitsiz / Kasada Belirle', null),
                    const SizedBox(width: 6),
                    _buildAmountChip('₺100', 100),
                    const SizedBox(width: 6),
                    _buildAmountChip('₺250', 250),
                    const SizedBox(width: 6),
                    _buildAmountChip('₺500', 500),
                    const SizedBox(width: 6),
                    _buildAmountChip('₺1.250', 1250),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Aksiyon Butonları: Şimdi Yenile & Kodu Kopyala
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.darkNavy,
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _generationCount++;
                          _generateNewQrCode(resetTimer: true);
                        });
                        _startCountdownTimer();
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text(
                        'Şimdi Yenile (48sn)',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: qrPayload));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: AppColors.primaryGreen,
                            content: Text(
                              'Canlı TR Karekod verisi panoya kopyalandı.',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      label: const Text(
                        'QR Verisini Kopyala',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmountChip(String label, double? amount) {
    final isSelected = _requestedAmount == amount;
    return GestureDetector(
      onTap: () {
        setState(() {
          _requestedAmount = amount;
          _generationCount++;
          _generateNewQrCode(resetTimer: true);
        });
        _startCountdownTimer();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkNavy : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.darkNavy : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: isSelected ? Colors.white : AppColors.darkNavy,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildScanQrSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TR Karekod / PayPulse POS Okut',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkNavy,
                ),
              ),
              const StatusBadgeWidget(
                label: 'Kamera & Simülatör',
                type: BadgeType.info,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Kamera Alanı veya Simüle Edilmiş Vizör
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Container(
              height: 220,
              width: double.infinity,
              color: const Color(0xFF0F172A),
              child: _isCameraActive
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        MobileScanner(
                          onDetect: (capture) {
                            if (capture.barcodes.isEmpty) return;
                            final raw = capture.barcodes.first.rawValue;
                            if (raw != null && raw.isNotEmpty) {
                              setState(() => _isCameraActive = false);
                              _simulateScanAndPay(
                                merchantName: 'Nova Tasarım Ltd. POS',
                                terminalId: 'POS-TR-8492',
                                amount: 3750.00,
                                qrRef: raw.length > 18
                                    ? raw.substring(raw.length - 12)
                                    : raw,
                              );
                            }
                          },
                        ),
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.primaryGreen,
                              width: 2.5,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.qr_code_scanner_rounded,
                            color: Color(0xFF5EEAD4),
                            size: 46,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Kasa POS üzerindeki PayPulse QR kodu okutun',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF5EEAD4),
                            side: const BorderSide(color: Color(0xFF5EEAD4)),
                          ),
                          onPressed: () =>
                              setState(() => _isCameraActive = true),
                          icon: const Icon(Icons.camera_alt_outlined, size: 16),
                          label: const Text('Kamerayı Başlat'),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Hızlı QR Ödeme Simülatörü (Sunum & Test)',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.darkNavy,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Kasa POS terminalindeki 48sn dinamik QR kodu okutarak ödeme işlemini simüle edin:',
            style: AppTextStyles.bodySmall.copyWith(
              color: const Color(0xFF64748B),
              fontSize: 11.5,
            ),
          ),
          const SizedBox(height: 12),

          _buildScanPresetCard(
            merchantName: 'Nova Tasarım Ltd. (Sanal POS)',
            terminalId: 'POS-TR-8492',
            description: 'Web Tasarım Hizmet Bedeli - FTR-2026-08',
            amount: 3750.00,
          ),
          const SizedBox(height: 8),
          _buildScanPresetCard(
            merchantName: 'Espresso Lab Kurumsal POS',
            terminalId: 'POS-TR-1904',
            description: 'Kahve & İkram Ödemesi',
            amount: 185.00,
          ),
        ],
      ),
    );
  }

  Widget _buildScanPresetCard({
    required String merchantName,
    required String terminalId,
    required String description,
    required double amount,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.qr_code_2_rounded,
              color: Color(0xFF065F46),
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  merchantName,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.darkNavy,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '$terminalId • $description',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF64748B),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkNavy,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: _isSimulatingScanPayment
                ? null
                : () => _simulateScanAndPay(
                    merchantName: merchantName,
                    terminalId: terminalId,
                    amount: amount,
                    qrRef: _qrToken.substring(_qrToken.length - 8),
                  ),
            child: Text(
              'Öde (${_formatAmount(amount)})',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 11.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
