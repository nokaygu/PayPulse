import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/errors/auth_error_messages.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/datasources/remote/firebase_auth_datasource.dart';

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

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_kvkkAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Devam etmek için KVKK ve Kullanıcı Sözleşmesini onaylayın.',
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Yeni Hesap Oluştur', style: AppTextStyles.headlineSmall),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PayPulse Ekosistemine Katılın',
                  style: AppTextStyles.headlineMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'Hesap tipinizi seçerek saniyeler içinde dijital cüzdanınızı açın.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),

                // 1. B2C / B2B Hesap Tipi Seçimi
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppLightColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isB2BAccount = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !_isB2BAccount
                                  ? AppLightColors.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                'Bireysel (B2C)',
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: !_isB2BAccount
                                      ? Colors.white
                                      : AppLightColors.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isB2BAccount = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _isB2BAccount
                                  ? AppLightColors.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                'Kurumsal (B2B)',
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: _isB2BAccount
                                      ? Colors.white
                                      : AppLightColors.onSurfaceVariant,
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

                // 2. Ad Soyad
                Text('Ad Soyad', style: AppTextStyles.labelLarge),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    hintText: 'Deniz Aksoy',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: (val) => (val == null || val.trim().length < 3)
                      ? 'Ad ve soyadınızı eksiksiz girin'
                      : null,
                ),
                const SizedBox(height: 16),

                // 3. Eğer B2B Kurumsal Seçildiyse Şirket & Vergi No Alanları
                if (_isB2BAccount) ...[
                  Text(
                    'Şirket / İşletme Ünvanı',
                    style: AppTextStyles.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _companyNameController,
                    decoration: const InputDecoration(
                      hintText: 'PayPulse Teknoloji A.Ş.',
                      prefixIcon: Icon(Icons.business_rounded),
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
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    decoration: const InputDecoration(
                      hintText: '10 haneli VKN',
                      prefixIcon: Icon(Icons.receipt_long_rounded),
                    ),
                    validator: (val) => (val == null || val.length != 10)
                        ? 'Vergi numarası 10 haneli olmalıdır'
                        : null,
                  ),
                  const SizedBox(height: 16),
                ],

                // 4. E-Posta
                Text('E-Posta Adresi', style: AppTextStyles.labelLarge),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'deniz@paypulse.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (val) {
                    if (val == null || !_emailRegex.hasMatch(val.trim())) {
                      return 'Geçerli bir e-posta adresi girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 5. Telefon Numarası (FAST Kolay Adres)
                Text(
                  'Telefon Numarası (FAST Kolay Adres)',
                  style: AppTextStyles.labelLarge,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: const InputDecoration(
                    hintText: '5XX XXX XX XX',
                    prefixIcon: Icon(Icons.phone_iphone_rounded),
                  ),
                  validator: (val) => (val == null || val.length != 10)
                      ? 'Başında 0 olmadan 10 haneli numaranızı girin'
                      : null,
                ),
                const SizedBox(height: 16),

                // 6. Şifre
                Text('Şifre Belirleyin', style: AppTextStyles.labelLarge),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'En az 6 karakter',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                  ),
                  validator: (val) => (val == null || val.length < 6)
                      ? 'Şifre en az 6 karakter olmalıdır'
                      : null,
                ),
                const SizedBox(height: 16),

                // 7. KVKK Onayı
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppLightColors.primary,
                  value: _kvkkAccepted,
                  onChanged: (val) =>
                      setState(() => _kvkkAccepted = val ?? false),
                  title: Text(
                    'KVKK Aydınlatma Metni ve PayPulse Çift Yönlü Cüzdan Sözleşmesini okudum, onaylıyorum.',
                    style: AppTextStyles.bodySmall,
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const SizedBox(height: 20),

                // 8. Kayıt Ol Butonu
                ElevatedButton(
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
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
