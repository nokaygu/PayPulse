import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/equatable.dart';

/// LoginScreen form ve görünüm durumu.
class LoginFormState extends Equatable {
  final bool isB2BSelected;
  final bool obscurePassword;

  const LoginFormState({
    this.isB2BSelected = false,
    this.obscurePassword = true,
  });

  LoginFormState copyWith({bool? isB2BSelected, bool? obscurePassword}) {
    return LoginFormState(
      isB2BSelected: isB2BSelected ?? this.isB2BSelected,
      obscurePassword: obscurePassword ?? this.obscurePassword,
    );
  }

  @override
  List<Object?> get props => [isB2BSelected, obscurePassword];
}

class LoginFormCubit extends Cubit<LoginFormState> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginFormCubit() : super(const LoginFormState());

  void setB2BSelected(bool value) {
    emit(state.copyWith(isB2BSelected: value));
  }

  void togglePasswordVisibility() {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  @override
  Future<void> close() {
    emailController.dispose();
    passwordController.dispose();
    return super.close();
  }
}

/// RegisterScreen form ve görünüm durumu.
class RegisterFormState extends Equatable {
  final bool isB2BAccount;
  final bool obscurePassword;
  final bool kvkkAccepted;

  const RegisterFormState({
    this.isB2BAccount = false,
    this.obscurePassword = true,
    this.kvkkAccepted = false,
  });

  RegisterFormState copyWith({
    bool? isB2BAccount,
    bool? obscurePassword,
    bool? kvkkAccepted,
  }) {
    return RegisterFormState(
      isB2BAccount: isB2BAccount ?? this.isB2BAccount,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      kvkkAccepted: kvkkAccepted ?? this.kvkkAccepted,
    );
  }

  @override
  List<Object?> get props => [isB2BAccount, obscurePassword, kvkkAccepted];
}

class RegisterFormCubit extends Cubit<RegisterFormState> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController taxNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  RegisterFormCubit() : super(const RegisterFormState());

  void setB2BAccount(bool value) {
    emit(state.copyWith(isB2BAccount: value));
  }

  void togglePasswordVisibility() {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  void setKvkkAccepted(bool value) {
    emit(state.copyWith(kvkkAccepted: value));
  }

  void toggleKvkkAccepted() {
    emit(state.copyWith(kvkkAccepted: !state.kvkkAccepted));
  }

  @override
  Future<void> close() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    companyNameController.dispose();
    taxNumberController.dispose();
    passwordController.dispose();
    return super.close();
  }
}

