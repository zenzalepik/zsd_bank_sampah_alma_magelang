import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_text.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../data/models/nasabah.dart';
import '../../../data/models/driver.dart';
import '../../../data/services/json_service.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Nasabah> _nasabahs = [];
  List<Driver> _drivers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUsers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);

    try {
      final nasabahs = await JsonService.instance.loadNasabahs();
      final drivers = await JsonService.instance.loadDrivers();

      setState(() {
        _nasabahs = nasabahs;
        _drivers = drivers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Pengguna'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Nasabah'),
            Tab(text: 'Driver'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [_buildNasabahList(), _buildDriverList()],
            ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton.extended(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tambah Driver - Coming Soon'),
                    backgroundColor: AppColors.info,
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Tambah Driver'),
            )
          : null,
    );
  }

  Widget _buildNasabahList() {
    if (_nasabahs.isEmpty) {
      return const EmptyStateCard(
        icon: Icons.people_outline,
        title: 'Tidak Ada Nasabah',
        message: 'Belum ada nasabah terdaftar',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        itemCount: _nasabahs.length,
        itemBuilder: (context, index) {
          final nasabah = _nasabahs[index];
          return CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        nasabah.fullName.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BodyText(
                            nasabah.fullName,
                            fontWeight: FontWeight.w600,
                          ),
                          CaptionText(nasabah.username),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const CaptionText(
                        'Aktif',
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.phone,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    CaptionText(nasabah.phone),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.email,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: CaptionText(nasabah.email)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    PriceText(nasabah.balance, size: 'small'),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDriverList() {
    if (_drivers.isEmpty) {
      return const EmptyStateCard(
        icon: Icons.local_shipping_outlined,
        title: 'Tidak Ada Driver',
        message: 'Belum ada driver terdaftar',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        itemCount: _drivers.length,
        itemBuilder: (context, index) {
          final driver = _drivers[index];
          return CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.secondary.withOpacity(0.1),
                      child: Text(
                        driver.fullName.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BodyText(
                            driver.fullName,
                            fontWeight: FontWeight.w600,
                          ),
                          CaptionText(driver.username),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            (driver.isAvailable
                                    ? AppColors.success
                                    : AppColors.error)
                                .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CaptionText(
                        driver.isAvailable ? 'Tersedia' : 'Sibuk',
                        color: driver.isAvailable
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.local_shipping,
                      size: 16,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 8),
                    BodyText(
                      driver.vehicleNumber,
                      size: 'small',
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.phone,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    CaptionText(driver.phone),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.email,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: CaptionText(driver.email)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
