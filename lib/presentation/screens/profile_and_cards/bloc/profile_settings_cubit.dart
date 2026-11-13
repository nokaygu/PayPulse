import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/equatable.dart';
import '../../../../domain/entities/user_entity.dart';

/// Profil ve Ayarlar ekranının değişmez (immutable) durum modeli.
class ProfileSettingsState extends Equatable {
  final UserEntity? user;
  final String phone;
  final bool biometricEnabled;
  final bool twoFactorEnabled;
  final bool pushNotifications;
  final bool smsNotifications;
  final bool campaignNotifications;
  final String sessionTimeout;
  final String currency;
  final String themeLabel;
  final String language;
  final bool kolasEmailLinked;
  final String? feedbackMessage;
  final bool isErrorFeedback;

  const ProfileSettingsState({
    this.user,
    this.phone = '+90 532 555 45 45',
    this.biometricEnabled = true,
    this.twoFactorEnabled = true,
    this.pushNotifications = true,
    this.smsNotifications = true,
    this.campaignNotifications = false,
    this.sessionTimeout = '5 Dakika',
    this.currency = '🇹🇷 TRY (₺)',
    this.themeLabel = 'Açık Tema',
    this.language = 'Türkçe (TR)',
    this.kolasEmailLinked = false,
    this.feedbackMessage,
    this.isErrorFeedback = false,
  });

  String get displayName =>
      (user?.name.trim().isNotEmpty ?? false) ? user!.name : 'PayPulse Kullanıcısı';

  String get displayEmail =>
      (user?.email.trim().isNotEmpty ?? false) ? user!.email : 'kullanici@paypulse.app';

  String get displayCustomerNo => user?.customerNo ?? 'PP-000000';

  String get displayIban =>
      user?.iban ?? 'TR34 0006 2000 0001 2345 6789 01';

  int get verificationLevel => user?.verificationLevel ?? 2;

  double get monthlyLimit => user?.monthlyLimit ?? 25000.0;

  double get spentThisMonth => user?.spentThisMonth ?? 0.0;

  double get limitUsageRatio => user?.limitUsageRatio ?? 0.0;

  ProfileSettingsState copyWith({
    UserEntity? user,
    String? phone,
    bool? biometricEnabled,
    bool? twoFactorEnabled,
    bool? pushNotifications,
    bool? smsNotifications,
    bool? campaignNotifications,
    String? sessionTimeout,
    String? currency,
    String? themeLabel,
    String? language,
    bool? kolasEmailLinked,
    String? feedbackMessage,
    bool? isErrorFeedback,
    bool clearFeedback = false,
  }) {
    return ProfileSettingsState(
      user: user ?? this.user,
      phone: phone ?? this.phone,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      campaignNotifications:
          campaignNotifications ?? this.campaignNotifications,
      sessionTimeout: sessionTimeout ?? this.sessionTimeout,
      currency: currency ?? this.currency,
      themeLabel: themeLabel ?? this.themeLabel,
      language: language ?? this.language,
      kolasEmailLinked: kolasEmailLinked ?? this.kolasEmailLinked,
      feedbackMessage:
          clearFeedback ? null : (feedbackMessage ?? this.feedbackMessage),
      isErrorFeedback:
          clearFeedback ? false : (isErrorFeedback ?? this.isErrorFeedback),
    );
  }

  @override
  List<Object?> get props => [
    user,
    phone,
    biometricEnabled,
    twoFactorEnabled,
    pushNotifications,
    smsNotifications,
    campaignNotifications,
    sessionTimeout,
    currency,
    themeLabel,
    language,
    kolasEmailLinked,
    feedbackMessage,
    isErrorFeedback,
  ];
}

