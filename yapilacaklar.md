# PayPulse — QR Beyaz Ekran Hatası & `screens/*/widgets/` Mimari Ayrıştırma Planı

> **Durum:** Planlama aşaması (henüz kod değişikliği yapılmamıştır). Tüm maddeler sorun + kök neden + net çözüm adımları olarak işaretlenebilir (`- [ ]`) biçimde hazırlanmıştır.

---

## 🔴 Bölüm 1: QR Sekmesi Beyaz Ekran & `RenderBox was not laid out` Hatası

### Tespit Edilen Sorun ve Kök Neden
1. **Doğrudan Tetikleyici (`QrPaymentCenterScreen`):**
   - `lib/presentation/screens/qr_and_ocr/qr_payment_center_screen.dart` dosyasında `_ShowMyQrCard` (`satır 246–273`) içindeki `Row`, `Expanded(child: TextField(...))` ve `const SizedBox(width: 10)` yanında doğrudan **`ElevatedButton('QR Oluştur')` (`satır 263–271`)** barındırır.
   - `Row`, flex olmayan çocuklarına yatayda **sınırsız genişlik (`maxWidth = double.infinity`)** kısıtı ile layout uygular.
2. **Global Tema Çakışması (`AppTheme`):**
   - `lib/core/theme/app_theme.dart` dosyasında hem `lightTheme` (`satır 88`) hem `darkTheme` (`satır 191`) için `elevatedButtonTheme` içinde **`minimumSize: const Size(double.infinity, 52)`** tanımlanmıştır.
   - `Row` içindeki `ElevatedButton`'da `minimumSize` ezilmediği ve genişlik `Expanded`/`SizedBox` ile sınırlandırılmadığı için, sınırsız genişlik altında `minWidth = double.infinity` zorlanır ve Flutter `performLayout()` sırasında layout çöker (`BoxConstraints forces an infinite width`).
3. **Render Tree Zinciri (`up1` → `up20`) ve Saniyelik Rebuild Kilitlenmesi:**
   - Hata `_ShowMyQrCard` altındaki `Column` (`RenderFlex#22fa5 relayoutBoundary=up20`) içinde meydana geldiği için layout tamamlanamaz ve yukarıdaki tüm ata düğümlere sırayla yayılır:
     `Container` (`up17–up19`) → ana `Column` (`up16`) → `SingleChildScrollView` (`up14–up15`) → scroll göstergesi (`RenderCustomPaint#19ef1`, `up6`) → kök `RepaintBoundary` (`up1`).
   - `QrPaymentCubit` içindeki 1 saniyelik `_countdownTimer` her saniye state yayıp yeniden build tetiklediğinden `'package:flutter/src/rendering/object.dart': Failed assertion: line 2857 pos 12: '!_debugDoingThisLayout': is not true` hatası tekrar eder ve ekran tamamen **beyaz ekran (`NEEDS-PAINT`)** olarak kalır.
   - `test/` altında `QrPaymentCenterScreen` için widget testi bulunmadığından mevcut test çalıştırmalarında fark edilmemiştir.
4. **İkincil / İlişkili Yatay Kısıt ve `ParentDataWidget` Riskleri:**
   - **Aynı `AppTheme` Riski (`AlertDialog.actions`):** `e_invoice_gib_list_screen.dart` (`satır 592`), `b2b_expense_approval_center_screen.dart` (`satır 544`), `virtual_pos_terminal_screen.dart` (`satır 354`), `transfer_summary_screen.dart` (`satır 96`), `home_screen.dart` (`satır 1704`) ve `profile_settings_screen.dart` (`satır 3212, 3263`) içindeki `AlertDialog.actions` (`OverflowBar`) butonlarında `minimumSize` ezilmemiştir.
   - **`StatelessWidget` İçinde `Expanded` Kullanımı:** `_ModeTab` (`qr_payment_center_screen.dart:149`), `_TabButton` (`e_invoice_gib_list_screen.dart:766`) ve `_DocModeTab` (`ocr_camera_scanner_screen.dart:360`) doğrudan `Expanded(...)` döndürmektedir (`ParentDataWidget` çağrı noktasındaki `Row` içinde olmalıdır).

