import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_text.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../data/models/transaction.dart';
import '../../../data/services/json_service.dart';

class TransactionMonitoringScreen extends StatefulWidget {
  const TransactionMonitoringScreen({super.key});

  @override
  State<TransactionMonitoringScreen> createState() =>
      _TransactionMonitoringScreenState();
}

class _TransactionMonitoringScreenState
    extends State<TransactionMonitoringScreen> {
  List<Transaction> _transactions = [];
  bool _isLoading = true;
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);

    try {
      final transactions = await JsonService.instance.loadTransactions();
      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<Transaction> get _filteredTransactions {
    if (_filterStatus == 'all') {
      return _transactions;
    }
    return _transactions.where((t) => t.status == _filterStatus).toList();
  }

  double get _totalAmount {
    return _filteredTransactions.fold(0, (sum, t) => sum + t.totalAmount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Monitoring Transaksi')),
      body: Column(
        children: [
          // Statistics Summary
          Container(
            margin: const EdgeInsets.all(AppTheme.paddingMedium),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const BodyText(
                      'Total Transaksi',
                      size: 'small',
                      color: AppColors.textOnPrimary,
                    ),
                    const SizedBox(height: 8),
                    HeadingText(
                      _filteredTransactions.length.toString(),
                      level: 3,
                      color: AppColors.textOnPrimary,
                    ),
                  ],
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.textOnPrimary.withOpacity(0.3),
                ),
                Column(
                  children: [
                    const BodyText(
                      'Total Nilai',
                      size: 'small',
                      color: AppColors.textOnPrimary,
                    ),
                    const SizedBox(height: 8),
                    PriceText(
                      _totalAmount,
                      size: 'small',
                      color: AppColors.textOnPrimary,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.paddingMedium,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Semua', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Proses', 'proses'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Dijemput', 'dijemput'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Selesai', 'selesai'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Dibatalkan', 'dibatalkan'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Transactions List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTransactions.isEmpty
                ? EmptyStateCard(
                    icon: Icons.receipt_long_outlined,
                    title: 'Tidak Ada Data',
                    message: _filterStatus == 'all'
                        ? 'Belum ada transaksi'
                        : 'Tidak ada transaksi dengan status $_filterStatus',
                  )
                : RefreshIndicator(
                    onRefresh: _loadTransactions,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.paddingMedium,
                      ),
                      itemCount: _filteredTransactions.length,
                      itemBuilder: (context, index) {
                        final transaction = _filteredTransactions[index];
                        return _buildTransactionCard(transaction);
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

  Widget _buildTransactionCard(Transaction transaction) {
    return CustomCard(
      onTap: () {
        _showTransactionDetail(transaction);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BodyText(
                'TRX-${transaction.id.toUpperCase()}',
                fontWeight: FontWeight.w600,
              ),
              StatusBadge(status: transaction.status, type: 'transaction'),
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
                      transaction.nasabahName,
                      size: 'small',
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ),
              if (transaction.driverName != null)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CaptionText('Driver'),
                      BodyText(
                        transaction.driverName!,
                        size: 'small',
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CaptionText('Items:'),
                const SizedBox(height: 8),
                ...transaction.items.map(
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
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  CaptionText(
                    '${transaction.createdAt.day}/${transaction.createdAt.month}/${transaction.createdAt.year}',
                  ),
                ],
              ),
              PriceText(transaction.totalAmount, size: 'small'),
            ],
          ),
        ],
      ),
    );
  }

  void _showTransactionDetail(Transaction transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
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

              const HeadingText('Detail Transaksi', level: 3),
              const SizedBox(height: 24),

              _buildDetailRow('Nomor', 'TRX-${transaction.id.toUpperCase()}'),
              _buildDetailRow('Nasabah', transaction.nasabahName),
              if (transaction.driverName != null)
                _buildDetailRow('Driver', transaction.driverName!),
              _buildDetailRow('Status', transaction.status, isStatus: true),
              _buildDetailRow(
                'Tanggal',
                '${transaction.createdAt.day}/${transaction.createdAt.month}/${transaction.createdAt.year} ${transaction.createdAt.hour}:${transaction.createdAt.minute}',
              ),

              const Divider(height: 32),

              const BodyText('Item Sampah', fontWeight: FontWeight.w600),
              const SizedBox(height: 12),

              ...transaction.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BodyText(item.categoryName, size: 'small'),
                            CaptionText(
                              '${item.weight} kg × Rp ${item.pricePerKg.toInt()}',
                            ),
                          ],
                        ),
                      ),
                      BodyText(
                        'Rp ${item.subtotal.toInt()}',
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const HeadingText('Total', level: 4),
                  PriceText(transaction.totalAmount),
                ],
              ),

              const SizedBox(height: 24),

              const BodyText('Alamat', fontWeight: FontWeight.w600),
              const SizedBox(height: 8),
              BodyText(transaction.address, size: 'small'),

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
            StatusBadge(status: value, type: 'transaction')
          else
            BodyText(value, size: 'small', fontWeight: FontWeight.w600),
        ],
      ),
    );
  }
}
