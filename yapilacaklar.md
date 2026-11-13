# PayPulse — Rol/Navigasyon, Bütçe Okları ve Filtre Butonu Çözüm Planı

> **Not:** Bu liste mevcut kod tabanındaki inceleme bulgularına dayanır; yalnızca adım adım düzeltme planı içerir (henüz kod değişikliği yapılmamıştır). Her madde uygulandıktan sonra `[x]` olarak işaretlenebilir.

---

## 🔍 Tespit Edilen Sorunlar ve Kök Nedenler

1. **Ahmet Yılmaz (`role: employee`) İşletme Modunda "Raporlar" Sekmesine Basınca En Soldaki Sekmeye ("Genel Bakış") Atıyor**
   - `lib/presentation/shell_navigation/main_shell_wrapper_screen.dart` (`MainShellWrapperScreen._businessTabs`, satır 47–78 ve 110–113): İşletme modundaki alt navigasyon çubuğu (`NavigationBar`) kullanıcının rolüne bakmaksızın hem `admin` hem `employee` için aynı 5 sekmeyi (`Genel Bakış`, `Tahsilat`, `Faturalar`, `Masraflar`, `Raporlar`) göstermektedir.
   - `lib/core/router/app_router.dart` (`_handleRedirect` — Kalkan 4, satır 259–266): `/business/reports` (`AppRoutes.businessReports`) rotası yalnızca `authState.canApproveExpenses` (`isAdmin`) yetkisine açıktır.
   - Ahmet Yılmaz `employee` rolünde olduğu için `canAccessBusinessPanel == true` fakat `canApproveExpenses == false` değerindedir. En sağdaki `Raporlar` sekmesine bastığında `context.go(AppRoutes.businessReports)` tetiklenir, Kalkan 4 devreye girer ve kullanıcıyı anında **`AppRoutes.businessOverview`** (`/business/overview` — yani en soldaki `index 0` sekmesi) rotasına geri fırlatır.

2. **Bütçe ve Analitik Ekranındaki Dönem Okları (`<` / `>`) ve Üst Sağ Ayar İkonu Çalışmıyor**
   - `lib/presentation/screens/analytics_and_reports/widgets/budget_period_tab_bar.dart` (`_PeriodIndicatorRow`, satır 109–143): Sol ok (`Icons.chevron_left_rounded`, satır 119) ve sağ ok (`Icons.chevron_right_rounded`, satır 139) hiçbir `IconButton` / `InkWell` / `onTap` geri çağrısına bağlanmamış statik `const Icon(...)` widget'larıdır.
   - Aynı bileşende satır 129'daki `'Kasım 2026 ($selectedPeriodLabel)'` metni sabit kodlanmıştır (*hardcoded*); ay/dönem kaydırmasına göre güncellenmemektedir.
   - `lib/presentation/screens/analytics_and_reports/bloc/budget_analytics_cubit.dart` (`BudgetAnalyticsState` & `BudgetAnalyticsCubit`): State yalnızca `Haftalık / Aylık / Yıllık` (`selectedPeriodIndex`) bilgisini tutmakta; önceki/sonraki ay veya dönem ofsetini (`periodOffset` / `referenceDate`) ve bunu değiştiren `previousPeriod()` / `nextPeriod()` metotlarını içermemektedir.
   - Ek olarak aynı başlıktaki `Icons.tune_rounded` butonu (`budget_period_tab_bar.dart:87-103`) `onRefresh: cubit.refresh` çağrısına bağlıdır; bir ayar/filtre penceresi açmadığı için kullanıcıda çalışmıyormuş hissi vermektedir.

