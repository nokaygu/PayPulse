import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

Future<void> showLegalContractsSheet(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (bottomCtx) => _LegalContractsSheetBody(isDark: isDark),
  );
}

class _LegalContractsSheetBody extends StatelessWidget {
  final bool isDark;

  const _LegalContractsSheetBody({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : AppColors.darkNavy;
    final subColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final dividerColor =
        isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF475569)
                      : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Sözleşmeler ve Yasal Metinler',
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Detaylarını incelemek istediğiniz yasal sözleşmeye dokunun.',
              style: TextStyle(color: subColor, fontSize: 12),
            ),
            const SizedBox(height: 14),
            _ContractTile(
              icon: Icons.description_outlined,
              iconColor: AppColors.primaryTeal,
              title: 'Kullanıcı Çerçeve Sözleşmesi',
              subtitle: 'Elektronik para ve ödeme hizmetleri koşulları',
              textColor: textColor,
              onTap: () => showDocumentDetailSheet(
                context,
                title: 'Kullanıcı Çerçeve Sözleşmesi',
                lastUpdated: '01.01.2025 (v2.4)',
                sections: _frameworkContractSections,
              ),
            ),
            Divider(color: dividerColor),
            _ContractTile(
              icon: Icons.privacy_tip_outlined,
              iconColor: const Color(0xFF3B82F6),
              title: 'KVKK Aydınlatma ve Açık Rıza Metni',
              subtitle: 'Kişisel verilerin işlenmesine ilişkin esaslar',
              textColor: textColor,
              onTap: () => showDocumentDetailSheet(
                context,
                title: 'KVKK Aydınlatma ve Açık Rıza Metni',
                lastUpdated: '15.01.2025 (v1.8)',
                sections: _kvkkSections,
              ),
            ),
            Divider(color: dividerColor),
            _ContractTile(
              icon: Icons.shield_outlined,
              iconColor: AppColors.primaryGreen,
              title: 'Çerez ve Gizlilik Politikası',
              subtitle: 'Mobil uygulama veri güvenliği ve SSL standartları',
              textColor: textColor,
              onTap: () => showDocumentDetailSheet(
                context,
                title: 'Çerez ve Gizlilik Politikası',
                lastUpdated: '10.02.2025 (v3.1)',
                sections: _privacySections,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContractTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Color textColor;
  final VoidCallback onTap;

  const _ContractTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        title,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
      onTap: onTap,
    );
  }
}

Future<void> showDocumentDetailSheet(
  BuildContext context, {
  required String title,
  required String lastUpdated,
  required List<Map<String, String>> sections,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (docCtx) => DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, scrollController) => _DocumentDetailSheetBody(
        title: title,
        lastUpdated: lastUpdated,
        sections: sections,
        isDark: isDark,
        scrollController: scrollController,
        onClose: () => Navigator.of(docCtx).pop(),
      ),
    ),
  );
}

class _DocumentDetailSheetBody extends StatelessWidget {
  final String title;
  final String lastUpdated;
  final List<Map<String, String>> sections;
  final bool isDark;
  final ScrollController scrollController;
  final VoidCallback onClose;

