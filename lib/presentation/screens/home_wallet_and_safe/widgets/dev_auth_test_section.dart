import 'package:flutter/material.dart';

import '../bloc/dev_console_cubit.dart';
import 'dev_section_card.dart';

class DevAuthTestSection extends StatelessWidget {
  final DevConsoleCubit cubit;
  final DevConsoleState state;

  const DevAuthTestSection({
    super.key,
    required this.cubit,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return DevSectionCard(
      title: '1. Kimlik Doğrulama (Auth & Cüzdan)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
    );
  }
}

