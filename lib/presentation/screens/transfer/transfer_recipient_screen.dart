import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../widgets/role_switch_app_bar.dart';

/// FAST Para Transferi Adım 1/4: Alıcı ve IBAN Seçimi Ekranı
class TransferRecipientScreen extends StatelessWidget {
  const TransferRecipientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const RoleSwitchAppBar(
        isBusinessMode: false,
        showBackButton: true,
        customTitle: '7/24 FAST Para Gönder',
        customSubtitle: 'Adım 1/4 • Alıcı veya Kolay Adres Seçin',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'KAYITLI ALICILAR',
              style: AppTextStyles.labelSmall.copyWith(
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFD1FAE5),
                  child: Text('ZK'),
                ),
                title: const Text(
                  'Zeynep Kaya',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: const Text(
                  'Garanti BBVA • TR34 0006 2000 •••• 6789 01',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push(AppRoutes.fastTransfer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