  const _DocumentDetailSheetBody({
    required this.title,
    required this.lastUpdated,
    required this.sections,
    required this.isDark,
    required this.scrollController,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : AppColors.darkNavy;
    final subColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 8),
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.headlineSmall.copyWith(
                        fontWeight: FontWeight.w800,
                        color: textColor,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Son Güncelleme: $lastUpdated',
                      style: TextStyle(color: subColor, fontSize: 11),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  color: isDark ? Colors.white : const Color(0xFF64748B),
                ),
                onPressed: onClose,
              ),
            ],
          ),
        ),
        Divider(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
        ),
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            itemCount: sections.length,
            itemBuilder: (ctx, idx) {
              final sec = sections[idx];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sec['title'] ?? '',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryTeal,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      sec['body'] ?? '',
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.5,
                        color: isDark
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
            border: Border(
              top: BorderSide(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
              ),
            ),
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryTeal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onClose,
              child: const Text(
                'Okudum ve Anladım',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> showComplianceSheet(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (bottomCtx) => _ComplianceSheetBody(isDark: isDark),
  );
}

class _ComplianceSheetBody extends StatelessWidget {
  final bool isDark;

  const _ComplianceSheetBody({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : AppColors.darkNavy;
    final subColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Güvenlik ve Lisans Bilgileri',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          _ComplianceItem(
            icon: Icons.verified_rounded,
            title: 'TCMB Elektronik Para Lisansı',
            desc: '6493 sayılı Kanun kapsamında Türkiye Cumhuriyet Merkez Bankası tarafından yetkilendirilmiştir.',
            textColor: textColor,
            subColor: subColor,
          ),
          _ComplianceItem(
            icon: Icons.shield_rounded,
            title: 'BDDK Mevzuat Uyumu',
            desc: 'Banka ve finansal kuruluşlar bilgi güvenliği standartları ile tam uyumludur.',
            textColor: textColor,
            subColor: subColor,
          ),
          _ComplianceItem(
            icon: Icons.lock_outline_rounded,
            title: 'PCI-DSS Seviye 1 & 256-bit SSL',
            desc: 'Uluslararası ödeme sistemleri en yüksek güvenlik sertifikasyonuna sahiptir.',
            textColor: textColor,
            subColor: subColor,
          ),
        ],
      ),
    );
  }
}

