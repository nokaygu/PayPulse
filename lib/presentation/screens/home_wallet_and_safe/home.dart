import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/dev_console_cubit.dart';
import 'widgets/dev_active_user_section.dart';
import 'widgets/dev_auth_test_section.dart';
import 'widgets/dev_expense_and_pos_test_sections.dart';
import 'widgets/dev_notifications_test_section.dart';
import 'widgets/dev_transactions_test_section.dart';
import 'widgets/dev_transfer_test_section.dart';

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
                  DevActiveUserSection(
                    cubit: cubit,
                    email: currentUser.email,
                    uid: currentUser.uid,
                  ),
                  const SizedBox(height: 16),
                ],
                DevAuthTestSection(cubit: cubit, state: state),
                const SizedBox(height: 16),
                if (currentUser != null) ...[
                  DevTransferTestSection(cubit: cubit, state: state),
                  const SizedBox(height: 16),
                  DevNotificationsTestSection(
                    cubit: cubit,
                    userId: currentUser.uid,
                  ),
                  const SizedBox(height: 16),
                  DevTransactionsTestSection(
                    cubit: cubit,
                    userId: currentUser.uid,
                  ),
                  const SizedBox(height: 16),
                  DevExpenseTestSection(cubit: cubit, state: state),
                  const SizedBox(height: 16),
                  DevPosTestSection(cubit: cubit, state: state),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
