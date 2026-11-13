import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../widgets/role_switch_app_bar.dart';
import '../../widgets/status_badge_widget.dart';

/// Kart Modeli
class CardItem {
  final String id;
  final String title;
  final String cardNumber;
  final String expiry;
  final String cvv;
  String limit;
  final String holder;
  final bool isVirtual;
  final String cardType;
  final String linkedAccount;
  final LinearGradient gradient;
  bool isFrozen;
  bool isDefault;
  bool allowOnline;
  bool allowInternational;
  bool allowContactless;

  CardItem({
    required this.id,
    required this.title,
    required this.cardNumber,
    required this.expiry,
    required this.cvv,
    required this.limit,
    required this.holder,
    required this.isVirtual,
    this.cardType = 'Sanal Kart',
    this.linkedAccount = 'PayPulse FAST Cüzdanı',
    this.gradient = AppColors.heroCardGradient,
    this.isFrozen = false,
    this.isDefault = false,
    this.allowOnline = true,
    this.allowInternational = true,
    this.allowContactless = true,
  });
}

/// Banka Hesabı Modeli
class BankAccountItem {
  final String id;
  final String bankName;
  final String accountType;
  final String iban;
  final String balance;
  final IconData icon;
  final Color iconColor;
  bool isDefault;

  BankAccountItem({
    required this.id,
    required this.bankName,
    required this.accountType,
    required this.iban,
    required this.balance,
    required this.icon,
    required this.iconColor,
    this.isDefault = false,
  });
}

/// Kayıtlı Banka ve Sanal/Fiziksel Kartlar Yönetim Ekranı
class CardsManagementScreen extends StatefulWidget {
  const CardsManagementScreen({super.key});

  @override
  State<CardsManagementScreen> createState() => _CardsManagementScreenState();
}

class _CardsManagementScreenState extends State<CardsManagementScreen> {
  int _currentCardIndex = 0;
  bool _showCardDetails = false;
  late final PageController _pageController;

  // Kart Listesi
  late final List<CardItem> _cards;

