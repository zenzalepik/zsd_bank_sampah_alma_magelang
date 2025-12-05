import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_text.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../data/services/json_service.dart';
import '../../../features/auth/screens/login_screen.dart';
import 'user_management_screen.dart';
import 'withdrawal_management_screen.dart';
import 'transaction_monitoring_screen.dart';
import 'category_management_screen.dart';
import 'company_profile_screen.dart';

class DashboardAdminScreen extends StatefulWidget {
  const DashboardAdminScreen({super.key});

  @override
  State<DashboardAdminScreen> createState() => _DashboardAdminScreenState();
}

class _DashboardAdminScreenState extends State<DashboardAdminScreen> {
  int _nasabahCount = 0;
  int _driverCount = 0;
  int _pendingWithdrawals = 0;
  int _activeTransactions = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);

    try {
      final nasabahList = await JsonService.instance.loadNasabah();
      final drivers = await JsonService.instance.loadDrivers();
      final withdrawals = await JsonService.instance.loadWithdrawals();
      final transactions = await JsonService.instance.loadTransactions();

      setState(() {
        _nasabahCount = nasabahList.length;
        _driverCount = drivers.length;
        _pendingWithdrawals = withdrawals
            .where((w) => w.status == 'pending')
            .length;
        _activeTransactions = transactions
            .where((t) => t.status == 'proses' || t.status == 'dijemput')
            .length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatistics,
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.logout, color: AppColors.error),
                    SizedBox(width: 12),
                    Text('Logout'),
                  ],
                ),
                onTap: () {
                  Future.delayed(Duration.zero, () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Yakin ingin keluar?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () {
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
                  });
                },
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStatistics,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppTheme.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HeadingText('Bank Sampah Alma Magelang', level: 3),
                    const SizedBox(height: 8),
                    const BodyText(
                      'Sistem Manajemen Bank Sampah',
                      size: 'small',
                      color: AppColors.textSecondary,
                    ),

                    const SizedBox(height: 24),

                    // Statistics Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.4,
                      children: [
                        StatCard(
                          label: 'Total Nasabah',
                          value: _nasabahCount.toString(),
                          icon: Icons.people,
                          color: AppColors.primary,
                        ),
                        StatCard(
                          label: 'Total Driver',
                          value: _driverCount.toString(),
                          icon: Icons.local_shipping,
                          color: AppColors.secondary,
                        ),
                        StatCard(
                          label: 'Pencairan Pending',
                          value: _pendingWithdrawals.toString(),
                          icon: Icons.account_balance_wallet,
                          color: AppColors.warning,
                        ),
                        StatCard(
                          label: 'Transaksi Aktif',
                          value: _activeTransactions.toString(),
                          icon: Icons.recycling,
                          color: AppColors.accent,
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Quick Actions
                    const HeadingText('Menu Utama', level: 4),
                    const SizedBox(height: 16),

                    _buildMenuCard(
                      icon: Icons.people_outline,
                      title: 'Manajemen Pengguna',
                      subtitle: 'Kelola data nasabah dan driver',
                      color: AppColors.primary,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const UserManagementScreen(),
                          ),
                        );
                      },
                    ),

                    _buildMenuCard(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'Pencairan Saldo',
                      subtitle: 'Approval pencairan saldo nasabah',
                      color: AppColors.accent,
                      badge: _pendingWithdrawals > 0
                          ? _pendingWithdrawals.toString()
                          : null,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const WithdrawalManagementScreen(),
                          ),
                        );
                      },
                    ),

                    _buildMenuCard(
                      icon: Icons.receipt_long_outlined,
                      title: 'Monitoring Transaksi',
                      subtitle: 'Lihat semua transaksi',
                      color: AppColors.secondary,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const TransactionMonitoringScreen(),
                          ),
                        );
                      },
                    ),

                    _buildMenuCard(
                      icon: Icons.category_outlined,
                      title: 'Kategori Sampah',
                      subtitle: 'Kelola kategori dan harga',
                      color: AppColors.success,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CategoryManagementScreen(),
                          ),
                        );
                      },
                    ),

                    _buildMenuCard(
                      icon: Icons.business_outlined,
                      title: 'Profil Perusahaan',
                      subtitle: 'Pengaturan bank sampah',
                      color: AppColors.info,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CompanyProfileScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    String? badge,
    required VoidCallback onTap,
  }) {
    return CustomCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: BodyText(title, fontWeight: FontWeight.w600),
                    ),
                    if (badge != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(
                            color: AppColors.textOnPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                CaptionText(subtitle),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
