import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_text.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/utils/whatsapp_helper.dart';
import '../../../data/models/driver.dart';
import '../../../data/models/transaction.dart';
import '../../../data/services/json_service.dart';

class DetailPenjemputanScreen extends StatefulWidget {
  final Transaction transaction;
  final Driver driver;
  final VoidCallback onStatusUpdated;

  const DetailPenjemputanScreen({
    super.key,
    required this.transaction,
    required this.driver,
    required this.onStatusUpdated,
  });

  @override
  State<DetailPenjemputanScreen> createState() =>
      _DetailPenjemputanScreenState();
}

class _DetailPenjemputanScreenState extends State<DetailPenjemputanScreen> {
  bool _isLoading = false;
  final Map<String, TextEditingController> _adjustedWeights = {};

  @override
  void initState() {
    super.initState();
    // Initialize weight controllers
    for (var item in widget.transaction.items) {
      _adjustedWeights[item.categoryId] = TextEditingController(
        text: item.weight.toString(),
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _adjustedWeights.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() => _isLoading = false);

    String message;
    if (newStatus == 'dijemput') {
      message = 'Status diupdate: Dalam Perjalanan';
    } else if (newStatus == 'selesai') {
      message = 'Penjemputan selesai!';
    } else {
      message = 'Status diupdate: Dibatalkan';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: newStatus == 'dibatalkan'
            ? AppColors.error
            : AppColors.success,
      ),
    );

    widget.onStatusUpdated();
    Navigator.of(context).pop();
  }

  double _calculateAdjustedTotal() {
    double total = 0;
    for (var item in widget.transaction.items) {
      final weight =
          double.tryParse(_adjustedWeights[item.categoryId]!.text) ?? 0;
      total += weight * item.pricePerKg;
    }
    return total;
  }

  Future<void> _saveAdjustments() async {
    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kuantitas berhasil diperbarui'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Penjemputan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.secondaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  StatusBadge(
                    status: widget.transaction.status,
                    type: 'transaction',
                  ),
                  const SizedBox(height: 12),
                  HeadingText(
                    'TRX-${widget.transaction.id.toUpperCase()}',
                    level: 4,
                    color: AppColors.textOnPrimary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Customer  Info
            const HeadingText('Informasi Nasabah', level: 4),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CaptionText('Nama'),
                            BodyText(
                              widget.transaction.nasabahName,
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: AppColors.error),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CaptionText('Alamat'),
                            BodyText(widget.transaction.address, size: 'small'),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // WhatsApp contact button
                  const Divider(height: 24),
                  FutureBuilder(
                    future: JsonService.instance.getNasabahById(
                      widget.transaction.nasabahId,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        final nasabah = snapshot.data!;
                        return OutlineButton(
                          text: 'Hubungi Nasabah via WhatsApp',
                          icon: Icons.chat,
                          onPressed: () async {
                            try {
                              await WhatsAppHelper.openWhatsApp(
                                nasabah.phone,
                                message:
                                    'Halo ${nasabah.fullName}, saya driver akan mengambil sampah Anda untuk TRX-${widget.transaction.id.toUpperCase()}',
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
              ),
            ),

            const SizedBox(height: 24),

            // Items Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const HeadingText('Item Sampah', level: 4),
                if (widget.transaction.status == 'dijemput')
                  TextButton.icon(
                    onPressed: _saveAdjustments,
                    icon: const Icon(Icons.save, size: 18),
                    label: const Text('Simpan Perubahan'),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            ...widget.transaction.items.map((item) {
              final controller = _adjustedWeights[item.categoryId]!;
              final canEdit = widget.transaction.status == 'dijemput';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item.categoryName,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: BodyText(
                            item.categoryName,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const CaptionText('Berat (kg)'),
                              const SizedBox(height: 8),
                              if (canEdit)
                                TextField(
                                  controller: controller,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  decoration: InputDecoration(
                                    hintText: '0.0',
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    setState(() {}); // Refresh total
                                  },
                                )
                              else
                                BodyText(
                                  '${item.weight} kg',
                                  fontWeight: FontWeight.w600,
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const CaptionText('Subtotal'),
                              const SizedBox(height: 8),
                              PriceText(
                                (double.tryParse(controller.text) ?? 0) *
                                    item.pricePerKg,
                                size: 'small',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 16),

            // Total
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const HeadingText('Total', level: 4),
                  PriceText(_calculateAdjustedTotal()),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Action Buttons
            if (widget.transaction.status == 'proses') ...[
              PrimaryButton(
                text: 'Mulai Penjemputan',
                onPressed: () => _updateStatus('dijemput'),
                isLoading: _isLoading,
                icon: Icons.local_shipping,
              ),
              const SizedBox(height: 12),
              OutlineButton(
                text: 'Batalkan',
                onPressed: () => _updateStatus('dibatalkan'),
                borderColor: AppColors.error,
                textColor: AppColors.error,
              ),
            ] else if (widget.transaction.status == 'dijemput') ...[
              PrimaryButton(
                text: 'Selesai',
                onPressed: () => _updateStatus('selesai'),
                isLoading: _isLoading,
                icon: Icons.check_circle,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
