# PayPulse — Merge Conflict Çözümü, QR Entegrasyonu & `widgets/` Mimari Refactoring Planı

> **Durum:** Planlama aşaması (henüz `.dart` kodu değiştirilmemiştir; depo `.git/MERGE_HEAD = cd736f0` aşamasında `29` çakışmalı dosya ile beklemektedir).
> **Bağlam:** `origin/main` üzerinden gelen PR `#23` (`cd736f0 feat/qr_kod`, taban commit `7fcd02f`), yerel `HEAD` (`d9b34a6 changes` — Clean Architecture, UseCase, Cubit/BLoC ve `StatelessWidget` dönüşümü) ile çakışmaktadır. Ayrıca `cd736f0` fonksiyonel QR özelliklerini eklemiş olsa da QR sekmesindeki `RenderBox` beyaz ekran kök nedenini (`AppTheme` sonsuz genişlik) düzeltmemiştir. Tüm adımlar sırayla uygulanabilmesi için tiklenebilir (`- [ ]`) biçimde düzenlenmiştir.

---

## 🔀 Bölüm 0: `git merge` (`d9b34a6` ↔ `cd736f0`) Çakışma Çözümü & Yeni QR Entegrasyonu

### Mevcut Git Merge Durumu
- **Tamamlanan/Stage edilmiş dosyalar (`9` dosya — `cd736f0`'dan temiz geldi):**
  - Kamera izinleri: `android/app/src/main/AndroidManifest.xml`, `ios/Runner/Info.plist`, `macos/Runner/Info.plist`, `macos/Runner/DebugProfile.entitlements`, `macos/Runner/Release.entitlements`
  - QR Payload altyapısı ve testleri: `lib/core/utils/qr_payload_parser.dart` (`PayPulseQrPayload`, `defaultTtlSeconds = 48`), `test/core/qr_payload_parser_test.dart`
  - Yardımcı format & liste satırı factory: `lib/core/utils/financial_amount.dart` (`symbol` parametresi + `formatLira`), `lib/presentation/widgets/transaction_list_tile_widget.dart` (`TransactionListTileWidget.fromEntity`)
- **Çakışan dosyalar (`29` Unmerged dosya):** `2` adet `UD` (`deleted by them`) + `27` adet `UU` (`both modified`).
- **Temel Çözüm Stratejisi:** `cd736f0` dalındaki eski `StatefulWidget` / doğrudan Repository-Datasource çağrılarına geri dönüş **reddedilecek**, `HEAD` (`d9b34a6`) Clean Architecture + BLoC/Cubit + `StatelessWidget` omurgası korunacak; buna karşılık `cd736f0`'ın getirdiği **gerçek `PayPulseQrPayload` (48sn dinamik QR), `MobileScanner` kamera okuyucu, pano yapıştırma/kopyalama, tutar/fiş akışları ve B2C doğrudan QR transferi (`executeFastTransfer`)** Clean Architecture katmanlarına ve `QrPaymentCubit` / `VirtualPosCubit` içine entegre edilecektir.

### 0.1. Silinen Çekirdek Sabitlerin Kurtarılması (`UD` — 2 Dosya)
- [x] **0.1.1. `lib/core/constants/app_limits.dart` dosyasını koru:** `cd736f0` tarafından silinen bu dosyayı `HEAD` sürümüyle koru (`transaction_entity.dart`, `execute_fast_transfer_use_case.dart`, `virtual_pos_cubit.dart`, `qr_payment_cubit.dart`, `business_overview_cubit.dart`, `transfer_cubits.dart` ve `test/domain/use_cases_test.dart` bu sınıfa bağımlıdır). `AppLimits.qrCountdownSeconds` sabitini `PayPulseQrPayload.defaultTtlSeconds` (`48` saniye) ile uyumlu hale getir (`48` olarak hizalayıp ilgili cubit/test beklentilerini kontrol et).
- [x] **0.1.2. `lib/core/constants/app_strings.dart` dosyasını koru:** `cd736f0` tarafından silinen bu dosyayı `HEAD` sürümüyle koru (`user_repository.dart` ve `approve_or_reject_expense_use_case.dart` bu sabitleri kullanmaktadır).

### 0.2. Domain Katmanı Sözleşmeleri (`UU` — 6 Dosya: `lib/domain/repositories/`)
- [x] **0.2.1. `i_company_repository.dart`, `i_expense_repository.dart`, `i_payment_request_repository.dart`, `i_user_repository.dart`, `i_wallet_repository.dart` (`5` dosya, 1'er conflict):** `HEAD` (`ours`) tarafındaki eksiksiz Clean Architecture sözleşmelerini (`createCompany`, `approvedBy`/`rejectedBy`/`uploadReceiptImage`, `completePaymentRequestWithWallet`, `watchAuthUser`/`login`/`register`/`logout`/`getDemoUserByRole`/`updateFcmToken`/`seedDemoData`, `getUserWallet`/`createWallet`/`updateWallet`) koru.
- [x] **0.2.2. `i_transaction_repository.dart` (`3` conflict):** `HEAD` sözleşmesini (`getSentTransactions`, `findRecipientByIban`, `getSavedRecipients`, `executeFastTransferByIban`, `executeQrWalletPayment`, `executeCardPosPayment`, `getPosTransactions`) koru **ve `cd736f0`'dan `executeFastTransfer` metodunu ekle:**
  ```dart
  Future<TransactionEntity> executeFastTransfer({
    required String senderUserId,
    required String receiverUserId,
    required int amountKurus,
    String currency = 'TRY',
    String? targetIban,
  });
  ```
  *(B2C TR Karekod okutulduğunda, alıcı kullanıcının `safe_recipients` listesinde kayıtlı olmasına gerek kalmadan `receiverUserId` ile doğrudan B2C transferi çalıştırmak için gereklidir.)*

### 0.3. Data Katmanı Kaynak ve Repository Çakışmaları (`UU` — 8 Dosya)
- [x] **0.3.1. `lib/data/repositories/` (`company_repository.dart` [2], `expense_repository.dart` [4], `payment_request_repository.dart` [2], `user_repository.dart` [5], `wallet_repository.dart` [4]):** `HEAD` implementasyonlarını (`AppStrings`, tam `Entity` dönüşümleri ve ek UseCase metodları) koru; conflict işaretçilerini temizle.
- [x] **0.3.2. `lib/data/repositories/transaction_repository.dart` (`3` conflict):** `HEAD` implementasyonunu koru ve `ITransactionRepository.executeFastTransfer` delegasyonunu ekle (gelen entity model dönüşümüyle birlikte `_firestoreDatasource.executeFastTransfer(...)` çağıracak).
- [x] **0.3.3. `lib/data/datasources/remote/firebase_firestore_datasource.dart` (`3` conflict):** `HEAD` sürümünü koru (`HEAD` zaten tüm metotlarda `AppMode.isDemoMode` yönlendirmesini ve tam parametreleri barındırır); `executeFastTransfer` metodunun `LocalDemoDataService.executeFastTransfer` ile imzasının uyumlu olduğunu doğrula.
- [x] **0.3.4. `lib/data/datasources/remote/local_demo_data_service.dart` (`10` conflict):** `HEAD` yapısını koru ve `cd736f0`'dan `executeFastTransfer(...)` + ortak `_performDemoFastTransfer(..., required String recipientDisplayName)` yardımcı yapısını entegre et; böylece hem IBAN üzerinden (`executeFastTransferByIban`) hem de B2C QR üzerinden (`executeFastTransfer`) demo cüzdan bakiyeleri ve bildirimleri tutarlı çalışsın.

### 0.4. Auth BLoC Çakışmaları (`UU` — 3 Dosya)
- [x] **0.4.1. `lib/presentation/screens/auth/bloc/` (`auth_bloc.dart` [6], `auth_event.dart` [3], `auth_state.dart` [5]):** `HEAD` sürümünü koru (`IUserRepository` üzerinden tam giriş/kayıt/profil yükleme/FCM ve test uyumluluğu `HEAD` tarafında tamdır; `cd736f0` yalnızca eski ara dönüşümdür).

### 0.5. Mevcut Cubit Mimarisine Geçmiş Ekran & AppBar Çakışmaları (`UU` — 8 Dosya)
> Aşağıdaki 8 dosyada `cd736f0` dalı hala eski `StatefulWidget` ve ekran içi doğrudan `Repository`/`StreamBuilder` yapısını içermektedir; `HEAD` dalı ise bunları Clean Architecture + `Cubit` + `StatelessWidget` yapısına geçirmiştir.
- [x] **0.5.1. `lib/presentation/widgets/role_switch_app_bar.dart` (`4` conflict):** `HEAD` (`NotificationCubit` + `StatelessWidget`) sürümünü koru.
- [x] **0.5.2. `lib/presentation/screens/analytics_and_reports/transaction_history_screen.dart` (`3` conflict):** `HEAD` (`TransactionHistoryCubit` + `StatelessWidget`) sürümünü koru; varsa `TransactionListTileWidget.fromEntity` / `FinancialAmount` sadeleştirmelerinden yararlan.
- [x] **0.5.3. `lib/presentation/screens/b2b_operations/b2b_expense_approval_center_screen.dart` (`4` conflict):** `HEAD` (`ExpenseApprovalCubit` + `StatelessWidget`) sürümünü koru (`FinancialAmount.format` uyumu zaten var/uygulanacak).
- [x] **0.5.4. `lib/presentation/screens/home_wallet_and_safe/home_screen.dart` (`7` conflict):** `HEAD` (`HomeWalletCubit` & `BusinessOverviewCubit` + `StatelessWidget`) sürümünü koru; `TransactionListTileWidget.fromEntity` kullanımını kontrol et.
- [x] **0.5.5. `lib/presentation/screens/qr_and_ocr/e_invoice_gib_list_screen.dart` (`3` conflict):** `HEAD` (`EInvoiceCubit` + `StatelessWidget`) sürümünü koru; tutar formatında `FinancialAmount.formatLira` kullanımını eşitle.
- [x] **0.5.6. `lib/presentation/screens/qr_and_ocr/ocr_camera_scanner_screen.dart` (`5` conflict):** `HEAD` (`OcrScannerCubit` + `StatelessWidget`) sürümünü koru; `FinancialAmount.formatLira` tutarlılığını eşitle.
- [x] **0.5.7. `lib/presentation/screens/transfer/transfer_receipt_screen.dart` (`3` conflict):** `HEAD` (`TransferReceiptCubit` + `StatelessWidget`) sürümünü koru (`FinancialAmount.format` kontrolü dahil).
- [x] **0.5.8. `lib/presentation/screens/transfer/transfer_summary_screen.dart` (`4` conflict):** `HEAD` (`TransferSummaryCubit` + `StatelessWidget`) sürümünü koru (`FinancialAmount.format` kontrolü dahil).

### 0.6. Yeni QR Kod (`cd736f0`) Özelliklerinin `Cubit` + `StatelessWidget` Mimarisine Entegrasyonu (`UU` — 2 Ekran + 2 Cubit)
- [x] **0.6.1. `QrPaymentCubit` & `qr_payment_center_screen.dart` (`2` conflict) Birleştirmesi:**
  - `cd736f0`'daki `StatefulWidget` + `Timer` + `FirebaseAuth` + doğrudan `TransactionRepository` yapısı yerine **`HEAD`'in `StatelessWidget` + `QrPaymentCubit` omurgasını** koru.
  - `QrPaymentCubit` & `QrPaymentState` (`lib/presentation/screens/qr_and_ocr/bloc/qr_payment_cubit.dart`) içine `cd736f0`'ın tüm gerçek QR yeteneklerini taşı:
    - `PayPulseQrPayload.defaultTtlSeconds` (`48` sn) geri sayım, `generationCount`, `generatedAt` ve `PayPulseQrPayload.generateDynamicToken(prefix: 'PPB2C')`,
    - `PayPulseQrPayload.buildB2cPayload(...)` ile dinamik TR Karekod metni üretimi ve hızlı tutar seçimi (`Serbest`, `₺100`, `₺250`, `₺500`),
    - Kamera durumu (`isCameraActive`, `hasHandledCameraFrame`) ve `MobileScanner` üzerinden okutulan QR verisini iletme,
    - `PayPulseQrPayload.tryParse(rawData)` ile QR çözümleme, `parsed.isExpired()` (`48` sn süre dolumu) kontrolü, `parsed.amount <= 0` ise kullanıcıdan tutar isteme akışı (`pendingZeroAmountQr` / dialog tetikleme),
    - Mod bazlı ödeme çalıştırma: `B2C` + farklı `targetUserId` → `ITransactionRepository.executeFastTransfer(...)`, `B2B_POS` / `EXTERNAL` → `ITransactionRepository.executeQrWalletPayment(...)`, legacy deep-link `paypulse://pay/:id` → `IPaymentRequestRepository`,
    - Başarılı QR ödeme sonrası slip bilgisi (`QrPaymentReceipt` state alanı) üreterek UI'da `QrPaymentSuccessDialog` açtırma, pano yapıştırma/kopyalama ve hazır senaryo simülasyon kartlarını koruma.
- [x] **0.6.2. `VirtualPosCubit` & `virtual_pos_terminal_screen.dart` (`19` conflict) Birleştirmesi:**
  - **`HEAD`'in `StatelessWidget` + `VirtualPosCubit` omurgasını** koru; `cd736f0`'ın `StatefulWidget` haline geri dönme.
  - `VirtualPosCubit` & `VirtualPosState` (`lib/presentation/screens/b2b_operations/bloc/virtual_pos_cubit.dart`) içine `cd736f0`'ın B2B QR POS yeniliklerini taşı:
    - `48` saniyelik dinamik POS QR timer'ı, `qrGenerationCount`, `remainingQrSeconds`, `qrGeneratedAt`, `regeneratePosQr()`, `PayPulseQrPayload.buildB2bPosPayload(...)`,
    - **Müşteri B2C QR Okut & Tahsil Et** akışı: kamera (`MobileScanner`) / pano yapıştırma / manuel kod metnini `PayPulseQrPayload.tryParse` ile ayrıştırma, `isExpired()` kontrolü, müşteri cüzdanından tahsilat (`submitQrPayment`),
    - `PosTransactionEntity` / POS fiş listesi ve slip diyalogunda QR token & `PayPulse Dinamik QR (48sn)` bilgisi gösterimi.
- [x] **0.6.3. Merge Çakışma Temizliği Doğrulaması:** Tüm 29 dosya çözüldükten sonra `git diff --name-status --diff-filter=U` çıktısının boş (`0` çakışma) olduğunu ve derleme hatası kalmadığını doğrula (`android/ios/macos` kamera izinleri ve `qr_payload_parser.dart` / `qr_payload_parser_test.dart` stage edilmiş olarak kalacak).

---

## 🔴 Bölüm 1: QR Sekmesi Beyaz Ekran & `RenderBox was not laid out` Hatası

### Tespit Edilen Sorun ve Kök Neden (Merge Sonrası Güncel Analiz)
1. **Global Tema Kök Nedeni Hala Aktif (`AppTheme`):**
   - `cd736f0` PR'ı `lib/core/theme/app_theme.dart` dosyasına hiç dokunmamıştır. Diskteki güncel dosyada hem `lightTheme` (`satır 88`) hem `darkTheme` (`satır 191`) için `elevatedButtonTheme` içinde halen **`minimumSize: const Size(double.infinity, 52)`** tanımlıdır.
2. **QR Sekmesi ve Sanal POS İçindeki Tetikleyiciler:**
   - `HEAD` (`qr_payment_center_screen.dart`): `_ShowMyQrCard` içindeki `Row` (`satır 246`), `Expanded(TextField)` yanında doğrudan `ElevatedButton('QR Oluştur')` (`satır 263`) barındırır; sınırsız yatay kısıt (`maxWidth = double.infinity`) altında `minWidth = double.infinity` çökerek `RenderFlex` → `SingleChildScrollView` → `RenderCustomPaint#19ef1` (`up6` → `up1`) hattında layout iptaline ve saniyelik timer rebuild'leriyle `'!_debugDoingThisLayout': is not true` beyaz ekran hatasına yol açar.
   - `cd736f0` (`MERGE_HEAD`): `qr_payment_center_screen.dart` içindeki **`Row` içi `ElevatedButton('Çözümle & Öde')` (`satır 1059`)** ve **`Stack > Positioned` içindeki `ElevatedButton.icon('Kamerayı Kapat')` (`satır 927`)** ile `virtual_pos_terminal_screen.dart` içindeki **müşteri QR okutma diyalogunun `Row > ElevatedButton` (`satır 652`)** bileşenleri de `minimumSize` geçersiz kılınmadığı için aynı global `AppTheme` hatasından etkilenmektedir.
3. **İkincil Yatay Kısıt & `ParentDataWidget` Riskleri:**
   - **Aynı `AppTheme` Riski (`AlertDialog.actions`):** `e_invoice_gib_list_screen.dart`, `b2b_expense_approval_center_screen.dart`, `virtual_pos_terminal_screen.dart`, `transfer_summary_screen.dart`, `home_screen.dart`, `profile_settings_screen.dart` ve `cd736f0` QR başarı/tutar diyaloglarındaki `AlertDialog.actions` içi `ElevatedButton`'lar.
   - **`StatelessWidget` İçinde `Expanded` Kullanımı:** `_ModeTab` (`qr_payment_center_screen.dart:149`), `_TabButton` (`e_invoice_gib_list_screen.dart`) ve `_DocModeTab` (`ocr_camera_scanner_screen.dart`) doğrudan `Expanded(...)` döndürmektedir (`ParentDataWidget` çağrı noktasındaki `Row` içinde olmalıdır).

### Çözüm Adımları
- [x] **1.1. Global `AppTheme` `ElevatedButton` Kök Nedenini Düzelt:** `lib/core/theme/app_theme.dart` içinde `lightTheme` (`satır 88`) ve `darkTheme` (`satır 191`) `elevatedButtonTheme` ayarlarında `minimumSize: const Size(double.infinity, 52)` yerine `minimumSize: const Size(0, 52)` tanımla; tam genişlik gereken yerlerde mevcut `SizedBox(width: double.infinity, ...)` sarmalayıcılarını koru/doğrula.
- [x] **1.2. QR & POS İçindeki Tüm `Row`/`Positioned` `ElevatedButton`'ları Güvenli Kıl:**
  - `lib/presentation/screens/qr_and_ocr/widgets/show_my_qr_card.dart` içinde talep tutarı / üret butonuna sonlu `minimumSize` (`Size(116, 52)`) ver.
  - `lib/presentation/screens/qr_and_ocr/widgets/scan_qr_card.dart` içinde `Row` içindeki `Çözümle & Öde` butonuna ve `MobileScanner` üzerindeki `Kamerayı Kapat` `ElevatedButton.icon` butonuna sonlu `minimumSize` ve temiz `padding` tanımla.
  - `lib/presentation/screens/b2b_operations/widgets/pos_customer_qr_scanner_dialog.dart` (yeni ayrıştırılacak müşteri B2C QR okutma modalı) içinde `Row` yanındaki `ElevatedButton` için sonlu `minimumSize` tanımla.
- [x] **1.3. `ParentDataWidget` (`Expanded`) Kullanımını Düzelt:** `qr_mode_switcher.dart` (`_ModeTab`), `invoice_direction_tab_bar.dart` (`_TabButton`) ve `ocr_doc_mode_selector.dart` (`_DocModeTab`) bileşenlerinde `Expanded`'ı alt widget gövdesinden çıkarıp doğrudan çağrı yerindeki `Row` içine taşı.
- [x] **1.4. `AlertDialog.actions` İçi `ElevatedButton`'ları Doğrula:** QR tutar girişi, QR başarı fişi, POS slip ve diğer ekran dialoglarındaki `ElevatedButton`'ların `AppTheme` düzeltmesiyle overflow/layout hatası üretmediğini kontrol et.
- [x] **1.5. QR & POS Ekranı Widget Testlerini Ekle:** `test/presentation/router_and_screens_widget_test.dart` (veya özel QR widget test grubu) içinde `AppTheme.lightTheme` ve `AppTheme.darkTheme` altında `QrPaymentCenterScreen` (her iki sekme + tutar chipleri + 48sn sayaç) ve `VirtualPosTerminalScreen` QR sekmesinin `0` `FlutterError` ile render olduğunu doğrula.

---

## 🧱 Bölüm 2: `lib/presentation/screens/` → `widgets/` Oluşturma & 40 Satırı Geçen UI Yapılarını Taşıma Planı

### Mevcut Durum Analizi ve Mimari Kurallar
- **Diskteki Güncel Klasör Durumu:**
  - `splash_and_onboarding/widgets/splash_brand_content.dart` (`1` dosya) ve `qr_and_ocr/widgets/` (`9` dosya) şu anda **0 baytlık boş yer tutuculardır** (henüz doldurulmamıştır).
  - `analytics_and_reports/`, `auth/`, `b2b_operations/`, `home_wallet_and_safe/`, `profile_and_cards/` ve `transfer/` klasörlerinde `widgets/` alt klasörü henüz yoktur.
- **Taşıma Kuralları:**
  - [x] Tüm `8` aktif screen klasörü altında standart **`bloc/` + `widgets/` + `*_screen.dart`** dizilimi kurulacak ve 0 baytlık boş dosya kalmayacak.
  - [x] Çıkarılan her widget **kesinlikle `StatelessWidget`** olacak; `StatefulWidget`, `State<...>`, `TextEditingController`, `Timer` veya `BlocProvider` barındırmayacak.
  - [x] **40 satırı geçen tüm UI yapıları** — private `_Widget` sınıfları, `_show*Sheet`, `_show*Dialog`, `_build*Section`, `_build*Tile` metotları ve `build()` içindeki `40+` satırlık inline kart/form/hero/liste blokları dahil — `widgets/` altına ayrılacak.
  - [x] `200+` satırlık büyük kart/sheet widget'ları içeride alt `StatelessWidget` parçalarına bölünerek okunabilirlik ve tek sorumluluk korunacak.

---

### 2.1. `lib/presentation/screens/auth/` (`widgets/` oluşturulacak)
*Mevcut: `login_screen.dart` (619 satır), `register_screen.dart` (568 satır)*
- [x] `lib/presentation/screens/auth/widgets/` klasörünü oluştur.
- [x] `login_screen.dart` içindeki `_DemoRoleCard` (`126` satır) → `widgets/demo_role_card.dart` (`DemoRoleCard`).
- [x] `_LoginView.build` (`436` satır) içindeki 40+ satırlık blokları ayır:
  - Logo + marka başlığı (`register_screen.dart` ile ortak kullanım) → `widgets/auth_brand_header.dart`
  - E-posta, şifre, beni hatırla ve giriş butonu formu → `widgets/login_form_card.dart`
  - Hızlı demo giriş bölümü + kayıt yönlendirme alanı → `widgets/demo_quick_login_section.dart`
- [x] `_RegisterView.build` (`469` satır) içindeki kayıt formu, şifre doğrulama kuralları, rol seçici ve KVKK onay bloğunu → `widgets/register_form_card.dart` (ve gerekirse alt form kartı bileşenleri) olarak çıkar.

---

### 2.2. `lib/presentation/screens/splash_and_onboarding/` (`widgets/splash_brand_content.dart` doldurulacak)
*Mevcut: `splash_screen.dart` (113 satır), `widgets/splash_brand_content.dart` (0 bayt yer tutucu)*
- [x] `_SplashView.build` (`80` satır) gövdesindeki logo, marka başlığı, alt slogan ve yükleme göstergesi yapısını `widgets/splash_brand_content.dart` (`SplashBrandContent`) içine çıkar; `splash_screen.dart` dosyasını sadece `BlocProvider` + yönlendirme dinleyicisi + `SplashBrandContent` barındıran sade ekran kabuğuna indir.

---

### 2.3. `lib/presentation/screens/home_wallet_and_safe/` (`widgets/` oluşturulacak)
*Mevcut (HEAD): `home.dart` (616 satır), `home_screen.dart` (1953 satır)*
- [x] `lib/presentation/screens/home_wallet_and_safe/widgets/` klasörünü oluştur.
- [x] **`home.dart` (`/developer-console`) 40+ satırlık bölümleri ayır:**
  - Ortak test kartı sarmalayıcısı + `_buildActiveUserSection` (`108` satır) → `widgets/dev_active_user_section.dart`
  - `_buildAuthSection` (`59` satır) → `widgets/dev_auth_test_section.dart`
  - `_buildTransferSection` (`59` satır) → `widgets/dev_transfer_test_section.dart`
  - `_buildNotificationsSection` (`75` satır) → `widgets/dev_notifications_test_section.dart`
  - `_buildTransactionsSection` (`52` satır) → `widgets/dev_transactions_test_section.dart`
  - `_buildExpenseSection` (`90` satır) + `_buildPosSection` (`36` satır) → `widgets/dev_expense_and_pos_test_sections.dart` (veya ayrı dosyalar).
- [x] **`home_screen.dart` (`HomeScreen` + `BusinessSafeOverviewScreen`) 40+ satırlık widget ve metotları ayır:**
  - `_TransactionTileItem` (`41` satır) + `_CurrencyChip` → `widgets/home_transaction_tile_item.dart` (mümkünse `TransactionListTileWidget.fromEntity` ile sadeleştirilecek)
  - `_MetricCard` (`90` satır) → `widgets/business_metric_card.dart`
  - `_QuickActionBox` (`101` satır) + `_SmallToggle` → `widgets/business_quick_action_box.dart`
  - `_HomeWalletView.build` (`418` satır) bölümleri → `widgets/personal_wallet_hero_card.dart`, `widgets/personal_quick_actions_row.dart`, `widgets/demo_seed_banner_card.dart`, `widgets/recent_transactions_card.dart`
  - `_BusinessOverviewView` (`1135` satır) bölümleri ve modal sheet/dialogları:
    - `widgets/business_safe_hero_card.dart`, `widgets/business_weekly_cashflow_card.dart`, `widgets/business_quick_actions_grid.dart`, `widgets/business_pending_expenses_card.dart`
    - `_showTransferToAccountSheet` (`162` satır) → `widgets/business_transfer_to_account_sheet.dart`
    - `_showTopUpBalanceSheet` (`138` satır) → `widgets/business_top_up_balance_sheet.dart`
    - `_showReceiptInspectDialog` (`59` satır) → `widgets/expense_receipt_inspect_dialog.dart`

---

### 2.4. `lib/presentation/screens/transfer/` (`widgets/` oluşturulacak)
*Mevcut (HEAD): `transfer_recipient_screen.dart` (315 satır), `transfer_amount_screen.dart` (244 satır), `transfer_summary_screen.dart` (706 satır), `transfer_receipt_screen.dart` (113 satır)*
- [x] `lib/presentation/screens/transfer/widgets/` klasörünü oluştur.
- [x] `transfer_recipient_screen.dart`: `_RecipientCard` (`48` satır) → `widgets/recipient_card.dart`; IBAN giriş kartı & kayıtlı alıcılar → `widgets/transfer_iban_input_card.dart`, `widgets/saved_recipients_section.dart`.
- [x] `transfer_amount_screen.dart`: `_TransferAmountView.build` (`189` satır) içindeki alıcı banner + tutar/kategori/açıklama kartını `widgets/transfer_amount_entry_card.dart` içine çıkar.
- [x] `transfer_summary_screen.dart`: `_StepCircle` (`51` satır) + adım çubuğu → `widgets/transfer_step_indicator.dart`; `_showFraudConfirmationDialog` (`47` satır) → `widgets/fraud_confirmation_dialog.dart`; ödeme talebi/tutar/detay/güvenlik kartları → `widgets/transfer_summary_details_card.dart`, `widgets/transfer_payment_request_card.dart`, `widgets/transfer_security_notice_card.dart`.
- [x] `transfer_receipt_screen.dart`: `FourStateView` içindeki 54 satırlık dekont gövdesini → `widgets/transfer_receipt_content.dart` olarak çıkar.

---

### 2.5. `lib/presentation/screens/qr_and_ocr/` (`widgets/` 9 yer tutucu doldurulacak + eksikler eklenecek)
*Mevcut (HEAD + yeni `cd736f0` QR entegrasyonu): `qr_payment_center_screen.dart`, `ocr_camera_scanner_screen.dart`, `ocr_data_verification_screen.dart` (319 satır), `e_invoice_gib_list_screen.dart` (1083 satır)*
- [x] `qr_payment_center_screen.dart` + **`cd736f0` yeni QR bileşenleri:**
  - `widgets/qr_mode_switcher.dart` (`Expanded` dışarı alınarak)
  - `widgets/show_my_qr_card.dart` *(Bölüm 1 buton kısıtı düzeltmesi + 48sn `PayPulseQrPayload` dinamik QR kodu, tutar chipleri, yeni QR üret ve pano kopyala butonları dahil)*
  - `widgets/scan_qr_card.dart` *(`MobileScanner` canlı kamera / simüle vizör, kamerayı aç/kapat butonu, panodan yapıştır + `Çözümle & Öde` `Row` düzeltmesi ve B2B/B2C demo test senaryo kartları dahil)*
  - `widgets/qr_payment_dialogs.dart` *(`cd736f0`'dan gelen 0 TL tutar girişi diyalogu ve QR ödeme başarı fişi diyalogu — `StatelessWidget` olarak)*
- [x] `ocr_camera_scanner_screen.dart`:
  - `widgets/ocr_doc_mode_selector.dart` (`Expanded` çağrı noktasına taşınacak)
  - `widgets/ocr_viewfinder_card.dart`
  - `widgets/ocr_scanner_actions_bar.dart`
  - `widgets/ocr_sample_picker_sheet.dart`
- [x] `ocr_data_verification_screen.dart`:
  - `widgets/ocr_verification_form_card.dart`
  - `widgets/ocr_vat_and_category_selector.dart`
- [x] `e_invoice_gib_list_screen.dart`:
  - `widgets/invoice_volume_hero_card.dart` (`136` satır)
  - `widgets/invoice_direction_tab_bar.dart` (`_TabButton`, `Expanded` dışarı alınarak)
  - `widgets/invoice_list_card.dart` (`_InvoiceCard` `278` satır — alt satır/detay bileşeniyle bölünerek)
  - `widgets/invoice_doc_type_filter_sheet.dart` (`_showDocTypeFilterSheet`)
  - `widgets/invoice_fast_payment_dialog.dart` (`_showFastPaymentDialog`)
  - `widgets/invoice_filter_header.dart`

---

### 2.6. `lib/presentation/screens/b2b_operations/` (`widgets/` oluşturulacak)
*Mevcut (HEAD + yeni `cd736f0` POS QR entegrasyonu): `b2b_expense_approval_center_screen.dart` (927 satır), `bulk_expense_erp_receipt_screen.dart` (534 satır), `virtual_pos_terminal_screen.dart` (1131+ satır)*
- [x] `lib/presentation/screens/b2b_operations/widgets/` klasörünü oluştur.
- [x] `b2b_expense_approval_center_screen.dart`:
  - `widgets/pending_summary_hero_card.dart` (`_PendingSummaryHeroCard`)
  - `widgets/expense_review_card.dart` (`_ExpenseReviewCard`)
  - `widgets/expense_filter_dialog.dart` (`_showFilterDialog`)
  - `widgets/expense_sort_dialog.dart` (`_showSortDialog`)
  - `widgets/expense_reject_dialog.dart` (`_showRejectDialog`)
  - `widgets/expense_status_tab_bar.dart` (`_TabPill` + arama/filtre barı)
- [x] `bulk_expense_erp_receipt_screen.dart`:
  - `widgets/batch_success_card.dart` (`_BatchSuccessCard`)
  - `widgets/erp_integration_card.dart` (`_ErpIntegrationCard`)
  - `widgets/approved_expense_line_item.dart` (`_ApprovedLineItem`)
  - `widgets/approved_expenses_list_card.dart` (`build` içindeki liste + aksiyon çubuğu)
- [x] `virtual_pos_terminal_screen.dart` + **`cd736f0` yeni B2B POS QR bileşenleri:**
  - `widgets/pos_tab_switcher.dart` (`_PosTabPill`)
  - `widgets/pos_amount_entry_card.dart` (`_AmountEntryCard` + `_QuickAddButton`)
  - `widgets/pos_card_preview.dart` (`_PosCardPreview`)
  - `widgets/pos_card_payment_form_card.dart` (`_CardPaymentFormCard`)
  - `widgets/pos_commission_summary_card.dart` (`_CommissionSummaryCard`)
  - `widgets/pos_qr_payment_card.dart` (`_QrPaymentCard` + 48sn `PayPulseQrPayload` dinamik kasa QR, `Yeni QR Üret (48sn)`, `QR Kodu Kopyala` ve `Müşterinin B2C QR Kodunu Okutarak Tahsil Et` butonu)
  - `widgets/pos_customer_qr_scanner_dialog.dart` *(`cd736f0`'dan gelen müşteri B2C QR okutma modalı: `MobileScanner` + pano/manuel giriş, `Row` içi `ElevatedButton` sonlu genişlik düzeltmesi ile)*
  - `widgets/pos_z_report_sheet.dart` (`_showZReportBottomSheet`)
  - `widgets/pos_payment_slip_dialog.dart` (`_showSlipDialog` + `_SlipRow` — 48sn QR slip bilgileri dahil)

---

### 2.7. `lib/presentation/screens/analytics_and_reports/` (`widgets/` oluşturulacak)
*Mevcut (HEAD): `budget_analytics_screen.dart` (1077 satır), `tax_and_vat_report_screen.dart` (905 satır), `transaction_history_screen.dart` (674 satır)*
- [x] `lib/presentation/screens/analytics_and_reports/widgets/` klasörünü oluştur.
- [x] `budget_analytics_screen.dart`: `widgets/budget_period_tab_bar.dart`, `widgets/budget_quota_hero_card.dart`, `widgets/budget_weekly_trend_card.dart`, `widgets/budget_category_breakdown_card.dart`, `widgets/budget_category_box.dart`, `widgets/budget_savings_goal_card.dart`, `widgets/budget_advice_card.dart`.
- [x] `tax_and_vat_report_screen.dart`: `widgets/net_vat_hero_card.dart`, `widgets/vat_declaration_draft_card.dart`, `widgets/vat_distribution_card.dart`, `widgets/vat_expense_matrah_card.dart`, `widgets/accountant_export_card.dart`.
- [x] `transaction_history_screen.dart`: `widgets/transaction_net_summary_hero_card.dart`, `widgets/highlighted_fast_card.dart`, `widgets/transaction_search_and_filter_bar.dart`, `widgets/transaction_grouped_list_section.dart`.

---

### 2.8. `lib/presentation/screens/profile_and_cards/` (`widgets/` oluşturulacak)
*Mevcut (HEAD): `cards_management_screen.dart` (1454 satır), `profile_settings_screen.dart` (3412 satır)*
- [x] `lib/presentation/screens/profile_and_cards/widgets/` klasörünü oluştur.
- [x] `cards_management_screen.dart`:
  - `widgets/card_preview_tile.dart` (`218` satır)
  - `widgets/card_choice_chip_item.dart` (`67` satır)
  - `widgets/add_new_card_sheet.dart` (`495` satır — canlı kart önizleme + form alanları alt widget'lara bölünerek)
  - `widgets/add_new_bank_sheet.dart` (`177` satır)
  - `widgets/cards_section_body.dart` + `widgets/bank_accounts_section.dart`
- [x] `profile_settings_screen.dart` (`3412` satır):
  - `widgets/profile_hero_card.dart`
  - `widgets/profile_settings_section_card.dart` + `widgets/profile_setting_tile.dart` (`103` satır)
  - 40 satırı geçen **21 sheet & dialog** metodunu ortak seçim bileşenleriyle tekrarsız biçimde `widgets/` altına çıkar:
    - `widgets/profile_qr_dialog.dart` (`_showQrCodeDialog`)
    - `widgets/profile_edit_and_info_sheets.dart` (`_showEditProfileSheet`, `_showMoreOptionsSheet`, `_showAvatarOptionsSheet`, `_showPersonalInfoSheet`)
    - `widgets/profile_kolas_sheet.dart` (`_showKolasSheet`)
    - `widgets/profile_security_sheets.dart` (`_showChangePinSheet`, `_showTwoFactorSheet`, `_showTrustedDevicesSheet`, `_showSessionTimeoutSheet`, `_showLimitIncreaseSheet`)
    - `widgets/profile_preferences_sheets.dart` (`_showNotificationPreferencesSheet`, `_showCurrencyPickerSheet`, `_showThemePickerSheet`, `_showLanguagePickerSheet`)
    - `widgets/profile_support_sheets.dart` (`_showSupportSheet`, `_showFaqSheet`)
    - `widgets/profile_legal_sheets.dart` (`_showLegalContractsSheet`, `_showDocumentDetailSheet`, `_showComplianceSheet`)
    - `widgets/profile_account_dialogs.dart` (`_showFreezeAccountDialog`, `_showLogoutConfirmationDialog`)

---

## ✅ Bölüm 3: Merge Sonrası Doğrulama ve Test Kontrol Listesi

- [x] **3.1. Git Conflict Temizliği:** `git diff --name-status --diff-filter=U` komutunun `0` sonuç döndürdüğünü ve `lib/` ile `test/` içinde hiç `<<<<<<<`, `=======`, `>>>>>>>` kalmadığını doğrula.
- [x] **3.2. `StatelessWidget` & Klasör Taraması:** `grep -rn "StatefulWidget" lib/presentation/screens/` sonucunun `0` olduğunu, 8 screen modülünün tamamında `bloc/` + `widgets/` bulunduğunu ve 0 baytlık boş dosya kalmadığını doğrula.
- [x] **3.3. QR & POS Render + Payload Testleri:**
  - `test/core/qr_payload_parser_test.dart` (`48` sn B2C & B2B POS QR üretim/ayrıştırma testleri),
  - `QrPaymentCenterScreen` (her iki sekme, `lightTheme` & `darkTheme`, `0` layout/RenderBox istisnası) ve `VirtualPosTerminalScreen` QR sekmesi widget testleri,
  - `ITransactionRepository.executeFastTransfer` / `QrPaymentCubit` / `VirtualPosCubit` birim testleri.
- [x] **3.4. Statik Analiz ve Tam Test Koşusu:** `flutter analyze --no-pub` (`No issues found`) ve `flutter test --no-pub` (`%100` geçiş) çıktısını gözlemle.
