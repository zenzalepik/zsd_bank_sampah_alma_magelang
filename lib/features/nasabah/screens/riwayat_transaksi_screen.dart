import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_text.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/utils/whatsapp_helper.dart';
import '../../../data/models/nasabah.dart';
import '../../../data/models/transaction.dart';
import '../../../data/services/json_service.dart';

class RiwayatTransaksiScreen extends StatefulWidget {
  final Nasabah nasabah;

  const RiwayatTransaksiScreen({super.key, required this.nasabah});

  @override
  State<RiwayatTransaksiScreen> createState() => _RiwayatTransaksiScreenState();
}

class _RiwayatTransaksiScreenState extends State<RiwayatTransaksiScreen> {
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
      final transactions = await JsonService.instance
          .getTransactionsByNasabahId(widget.nasabah.id);
      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Transaction> get _filteredTransactions {
    if (_filterStatus == 'all') {
      return _transactions;
    }
    return _transactions.where((t) => t.status == _filterStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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

        // Transactions List
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredTransactions.isEmpty
              ? EmptyStateCard(
                  icon: Icons.receipt_long_outlined,
                  title: 'Tidak Ada Transaksi',
                  message: _filterStatus == 'all'
                      ? 'Anda belum memiliki transaksi'
                      : 'Tidak ada transaksi dengan status $_filterStatus',
                )
              : RefreshIndicator(
                  onRefresh: _loadTransactions,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(
                      bottom: AppTheme.paddingMedium,
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
        // Navigate to detail
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

          // Items
          ...transaction.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(
                    Icons.circle,
                    size: 6,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: BodyText(
                      '${item.categoryName} - ${item.weight} kg',
                      size: 'small',
                    ),
                  ),
                  BodyText(
                    'Rp ${item.subtotal.toInt()}',
                    size: 'small',
                    color: AppColors.primary,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CaptionText('Tanggal'),
                  const SizedBox(height: 4),
                  BodyText(
                    '${transaction.createdAt.day}/${transaction.createdAt.month}/${transaction.createdAt.year}',
                    size: 'small',
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const CaptionText('Total'),
                  const SizedBox(height: 4),
                  PriceText(transaction.totalAmount, size: 'small'),
                ],
              ),
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

              _buildDetailRow(
                'Nomor Transaksi',
                'TRX-${transaction.id.toUpperCase()}',
              ),
              _buildDetailRow(
                'Tanggal',
                '${transaction.createdAt.day}/${transaction.createdAt.month}/${transaction.createdAt.year} ${transaction.createdAt.hour}:${transaction.createdAt.minute}',
              ),
              _buildDetailRow('Status', transaction.status, isStatus: true),

              if (transaction.driverName != null)
                _buildDetailRow('Driver', transaction.driverName!),

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

              const BodyText('Alamat Penjemputan', fontWeight: FontWeight.w600),
              const SizedBox(height: 8),
              BodyText(transaction.address, size: 'small'),

              // WhatsApp contact button if driver assigned and transaction is active
              if (transaction.driverId != null &&
                  (transaction.status == 'proses' ||
                      transaction.status == 'dijemput')) ...[
                const SizedBox(height: 24),

                FutureBuilder(
                  future: JsonService.instance.getDriverById(
                    transaction.driverId!,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      final driver = snapshot.data!;
                      return OutlineButton(
                        text: 'Hubungi Driver via WhatsApp',
                        icon: Icons.chat,
                        onPressed: () async {
                          try {
                            await WhatsAppHelper.openWhatsApp(
                              driver.phone,
                              message:
                                  'Halo ${driver.fullName}, saya ingin menanyakan tentang penjemputan sampah TRX-${transaction.id.toUpperCase()}',
                            );
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Tidak dapat membuka WhatsApp: $e',
                                  ),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        },
                        borderColor: Colors.green,
                        textColor: Colors.green,
                      );
                    }
                    return const SizedBox.shrink();
                  },
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
            StatusBadge(status: value, type: 'transaction')
          else
            BodyText(value, size: 'small', fontWeight: FontWeight.w600),
        ],
      ),
    );
  }
}
