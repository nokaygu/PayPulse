import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../data/models/wallet_model.dart';
import '../bloc/dev_console_cubit.dart';

class DevActiveUserSection extends StatelessWidget {
  final DevConsoleCubit cubit;
  final String? email;
  final String uid;

  const DevActiveUserSection({
    super.key,
    required this.cubit,
    required this.email,
    required this.uid,
  });

  @override
  Widget build(BuildContext context) {
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
                        _BalanceChip(
                          currency: '₺ TL',
                          amount: (wallet.balanceTl / 100).toStringAsFixed(2),
                          color: const Color(0xFF10B981),
                        ),
                        _BalanceChip(
                          currency: '\$ USD',
                          amount: (wallet.balanceUsd / 100).toStringAsFixed(2),
                          color: Colors.blueAccent,
                        ),
                        _BalanceChip(
                          currency: '€ EUR',
                          amount: (wallet.balanceEur / 100).toStringAsFixed(2),
                          color: Colors.purpleAccent,
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
}

class _BalanceChip extends StatelessWidget {
  final String currency;
  final String amount;
  final Color color;

  const _BalanceChip({
    required this.currency,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
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
}

