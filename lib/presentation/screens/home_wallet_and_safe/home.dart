
import 'package:flutter/material.dart';
import '../../../data/datasources/remote/firebase_auth_datasource.dart';
import '../../../data/datasources/remote/firebase_firestore_datasource.dart';

class HomeAndWalletEkrani extends StatefulWidget {
  const HomeAndWalletEkrani({super.key});

  @override
  State<HomeAndWalletEkrani> createState() =>
      _HomeAndWalletEkraniState();
}

class _HomeAndWalletEkraniState extends State<HomeAndWalletEkrani> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  final authService = FirebaseAuthDatasource();
  final firestoreService = FirebaseFirestoreDatasource();

  String mesaj = 'Henüz bir işlem yapılmadı.';
  bool isLoading = false;

  // Ekrandaki durum mesajını günceller.
  void mesajGuncelle(String yeniMesaj) {
    if (!mounted) return;

    setState(() {
      mesaj = yeniMesaj;
      isLoading = false;
    });
  }

  // Firebase Authentication işlemleri

  // Yeni kullanıcı kaydı oluşturur.
  Future<void> kayitOl() async {
    setState(() => isLoading = true);

    try {
      await authService.register(
        emailController.text.trim(),
        passwordController.text,
      );

      mesajGuncelle('Kayıt başarılı!');
    } catch (e) {
      mesajGuncelle('Kayıt hatası: $e');
    }
  }

  // Mevcut kullanıcıyla giriş yapar.
  Future<void> girisYap() async {
    setState(() => isLoading = true);

    try {
      await authService.login(
        emailController.text.trim(),
        passwordController.text,
      );

      mesajGuncelle('Giriş başarılı!');
    } catch (e) {
      mesajGuncelle('Giriş hatası: $e');
    }
  }

  // Kullanıcının oturumunu kapatır.
  Future<void> cikisYap() async {
    setState(() => isLoading = true);

    try {
      await authService.logout();

      mesajGuncelle('Çıkış yapıldı!');
    } catch (e) {
      mesajGuncelle('Çıkış hatası: $e');
    }
  }

  // Firestore CRUD işlemleri

  // Giriş yapan kullanıcının UID değerini getirir.
  String? kullaniciUid() {
    return authService.getCurrentUser()?.uid;
  }

  // Firestore'a test kullanıcısı ekler.
  Future<void> veriEkle() async {
    final uid = kullaniciUid();

    if (uid == null) {
      mesajGuncelle('Önce giriş yapmalısın!');
      return;
    }

    if (nameController.text.trim().isEmpty) {
      mesajGuncelle('Lütfen isim gir!');
      return;
    }

    setState(() => isLoading = true);

    try {
      await firestoreService.addUser(
        uid,
        nameController.text.trim(),
        authService.getCurrentUser()?.email ?? '',
      );

      mesajGuncelle('Firestore: Veri başarıyla eklendi!');
    } catch (e) {
      mesajGuncelle('Veri ekleme hatası: $e');
    }
  }

  // Firestore'dan kullanıcı verisini okur.
  Future<void> veriGetir() async {
    final uid = kullaniciUid();

    if (uid == null) {
      mesajGuncelle('Önce giriş yapmalısın!');
      return;
    }

    setState(() => isLoading = true);

    try {
      final data = await firestoreService.getUser(uid);

      if (data == null) {
        mesajGuncelle('Firestore: Kullanıcı belgesi bulunamadı.');
      } else {
        mesajGuncelle(
          'Firestore verileri:\n'
          'İsim: ${data['name']}\n'
          'E-posta: ${data['email']}',
        );
      }
    } catch (e) {
      mesajGuncelle('Veri okuma hatası: $e');
    }
  }

  // Firestore'daki kullanıcı adını günceller.
  Future<void> veriGuncelle() async {
    final uid = kullaniciUid();

    if (uid == null) {
      mesajGuncelle('Önce giriş yapmalısın!');
      return;
    }

    if (nameController.text.trim().isEmpty) {
      mesajGuncelle('Yeni isim gir!');
      return;
    }

    setState(() => isLoading = true);

    try {
      await firestoreService.updateUser(
        uid,
        nameController.text.trim(),
      );

      mesajGuncelle('Firestore: İsim güncellendi!');
    } catch (e) {
      mesajGuncelle('Güncelleme hatası: $e');
    }
  }

  // Firestore'daki test belgesini siler.
  Future<void> veriSil() async {
    final uid = kullaniciUid();

    if (uid == null) {
      mesajGuncelle('Önce giriş yapmalısın!');
      return;
    }

    setState(() => isLoading = true);

    try {
      await firestoreService.deleteUser(uid);

      mesajGuncelle('Firestore: Veri silindi!');
    } catch (e) {
      mesajGuncelle('Silme hatası: $e');
    }
  }

  // Firebase Firestore'dan kullanıcının cüzdanını getirir.
  Future<void> cuzdanGetir() async {
    final user = authService.getCurrentUser();

    if (user == null) {
      mesajGuncelle('Önce giriş yapmalısın!');
      return;
    }

    setState(() => isLoading = true);

    try {
      final walletId = 'wallet_${user.uid}';

      final wallet = await firestoreService.getWallet(walletId);

      if (wallet == null) {
        mesajGuncelle('Cüzdan bulunamadı!');
        return;
      }

      mesajGuncelle(
        'Cüzdan bilgileri:\n'
        'TL: ${(wallet.balanceTl / 100).toStringAsFixed(2)}\n'
        'USD: ${(wallet.balanceUsd / 100).toStringAsFixed(2)}\n'
        'EUR: ${(wallet.balanceEur / 100).toStringAsFixed(2)}',
      );
    } catch (e) {
      mesajGuncelle('Cüzdan getirme hatası: $e');
    }
  }


  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PayPulse - Firebase Test'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.account_balance_wallet,
              size: 65,
              color: Colors.blue,
            ),

            const SizedBox(height: 16),

            const Text(
              'Firebase Authentication',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-posta',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Şifre',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: isLoading ? null : kayitOl,
              child: const Text('Kayıt Ol'),
            ),

            ElevatedButton(
              onPressed: isLoading ? null : girisYap,
              child: const Text('Giriş Yap'),
            ),

            OutlinedButton(
              onPressed: isLoading ? null : cikisYap,
              child: const Text('Çıkış Yap'),
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            const Text(
              'Cloud Firestore CRUD Test',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Kullanıcı adı',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: isLoading ? null : veriEkle,
              child: const Text('Veri Ekle'),
            ),

            ElevatedButton(
              onPressed: isLoading ? null : veriGetir,
              child: const Text('Veri Getir'),
            ),

            ElevatedButton(
              onPressed: isLoading ? null : veriGuncelle,
              child: const Text('Veri Güncelle'),
            ),

            OutlinedButton(
              onPressed: isLoading ? null : veriSil,
              child: const Text('Veri Sil'),
            ),

            const SizedBox(height: 24),

            if (isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),

            const SizedBox(height: 12),

            Text(
              mesaj,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
            ),

            const SizedBox(height: 24),

const Divider(),

const Text(
  'WalletModel Test',
  textAlign: TextAlign.center,
  style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 16),

ElevatedButton(
  onPressed: isLoading ? null : cuzdanGetir,
  child: const Text('Cüzdan Getir'),
),
          ],
        ),
      ),
    );
  }
}
