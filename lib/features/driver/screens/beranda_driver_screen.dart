import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_text.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../data/models/driver.dart';
import '../../../data/models/transaction.dart';
import '../../../data/services/json_service.dart';
import '../../../features/auth/screens/login_screen.dart';
import 'detail_penjemputan_screen.dart';

class BerandaDriverScreen extends StatefulWidget {
  final Driver driver;

  const BerandaDriverScreen({super.key, required this.driver});

  @override
  State<BerandaDriverScreen> createState() => _BerandaDriverScreenState();
}

class _BerandaDriverScreenState extends State<BerandaDriverScreen> {
  List<Transaction> _activeTasks = [];
  List<Transaction> _completedTasks = [];
  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);

    try {
      final allTransactions = await JsonService.instance.loadTransactions();

      setState(() {
        // Get active tasks (proses or dijemput status)
        _activeTasks = allTransactions
            .where((t) => t.status == 'proses' || t.status == 'dijemput')
            .toList();

        // Get completed tasks for this driver
        _completedTasks = allTransactions
            .where(
              (t) => t.driverId == widget.driver.id && t.status == 'selesai',
            )
            .toList();

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildBody() {
    if (_selectedIndex == 0) {
      return _buildBerandaContent();
    } else {
      return _buildRiwayatContent();
    }
  }

  Widget _buildBerandaContent() {
    return RefreshIndicator(
      onRefresh: _loadTasks,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Driver Info Header
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: AppColors.secondaryGradient,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Text(
                          widget.driver.fullName.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            HeadingText(
                              widget.driver.fullName,
                              level: 4,
                              color: AppColors.textOnPrimary,
                            ),
                            const SizedBox(height: 4),
                            BodyText(
                              widget.driver.vehicleNumber,
                              size: 'small',
                              color: AppColors.textOnPrimary,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: widget.driver.isAvailable
                              ? AppColors.success
                              : AppColors.error,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: BodyText(
                          widget.driver.isAvailable ? 'Tersedia' : 'Sibuk',
                          size: 'small',
                          color: AppColors.textOnPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Statistics Cards
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.paddingMedium,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'Penjemputan Aktif',
                      value: _activeTasks.length.toString(),
                      icon: Icons.local_shipping,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      label: 'Selesai Hari Ini',
                      value: _completedTasks
                          .where((t) {
                            final today = DateTime.now();
                            return t.createdAt.day == today.day &&
                                t.createdAt.month == today.month &&
                                t.createdAt.year == today.year;
                          })
                          .length
                          .toString(),
                      icon: Icons.check_circle,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Active Tasks Section
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.paddingMedium,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const HeadingText('Penjemputan Aktif', level: 4),
                  if (_activeTasks.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        // Refresh
                        _loadTasks();
                      },
                      child: const Icon(
                        Icons.refresh,
                        color: AppColors.primary,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Active Tasks List
            _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _activeTasks.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.paddingMedium,
                    ),
                    child: EmptyStateCard(
                      icon: Icons.inbox_outlined,
                      title: 'Tidak Ada Penjemputan',
                      message: 'Belum ada penjemputan aktif saat ini',
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: _activeTasks.length,
                    itemBuilder: (context, index) {
                      final task = _activeTasks[index];
                      return _buildTaskCard(task);
                    },
                  ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRiwayatContent() {
    return Column(
      children: [
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _completedTasks.isEmpty
              ? const EmptyStateCard(
                  icon: Icons.history_outlined,
                  title: 'Tidak Ada Riwayat',
                  message: 'Anda belum menyelesaikan penjemputan',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppTheme.paddingMedium),
                  itemCount: _completedTasks.length,
                  itemBuilder: (context, index) {
                    final task = _completedTasks[index];
                    return _buildTaskCard(task, isCompleted: true);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTaskCard(Transaction task, {bool isCompleted = false}) {
    return CustomCard(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DetailPenjemputanScreen(
              transaction: task,
              driver: widget.driver,
              onStatusUpdated: _loadTasks,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BodyText(task.nasabahName, fontWeight: FontWeight.w600),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: CaptionText(
                            task.address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!isCompleted)
                StatusBadge(status: task.status, type: 'transaction'),
            ],
          ),

          const SizedBox(height: 12),

          // Items
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BodyText(
                  'Item Sampah:',
                  size: 'small',
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 8),
                ...task.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        BodyText(
                          '${item.categoryName} (${item.weight} kg)',
                          size: 'small',
                        ),
                        BodyText(
                          'Rp ${item.subtotal.toInt()}',
                          size: 'small',
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BodyText(
                '${task.createdAt.day}/${task.createdAt.month}/${task.createdAt.year}',
                size: 'small',
                color: AppColors.textSecondary,
              ),
              PriceText(task.totalAmount, size: 'small'),
            ],
          ),

          if (!isCompleted) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DetailPenjemputanScreen(
                        transaction: task,
                        driver: widget.driver,
                        onStatusUpdated: _loadTasks,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: const Text('Lihat Detail'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Beranda' : 'Riwayat'),
        automaticallyImplyLeading: false,
        actions: [
          if (_selectedIndex == 0)
            PopupMenuButton(
              icon: const Icon(Icons.more_vert),
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
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Riwayat',
          ),
        ],
      ),
    );
  }
}
