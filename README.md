---
proje: egitim
tur: 6sarli_teslim_projesi
grup: "3. Grup"
proje_adi: "PayPulse — Yeni Nesil Dijital Cüzdan, Masraf Yönetimi ve B2B/B2C Tahsilat Portalı"
sektor: "FinTech, Kurumsal Masraf & Yeni Nesil Ticaret"
teslim_tarihi: 2026-11-13
durum: aktif_gelistirme
uye_sayisi: 6
tags:
  - proje/egitim
  - teslim_projesi
  - buyuk_grup
  - flutter
  - softito
  - firebase
---

# 🚀 SoftITO 4. Dönem Mobil — 3. Grup Büyük Teslim Projesi

> **Grup Adı:** **3. Grup (6 Kişilik Büyük Teslim Proje Takımı)**  
> **Ekip Üyeleri:** Eren Türkmen, Shahd Mohamed Ragab (Shad), Betül Zağlı, Berat Atmaca, Abdullah Belli, Hasbiyenur Çoban  
> **Proje Başlığı:** **PayPulse — Yeni Nesil Dijital Cüzdan, Masraf Yönetimi ve B2B/B2C Tahsilat Portalı**  
> **Sektörel Alan:** `FinTech, Kurumsal Masraf & Yeni Nesil Ticaret`  
> **Mimari Standart:** Flutter SDK & Clean Architecture + Full Firebase Entegrasyonu  
> **Çift Yönlü Rol Modeli:** Zorunlu (Rol 1: Kullanıcı Portalı vs Rol 2: Yönetici/Sağlayıcı Portalı)  
> **Büyük Teslim & Demo Day:** 13 Kasım 2026 Cuma (Canlı Jüri Sunumu)

---

## 🧭 Hızlı Navigasyon & Bağlantılar
- 📋 **Büyük Teslim Grupları Komuta Paneli:** [[02_PROJELER/egitim/ogrenci_projeleri/6sarli_teslim_projeleri/README|🚀 4 Büyük Teslim Grubu Komuta Merkezi]]
- 👥 **Öğrenci Takip Paneli:** [[02_PROJELER/egitim/ogrenciler|👥 SoftITO Öğrenci Listesi]]
- 🎓 **22 Bireysel Bitirme Projeleri:** [[02_PROJELER/egitim/ogrenci_projeleri/bireysel_bitirme_projeleri/README|🎓 Bireysel Bitirme Projeleri]]
- ⚡ **Eğitim Master Context:** [[02_PROJELER/egitim/egitim|⚡ Eğitim Master Context]]

---

## 🎯 1. Proje Açıklaması & Kapsamı

### 🌟 Projenin Amacı ve Vizyonu
Bireysel kullanıcılar ve şirket personelleri için çok para birimli dijital cüzdan, 7/24 FAST transferi ve akıllı masraf fişi takibi sunan; KOBİ ve işletmeler için ise sanal POS, anlık tahsilat, personel harcama onay mekanizması ve finansal raporlama sağlayan çift yönlü FinTech ekosistemi.

Bu proje; 6 kişilik bir yazılım mühendisliği ekibinin 1 hafta boyunca tam zamanlı çalışarak uçtan uca, store kalitesinde, kurumsal mimariyle ve çift taraflı rol yönetimiyle geliştireceği büyük ölçekli bir bitirme ürünüdür.

---

### 🎭 Çift Yönlü Rol Modeli (Role-Based Dual Mode)

Uygulama iki farklı kullanıcı tipine hizmet verecek şekilde tasarlanacaktır. Giriş yapan kullanıcının rolüne göre arayüz, yetkiler ve dashboard dinamik olarak değişecektir:

#### 👤 1. Modül: Bireysel Kullanıcı & Şirket Çalışanı Cüzdanı (B2C Portalı)
- **Çoklu Para Birimli Ana Cüzdan:** TL, USD, EUR bakiye kartları, bakiye gizleme (Göz ikonu), son finansal hareketler dökümü.
- **7/24 FAST / Kolay Adres Para Transferi:** Telefon numarası veya IBAN ile diğer kullanıcılara anında bakiye gönderme, işlem açıklaması ve komisyonsuz transfer.
- **Dinamik QR Kod ile Öde & Tahsil Et:** Kasa önünde kasaya gösterilecek geri sayımlı QR kod üretimi veya arkadaştan para isteme QR'ı.
- **Şirket Masraf & Fiş Yönetimi Masası:** Şirket adına yapılan harcamanın (Yemek, Taksi, Otel, Yakıt) fiş fotoğrafını çekip Storage'a yükleme, KDV/Tutar girişi ve yöneticiye masraf onay talebi iletme.
- **Kategorize Bütçe & Harcama Grafikleri:** Ay içindeki harcamaların sektör bazlı pasta grafik dökümü ve limit aşım alarmları.

#### 🏢 2. Modül: KOBİ / Üye İşyeri & Şirket Finans Yöneticisi Portalı (B2B Paneli)
- **İşletme Kasası & Sanal POS Terminali:** Kasadan müşteriden kredi kartı veya PayPulse QR ile ödeme alma, başarılı işlem slip simülatörü.
- **Personel Masraf Onay Masası:** Şirket çalışanlarının yüklediği fişleri, KDV tutarlarını ve fatura fotoğraflarını inceleme; tek tıkla 'Onayla / Reddet (Gerekçeli)' aksiyonu ve muhasebe kodu atama.
- **Gün Sonu Kapanışı (Z-Raporu) & Ciro Raporu:** Günlük, haftalık, aylık net tahsilat, iade edilen işlemler ve komisyon kesintisi analitiği.
- **Dinamik Fatura & Ödeme Linki Üretme:** Müşteriye SMS/WhatsApp ile gönderilebilecek ödeme linki simülasyonu.
- **Fraud / Şüpheli İşlem Alarmları (FCM Push):** Kısa sürede yapılan yüksek tutarlı veya olağandışı transferlerde yöneticiye anlık push güvenlik onayı bildirimi.

---

### ⚙️ Temel İş Kuralları & Kritik Mantık Akışları (Business Rules)
6 kişilik ekibin 1 hafta boyunca kodlayacağı kritik iş mantıkları şunlardır:

1. **Atomik Transfer Mimarisi (Firestore Transaction):** A hesabından B hesabına para aktarılırken, A'dan düşme ve B'ye ekleme işlemi tek bir atomik Transaction içinde yapılmalıdır. Bakiye yetersizse işlem kesinlikle hata fırlatmalıdır.
2. **Bakiye Negatife Düşemez:** Kullanıcı hesabında bulunan tutardan 1 kuruş fazla transfer veya harcama yapamaz.
3. **Masraf Yaşam Döngüsü:** Personel fiş yükler -> Durum: `ONAY_BEKLIYOR`. Yönetici onaylarsa -> Durum: `ONAYLANDI` ve onaylanan tutar personelin ana cüzdanına avans/masraf iadesi olarak otomatik yansır. Reddedilirse gerekçe metni personelin bildirim ekranına düşer.
4. **Finansal Maskeleme & Validasyon:** Kredi kartı numarası 16 hane Luhn algoritması, IBAN 'TR' ile başlayan 26 karakter kontrolü ve CVV gizleme standarttır.
5. **Kuruş ve Yuvarlama Hassasiyeti:** Finansal hesaplamalarda kuruş kaybı olmamalıdır; hesaplamalar `intl` NumberFormat ve 2 basamaklı hassasiyetle yönetilir.

---

## 🛠️ 2. İstediğim Teknolojiler & Mimari Standartlar

Projede derste kapsamlı olarak işlediğimiz kurumsal mobil geliştirme teknolojileri ve standartları eksiksiz kullanılacaktır:

