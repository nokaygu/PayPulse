import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/equatable.dart';
import '../../../../data/datasources/remote/firebase_auth_datasource.dart';
import '../../../../data/datasources/remote/firebase_firestore_datasource.dart';
import '../../../../data/datasources/remote/firebase_notification_datasource.dart';
import '../../../../data/models/expense_model.dart';
import '../../../../data/models/notification_model.dart';
import '../../../../data/models/safe_recipient_model.dart';
import '../../../../data/models/transaction_model.dart';
import '../../../../data/models/wallet_model.dart';

/// Geliştirici ve Jüri Değerlendirme Tezgahı ekran durumu.
class DevConsoleState extends Equatable {
  final String statusMessage;
  final bool isLoading;
  final SafeRecipientModel? searchedRecipient;
  final User? currentUser;

  const DevConsoleState({
    this.statusMessage = 'Sistem hazır. Giriş yapabilir veya test edebilirsiniz.',
    this.isLoading = false,
    this.searchedRecipient,
    this.currentUser,
  });

  DevConsoleState copyWith({
    String? statusMessage,
    bool? isLoading,
    SafeRecipientModel? searchedRecipient,
    bool clearSearchedRecipient = false,
    User? currentUser,
    bool clearUser = false,
  }) {
    return DevConsoleState(
      statusMessage: statusMessage ?? this.statusMessage,
      isLoading: isLoading ?? this.isLoading,
      searchedRecipient: clearSearchedRecipient
          ? null
          : (searchedRecipient ?? this.searchedRecipient),
      currentUser: clearUser ? null : (currentUser ?? this.currentUser),
    );
  }

  @override
  List<Object?> get props => [
    statusMessage,
    isLoading,
    searchedRecipient,
    currentUser?.uid,
  ];
}

/// macOS & Android Firebase Test Tezgahı ekranının tüm işlemlerini yöneten Cubit.
class DevConsoleCubit extends Cubit<DevConsoleState> {
  final FirebaseAuthDatasource _authDatasource;
  final FirebaseFirestoreDatasource _firestoreDatasource;
  final FirebaseNotificationDatasource _notificationDatasource;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  final TextEditingController targetIbanController = TextEditingController();
  final TextEditingController transferAmountController = TextEditingController();

  final TextEditingController expenseAmountController = TextEditingController();
  final TextEditingController expenseVatController = TextEditingController();
  final TextEditingController rejectReasonController = TextEditingController();

  final TextEditingController posAmountController = TextEditingController();

  DevConsoleCubit({
    FirebaseAuthDatasource? authDatasource,
    FirebaseFirestoreDatasource? firestoreDatasource,
    FirebaseNotificationDatasource? notificationDatasource,
  }) : _authDatasource = authDatasource ?? FirebaseAuthDatasource(),
       _firestoreDatasource =
           firestoreDatasource ?? FirebaseFirestoreDatasource(),
       _notificationDatasource =
           notificationDatasource ?? FirebaseNotificationDatasource(),
       super(const DevConsoleState()) {
    refreshCurrentUser();
  }

  void refreshCurrentUser() {
    try {
      final user = _authDatasource.getCurrentUser();
      if (!isClosed) {
        emit(state.copyWith(currentUser: user, clearUser: user == null));
      }
    } catch (_) {
      // Firebase test ortamında başlatılmamış olabilir.
    }
  }

  void updateMessage(String newMessage) {
    if (isClosed) return;
    emit(state.copyWith(statusMessage: newMessage, isLoading: false));
  }

  Stream<int> watchUnreadNotificationCount(String uid) =>
      _firestoreDatasource.watchUnreadNotificationCount(uid);

  Stream<WalletModel?> watchUserWallet(String uid) =>
      _firestoreDatasource.watchUserWallet(uid);

  Stream<List<NotificationModel>> watchUserNotifications(String uid) =>
      _firestoreDatasource.watchUserNotifications(uid);

  Stream<List<TransactionModel>> watchUserTransactions(String uid) =>
      _firestoreDatasource.watchUserTransactions(uid);

  Stream<List<ExpenseModel>> watchCompanyExpenses(String companyId) =>
      _firestoreDatasource.watchCompanyExpenses(companyId);

  Future<void> markNotificationAsRead(String notificationId) =>
      _firestoreDatasource.markNotificationAsRead(notificationId);

  Future<void> register() async {
    emit(state.copyWith(isLoading: true));
    try {
      final cred = await _authDatasource.register(
        emailController.text.trim(),
        passwordController.text,
        name: nameController.text.trim().isEmpty
            ? 'Kullanıcı'
            : nameController.text.trim(),
      );
      await _notificationDatasource.saveTokenToFirestore();
      if (!isClosed) {
        emit(
          state.copyWith(
            currentUser: cred.user,
            isLoading: false,
            statusMessage:
                'Kayıt başarılı! Otomatik sıfır bakiyeli cüzdan ve IBAN oluşturuldu.',
          ),
        );
      }
    } catch (e) {
      updateMessage('Kayıt hatası: $e');
    }
  }

  Future<void> login() async {
    emit(state.copyWith(isLoading: true));
    try {
      final cred = await _authDatasource.login(
        emailController.text.trim(),
        passwordController.text,
      );
      await _notificationDatasource.saveTokenToFirestore();
      if (!isClosed) {
        emit(
          state.copyWith(
            currentUser: cred.user,
            isLoading: false,
            statusMessage: 'Giriş başarılı!',
          ),
        );
      }
    } catch (e) {
      updateMessage('Giriş hatası: $e');
    }
  }