### Çözüm Adımları
- [ ] **1.1. Global `AppTheme` `ElevatedButton` Kök Nedenini Düzelt:** `lib/core/theme/app_theme.dart` içinde `lightTheme` (`satır 88`) ve `darkTheme` (`satır 191`) `elevatedButtonTheme` ayarlarında `minimumSize: const Size(double.infinity, 52)` yerine `minimumSize: const Size(0, 52)` (veya `Size(64, 52)`) tanımla; tam genişlik gereken yerlerin zaten `SizedBox(width: double.infinity, ...)` veya kendi `minimumSize` stiliyle sarılı olduğunu kontrol et (`home.dart` satır `346, 510, 601` dahil).
- [ ] **1.2. `QrPaymentCenterScreen` (`_ShowMyQrCard`) Buton Kısıtını Düzelt:** Yeni oluşturulacak `lib/presentation/screens/qr_and_ocr/widgets/show_my_qr_card.dart` içinde `QR Oluştur` butonuna `minimumSize: const Size(116, 52)` ve `padding: const EdgeInsets.symmetric(horizontal: 16)` (veya sabit yükseklikte sonlu genişlik) tanımla.
- [ ] **1.3. `ParentDataWidget` (`Expanded`) Kullanımını Düzelt:** `QrPaymentCenterScreen` (`_ModeTab` / yeni `qr_mode_switcher.dart`), `EInvoiceGibListScreen` (`_TabButton`) ve `OcrCameraScannerScreen` (`_DocModeTab`) bileşenlerinde `Expanded`'ı alt widget gövdesinden çıkarıp doğrudan çağrı yerindeki `Row` içine taşı.
- [ ] **1.4. `AlertDialog.actions` İçindeki `ElevatedButton`'ları Güvenli Kıl:** Yukarıda listelenen dialog butonlarını (ve gerekirse `OverflowBar` düzenini) test edip sonlu genişlikle temiz göründüğünü doğrula.
- [ ] **1.5. QR Ekranı Widget Testini Ekle:** `test/presentation/router_and_screens_widget_test.dart` (veya ayrı QR test dosyası) içine `AppTheme.lightTheme` ve `AppTheme.darkTheme` altında `QrPaymentCenterScreen` render testi (`QR Kodumu Göster` ↔ `QR Okut ve Öde` geçişi, `FlutterError` sıfır) ekle.

---

## 🧱 Bölüm 2: `lib/presentation/screens/` Klasörlerinde `widgets/` Oluşturma ve 40 Satırı Geçen Tüm UI Yapılarını Taşıma Planı

### Mevcut Durum Analizi ve Mimari Kurallar
- **Klasör Durumu:** Şu anda `lib/presentation/screens/` altındaki 8 aktif modülün hiçbirinde (`auth/` dahil; git merge sonrası `auth/widgets/` diskte yoktur) `widgets/` alt klasörü bulunmamaktadır. Ayrıca kullanılmayan boş bir `lib/presentation/screens/home/` klasörü vardır.
- **Taşıma Kuralları:**
  - [ ] Her aktif ekran klasörü altında standart **`bloc/` + `widgets/` + `*_screen.dart`** dizilimi kurulacak; boş `lib/presentation/screens/home/` klasörü silinecek.
  - [ ] Çıkarılan her widget dosyası **kesinlikle `StatelessWidget`** olacak; içinde `State`, `StatefulWidget`, `TextEditingController`, `Timer` veya `BlocProvider` barındırmayacak (tüm durum ve controller'lar `bloc/` altındaki BLoC/Cubit'te kalacak).
  - [ ] **40 satırı geçen tüm UI yapıları** — yalnız private `_Widget` sınıfları değil; `_show*Sheet`, `_show*Dialog`, `_build*Section`, `_build*Tile` metotları ve `*_screen.dart` gövdesindeki `40+` satırlık inline kart/form/hero/liste blokları da — `widgets/` klasörüne anlamlı alt bileşenler halinde ayrılacak.
  - [ ] Büyük kart/form widget'ları (`200+` satır olanlar) kendi içlerinde alt özel `StatelessWidget` bileşenlere bölünerek `build()` metotlarının gereksiz uzaması ve kod tekrarı önlenecek (`auth/widgets` düzeni referans alınacak).

---

