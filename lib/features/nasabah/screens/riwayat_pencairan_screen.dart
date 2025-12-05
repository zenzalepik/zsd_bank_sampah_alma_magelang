import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_text.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../data/models/nasabah.dart';
import '../../../data/models/withdrawal.dart';
import '../../../data/services/json_service.dart';

class RiwayatPencairanScreen extends StatefulWidget {
  final Nasabah nasabah;

  const RiwayatPencairanScreen({super.key, required this.nasabah});

  @override
  State<RiwayatPencairanScreen> createState() => _RiwayatPencairanScreenState();
}

class _RiwayatPencairanScreenState extends State<RiwayatPencairanScreen> {
  List<Withdrawal> _withdrawals = [];
  bool _isLoading = true;
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadWithdrawals();
  }

  Future<void> _loadWithdrawals() async {
    setState(() => _isLoading = true);

    try {
      final withdrawals = await JsonService.instance.getWithdrawalsByNasabahId(
        widget.nasabah.id,
      );
      setState(() {
        _withdrawals = withdrawals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Withdrawal> get _filteredWithdrawals {
    if (_filterStatus == 'all') {
      return _withdrawals;
    }
    return _withdrawals.where((w) => w.status == _filterStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Pencairan')),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Semua', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Pending', 'pending'),
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredWithdrawals.isEmpty
                ? EmptyStateCard(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Tidak Ada Pencairan',
                    message: _filterStatus == 'all'
                        ? 'Anda belum mengajukan pencairan saldo'
                        : 'Tidak ada pencairan dengan status $_filterStatus',
                  )
                : RefreshIndicator(
                    onRefresh: _loadWithdrawals,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(
                        bottom: AppTheme.paddingMedium,
                      ),
                      itemCount: _filteredWithdrawals.length,
                      itemBuilder: (context, index) {
                        final withdrawal = _filteredWithdrawals[index];
                        return _buildWithdrawalCard(withdrawal);
                      },
                    ),
                  ),
          ),
        ],
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
      onTap: () {
        _showWithdrawalDetail(withdrawal);
      },
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CaptionText('Jumlah'),
                  const SizedBox(height: 4),
                  PriceText(withdrawal.amount, size: 'small'),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const CaptionText('Metode'),
                  const SizedBox(height: 4),
                  BodyText(
                    withdrawal.method == 'cash' ? 'Cash' : 'Transfer',
                    size: 'small',
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              CaptionText(
                '${withdrawal.createdAt.day}/${withdrawal.createdAt.month}/${withdrawal.createdAt.year} ${withdrawal.createdAt.hour}:${withdrawal.createdAt.minute.toString().padLeft(2, '0')}',
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
                children: [
                  const Icon(
                    Icons.note_alt_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: CaptionText(withdrawal.notes!)),
                ],
              ),
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

  void _showWithdrawalDetail(Withdrawal withdrawal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(AppTheme.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const HeadingText('Detail Pencairan', level: 3),
              const SizedBox(height: 24),

              _buildDetailRow(
                'Nomor Pencairan',
                'WD-${withdrawal.id.toUpperCase()}',
              ),
              _buildDetailRow(
                'Tanggal',
                '${withdrawal.createdAt.day}/${withdrawal.createdAt.month}/${withdrawal.createdAt.year}',
              ),
              _buildDetailRow('Status', withdrawal.status, isStatus: true),
              _buildDetailRow('Jumlah', 'Rp ${withdrawal.amount.toInt()}'),
              _buildDetailRow(
                'Metode',
                withdrawal.method == 'cash' ? 'Cash' : 'Transfer',
              ),

              if (withdrawal.notes != null && withdrawal.notes!.isNotEmpty) ...[
                const Divider(height: 32),
                const BodyText('Catatan', fontWeight: FontWeight.w600),
                const SizedBox(height: 8),
                BodyText(withdrawal.notes!, size: 'small'),
              ],

              if (withdrawal.status == 'dibatalkan' &&
                  withdrawal.rejectionReason != null) ...[
                const Divider(height: 32),
                const BodyText(
                  'Alasan Penolakan',
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
                const SizedBox(height: 8),
                BodyText(
                  withdrawal.rejectionReason!,
                  size: 'small',
                  color: AppColors.error,
                ),
              ],

              if (withdrawal.status == 'terverifikasi' &&
                  withdrawal.proofImageUrl != null) ...[
                const Divider(height: 32),
                const BodyText('Bukti Pembayaran', fontWeight: FontWeight.w600),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.success.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.success),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: BodyText(
                          'Pembayaran telah diverifikasi',
                          size: 'small',
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          BodyText(label, size: 'small', color: AppColors.textSecondary),
          if (isStatus)
            StatusBadge(status: value, type: 'withdrawal')
          else
            BodyText(value, size: 'small', fontWeight: FontWeight.w600),
        ],
      ),
    );
  }
}