  Future<void> logout() async {
    emit(state.copyWith(isLoading: true));
    try {
      final user = _authDatasource.getCurrentUser();
      if (user != null) {
        await _notificationDatasource.deleteTokenOnLogout(user.uid);
      }
      await _authDatasource.logout();
      if (!isClosed) {
        emit(
          state.copyWith(
            clearUser: true,
            clearSearchedRecipient: true,
            isLoading: false,
            statusMessage: 'Çıkış yapıldı.',
          ),
        );
      }
    } catch (e) {
      updateMessage('Çıkış hatası: $e');
    }
  }

  Future<void> lookupRecipient() async {
    final iban = targetIbanController.text.trim();
    if (iban.isEmpty) {
      updateMessage('Lütfen hedef IBAN giriniz.');
      return;
    }

    emit(state.copyWith(isLoading: true));
    try {
      final recipient = await _firestoreDatasource.findRecipientByIban(iban);
      if (isClosed) return;
      emit(
        state.copyWith(
          searchedRecipient: recipient,
          clearSearchedRecipient: recipient == null,
          isLoading: false,
          statusMessage: recipient != null
              ? 'Alıcı Bulundu: ${recipient.maskedName} (${recipient.iban})'
              : 'IBAN bulunamadı. Lütfen geçerli bir PayPulse IBAN girin.',
        ),
      );
    } catch (e) {
      updateMessage('Sorgulama hatası: $e');
    }
  }

  Future<void> executeFastTransfer() async {
    final user = _authDatasource.getCurrentUser();
    if (user == null) {
      updateMessage('Önce oturum açmalısınız!');
      return;
    }

    final targetIban = targetIbanController.text.trim();
    final amountText = transferAmountController.text.trim();
    final amountTl = double.tryParse(amountText.replaceAll(',', '.'));

    if (amountTl == null || amountTl <= 0) {
      updateMessage('Geçerli bir transfer tutarı giriniz.');
      return;
    }

    final kurus = (amountTl * 100).round();

    emit(state.copyWith(isLoading: true));
    try {
      final tx = await _firestoreDatasource.executeFastTransferByIban(
        senderUserId: user.uid,
        targetIban: targetIban,
        amountKurus: kurus,
      );

      transferAmountController.clear();
      updateMessage(
        'FAST Transferi Başarılı!\n'
        'İşlem No: ${tx.txId}\n'
        'Tutar: ${(tx.amount / 100).toStringAsFixed(2)} TL\n'
        'Alıcıya bildirim iletildi.',
      );
    } catch (e) {
      updateMessage('Transfer hatası: $e');
    }
  }

  Future<void> submitExpense() async {
    final user = _authDatasource.getCurrentUser();
    if (user == null) {
      updateMessage('Önce oturum açmalısınız!');
      return;
    }

    final amountText = expenseAmountController.text.trim();
    final amountTl = double.tryParse(amountText.replaceAll(',', '.'));
    if (amountTl == null || amountTl <= 0) {
      updateMessage('Geçerli bir masraf tutarı girin.');
      return;
    }

    final kurus = (amountTl * 100).round();
    final vatKurus = (kurus * 0.20).round();

    emit(state.copyWith(isLoading: true));
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

      await _firestoreDatasource.createExpense(expense);
      expenseAmountController.clear();
      updateMessage(
        'Masraf oluşturuldu ve yönetici onayına sunuldu!\n'
        'Masraf ID: ${expense.expenseId}\n'
        'Tutar: ${(expense.amount / 100).toStringAsFixed(2)} TL',
      );
    } catch (e) {
      updateMessage('Masraf gönderme hatası: $e');
    }
  }

  Future<void> approveExpense(String expenseId) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _firestoreDatasource.approveExpense(
        expenseId: expenseId,
        accountingCode: 'ACC-770-OFFICE',
      );
      updateMessage(
        'Masraf onaylandı! Şirket kasasından düşülüp çalışana aktarıldı.',
      );
    } catch (e) {
      updateMessage('Masraf onay hatası: $e');
    }
  }

  Future<void> rejectExpense(String expenseId) async {
    final reason = rejectReasonController.text.trim().isEmpty
        ? 'Politika dışı harcama'
        : rejectReasonController.text.trim();

    emit(state.copyWith(isLoading: true));
    try {
      await _firestoreDatasource.rejectExpense(
        expenseId: expenseId,
        reason: reason,
      );
      updateMessage('Masraf gerekçeli reddedildi: $reason');
    } catch (e) {
      updateMessage('Masraf ret hatası: $e');
    }
  }

  Future<void> collectPosPayment() async {
    final amountText = posAmountController.text.trim();
    final amountTl = double.tryParse(amountText.replaceAll(',', '.'));
    if (amountTl == null || amountTl <= 0) {
      updateMessage('Geçerli bir POS tutarı giriniz.');
      return;
    }

    final kurus = (amountTl * 100).round();
    emit(state.copyWith(isLoading: true));
    try {
      final tx = await _firestoreDatasource.executeCardPosPayment(
        companyId: 'company_001',
        maskedCardNumber: '**** **** **** 4242',
        amountKurus: kurus,
      );
      posAmountController.clear();
      updateMessage(
        'POS Tahsilatı Başarılı!\n'
        'Slip No: ${tx.txId}\n'
        'Tahsilat: ${(tx.amount / 100).toStringAsFixed(2)} TL\n'
        'Şirket kasasına eklendi.',
      );
    } catch (e) {
      updateMessage('POS hatası: $e');
    }
  }

  @override
  Future<void> close() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    targetIbanController.dispose();
    transferAmountController.dispose();
    expenseAmountController.dispose();
    expenseVatController.dispose();
    rejectReasonController.dispose();
    posAmountController.dispose();
    return super.close();
  }
}
