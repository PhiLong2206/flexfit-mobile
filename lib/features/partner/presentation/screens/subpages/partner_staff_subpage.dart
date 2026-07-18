import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../catalog/domain/entities/branch.dart';
import '../../providers/partner_provider.dart';

class PartnerStaffSubpage extends StatefulWidget {
  final PartnerProvider provider;

  const PartnerStaffSubpage({super.key, required this.provider});

  @override
  State<PartnerStaffSubpage> createState() => _PartnerStaffSubpageState();
}

class _PartnerStaffSubpageState extends State<PartnerStaffSubpage> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _showAddStaffDialog(BuildContext context, Branch branch) {
    _emailController.clear();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppConstants.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            side: const BorderSide(color: AppConstants.borderColor),
          ),
          title: Text(
            'Thêm nhân viên vào ${branch.name}',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
          ),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nhập email tài khoản nhân viên đã đăng ký để gán vào chi nhánh này.',
                  style: TextStyle(color: AppConstants.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'staff@example.com',
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                    filled: true,
                    fillColor: AppConstants.backgroundColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppConstants.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppConstants.primaryColor),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Vui lòng nhập email';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim())) {
                      return 'Email không hợp lệ';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                Navigator.of(ctx).pop();

                try {
                  await widget.provider.assignStaff(branch.id, _emailController.text.trim());
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã gán nhân viên thành công'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Lỗi: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Thêm', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showRemoveConfirmDialog(BuildContext context, Branch branch, String staffId, String staffName) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppConstants.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            side: const BorderSide(color: AppConstants.borderColor),
          ),
          title: const Text(
            'Gỡ nhân viên',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          content: Text(
            'Bạn có chắc chắn muốn gỡ nhân viên "$staffName" khỏi chi nhánh "${branch.name}"?',
            style: const TextStyle(color: AppConstants.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                Navigator.of(ctx).pop();

                try {
                  await widget.provider.removeStaff(branch.id, staffId);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã gỡ nhân viên thành công'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Lỗi: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Gỡ', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final branches = widget.provider.branches;

    return RefreshIndicator(
      color: AppConstants.primaryColor,
      onRefresh: () => widget.provider.fetchBranches(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Danh sách nhân viên',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 4),
            const Text(
              'Quản lý phân quyền và gán nhân viên phụ trách cho từng chi nhánh.',
              style: TextStyle(fontSize: 13, color: AppConstants.textSecondary),
            ),
            const SizedBox(height: 20),

            if (widget.provider.isLoadingBranches && branches.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: AppConstants.primaryColor),
                ),
              )
            else if (branches.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: AppConstants.surfaceColor,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
                child: const Center(
                  child: Text(
                    'Không có chi nhánh nào để quản lý nhân viên.',
                    style: TextStyle(color: AppConstants.textSecondary),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: branches.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, idx) {
                  final branch = branches[idx];
                  // In branch.dart, staffs may be parsed as List of maps or objects. Let's make sure we safely parse it.
                  final List staffs = (branch as dynamic).staffs ?? [];

                  return Container(
                    decoration: BoxDecoration(
                      color: AppConstants.surfaceColor,
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                      border: Border.all(color: AppConstants.borderColor.withOpacity(0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppConstants.borderRadius)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.storefront, color: AppConstants.primaryColor, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  branch.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppConstants.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${staffs.length} nhân sự',
                                  style: const TextStyle(color: AppConstants.primaryColor, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Body - Staff List
                        if (staffs.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.people_outline, color: Colors.grey, size: 32),
                                  SizedBox(height: 8),
                                  Text(
                                    'Chưa có nhân viên nào tại chi nhánh này',
                                    style: TextStyle(color: AppConstants.textSecondary, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: staffs.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 8),
                              itemBuilder: (context, sIdx) {
                                final staff = staffs[sIdx];
                                final staffId = (staff['staffId'] ?? staff['userId'] ?? '').toString();
                                final staffName = (staff['fullName'] ?? staff['name'] ?? 'Nhân viên').toString();

                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppConstants.backgroundColor.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppConstants.borderColor.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 14,
                                        backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                                        child: Text(
                                          staffName.isNotEmpty ? staffName[0].toUpperCase() : 'S',
                                          style: const TextStyle(color: AppConstants.primaryColor, fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          staffName,
                                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                                        onPressed: () => _showRemoveConfirmDialog(context, branch, staffId, staffName),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),

                        // Footer Action
                        Padding(
                          padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                                foregroundColor: AppConstants.primaryColor,
                                side: BorderSide(color: AppConstants.primaryColor.withOpacity(0.3)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                              onPressed: () => _showAddStaffDialog(context, branch),
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Thêm nhân viên', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
