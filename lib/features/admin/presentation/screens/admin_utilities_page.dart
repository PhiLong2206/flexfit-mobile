import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../catalog/domain/entities/category.dart';
import '../../../membership/data/models/credit_package_model.dart';
import '../providers/admin_utilities_provider.dart';
import '../widgets/admin_ui.dart';

class AdminUtilitiesPage extends StatelessWidget {
  const AdminUtilitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminUtilitiesProvider>();
    if (provider.isLoading && provider.data == null) {
      return const AdminLoadingState(rows: 5);
    }
    if (provider.errorMessage != null && provider.data == null) {
      return AdminErrorState(
        message: provider.errorMessage!,
        onRetry: provider.load,
      );
    }

    final data = provider.data;
    final categories = provider.filteredCategories;
    final packages = provider.filteredCreditPackages;
    return RefreshIndicator(
      onRefresh: provider.refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
        children: [
          AdminPageHeader(
            title: 'Tiện ích',
            subtitle:
                'Backend không có Amenity API, nên dùng danh mục và gói Credit.',
            trailing: AdminStatusPill(
              label: provider.isMutating ? 'Đang xử lý' : 'CRUD API',
            ),
          ),
          const SizedBox(height: 18),
          AdminSearchField(
            hintText: 'Tìm danh mục hoặc gói Credit',
            onChanged: provider.setQuery,
          ),
          const SizedBox(height: 20),
          if (data == null ||
              (data.categories.isEmpty && data.creditPackages.isEmpty))
            const AdminEmptyState(
              icon: Icons.extension_outlined,
              message: 'Backend chưa có dữ liệu tiện ích phù hợp để hiển thị.',
            )
          else ...[
            AdminPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: AdminSectionTitle(
                          'Danh mục lớp học',
                          Icons.category_rounded,
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: provider.isMutating
                            ? null
                            : () => _showCategoryDialog(context),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Thêm'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (categories.isEmpty)
                    const Text(
                      'Không có danh mục phù hợp.',
                      style: TextStyle(color: AdminColors.muted),
                    )
                  else
                    ...categories.map(
                      (category) => _CategoryRow(category: category),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            AdminPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: AdminSectionTitle(
                          'Gói Credit',
                          Icons.wallet_rounded,
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: provider.isMutating
                            ? null
                            : () => _showCreditPackageDialog(context),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Thêm'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (packages.isEmpty)
                    const Text(
                      'Không có gói Credit phù hợp hoặc API chưa sẵn sàng.',
                      style: TextStyle(color: AdminColors.muted),
                    )
                  else
                    ...packages.map(
                      (package) => _CreditPackageRow(package: package),
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

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.category});

  final Category category;

  @override
  Widget build(BuildContext context) {
    return _ActionRow(
      title: category.name,
      subtitle: category.description ?? 'Không có mô tả',
      icon: Icons.label_rounded,
      onEdit: () => _showCategoryDialog(context, category: category),
      onDelete: () => _confirmAndRun(
        context,
        title: 'Xóa danh mục?',
        message: 'Danh mục ${category.name} sẽ bị xóa.',
        successMessage: 'Đã xóa danh mục.',
        action: () =>
            context.read<AdminUtilitiesProvider>().deleteCategory(category.id),
      ),
    );
  }
}

class _CreditPackageRow extends StatelessWidget {
  const _CreditPackageRow({required this.package});

  final CreditPackageModel package;

  @override
  Widget build(BuildContext context) {
    return _ActionRow(
      title: package.name,
      subtitle:
          '${package.totalCredit} credit • ${formatMoney(package.price)} • ${package.isActive ? 'Hoạt động' : 'Tạm dừng'}',
      icon: Icons.toll_rounded,
      trailing: AdminStatusPill(
        label: package.isActive ? 'Hoạt động' : 'Tạm dừng',
        color: package.isActive ? AdminColors.success : AdminColors.warning,
      ),
      onEdit: () => _showCreditPackageDialog(context, package: package),
      onDelete: () => _confirmAndRun(
        context,
        title: 'Xóa gói Credit?',
        message: 'Gói ${package.name} sẽ bị xóa.',
        successMessage: 'Đã xóa gói Credit.',
        action: () => context
            .read<AdminUtilitiesProvider>()
            .deleteCreditPackage(package.id),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onEdit,
    required this.onDelete,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AdminColors.subtle),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AdminColors.muted,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
          IconButton(
            tooltip: 'Sửa',
            onPressed: onEdit,
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
            icon: const Icon(Icons.edit_rounded),
          ),
          IconButton(
            tooltip: 'Xóa',
            onPressed: onDelete,
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
            icon: const Icon(Icons.delete_rounded, color: AdminColors.danger),
          ),
        ],
      ),
    );
  }
}

Future<void> _showCategoryDialog(
  BuildContext context, {
  Category? category,
}) async {
  final nameController = TextEditingController(text: category?.name ?? '');
  final descriptionController = TextEditingController(
    text: category?.description ?? '',
  );
  String? error;
  final editing = category != null;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(editing ? 'Sửa danh mục' : 'Thêm danh mục'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Tên danh mục'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Mô tả'),
            ),
            if (error != null) ...[
              const SizedBox(height: 12),
              Text(error!, style: const TextStyle(color: AdminColors.danger)),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                setState(() => error = 'Tên danh mục không được để trống.');
                return;
              }
              try {
                final provider = context.read<AdminUtilitiesProvider>();
                if (editing) {
                  await provider.updateCategory(
                    categoryId: category.id,
                    categoryName: nameController.text.trim(),
                    description: descriptionController.text.trim(),
                  );
                } else {
                  await provider.createCategory(
                    categoryName: nameController.text.trim(),
                    description: descriptionController.text.trim(),
                  );
                }
                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();
                _showSnack(
                  context,
                  editing ? 'Đã cập nhật danh mục.' : 'Đã thêm danh mục.',
                );
              } catch (e) {
                setState(() => error = e.toString());
                _showSnack(context, e.toString(), isError: true);
              }
            },
            child: Text(editing ? 'Lưu' : 'Thêm'),
          ),
        ],
      ),
    ),
  );

  nameController.dispose();
  descriptionController.dispose();
}

