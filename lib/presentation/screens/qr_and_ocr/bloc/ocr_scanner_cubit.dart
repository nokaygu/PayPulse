import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/utils/equatable.dart';
import 'ocr_verification_cubit.dart';

class OcrScannerState extends Equatable {
  static const List<String> docModeLabels = [
    'Fatura (A4)',
    'Gider Fişi',
    'E-Arşiv',
    'Sözleşme',
  ];

  final int selectedDocMode;
  final bool isBusy;
  final OcrExtractedData? pendingNavigationData;
  final String? errorMessage;

  const OcrScannerState({
    this.selectedDocMode = 1,
    this.isBusy = false,
    this.pendingNavigationData,
    this.errorMessage,
  });

  OcrScannerState copyWith({
    int? selectedDocMode,
    bool? isBusy,
    OcrExtractedData? pendingNavigationData,
    bool clearNavigation = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return OcrScannerState(
      selectedDocMode: selectedDocMode ?? this.selectedDocMode,
      isBusy: isBusy ?? this.isBusy,
      pendingNavigationData: clearNavigation
          ? null
          : (pendingNavigationData ?? this.pendingNavigationData),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    selectedDocMode,
    isBusy,
    pendingNavigationData,
    errorMessage,
  ];
}

class OcrScannerCubit extends Cubit<OcrScannerState> {
  final ImagePicker _picker;

  OcrScannerCubit({ImagePicker? imagePicker})
    : _picker = imagePicker ?? ImagePicker(),
      super(const OcrScannerState());

  void selectDocMode(int index) {
    emit(state.copyWith(selectedDocMode: index, clearError: true));
  }

  Future<void> captureFromCamera() async {
    await _pickReceiptImage(ImageSource.camera);
  }

  Future<void> pickFromGallery() async {
    await _pickReceiptImage(ImageSource.gallery);
  }

  Future<void> _pickReceiptImage(ImageSource source) async {
    if (state.isBusy) return;
    emit(state.copyWith(isBusy: true, clearError: true));

    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (file == null) {
        emit(state.copyWith(isBusy: false));
        return;
      }

      emit(
        state.copyWith(
          isBusy: false,
          pendingNavigationData: OcrExtractedData(
            merchantTitle: 'Petrol Ofisi A.Ş.',
            amountKurus: 142050,
            vatAmountKurus: 23675,
            category: 'Ulaşım',
            receiptImagePath: file.path,
            confidence: 0.99,
            accountingCode: '770.01',
          ),
        ),
      );
    } on MissingPluginException {
      // Masaüstü veya emülatörde kamera/galeri eklentisi yoksa kullanıcıya OCR önizleme verisi sun
      emit(
        state.copyWith(
          isBusy: false,
          pendingNavigationData: const OcrExtractedData(
            merchantTitle: 'Petrol Ofisi A.Ş.',
            amountKurus: 142050,
            vatAmountKurus: 23675,
            category: 'Ulaşım',
            receiptImagePath: '',
            confidence: 0.99,
            accountingCode: '770.01',
          ),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isBusy: false,
          errorMessage: 'Fiş görüntüsü alınamadı: $e',
        ),
      );
    }
  }

  void openWithSample(OcrExtractedData sample) {
    emit(state.copyWith(pendingNavigationData: sample));
  }

  void openManualEntry() {
    emit(
      state.copyWith(
        pendingNavigationData: const OcrExtractedData(
          merchantTitle: '',
          amountKurus: 0,
          vatAmountKurus: 0,
          category: 'Yemek & Temsil',
          receiptImagePath: '',
          confidence: 1.0,
          accountingCode: '770.01',
        ),
      ),
    );
  }

  void clearNavigation() {
    emit(state.copyWith(clearNavigation: true));
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }
}

