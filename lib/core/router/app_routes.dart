class AppRoutes {
  const AppRoutes._();

  // Bireysel Cüzdan (B2C) Ana Sekmeleri
  static const String home = '/home';
  static const String qr = '/qr';
  static const String transactions = '/transactions';
  static const String budget = '/budget';
  static const String profile = '/profile';

  // Bireysel Alt Rotalar (Shell içinde kalır, BottomBar korunur)
  static const String fastTransfer = '/home/transfer';
  static const String fastReceipt = '/home/transfer/receipt/:txId';

  // İşletme Paneli (B2B - Admin & Employee) Ana Sekmeleri
  static const String businessOverview = '/business/overview';
  static const String businessPos = '/business/pos';
  static const String businessInvoices = '/business/invoices';
  static const String businessExpenses = '/business/expenses';
  static const String businessReports = '/business/reports';

  // İşletme Paneli Alt Rotalar (Shell içinde kalır, BottomBar korunur)
  static const String businessOcrScan = '/business/overview/ocr-scan';
  static const String businessBatchApproval =
      '/business/expenses/batch-approval';

  // Deep Link Özel Rotaları (Ödeme Linki / QR Tahsilat Talebi)
  static const String paymentRequestDeepLink = '/pay/:requestId';
}