### 2.1. `lib/presentation/screens/auth/` (`widgets/` oluşturulacak)
*Mevcut: `login_screen.dart` (619 satır), `register_screen.dart` (568 satır)*
- [ ] `lib/presentation/screens/auth/widgets/` klasörünü oluştur.
- [ ] `login_screen.dart` içindeki `_DemoRoleCard` (`126` satır, `satır 494–619`) → `widgets/demo_role_card.dart` (`DemoRoleCard`).
- [ ] `_LoginView.build` (`436` satır, `satır 56–491`) içindeki 40+ satırlık blokları ayır:
  - Üst logo + başlık/alt başlık alanı → `widgets/auth_brand_header.dart` (`AuthBrandHeader` — `register_screen.dart` ile ortak kullanım).
  - E-posta, şifre, beni hatırla ve giriş butonu formu → `widgets/login_form_card.dart` (`LoginFormCard`).
  - Hızlı demo giriş bölümü + kayıt yönlendirme alt alanı → `widgets/demo_quick_login_section.dart` (`DemoQuickLoginSection`).
- [ ] `_RegisterView.build` (`469` satır, `satır 70–538`) içindeki 40+ satırlık kayıt formu, rol/şifre doğrulama kuralları ve KVKK onay bloğunu `widgets/register_form_card.dart` (`RegisterFormCard` + alt alan grupları) olarak çıkar.

---

### 2.2. `lib/presentation/screens/splash_and_onboarding/` (`widgets/` oluşturulacak)
*Mevcut: `splash_screen.dart` (113 satır)*
- [ ] `lib/presentation/screens/splash_and_onboarding/widgets/` klasörünü oluştur.
- [ ] `_SplashView.build` (`80` satır, `satır 33–112`) gövdesindeki animasyonlu logo, marka başlığı ve yükleme göstergesi yapısını `widgets/splash_brand_content.dart` (`SplashBrandContent`) olarak çıkar.

---

### 2.3. `lib/presentation/screens/home_wallet_and_safe/` (`widgets/` oluşturulacak)
*Mevcut: `home.dart` (616 satır), `home_screen.dart` (1953 satır)*
- [ ] `lib/presentation/screens/home_wallet_and_safe/widgets/` klasörünü oluştur.
- [ ] **`home.dart` (`/developer-console`) 40+ satırlık bölümleri ayır:**
  - `_buildActiveUserSection` (`108` satır, `108–215`) → `widgets/dev_active_user_section.dart`
  - `_buildAuthSection` (`59` satır, `240–298`) → `widgets/dev_auth_test_section.dart`
  - `_buildTransferSection` (`59` satır, `300–358`) → `widgets/dev_transfer_test_section.dart`
  - `_buildNotificationsSection` (`75` satır, `360–434`) → `widgets/dev_notifications_test_section.dart`
  - `_buildTransactionsSection` (`52` satır, `436–487`) → `widgets/dev_transactions_test_section.dart`
  - `_buildExpenseSection` (`90` satır, `489–578`) → `widgets/dev_expense_test_section.dart`
  - `_buildPosSection` (`36` satır, `580–615`) ile birlikte tüm bölümler için ortak `DevTestCardContainer` sarmalayıcısı kur.
- [ ] **`home_screen.dart` (`HomeScreen` + `BusinessSafeOverviewScreen`) 40+ satırlık widget ve metotları ayır:**
  - `_TransactionTileItem` (`41` satır, `532–572`) (+ `_CurrencyChip` sadeleştirilerek) → `widgets/home_transaction_tile_item.dart`
  - `_MetricCard` (`90` satır, `1730–1819`) → `widgets/business_metric_card.dart`
  - `_QuickActionBox` (`101` satır, `1820–1920`) (+ `_SmallToggle`) → `widgets/business_quick_action_box.dart`
  - `_HomeWalletView.build` (`418` satır, `76–493`) içindeki bloklar:
    - B2C cüzdan bakiye hero kartı (döviz seçici + gizle + IBAN kopyala) → `widgets/personal_wallet_hero_card.dart`
    - 4'lü hızlı aksiyon satırı → `widgets/personal_quick_actions_row.dart`
    - Demo/Seed & Geliştirici Konsolu kartı (~65 satır; B2B tarafıyla ortak parametreli) → `widgets/demo_seed_banner_card.dart`
    - Son işlemler kartı & liste → `widgets/recent_transactions_card.dart`
  - `_BusinessOverviewView` (`1135` satır, `595–1729`) içindeki blok & sheet'ler:
    - `build` (`761` satır, `605–1365`) içindeki 40+ satırlık bölümler → `widgets/business_safe_hero_card.dart`, `widgets/business_weekly_cashflow_card.dart`, `widgets/business_quick_actions_grid.dart`, `widgets/business_pending_expenses_card.dart`
    - `_showTransferToAccountSheet` (`162` satır, `1367–1528`) → `widgets/business_transfer_to_account_sheet.dart`
    - `_showTopUpBalanceSheet` (`138` satır, `1530–1667`) → `widgets/business_top_up_balance_sheet.dart`
    - `_showReceiptInspectDialog` (`59` satır, `1669–1727`) → `widgets/expense_receipt_inspect_dialog.dart`

