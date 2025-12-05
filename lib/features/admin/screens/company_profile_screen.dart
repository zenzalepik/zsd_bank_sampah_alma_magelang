import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_text.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../data/models/company.dart';
import '../../../data/services/json_service.dart';

class CompanyProfileScreen extends StatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  Company? _company;
  bool _isLoading = true;
  bool _isEditing = false;

  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _descriptionController;
  late TextEditingController _operationalHoursController;
  late TextEditingController _minimumWithdrawalController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _descriptionController = TextEditingController();
    _operationalHoursController = TextEditingController();
    _minimumWithdrawalController = TextEditingController();
    _loadCompany();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _descriptionController.dispose();
    _operationalHoursController.dispose();
    _minimumWithdrawalController.dispose();
    super.dispose();
  }

  Future<void> _loadCompany() async {
    setState(() => _isLoading = true);

    try {
      final company = await JsonService.instance.loadCompany();
      setState(() {
        _company = company;
        _nameController.text = company.name;
        _addressController.text = company.address;
        _phoneController.text = company.phone;
        _emailController.text = company.email;
        _descriptionController.text = company.description;
        _operationalHoursController.text = company.operationalHours;
        _minimumWithdrawalController.text = company.minimumWithdrawal
            .toInt()
            .toString();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil perusahaan berhasil diperbarui'),
        backgroundColor: AppColors.success,
      ),
    );

    _loadCompany();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Perusahaan'),
        actions: [
          if (!_isEditing && !_isLoading)
            IconButton(
              onPressed: () {
                setState(() => _isEditing = true);
              },
              icon: const Icon(Icons.edit),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo placeholder
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.business,
                            size: 60,
                            color: AppColors.primary,
                          ),
                        ),
                        if (_isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: AppColors.textOnPrimary,
                                size: 20,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  if (_isEditing) ...[
                    // Edit mode
                    CustomTextField(
                      label: 'Nama Perusahaan',
                      controller: _nameController,
                      prefixIcon: Icons.business,
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      label: 'Alamat',
                      controller: _addressController,
                      prefixIcon: Icons.location_on_outlined,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    PhoneTextField(
                      label: 'No. Telepon',
                      controller: _phoneController,
                    ),
                    const SizedBox(height: 16),

                    EmailTextField(
                      label: 'Email',
                      controller: _emailController,
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      label: 'Deskripsi',
                      controller: _descriptionController,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      label: 'Jam Operasional',
                      controller: _operationalHoursController,
                      prefixIcon: Icons.access_time,
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      label: 'Minimum Pencairan (Rp)',
                      controller: _minimumWithdrawalController,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.payments,
                    ),

                    const SizedBox(height: 32),

                    Row(
                      children: [
                        Expanded(
                          child: OutlineButton(
                            text: 'Batal',
                            onPressed: () {
                              setState(() => _isEditing = false);
                              _loadCompany();
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: PrimaryButton(
                            text: 'Simpan',
                            onPressed: _saveChanges,
                            isLoading: _isLoading,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    // View mode
                    InfoCard(
                      icon: Icons.business,
                      iconColor: AppColors.primary,
                      title: 'Nama Perusahaan',
                      value: _company!.name,
                    ),

                    InfoCard(
                      icon: Icons.location_on_outlined,
                      iconColor: AppColors.error,
                      title: 'Alamat',
                      value: _company!.address,
                    ),

                    InfoCard(
                      icon: Icons.phone,
                      iconColor: AppColors.secondary,
                      title: 'No. Telepon',
                      value: _company!.phone,
                    ),

                    InfoCard(
                      icon: Icons.email,
                      iconColor: AppColors.accent,
                      title: 'Email',
                      value: _company!.email,
                    ),

                    InfoCard(
                      icon: Icons.description,
                      iconColor: AppColors.info,
                      title: 'Deskripsi',
                      value: _company!.description,
                    ),

                    InfoCard(
                      icon: Icons.access_time,
                      iconColor: AppColors.warning,
                      title: 'Jam Operasional',
                      value: _company!.operationalHours,
                    ),

                    InfoCard(
                      icon: Icons.payments,
                      iconColor: AppColors.success,
                      title: 'Minimum Pencairan',
                      value: 'Rp ${_company!.minimumWithdrawal.toInt()}',
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
