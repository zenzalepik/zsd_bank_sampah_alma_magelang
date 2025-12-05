import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_text.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../data/models/nasabah.dart';
import '../../../features/auth/screens/login_screen.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';

class ProfileScreen extends StatelessWidget {
  final Nasabah nasabah;

  const ProfileScreen({super.key, required this.nasabah});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Profile Header
          Container(
            width: double.infinity,
            decoration: BoxDecoration(gradient: AppColors.primaryGradient),
            padding: const EdgeInsets.all(AppTheme.paddingLarge),
            child: Column(
              children: [
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Text(
                    nasabah.fullName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                HeadingText(
                  nasabah.fullName,
                  level: 3,
                  color: AppColors.textOnPrimary,
                ),
                const SizedBox(height: 4),
                BodyText(
                  nasabah.email,
                  size: 'small',
                  color: AppColors.textOnPrimary,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Profile Options
          InfoCard(
            icon: Icons.person_outline,
            iconColor: AppColors.primary,
            title: 'Edit Profile',
            value: 'Ubah data diri',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EditProfileScreen(nasabah: nasabah),
                ),
              );
            },
          ),

          InfoCard(
            icon: Icons.lock_outline,
            iconColor: AppColors.accent,
            title: 'Ubah Password',
            value: 'Keamanan akun',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChangePasswordScreen(nasabah: nasabah),
                ),
              );
            },
          ),

          InfoCard(
            icon: Icons.location_on_outlined,
            iconColor: AppColors.secondary,
            title: 'Alamat',
            value: nasabah.address,
          ),

          InfoCard(
            icon: Icons.phone_outlined,
            iconColor: AppColors.info,
            title: 'No. Handphone',
            value: nasabah.phone,
          ),

          const SizedBox(height: 16),

          // Balance Info
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.paddingMedium,
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const CaptionText('Total Saldo'),
                      const SizedBox(height: 8),
                      PriceText(nasabah.balance, size: 'small'),
                    ],
                  ),
                  Container(width: 1, height: 40, color: AppColors.border),
                  Column(
                    children: [
                      const CaptionText('Dapat Dicairkan'),
                      const SizedBox(height: 8),
                      PriceText(nasabah.withdrawableBalance, size: 'small'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Logout Button
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.paddingMedium,
            ),
            child: OutlinedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Apakah Anda yakin ingin keluar?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        child: const Text(
                          'Logout',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.logout, color: AppColors.error),
              label: const Text(
                'Logout',
                style: TextStyle(color: AppColors.error),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
