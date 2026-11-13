import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/financial_amount.dart';
import '../../../../domain/entities/invoice_entity.dart';

/// Tekil e-Fatura / e-Arşiv satır kartı ve PDF / FAST ödeme aksiyonları.
class InvoiceListCard extends StatelessWidget {
  final InvoiceEntity invoice;
  final bool isPaying;
  final VoidCallback onPdfDownload;
  final VoidCallback? onFastPay;

  const InvoiceListCard({
    super.key,
    required this.invoice,
    required this.isPaying,
    required this.onPdfDownload,
    required this.onFastPay,
  });

  @override
  Widget build(BuildContext context) {
    final isActionable = !invoice.isPaid && invoice.canPayWithFast;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isActionable
              ? const Color(0xFFF59E0B).withValues(alpha: 0.45)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InvoiceHeaderRow(invoice: invoice),
            const SizedBox(height: 12),
            _InvoiceStatusAndDateRow(invoice: invoice),
            const SizedBox(height: 12),
            _InvoiceActionsFooter(
              invoice: invoice,
              isPaying: isPaying,
              onPdfDownload: onPdfDownload,
              onFastPay: onFastPay,
            ),
          ],
        ),
      ),
    );
  }
}

class _InvoiceHeaderRow extends StatelessWidget {
  final InvoiceEntity invoice;

  const _InvoiceHeaderRow({required this.invoice});

  String _docTypeLabel(String type) {
    switch (type) {
      case 'e_smm':
        return 'E-SMM Makbuzu';
      case 'e_arsiv':
        return 'E-Arşiv Fatura';
      case 'e_fatura':
      default:
        return 'E-Fatura';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: invoice.isIncoming
                ? const Color(0xFFFEF3C7)
                : const Color(0xFFD1FAE5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            invoice.isIncoming
                ? Icons.receipt_long_rounded
                : Icons.outbox_rounded,
            color: invoice.isIncoming
                ? const Color(0xFFD97706)
                : AppColors.primaryTeal,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                invoice.counterpartyName,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkNavy,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                invoice.gibInvoiceNo,
                style: AppTextStyles.bodySmall.copyWith(
                  color: const Color(0xFF64748B),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _docTypeLabel(invoice.documentType),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: const Color(0xFF1D4ED8),
                    fontSize: 9.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              FinancialAmount.format(invoice.totalAmount),
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.darkNavy,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'KDV: ${FinancialAmount.format(invoice.vatAmount)}',
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFF64748B),
                fontSize: 10.5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InvoiceStatusAndDateRow extends StatelessWidget {
  final InvoiceEntity invoice;

  const _InvoiceStatusAndDateRow({required this.invoice});

  @override
  Widget build(BuildContext context) {
    final issueText =
        '${invoice.issueDate.day.toString().padLeft(2, '0')}.${invoice.issueDate.month.toString().padLeft(2, '0')}.${invoice.issueDate.year}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: invoice.isPaid
                      ? const Color(0xFFD1FAE5)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  invoice.isPaid ? 'Ödendi / Kapandı' : 'Ödeme Bekliyor',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: invoice.isPaid
                        ? const Color(0xFF065F46)
                        : const Color(0xFF92400E),
                    fontSize: 10,
                  ),
                ),
              ),
              if (invoice.badgeText != null && invoice.badgeText!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    invoice.badgeText!,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: const Color(0xFF475569),
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Text(
          issueText,
          style: AppTextStyles.bodySmall.copyWith(
            color: const Color(0xFF64748B),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _InvoiceActionsFooter extends StatelessWidget {
  final InvoiceEntity invoice;
  final bool isPaying;
  final VoidCallback onPdfDownload;
  final VoidCallback? onFastPay;

  const _InvoiceActionsFooter({
    required this.invoice,
    required this.isPaying,
    required this.onPdfDownload,
    required this.onFastPay,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: onPdfDownload,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.picture_as_pdf_outlined,
                  size: 14,
                  color: Color(0xFFDC2626),
                ),
                const SizedBox(width: 4),
                Text(
                  'PDF İndir',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.darkNavy,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (onFastPay != null)
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F766E),
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 36),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: isPaying ? null : onFastPay,
            icon: isPaying
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.bolt_rounded, size: 15),
            label: Text(
              isPaying ? 'Ödeniyor...' : 'Anında Öde (FAST)',
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          )
        else
          Text(
            invoice.isPaid ? 'ERP Defterine İşlendi' : 'GİB Onaylı',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.primaryTeal,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }
}