---

### 2.4. `lib/presentation/screens/transfer/` (`widgets/` oluşturulacak)
*Mevcut: `transfer_recipient_screen.dart` (315 satır), `transfer_amount_screen.dart` (244 satır), `transfer_summary_screen.dart` (706 satır), `transfer_receipt_screen.dart` (113 satır)*
- [ ] `lib/presentation/screens/transfer/widgets/` klasörünü oluştur.
- [ ] `transfer_recipient_screen.dart`:
  - `_RecipientCard` (`48` satır, `268–315`) → `widgets/recipient_card.dart`
  - `_TransferRecipientView.build` (`219` satır, `47–265`) içindeki IBAN giriş/doğrulama kartı ve kayıtlı alıcı listesi bölümü → `widgets/transfer_iban_input_card.dart`, `widgets/saved_recipients_section.dart`
- [ ] `transfer_amount_screen.dart`:
  - `_TransferAmountView.build` (`189` satır, `55–243`) içindeki alıcı bilgi banner'ı + tutar/kategori/açıklama kartını 40+ satırlık bloklar hâlinde `widgets/transfer_amount_entry_card.dart` (ve üst alıcı özeti) içine çıkar.
- [ ] `transfer_summary_screen.dart`:
  - `_StepCircle` (`51` satır, `656–706`) ve üst adım göstergesi → `widgets/transfer_step_indicator.dart`
  - `_showFraudConfirmationDialog` (`47` satır, `70–116`) → `widgets/fraud_confirmation_dialog.dart`
  - `_TransferSummaryView.build` (`535` satır, `119–653`) içindeki ödeme talebi özeti, tutar hero kartı, gönderen/alıcı hesap detayları kartı ve masraf onay/güvenlik bilgi blokları → `widgets/transfer_summary_details_card.dart`, `widgets/transfer_payment_request_card.dart`, `widgets/transfer_security_notice_card.dart`
- [ ] `transfer_receipt_screen.dart`:
  - `FourStateView` içindeki 54 satırlık (`satır 52–106`) dekont `Builder` gövdesini `widgets/transfer_receipt_content.dart` olarak çıkar.

---