class _ComplianceItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final Color textColor;
  final Color subColor;

  const _ComplianceItem({
    required this.icon,
    required this.title,
    required this.desc,
    required this.textColor,
    required this.subColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primaryTeal, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w700, color: textColor),
                ),
                const SizedBox(height: 2),
                Text(desc, style: TextStyle(color: subColor, fontSize: 11.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const List<Map<String, String>> _frameworkContractSections = [
  {
    'title': '1. Taraflar ve Kapsam',
    'body':
        'İşbu Çerçeve Sözleşme, 6493 sayılı Kanun kapsamında faaliyet gösteren PayPulse Ödeme ve Elektronik Para Hizmetleri A.Ş. ile PayPulse mobil uygulamasını kullanan hesap sahibi ("Kullanıcı") arasında akdedilmiştir. Sözleşme, cüzdan oluşturma, FAST transferleri, ön ödemeli kart ihracı ve tahsilat hizmetlerinin yasal sınırlarını düzenler.',
  },
  {
    'title': '2. Hesap Güvenliği ve Doğrulama',
    'body':
        'Kullanıcı, hesap açılışında beyan ettiği T.C. Kimlik Numarası, telefon numarası ve yerleşim yeri bilgilerinin güncel ve doğru olduğunu taahhüt eder. Şifre, cüzdan PIN kodu ve tek kullanımlık SMS onay kodlarının gizliliği tamamen Kullanıcı sorumluluğundadır. Yetkisiz bir işlem şüphesinde derhal 7/24 Çağrı Merkezine bildirim yapılmalıdır.',
  },
  {
    'title': '3. FAST ve Fon Aktarımı Kuralları',
    'body':
        'TCMB FAST kuralları gereğince yapılan transferler geri dönülemez nitelikte olup alıcı hesabına saniyeler içinde ulaşır. Yanlış IBAN veya KOLAS adresine yapılan transferlerde iade talepleri alıcı bankanın onayına tabidir. Seviye 2 onaylı bireysel hesaplar için aylık FAST transfer tavanı ₺250.000 TL\'dir.',
  },
  {
    'title': '4. Ücretler ve Masraflar',
    'body':
        'PayPulse bireysel kullanıcılarından standart FAST transferleri, hesap işletim ücreti veya bakiye sorgulama için hiçbir masraf alınmaz. Sanal kart oluşturma ilk 3 kart için tamamen ücretsizdir. Kurumsal POS komisyonları ise B2B sözleşmesinde ayrıca belirlenir.',
  },
  {
    'title': '5. Fesih ve Hesap Kapatma',
    'body':
        'Kullanıcı, dilediği an hiçbir gerekçe göstermeksizin ve cezai şart ödemeksizin hesabını kapatma hakkına sahiptir. Hesapta kalan bakiye, kullanıcının adına kayıtlı teyitli IBAN adresine 1 iş günü içinde eksiksiz aktarılır.',
  },
];

const List<Map<String, String>> _kvkkSections = [
  {
    'title': '1. Veri Sorumlusu',
    'body':
        '6698 sayılı Kişisel Verilerin Korunması Kanunu ("KVKK") uyarınca PayPulse A.Ş., veri sorumlusu sıfatıyla kişisel verilerinizi mevzuata uygun şekilde toplamakta, saklamakta ve işlemektedir.',
  },
  {
    'title': '2. İşlenen Kişisel Veri Kategorileri',
    'body':
        'Kimlik Bilgileri (Ad, Soyad, TCKN, Doğum Tarihi), İletişim Bilgileri (Telefon, E-posta, İkametgah Adresi), Finansal Veriler (FAST IBAN, kart numaraları, hesap hareketleri, işlem tutarları) ve Cihaz Güvenlik Bilgileri (IP adresi, cihaz UUID, işletim sistemi versiyonu).',
  },
  {
    'title': '3. Veri İşleme Amaçları ve Hukuki Sebepler',
    'body':
        'Kişisel verileriniz; finansal işlemlerin güvenle ifa edilmesi, MASAK ve TCMB yasal yükümlülüklerinin yerine getirilmesi, kimlik teyidi (KYC) yapılması, dolandırıcılığın önlenmesi ve 7/24 müşteri desteği sağlanması amacıyla işlenir.',
  },
  {
    'title': '4. Verilerin Aktarıldığı Taraflar',
    'body':
        'Toplanan veriler yalnızca yasal zorunluluklar çerçevesinde Türkiye Cumhuriyet Merkez Bankası (TCMB), MASAK, Bankalararası Kart Merkezi (BKM) ve yetkili yargı mercileri ile paylaşılır. Verileriniz hiçbir koşulda ticari amaçla üçüncü kişilere satılmaz.',
  },
  {
    'title': '5. KVKK Kapsamındaki Haklarınız',
    'body':
        'KVKK\'nın 11. maddesi uyarınca; kişisel verilerinizin işlenip işlenmediğini öğrenme, yanlış işlenen verilerin düzeltilmesini talep etme ve verilerinizin silinmesini isteme hakkına sahipsiniz. Başvurularınızı kvkk@paypulse.me adresine iletebilirsiniz.',
  },
];

const List<Map<String, String>> _privacySections = [
  {
    'title': '1. Güvenlik Standartları',
    'body':
        'PayPulse mobil uygulaması üzerinden iletilen tüm hassas finansal veriler 256-bit SSL şifreleme ve PCI-DSS Seviye 1 sertifikalı sunucularda korunmaktadır.',
  },
  {
    'title': '2. Biyometrik Verilerin Korunması',
    'body':
        'Face ID ve Parmak İzi ile giriş özelliği kullanılırken biyometrik verileriniz hiçbir zaman sunucularımıza gönderilmez. Doğrulama tamamen cihazınızın kendi güvenli donanım çipinde (Secure Enclave) yerel olarak gerçekleştirilir.',
  },
  {
    'title': '3. Mobil Oturum ve Çerezler',
    'body':
        'Uygulamada oturum güvenliğini sağlamak amacıyla güvenli token teknolojisi kullanılır. Arka planda 5 dakika boyunca hareketsiz kalan oturumlar otomatik olarak kilitlenir.',
  },
  {
    'title': '4. Gizlilik İletişim Hattı',
    'body':
        'Veri güvenliği ve gizlilik politikamıza ilişkin tüm soru ve önerileriniz için gizlilik@paypulse.me üzerinden Veri Koruma Görevlimizle irtibata geçebilirsiniz.',
  },
];