- **Mobil Framework & Dil:** Flutter SDK (En güncel kararlı sürüm) & Dart (Strict Type Safety, Null Safety)
- **Mimari Disiplin:** Kurumsal Clean Architecture (`core`, `data`, `domain`, `presentation`) & Katmanlı Klasör Düzeni
- **Kimlik Doğrulama (Auth):** Firebase Authentication (Email/Şifre, opsiyonel Google Sign-In, Rol tabanlı Custom Claims / Profil eşleme)
- **Veritabanı & Canlı Veri:** Cloud Firestore (NoSQL, Realtime Streams, Subcollections, Composite Queries, Atomik Transactions & Batch Writes)
- **Medya & Belge Saklama:** Firebase Storage (Profil fotoğrafları, makbuz/fiş/rapor/ödev dosyaları, ImagePicker, Yükleme Stream'i & İlerleme Barı)
- **Push Bildirimleri & Uyarılar:** Firebase Cloud Messaging (FCM) & `flutter_local_notifications` (Ön plan, arka plan, topic tabanlı toplu duyurular)
- **Hata Takibi & Analitik:** Firebase Crashlytics & Firebase Analytics (Kritik kullanıcı aksiyonları, özel event logları)
- **State Management:** BLoC / Cubit veya Provider / Riverpod (Tek bir kurumsal standart seçilmeli, spagetti setState yasaktır)
- **Navigasyon Mimarisi:** GoRouter (ShellRoute ile kalıcı BottomNavigationBar, Deep Linking, Rol bazlı Route Guards / Yönlendirme Kalkanı)
- **Yerel Depolama (Offline Cache):** SharedPreferences veya Hive / SQLite (Oturum token'ı, çevrimdışı taslaklar, tema tercihleri)
- **Tasarım Sistemi & UI/UX:** Material 3 (ColorScheme.fromSeed, Açık ve Koyu Tema, Akıcı Mikro Animasyonlar, Hero, CustomPainter grafikler)
- **Form & Validasyon Güvencesi:** `Form` & `GlobalKey<FormState>`, Regex validatörleri, InputFormatters, TextEditingController yaşam döngüsü (`dispose`)
- **Kalite & Güvenilirlik:** Sıfır `RenderFlex overflow` (sarı-siyah taşma) kuralı, asenkron `mounted` kontrolleri, Unit & Widget testleri
- **Versiyon Kontrol & Git-Flow:** `main` (Stabil), `develop` (Entegrasyon) ve `feat/<isim>-<modul>` feature branch'leri, PR (Pull Request) onay mekanizması

---

## 📋 3. Ekip Tarafından Tamamlanacak Çalışma Alanı

> [!NOTE]
> Bu bölüm projenin teknik şartnamesi doğrultusunda **6 kişilik öğrenci ekibi tarafından** doldurulmuş; mimari kararlar, ekran tasarımları, DTO modelleri ve GitHub repo ilerlemeleri burada belgelenmiştir.

### 👥 3.1. Takım İçi 6 Kişilik Görev Dağılımı ve Sorumluluk Matrisi

- [x] **[Berat Atmaca] Geliştirici 1 (Team Lead & Core Architecture):** Core katmanı, Base sınıflar, Git branch kuralları, GoRouter Role Guards & Shell Navigation.
- [x] **[Shahd Mohamed Ragab] Geliştirici 2 (UI / UX & Design System Lead):** Material 3 teması, Renk paleti (`#0D1F2D` $\rightarrow$ `#12353C`, `#10B981`), Custom Widgets, Grafikler (`BudgetDonutChart`, `WeeklyBarChart`), Bütçe, Profil ve KDV Raporu ekranları.
- [x] **[Abdullah Belli] Geliştirici 3 (Network, API & Firebase Lead):** Firebase Auth, Firestore servisleri, Storage bağlantısı, FCM altyapısı ve atomik transfer işlemleri.
- [x] **[Betül Zağlı] Geliştirici 4 (Data Models & DTO Lead):** 7 temel Entity ve DTO modelleri (`fromJson`, `toJson`, `copyWith`, `Equatable`), `firestore_collections.dart`, `FirestoreSeeder` servisi, İşlem Geçmişi ve E-Fatura & E-Arşiv ekranları.
- [x] **[Eren Türkmen] Geliştirici 5 (State Management & Logic Lead):** BLoC / Cubit akışları, Event/State sınıfları, Reaktif dinleyiciler.
- [x] **[Hasbiyenur Çoban] Geliştirici 6 (Feature Screens & QA / Test Lead):** Form validasyonları, 4 durum yönetimi (`FourStateView`), POS, Masraf Onay ve Transfer ekranları.

### 📱 3.2. Ekran Listesi ve Kullanıcı Akış Şeması

```text
lib/presentation/
├── widgets/                                  # Tüm ekibin kullandığı ortak widget'lar
│   ├── dark_gradient_hero_card.dart
│   ├── status_badge_widget.dart
│   ├── budget_donut_chart.dart
│   ├── weekly_bar_chart.dart
│   ├── transaction_list_tile_widget.dart
│   ├── custom_numpad_widget.dart
│   ├── receipt_summary_card_widget.dart
│   └── role_switch_app_bar.dart
├── shell_navigation/                         # 5'li BottomNavBar + B2B->B2C Switch
│   └── main_shell_wrapper_screen.dart
└── screens/
    ├── splash_and_onboarding/ (splash_screen.dart)
    ├── auth/ (login_screen.dart, register_screen.dart, bloc/)
    ├── home_wallet_and_safe/ (home_screen.dart — B2C Cüzdan & B2B İşletme Kasası)
    ├── transfer/ (4 Adımlı FAST: recipient, amount, summary, receipt)
    ├── qr_and_ocr/ (qr_payment_center, ocr_camera_scanner, ocr_data_verification, e_invoice_gib_list)
    ├── b2b_operations/ (virtual_pos_terminal, b2b_expense_approval_center, bulk_expense_erp_receipt)
    ├── analytics_and_reports/ (budget_analytics, tax_and_vat_report, transaction_history)
    └── profile_and_cards/ (profile_settings, cards_management)
```

### 🗄️ 3.3. Cloud Firestore Veri Şeması (Koleksiyon & Döküman Tasarımı)

- `users`: `{ uid, name, email, role, companyId, customerNo, verificationLevel, iban, monthlyLimit, spentThisMonth, hasB2BAccess }`
- `wallets`: `{ walletId, ownerId, balances: { TRY, USD, EUR }, updatedAt }`
- `transactions`: `{ txId, senderId, receiverId, title, category, amount (kuruş), currency, timestamp, type, targetIban, isExpense, dateGroup, status }`
- `budget_categories`: `{ categoryId, title, spentAmount, allocatedAmount, percentage, colorHex, iconName }`
- `savings_goals`: `{ id, title, targetAmount, currentAmount, deadline, iconName }`
- `expenses`: `{ expenseId, employeeId, employeeName, merchantTitle, category, companyId, amount, vatAmount, receiptImageUrl, status, accountingCode, date }`
- `invoices`: `{ invoiceId, companyId, gibInvoiceNo, counterpartyName, isIncoming, documentType, totalAmount, vatAmount, withholdingRate, badgeText, isPaid, canPayWithFast, issueDate }`
- `pos_transactions`: `{ posTxId, terminalId, customerName, grossAmount, commissionRate, commissionAmount, netAmount, timestamp, cardMasked, status }`

### 🔗 3.4. GitHub Repository & Sprint Takip Bilgileri
- **GitHub Repo Linki:** `https://github.com/nokaygu/PayPulse`
- **Sprint 1 (09 - 10 Kasım):** Mimari kurulum, modeller, auth ve temel ekran iskeletleri.
- **Sprint 2 (11 - 12 Kasım):** Çift yönlü rollerin canlı bağlanması, Storage, FCM, 4 durum kalkanı ve testler.
- **Demo Day (13 Kasım):** Canlı emülatör/cihaz sunumu ve jüri değerlendirmesi.

---
*Belge Oluşturuldu: 2026-11-09 — Antigravity E-Mektep & SoftITO Mobil Büyük Teslim Projeleri Sistemi*
