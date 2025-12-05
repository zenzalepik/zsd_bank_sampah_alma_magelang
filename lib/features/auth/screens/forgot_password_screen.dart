import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_text.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import 'otp_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
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
          phone: _emailController.text,
          verificationType: 'forgot_password',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lupa Password')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_reset,
                  size: 60,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 32),

              const HeadingText(
                'Lupa Password?',
                level: 3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const BodyText(
                'Masukkan email Anda untuk menerima kode verifikasi',
                size: 'small',
                color: AppColors.textSecondary,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              EmailTextField(
                label: 'Email',
                hint: 'email@example.com',
                controller: _emailController,
              ),

              const SizedBox(height: 32),

              PrimaryButton(
                text: 'Kirim Kode Verifikasi',
                onPressed: _handleSubmit,
                isLoading: _isLoading,
                icon: Icons.send,
              ),

              const SizedBox(height: 24),

              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Kembali ke Login',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