  // Banka Hesapları Listesi
  late final List<BankAccountItem> _bankAccounts;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _cards = [
      CardItem(
        id: 'card_1',
        title: 'PAYPULSE VIRTUAL PREPAID',
        cardNumber: '5400 8812 4319 4829',
        expiry: '08/28',
        cvv: '391',
        limit: '₺15.000,00',
        holder: 'DENİZ AKSOY',
        isVirtual: true,
        cardType: 'Sanal Kart',
        linkedAccount: 'PayPulse TRY FAST Cüzdanı',
        gradient: AppColors.heroCardGradient,
        isDefault: true,
      ),
      CardItem(
        id: 'card_2',
        title: 'PAYPULSE BLACK METAL CARD',
        cardNumber: '5124 9901 2234 9012',
        expiry: '11/29',
        cvv: '814',
        limit: '₺100.000,00',
        holder: 'DENİZ AKSOY',
        isVirtual: false,
        cardType: 'Metal Kart',
        linkedAccount: 'Garanti BBVA Vadesiz TRY',
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
        ),
        isDefault: false,
      ),
      CardItem(
        id: 'card_3',
        title: 'PAYPULSE CORPORATE & TRAVEL',
        cardNumber: '4532 1084 7762 7741',
        expiry: '03/27',
        cvv: '520',
        limit: '₺35.000,00',
        holder: 'DENİZ AKSOY',
        isVirtual: true,
        cardType: 'Ticari Ek Kart',
        linkedAccount: 'Türkiye İş Bankası TRY',
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A8A), Color(0xFF0284C7)],
        ),
        isDefault: false,
      ),
    ];

    _bankAccounts = [
      BankAccountItem(
        id: 'bank_1',
        bankName: 'Garanti BBVA Vadesiz TRY',
        accountType: 'Bireysel FAST Hesabı',
        iban: 'TR56 0006 2000 0001 5500 01',
        balance: '₺48.250,00',
        icon: Icons.account_balance_rounded,
        iconColor: const Color(0xFF10B981),
        isDefault: true,
      ),
      BankAccountItem(
        id: 'bank_2',
        bankName: 'Türkiye İş Bankası TRY',
        accountType: 'Maaş ve Birikim Hesabı',
        iban: 'TR12 0006 4000 0002 8821 02',
        balance: '₺12.400,00',
        icon: Icons.account_balance_rounded,
        iconColor: const Color(0xFF0D9488),
        isDefault: false,
      ),
      BankAccountItem(
        id: 'bank_3',
        bankName: 'QNB Finansbank TRY',
        accountType: 'Esnek Vadeli Hesap',
        iban: 'TR88 0011 1000 0003 3342 03',
        balance: '₺9.800,00',
        icon: Icons.account_balance_rounded,
        iconColor: const Color(0xFF6366F1),
        isDefault: false,
      ),
      BankAccountItem(
        id: 'bank_4',
        bankName: 'Yapı Kredi Bankası TRY',
        accountType: 'İkincil Transfer Hesabı',
        iban: 'TR44 0006 7000 0004 1190 04',
        balance: '₺5.600,00',
        icon: Icons.account_balance_rounded,
        iconColor: const Color(0xFFF59E0B),
        isDefault: false,
      ),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _switchDefaultAccount(BankAccountItem selectedAccount) {
    setState(() {
      for (final acc in _bankAccounts) {
        acc.isDefault = (acc.id == selectedAccount.id);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${selectedAccount.bankName} varsayılan FAST transfer hesabı olarak seçildi.',
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.primaryTeal,
      ),
    );
  }

  void _switchDefaultCard(CardItem selectedCard) {
    setState(() {
      for (final card in _cards) {
        card.isDefault = (card.id == selectedCard.id);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${selectedCard.title} varsayılan ödeme kartı olarak belirlendi.',
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.primaryTeal,
      ),
    );
  }

  void _toggleFreezeCard(CardItem card) {
    setState(() {
      card.isFrozen = !card.isFrozen;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          card.isFrozen
              ? '${card.title} geçici olarak donduruldu.'
              : '${card.title} kullanıma açıldı.',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final primaryTextColor = isDark ? Colors.white : AppColors.darkNavy;
    final secondaryTextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final currentCard = _cards[_currentCardIndex];

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: const RoleSwitchAppBar(
        isBusinessMode: false,
        showBackButton: true,
        customTitle: 'Kayıtlı Banka ve Kartlarım',
        customSubtitle: 'Fiziksel & Sanal Kart Yönetimi',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kart Seçim Başlığı ve Yeni Kart Ekle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'KARTLARIM (${_cards.length})',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: secondaryTextColor,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                TextButton.icon(
                  onPressed: _showAddNewCardSheet,
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
                  label: const Text('Yeni Kart Ekle'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryTeal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Kart Swipe / PageView Carousel
            SizedBox(
              height: 215,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _cards.length,
                onPageChanged: (idx) {
                  setState(() => _currentCardIndex = idx);
                },
                itemBuilder: (ctx, idx) {
                  final card = _cards[idx];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _buildCardView(card),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Kart Sayfa Göstergeleri (Dots)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_cards.length, (index) {
                final isSelected = index == _currentCardIndex;
                return GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isSelected ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryTeal
                          : (isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 14),

            // Seçili Kart İşlem Butonları (Varsayılan Yap, Dondur, Bilgileri Göster)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cardBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        side: BorderSide(
                          color: currentCard.isDefault
                              ? AppColors.primaryTeal
                              : (isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
                        ),
                        backgroundColor: currentCard.isDefault
                            ? AppColors.primaryTeal.withValues(alpha: 0.1)
                            : Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: currentCard.isDefault
                          ? null
                          : () => _switchDefaultCard(currentCard),
                      icon: Icon(
                        currentCard.isDefault
                            ? Icons.check_circle_rounded
                            : Icons.star_border_rounded,
                        size: 16,
                        color: currentCard.isDefault
                            ? AppColors.primaryTeal
                            : secondaryTextColor,
                      ),
                      label: Text(
                        currentCard.isDefault ? 'Varsayılan Kart' : 'Varsayılan Yap',
                        style: TextStyle(
                          color: currentCard.isDefault
                              ? AppColors.primaryTeal
                              : primaryTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        side: BorderSide(
                          color: currentCard.isFrozen
                              ? const Color(0xFFDC2626)
                              : (isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => _toggleFreezeCard(currentCard),
                      icon: Icon(
                        currentCard.isFrozen
                            ? Icons.lock_open_rounded
                            : Icons.lock_outline_rounded,
                        size: 16,
                        color: currentCard.isFrozen
                            ? const Color(0xFFDC2626)
                            : secondaryTextColor,
                      ),
                      label: Text(
                        currentCard.isFrozen ? 'Kartı Aç' : 'Dondur',
                        style: TextStyle(
                          color: currentCard.isFrozen
                              ? const Color(0xFFDC2626)
                              : primaryTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      setState(() => _showCardDetails = !_showCardDetails);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _showCardDetails
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 18,
                        color: primaryTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // KAYITLI BANKA HESAPLARI BAŞLIĞI VE GEÇİŞ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'KAYITLI BANKA HESAPLARI (FAST)',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: secondaryTextColor,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                TextButton.icon(
                  onPressed: _showAddNewBankSheet,
                  icon: const Icon(Icons.account_balance_outlined, size: 16),
                  label: const Text('Yeni Hesap Ekle'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryTeal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Aktif transfer hesabı olarak kullanmak istediğiniz bankaya dokunun.',
              style: AppTextStyles.bodySmall.copyWith(
                color: secondaryTextColor,
                fontSize: 11.5,
              ),
            ),
            const SizedBox(height: 10),

            // Banka Hesapları Listesi (Tıklanarak Hesaplar Arasında Geçiş Yapılır)
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: cardBorder),
              ),
              child: Column(
                children: List.generate(_bankAccounts.length, (index) {
                  final account = _bankAccounts[index];
                  final isLast = index == _bankAccounts.length - 1;
                  return Column(
                    children: [
                      InkWell(
                        onTap: () => _switchDefaultAccount(account),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: account.isDefault
                                ? AppColors.primaryTeal.withValues(alpha: isDark ? 0.15 : 0.08)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: account.iconColor.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  account.icon,
                                  color: account.iconColor,
                                  size: 22,
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
                                          account.bankName,
                                          style: AppTextStyles.bodyMedium.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: primaryTextColor,
                                          ),
                                        ),
                                        if (account.isDefault) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFD1FAE5),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: const Text(
                                              'Varsayılan',
                                              style: TextStyle(
                                                color: Color(0xFF065F46),
                                                fontSize: 9.5,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      account.iban,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: secondaryTextColor,
                                        fontSize: 11,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Bakiye: ${account.balance}',
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: AppColors.primaryGreen,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Seçim Durumu Radyo / İkon
                              Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: account.isDefault
                                      ? AppColors.primaryTeal
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: account.isDefault
                                        ? AppColors.primaryTeal
                                        : (isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
                                    width: 2,
                                  ),
                                ),
                                child: account.isDefault
                                    ? const Icon(
                                        Icons.check_rounded,
                                        size: 16,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (!isLast)
                        Divider(
                          height: 1,
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                        ),
                    ],
                  );
                }),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Kart Önizleme Widget'ı
  Widget _buildCardView(CardItem card) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        gradient: card.isFrozen
            ? const LinearGradient(
                colors: [Color(0xFF334155), Color(0xFF475569)],
              )
            : card.gradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        card.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 0.8,
                          fontSize: 10.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        card.cardType,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusBadgeWidget(
                label: card.isFrozen
                    ? 'Donduruldu'
                    : (card.isDefault ? 'Varsayılan' : 'Aktif'),
                type: card.isFrozen ? BadgeType.error : BadgeType.darkGlass,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _showCardDetails
                        ? card.cardNumber
                        : '${card.cardNumber.substring(0, 4)} •••• •••• ${card.cardNumber.substring(card.cardNumber.length - 4)}',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: Colors.white,
                      letterSpacing: 1.8,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              if (_showCardDetails) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2.5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'CVV: ${card.cvv}',
                    style: const TextStyle(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KART SAHİBİ',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: const Color(0xFF94A3B8),
                        fontSize: 8.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      card.holder,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'S.K.T',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: const Color(0xFF94A3B8),
                      fontSize: 8.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    card.expiry,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 6),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'AYLIK LİMİT',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: const Color(0xFF94A3B8),
                        fontSize: 8.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        card.limit,
                        maxLines: 1,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== YENİ KART OLUŞTURMA MODALI ====================
  void _showAddNewCardSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleController = TextEditingController();
    final holderController = TextEditingController(text: 'DENİZ AKSOY');
    final limitController = TextEditingController(text: '15000');

    String selectedCardType = 'Sanal Kart';
    String selectedLinkedAccount = _bankAccounts.first.bankName;
    int selectedColorIndex = 0;
    bool allowOnline = true;
    bool allowInternational = true;
    bool allowContactless = true;

    final colorGradients = [
      AppColors.heroCardGradient,
      const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
      ),
      const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0D9488), Color(0xFF10B981)],
      ),
      const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF4C1D95), Color(0xFF7C3AED)],
      ),
      const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1E3A8A), Color(0xFF0284C7)],
      ),
      const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF78350F), Color(0xFFD97706)],
      ),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomCtx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 16,
                  bottom: MediaQuery.of(bottomCtx).viewInsets.bottom + 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Yeni PayPulse Kartı Oluştur',
                          style: AppTextStyles.headlineSmall.copyWith(
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : AppColors.darkNavy,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close_rounded, color: isDark ? Colors.white : const Color(0xFF64748B)),
                          onPressed: () => Navigator.of(bottomCtx).pop(),
                        ),
                      ],
                    ),
                    Text(
                      'İhtiyacınıza uygun kart tipini seçin, limitinizi ve tercihlerinizi belirleyin.',
                      style: TextStyle(
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 1. KART TİPİ SEÇİMİ
                    Text(
                      'KART TİPİ',
                      style: AppTextStyles.labelSmall.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildChoiceChip(
                          label: 'Sanal Kart',
                          icon: Icons.credit_card_rounded,
                          isSelected: selectedCardType == 'Sanal Kart',
                          isDark: isDark,
                          onTap: () => setSheetState(() => selectedCardType = 'Sanal Kart'),
                        ),
                        const SizedBox(width: 8),
                        _buildChoiceChip(
                          label: 'Metal Kart',
                          icon: Icons.shield_rounded,
                          isSelected: selectedCardType == 'Metal Kart',
                          isDark: isDark,
                          onTap: () => setSheetState(() => selectedCardType = 'Metal Kart'),
                        ),
                        const SizedBox(width: 8),
                        _buildChoiceChip(
                          label: 'Ticari Ek Kart',
                          icon: Icons.business_center_rounded,
                          isSelected: selectedCardType == 'Ticari Ek Kart',
                          isDark: isDark,
                          onTap: () => setSheetState(() => selectedCardType = 'Ticari Ek Kart'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 2. KART ADI / ETİKETİ
                    TextField(
                      controller: titleController,
                      style: TextStyle(color: isDark ? Colors.white : AppColors.darkNavy),
                      decoration: InputDecoration(
                        labelText: 'Kart Adı / Etiketi (Örn: Alışveriş Kartı)',
                        labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                        prefixIcon: const Icon(Icons.badge_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 3. KART SAHİBİ
                    TextField(
                      controller: holderController,
                      style: TextStyle(color: isDark ? Colors.white : AppColors.darkNavy),
                      decoration: InputDecoration(
                        labelText: 'Kart Üzerinde Yazacak İsim',
                        labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 4. AYLIK HARCAMA LİMİTİ
                    TextField(
                      controller: limitController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: isDark ? Colors.white : AppColors.darkNavy),
                      decoration: InputDecoration(
                        labelText: 'Aylık Harcama Limiti (₺)',
                        labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                        prefixIcon: const Icon(Icons.tune_rounded),
                        suffixText: 'TL',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Hızlı Limit Butonları
                    Wrap(
                      spacing: 6,
                      children: ['5000', '15000', '30000', '50000', '100000'].map((l) {
                        return ActionChip(
                          label: Text('₺$l'),
                          labelStyle: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white : AppColors.darkNavy,
                          ),
                          backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                          onPressed: () {
                            setSheetState(() => limitController.text = l);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // 5. KART RENGİ / TEMASI
                    Text(
                      'KART TEMASI & RENGİ',
                      style: AppTextStyles.labelSmall.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(colorGradients.length, (idx) {
                        final isSel = selectedColorIndex == idx;
                        return GestureDetector(
                          onTap: () => setSheetState(() => selectedColorIndex = idx),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: colorGradients[idx],
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSel ? AppColors.primaryTeal : Colors.transparent,
                                width: 3,
                              ),
                              boxShadow: [
                                if (isSel)
                                  BoxShadow(
                                    color: AppColors.primaryTeal.withValues(alpha: 0.5),
                                    blurRadius: 8,
                                  ),
                              ],
                            ),
                            child: isSel
                                ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                                : null,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),

                    // 6. BAĞLANACAK BANKA HESABI
                    Text(
                      'BAĞLANACAK HESAP / BAKİYE KAYNAĞI',
                      style: AppTextStyles.labelSmall.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedLinkedAccount,
                          isExpanded: true,
                          dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                          items: [
                            'PayPulse TRY FAST Cüzdanı',
                            ..._bankAccounts.map((b) => b.bankName),
                          ].map((name) {
                            return DropdownMenuItem<String>(
                              value: name,
                              child: Text(
                                name,
                                style: TextStyle(
                                  color: isDark ? Colors.white : AppColors.darkNavy,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setSheetState(() => selectedLinkedAccount = val);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 7. GÜVENLİK VE KULLANIM İZİNLERİ
                    Text(
                      'KART GÜVENLİK VE İŞLEM İZİNLERİ',
                      style: AppTextStyles.labelSmall.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'İnternet (E-Ticaret) Harcamaları',
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.darkNavy,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: const Text('Online alışveriş ve abonelik ödemeleri'),
                      value: allowOnline,
                      activeColor: AppColors.primaryTeal,
                      onChanged: (v) => setSheetState(() => allowOnline = v),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Yurt Dışı İşlemleri',
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.darkNavy,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: const Text('Uluslararası sitelerde ve seyahatlerde geçerlilik'),
                      value: allowInternational,
                      activeColor: AppColors.primaryTeal,
                      onChanged: (v) => setSheetState(() => allowInternational = v),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Temassız ve POS Ödemeleri',
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.darkNavy,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: const Text('Fiziksel POS cihazlarında temassız işlem'),
                      value: allowContactless,
                      activeColor: AppColors.primaryTeal,
                      onChanged: (v) => setSheetState(() => allowContactless = v),
                    ),
                    const SizedBox(height: 18),

                    // OLUŞTUR BUTONU
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryTeal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          final name = titleController.text.trim().isEmpty
                              ? 'PAYPULSE $selectedCardType'.toUpperCase()
                              : titleController.text.trim().toUpperCase();
                          final holder = holderController.text.trim().isEmpty
                              ? 'DENİZ AKSOY'
                              : holderController.text.trim().toUpperCase();
                          final rawLimit = limitController.text.trim().replaceAll('.', '');
                          final limitFormatted = '₺${rawLimit.isEmpty ? "15.000" : rawLimit},00';

                          // Güvenli Rastgele Kart Numarası Üret
                          final random = Random();
                          final bin = selectedCardType == 'Metal Kart' ? '5124' : '5400';
                          final generatedCardNumber =
                              '$bin ${1000 + random.nextInt(9000)} ${1000 + random.nextInt(9000)} ${1000 + random.nextInt(9000)}';
                          final generatedCvv = '${100 + random.nextInt(900)}';
                          final generatedExpiry = '0${1 + random.nextInt(9)}/${29 + random.nextInt(3)}';

                          final newCard = CardItem(
                            id: 'card_${DateTime.now().millisecondsSinceEpoch}',
                            title: name,
                            cardNumber: generatedCardNumber,
                            expiry: generatedExpiry,
                            cvv: generatedCvv,
                            limit: limitFormatted,
                            holder: holder,
                            isVirtual: selectedCardType != 'Metal Kart',
                            cardType: selectedCardType,
                            linkedAccount: selectedLinkedAccount,
                            gradient: colorGradients[selectedColorIndex],
                            allowOnline: allowOnline,
                            allowInternational: allowInternational,
                            allowContactless: allowContactless,
                          );

                          setState(() {
                            _cards.add(newCard);
                            _currentCardIndex = _cards.length - 1;
                          });

                          Navigator.of(bottomCtx).pop();

                          // Yeni karta kaydır
                          Future.delayed(const Duration(milliseconds: 200), () {
                            if (_pageController.hasClients) {
                              _pageController.animateToPage(
                                _currentCardIndex,
                                duration: const Duration(milliseconds: 350),
                                curve: Curves.easeOut,
                              );
                            }
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$name başarıyla oluşturuldu ve kullanıma hazır.'),
                              backgroundColor: AppColors.primaryTeal,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        },
                        child: Text(
                          '$selectedCardType Oluştur',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryTeal.withValues(alpha: 0.15)
                : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryTeal
                  : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? AppColors.primaryTeal
                    : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? AppColors.primaryTeal
                      : (isDark ? Colors.white : AppColors.darkNavy),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Yeni Banka Hesabı Ekleme Modalı
  void _showAddNewBankSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bankNameController = TextEditingController();
    final ibanController = TextEditingController();
    String accountType = 'Bireysel FAST Hesabı';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomCtx) {
        return StatefulBuilder(
          builder: (ctx, setBankState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(bottomCtx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Yeni Banka Hesabı (IBAN) Bağla',
                        style: AppTextStyles.headlineSmall.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppColors.darkNavy,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close_rounded, color: isDark ? Colors.white : const Color(0xFF64748B)),
                        onPressed: () => Navigator.of(bottomCtx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Adınıza kayıtlı vadesiz TL hesabınızı FAST transferleri için bağlayın.',
                    style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: bankNameController,
                    style: TextStyle(color: isDark ? Colors.white : AppColors.darkNavy),
                    decoration: InputDecoration(
                      labelText: 'Banka Adı (Örn: Akbank Vadesiz TRY)',
                      labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                      prefixIcon: const Icon(Icons.account_balance_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: ibanController,
                    style: TextStyle(color: isDark ? Colors.white : AppColors.darkNavy),
                    decoration: InputDecoration(
                      labelText: 'IBAN (TR...)',
                      labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                      prefixIcon: const Icon(Icons.credit_card_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: accountType,
                    dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                    style: TextStyle(color: isDark ? Colors.white : AppColors.darkNavy),
                    decoration: InputDecoration(
                      labelText: 'Hesap Türü',
                      labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Bireysel FAST Hesabı', child: Text('Bireysel FAST Hesabı')),
                      DropdownMenuItem(value: 'Maaş ve Birikim Hesabı', child: Text('Maaş ve Birikim Hesabı')),
                      DropdownMenuItem(value: 'Ticari / Şirket Hesabı', child: Text('Ticari / Şirket Hesabı')),
                    ],
                    onChanged: (val) {
                      if (val != null) setBankState(() => accountType = val);
                    },
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryTeal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        final bank = bankNameController.text.trim().isEmpty
                            ? 'Akbank Vadesiz TRY'
                            : bankNameController.text.trim();
                        final iban = ibanController.text.trim().isEmpty
                            ? 'TR23 0004 6000 0001 9912 05'
                            : ibanController.text.trim();
                        setState(() {
                          _bankAccounts.add(
                            BankAccountItem(
                              id: 'bank_${DateTime.now().millisecondsSinceEpoch}',
                              bankName: bank,
                              accountType: accountType,
                              iban: iban,
                              balance: '₺0,00',
                              icon: Icons.account_balance_rounded,
                              iconColor: const Color(0xFFEF4444),
                            ),
                          );
                        });
                        Navigator.of(bottomCtx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('$bank başarıyla hesaba bağlandı.'),
                            backgroundColor: AppColors.primaryTeal,
                          ),
                        );
                      },
                      child: const Text('Hesabı Bağla', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
