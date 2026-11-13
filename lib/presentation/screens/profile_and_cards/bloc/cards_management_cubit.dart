import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/equatable.dart';
import '../../../../core/utils/financial_amount.dart';
import '../../../../core/validators/financial_validators.dart';

/// Kayıtlı fiziksel veya sanal kart modelini immutable olarak temsil eder.
class CardItem extends Equatable {
  final String id;
  final String title;
  final String cardNumber;
  final String expiry;
  final String cvv;
  final String limit;
  final String holder;
  final bool isVirtual;
  final String cardType;
  final String linkedAccount;
  final LinearGradient gradient;
  final bool isFrozen;
  final bool isDefault;
  final bool allowOnline;
  final bool allowInternational;
  final bool allowContactless;

  const CardItem({
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

  CardItem copyWith({
    String? id,
    String? title,
    String? cardNumber,
    String? expiry,
    String? cvv,
    String? limit,
    String? holder,
    bool? isVirtual,
    String? cardType,
    String? linkedAccount,
    LinearGradient? gradient,
    bool? isFrozen,
    bool? isDefault,
    bool? allowOnline,
    bool? allowInternational,
    bool? allowContactless,
  }) {
    return CardItem(
      id: id ?? this.id,
      title: title ?? this.title,
      cardNumber: cardNumber ?? this.cardNumber,
      expiry: expiry ?? this.expiry,
      cvv: cvv ?? this.cvv,
      limit: limit ?? this.limit,
      holder: holder ?? this.holder,
      isVirtual: isVirtual ?? this.isVirtual,
      cardType: cardType ?? this.cardType,
      linkedAccount: linkedAccount ?? this.linkedAccount,
      gradient: gradient ?? this.gradient,
      isFrozen: isFrozen ?? this.isFrozen,
      isDefault: isDefault ?? this.isDefault,
      allowOnline: allowOnline ?? this.allowOnline,
      allowInternational: allowInternational ?? this.allowInternational,
      allowContactless: allowContactless ?? this.allowContactless,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    cardNumber,
    expiry,
    cvv,
    limit,
    holder,
    isVirtual,
    cardType,
    linkedAccount,
    isFrozen,
    isDefault,
    allowOnline,
    allowInternational,
    allowContactless,
  ];
}

/// Kayıtlı FAST banka hesabı modelini immutable olarak temsil eder.
class BankAccountItem extends Equatable {
  final String id;
  final String bankName;
  final String accountType;
  final String iban;
  final String balance;
  final IconData icon;
  final Color iconColor;
  final bool isDefault;

  const BankAccountItem({
    required this.id,
    required this.bankName,
    required this.accountType,
    required this.iban,
    required this.balance,
    required this.icon,
    required this.iconColor,
    this.isDefault = false,
  });

  BankAccountItem copyWith({
    String? id,
    String? bankName,
    String? accountType,
    String? iban,
    String? balance,
    IconData? icon,
    Color? iconColor,
    bool? isDefault,
  }) {
    return BankAccountItem(
      id: id ?? this.id,
      bankName: bankName ?? this.bankName,
      accountType: accountType ?? this.accountType,
      iban: iban ?? this.iban,
      balance: balance ?? this.balance,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  List<Object?> get props => [
    id,
    bankName,
    accountType,
    iban,
    balance,
    isDefault,
  ];
}

/// Kartlar ve Banka Hesapları ekranının durum modeli.
class CardsManagementState extends Equatable {
  final List<CardItem> cards;
  final List<BankAccountItem> bankAccounts;
  final int currentCardIndex;
  final bool showCardDetails;

  // Yeni Kart Oluşturma Formu Durumu
  final String draftCardType;
  final String draftLinkedAccount;
  final int draftColorIndex;
  final bool draftAllowOnline;
  final bool draftAllowInternational;
  final bool draftAllowContactless;

  // Yeni Banka Hesabı Bağlama Formu Durumu
  final String draftBankAccountType;

  final String? feedbackMessage;
  final bool isSuccessFeedback;

  const CardsManagementState({
    required this.cards,
    required this.bankAccounts,
    this.currentCardIndex = 0,
    this.showCardDetails = false,
    this.draftCardType = 'Sanal Kart',
    this.draftLinkedAccount = 'PayPulse TRY FAST Cüzdanı',
    this.draftColorIndex = 0,
    this.draftAllowOnline = true,
    this.draftAllowInternational = true,
    this.draftAllowContactless = true,
    this.draftBankAccountType = 'Bireysel FAST Hesabı',
    this.feedbackMessage,
    this.isSuccessFeedback = false,
  });

  CardItem get currentCard =>
      cards[currentCardIndex.clamp(0, cards.isEmpty ? 0 : cards.length - 1)];

  CardsManagementState copyWith({
    List<CardItem>? cards,
    List<BankAccountItem>? bankAccounts,
    int? currentCardIndex,
    bool? showCardDetails,
    String? draftCardType,
    String? draftLinkedAccount,
    int? draftColorIndex,
    bool? draftAllowOnline,
    bool? draftAllowInternational,
    bool? draftAllowContactless,
    String? draftBankAccountType,
    String? feedbackMessage,
    bool? isSuccessFeedback,
    bool clearFeedback = false,
  }) {
    return CardsManagementState(
      cards: cards ?? this.cards,
      bankAccounts: bankAccounts ?? this.bankAccounts,
      currentCardIndex: currentCardIndex ?? this.currentCardIndex,
      showCardDetails: showCardDetails ?? this.showCardDetails,
      draftCardType: draftCardType ?? this.draftCardType,
      draftLinkedAccount: draftLinkedAccount ?? this.draftLinkedAccount,
      draftColorIndex: draftColorIndex ?? this.draftColorIndex,
      draftAllowOnline: draftAllowOnline ?? this.draftAllowOnline,
      draftAllowInternational:
          draftAllowInternational ?? this.draftAllowInternational,
      draftAllowContactless:
          draftAllowContactless ?? this.draftAllowContactless,
      draftBankAccountType: draftBankAccountType ?? this.draftBankAccountType,
      feedbackMessage:
          clearFeedback ? null : (feedbackMessage ?? this.feedbackMessage),
      isSuccessFeedback:
          clearFeedback ? false : (isSuccessFeedback ?? this.isSuccessFeedback),
    );
  }

  @override
  List<Object?> get props => [
    cards,
    bankAccounts,
    currentCardIndex,
    showCardDetails,
    draftCardType,
    draftLinkedAccount,
    draftColorIndex,
    draftAllowOnline,
    draftAllowInternational,
    draftAllowContactless,
    draftBankAccountType,
    feedbackMessage,
    isSuccessFeedback,
  ];
}

/// Kartlarım ve Banka Hesaplarım durumunu yöneten Cubit.
class CardsManagementCubit extends Cubit<CardsManagementState> {
  static const List<LinearGradient> cardGradients = [
    AppColors.heroCardGradient,
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
    ),
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF0D9488), Color(0xFF10B981)],
    ),
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF4C1D95), Color(0xFF7C3AED)],
    ),
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF1E3A8A), Color(0xFF0284C7)],
    ),
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF78350F), Color(0xFFD97706)],
    ),
  ];

  final PageController pageController = PageController(viewportFraction: 0.92);

  final TextEditingController cardTitleController = TextEditingController();
  final TextEditingController cardHolderController = TextEditingController();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController cardExpiryController = TextEditingController();
  final TextEditingController cardLimitController = TextEditingController(
    text: '15000',
  );
  final GlobalKey<FormState> addCardFormKey = GlobalKey<FormState>();
  String _lastGeneratedCardNumber = '';

  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController ibanController = TextEditingController();
  final GlobalKey<FormState> addBankFormKey = GlobalKey<FormState>();

  String _holderUpper;
  final Random _random;

  CardsManagementCubit({String? initialHolderName, Random? random})
    : _holderUpper = _normalizeHolder(initialHolderName),
      _random = random ?? Random(),
      super(
        CardsManagementState(
          cards: _buildInitialCards(_normalizeHolder(initialHolderName)),
          bankAccounts: _initialBankAccounts(),
          draftLinkedAccount: 'Garanti BBVA Vadesiz TRY',
        ),
      );

  static String _normalizeHolder(String? name) {
    final trimmed = name?.trim() ?? '';
    return trimmed.isEmpty ? 'PAYPULSE KULLANICISI' : trimmed.toUpperCase();
  }

  static List<CardItem> _buildInitialCards(String holder) {
    return [
      CardItem(
        id: 'card_1',
        title: 'PAYPULSE VIRTUAL PREPAID',
        cardNumber: '5400 8812 4319 4829',
        expiry: '08/28',
        cvv: '391',
        limit: '₺15.000,00',
        holder: holder,
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
        holder: holder,
        isVirtual: false,
        cardType: 'Metal Kart',
        linkedAccount: 'Garanti BBVA Vadesiz TRY',
        gradient: cardGradients[1],
        isDefault: false,
      ),
      CardItem(
        id: 'card_3',
        title: 'PAYPULSE CORPORATE & TRAVEL',
        cardNumber: '4532 1084 7762 7741',
        expiry: '03/27',
        cvv: '520',
        limit: '₺35.000,00',
        holder: holder,
        isVirtual: true,
        cardType: 'Ticari Ek Kart',
        linkedAccount: 'Türkiye İş Bankası TRY',
        gradient: cardGradients[4],
        isDefault: false,
      ),
    ];
  }

  static List<BankAccountItem> _initialBankAccounts() {
    return const [
      BankAccountItem(
        id: 'bank_1',
        bankName: 'Garanti BBVA Vadesiz TRY',
        accountType: 'Bireysel FAST Hesabı',
        iban: 'TR56 0006 2000 0001 5500 01',
        balance: '₺48.250,00',
        icon: Icons.account_balance_rounded,
        iconColor: Color(0xFF10B981),
        isDefault: true,
      ),
      BankAccountItem(
        id: 'bank_2',
        bankName: 'Türkiye İş Bankası TRY',
        accountType: 'Maaş ve Birikim Hesabı',
        iban: 'TR12 0006 4000 0002 8821 02',
        balance: '₺12.400,00',
        icon: Icons.account_balance_rounded,
        iconColor: Color(0xFF0D9488),
        isDefault: false,
      ),
      BankAccountItem(
        id: 'bank_3',
        bankName: 'QNB Finansbank TRY',
        accountType: 'Esnek Vadeli Hesap',
        iban: 'TR88 0011 1000 0003 3342 03',
        balance: '₺9.800,00',
        icon: Icons.account_balance_rounded,
        iconColor: Color(0xFF6366F1),
        isDefault: false,
      ),
      BankAccountItem(
        id: 'bank_4',
        bankName: 'Yapı Kredi Bankası TRY',
        accountType: 'İkincil Transfer Hesabı',
        iban: 'TR44 0006 7000 0004 1190 04',
        balance: '₺5.600,00',
        icon: Icons.account_balance_rounded,
        iconColor: Color(0xFFF59E0B),
        isDefault: false,
      ),
    ];
  }

  /// Oturumdaki kullanıcı adı değiştiğinde kart sahibi etiketlerini günceller.
  void syncHolderName(String? name) {
    final normalized = _normalizeHolder(name);
    if (normalized == _holderUpper) return;
    _holderUpper = normalized;
    emit(
      state.copyWith(
        cards: state.cards.map((c) => c.copyWith(holder: normalized)).toList(),
        clearFeedback: true,
      ),
    );
  }

  void onCardPageChanged(int index) {
    emit(state.copyWith(currentCardIndex: index, clearFeedback: true));
  }

  void animateToCard(int index) {
    if (pageController.hasClients) {
      pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void toggleShowCardDetails() {
    emit(
      state.copyWith(
        showCardDetails: !state.showCardDetails,
        clearFeedback: true,
      ),
    );
  }

  void switchDefaultCard(CardItem selectedCard) {
    final updated = state.cards
        .map((c) => c.copyWith(isDefault: c.id == selectedCard.id))
        .toList();
    emit(
      state.copyWith(
        cards: updated,
        feedbackMessage:
            '${selectedCard.title} varsayılan ödeme kartı olarak belirlendi.',
        isSuccessFeedback: true,
      ),
    );
  }

  void toggleFreezeCard(CardItem card) {
    final nextFrozen = !card.isFrozen;
    final updated = state.cards
        .map((c) => c.id == card.id ? c.copyWith(isFrozen: nextFrozen) : c)
        .toList();
    emit(
      state.copyWith(
        cards: updated,
        feedbackMessage: nextFrozen
            ? '${card.title} geçici olarak donduruldu.'
            : '${card.title} kullanıma açıldı.',
        isSuccessFeedback: false,
      ),
    );
  }

  void switchDefaultAccount(BankAccountItem selectedAccount) {
    final updated = state.bankAccounts
        .map((b) => b.copyWith(isDefault: b.id == selectedAccount.id))
        .toList();
    emit(
      state.copyWith(
        bankAccounts: updated,
        feedbackMessage:
            '${selectedAccount.bankName} varsayılan FAST transfer hesabı olarak seçildi.',
        isSuccessFeedback: true,
      ),
    );
  }

  void prepareAddCardDraft() {
    cardTitleController.clear();
    cardHolderController.text = _holderUpper;
    cardLimitController.text = '15000';
    _lastGeneratedCardNumber = _generateLuhnValidCardNumber('5400');
    cardNumberController.text = _lastGeneratedCardNumber;
    cardExpiryController.text = _generateDefaultExpiry();
    emit(
      state.copyWith(
        draftCardType: 'Sanal Kart',
        draftLinkedAccount: state.bankAccounts.isNotEmpty
            ? state.bankAccounts.first.bankName
            : 'PayPulse TRY FAST Cüzdanı',
        draftColorIndex: 0,
        draftAllowOnline: true,
        draftAllowInternational: true,
        draftAllowContactless: true,
        clearFeedback: true,
      ),
    );
  }

  void setDraftCardType(String type) {
    if (cardNumberController.text.trim().isEmpty ||
        cardNumberController.text == _lastGeneratedCardNumber) {
      final bin = type == 'Metal Kart' ? '5124' : '5400';
      _lastGeneratedCardNumber = _generateLuhnValidCardNumber(bin);
      cardNumberController.text = _lastGeneratedCardNumber;
    }
    emit(state.copyWith(draftCardType: type, clearFeedback: true));
  }

  void regenerateDraftCardNumber() {
    final bin = state.draftCardType == 'Metal Kart' ? '5124' : '5400';
    _lastGeneratedCardNumber = _generateLuhnValidCardNumber(bin);
    cardNumberController.text = _lastGeneratedCardNumber;
  }

  void setDraftLinkedAccount(String account) =>
      emit(state.copyWith(draftLinkedAccount: account, clearFeedback: true));

  void setDraftColorIndex(int index) =>
      emit(state.copyWith(draftColorIndex: index, clearFeedback: true));

  void setDraftLimitPreset(String amount) {
    cardLimitController.text = amount;
  }

  void setDraftAllowOnline(bool v) =>
      emit(state.copyWith(draftAllowOnline: v, clearFeedback: true));

  void setDraftAllowInternational(bool v) =>
      emit(state.copyWith(draftAllowInternational: v, clearFeedback: true));

  void setDraftAllowContactless(bool v) =>
      emit(state.copyWith(draftAllowContactless: v, clearFeedback: true));

  bool createCardFromDraft() {
    final isValid = addCardFormKey.currentState?.validate() ?? true;
    if (!isValid) return false;

    final bin = state.draftCardType == 'Metal Kart' ? '5124' : '5400';
    if (addCardFormKey.currentState == null &&
        (cardNumberController.text.trim().isNotEmpty ||
            cardExpiryController.text.trim().isNotEmpty)) {
      final cardError = cardNumberController.text.trim().isNotEmpty
          ? FinancialValidators.cardNumber(cardNumberController.text)
          : null;
      final expiryError = cardExpiryController.text.trim().isNotEmpty
          ? FinancialValidators.expiry(cardExpiryController.text)
          : null;
      if (cardError != null || expiryError != null) {
        emit(
          state.copyWith(
            feedbackMessage: cardError ?? expiryError,
            isSuccessFeedback: false,
          ),
        );
        return false;
      }
    }

    final name = cardTitleController.text.trim().isEmpty
        ? 'PAYPULSE ${state.draftCardType}'.toUpperCase()
        : cardTitleController.text.trim().toUpperCase();
    final holder = cardHolderController.text.trim().isEmpty
        ? _holderUpper
        : cardHolderController.text.trim().toUpperCase();

    final rawLimitDigits = cardLimitController.text
        .trim()
        .replaceAll(RegExp(r'[^0-9]'), '');
    final limitTL = int.tryParse(rawLimitDigits) ?? 15000;
    final limitFormatted = FinancialAmount.format(limitTL * 100);

    final resolvedNumber = cardNumberController.text.trim().isNotEmpty
        ? _formatIbanGroups(
            FinancialValidators.normalizeCard(cardNumberController.text),
          )
        : _generateLuhnValidCardNumber(bin);
    final resolvedExpiry = cardExpiryController.text.trim().isNotEmpty
        ? cardExpiryController.text.replaceAll(' ', '')
        : _generateDefaultExpiry().replaceAll(' ', '');
    final generatedCvv = '${100 + _random.nextInt(900)}';

    final newCard = CardItem(
      id: 'card_${DateTime.now().millisecondsSinceEpoch}',
      title: name,
      cardNumber: resolvedNumber,
      expiry: resolvedExpiry,
      cvv: generatedCvv,
      limit: limitFormatted,
      holder: holder,
      isVirtual: state.draftCardType != 'Metal Kart',
      cardType: state.draftCardType,
      linkedAccount: state.draftLinkedAccount,
      gradient: cardGradients[state.draftColorIndex],
      allowOnline: state.draftAllowOnline,
      allowInternational: state.draftAllowInternational,
      allowContactless: state.draftAllowContactless,
    );

    final updatedCards = [...state.cards, newCard];
    final nextIndex = updatedCards.length - 1;

    emit(
      state.copyWith(
        cards: updatedCards,
        currentCardIndex: nextIndex,
        feedbackMessage: '$name başarıyla oluşturuldu ve kullanıma hazır.',
        isSuccessFeedback: true,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isClosed && pageController.hasClients) {
        pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });

    return true;
  }

  void prepareAddBankDraft() {
    bankNameController.clear();
    ibanController.clear();
    emit(
      state.copyWith(
        draftBankAccountType: 'Bireysel FAST Hesabı',
        clearFeedback: true,
      ),
    );
  }

  void setDraftBankAccountType(String accountType) =>
      emit(state.copyWith(draftBankAccountType: accountType, clearFeedback: true));

  bool linkBankAccountFromDraft() {
    final isValid = addBankFormKey.currentState?.validate() ?? true;
    if (!isValid) return false;

    final bank = bankNameController.text.trim();
    final formattedIban = _formatIbanGroups(
      FinancialValidators.normalizeIban(ibanController.text),
    );

    final updatedBanks = [
      ...state.bankAccounts,
      BankAccountItem(
        id: 'bank_${DateTime.now().millisecondsSinceEpoch}',
        bankName: bank,
        accountType: state.draftBankAccountType,
        iban: formattedIban,
        balance: '₺0,00',
        icon: Icons.account_balance_rounded,
        iconColor: const Color(0xFFEF4444),
      ),
    ];

    emit(
      state.copyWith(
        bankAccounts: updatedBanks,
        feedbackMessage: '$bank başarıyla hesaba bağlandı.',
        isSuccessFeedback: true,
      ),
    );

    return true;
  }

  String _generateLuhnValidCardNumber(String binPrefix) {
    final digits = <int>[
      for (final ch in binPrefix.split('')) int.parse(ch),
      for (var i = 0; i < 11; i++) _random.nextInt(10),
    ];

    var sum = 0;
    var shouldDouble = true;
    for (var i = digits.length - 1; i >= 0; i--) {
      var d = digits[i];
      if (shouldDouble) {
        d *= 2;
        if (d > 9) d -= 9;
      }
      sum += d;
      shouldDouble = !shouldDouble;
    }

    final checkDigit = (10 - (sum % 10)) % 10;
    digits.add(checkDigit);

    final raw = digits.join();
    return '${raw.substring(0, 4)} ${raw.substring(4, 8)} '
        '${raw.substring(8, 12)} ${raw.substring(12, 16)}';
  }

  String _generateDefaultExpiry() {
    final now = DateTime.now();
    final futureYear = ((now.year + 3) % 100).toString().padLeft(2, '0');
    final month = now.month.toString().padLeft(2, '0');
    return '$month / $futureYear';
  }

  String _formatIbanGroups(String normalized) {
    final buf = StringBuffer();
    for (var i = 0; i < normalized.length; i++) {
      if (i > 0 && i % 4 == 0) buf.write(' ');
      buf.write(normalized[i]);
    }
    return buf.toString();
  }

  void clearFeedback() => emit(state.copyWith(clearFeedback: true));

  @override
  Future<void> close() {
    pageController.dispose();
    cardTitleController.dispose();
    cardHolderController.dispose();
    cardNumberController.dispose();
    cardExpiryController.dispose();
    cardLimitController.dispose();
    bankNameController.dispose();
    ibanController.dispose();
    return super.close();
  }
}
