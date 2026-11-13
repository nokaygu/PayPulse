import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/financial_amount.dart';
import '../../../../core/validators/financial_validators.dart';
import '../../../../domain/entities/invoice_entity.dart';
import '../bloc/e_invoice_cubit.dart';

/// TCMB FAST ile tek tık e-Fatura ödeme onay diyalogu (`StatelessWidget`).
class InvoiceFastPaymentDialog extends StatelessWidget {
  final EInvoiceCubit cubit;
  final InvoiceEntity invoice;
  final String payerUserId;
  final String defaultIban;

  const InvoiceFastPaymentDialog({
    super.key,
    required this.cubit,
    required this.invoice,
    required this.payerUserId,
    required this.defaultIban,
  });

  static Future<void> show({
    required BuildContext context,
    required EInvoiceCubit cubit,
    required InvoiceEntity invoice,
    required String payerUserId,
    required String defaultIban,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => InvoiceFastPaymentDialog(
        cubit: cubit,
        invoice: invoice,
        payerUserId: payerUserId,
        defaultIban: defaultIban,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    var targetIban = defaultIban;

    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.bolt_rounded,
              color: AppColors.primaryGreen,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TCMB FAST Fatura Ödemesi',
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkNavy,
                  ),
                ),
                Text(
                  invoice.counterpartyName,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF64748B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ÖDENECEK TUTAR (${invoice.gibInvoiceNo})',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: const Color(0xFF64748B),
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    FinancialAmount.format(invoice.totalAmount),
                    style: AppTextStyles.numericBalance.copyWith(
                      color: AppColors.darkNavy,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: defaultIban,
              onChanged: (value) => targetIban = value,
              decoration: const InputDecoration(
                labelText: 'Tedarikçi IBAN Numarası',
                hintText: 'TR...',
              ),
              validator: FinancialValidators.iban,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Vazgeç'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: Colors.white,
            minimumSize: const Size(0, 44),
          ),
          onPressed: () {
            if (!(formKey.currentState?.validate() ?? false)) return;
            final iban = targetIban.trim();
            Navigator.pop(context);
            cubit.payInvoiceFast(
              invoice: invoice,
              payerUserId: payerUserId,
              targetIban: iban,
            );
          },
          child: const Text('Onayla ve Öde'),
        ),
      ],
    );
  }
}

