import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../widgets/role_switch_app_bar.dart';
import 'bloc/ocr_scanner_cubit.dart';
import 'bloc/ocr_verification_cubit.dart';

/// Fatura & Fiş Tarama (AI-OCR) Ekranı (Stateless + OcrScannerCubit + ImagePicker)
class OcrCameraScannerScreen extends StatelessWidget {
  const OcrCameraScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OcrScannerCubit>(
      create: (_) => OcrScannerCubit(),
      child: const _OcrCameraScannerBody(),
    );
  }
}

class _OcrCameraScannerBody extends StatelessWidget {
  const _OcrCameraScannerBody();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OcrScannerCubit>();

    return MultiBlocListener(
      listeners: [
        BlocListener<OcrScannerCubit, OcrScannerState>(
          listenWhen: (prev, curr) =>
              curr.pendingNavigationData != null &&
              prev.pendingNavigationData != curr.pendingNavigationData,
          listener: (ctx, state) {
            final data = state.pendingNavigationData;
            if (data == null) return;
            ctx.read<OcrScannerCubit>().clearNavigation();
            ctx.push(AppRoutes.businessOcrVerify, extra: data);
          },
        ),
        BlocListener<OcrScannerCubit, OcrScannerState>(
          listenWhen: (prev, curr) =>
              curr.errorMessage != null &&
              prev.errorMessage != curr.errorMessage,
          listener: (ctx, state) {
            final msg = state.errorMessage;
            if (msg == null) return;
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text(msg),
                backgroundColor: AppColors.expenseRed,
              ),
            );
            ctx.read<OcrScannerCubit>().clearError();
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: const RoleSwitchAppBar(isBusinessMode: true),
        body: BlocBuilder<OcrScannerCubit, OcrScannerState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Başlık Satırı
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI-OCR BELGE TARAYICI',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: const Color(0xFF64748B),
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Fatura & Fiş Tara',
                            style: AppTextStyles.headlineMedium.copyWith(
                              color: AppColors.darkNavy,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () => context.pop(),
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE2E8F0),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: AppColors.darkNavy,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Belge Tipi Sekmeleri
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0).withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: List.generate(
                        OcrScannerState.docModeLabels.length,
                        (index) => _DocModeTab(
                          label: OcrScannerState.docModeLabels[index],
                          selected: state.selectedDocMode == index,
                          onTap: () => cubit.selectDocMode(index),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Kamera Vizörü ve AI-OCR Algılama Önizleme Kartı
                  _OcrViewfinderCard(
                    docModeLabel:
                        OcrScannerState.docModeLabels[state.selectedDocMode],
                  ),
                  const SizedBox(height: 20),

                  // Deklanşör, Galeri ve Manuel Giriş Butonları
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ActionOption(
                        icon: Icons.photo_library_outlined,
                        label: 'Galeriden Seç',
                        onTap: state.isBusy
                            ? null
                            : () => _showGalleryOrSampleSheet(context, cubit),
                      ),
                      GestureDetector(
                        onTap: state.isBusy ? null : cubit.captureFromCamera,
                        child: Container(
                          width: 74,
                          height: 74,
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF99F6E4),
                              width: 4,
                            ),
                          ),
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF10B981), Color(0xFF0D9488)],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: state.isBusy
                                ? const Padding(
                                    padding: EdgeInsets.all(18),
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Icon(
                                    Icons.document_scanner_outlined,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                          ),
                        ),
                      ),
                      _ActionOption(
                        icon: Icons.edit_note_rounded,
                        label: 'Manuel Giriş',
                        onTap: state.isBusy ? null : cubit.openManualEntry,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Akıllı Fiş İpucu Kartı
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFFD1FAE5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            color: AppColors.primaryTeal,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Doğrudan Doğrulama ve Muhasebeleştirme',
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: AppColors.darkNavy,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Seçilen veya çekilen fiş görseli bir sonraki adımda doğrulanıp Firebase Storage üzerinden güvenle arşivlenir.',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: const Color(0xFF475569),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showGalleryOrSampleSheet(BuildContext context, OcrScannerCubit cubit) {
    const samples = [
      OcrExtractedData(
        merchantTitle: 'Petrol Ofisi A.Ş.',
        amountKurus: 142050,
        vatAmountKurus: 23675,
        category: 'Ulaşım',
        confidence: 0.99,
      ),
      OcrExtractedData(
        merchantTitle: 'Midpoint Restoran',
        amountKurus: 198050,
        vatAmountKurus: 18005,
        category: 'Yemek & Temsil',
        confidence: 0.97,
      ),
      OcrExtractedData(
        merchantTitle: 'Apple Store Türkiye',
        amountKurus: 485000,
        vatAmountKurus: 80833,
        category: 'Donanım & Ofis',
        confidence: 0.98,
      ),
    ];

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fiş Görseli Seç',
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkNavy,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    cubit.pickFromGallery();
                  },
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Cihaz Galerisinden Seç'),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Hızlı Test / Demo Örnek Fişler',
                style: AppTextStyles.labelSmall.copyWith(
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 6),
              ...samples.map(
                (s) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.receipt_long_rounded,
                    color: AppColors.primaryTeal,
                  ),
                  title: Text(s.merchantTitle),
                  subtitle: Text(s.category),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () {
                    Navigator.pop(ctx);
                    cubit.openWithSample(s);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocModeTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DocModeTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: selected ? AppColors.darkNavy : const Color(0xFF64748B),
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              fontSize: 11,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

class _OcrViewfinderCard extends StatelessWidget {
  final String docModeLabel;

  const _OcrViewfinderCard({required this.docModeLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.heroCardGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryTeal.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '● AI-OCR Hazır ($docModeLabel)',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: const Color(0xFF5EEAD4),
                    fontSize: 10.5,
                  ),
                ),
              ),
              const Icon(Icons.qr_code_scanner, color: Colors.white70, size: 20),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.16),
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.receipt_long_rounded,
                  size: 56,
                  color: Color(0xFF5EEAD4),
                ),
                const SizedBox(height: 12),
                Text(
                  'Fiş veya faturayı kadraja yerleştirin',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Kamera çekimi, galeri yüklemesi veya manuel fiş girişi sonrası doğrulama adımına yönlendirilirsiniz.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF94A3B8),
                    fontSize: 11.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'VKN, Tarih, Toplam Tutar ve KDV Matrahı Otomatik Ayrıştırılır',
            style: AppTextStyles.labelSmall.copyWith(
              color: const Color(0xFF5EEAD4),
              fontSize: 10.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ActionOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ActionOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0).withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.darkNavy),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: const Color(0xFF475569),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