3. **Deniz Aksoy (B2C) Tarafındaki Filtre Butonu (`Icons.tune_rounded`) Çalışmıyor**
   - `lib/presentation/screens/analytics_and_reports/widgets/transaction_search_and_filter_bar.dart` (`_SearchBarRow`, satır 78–95): Deniz Aksoy'un `İşlemler` (`/transactions`) ekranındaki `Icons.tune_rounded` butonu, B2B Masraf (`expense_status_tab_bar.dart`) ve e-Fatura (`invoice_filter_header.dart`) ekranlarının aksine bir filtre/sıralama sheet'i veya dialogu açmak yerine doğrudan `cubit.resetFilters` çağırmaktadır. Arama veya çip filtresi seçili değilken basıldığında state hiç değişmediği için buton hiçbir tepki vermez.
   - `lib/presentation/screens/analytics_and_reports/bloc/transaction_history_cubit.dart`: State yalnızca tek boyutlu `TransactionFilterType` (`Tümü`, `Gelen (+)`, `Giden (-)`, `QR Ödemeleri`) destekler; kategori, tutar/tarih sıralaması veya gelişmiş filtre seçimi ile aktif filtre vurgu durumu (`hasActiveAdvancedFilters`) tanımlı değildir.
   - Ayrıca `Bütçe ve Analitik` (`/budget`) ekranındaki sağ üst `Icons.tune_rounded` ikonu da filtre/ayar paneli yerine sessizce `cubit.refresh` tetiklemektedir.

---

## 🛠️ Bölüm 1: Ahmet Yılmaz (`employee`) İşletme Alt Bar & RBAC Mantığı

- [x] **1.1. Rol Bazlı İşletme Sekmesi Politikası (`_businessTabs`) Düzeltmesi**
  - Dosya: `lib/presentation/shell_navigation/main_shell_wrapper_screen.dart`
  - `_businessTabs` listesini statik sabit yerine rol/yetki parametrelerine göre üreten `_resolveBusinessTabs(AuthState authState)` yardımcısına geçir:
    - **Önerilen Yaklaşım (Kalkan 4 ile %100 Uyumlu):** `authState.canApproveExpenses` (`admin`) değilse `AppRoutes.businessReports` sekmesini `employee` alt barından kaldır (yalnızca yetkili olduğu `Genel Bakış`, `Tahsilat`, `Faturalar`, `Masraflar` sekmelerini göster). Böylece çalışan, tıklandığında en soldaki taba fırlatan yasaklı bir sekme görmez; `AppRouter` Kalkan 4 (`/business/reports` -> `/business/overview`) korunur ve mevcut RBAC testi de bozulmaz.
    - *(Alternatif Karar Notu — Eğer çalışana da "Raporlar" açılacaksa):* `AppRouter` Kalkan 4'ten `AppRoutes.businessReports` çıkarılıp `TaxAndVatReportScreen` içinde yönetici aksiyonları (`VatDeclarationDraftCard`, `AccountantExportCard`) yalnızca `authState.isAdmin` ise gösterilecek şekilde kısıtlanmalı ve `test/presentation/router_and_screens_widget_test.dart` RBAC beklentisi buna göre güncellenmelidir.
- [x] **1.2. Shell Sekme İndeks Güvenliği ve Rol Geçiş Tutarlılığı**
  - Dosya: `lib/presentation/shell_navigation/main_shell_wrapper_screen.dart` ve `lib/core/router/app_router.dart`
  - `_calculateSelectedIndex` fonksiyonunun alt rotalarla (`/business/overview/...`, `/business/expenses/...`) uyumlu kaldığından ve dinamik sekme listesi küçüldüğünde `selectedIndex` sınır aşımı (`RangeError`) oluşmadığından emin ol (`selectedIndex.clamp(0, tabs.length - 1)`).
  - `lib/presentation/widgets/role_switch_app_bar.dart` üzerinden `Ahmet Yılmaz` seçilip `İşletme Paneline Geç` tıklandığında `NavigationBar`'ın güncel kullanıcı rolünün izin verdiği sekmelerle anında güncellendiğini doğrula.

---

## 📅 Bölüm 2: Bütçe Dönem Okları (`<` / `>`) ve Dinamik Dönem Yönetimi

