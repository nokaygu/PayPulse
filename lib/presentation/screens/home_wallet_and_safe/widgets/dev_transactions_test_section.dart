import 'package:flutter/material.dart';

import '../../../../data/models/transaction_model.dart';
import '../bloc/dev_console_cubit.dart';
import 'dev_section_card.dart';

class DevTransactionsTestSection extends StatelessWidget {
  final DevConsoleCubit cubit;
  final String userId;

  const DevTransactionsTestSection({
    super.key,
    required this.cubit,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return DevSectionCard(
      title: '4. Gerçek Zamanlı İşlem Geçmişi (Ledger)',
      crossAxisAlignment: CrossAxisAlignment.start,
      child: SizedBox(
        height: 160,
        child: StreamBuilder<List<TransactionModel>>(
          stream: cubit.watchUserTransactions(userId),
          builder: (context, snapshot) {
            final list = snapshot.data ?? [];
            if (list.isEmpty) {
              return const Center(child: Text('Henüz bir finansal işlem yok.'));
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
    );
  }
}

