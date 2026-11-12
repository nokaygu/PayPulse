import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'bloc/cards_bloc.dart';
import 'bloc/cards_event.dart';
import 'bloc/cards_state.dart';

class CardsManagementScreen extends StatelessWidget {
  const CardsManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CardsBloc()..add(const CardsLoadRequested('user_1')),
      child: const _CardsManagementView(),
    );
  }
}

class _CardsManagementView extends StatelessWidget {
  const _CardsManagementView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kart Yönetimi', style: AppTextStyles.headlineSmall),
        centerTitle: true,
      ),
      body: BlocConsumer<CardsBloc, CardsState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppLightColors.error,
              ),
            );
          }
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: AppLightColors.primary,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.cards.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.credit_card_off_rounded, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('Kayıtlı kart bulunamadı.', style: AppTextStyles.bodyLarge),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.cards.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final card = state.cards[index];
              return _CreditCardWidget(card: card);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCardDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Yeni Kart Ekle'),
      ),
    );
  }

  void _showAddCardDialog(BuildContext context) {
    final titleController = TextEditingController();
    final numberController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (bottomSheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Yeni Kart Oluştur', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Kart Başlığı (Örn: Dijital Abonelik)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: numberController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Kart Numarası',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  context.read<CardsBloc>().add(
                        CardAdded(
                          cardTitle: titleController.text,
                          cardNumber: numberController.text.isEmpty
                              ? '•••• •••• •••• 1234'
                              : numberController.text,
                          expiryDate: '12/28',
                          cardType: 'virtual',
                          limitInKurus: 2000000,
                        ),
                      );
                  Navigator.pop(bottomSheetContext);
                }
              },
              child: const Text('Oluştur'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreditCardWidget extends StatelessWidget {
  final PaymentCardItem card;

  const _CreditCardWidget({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: card.isFrozen
              ? [Colors.grey.shade700, Colors.grey.shade900]
              : card.cardType == 'virtual'
                  ? [const Color(0xFF6366F1), const Color(0xFF4338CA)]
                  : [const Color(0xFF0F172A), const Color(0xFF1E293B)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                card.cardTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              IconButton(
                onPressed: () {
                  context.read<CardsBloc>().add(CardStatusToggled(card.cardId));
                },
                icon: Icon(
                  card.isFrozen ? Icons.lock_rounded : Icons.lock_open_rounded,
                  color: card.isFrozen ? Colors.redAccent : Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            card.cardNumber,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              letterSpacing: 2.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('LİMİT', style: TextStyle(color: Colors.white54, fontSize: 10)),
                  Text(
                    '₺${card.limitInLira.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('S.K.T', style: TextStyle(color: Colors.white54, fontSize: 10)),
                  Text(
                    card.expiryDate,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

