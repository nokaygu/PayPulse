import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../widgets/role_switch_app_bar.dart';
import 'bloc/ocr_scanner_cubit.dart';
import 'widgets/ocr_doc_mode_selector.dart';
import 'widgets/ocr_sample_picker_sheet.dart';
import 'widgets/ocr_scanner_actions_bar.dart';
import 'widgets/ocr_viewfinder_card.dart';

/// Fatura & Fiş Tarama (AI-OCR) Ekranı (Stateless + OcrScannerCubit + ImagePicker).
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
              SnackBar(content: Text(msg), backgroundColor: AppColors.expenseRed),
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
                  const _ScannerHeader(),
                  const SizedBox(height: 14),
                  OcrDocModeSelector(
                    labels: OcrScannerState.docModeLabels,
                    selectedIndex: state.selectedDocMode,
                    onSelect: cubit.selectDocMode,
                  ),
                  const SizedBox(height: 16),
                  OcrViewfinderCard(
                    docModeLabel:
                        OcrScannerState.docModeLabels[state.selectedDocMode],
                  ),
                  const SizedBox(height: 20),
                  OcrScannerActionsBar(
                    isBusy: state.isBusy,
                    onOpenGalleryOrSamples: () =>
                        OcrSamplePickerSheet.show(context, cubit),
                    onCaptureCamera: cubit.captureFromCamera,
                    onManualEntry: cubit.openManualEntry,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ScannerHeader extends StatelessWidget {
  const _ScannerHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}
