class AppStrings {
  AppStrings._();

  static const String appName = 'PayPulse';
  static const String defaultCurrency = 'TRY';
  static const String defaultCompanyId = 'comp_paypulse_tech';
  static const String defaultCompanyName = 'PayPulse Teknoloji A.Ş.';

  static const String roleB2C = 'b2c';
  static const String roleEmployee = 'employee';
  static const String roleAdmin = 'admin';

  static const String demoB2CUid = 'user_deniz_aksoy';
  static const String demoEmployeeUid = 'user_employee_ahmet';
  static const String demoAdminUid = 'user_admin_ali';

  static const String unauthorizedOperationError =
      'Bu işlem için yetkiniz bulunmamaktadır.';
  static const String invalidAmountError =
      'Lütfen geçerli ve pozitif bir tutar giriniz.';
  static const String fraudWarningMessage =
      '50.000,00 TL ve üzeri işlemler güvenlik (Fraud) kontrolüne tabidir.';
}
