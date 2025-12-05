import 'package:flutter/material.dart';
import '../../../core/services/session_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/json_service.dart';
import '../../auth/screens/login_screen.dart';
import '../../nasabah/screens/beranda_nasabah_screen.dart';
import '../../driver/screens/beranda_driver_screen.dart';
import '../../admin/screens/dashboard_admin_screen.dart';
import '../../../data/models/nasabah.dart';
import '../../../data/models/driver.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // Artificial delay for splash effect
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final session = await SessionService.instance.getSession();
    final userId = session['userId'];
    final role = session['role'];

    if (userId != null && role != null) {
      try {
        // Validate session by trying to fetch user data
        // Note: In a real app, we might verify a token here.
        // For now, we just check if we can load the user from JsonService.

        // Ensure data is loaded first
        await JsonService.instance.initialize();

        Widget targetScreen;
        if (role == 'admin') {
          targetScreen = const DashboardAdminScreen();
        } else if (role == 'driver') {
          final driver = await JsonService.instance.getDriverById(userId);
          if (driver != null) {
            targetScreen = BerandaDriverScreen(driver: driver);
          } else {
            throw Exception('Driver not found');
          }
        } else {
          final nasabah = await JsonService.instance.getNasabahById(userId);
          if (nasabah != null) {
            targetScreen = BerandaNasabahScreen(nasabah: nasabah);
          } else {
            throw Exception('Nasabah not found');
          }
        }

        if (mounted) {
          Navigator.of(
            context,
          ).pushReplacement(MaterialPageRoute(builder: (_) => targetScreen));
          return;
        }
      } catch (e) {
        // Session invalid or user not found, clear session
        await SessionService.instance.clearSession();
      }
    }

    if (mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
            const CircularProgressIndicator(color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