- [x] **2.1. `BudgetAnalyticsState` ve `BudgetAnalyticsCubit` İçine Dönem Kaydırma Mantığı Ekleme**
  - Dosya: `lib/presentation/screens/analytics_and_reports/bloc/budget_analytics_cubit.dart`
  - State içine `periodOffset` (varsayılan `0`: güncel dönem `Kasım 2026`, negatif değerler geçmiş dönemler) alanı ekle.
  - Seçili `selectedPeriodIndex` (`0: Haftalık`, `1: Aylık`, `2: Yıllık`) ve `periodOffset` kombinasyonuna göre dinamik başlık (`dynamicPeriodLabel`, örn. Aylıkta `Ekim 2026` / `Kasım 2026`, Haftalıkta `1. Hafta`–`4. Hafta`, Yıllıkta `2025` / `2026`) ve durum etiketi (`isCurrentPeriod` -> `'Aktif'` / `'Geçmiş'`) getter'ları ekle.
  - `canGoPrevious` (örn. `periodOffset > -11`) ve `canGoNext` (örn. `periodOffset < 0`, geleceğe taşmayı engelleyen sınır) bayraklarını tanımla.
  - `previousPeriod()` ve `nextPeriod()` (veya `stepPeriod(int delta)`) metotlarını ekle; dönem değiştiğinde yeni dönem verisini yükle.
- [x] **2.2. Bütçe Repository / Demo Veri Katmanında Dönem Ofseti Desteği**
  - Dosyalar: `lib/domain/repositories/i_budget_repository.dart`, `lib/data/repositories/budget_repository.dart`, `lib/data/datasources/remote/firebase_firestore_datasource.dart`, `lib/data/datasources/remote/local_demo_data_service.dart`
  - `getBudgetCategories` sözleşmesine opsiyonel `int periodOffset = 0` (veya dönem anahtarı) parametresi ekle; demo veri servisinde farklı aylara/haftalara geçildiğinde harcama ve kota değerlerinin belirlenebilir (deterministik) şekilde güncellenmesini sağla ki kullanıcı oklarla gezerken sayılar ve grafikler gerçekten değişsin.
- [x] **2.3. `BudgetPeriodTabBar` Oklarını Etkileşimli Yapma ve Sabit Metni Kaldırma**
  - Dosya: `lib/presentation/screens/analytics_and_reports/widgets/budget_period_tab_bar.dart` ve `lib/presentation/screens/analytics_and_reports/budget_analytics_screen.dart`
  - `BudgetPeriodTabBar` parametrelerine `onPreviousPeriod`, `onNextPeriod`, `canGoPrevious`, `canGoNext`, `dynamicDateLabel`, `isCurrentPeriod` (ve `onOpenFilter` — Bölüm 3 ile bağlantılı) ekle; `StatelessWidget` yapısını koru.
  - `_PeriodIndicatorRow` içindeki `Icons.chevron_left_rounded` ve `Icons.chevron_right_rounded` ikonlarını `IconButton` / `InkWell` ile sar; pasif durumda tıklamayı kapatıp rengini soluklaştır.
  - Sabit `'Kasım 2026 ($selectedPeriodLabel)'` metnini state'ten gelen dinamik dönem metniyle değiştir.

---

## 🎛️ Bölüm 3: Deniz Aksoy Filtre Butonlarının (`Icons.tune_rounded`) İşlevsel Hale Getirilmesi

- [x] **3.1. `TransactionHistoryCubit` İçin Gelişmiş Filtre ve Sıralama State'i**
  - Dosya: `lib/presentation/screens/analytics_and_reports/bloc/transaction_history_cubit.dart`
  - Sıralama ve kategori filtreleri ekle:
    - `TransactionSortOrder` enum (`newest`, `oldest`, `highestAmount`, `lowestAmount`)
    - Opsiyonel `selectedCategory` (mevcut işlemlerden dinamik olarak türetilen kategori listesi + `'Tümü'`)
    - `hasActiveAdvancedFilters` getter'ı (sıralama varsayılan dışındaysa veya kategori seçiliyse `true`)
  - `filteredTransactions` getter'ını hem arama + tür çipi + seçili kategori filtresini uygulayacak hem de seçili `sortOrder`'a göre sıralayacak şekilde güncelle.
  - `setCategoryFilter(String?)`, `setSortOrder(TransactionSortOrder)` ve tümünü temizleyen `resetFilters()` metotlarını tanımla.