Future<void> _showCreditPackageDialog(
  BuildContext context, {
  CreditPackageModel? package,
}) async {
  final nameController = TextEditingController(text: package?.name ?? '');
  final creditController = TextEditingController(
    text: package?.creditAmount.toString() ?? '',
  );
  final priceController = TextEditingController(
    text: package?.price.toStringAsFixed(0) ?? '',
  );
  final descriptionController = TextEditingController(
    text: package?.description ?? '',
  );
  String? error;
  final editing = package != null;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(editing ? 'Sửa gói Credit' : 'Thêm gói Credit'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Tên gói'),
              ),
              TextField(
                controller: creditController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Credit'),
              ),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Giá'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Mô tả'),
              ),
              if (error != null) ...[
                const SizedBox(height: 12),
                Text(error!, style: const TextStyle(color: AdminColors.danger)),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () async {
              final credit = int.tryParse(creditController.text.trim());
              final price = double.tryParse(priceController.text.trim());
              if (nameController.text.trim().isEmpty ||
                  credit == null ||
                  price == null) {
                setState(
                  () => error = 'Vui lòng nhập tên, credit và giá hợp lệ.',
                );
                return;
              }
              try {
                final provider = context.read<AdminUtilitiesProvider>();
                if (editing) {
                  await provider.updateCreditPackage(
                    packageId: package.id,
                    packageName: nameController.text.trim(),
                    creditAmount: credit,
                    price: price,
                    description: descriptionController.text.trim(),
                  );
                } else {
                  await provider.createCreditPackage(
                    packageName: nameController.text.trim(),
                    creditAmount: credit,
                    price: price,
                    description: descriptionController.text.trim(),
                  );
                }
                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();
                _showSnack(
                  context,
                  editing ? 'Đã cập nhật gói Credit.' : 'Đã thêm gói Credit.',
                );
              } catch (e) {
                setState(() => error = e.toString());
                _showSnack(context, e.toString(), isError: true);
              }
            },
            child: Text(editing ? 'Lưu' : 'Thêm'),
          ),
        ],
      ),
    ),
  );

  nameController.dispose();
  creditController.dispose();
  priceController.dispose();
  descriptionController.dispose();
}

Future<void> _confirmAndRun(
  BuildContext context, {
  required String title,
  required String message,
  required String successMessage,
  required Future<void> Function() action,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Xác nhận'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;
  try {
    await action();
    if (!context.mounted) return;
    _showSnack(context, successMessage);
  } catch (e) {
    if (!context.mounted) return;
    _showSnack(context, e.toString(), isError: true);
  }
}

void _showSnack(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? AdminColors.danger : AdminColors.success,
    ),
  );
}
