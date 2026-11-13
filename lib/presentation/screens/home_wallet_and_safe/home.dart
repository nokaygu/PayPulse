import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/expense_model.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/wallet_model.dart';
import 'bloc/dev_console_cubit.dart';

/// PayPulse macOS & Android Firebase Test ve Jüri Değerlendirme Tezgahı (Stateless + DevConsoleCubit).
class HomeAndWalletEkrani extends StatelessWidget {
  const HomeAndWalletEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DevConsoleCubit>(
      create: (_) => DevConsoleCubit(),
      child: const _DevConsoleView(),
    );
  }
}

class _DevConsoleView extends StatelessWidget {
  const _DevConsoleView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DevConsoleCubit, DevConsoleState>(
      builder: (context, state) {
        final cubit = context.read<DevConsoleCubit>();
        final currentUser = state.currentUser;

        return Scaffold(
          appBar: AppBar(
            title: const Text('PayPulse — macOS Demo & Test Tezgahı'),
            backgroundColor: const Color(0xFF0F172A),
            foregroundColor: Colors.white,
            actions: [
              if (currentUser != null)
                StreamBuilder<int>(
                  stream: cubit.watchUnreadNotificationCount(currentUser.uid),
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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blueGrey.shade200),
                  ),
                  child: Text(
                    state.statusMessage,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                if (currentUser != null) ...[
                  _buildActiveUserSection(cubit, currentUser.email, currentUser.uid),
                  const SizedBox(height: 16),
                ],

                _buildAuthSection(cubit, state),
                const SizedBox(height: 16),

                if (currentUser != null) ...[
                  _buildTransferSection(cubit, state),
                  const SizedBox(height: 16),
                  _buildNotificationsSection(cubit, currentUser.uid),
                  const SizedBox(height: 16),
                  _buildTransactionsSection(cubit, currentUser.uid),
                  const SizedBox(height: 16),
                  _buildExpenseSection(cubit, state),
                  const SizedBox(height: 16),
                  _buildPosSection(cubit, state),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActiveUserSection(
    DevConsoleCubit cubit,
    String? email,
    String uid,
  ) {
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
                  'Aktif Oturum: ${email ?? "-"}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                OutlinedButton(
                  onPressed: cubit.logout,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                  ),
                  child: const Text('Çıkış'),
                ),
              ],
            ),
            const Divider(color: Colors.white24),
            StreamBuilder<WalletModel?>(
              stream: cubit.watchUserWallet(uid),
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
                              cubit.updateMessage(
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

  Widget _buildAuthSection(DevConsoleCubit cubit, DevConsoleState state) {
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
              controller: cubit.nameController,
              decoration: const InputDecoration(
                labelText: 'Ad Soyad (Kayıt için)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: cubit.emailController,
              decoration: const InputDecoration(
                labelText: 'E-posta',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: cubit.passwordController,
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
                    onPressed: state.isLoading ? null : cubit.register,
                    child: const Text('Kayıt Ol'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: state.isLoading ? null : cubit.login,
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

  Widget _buildTransferSection(DevConsoleCubit cubit, DevConsoleState state) {
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
              controller: cubit.targetIbanController,
              decoration: const InputDecoration(
                labelText: 'Hedef TR IBAN',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: state.isLoading ? null : cubit.lookupRecipient,
              icon: const Icon(Icons.person_search),
              label: const Text('Alıcıyı Güvenli Doğrula (Directory)'),
            ),
            if (state.searchedRecipient != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Doğrulanan Alıcı: ${state.searchedRecipient!.maskedName}',
                  style: const TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            TextField(
              controller: cubit.transferAmountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Tutar (TL)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: state.isLoading ? null : cubit.executeFastTransfer,
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

  Widget _buildNotificationsSection(DevConsoleCubit cubit, String userId) {
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
                stream: cubit.watchUserNotifications(userId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final list = snapshot.data ?? [];
                  if (list.isEmpty) {
                    return const Center(
                      child: Text('Henüz bir bildirim yok.'),
                    );
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
                                onPressed: () => cubit.markNotificationAsRead(
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

  Widget _buildTransactionsSection(DevConsoleCubit cubit, String userId) {
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
                stream: cubit.watchUserTransactions(userId),
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

  Widget _buildExpenseSection(DevConsoleCubit cubit, DevConsoleState state) {
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
              controller: cubit.expenseAmountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Harcama Tutarı (TL)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: state.isLoading ? null : cubit.submitExpense,
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
                stream: cubit.watchCompanyExpenses('company_001'),
                builder: (context, snapshot) {
                  final list = snapshot.data ?? [];
                  if (list.isEmpty) {
                    return const Center(
                      child: Text('Onay bekleyen masraf yok.'),
                    );
                  }

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
                                          cubit.approveExpense(exp.expenseId),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.red,
                                      ),
                                      onPressed: () =>
                                          cubit.rejectExpense(exp.expenseId),
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

  Widget _buildPosSection(DevConsoleCubit cubit, DevConsoleState state) {
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
              controller: cubit.posAmountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Çekim Tutarı (TL)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: state.isLoading ? null : cubit.collectPosPayment,
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
