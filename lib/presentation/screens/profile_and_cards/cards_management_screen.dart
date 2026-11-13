import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/formatters/currency_and_card_formatters.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/validators/financial_validators.dart';
import '../../widgets/role_switch_app_bar.dart';
import '../../widgets/status_badge_widget.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_state.dart';
import 'bloc/cards_management_cubit.dart';

export 'bloc/cards_management_cubit.dart' show BankAccountItem, CardItem;

/// Kayıtlı Banka ve Sanal/Fiziksel Kartlar Yönetim Ekranı.
class CardsManagementScreen extends StatelessWidget {
  const CardsManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final holderName = context.read<AuthBloc>().state.user?.name;

    return BlocProvider<CardsManagementCubit>(
      create: (_) => CardsManagementCubit(initialHolderName: holderName),
      child: const _CardsManagementView(),
    );
  }
}

class _CardsManagementView extends StatelessWidget {
  const _CardsManagementView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg =
        isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final cardBorder =
        isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final primaryTextColor = isDark ? Colors.white : AppColors.darkNavy;
    final secondaryTextColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (prev, curr) => prev.user?.name != curr.user?.name,
          listener: (ctx, authState) {
            ctx.read<CardsManagementCubit>().syncHolderName(
              authState.user?.name,
            );
          },
        ),
        BlocListener<CardsManagementCubit, CardsManagementState>(
          listenWhen: (prev, curr) =>
              prev.feedbackMessage != curr.feedbackMessage &&
              curr.feedbackMessage != null,
          listener: (ctx, state) {
            final msg = state.feedbackMessage!;
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text(msg),
                duration: const Duration(seconds: 2),
                backgroundColor:
                    state.isSuccessFeedback ? AppColors.primaryTeal : null,
              ),
            );
            ctx.read<CardsManagementCubit>().clearFeedback();
          },
        ),
      ],
      child: BlocBuilder<CardsManagementCubit, CardsManagementState>(
        builder: (context, state) {
          final cubit = context.read<CardsManagementCubit>();
          final currentCard = state.currentCard;

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'KARTLARIM (${state.cards.length})',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: secondaryTextColor,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          cubit.prepareAddCardDraft();
                          _showAddNewCardSheet(context, cubit);
                        },
                        icon: const Icon(
                          Icons.add_circle_outline_rounded,
                          size: 16,
                        ),
                        label: const Text('Yeni Kart Ekle'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primaryTeal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  SizedBox(
                    height: 215,
                    child: PageView.builder(
                      controller: cubit.pageController,
                      itemCount: state.cards.length,
                      onPageChanged: cubit.onCardPageChanged,
                      itemBuilder: (ctx, idx) {
                        final card = state.cards[idx];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: _CardPreviewTile(
                            card: card,
                            showCardDetails: state.showCardDetails,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(state.cards.length, (index) {
                      final isSelected = index == state.currentCardIndex;
                      return GestureDetector(
                        onTap: () => cubit.animateToCard(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isSelected ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryTeal
                                : (isDark
                                      ? const Color(0xFF475569)
                                      : const Color(0xFFCBD5E1)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 14),

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
                                    : (isDark
                                          ? const Color(0xFF475569)
                                          : const Color(0xFFCBD5E1)),
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
                                : () => cubit.switchDefaultCard(currentCard),
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
                              currentCard.isDefault
                                  ? 'Varsayılan Kart'
                                  : 'Varsayılan Yap',
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
                                    : (isDark
                                          ? const Color(0xFF475569)
                                          : const Color(0xFFCBD5E1)),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () => cubit.toggleFreezeCard(currentCard),
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
                          onTap: cubit.toggleShowCardDetails,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              state.showCardDetails
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

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'KAYITLI BANKA HESAPLARI (FAST)',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: secondaryTextColor,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () {
                          cubit.prepareAddBankDraft();
                          _showAddNewBankSheet(context, cubit);
                        },
                        icon: const Icon(
                          Icons.account_balance_outlined,
                          size: 16,
                        ),
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

                  Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: cardBorder),
                    ),
                    child: Column(
                      children: List.generate(state.bankAccounts.length, (index) {
                        final account = state.bankAccounts[index];
                        final isLast = index == state.bankAccounts.length - 1;
                        return Column(
                          children: [
                            InkWell(
                              onTap: () => cubit.switchDefaultAccount(account),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: account.isDefault
                                      ? AppColors.primaryTeal.withValues(
                                          alpha: isDark ? 0.15 : 0.08,
                                        )
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: account.iconColor.withValues(
                                          alpha: 0.14,
                                        ),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  account.bankName,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: AppTextStyles.bodyMedium
                                                      .copyWith(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: primaryTextColor,
                                                      ),
                                                ),
                                              ),
                                              if (account.isDefault) ...[
                                                const SizedBox(width: 6),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFFD1FAE5,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                  ),
                                                  child: const Text(
                                                    'Varsayılan',
                                                    style: TextStyle(
                                                      color: Color(0xFF065F46),
                                                      fontSize: 9.5,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            account.iban,
                                            style: AppTextStyles.bodySmall
                                                .copyWith(
                                                  color: secondaryTextColor,
                                                  fontSize: 11,
                                                ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Bakiye: ${account.balance}',
                                            style: AppTextStyles.labelSmall
                                                .copyWith(
                                                  color: AppColors.primaryGreen,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 11,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
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
                                              : (isDark
                                                    ? const Color(0xFF475569)
                                                    : const Color(0xFFCBD5E1)),
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
                                color: isDark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFF1F5F9),
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
        },
      ),
    );
  }

  void _showAddNewCardSheet(BuildContext context, CardsManagementCubit cubit) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomCtx) {
        return BlocProvider<CardsManagementCubit>.value(
          value: cubit,
          child: BlocBuilder<CardsManagementCubit, CardsManagementState>(
            builder: (sheetCtx, state) {
              return SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 16,
                    bottom: MediaQuery.of(bottomCtx).viewInsets.bottom + 20,
                  ),
                  child: Form(
                    key: cubit.addCardFormKey,
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
                              color: isDark
                                  ? const Color(0xFF475569)
                                  : const Color(0xFFCBD5E1),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Yeni PayPulse Kartı Oluştur',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.headlineSmall.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.darkNavy,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.close_rounded,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF64748B),
                              ),
                              onPressed: () => Navigator.of(bottomCtx).pop(),
                            ),
                          ],
                        ),
                        Text(
                          'İhtiyacınıza uygun kart tipini seçin, limitinizi ve tercihlerinizi belirleyin.',
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 16),

                        Text(
                          'KART TİPİ',
                          style: AppTextStyles.labelSmall.copyWith(
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _ChoiceChipItem(
                              label: 'Sanal Kart',
                              icon: Icons.credit_card_rounded,
                              isSelected: state.draftCardType == 'Sanal Kart',
                              isDark: isDark,
                              onTap: () => cubit.setDraftCardType('Sanal Kart'),
                            ),
                            const SizedBox(width: 8),
                            _ChoiceChipItem(
                              label: 'Metal Kart',
                              icon: Icons.shield_rounded,
                              isSelected: state.draftCardType == 'Metal Kart',
                              isDark: isDark,
                              onTap: () => cubit.setDraftCardType('Metal Kart'),
                            ),
                            const SizedBox(width: 8),
                            _ChoiceChipItem(
                              label: 'Ticari Ek Kart',
                              icon: Icons.business_center_rounded,
                              isSelected:
                                  state.draftCardType == 'Ticari Ek Kart',
                              isDark: isDark,
                              onTap: () =>
                                  cubit.setDraftCardType('Ticari Ek Kart'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: cubit.cardTitleController,
                          style: TextStyle(
                            color: isDark ? Colors.white : AppColors.darkNavy,
                          ),
                          decoration: InputDecoration(
                            labelText:
                                'Kart Adı / Etiketi (Örn: Alışveriş Kartı)',
                            labelStyle: TextStyle(
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                            ),
                            prefixIcon: const Icon(Icons.badge_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: cubit.cardHolderController,
                          validator: FinancialValidators.cardHolder,
                          style: TextStyle(
                            color: isDark ? Colors.white : AppColors.darkNavy,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Kart Üzerinde Yazacak İsim',
                            labelStyle: TextStyle(
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                            ),
                            prefixIcon: const Icon(Icons.person_outline_rounded),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: cubit.cardNumberController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  CardNumberInputFormatter(),
                                ],
                                validator: FinancialValidators.cardNumber,
                                style: TextStyle(
                                  color:
                                      isDark ? Colors.white : AppColors.darkNavy,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Kart Numarası',
                                  labelStyle: TextStyle(
                                    color: isDark
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF64748B),
                                  ),
                                  prefixIcon:
                                      const Icon(Icons.credit_card_rounded),
                                  suffixIcon: IconButton(
                                    tooltip: 'Yeni Numara Üret',
                                    icon: const Icon(Icons.autorenew_rounded),
                                    onPressed: cubit.regenerateDraftCardNumber,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: cubit.cardExpiryController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  ExpiryDateInputFormatter(),
                                ],
                                validator: FinancialValidators.expiry,
                                style: TextStyle(
                                  color:
                                      isDark ? Colors.white : AppColors.darkNavy,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'SKT (AA/YY)',
                                  labelStyle: TextStyle(
                                    color: isDark
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF64748B),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: cubit.cardLimitController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (v) {
                            final amount = int.tryParse((v ?? '').trim());
                            if (amount == null || amount <= 0) {
                              return 'Geçerli bir aylık limit giriniz.';
                            }
                            return null;
                          },
                          style: TextStyle(
                            color: isDark ? Colors.white : AppColors.darkNavy,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Aylık Harcama Limiti (₺)',
                            labelStyle: TextStyle(
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                            ),
                            prefixIcon: const Icon(Icons.tune_rounded),
                            suffixText: 'TL',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        Wrap(
                          spacing: 6,
                          children: const ['5000', '15000', '30000', '50000', '100000']
                              .map(
                                (limitStr) => ActionChip(
                                  label: Text('₺$limitStr'),
                                  labelStyle: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.darkNavy,
                                  ),
                                  backgroundColor: isDark
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFF1F5F9),
                                  onPressed: () =>
                                      cubit.setDraftLimitPreset(limitStr),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 16),

                        Text(
                          'KART TEMASI & RENGİ',
                          style: AppTextStyles.labelSmall.copyWith(
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            CardsManagementCubit.cardGradients.length,
                            (idx) {
                              final isSel = state.draftColorIndex == idx;
                              return GestureDetector(
                                onTap: () => cubit.setDraftColorIndex(idx),
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    gradient:
                                        CardsManagementCubit.cardGradients[idx],
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSel
                                          ? AppColors.primaryTeal
                                          : Colors.transparent,
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      if (isSel)
                                        BoxShadow(
                                          color: AppColors.primaryTeal
                                              .withValues(alpha: 0.5),
                                          blurRadius: 8,
                                        ),
                                    ],
                                  ),
                                  child: isSel
                                      ? const Icon(
                                          Icons.check_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        )
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),

                        Text(
                          'BAĞLANACAK HESAP / BAKİYE KAYNAĞI',
                          style: AppTextStyles.labelSmall.copyWith(
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: state.draftLinkedAccount,
                          isExpanded: true,
                          dropdownColor:
                              isDark ? const Color(0xFF1E293B) : Colors.white,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: isDark
                                ? const Color(0xFF0F172A)
                                : const Color(0xFFF8FAFC),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFCBD5E1),
                              ),
                            ),
                          ),
                          items: [
                            'PayPulse TRY FAST Cüzdanı',
                            ...state.bankAccounts.map((b) => b.bankName),
                          ].map((name) {
                            return DropdownMenuItem<String>(
                              value: name,
                              child: Text(
                                name,
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.darkNavy,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) cubit.setDraftLinkedAccount(val);
                          },
                        ),
                        const SizedBox(height: 16),

                        Text(
                          'KART GÜVENLİK VE İŞLEM İZİNLERİ',
                          style: AppTextStyles.labelSmall.copyWith(
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
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
                          subtitle: const Text(
                            'Online alışveriş ve abonelik ödemeleri',
                          ),
                          value: state.draftAllowOnline,
                          activeThumbColor: AppColors.primaryTeal,
                          onChanged: cubit.setDraftAllowOnline,
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
                          subtitle: const Text(
                            'Uluslararası sitelerde ve seyahatlerde geçerlilik',
                          ),
                          value: state.draftAllowInternational,
                          activeThumbColor: AppColors.primaryTeal,
                          onChanged: cubit.setDraftAllowInternational,
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
                          subtitle: const Text(
                            'Fiziksel POS cihazlarında temassız işlem',
                          ),
                          value: state.draftAllowContactless,
                          activeThumbColor: AppColors.primaryTeal,
                          onChanged: cubit.setDraftAllowContactless,
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
                              if (cubit.createCardFromDraft()) {
                                Navigator.of(bottomCtx).pop();
                              }
                            },
                            child: Text(
                              '${state.draftCardType} Oluştur',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showAddNewBankSheet(BuildContext context, CardsManagementCubit cubit) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomCtx) {
        return BlocProvider<CardsManagementCubit>.value(
          value: cubit,
          child: BlocBuilder<CardsManagementCubit, CardsManagementState>(
            builder: (sheetCtx, state) {
              return Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: MediaQuery.of(bottomCtx).viewInsets.bottom + 20,
                ),
                child: Form(
                  key: cubit.addBankFormKey,
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
                            icon: Icon(
                              Icons.close_rounded,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF64748B),
                            ),
                            onPressed: () => Navigator.of(bottomCtx).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Adınıza kayıtlı vadesiz TL hesabınızı FAST transferleri için bağlayın.',
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: cubit.bankNameController,
                        validator: (v) {
                          if (v == null || v.trim().length < 2) {
                            return 'Banka adını giriniz.';
                          }
                          return null;
                        },
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.darkNavy,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Banka Adı (Örn: Akbank Vadesiz TRY)',
                          labelStyle: TextStyle(
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                          prefixIcon: const Icon(
                            Icons.account_balance_outlined,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: cubit.ibanController,
                        validator: FinancialValidators.iban,
                        textCapitalization: TextCapitalization.characters,
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.darkNavy,
                        ),
                        decoration: InputDecoration(
                          labelText: 'IBAN (TR...)',
                          labelStyle: TextStyle(
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                          prefixIcon: const Icon(Icons.credit_card_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: state.draftBankAccountType,
                        dropdownColor:
                            isDark ? const Color(0xFF1E293B) : Colors.white,
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.darkNavy,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Hesap Türü',
                          labelStyle: TextStyle(
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Bireysel FAST Hesabı',
                            child: Text('Bireysel FAST Hesabı'),
                          ),
                          DropdownMenuItem(
                            value: 'Maaş ve Birikim Hesabı',
                            child: Text('Maaş ve Birikim Hesabı'),
                          ),
                          DropdownMenuItem(
                            value: 'Ticari / Şirket Hesabı',
                            child: Text('Ticari / Şirket Hesabı'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) cubit.setDraftBankAccountType(val);
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
                            if (cubit.linkBankAccountFromDraft()) {
                              Navigator.of(bottomCtx).pop();
                            }
                          },
                          child: const Text(
                            'Hesabı Bağla',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _CardPreviewTile extends StatelessWidget {
  final CardItem card;
  final bool showCardDetails;

  const _CardPreviewTile({
    required this.card,
    required this.showCardDetails,
  });

  @override
  Widget build(BuildContext context) {
    final maskedNumber = card.cardNumber.length >= 8
        ? '${card.cardNumber.substring(0, 4)} •••• •••• ${card.cardNumber.substring(card.cardNumber.length - 4)}'
        : card.cardNumber;

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
                    showCardDetails ? card.cardNumber : maskedNumber,
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: Colors.white,
                      letterSpacing: 1.8,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              if (showCardDetails) ...[
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
}

class _ChoiceChipItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _ChoiceChipItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
                  : (isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFCBD5E1)),
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
                    : (isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B)),
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
}
