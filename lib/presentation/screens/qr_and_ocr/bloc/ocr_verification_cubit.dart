import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/equatable.dart';
import '../../../../core/utils/financial_amount.dart';
import '../../../../domain/entities/expense_entity.dart';
import '../../../../domain/entities/user_entity.dart';
import '../../../../domain/repositories/i_expense_repository.dart';
import '../../../../domain/use_cases/submit_expense_use_case.dart';

class OcrExtractedData extends Equatable {
  final String merchantTitle;
  final int amountKurus;
  final int vatAmountKurus;
  final String category;
  final String receiptImagePath;
  final double confidence;
  final String accountingCode;

  const OcrExtractedData({
    required this.merchantTitle,
    required this.amountKurus,
    required this.vatAmountKurus,
    required this.category,
    this.receiptImagePath = '',
    this.confidence = 0.99,
    this.accountingCode = '770.01',
  });

  @override
  List<Object?> get props => [
    merchantTitle,
    amountKurus,
    vatAmountKurus,
    category,
    receiptImagePath,
    confidence,
    accountingCode,
  ];
}

class OcrVerificationState extends Equatable {
  static const List<String> categories = [
    'Ulaşım',
    'Yemek & Temsil',
    'Donanım & Ofis',
    'Yazılım & SaaS',
  ];

  static const List<int> vatRates = [20, 10, 1];

  final String selectedCategory;
  final int selectedVatRate;
  final String receiptImagePath;
  final double confidence;
  final bool isSubmitting;
  final bool isSubmitted;
  final String? errorMessage;

  const OcrVerificationState({
    this.selectedCategory = 'Ulaşım',
    this.selectedVatRate = 20,
    this.receiptImagePath = '',
    this.confidence = 0.99,
    this.isSubmitting = false,
    this.isSubmitted = false,
    this.errorMessage,
  });

  OcrVerificationState copyWith({
    String? selectedCategory,
    int? selectedVatRate,
    String? receiptImagePath,
    double? confidence,
    bool? isSubmitting,
    bool? isSubmitted,
    String? errorMessage,
    bool clearError = false,
  }) {
    return OcrVerificationState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedVatRate: selectedVatRate ?? this.selectedVatRate,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      confidence: confidence ?? this.confidence,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    selectedCategory,
    selectedVatRate,
    receiptImagePath,
    confidence,
    isSubmitting,
    isSubmitted,
    errorMessage,
  ];
}

class OcrVerificationCubit extends Cubit<OcrVerificationState> {
  final IExpenseRepository _expenseRepo;
  final SubmitExpenseUseCase _submitUseCase;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController merchantController;
  final TextEditingController amountController;
  final TextEditingController vatController;
  final TextEditingController accountingCodeController;
  final TextEditingController noteController;

  OcrVerificationCubit({
    required IExpenseRepository expenseRepository,
    SubmitExpenseUseCase? submitUseCase,
    OcrExtractedData? initialData,
  }) : _expenseRepo = expenseRepository,
       _submitUseCase = submitUseCase ?? SubmitExpenseUseCase(expenseRepository),
       merchantController = TextEditingController(
         text: initialData?.merchantTitle ?? 'Petrol Ofisi A.Ş.',
       ),
       amountController = TextEditingController(
         text: (initialData?.amountKurus ?? 142050) > 0
             ? FinancialAmount.input(initialData?.amountKurus ?? 142050)
             : '',
       ),
       vatController = TextEditingController(
         text: (initialData?.vatAmountKurus ?? 23675) > 0
             ? FinancialAmount.input(initialData?.vatAmountKurus ?? 23675)
             : '',
       ),
       accountingCodeController = TextEditingController(
         text: initialData?.accountingCode ?? '770.01',
       ),
       noteController = TextEditingController(),
       super(
         OcrVerificationState(
           selectedCategory:
               OcrVerificationState.categories.contains(initialData?.category)
               ? initialData!.category
               : OcrVerificationState.categories.first,
           receiptImagePath: initialData?.receiptImagePath ?? '',
           confidence: initialData?.confidence ?? 0.99,
         ),
       );

  void selectCategory(String category) {
    emit(state.copyWith(selectedCategory: category));
  }

  void selectVatRate(int rate) {
    emit(state.copyWith(selectedVatRate: rate));
    recalculateVat();
  }

  void onAmountChanged(String _) {
    recalculateVat();
  }

  void recalculateVat() {
    final totalKurus = FinancialAmount.parse(amountController.text) ?? 0;
    if (totalKurus <= 0) {
      vatController.clear();
      return;
    }
    final netKurus = (totalKurus / (1 + (state.selectedVatRate / 100.0))).round();
    final vatKurus = totalKurus - netKurus;
    vatController.text = FinancialAmount.input(vatKurus);
  }

  Future<void> submitExpense({required UserEntity? actor}) async {
    if (state.isSubmitting) return;
    if (!(formKey.currentState?.validate() ?? false)) return;

    final amountKurus = FinancialAmount.parse(amountController.text) ?? 0;
    final vatKurus = FinancialAmount.parse(vatController.text) ?? 0;
    final expenseId = 'exp_${DateTime.now().millisecondsSinceEpoch}';

    emit(state.copyWith(isSubmitting: true, clearError: true));

    try {
      String resolvedReceiptUrl = state.receiptImagePath.trim();
      if (resolvedReceiptUrl.isNotEmpty &&
          !resolvedReceiptUrl.startsWith('http')) {
        resolvedReceiptUrl = await _expenseRepo.uploadReceiptImage(
          localFilePath: resolvedReceiptUrl,
          expenseId: expenseId,
        );
      }

      final expense = ExpenseEntity(
        expenseId: expenseId,
        employeeId: actor?.uid ?? AppStrings.demoEmployeeUid,
        employeeName: actor?.name ?? 'Kurumsal Personel',
        merchantTitle: merchantController.text.trim(),
        category: state.selectedCategory,
        companyId: actor?.companyId ?? AppStrings.defaultCompanyId,
        amount: amountKurus,
        vatAmount: vatKurus,
        receiptImageUrl: resolvedReceiptUrl,
        status: 'pending',
        date: DateTime.now(),
        accountingCode: accountingCodeController.text.trim().isEmpty
            ? '770.01'
            : accountingCodeController.text.trim(),
      );

      await _submitUseCase.call(expense: expense, actor: actor);
      emit(state.copyWith(isSubmitting: false, isSubmitted: true));
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  @override
  Future<void> close() {
    merchantController.dispose();
    amountController.dispose();
    vatController.dispose();
    accountingCodeController.dispose();
    noteController.dispose();
    return super.close();
  }
}

