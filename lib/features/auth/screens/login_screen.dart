import 'package:bank_sampah/core/theme/app_colors.dart';
import 'package:bank_sampah/core/theme/app_text_styles.dart';
import 'package:bank_sampah/core/widgets/custom_button.dart';
import 'package:bank_sampah/core/widgets/custom_text.dart';
import 'package:bank_sampah/core/widgets/custom_text_field.dart';
import 'package:bank_sampah/data/models/driver.dart';
import 'package:bank_sampah/data/models/nasabah.dart';
import 'package:bank_sampah/data/services/json_service.dart';
import 'package:flutter/material.dart';
import '../../nasabah/screens/beranda_nasabah_screen.dart';
import '../../driver/screens/beranda_driver_screen.dart';
import '../../admin/screens/dashboard_admin_screen.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'nasabah';
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = await JsonService.instance.authenticate(
        _usernameController.text.trim(),
        _passwordController.text,
        _selectedRole,
      );

      if (!mounted) return;

      // Navigate based on role
      Widget targetScreen;
      if (_selectedRole == 'admin') {
        targetScreen = const DashboardAdminScreen();
      } else if (_selectedRole == 'driver') {
        targetScreen = BerandaDriverScreen(driver: user as Driver);
      } else {
        targetScreen = BerandaNasabahScreen(nasabah: user as Nasabah);
      }

      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => targetScreen));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login gagal: Username atau password salah'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // Logo or App Name
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.recycling,
                    size: 80,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(height: 24),

                const HeadingText(
                  'Bank Sampah',
                  level: 2,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                const BodyText(
                  'Alma Magelang',
                  size: 'large',
                  color: AppColors.textSecondary,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // Role Selection
                const BodyText(
                  'Login sebagai',
                  size: 'medium',
                  fontWeight: FontWeight.w600,
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(child: _buildRoleChip('Nasabah', 'nasabah')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildRoleChip('Driver', 'driver')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildRoleChip('Admin', 'admin')),
                  ],
                ),

                const SizedBox(height: 24),

                // Username Field
                CustomTextField(
                  label: 'Username / No. Handphone',
                  hint: 'Masukkan username atau nomor HP',
                  controller: _usernameController,
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Username tidak boleh kosong';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Password Field
                PasswordTextField(
                  label: 'Password',
                  hint: 'Masukkan password',
                  controller: _passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password tidak boleh kosong';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 8),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Lupa password?',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Login Button
                PrimaryButton(
                  text: 'Login',
                  onPressed: _handleLogin,
                  isLoading: _isLoading,
                ),

                if (_selectedRole == 'nasabah') ...[
                  const SizedBox(height: 24),

                  // Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const BodyText('Belum punya akun? ', size: 'medium'),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Daftar',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 40),

                // Info Text
                const CaptionText(
                  'Dengan login, Anda menyetujui syarat dan ketentuan yang berlaku',
                  textAlign: TextAlign.center,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleChip(String label, String value) {
    final isSelected = _selectedRole == value;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedRole = value;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
