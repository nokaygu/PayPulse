import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/e_invoice_cubit.dart';

/// E-Fatura belge türü filtre alt sayfası (`StatelessWidget`).
class InvoiceDocTypeFilterSheet extends StatelessWidget {
  final EInvoiceCubit cubit;
  final String selectedDocType;

  const InvoiceDocTypeFilterSheet({
    super.key,
    required this.cubit,
    required this.selectedDocType,
  });

  static const _options = <MapEntry<String, String>>[
    MapEntry('Tümü', 'Tüm Belge Türleri'),
    MapEntry('e_fatura', 'E-Fatura'),
    MapEntry('e_arsiv', 'E-Arşiv'),
    MapEntry('e_smm', 'E-SMM (Serbest Meslek Makbuzu)'),
  ];

  static Future<void> show(
    BuildContext context, {
    required EInvoiceCubit cubit,
    required String selectedDocType,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => InvoiceDocTypeFilterSheet(
        cubit: cubit,
        selectedDocType: selectedDocType,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Belge Türüne Göre Filtrele',
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.darkNavy,
              ),
            ),
            const SizedBox(height: 12),
            ..._options.map((opt) {
              final selected = selectedDocType == opt.key;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: selected
                      ? AppColors.primaryTeal
                      : const Color(0xFF94A3B8),
                ),
                title: Text(opt.value),
                onTap: () {
                  cubit.setDocTypeFilter(opt.key);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

