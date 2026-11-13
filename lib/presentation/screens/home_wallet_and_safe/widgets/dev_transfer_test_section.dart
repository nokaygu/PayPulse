import 'package:flutter/material.dart';

import '../bloc/dev_console_cubit.dart';
import 'dev_section_card.dart';

class DevTransferTestSection extends StatelessWidget {
  final DevConsoleCubit cubit;
  final DevConsoleState state;

  const DevTransferTestSection({
    super.key,
    required this.cubit,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return DevSectionCard(
      title: '2. Atomik FAST Para Transferi',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
    );
  }
}

