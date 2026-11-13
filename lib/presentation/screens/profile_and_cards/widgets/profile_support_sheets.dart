import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

Future<void> showSupportSheet(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (bottomCtx) => _SupportSheetBody(
      isDark: isDark,
      onLiveSupport: () {
        Navigator.of(bottomCtx).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Canlı destek oturumu başlatılıyor...')),
        );
      },
      onCallCenter: () {
        Navigator.of(bottomCtx).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Çağrı merkezi numarası panoya kopyalandı.'),
          ),
        );
      },
    ),
  );
}

class _SupportSheetBody extends StatelessWidget {
  final bool isDark;
  final VoidCallback onLiveSupport;
  final VoidCallback onCallCenter;

  const _SupportSheetBody({
    required this.isDark,
    required this.onLiveSupport,
    required this.onCallCenter,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : AppColors.darkNavy;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Yardım ve Canlı Destek',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'PayPulse uzman destek ekibi 7/24 yanınızda.',
            style: TextStyle(
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFD1FAE5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.support_agent_rounded,
                color: AppColors.primaryTeal,
              ),
            ),
            title: Text(
              'Canlı Desteğe Bağlan',
              style: TextStyle(color: textColor),
            ),
            subtitle: const Text('Ortalama yanıt süresi: < 1 dakika'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            onTap: onLiveSupport,
          ),
          Divider(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.phone_outlined, color: textColor),
            ),
            title: Text(
              'Müşteri Hizmetleri Çağrı Merkezi',
              style: TextStyle(color: textColor),
            ),
            subtitle: const Text('0850 555 00 00 (Ücretsiz)'),
            onTap: onCallCenter,
          ),
        ],
      ),
    );
  }
}

Future<void> showFaqSheet(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (bottomCtx) => DraggableScrollableSheet(
      initialChildSize: 0.65,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (_, scrollController) => _FaqSheetBody(
        isDark: isDark,
        scrollController: scrollController,
      ),
    ),
  );
}

class _FaqSheetBody extends StatelessWidget {
  final bool isDark;
  final ScrollController scrollController;

  const _FaqSheetBody({
    required this.isDark,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : AppColors.darkNavy;
    final answerColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    const items = [
      (
        'FAST para transferi ne kadar sürer?',
        'TCMB FAST sistemi sayesinde PayPulse ile yapılan tüm transferler 7/24 saniyeler içerisinde alıcının hesabına geçer.',
      ),
      (
        'Transfer ve işlem limitleri nelerdir?',
        'Seviye 2 onaylı bireysel hesaplar için aylık FAST transfer limiti ₺250.000 TL\'dir. Limit artırımı için Kimlik ve Adres belgesi yükleyebilirsiniz.',
      ),
      (
        'Kolay Adres (KOLAS) nedir, nasıl çalışır?',
        'IBAN yerine telefon numarası veya e-posta bilginizi eşleştirerek doğrudan para transferi alabilmenizi sağlayan TCMB altyapısıdır.',
      ),
    ];

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Sıkça Sorulan Sorular (SSS)',
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
        const SizedBox(height: 12),
        for (final entry in items)
          ExpansionTile(
            title: Text(
              entry.$1,
              style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(entry.$2, style: TextStyle(color: answerColor)),
              ),
            ],
          ),
      ],
    );
  }
}

