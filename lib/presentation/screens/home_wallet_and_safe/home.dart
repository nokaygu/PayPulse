import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../data/datasources/remote/firebase_auth_datasource.dart';
import '../../../data/datasources/remote/firebase_firestore_datasource.dart';
import '../../../data/datasources/remote/firebase_notification_datasource.dart';
import '../../../data/models/expense_model.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/models/safe_recipient_model.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/wallet_model.dart';

/// PayPulse macOS & Android Firebase Test ve Jüri Değerlendirme Tezgahı.
/// Tüm Firebase Auth, Canlı Cüzdan, FAST Transferi, Masraf Onay Masası,
/// Firestore Bildirimleri ve POS simülasyonunu tek bir ekranda canlı test ettirir.
class HomeAndWalletEkrani extends StatefulWidget {
  const HomeAndWalletEkrani({super.key});

  @override
  State<HomeAndWalletEkrani> createState() => _HomeAndWalletEkraniState();
}

class _HomeAndWalletEkraniState extends State<HomeAndWalletEkrani> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  // FAST Transfer kontrolleri
  final targetIbanController = TextEditingController();
  final transferAmountController = TextEditingController();

  // Masraf kontrolleri
  final expenseAmountController = TextEditingController();
  final expenseVatController = TextEditingController();
  final rejectReasonController = TextEditingController();

  // POS kontrolü
  final posAmountController = TextEditingController();

  final authService = FirebaseAuthDatasource();
  final firestoreService = FirebaseFirestoreDatasource();
  final notificationService = FirebaseNotificationDatasource();

  String mesaj = 'Sistem hazır. Giriş yapabilir veya test edebilirsiniz.';
  bool isLoading = false;
  SafeRecipientModel? searchedRecipient;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    targetIbanController.dispose();
    transferAmountController.dispose();
    expenseAmountController.dispose();
    expenseVatController.dispose();
    rejectReasonController.dispose();
    posAmountController.dispose();
    super.dispose();
  }

  void mesajGuncelle(String yeniMesaj) {
    if (!mounted) return;
    setState(() {
      mesaj = yeniMesaj;
      isLoading = false;
    });
  }

  // ================= 1. AUTH İŞLEMLERİ =================
  Future<void> kayitOl() async {
    setState(() => isLoading = true);
    try {
      await authService.register(
        emailController.text.trim(),
        passwordController.text,
        name: nameController.text.trim().isEmpty
            ? 'Kullanıcı'
            : nameController.text.trim(),
      );
      await notificationService.saveTokenToFirestore();
      mesajGuncelle(
        'Kayıt başarılı! Otomatik sıfır bakiyeli cüzdan ve IBAN oluşturuldu.',
      );
    } catch (e) {
      mesajGuncelle('Kayıt hatası: $e');
    }
  }

  Future<void> girisYap() async {
    setState(() => isLoading = true);
    try {
      await authService.login(
        emailController.text.trim(),
        passwordController.text,
      );
      await notificationService.saveTokenToFirestore();
      mesajGuncelle('Giriş başarılı!');
    } catch (e) {
      mesajGuncelle('Giriş hatası: $e');
    }
  }

  Future<void> cikisYap() async {
    setState(() => isLoading = true);
    try {
      final user = authService.getCurrentUser();
      if (user != null) {
        await notificationService.deleteTokenOnLogout(user.uid);
      }
      await authService.logout();
      mesajGuncelle('Çıkış yapıldı.');
    } catch (e) {
      mesajGuncelle('Çıkış hatası: $e');
    }
  }

  // ================= 2. ALICI ARAMA & FAST TRANSFERİ =================
  Future<void> aliciyiSorgula() async {
    final iban = targetIbanController.text.trim();
    if (iban.isEmpty) {
      mesajGuncelle('Lütfen hedef IBAN giriniz.');
      return;
    }

    setState(() => isLoading = true);
    try {
      final recipient = await firestoreService.findRecipientByIban(iban);
      setState(() {
        searchedRecipient = recipient;
        isLoading = false;
      });

      if (recipient != null) {
        mesajGuncelle(
          'Alıcı Bulundu: ${recipient.maskedName} (${recipient.iban})',
        );
      } else {
        mesajGuncelle(
          'IBAN bulunamadı. Lütfen geçerli bir PayPulse IBAN girin.',
        );
      }
    } catch (e) {
      mesajGuncelle('Sorgulama hatası: $e');
    }
  }

  Future<void> fastTransferiYap() async {
    final user = authService.getCurrentUser();
    if (user == null) {
      mesajGuncelle('Önce oturum açmalısınız!');
      return;
    }

    final targetIban = targetIbanController.text.trim();
    final amountText = transferAmountController.text.trim();
    final amountTl = double.tryParse(amountText.replaceAll(',', '.'));

    if (amountTl == null || amountTl <= 0) {
      mesajGuncelle('Geçerli bir transfer tutarı giriniz.');
      return;
    }

    final kurus = (amountTl * 100).round();

    setState(() => isLoading = true);
    try {
      final tx = await firestoreService.executeFastTransferByIban(
        senderUserId: user.uid,
        targetIban: targetIban,
        amountKurus: kurus,
      );

      mesajGuncelle(
        'FAST Transferi Başarılı!\n'
        'İşlem No: ${tx.txId}\n'
        'Tutar: ${(tx.amount / 100).toStringAsFixed(2)} TL\n'
        'Alıcıya bildirim iletildi.',
      );
      transferAmountController.clear();
    } catch (e) {
      mesajGuncelle('Transfer hatası: $e');
    }
  }

  // ================= 3. MASRAF OLUŞTURMA & ONAY MASASI =================
  Future<void> masrafGonder() async {
    final user = authService.getCurrentUser();
    if (user == null) {
      mesajGuncelle('Önce oturum açmalısınız!');
      return;
    }

    final amountText = expenseAmountController.text.trim();
    final amountTl = double.tryParse(amountText.replaceAll(',', '.'));
    if (amountTl == null || amountTl <= 0) {
      mesajGuncelle('Geçerli bir masraf tutarı girin.');
      return;
    }

    final kurus = (amountTl * 100).round();
    final vatKurus = (kurus * 0.20).round(); // %20 KDV

    setState(() => isLoading = true);
    try {
      final expense = ExpenseModel(
        expenseId: 'exp_${DateTime.now().millisecondsSinceEpoch}',
        employeeId: user.uid,
        companyId: 'company_001',
        amount: kurus,
        vatAmount: vatKurus,
        receiptImageUrl: '/local/device/storage/receipt_test.jpg',
        status: 'pending',
      );

      await firestoreService.createExpense(expense);
      mesajGuncelle(
        'Masraf oluşturuldu ve yönetici onayına sunuldu!\n'
        'Masraf ID: ${expense.expenseId}\n'
        'Tutar: ${(expense.amount / 100).toStringAsFixed(2)} TL',
      );
      expenseAmountController.clear();
    } catch (e) {
      mesajGuncelle('Masraf gönderme hatası: $e');
    }
  }

  Future<void> masrafiOnayla(String expenseId) async {
    setState(() => isLoading = true);
    try {
      await firestoreService.approveExpense(
        expenseId: expenseId,
        accountingCode: 'ACC-770-OFFICE',
      );
      mesajGuncelle(
        'Masraf onaylandı! Şirket kasasından düşülüp çalışana aktarıldı.',
      );
    } catch (e) {
      mesajGuncelle('Masraf onay hatası: $e');
    }
  }

  Future<void> masrafiReddet(String expenseId) async {
    final reason = rejectReasonController.text.trim().isEmpty
        ? 'Politika dışı harcama'
        : rejectReasonController.text.trim();

    setState(() => isLoading = true);
    try {
      await firestoreService.rejectExpense(
        expenseId: expenseId,
        reason: reason,
      );
      mesajGuncelle('Masraf gerekçeli reddedildi: $reason');
    } catch (e) {
      mesajGuncelle('Masraf ret hatası: $e');
    }
  }

  // ================= 4. POS VE KART ÇEKİM SİMÜLASYONU =================
  Future<void> kartlaPosTahsilatYap() async {
    final amountText = posAmountController.text.trim();
    final amountTl = double.tryParse(amountText.replaceAll(',', '.'));
    if (amountTl == null || amountTl <= 0) {
      mesajGuncelle('Geçerli bir POS tutarı giriniz.');
      return;
    }

    final kurus = (amountTl * 100).round();
    setState(() => isLoading = true);
    try {
      final tx = await firestoreService.executeCardPosPayment(
        companyId: 'company_001',
        maskedCardNumber: '**** **** **** 4242',
        amountKurus: kurus,
      );
      mesajGuncelle(
        'POS Tahsilatı Başarılı!\n'
        'Slip No: ${tx.txId}\n'
        'Tahsilat: ${(tx.amount / 100).toStringAsFixed(2)} TL\n'
        'Şirket kasasına eklendi.',
      );
      posAmountController.clear();
    } catch (e) {
      mesajGuncelle('POS hatası: $e');
    }
  }

  // ================= WIDGET BUILD =================
  @override
  Widget build(BuildContext context) {
    final currentUser = authService.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: const Text('PayPulse — macOS Demo & Test Tezgahı'),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        actions: [
          if (currentUser != null)
            StreamBuilder<int>(
              stream: firestoreService.watchUnreadNotificationCount(
                currentUser.uid,
              ),
              builder: (context, snapshot) {
                final count = snapshot.data ?? 0;
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Badge(
                      isLabelVisible: count > 0,
                      label: Text('$count'),
                      child: const Icon(Icons.notifications_rounded),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Durum Göstergesi
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blueGrey.shade200),
              ),
              child: Text(
                mesaj,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // AKTİF KULLANICI VE CANLI CÜZDAN KARTI
            if (currentUser != null) ...[
              _buildActiveUserSection(currentUser),
              const SizedBox(height: 16),
            ],

            // 1. KULLANICI OTURUM KARTI
            _buildAuthSection(currentUser),
            const SizedBox(height: 16),

            // 2. FAST PARA TRANSFERİ & ALICI BULMA
            if (currentUser != null) ...[
              _buildTransferSection(),
              const SizedBox(height: 16),

              // 3. CANLI BİLDİRİMLER (macOS Gerçek Zamanlı Akış)
              _buildNotificationsSection(currentUser.uid),
              const SizedBox(height: 16),

              // 4. CANLI İŞLEM GEÇMİŞİ
              _buildTransactionsSection(currentUser.uid),
              const SizedBox(height: 16),

              // 5. MASRAF YÖNETİMİ & ONAY MASASI
              _buildExpenseSection(currentUser.uid),
              const SizedBox(height: 16),

              // 6. SANAL POS SİMÜLASYONU
              _buildPosSection(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActiveUserSection(dynamic user) {
    return Card(
      color: const Color(0xFF1E293B),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Aktif Oturum: ${user.email}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                OutlinedButton(
                  onPressed: cikisYap,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                  ),
                  child: const Text('Çıkış'),
                ),
              ],
            ),
            const Divider(color: Colors.white24),
            StreamBuilder<WalletModel?>(
              stream: firestoreService.watchUserWallet(user.uid as String),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LinearProgressIndicator();
                }
                final wallet = snapshot.data;
                if (wallet == null) {
                  return const Text(
                    'Cüzdan oluşturuluyor...',
                    style: TextStyle(color: Colors.white70),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'IBAN: ${wallet.iban ?? "-"}',
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 13,
                            fontFamily: 'monospace',
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.copy,
                            size: 16,
                            color: Colors.amber,
                          ),
                          onPressed: () {
                            if (wallet.iban != null) {
                              Clipboard.setData(
                                ClipboardData(text: wallet.iban!),
                              );
                              mesajGuncelle(
                                'IBAN panoya kopyalandı: ${wallet.iban}',
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _balanceChip(
                          '₺ TL',
                          (wallet.balanceTl / 100).toStringAsFixed(2),
                          const Color(0xFF10B981),
                        ),
                        _balanceChip(
                          '\$ USD',
                          (wallet.balanceUsd / 100).toStringAsFixed(2),
                          Colors.blueAccent,
                        ),
                        _balanceChip(
                          '€ EUR',
                          (wallet.balanceEur / 100).toStringAsFixed(2),
                          Colors.purpleAccent,
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _balanceChip(String currency, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Text(currency, style: TextStyle(color: color, fontSize: 11)),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthSection(dynamic currentUser) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '1. Kimlik Doğrulama (Auth & Cüzdan)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Ad Soyad (Kayıt için)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'E-posta',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Şifre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : kayitOl,
                    child: const Text('Kayıt Ol'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : girisYap,
                    child: const Text('Giriş Yap'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransferSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '2. Atomik FAST Para Transferi',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: targetIbanController,
              decoration: const InputDecoration(
                labelText: 'Hedef TR IBAN',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: isLoading ? null : aliciyiSorgula,
              icon: const Icon(Icons.person_search),
              label: const Text('Alıcıyı Güvenli Doğrula (Directory)'),
            ),
            if (searchedRecipient != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Doğrulanan Alıcı: ${searchedRecipient!.maskedName}',
                  style: const TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            TextField(
              controller: transferAmountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Tutar (TL)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: isLoading ? null : fastTransferiYap,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              child: const Text('FAST Transferini Gerçekleştir'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsSection(String userId) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '3. Canlı Uygulama İçi Bildirimler (macOS / Cross-Platform)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 160,
              child: StreamBuilder<List<NotificationModel>>(
                stream: firestoreService.watchUserNotifications(userId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final list = snapshot.data ?? [];
                  if (list.isEmpty) {
                    return const Center(child: Text('Henüz bir bildirim yok.'));
                  }

                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final notif = list[index];
                      return ListTile(
                        dense: true,
                        leading: Icon(
                          notif.type == 'transfer_received'
                              ? Icons.arrow_downward_rounded
                              : (notif.type == 'expense_approved'
                                    ? Icons.check_circle_outline
                                    : Icons.notifications),
                          color: notif.isRead ? Colors.grey : Colors.blue,
                        ),
                        title: Text(
                          notif.title,
                          style: TextStyle(
                            fontWeight: notif.isRead
                                ? FontWeight.normal
                                : FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(notif.body),
                        trailing: notif.isRead
                            ? const Text(
                                'Okundu',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              )
                            : IconButton(
                                icon: const Icon(Icons.done, size: 16),
                                onPressed: () =>
                                    firestoreService.markNotificationAsRead(
                                      notif.notificationId,
                                    ),
                              ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsSection(String userId) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '4. Gerçek Zamanlı İşlem Geçmişi (Ledger)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 160,
              child: StreamBuilder<List<TransactionModel>>(
                stream: firestoreService.watchUserTransactions(userId),
                builder: (context, snapshot) {
                  final list = snapshot.data ?? [];
                  if (list.isEmpty) {
                    return const Center(
                      child: Text('Henüz bir finansal işlem yok.'),
                    );
                  }

                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final tx = list[index];
                      final isIncoming = tx.receiverId == userId;
                      return ListTile(
                        dense: true,
                        leading: Icon(
                          isIncoming ? Icons.south_west : Icons.north_east,
                          color: isIncoming ? Colors.green : Colors.redAccent,
                        ),
                        title: Text(
                          '${isIncoming ? "+" : "-"}${(tx.amount / 100).toStringAsFixed(2)} ${tx.currency}',
                        ),
                        subtitle: Text(
                          'Tür: ${tx.type} • ${tx.timestamp.toLocal()}',
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseSection(String userId) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '5. Masraf Masası & Yönetici Onay Akışı',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: expenseAmountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Harcama Tutarı (TL)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: isLoading ? null : masrafGonder,
              child: const Text('Masraf Talebi Gönder'),
            ),
            const Divider(),
            const Text(
              'Onay Bekleyen Masraflar (Şirket: company_001):',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
            SizedBox(
              height: 170,
              child: StreamBuilder<List<ExpenseModel>>(
                stream: firestoreService.watchCompanyExpenses('company_001'),
                builder: (context, snapshot) {
                  final list = snapshot.data ?? [];
                  if (list.isEmpty)
                    return const Center(
                      child: Text('Onay bekleyen masraf yok.'),
                    );

                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final exp = list[index];
                      return Card(
                        color: Colors.grey.shade50,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          dense: true,
                          title: Text(
                            '${(exp.amount / 100).toStringAsFixed(2)} TL (Durum: ${exp.status})',
                          ),
                          subtitle: Text('Çalışan: ${exp.employeeId}'),
                          trailing: exp.status == 'pending'
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.check,
                                        color: Colors.green,
                                      ),
                                      onPressed: () =>
                                          masrafiOnayla(exp.expenseId),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.red,
                                      ),
                                      onPressed: () =>
                                          masrafiReddet(exp.expenseId),
                                    ),
                                  ],
                                )
                              : null,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPosSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '6. Sanal POS Tahsilat Simülasyonu',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: posAmountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Çekim Tutarı (TL)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: isLoading ? null : kartlaPosTahsilatYap,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Kredi Kartı ile Çekim Yap (Şirket Kasasına Ekle)',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