### 2.5. `lib/presentation/screens/qr_and_ocr/` (`widgets/` oluşturulacak)
*Mevcut: `qr_payment_center_screen.dart` (381 satır), `ocr_camera_scanner_screen.dart` (519 satır), `ocr_data_verification_screen.dart` (319 satır), `e_invoice_gib_list_screen.dart` (1083 satır)*
- [ ] `lib/presentation/screens/qr_and_ocr/widgets/` klasörünü oluştur.
- [ ] `qr_payment_center_screen.dart`:
  - `_ShowMyQrCard` (`108` satır, `172–279`) → `widgets/show_my_qr_card.dart` *(Bölüm 1'deki QR buton düzeltmesi dahil)*
  - `_ScanQrCard` (`102` satır, `280–381`) → `widgets/scan_qr_card.dart`
  - Üst sekme çubuğu (`_ModeTab`) → `widgets/qr_mode_switcher.dart` (`Expanded` çağrı yerindeki `Row` içine alınarak)
- [ ] `ocr_camera_scanner_screen.dart`:
  - `_OcrViewfinderCard` (`96` satır, `385–480`) → `widgets/ocr_viewfinder_card.dart`
  - `_showGalleryOrSampleSheet` (`87` satır, `258–344`) → `widgets/ocr_sample_picker_sheet.dart`
  - `_OcrCameraScannerBody.build` (`228` satır, `29–256`) içindeki mod seçici (`_DocModeTab`) + alt aksiyon paneli (`_ActionOption`) + ipucu kartı → `widgets/ocr_doc_mode_selector.dart`, `widgets/ocr_scanner_actions_bar.dart`
- [ ] `ocr_data_verification_screen.dart`:
  - `_OcrDataVerificationBody.build` (`281` satır, `38–318`) içindeki 180 satırlık OCR form kartını (`satır 95–275`) ve onay buton bölümünü bölerek → `widgets/ocr_verification_form_card.dart`, `widgets/ocr_vat_and_category_selector.dart`
- [ ] `e_invoice_gib_list_screen.dart`:
  - `_InvoiceVolumeHeroCard` (`136` satır, `615–750`) → `widgets/invoice_volume_hero_card.dart`
  - `_TabButton` (`55` satır, `751–805`) + sekme çubuğu → `widgets/invoice_direction_tab_bar.dart` (`Expanded` dışarı alınarak)
  - `_InvoiceCard` (`278` satır, `806–1083`) → `widgets/invoice_list_card.dart` *(içindeki matrah/tevkifat detayları alt widget'a bölünerek sadeleştirilecek)*
  - `_showDocTypeFilterSheet` (`57` satır, `424–480`) → `widgets/invoice_doc_type_filter_sheet.dart`
  - `_showFastPaymentDialog` (`131` satır, `482–612`) → `widgets/invoice_fast_payment_dialog.dart`
  - `_EInvoiceGibListBody.build` (`380` satır, `43–422`) içindeki arama/filtre üst barı → `widgets/invoice_filter_header.dart`

---

### 2.6. `lib/presentation/screens/b2b_operations/` (`widgets/` oluşturulacak)
*Mevcut: `b2b_expense_approval_center_screen.dart` (927 satır), `bulk_expense_erp_receipt_screen.dart` (534 satır), `virtual_pos_terminal_screen.dart` (1131 satır)*
- [ ] `lib/presentation/screens/b2b_operations/widgets/` klasörünü oluştur.
- [ ] `b2b_expense_approval_center_screen.dart`:
  - `_PendingSummaryHeroCard` (`145` satır, `606–750`) → `widgets/pending_summary_hero_card.dart`
  - `_ExpenseReviewCard` (`177` satır, `751–927`) → `widgets/expense_review_card.dart`
  - `_showFilterDialog` (`52` satır, `376–427`) → `widgets/expense_filter_dialog.dart`
  - `_showSortDialog` (`43` satır, `429–471`) → `widgets/expense_sort_dialog.dart`
  - `_showRejectDialog` (`94` satır, `473–566`) → `widgets/expense_reject_dialog.dart`
  - `_ExpenseApprovalBody.build` (`332` satır, `43–374`) içindeki durum sekmeleri (`_TabPill`) ve filtreleme/arama çubuğu → `widgets/expense_status_tab_bar.dart`
- [ ] `bulk_expense_erp_receipt_screen.dart`:
  - `_BatchSuccessCard` (`111` satır, `199–309`) → `widgets/batch_success_card.dart`
  - `_ErpIntegrationCard` (`110` satır, `310–419`) (+ `_DetailRow`) → `widgets/erp_integration_card.dart`
  - `_ApprovedLineItem` (`77` satır, `458–534`) → `widgets/approved_expense_line_item.dart`
  - `BulkExpenseErpReceiptScreen.build` (`157` satır, `40–196`) içindeki kalem listesi ve alt indirme/dönüş çubuğu → `widgets/approved_expenses_list_card.dart`
- [ ] `virtual_pos_terminal_screen.dart`:
  - `_PosTabPill` (`53` satır, `478–530`) + mod değiştirici → `widgets/pos_tab_switcher.dart`
  - `_AmountEntryCard` (`98` satır, `531–628`) (+ `_QuickAddButton`) → `widgets/pos_amount_entry_card.dart`
  - `_PosCardPreview` (`99` satır, `661–759`) → `widgets/pos_card_preview.dart`
  - `_CardPaymentFormCard` (`192` satır, `760–951`) → `widgets/pos_card_payment_form_card.dart`
  - `_CommissionSummaryCard` (`47` satır, `952–998`) → `widgets/pos_commission_summary_card.dart`
  - `_QrPaymentCard` (`133` satır, `999–1131`) → `widgets/pos_qr_payment_card.dart`
  - `_showZReportBottomSheet` (`78` satır, `363–440`) → `widgets/pos_z_report_sheet.dart`
  - `_showSlipDialog` (`35` satır, `327–361`; `_SlipRow` ile birlikte temizlik için opsiyonel `widgets/pos_payment_slip_dialog.dart` değerlendirilecek).

---

### 2.7. `lib/presentation/screens/analytics_and_reports/` (`widgets/` oluşturulacak)
*Mevcut: `budget_analytics_screen.dart` (1077 satır), `tax_and_vat_report_screen.dart` (905 satır), `transaction_history_screen.dart` (674 satır)*
- [ ] `lib/presentation/screens/analytics_and_reports/widgets/` klasörünü oluştur.
- [ ] `budget_analytics_screen.dart`:
  - `_PeriodTab` (`45` satır, `210–254`) + dönem seçici bar → `widgets/budget_period_tab_bar.dart`
  - `_QuotaHeroCard` (`135` satır, `255–389`) → `widgets/budget_quota_hero_card.dart`
  - `_WeeklyTrendCard` (`113` satır, `390–502`) + `_TrendWeekBar` (`70` satır, `503–572`) → `widgets/budget_weekly_trend_card.dart`
  - `_CategoryBreakdownCard` (`150` satır, `573–722`) → `widgets/budget_category_breakdown_card.dart`
  - `_CategoryBox` (`104` satır, `723–826`) → `widgets/budget_category_box.dart`
  - `_SavingsGoalCard` (`189` satır, `827–1015`) → `widgets/budget_savings_goal_card.dart`
  - `_BudgetAdviceCard` (`62` satır, `1016–1077`) → `widgets/budget_advice_card.dart`
- [ ] `tax_and_vat_report_screen.dart`:
  - `_NetVatHeroCard` (`185` satır, `196–380`) → `widgets/net_vat_hero_card.dart`
  - `_DeclarationDraftCard` (`140` satır, `381–520`) → `widgets/vat_declaration_draft_card.dart`
  - `_VatDistributionCard` (`91` satır, `521–611`) + `_VatColumn` (`63` satır, `612–674`) → `widgets/vat_distribution_card.dart`
  - `_ExpenseMatrahCard` (`132` satır, `675–806`) → `widgets/vat_expense_matrah_card.dart`
  - `_AccountantExportCard` (`99` satır, `807–905`) → `widgets/accountant_export_card.dart`
- [ ] `transaction_history_screen.dart`:
  - `_NetSummaryHeroCard` (`92` satır, `357–448`) + `_MiniFlowBox` (`58` satır, `449–506`) → `widgets/transaction_net_summary_hero_card.dart`
  - `_HighlightedFastCard` (`133` satır, `507–639`) → `widgets/highlighted_fast_card.dart`
  - `_TransactionHistoryBody.build` (`259` satır, `40–298`) içindeki arama + filtre çubuğu ve `_GroupHeader` / `_buildTransactionTile` gruplu işlem listesi → `widgets/transaction_search_and_filter_bar.dart`, `widgets/transaction_grouped_list_section.dart`

---

### 2.8. `lib/presentation/screens/profile_and_cards/` (`widgets/` oluşturulacak)
*Mevcut: `cards_management_screen.dart` (1454 satır), `profile_settings_screen.dart` (3412 satır)*
- [ ] `lib/presentation/screens/profile_and_cards/widgets/` klasörünü oluştur.
- [ ] `cards_management_screen.dart`:
  - `_CardPreviewTile` (`218` satır, `1170–1387`) → `widgets/card_preview_tile.dart`
  - `_ChoiceChipItem` (`67` satır, `1388–1454`) → `widgets/card_choice_chip_item.dart`
  - `_showAddNewCardSheet` (`495` satır, `495–989`) → `widgets/add_new_card_sheet.dart` *(canlı önizleme, form alanları ve kart tipi/limit seçiciler alt widget'lara bölünerek)*
  - `_showAddNewBankSheet` (`177` satır, `991–1167`) → `widgets/add_new_bank_sheet.dart`
  - `_CardsManagementView.build` (`458` satır, `36–493`) içindeki kartlar/limitler bölümü ve kayıtlı banka hesapları kartı → `widgets/cards_section_body.dart`, `widgets/bank_accounts_section.dart`
- [ ] `profile_settings_screen.dart` (`3412` satır — modüler parçalanacak en büyük ekran):
  - `_ProfileSettingsView.build` (`854` satır, `35–888`) içindeki bölümler:
    - Kullanıcı profil hero kartı & KYC seviyesi alanı → `widgets/profile_hero_card.dart`
    - Ayar grupları kartı (Hesap, Güvenlik, Uygulama, Destek/Yasal) + `_buildSettingTile` (`103` satır, `3309–3411`) → `widgets/profile_settings_section_card.dart`, `widgets/profile_setting_tile.dart`
  - **40 satırı geçen 21 sheet ve dialog metodunu** `widgets/` altına `StatelessWidget` olarak taşı:
    - QR & Profil & KOLAS (`widgets/profile_qr_dialog.dart`, `widgets/profile_edit_and_info_sheets.dart`, `widgets/profile_kolas_sheet.dart`):
      - `_showQrCodeDialog` (`217` satır, `891–1107`)
      - `_showEditProfileSheet` (`127` satır, `1110–1236`)
      - `_showMoreOptionsSheet` (`137` satır, `1239–1375`)
      - `_showAvatarOptionsSheet` (`91` satır, `1378–1468`)
      - `_showPersonalInfoSheet` (`87` satır, `1471–1557`)
      - `_showKolasSheet` (`133` satır, `1590–1722`)
    - Güvenlik & Limitler (`widgets/profile_security_sheets.dart` veya ayrı tekil sheet dosyaları):
      - `_showChangePinSheet` (`113` satır, `1725–1837`)
      - `_showTwoFactorSheet` (`83` satır, `1840–1922`)
      - `_showTrustedDevicesSheet` (`113` satır, `1925–2037`)
      - `_showSessionTimeoutSheet` (`74` satır, `2040–2113`)
      - `_showLimitIncreaseSheet` (`124` satır, `2116–2239`)
    - Uygulama Tercihleri & Destek (`widgets/profile_preferences_sheets.dart`, `widgets/profile_support_sheets.dart` — ortak radyo/liste seçim sheet bileşeniyle tekrarı azaltarak):
      - `_showNotificationPreferencesSheet` (`79` satır, `2242–2320`)
      - `_showCurrencyPickerSheet` (`69` satır, `2323–2391`)
      - `_showThemePickerSheet` (`74` satır, `2394–2467`)
      - `_showLanguagePickerSheet` (`79` satır, `2470–2548`)
      - `_showSupportSheet` (`72` satır, `2551–2622`)
      - `_showFaqSheet` (`80` satır, `2625–2704`)
    - Yasal Belgeler & Kritik Hesap Diyalogları (`widgets/profile_legal_sheets.dart`, `widgets/profile_account_dialogs.dart`):
      - `_showLegalContractsSheet` (`228` satır, `2707–2934`)
      - `_showDocumentDetailSheet` (`160` satır, `2937–3096`)
      - `_showComplianceSheet` (`47` satır, `3099–3145`)
      - `_showFreezeAccountDialog` (`49` satır, `3183–3231`)
      - `_showLogoutConfirmationDialog` (`51` satır, `3234–3284`)

---

## ✅ Bölüm 3: Uygulama Sonrası Doğrulama ve Test Kontrol Listesi

- [ ] **3.1. `StatelessWidget` Taraması:** `lib/presentation/screens/` altında tek bir `StatefulWidget` veya `State<...>` sınıfı bulunmadığını doğrula (`grep -rn "StatefulWidget" lib/presentation/screens/` → `0` sonuç).
- [ ] **3.2. Klasör Yapısı Kontrolü:** Tüm 8 aktif screen klasöründe `bloc/` + `widgets/` bulunduğunu, boş `lib/presentation/screens/home/` klasörünün kaldırıldığını ve hiçbir `*_screen.dart` dosyasında 40 satırı geçen ayrıştırılmamış UI bloğu kalmadığını doğrula.
- [ ] **3.3. QR Tabı Görsel & Render Testi:** `QrPaymentCenterScreen` için hem `QR Kodumu Göster` hem `QR Okut ve Öde` modlarında, hem `lightTheme` hem `darkTheme` ile `RenderBox` / `BoxConstraints` / `_debugDoingThisLayout` istisnası oluşmadığını testlerle doğrula.
- [ ] **3.4. Statik Analiz ve Tam Test Koşusu:** `flutter analyze --no-pub` (`No issues found`) ve `flutter test --no-pub` (`100%` pass) çıktısını gözlemle.

