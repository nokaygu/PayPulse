import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_mode.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/firestore_seeder.dart';
import '../../../data/datasources/remote/firebase_firestore_datasource.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/wallet_model.dart';
import '../../widgets/role_switch_app_bar.dart';
import '../../widgets/transaction_list_tile_widget.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_event.dart';
import 'home.dart';

/// B2C Ana Cüzdan Ekranı
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _hideBalance = false;
  String _selectedCurrency = 'TRY';
  final FirebaseFirestoreDatasource _firestoreDatasource =
      FirebaseFirestoreDatasource();

  String _formatKurus(int kurus, String symbol) {
    final double amount = kurus / 100.0;
    final parts = amount.toStringAsFixed(2).split('.');
    final integerPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return '$symbol$integerPart,${parts[1]}';
  }

  @override
  Widget build(BuildContext context) {
    final authUser = context.watch<AuthBloc>().state.user;
    final firebaseUser =
        AppMode.isDemoMode ? null : FirebaseAuth.instance.currentUser;
    final String currentUserId =
        authUser?.uid ?? firebaseUser?.uid ?? 'user_deniz_aksoy';
    final String currentUserName =
        (authUser?.name != null && authUser!.name.isNotEmpty)
            ? authUser.name
            : (firebaseUser?.displayName ??
                (firebaseUser?.email?.split('@').first ?? 'Deniz Aksoy'));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const RoleSwitchAppBar(isBusinessMode: false),
      body: StreamBuilder<WalletModel?>(
        stream: _firestoreDatasource.watchUserWallet(currentUserId),
        builder: (context, walletSnapshot) {
          final isDemoUser = currentUserId == 'user_deniz_aksoy' ||
              authUser?.uid == 'user_deniz_aksoy' ||
              currentUserId.startsWith('demo_');

          final wallet = walletSnapshot.data;
          final String ibanStr =
              wallet?.iban ?? (authUser?.iban ?? 'TR42 0006 2000 8492 0100 0000 01');

          final String balanceStr;
          if (_selectedCurrency == 'TRY') {
            balanceStr = wallet != null
                ? _formatKurus(wallet.balanceTl, '₺')
                : (_hideBalance ? '••••••' : '₺0,00');
          } else if (_selectedCurrency == 'USD') {
            balanceStr = wallet != null
                ? _formatKurus(wallet.balanceUsd, r'$')
                : (_hideBalance ? '••••••' : r'$0,00');
          } else {
            balanceStr = wallet != null
                ? _formatKurus(wallet.balanceEur, '€')
                : (_hideBalance ? '••••••' : '€0,00');
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Üst Rol Geçiş & Profil Bandı
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE).withOpacity(0.55),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBAE6FD)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryTeal,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '$currentUserName • ${wallet?.walletId ?? 'PP-849201'}',
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.darkNavy,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          context.read<AuthBloc>().add(
                                const AuthRoleChanged('admin'),
                              );
                          context.go(AppRoutes.businessOverview);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.business_center_outlined,
                                size: 13,
                                color: AppColors.primaryTeal,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'İşletme Paneline Geç',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.darkNavy,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 1. Çoklu Para Birimli Ana Cüzdan Kartı
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
                              _buildCurrencyChip('TRY'),
                              const SizedBox(width: 6),
                              _buildCurrencyChip('USD'),
                              const SizedBox(width: 6),
                              _buildCurrencyChip('EUR'),
                            ],
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            onPressed: () =>
                                setState(() => _hideBalance = !_hideBalance),
                            icon: Icon(
                              _hideBalance
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: const Color(0xFF5EEAD4),
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'KULLANILABİLİR CÜZDAN BAKİYESİ',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 0.7,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _hideBalance ? '₺ ••••••' : balanceStr,
                        style: AppTextStyles.numericBalance.copyWith(
                          color: Colors.white,
                          fontSize: 34,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                ibanStr,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontFamily: 'monospace',
                                  fontSize: 10.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(
                                  ClipboardData(text: ibanStr),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('FAST IBAN kopyalandı.'),
                                  ),
                                );
                              },
                              child: const Icon(
                                Icons.copy_rounded,
                                size: 15,
                                color: Color(0xFF5EEAD4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5EEAD4),
                                foregroundColor: AppColors.darkNavy,
                                minimumSize: const Size(0, 44),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () =>
                                  context.push(AppRoutes.fastTransfer),
                              icon: const Icon(Icons.bolt_rounded, size: 18),
                              label: const Text(
                                'FAST Gönder',
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.white.withOpacity(0.08),
                                side: BorderSide(
                                  color: Colors.white.withOpacity(0.18),
                                ),
                                minimumSize: const Size(0, 44),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => context.go(AppRoutes.qr),
                              icon: const Icon(Icons.qr_code_rounded, size: 18),
                              label: const Text(
                                'QR ile Öde',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // 2. Canlı Cüzdan Hareketleri
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Son Cüzdan Hareketleri',
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkNavy,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => context.go(AppRoutes.transactions),
                      child: Text(
                        'Tümünü Gör >',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primaryTeal,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: StreamBuilder<List<TransactionModel>>(
                    stream: _firestoreDatasource
                        .watchUserTransactions(currentUserId),
                    builder: (context, txSnapshot) {
                      if (txSnapshot.connectionState ==
                              ConnectionState.waiting &&
                          !txSnapshot.hasData) {
                        return const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryTeal,
                            ),
                          ),
                        );
                      }

                      var transactions = txSnapshot.data ?? [];
                      if (transactions.isEmpty && isDemoUser) {
                        transactions = FirestoreSeeder.mockTransactions;
                      }
                      if (transactions.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 24,
                            horizontal: 16,
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.receipt_long_outlined,
                                  size: 36,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Henüz kayıtlı cüzdan hareketi bulunmuyor.',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final recentTxs = transactions.take(3).toList();
                      return Column(
                        children: [
                          for (int i = 0; i < recentTxs.length; i++) ...[
                            if (i > 0)
                              const Divider(
                                height: 1,
                                color: Color(0xFFF1F5F9),
                              ),
                            _buildTransactionTile(recentTxs[i]),
                          ],
                        ],
                      );
                    },
                  ),
                ),

                // 3. Jüri Sunumu Firestore Seed & Canlı Test Paneli Butonu (Geliştirici & Demo)
                if (kDebugMode) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.cloud_upload_outlined,
                          color: AppColors.primaryTeal,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kasım 2026 Verilerini Firestore\'a Bas',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: AppColors.darkNavy,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                'Jüri sunumu için tüm koleksiyonları tek tıkla doldur veya Firebase konsolunu aç.',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: const Color(0xFF64748B),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkNavy,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 36),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          onPressed: () async {
                            try {
                              await FirestoreSeeder().seedAll();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: AppColors.primaryGreen,
                                    content: Text(
                                      'Kasım 2026 Seed verileri Cloud Firestore\'a başarıyla basıldı!',
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('Yerel Mock veriler aktif ($e)'),
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text(
                            'Seed Bas',
                            style: TextStyle(fontSize: 11.5),
                          ),
                        ),
                        const SizedBox(width: 6),
                        IconButton(
                          tooltip: 'Firebase Test Konsolu',
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const HomeAndWalletEkrani(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.developer_mode_rounded,
                            size: 20,
                            color: AppColors.darkNavy,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionTile(TransactionModel tx) {
    final bool isIncome = !tx.isExpense;
    final String amountFormatted = isIncome
        ? '+${_formatKurus(tx.amount, '₺')}'
        : '-${_formatKurus(tx.amount, '₺')}';

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

  Widget _buildCurrencyChip(String curr) {
    final bool isSelected = _selectedCurrency == curr;
    return GestureDetector(
      onTap: () => setState(() => _selectedCurrency = curr),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF5EEAD4)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          curr,
          style: AppTextStyles.labelSmall.copyWith(
            color: isSelected ? AppColors.darkNavy : Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

/// Görsel 9: B2B İşletme Paneli • Genel Bakış Ekranı (Nova Tasarım Ltd. - ₺245.800,00)
class BusinessSafeOverviewScreen extends StatelessWidget {
  const BusinessSafeOverviewScreen({super.key});

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
            // Üst Şerit: VKN + Kişisel Cüzdana Dön
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE).withOpacity(0.55),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBAE6FD)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryTeal,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Nova Ta... • VKN: 6320984112',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.darkNavy,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      context.read<AuthBloc>().add(
                        const AuthRoleChanged('employee'),
                      );
                      context.go(AppRoutes.home);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.swap_horiz_rounded,
                            size: 14,
                            color: AppColors.primaryTeal,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Kişisel Cüzdana Dön',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.darkNavy,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 1. Kullanılabilir İşletme Bakiyesi Hero Kartı (₺245.800,00 TRY)
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
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet_outlined,
                              color: Color(0xFF5EEAD4),
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'KULLANILABİLİR İŞLETME\nBAKİYESİ',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: const Color(0xFF94A3B8),
                              letterSpacing: 0.6,
                              height: 1.15,
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
                          '● Aktif\nHesap',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: const Color(0xFF5EEAD4),
                            fontSize: 9.5,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '₺245.800,00',
                        style: AppTextStyles.numericBalance.copyWith(
                          color: Colors.white,
                          fontSize: 32,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'TRY',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ana Ticari IBAN',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: const Color(0xFF94A3B8),
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                'TR89 0006 2000 0001 9845 2...',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontFamily: 'monospace',
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
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '📋 Kopyala',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5EEAD4),
                            foregroundColor: AppColors.darkNavy,
                            minimumSize: const Size(0, 42),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {},
                          icon: const Icon(Icons.output_rounded, size: 16),
                          label: const Text(
                            'Hesaba Aktar',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
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
                          onPressed: () {},
                          icon: const Icon(Icons.add_circle_outline, size: 16),
                          label: const Text(
                            'Bakiye Yükle',
                            style: TextStyle(
                              fontSize: 12.5,
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
            const SizedBox(height: 16),

            // 2. 2x2 Ciro ve Bloke Metrik Kartları
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.trending_up_rounded,
                    badge: '+%18',
                    badgeIsGreen: true,
                    title: 'Bugünkü Tahsilat',
                    amount: '₺84.560,00',
                    subtitle: "Dün'e kıyasla artışta",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.calendar_month_outlined,
                    badge: '+%24',
                    badgeIsGreen: true,
                    title: 'Bu Ayki Ciro',
                    amount: '₺1.240.500',
                    subtitle: 'Geçen aya göre',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.lock_clock_outlined,
                    badge: 'Ertesi Gün',
                    badgeIsGreen: false,
                    title: 'Bekleyen Bloke',
                    amount: '₺18.450,00',
                    subtitle: "Yarın 09:00'da serbest",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.percent_rounded,
                    badge: '%1,39 Ort.',
                    badgeIsGreen: false,
                    title: 'Komisyon Kesintisi',
                    amount: '₺1.690,00',
                    subtitle: '34 işlem üzerinden',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // 3. Hızlı İşlemler (2x2 Grid)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hızlı İşlemler',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkNavy,
                  ),
                ),
                Text(
                  'Özelleştir',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primaryTeal,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionBox(
                    icon: Icons.point_of_sale_rounded,
                    badgeText: 'ÖNE ÇIKAN',
                    badgeBg: const Color(0xFF065F46),
                    badgeFg: Colors.white,
                    title: 'POS ile Tahsilat',
                    subtitle: 'Sanal ve Temassız POS',
                    isHighlighted: true,
                    onTap: () => context.go(AppRoutes.businessPos),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildQuickActionBox(
                    icon: Icons.document_scanner_outlined,
                    badgeText: 'Akıllı OCR',
                    badgeBg: const Color(0xFFE0F2FE),
                    badgeFg: AppColors.darkNavy,
                    title: 'Fatura Tara',
                    subtitle: 'Gider fişini anında işle',
                    isHighlighted: false,
                    onTap: () => context.push(AppRoutes.businessOcrScan),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionBox(
                    icon: Icons.fact_check_outlined,
                    badgeText: '● 3 Bekleyen',
                    badgeBg: const Color(0xFFFEE2E2),
                    badgeFg: const Color(0xFFDC2626),
                    title: 'Masraf Onayları',
                    subtitle: 'Personel harcamaları',
                    isHighlighted: false,
                    onTap: () => context.go(AppRoutes.businessExpenses),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildQuickActionBox(
                    icon: Icons.link_rounded,
                    badgeText: '→',
                    badgeBg: const Color(0xFFF1F5F9),
                    badgeFg: AppColors.darkNavy,
                    title: 'Ödeme Linki',
                    subtitle: 'WhatsApp & SMS Paylaş',
                    isHighlighted: false,
                    onTap: () => context.push('/pay/LNK-4402'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // 4. Ciro ve Tahsilat Trendi Kartı
            Container(
              padding: const EdgeInsets.all(18),
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ciro ve Tahsilat\nTrendi',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkNavy,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Kasım 2026 Dönemi',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: const Color(0xFF64748B),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            _buildSmallToggle('Günlük', false),
                            _buildSmallToggle('Haftalık', false),
                            _buildSmallToggle('Aylık', true),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 130,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildCiroBar('1. Hf', 0.65, false),
                        const SizedBox(width: 12),
                        _buildCiroBar('2. Hf', 0.72, false),
                        const SizedBox(width: 12),
                        _buildCiroBar('3. Hf', 0.85, true, topTag: '₺340k'),
                        const SizedBox(width: 12),
                        _buildCiroBar('4. Hf', 0.75, false),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '↗ En yüksek tahsilat: 3. Hafta (Kurumsal Proje Ödemeleri)',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.darkNavy,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go(AppRoutes.businessReports),
                          child: Text(
                            'Raporu\nAç',
                            textAlign: TextAlign.right,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primaryTeal,
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // 5. Son Tahsilat ve Hareketler
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Son Tahsilat ve Hareketler',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkNavy,
                      ),
                    ),
                    Text(
                      'Canlı akış • Bugün (11.11.2026)',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: const Color(0xFF64748B),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Tümünü Gör',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primaryTeal,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  const TransactionListTileWidget(
                    title: 'Artisan Kahve',
                    badgeText: 'Başarılı',
                    badgeBgColor: Color(0xFFD1FAE5),
                    badgeTextColor: Color(0xFF065F46),
                    subtitle: 'POS (Mastercard •••• 4120) • 10:42',
                    amountText: '+₺14.200,00',
                    isIncome: true,
                    statusOrNoteText: 'ID: #POS-9812',
                    icon: Icons.contactless_outlined,
                    iconBgColor: Color(0xFFD1FAE5),
                    iconColor: AppColors.primaryTeal,
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const TransactionListTileWidget(
                    title: 'Mimar Selin T.',
                    badgeText: 'FAST',
                    badgeBgColor: Color(0xFFE0F2FE),
                    badgeTextColor: Color(0xFF0369A1),
                    subtitle: 'Ödeme Linki Tahsilatı • 09:15',
                    amountText: '+₺8.500,00',
                    isIncome: true,
                    statusOrNoteText: 'ID: #LNK-4402',
                    icon: Icons.link_rounded,
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const TransactionListTileWidget(
                    title: 'Ahmet Yılmaz',
                    badgeText: 'Onay Bekliyor',
                    badgeBgColor: Color(0xFFE0F2FE),
                    badgeTextColor: AppColors.darkNavy,
                    subtitle: 'Masraf: Taksi / Ulaşım • 08:40',
                    amountText: '₺450,00',
                    isIncome: false,
                    statusOrNoteText: 'Fiş No: 881',
                    icon: Icons.receipt_long_outlined,
                    iconBgColor: AppColors.darkNavy,
                    iconColor: Colors.white,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 36),
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            onPressed: () =>
                                context.go(AppRoutes.businessExpenses),
                            child: const Text(
                              '👁️ Fişi İncele',
                              style: TextStyle(fontSize: 11.5),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F766E),
                              foregroundColor: Colors.white,
                              minimumSize: const Size(0, 36),
                            ),
                            onPressed: () =>
                                context.go(AppRoutes.businessExpenses),
                            child: const Text(
                              '✓ Onayla',
                              style: TextStyle(fontSize: 11.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const TransactionListTileWidget(
                    title: 'Delta Tedarik A.Ş.',
                    badgeText: 'İade',
                    badgeBgColor: Color(0xFFFEE2E2),
                    badgeTextColor: Color(0xFFB91C1C),
                    subtitle: 'İptal / İade İşlemi • 08:10',
                    amountText: '-₺1.250,00',
                    isIncome: false,
                    statusOrNoteText: 'ID: #REF-1092',
                    icon: Icons.replay_rounded,
                    iconBgColor: Color(0xFFFEE2E2),
                    iconColor: Color(0xFFB91C1C),
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

  Widget _buildMetricCard({
    required IconData icon,
    required String badge,
    required bool badgeIsGreen,
    required String title,
    required String amount,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: AppColors.darkNavy),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeIsGreen
                      ? const Color(0xFFD1FAE5)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: badgeIsGreen
                        ? const Color(0xFF065F46)
                        : const Color(0xFF475569),
                    fontSize: 9.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: const Color(0xFF64748B),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            amount,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.darkNavy,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: const Color(0xFF94A3B8),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionBox({
    required IconData icon,
    required String badgeText,
    required Color badgeBg,
    required Color badgeFg,
    required String title,
    required String subtitle,
    required bool isHighlighted,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isHighlighted
              ? const Color(0xFFCCFBF1).withOpacity(0.55)
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isHighlighted
                ? const Color(0xFF5EEAD4)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isHighlighted
                        ? const Color(0xFF0F766E)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: isHighlighted ? Colors.white : AppColors.darkNavy,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badgeText,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: badgeFg,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.darkNavy,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFF64748B),
                fontSize: 10.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallToggle(String text, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelSmall.copyWith(
          color: active ? AppColors.darkNavy : const Color(0xFF64748B),
          fontSize: 9.5,
        ),
      ),
    );
  }

  Widget _buildCiroBar(
    String label,
    double factor,
    bool isHighlighted, {
    String? topTag,
  }) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (topTag != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                topTag,
                style: AppTextStyles.labelSmall.copyWith(
                  color: const Color(0xFF0F766E),
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                ),
              ),
            ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: factor,
                widthFactor: 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: isHighlighted
                        ? const Color(0xFF0F766E)
                        : const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: isHighlighted
                  ? AppColors.darkNavy
                  : const Color(0xFF64748B),
              fontWeight: isHighlighted ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
