import 'package:flutter/material.dart';

import '../../../../data/models/expense_model.dart';
import '../bloc/dev_console_cubit.dart';
import 'dev_section_card.dart';

class DevExpenseTestSection extends StatelessWidget {
  final DevConsoleCubit cubit;
  final DevConsoleState state;

  const DevExpenseTestSection({
    super.key,
    required this.cubit,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return DevSectionCard(
      title: '5. Masraf Masası & Yönetici Onay Akışı',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                  return const Center(child: Text('Onay bekleyen masraf yok.'));
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
    );
  }
}

class DevPosTestSection extends StatelessWidget {
  final DevConsoleCubit cubit;
  final DevConsoleState state;

  const DevPosTestSection({
    super.key,
    required this.cubit,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return DevSectionCard(
      title: '6. Sanal POS Tahsilat Simülasyonu',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
    );
  }
}

