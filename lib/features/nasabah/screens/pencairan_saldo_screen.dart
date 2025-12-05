import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_text.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../data/models/nasabah.dart';
import '../../../data/services/json_service.dart';

class PencairanSaldoScreen extends StatefulWidget {
  final Nasabah nasabah;

  const PencairanSaldoScreen({super.key, required this.nasabah});

  @override
  State<PencairanSaldoScreen> createState() => _PencairanSaldoScreenState();
}

class _PencairanSaldoScreenState extends State<PencairanSaldoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String _selectedMethod = 'cash';
  bool _isLoading = true;
  double _minimumWithdrawal = 50000;

  @override
  void initState() {
    super.initState();
    _loadCompanySettings();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadCompanySettings() async {
    try {
      final company = await JsonService.instance.loadCompany();
      setState(() {
        _minimumWithdrawal = company.minimumWithdrawal;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text);
    if (amount == null) return;

    if (amount > widget.nasabah.withdrawableBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saldo tidak mencukupi'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() => _isLoading = false);

    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            const HeadingText(
              'Pengajuan Berhasil!',
              level: 4,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const BodyText(
              'Pengajuan pencairan saldo Anda akan diproses oleh admin',
              size: 'small',
              color: AppColors.textSecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                text: 'OK',
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Back
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pencairan Saldo')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Balance Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const BodyText(
                            'Saldo yang Dapat Dicairkan',
                            size: 'small',
                            color: AppColors.textOnPrimary,
                          ),
                          const SizedBox(height: 8),
                          PriceText(
                            widget.nasabah.withdrawableBalance,
                            color: AppColors.textOnPrimary,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Info Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.info.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: AppColors.info),
                              const SizedBox(width: 12),
                              const BodyText(
                                'Ketentuan Pencairan',
                                fontWeight: FontWeight.w600,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          CaptionText(
                            '• Minimum pencairan: Rp ${_minimumWithdrawal.toInt()}',
                          ),
                          const SizedBox(height: 4),
                          const CaptionText(
                            '• Proses verifikasi 1-2 hari kerja',
                          ),
                          const SizedBox(height: 4),
                          const CaptionText(
                            '• Transfer dilakukan ke rekening terdaftar',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Amount Input
                    CustomTextField(
                      label: 'Jumlah Pencairan',
                      hint: 'Masukkan jumlah',
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: false,
                      ),
                      prefixIcon: Icons.payments_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Jumlah tidak boleh kosong';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null) {
                          return 'Jumlah tidak valid';
                        }
                        if (amount < _minimumWithdrawal) {
                          return 'Minimum pencairan Rp ${_minimumWithdrawal.toInt()}';
                        }
                        if (amount > widget.nasabah.withdrawableBalance) {
                          return 'Saldo tidak mencukupi';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Method Selection
                    const BodyText(
                      'Metode Pencairan',
                      fontWeight: FontWeight.w600,
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _buildMethodCard(
                            'Cash',
                            'cash',
                            Icons.money,
                            'Ambil di kantor',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMethodCard(
                            'Transfer',
                            'saldo',
                            Icons.account_balance,
                            'Transfer bank',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    PrimaryButton(
                      text: 'Ajukan Pencairan',
                      onPressed: _handleSubmit,
                      isLoading: _isLoading,
                      icon: Icons.send,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMethodCard(
    String label,
    String value,
    IconData icon,
    String subtitle,
  ) {
    final isSelected = _selectedMethod == value;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedMethod = value;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 32,
            ),
            const SizedBox(height: 8),
            BodyText(
              label,
              size: 'small',
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? AppColors.primary : AppColors.textPrimary,
            ),
            const SizedBox(height: 4),
            CaptionText(subtitle, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
