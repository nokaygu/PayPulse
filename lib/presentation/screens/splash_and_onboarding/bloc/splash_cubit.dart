import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/equatable.dart';

/// Açılış ekranı animasyon ve bekleme durumu.
class SplashState extends Equatable {
  final bool animateIn;
  final bool isCompleted;

  const SplashState({
    this.animateIn = false,
    this.isCompleted = false,
  });

  SplashState copyWith({
    bool? animateIn,
    bool? isCompleted,
  }) {
    return SplashState(
      animateIn: animateIn ?? this.animateIn,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [animateIn, isCompleted];
}

/// Açılış ekranı animasyon başlangıcını ve zamanlayıcısını yöneten Cubit.
class SplashCubit extends Cubit<SplashState> {
  Timer? _completionTimer;

  SplashCubit({
    Duration completionDelay = const Duration(milliseconds: 1800),
  }) : super(const SplashState()) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isClosed) {
        emit(state.copyWith(animateIn: true));
      }
    });

    _completionTimer = Timer(completionDelay, () {
      if (!isClosed) {
        emit(state.copyWith(isCompleted: true));
      }
    });
  }

  @override
  Future<void> close() {
    _completionTimer?.cancel();
    return super.close();
  }
}
