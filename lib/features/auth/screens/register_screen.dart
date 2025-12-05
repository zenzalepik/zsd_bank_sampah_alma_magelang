import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_text.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import 'otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() => _isLoading = false);

    // Navigate to OTP screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OTPScreen(
          phone: _phoneController.text,
          verificationType: 'register',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Nasabah')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const HeadingText('Buat Akun Baru', level: 3),
              const SizedBox(height: 8),
              const BodyText(
                'Daftar sebagai nasabah Bank Sampah Alma Magelang',
                size: 'small',
                color: AppColors.textSecondary,
              ),

              const SizedBox(height: 32),

              CustomTextField(
                label: 'Nama Lengkap',
                hint: 'Masukkan nama lengkap',
                controller: _fullNameController,
                prefixIcon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama lengkap tidak boleh kosong';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              CustomTextField(
                label: 'Username',
                hint: 'Masukkan username',
                controller: _usernameController,
                prefixIcon: Icons.account_circle_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Username tidak boleh kosong';
                  }
                  if (value.length < 4) {
                    return 'Username minimal 4 karakter';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              PhoneTextField(
                label: 'No. Handphone',
                controller: _phoneController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'No. handphone tidak boleh kosong';
                  }
                  if (value.length < 10) {
                    return 'No. handphone tidak valid';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              EmailTextField(label: 'Email', controller: _emailController),

              const SizedBox(height: 16),

              PasswordTextField(
                label: 'Password',
                hint: 'Minimal 6 karakter',
                controller: _passwordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password tidak boleh kosong';
                  }
                  if (value.length < 6) {
                    return 'Password minimal 6 karakter';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              PasswordTextField(
                label: 'Konfirmasi Password',
                hint: 'Ulangi password',
                controller: _confirmPasswordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Konfirmasi password tidak boleh kosong';
                  }
                  if (value != _passwordController.text) {
                    return 'Password tidak sama';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              PrimaryButton(
                text: 'Daftar',
                onPressed: _handleRegister,
                isLoading: _isLoading,
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const BodyText('Sudah punya akun? ', size: 'medium'),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
