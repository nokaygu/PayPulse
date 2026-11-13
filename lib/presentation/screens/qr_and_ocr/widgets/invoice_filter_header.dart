import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/e_invoice_cubit.dart';

/// E-Fatura ekranı başlık, GİB canlı rozeti, arama kutusu ve durum filtre çubuğu.
class InvoiceScreenTopBar extends StatelessWidget {
  final VoidCallback onSync;

  const InvoiceScreenTopBar({super.key, required this.onSync});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      'E-Fatura & E-Arşiv',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppColors.darkNavy,
                        fontWeight: FontWeight.w800,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const _GibLiveBadge(),
                ],
              ),
            ),
            IconButton(
              onPressed: onSync,
              icon: const Icon(
                Icons.sync_rounded,
                size: 20,
                color: AppColors.primaryTeal,
              ),
              tooltip: 'GİB Senkronize Et',
            ),
          ],
        ),
        Text(
          'Gelir İdaresi Başkanlığı resmi e-Fatura entegrasyonu',
          style: AppTextStyles.bodySmall.copyWith(
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}

class _GibLiveBadge extends StatelessWidget {
  const _GibLiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFD1FAE5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.primaryGreen,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'GİB Canlı',
            style: AppTextStyles.labelSmall.copyWith(
              color: const Color(0xFF065F46),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

/// Fatura arama kutusu, belge türü filtre butonu ve durum çip şeridi.
class InvoiceFilterHeader extends StatelessWidget {
  final EInvoiceCubit cubit;
  final EInvoiceState state;
  final VoidCallback onOpenDocTypeSheet;

  const InvoiceFilterHeader({
    super.key,
    required this.cubit,
    required this.state,
    required this.onOpenDocTypeSheet,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SearchAndFilterRow(
          cubit: cubit,
          state: state,
          onOpenDocTypeSheet: onOpenDocTypeSheet,
        ),
        const SizedBox(height: 12),
        _StatusFilterStrip(cubit: cubit, activeFilter: state.statusFilter),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              state.isIncomingTab
                  ? 'Gelen Fatura Kayıtları'
                  : 'Giden Fatura Kayıtları',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.darkNavy,
              ),
            ),
            Text(
              '${state.filteredInvoices.length} Kayıt',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primaryTeal,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SearchAndFilterRow extends StatelessWidget {
  final EInvoiceCubit cubit;
  final EInvoiceState state;
  final VoidCallback onOpenDocTypeSheet;

  const _SearchAndFilterRow({
    required this.cubit,
    required this.state,
    required this.onOpenDocTypeSheet,
  });

  @override
  Widget build(BuildContext context) {
    final hasDocFilter = state.selectedDocType != 'Tümü';
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: cubit.searchController,
              onChanged: cubit.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Unvan, GİB No veya tutar ara...',
                hintStyle: AppTextStyles.bodySmall.copyWith(
                  color: const Color(0xFF94A3B8),
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF64748B),
                  size: 20,
                ),
                suffixIcon: state.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: Color(0xFF64748B),
                        ),
                        onPressed: cubit.resetFilters,
                      )
                    : null,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: onOpenDocTypeSheet,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: hasDocFilter ? const Color(0xFFD1FAE5) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: hasDocFilter
                    ? AppColors.primaryTeal
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Icon(
              Icons.tune_rounded,
              size: 20,
              color: hasDocFilter
                  ? const Color(0xFF0F766E)
                  : AppColors.darkNavy,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusFilterStrip extends StatelessWidget {
  final EInvoiceCubit cubit;
  final InvoiceStatusFilter activeFilter;

  const _StatusFilterStrip({required this.cubit, required this.activeFilter});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: InvoiceStatusFilter.values.map((filter) {
          final selected = activeFilter == filter;
          final isWarning = filter == InvoiceStatusFilter.pending;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => cubit.setStatusFilter(filter),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: selected ? AppColors.darkNavy : Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: selected
                        ? AppColors.darkNavy
                        : isWarning
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Text(
                  isWarning ? '● ${filter.label}' : filter.label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: selected
                        ? Colors.white
                        : isWarning
                        ? const Color(0xFFB45309)
                        : const Color(0xFF475569),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

