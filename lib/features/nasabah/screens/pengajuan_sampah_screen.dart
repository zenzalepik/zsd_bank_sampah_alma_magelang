import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_text.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../data/models/nasabah.dart';
import '../../../data/models/category.dart';
import '../../../data/services/json_service.dart';

class PengajuanSampahScreen extends StatefulWidget {
  final Nasabah nasabah;

  const PengajuanSampahScreen({super.key, required this.nasabah});

  @override
  State<PengajuanSampahScreen> createState() => _PengajuanSampahScreenState();
}

class _PengajuanSampahScreenState extends State<PengajuanSampahScreen> {
  List<Category> _categories = [];
  Map<String, double> _selectedCategories = {};
  bool _isLoading = true;
  bool _isSubmitting = false;
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _addressController.text = widget.nasabah.address;
    _loadCategories();
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await JsonService.instance.loadCategories();
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  double _calculateTotal() {
    double total = 0;
    _selectedCategories.forEach((categoryId, weight) {
      final category = _categories.firstWhere((c) => c.id == categoryId);
      total += category.pricePerKg * weight;
    });
    return total;
  }

  Future<void> _submitPengajuan() async {
    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal 1 kategori sampah'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pengajuan sampah berhasil!'),
        backgroundColor: AppColors.success,
      ),
    );

    // Clear form
    setState(() {
      _selectedCategories.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HeadingText('Pilih Kategori Sampah', level: 4),
          const SizedBox(height: 8),
          const BodyText(
            'Pilih kategori dan masukkan berat sampah yang ingin Anda setor',
            size: 'small',
            color: AppColors.textSecondary,
          ),

          const SizedBox(height: 24),

          // Categories List
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = _selectedCategories.containsKey(
                      category.id,
                    );

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  category.iconUrl,
                                  style: const TextStyle(fontSize: 32),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      BodyText(
                                        category.name,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      const SizedBox(height: 4),
                                      BodyText(
                                        'Rp ${category.pricePerKg.toInt()} / kg',
                                        size: 'small',
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ],
                                  ),
                                ),
                                Checkbox(
                                  value: isSelected,
                                  onChanged: (value) {
                                    setState(() {
                                      if (value == true) {
                                        _selectedCategories[category.id] = 1.0;
                                      } else {
                                        _selectedCategories.remove(category.id);
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),

                            if (isSelected) ...[
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomTextField(
                                      label: 'Berat (kg)',
                                      hint: '0.0',
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      onChanged: (value) {
                                        final weight = double.tryParse(value);
                                        if (weight != null) {
                                          setState(() {
                                            _selectedCategories[category.id] =
                                                weight;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const BodyText(
                                          'Subtotal',
                                          size: 'small',
                                          color: AppColors.textSecondary,
                                        ),
                                        const SizedBox(height: 8),
                                        PriceText(
                                          category.pricePerKg *
                                              (_selectedCategories[category
                                                      .id] ??
                                                  0),
                                          size: 'small',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),

          const SizedBox(height: 24),

          // Address
          CustomTextField(
            label: 'Alamat Penjemputan',
            hint: 'Masukkan alamat',
            controller: _addressController,
            maxLines: 3,
            prefixIcon: Icons.location_on_outlined,
          ),

          const SizedBox(height: 24),

          // Total Summary
          if (_selectedCategories.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const BodyText(
                        'Jumlah Item',
                        fontWeight: FontWeight.w600,
                      ),
                      BodyText(
                        '${_selectedCategories.length} kategori',
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const HeadingText('Total', level: 4),
                      PriceText(_calculateTotal()),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Submit Button
          PrimaryButton(
            text: 'Ajukan Penjemputan',
            onPressed: _submitPengajuan,
            isLoading: _isSubmitting,
            icon: Icons.send,
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
