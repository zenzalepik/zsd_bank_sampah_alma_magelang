import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_text.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../data/models/category.dart';
import '../../../data/services/firestore_service.dart';

import 'add_category_screen.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kategori Sampah')),
      body: StreamBuilder<List<Category>>(
        stream: FirestoreService.instance.getCategoriesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final categories = snapshot.data ?? [];

          if (categories.isEmpty) {
            return const EmptyStateCard(
              icon: Icons.category_outlined,
              title: 'Tidak Ada Kategori',
              message: 'Belum ada kategori sampah tersedia',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return _buildCategoryCard(category);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddCategoryScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Kategori'),
      ),
    );
  }

  Widget _buildCategoryCard(Category category) {
    return CustomCard(
      child: Row(
        children: [
          // Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                category.iconUrl,
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BodyText(category.name, fontWeight: FontWeight.w600),
                const SizedBox(height: 4),
                CaptionText(
                  category.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const CaptionText('Harga'),
              const SizedBox(height: 4),
              PriceText(category.pricePerKg, size: 'small', prefix: 'Rp '),
              const CaptionText('/ kg'),
            ],
          ),

          const SizedBox(width: 8),

          // Edit button
          IconButton(
            onPressed: () {
              _showEditDialog(category);
            },
            icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Category category) {
    final priceController = TextEditingController(
      text: category.pricePerKg.toInt().toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Harga'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BodyText(category.name, fontWeight: FontWeight.w600),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Harga per kg (Rp)',
                border: OutlineInputBorder(),
              ),
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
                final newPrice = double.parse(priceController.text);
                final updatedCategory = Category(
                  id: category.id,
                  name: category.name,
                  iconUrl: category.iconUrl,
                  pricePerKg: newPrice,
                  description: category.description,
                );

                await FirestoreService.instance.updateCategory(updatedCategory);

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Harga berhasil diupdate'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gagal update: $e'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
