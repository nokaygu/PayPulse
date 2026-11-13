import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_mode.dart';
import '../../../core/errors/auth_error_messages.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/datasources/remote/firebase_auth_datasource.dart';
import 'bloc/auth_bloc.dart';
import 'bloc/auth_event.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _taxNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isB2BAccount = false;
  bool _obscurePassword = true;
  bool _kvkkAccepted = false;
  bool _isLoading = false;

  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyNameController.dispose();
    _taxNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: AppTextStyles.bodyMedium.copyWith(
        color: const Color(0xFF94A3B8),
      ),
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(prefixIcon, color: const Color(0xFF64748B), size: 20),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primaryTeal, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.expenseRed),
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_kvkkAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Devam etmek için KVKK ve Kullanıcı Sözleşmesini onaylayın.',
          ),
          backgroundColor: AppColors.expenseRed,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    if (AppMode.isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 250));
      if (!mounted) return;
      final role = _isB2BAccount ? 'admin' : 'b2c';
      context.read<AuthBloc>().add(AuthDemoLoginRequested(role));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isB2BAccount
                ? 'B2B Kurumsal Demo Hesabı başarıyla oluşturuldu!'
                : 'B2C Bireysel Demo Cüzdanı başarıyla oluşturuldu!',
          ),
          backgroundColor: AppColors.incomeGreen,
        ),
      );
      context.go(role == 'admin' ? AppRoutes.businessOverview : AppRoutes.home);
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final name = _fullNameController.text.trim();
      final companyName = _companyNameController.text.trim();

      // Firebase Authentication ve Firestore kullanıcı profili + 0 bakiyeli cüzdan oluşturur
      await FirebaseAuthDatasource().register(
        email,
        password,
        name: name.isNotEmpty ? name : 'PayPulse Kullanıcısı',
        role: _isB2BAccount ? 'admin' : 'b2c',
        companyId: _isB2BAccount
            ? (companyName.isNotEmpty
                ? 'comp_${companyName.toLowerCase().replaceAll(' ', '_')}'
                : 'comp_${DateTime.now().millisecondsSinceEpoch}')
            : null,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isB2BAccount
                ? 'B2B Kurumsal hesabınız başarıyla oluşturuldu!'
                : 'B2C Bireysel Cüzdan hesabınız başarıyla oluşturuldu!',
          ),
          backgroundColor: AppColors.incomeGreen,
        ),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final msg = AuthErrorMessages.fromCode(e.code);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: AppColors.expenseRed,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kayıt başarısız: $e'),
          backgroundColor: AppColors.expenseRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.darkNavy),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Yeni Hesap Oluştur',
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: AppColors.darkNavy,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Üst Logo & Başlık
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color:
                                AppColors.primaryGreen.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/images/paypulse_logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('PayPulse', style: AppTextStyles.headlineSmall),
                          Text(
                            'Yeni Nesil Dijital Cüzdan & POS',
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
                const SizedBox(height: 20),

                Text(
                  'PayPulse Ekosistemine Katılın',
                  style: AppTextStyles.displaySmallMobile.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkNavy,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Hesap tipinizi seçerek saniyeler içinde dijital cüzdanınızı açın.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 20),

                // 2. B2C / B2B Segmented Switch
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isB2BAccount = false),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !_isB2BAccount
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: !_isB2BAccount
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.05,
                                        ),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                'Bireysel (B2C)',
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: !_isB2BAccount
                                      ? AppColors.darkNavy
                                      : const Color(0xFF64748B),
                                  fontWeight: !_isB2BAccount
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isB2BAccount = true),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _isB2BAccount
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: _isB2BAccount
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.05,
                                        ),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                'Kurumsal (B2B)',
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: _isB2BAccount
                                      ? AppColors.darkNavy
                                      : const Color(0xFF64748B),
                                  fontWeight: _isB2BAccount
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 3. Ad Soyad
                Text('Ad Soyad', style: AppTextStyles.labelLarge),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _fullNameController,
                  style: AppTextStyles.bodyMedium,
                  decoration: _buildInputDecoration(
                    hintText: 'Deniz Aksoy',
                    prefixIcon: Icons.person_outline_rounded,
                  ),
                  validator: (val) => (val == null || val.trim().length < 3)
                      ? 'Ad ve soyadınızı eksiksiz girin'
                      : null,
                ),
                const SizedBox(height: 16),

                // 4. Eğer B2B Kurumsal Seçildiyse Şirket & Vergi No Alanları
                if (_isB2BAccount) ...[
                  Text(
                    'Şirket / İşletme Ünvanı',
                    style: AppTextStyles.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _companyNameController,
                    style: AppTextStyles.bodyMedium,
                    decoration: _buildInputDecoration(
                      hintText: 'PayPulse Teknoloji A.Ş.',
                      prefixIcon: Icons.business_rounded,
                    ),
                    validator: (val) => (val == null || val.trim().isEmpty)
                        ? 'Şirket ünvanı zorunludur'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Vergi Kimlik Numarası (VKN)',
                    style: AppTextStyles.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _taxNumberController,
                    style: AppTextStyles.bodyMedium,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    decoration: _buildInputDecoration(
                      hintText: '10 haneli VKN',
                      prefixIcon: Icons.receipt_long_rounded,
                    ),
                    validator: (val) => (val == null || val.length != 10)
                        ? 'Vergi numarası 10 haneli olmalıdır'
                        : null,
                  ),
                  const SizedBox(height: 16),
                ],

                // 5. E-Posta
                Text('E-Posta Adresi', style: AppTextStyles.labelLarge),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  style: AppTextStyles.bodyMedium,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _buildInputDecoration(
                    hintText: 'deniz@paypulse.com',
                    prefixIcon: Icons.mail_outline_rounded,
                  ),
                  validator: (val) {
                    if (val == null || !_emailRegex.hasMatch(val.trim())) {
                      return 'Geçerli bir e-posta adresi girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 6. Telefon Numarası (FAST Kolay Adres)
                Text(
                  'Telefon Numarası (FAST Kolay Adres)',
                  style: AppTextStyles.labelLarge,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  style: AppTextStyles.bodyMedium,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: _buildInputDecoration(
                    hintText: '5XX XXX XX XX',
                    prefixIcon: Icons.phone_iphone_rounded,
                  ),
                  validator: (val) => (val == null || val.length != 10)
                        ? 'Başında 0 olmadan 10 haneli numaranızı girin'
                        : null,
                ),
                const SizedBox(height: 16),

                // 7. Şifre
                Text('Şifre Belirleyin', style: AppTextStyles.labelLarge),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  style: AppTextStyles.bodyMedium,
                  obscureText: _obscurePassword,
                  decoration: _buildInputDecoration(
                    hintText: 'En az 6 karakter',
                    prefixIcon: Icons.lock_outline_rounded,
                    suffixIcon: IconButton(
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                  validator: (val) => (val == null || val.length < 6)
                      ? 'Şifre en az 6 karakter olmalıdır'
                      : null,
                ),
                const SizedBox(height: 16),

                // 8. KVKK Onayı
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          activeColor: AppColors.primaryGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          value: _kvkkAccepted,
                          onChanged: (val) =>
                              setState(() => _kvkkAccepted = val ?? false),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _kvkkAccepted = !_kvkkAccepted),
                          child: Text(
                            'KVKK Aydınlatma Metni ve PayPulse Çift Yönlü Cüzdan Sözleşmesini okudum, onaylıyorum.',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: const Color(0xFF475569),
                              height: 1.35,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 9. Kayıt Ol Butonu
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _isLoading ? null : _handleRegister,
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _isB2BAccount
                                ? 'Kurumsal Hesabı Oluştur'
                                : 'Bireysel Cüzdanı Oluştur',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // 10. Giriş Yap Ekranına Yönlendirme
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Zaten bir hesabınız var mı?',
                        style: AppTextStyles.bodyMedium,
                      ),
                      const SizedBox(width: 4),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Giriş Yapın',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
