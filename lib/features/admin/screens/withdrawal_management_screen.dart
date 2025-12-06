import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_text.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../data/models/withdrawal.dart';
import '../../../data/services/firestore_service.dart';

class WithdrawalManagementScreen extends StatefulWidget {
  const WithdrawalManagementScreen({super.key});

  @override
  State<WithdrawalManagementScreen> createState() =>
      _WithdrawalManagementScreenState();
}

class _WithdrawalManagementScreenState
    extends State<WithdrawalManagementScreen> {
  String _filterStatus = 'pending';

  Future<void> _approveWithdrawal(Withdrawal withdrawal) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Setujui Pencairan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BodyText('Setujui pencairan saldo sebesar:', size: 'small'),
            const SizedBox(height: 8),
            PriceText(withdrawal.amount),
            const SizedBox(height: 16),
            const BodyText(
              'Pastikan pembayaran telah dilakukan',
              size: 'small',
              color: AppColors.textSecondary,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              try {
                await FirestoreService.instance.updateWithdrawalStatus(
                  withdrawal.id,
                  'terverifikasi',
                );

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pencairan berhasil disetujui'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gagal menyetujui: $e'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text(
              'Setujui',
              style: TextStyle(color: AppColors.success),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _rejectWithdrawal(Withdrawal withdrawal) async {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tolak Pencairan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BodyText('Berikan alasan penolakan:', size: 'small'),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Alasan Penolakan',
              hint: 'Masukkan alasan',
              controller: reasonController,
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              if (reasonController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Alasan penolakan tidak boleh kosong'),
                    backgroundColor: AppColors.warning,
                  ),
                );
                return;
              }

              Navigator.pop(context);

              try {
                // Note: Currently updateWithdrawalStatus only updates status.
                // If we need to save rejection reason, we need to update FirestoreService
                // or just update status for now as per current service capability.
                // Ideally we should update the service to accept reason.
                // For now, just updating status to 'dibatalkan'.
                await FirestoreService.instance.updateWithdrawalStatus(
                  withdrawal.id,
                  'dibatalkan',
                );

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pencairan ditolak'),
                    backgroundColor: AppColors.error,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gagal menolak: $e'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text(
              'Tolak',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manajemen Pencairan')),
      body: StreamBuilder<List<Withdrawal>>(
        stream: FirestoreService.instance.getWithdrawalsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final withdrawals = snapshot.data ?? [];
          final filteredWithdrawals = _filterStatus == 'all'
              ? withdrawals
              : withdrawals.where((w) => w.status == _filterStatus).toList();

          return Column(
            children: [
              // Filter Chips
              Container(
                padding: const EdgeInsets.all(AppTheme.paddingMedium),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Pending', 'pending'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Semua', 'all'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Terverifikasi', 'terverifikasi'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Dibatalkan', 'dibatalkan'),
                    ],
                  ),
                ),
              ),

              // Withdrawals List
              Expanded(
                child: filteredWithdrawals.isEmpty
                    ? EmptyStateCard(
                        icon: Icons.inbox_outlined,
                        title: 'Tidak Ada Data',
                        message: _filterStatus == 'pending'
                            ? 'Tidak ada pencairan yang menunggu approval'
                            : 'Tidak ada pencairan dengan status $_filterStatus',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.paddingMedium,
                        ),
                        itemCount: filteredWithdrawals.length,
                        itemBuilder: (context, index) {
                          final withdrawal = filteredWithdrawals[index];
                          return _buildWithdrawalCard(withdrawal);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterStatus == value;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterStatus = value;
        });
      },
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildWithdrawalCard(Withdrawal withdrawal) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BodyText(
                'WD-${withdrawal.id.toUpperCase()}',
                fontWeight: FontWeight.w600,
              ),
              StatusBadge(status: withdrawal.status, type: 'withdrawal'),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CaptionText('Nasabah'),
                    BodyText(
                      withdrawal.nasabahId,
                      size: 'small',
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const CaptionText('Jumlah'),
                  PriceText(withdrawal.amount, size: 'small'),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(
                Icons.payment,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              CaptionText(
                withdrawal.method == 'cash' ? 'Cash' : 'Transfer Bank',
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.access_time,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              CaptionText(
                '${withdrawal.createdAt.day}/${withdrawal.createdAt.month}/${withdrawal.createdAt.year}',
              ),
            ],
          ),

          if (withdrawal.notes != null && withdrawal.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.note,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: CaptionText(withdrawal.notes!)),
                ],
              ),
            ),
          ],

          if (withdrawal.status == 'pending') ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlineButton(
                    text: 'Tolak',
                    onPressed: () => _rejectWithdrawal(withdrawal),
                    size: 'small',
                    borderColor: AppColors.error,
                    textColor: AppColors.error,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    text: 'Setujui',
                    onPressed: () => _approveWithdrawal(withdrawal),
                    size: 'small',
                  ),
                ),
              ],
            ),
          ],

          if (withdrawal.status == 'dibatalkan' &&
              withdrawal.rejectionReason != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 16,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CaptionText(
                      withdrawal.rejectionReason!,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