- [x] **3.2. `İşlemler` Ekranına "Filtrele & Sırala" Alt Penceresi (Bottom Sheet) Bağlama**
  - Dosyalar: `lib/presentation/screens/analytics_and_reports/transaction_history_screen.dart`, `lib/presentation/screens/analytics_and_reports/widgets/transaction_search_and_filter_bar.dart` ve yeni `StatelessWidget` dosyası `lib/presentation/screens/analytics_and_reports/widgets/transaction_filter_sheet.dart`
  - `TransactionSearchAndFilterBar` içindeki `Icons.tune_rounded` butonunun `onTap` aksiyonunu `cubit.resetFilters` yerine `onOpenFilterSheet` olarak değiştir (`showModalBottomSheet` ile `TransactionFilterSheet` açsın).
  - Gelişmiş filtre aktifken (`hasActiveAdvancedFilters == true`) buton arka planı ve ikonu `EInvoice` (`invoice_filter_header.dart`) / `B2B Masraf` (`expense_status_tab_bar.dart`) ekranlarındaki gibi teal/yeşil vurgu ile gösterilsin; sheet içinde `Filtreleri Sıfırla` ve `Uygula` butonları bulunsun.
- [x] **3.3. `Bütçe ve Analitik` Sağ Üst `Icons.tune_rounded` Butonunu Anlamlı Hale Getirme**
  - Dosyalar: `lib/presentation/screens/analytics_and_reports/budget_analytics_screen.dart`, `lib/presentation/screens/analytics_and_reports/widgets/budget_period_tab_bar.dart` (gerekirse `widgets/budget_filter_sheet.dart`)
  - Sağ üstteki `Icons.tune_rounded` butonunun sadece `cubit.refresh` çağırması yerine bütçe filtreleme/görünüm sheet'i açmasını sağla (ör. "Yalnızca Limit Aşımı Uyarısı Olanlar" / Kategori Sıralaması veya "Güncel Döneme Dön" kısayolu) ya da yenileme işlevini ayrı `Icons.refresh_rounded` ikonuna ayır.

---

## ✅ Bölüm 4: Doğrulama ve Test Güncellemeleri

- [x] **4.1. Navigation & RBAC Widget Testi**
  - `test/presentation/router_and_screens_widget_test.dart` içine `Ahmet Yılmaz` (`employee`) kullanıcısının işletme modunda alt barda yalnızca yetkili sekmeleri gördüğünü ve `Raporlar` tıklamasında en soldaki sekmeye geri atılma sorununun giderildiğini doğrulayan test ekle.
- [x] **4.2. Bütçe Dönem Okları Birim + Widget Testi**
  - `BudgetAnalyticsCubit` için `previousPeriod` / `nextPeriod` sınır ve dönem etiketi testleri, `BudgetAnalyticsScreen` için `<` / `>` oklarına basıldığında dönem metninin ve tutarların güncellendiğini doğrulayan widget testi ekle.
- [x] **4.3. İşlemler Filtre Butonu Birim + Widget Testi**
  - `TransactionHistoryCubit` için kategori/sıralama filtreleme birim testleri; `TransactionHistoryScreen` içinde `Icons.tune_rounded` butonuna dokunulduğunda filtre/sıralama sheet'inin açıldığını ve seçilen filtrenin listeyi güncellediğini doğrulayan widget testi ekle.
- [x] **4.4. Son Statik Analiz ve Tam Test Koşusu**
  - `flutter analyze --no-pub` (`No issues found`) ve `flutter test --no-pub` (`%100` geçiş) ile tüm suite'i doğrula.