/// Profil tercihleri, güvenlik ayarları ve form controller yaşam döngüsünü yönetir.
class ProfileSettingsCubit extends Cubit<ProfileSettingsState> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> editProfileFormKey = GlobalKey<FormState>();

  final TextEditingController oldPinController = TextEditingController();
  final TextEditingController newPinController = TextEditingController();
  final TextEditingController confirmPinController = TextEditingController();
  final GlobalKey<FormState> changePinFormKey = GlobalKey<FormState>();

  ProfileSettingsCubit({UserEntity? initialUser})
    : super(
        ProfileSettingsState(
          user: initialUser,
          themeLabel: _themeLabelFromMode(AppTheme.themeModeNotifier.value),
        ),
      );

  static String _themeLabelFromMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'Koyu Tema';
      case ThemeMode.light:
        return 'Açık Tema';
      case ThemeMode.system:
        return 'Sistem Varsayılanı';
    }
  }

  /// AuthBloc kullanıcı bilgisini güncel durumla eşitler.
  void syncUser(UserEntity? user) {
    if (user == state.user) return;
    emit(state.copyWith(user: user, clearFeedback: true));
  }

  /// Profil düzenleme alt penceresi açılmadan önce alanları mevcut verilerle doldurur.
  void prepareEditProfile() {
    nameController.text = state.displayName;
    phoneController.text = state.phone;
    emailController.text = state.displayEmail;
  }

  /// PIN değiştirme alt penceresi açılmadan önce eski girişleri temizler.
  void prepareChangePin() {
    oldPinController.clear();
    newPinController.clear();
    confirmPinController.clear();
  }

  void toggleBiometric(bool enabled) {
    emit(
      state.copyWith(
        biometricEnabled: enabled,
        feedbackMessage: enabled
            ? 'Biyometrik giriş etkinleştirildi.'
            : 'Biyometrik giriş devre dışı bırakıldı.',
        isErrorFeedback: false,
      ),
    );
  }

  void toggleTwoFactor(bool enabled) {
    emit(
      state.copyWith(
        twoFactorEnabled: enabled,
        feedbackMessage: enabled
            ? 'İki adımlı doğrulama (2FA) etkinleştirildi.'
            : 'İki adımlı doğrulama (2FA) pasif hale getirildi.',
        isErrorFeedback: false,
      ),
    );
  }

  void togglePushNotifications(bool enabled) {
    emit(state.copyWith(pushNotifications: enabled, clearFeedback: true));
  }

  void toggleSmsNotifications(bool enabled) {
    emit(state.copyWith(smsNotifications: enabled, clearFeedback: true));
  }

  void toggleCampaignNotifications(bool enabled) {
    emit(state.copyWith(campaignNotifications: enabled, clearFeedback: true));
  }

  void setSessionTimeout(String timeout) {
    emit(
      state.copyWith(
        sessionTimeout: timeout,
        feedbackMessage: 'Oturum süresi $timeout olarak güncellendi.',
        isErrorFeedback: false,
      ),
    );
  }

  void setCurrency(String currency) {
    emit(
      state.copyWith(
        currency: currency,
        feedbackMessage: 'Ana para birimi $currency olarak seçildi.',
        isErrorFeedback: false,
      ),
    );
  }

  void setThemeLabel(String label) {
    if (label == 'Koyu Tema') {
      AppTheme.setThemeMode(ThemeMode.dark);
    } else if (label == 'Açık Tema') {
      AppTheme.setThemeMode(ThemeMode.light);
    } else {
      AppTheme.setThemeMode(ThemeMode.system);
    }

    emit(
      state.copyWith(
        themeLabel: label,
        feedbackMessage: 'Tema: $label olarak ayarlandı.',
        isErrorFeedback: false,
      ),
    );
  }

  void linkKolasEmail() {
    emit(
      state.copyWith(
        kolasEmailLinked: true,
        feedbackMessage: 'E-posta KOLAS adresi olarak eşleştirildi.',
        isErrorFeedback: false,
      ),
    );
  }

  void savePhoneAndNotify({required String phone}) {
    emit(
      state.copyWith(
        phone: phone.trim().isEmpty ? state.phone : phone.trim(),
        feedbackMessage: 'Profil bilgileriniz başarıyla güncellendi.',
        isErrorFeedback: false,
      ),
    );
  }

  bool submitPinChange() {
    final oldPin = oldPinController.text.trim();
    final newPin = newPinController.text.trim();
    final confirmPin = confirmPinController.text.trim();

    if (oldPin.length < 4) {
      emitFeedback('Mevcut PIN kodunu en az 4 haneli giriniz.', isError: true);
      return false;
    }
    if (newPin.length < 4) {
      emitFeedback(
        'PIN kodu en az 4 veya 6 haneli olmalıdır.',
        isError: true,
      );
      return false;
    }
    if (newPin != confirmPin) {
      emitFeedback('Yeni PIN kodları birbiriyle uyuşmuyor.', isError: true);
      return false;
    }

    emitFeedback('Cüzdan PIN kodu başarıyla güncellendi.');
    return true;
  }

  void emitFeedback(String message, {bool isError = false}) {
    emit(
      state.copyWith(
        feedbackMessage: message,
        isErrorFeedback: isError,
      ),
    );
  }

  void clearFeedback() {
    emit(state.copyWith(clearFeedback: true));
  }

  @override
  Future<void> close() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    oldPinController.dispose();
    newPinController.dispose();
    confirmPinController.dispose();
    return super.close();
  }
}

