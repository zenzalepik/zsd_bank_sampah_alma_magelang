import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_text.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../data/models/company.dart';
import '../../../data/services/firestore_service.dart';

class CompanyProfileScreen extends StatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  bool _isEditing = false;
  bool _isLoading = false;

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

  void _populateControllers(Company company) {
    _nameController.text = company.name;
    _addressController.text = company.address;
    _phoneController.text = company.phone;
    _emailController.text = company.email;
    _descriptionController.text = company.description;
    _operationalHoursController.text = company.operationalHours;
    _minimumWithdrawalController.text = company.minimumWithdrawal
        .toInt()
        .toString();
  }

  Future<void> _saveChanges(String? currentId) async {
    setState(() => _isLoading = true);

    try {
      final company = Company(
        id: currentId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        address: _addressController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        logoUrl: 'assets/images/logo_placeholder.png', // Placeholder
        description: _descriptionController.text,
        operationalHours: _operationalHoursController.text,
        minimumWithdrawal:
            double.tryParse(_minimumWithdrawalController.text) ?? 0.0,
      );

      await FirestoreService.instance.updateCompany(company);

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
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Company?>(
      stream: FirestoreService.instance.getCompanyStream(),
      builder: (context, snapshot) {
        final company = snapshot.data;

        // If we have data and not editing, or if we just started editing,
        // we might want to populate controllers.
        // But we shouldn't populate if user is already typing.
        // So only populate when entering edit mode?
        // Handled in onPressed of Edit button.

        return Scaffold(
          appBar: AppBar(
            title: const Text('Profil Perusahaan'),
            actions: [
              if (!_isEditing && !_isLoading && company != null)
                IconButton(
                  onPressed: () {
                    _populateControllers(company);
                    setState(() => _isEditing = true);
                  },
                  icon: const Icon(Icons.edit),
                ),
            ],
          ),
          body: snapshot.connectionState == ConnectionState.waiting
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

                      if (_isEditing || company == null) ...[
                        // Edit mode or Create mode (if no data)
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
                            if (company != null) ...[
                              Expanded(
                                child: OutlineButton(
                                  text: 'Batal',
                                  onPressed: () {
                                    setState(() => _isEditing = false);
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                            Expanded(
                              child: PrimaryButton(
                                text: 'Simpan',
                                onPressed: () => _saveChanges(company?.id),
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
                          value: company.name,
                        ),

                        InfoCard(
                          icon: Icons.location_on_outlined,
                          iconColor: AppColors.error,
                          title: 'Alamat',
                          value: company.address,
                        ),

                        InfoCard(
                          icon: Icons.phone,
                          iconColor: AppColors.secondary,
                          title: 'No. Telepon',
                          value: company.phone,
                        ),

                        InfoCard(
                          icon: Icons.email,
                          iconColor: AppColors.accent,
                          title: 'Email',
                          value: company.email,
                        ),

                        InfoCard(
                          icon: Icons.description,
                          iconColor: AppColors.info,
                          title: 'Deskripsi',
                          value: company.description,
                        ),

                        InfoCard(
                          icon: Icons.access_time,
                          iconColor: AppColors.warning,
                          title: 'Jam Operasional',
                          value: company.operationalHours,
                        ),

                        InfoCard(
                          icon: Icons.payments,
                          iconColor: AppColors.success,
                          title: 'Minimum Pencairan',
                          value: 'Rp ${company.minimumWithdrawal.toInt()}',
                        ),
                      ],
                    ],
                  ),
                ),
        );
      },
    );
  }
}
