import 'package:flutter_bloc/flutter_bloc.dart';

import 'cards_event.dart';
import 'cards_state.dart';

class CardsBloc extends Bloc<CardsEvent, CardsState> {
  String? _currentUserId;

  CardsBloc() : super(const CardsState()) {
    on<CardsLoadRequested>(_onLoadRequested);
    on<CardAdded>(_onCardAdded);
    on<CardStatusToggled>(_onStatusToggled);
    on<CardLimitUpdated>(_onLimitUpdated);
    on<CardDeleted>(_onCardDeleted);
  }

  Future<void> _onLoadRequested(
    CardsLoadRequested event,
    Emitter<CardsState> emit,
  ) async {
    _currentUserId = event.userId;
    emit(state.copyWith(status: CardsStatus.loading, clearError: true));

    try {
      // Simülasyon kart listesi: Bireysel sanal ve fiziksel kartlar
      final defaultCards = [
        const PaymentCardItem(
          cardId: 'card_001',
          cardTitle: 'PayPulse Platinum Metal',
          cardNumber: '•••• •••• •••• 9412',
          expiryDate: '09/29',
          cardType: 'physical',
          limitInKurus: 5000000, // 50.000 TL
          spentInKurus: 1240000, // 12.400 TL
          isFrozen: false,
        ),
        const PaymentCardItem(
          cardId: 'card_002',
          cardTitle: 'Sanal Alışveriş Kartı',
          cardNumber: '•••• •••• •••• 3048',
          expiryDate: '11/27',
          cardType: 'virtual',
          limitInKurus: 1000000, // 10.000 TL
          spentInKurus: 345000,  // 3.450 TL
          isFrozen: false,
        ),
      ];

      emit(state.copyWith(
        status: CardsStatus.success,
        cards: defaultCards,
        selectedCardId: defaultCards.first.cardId,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CardsStatus.failure,
        errorMessage: 'Kartlar yüklenemedi: $e',
      ));
    }
  }

  void _onCardAdded(CardAdded event, Emitter<CardsState> emit) {
    final newCard = PaymentCardItem(
      cardId: 'card_${DateTime.now().millisecondsSinceEpoch}',
      cardTitle: event.cardTitle,
      cardNumber: event.cardNumber,
      expiryDate: event.expiryDate,
      cardType: event.cardType,
      limitInKurus: event.limitInKurus,
      spentInKurus: 0,
      isFrozen: false,
    );

    final updatedList = List<PaymentCardItem>.from(state.cards)..add(newCard);

    emit(state.copyWith(
      cards: updatedList,
      selectedCardId: newCard.cardId,
      successMessage: 'Yeni kart başarıyla eklendi.',
    ));
  }

  void _onStatusToggled(CardStatusToggled event, Emitter<CardsState> emit) {
    final updatedList = state.cards.map((c) {
      if (c.cardId == event.cardId) {
        return c.copyWith(isFrozen: !c.isFrozen);
      }
      return c;
    }).toList();

    emit(state.copyWith(
      cards: updatedList,
      successMessage: 'Kart durumu güncellendi.',
    ));
  }

  void _onLimitUpdated(CardLimitUpdated event, Emitter<CardsState> emit) {
    final updatedList = state.cards.map((c) {
      if (c.cardId == event.cardId) {
        return c.copyWith(limitInKurus: event.newLimitInKurus);
      }
      return c;
    }).toList();

    emit(state.copyWith(
      cards: updatedList,
      successMessage: 'Kart limiti başarıyla güncellendi.',
    ));
  }

  void _onCardDeleted(CardDeleted event, Emitter<CardsState> emit) {
    final updatedList = state.cards.where((c) => c.cardId != event.cardId).toList();

    emit(state.copyWith(
      cards: updatedList,
      selectedCardId: updatedList.isNotEmpty ? updatedList.first.cardId : null,
      successMessage: 'Kart başarıyla silindi.',
    ));
  }
}

