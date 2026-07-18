import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../catalog/domain/entities/branch.dart';
import '../../../../catalog/domain/entities/gym.dart';
import '../../providers/partner_provider.dart';

class PartnerBranchesSubpage extends StatefulWidget {
  final PartnerProvider provider;

  const PartnerBranchesSubpage({super.key, required this.provider});

  @override
  State<PartnerBranchesSubpage> createState() => _PartnerBranchesSubpageState();
}

class _PartnerBranchesSubpageState extends State<PartnerBranchesSubpage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _districtController = TextEditingController();
  final _cityController = TextEditingController();
  final _openTimeController = TextEditingController(text: '06:00');
  final _closeTimeController = TextEditingController(text: '22:00');
  final _creditCostController = TextEditingController(text: '10');
  final _thumbnailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _districtController.dispose();
    _cityController.dispose();
    _openTimeController.dispose();
    _closeTimeController.dispose();
    _creditCostController.dispose();
    _thumbnailController.dispose();
    super.dispose();
  }

  void _showBranchFormBottomSheet(BuildContext context, {Branch? branch}) {
    final isEdit = branch != null;

    if (isEdit) {
      _nameController.text = branch.name;
      _addressController.text = branch.address ?? '';
      _districtController.text = branch.district ?? '';
      _cityController.text = branch.city ?? '';
      _openTimeController.text = branch.openTime ?? '06:00';
      _closeTimeController.text = branch.closeTime ?? '22:00';
      _creditCostController.text = branch.creditCost.toString();
      _thumbnailController.text = branch.thumbnailUrl ?? '';
    } else {
      _nameController.clear();
      _addressController.clear();
      _districtController.clear();
      _cityController.clear();
      _openTimeController.text = '06:00';
      _closeTimeController.text = '22:00';
      _creditCostController.text = '10';
      _thumbnailController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final kb = MediaQuery.of(ctx).viewInsets.bottom;
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.8,
          margin: EdgeInsets.only(bottom: kb),
          decoration: const BoxDecoration(
            color: AppConstants.backgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(2)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  isEdit ? 'Chỉnh sửa chi nhánh' : 'Thêm chi nhánh mới',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const Divider(color: AppConstants.borderColor),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Tên chi nhánh *'),
                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: _buildInput('VD: FlexFit Quận 9'),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Nhập tên chi nhánh' : null,
                        ),
                        const SizedBox(height: 12),

                        _buildLabel('Địa chỉ *'),
                        TextFormField(
                          controller: _addressController,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: _buildInput('Số nhà, tên đường...'),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Nhập địa chỉ' : null,
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('Quận / Huyện *'),
                                  TextFormField(
                                    controller: _districtController,
                                    style: const TextStyle(color: Colors.white, fontSize: 13),
                                    decoration: _buildInput('VD: Thủ Đức'),
                                    validator: (v) => v == null || v.trim().isEmpty ? 'Nhập quận/huyện' : null,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('Thành phố *'),
                                  TextFormField(
                                    controller: _cityController,
                                    style: const TextStyle(color: Colors.white, fontSize: 13),
                                    decoration: _buildInput('VD: TP. Hồ Chí Minh'),
                                    validator: (v) => v == null || v.trim().isEmpty ? 'Nhập thành phố' : null,
                                  ),
                                ],
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
                                  _buildLabel('Giờ mở cửa *'),
                                  TextFormField(
                                    controller: _openTimeController,
                                    style: const TextStyle(color: Colors.white, fontSize: 13),
                                    decoration: _buildInput('06:00'),
                                    validator: (v) => v == null || v.trim().isEmpty ? 'Nhập giờ mở cửa' : null,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('Giờ đóng cửa *'),
                                  TextFormField(
                                    controller: _closeTimeController,
                                    style: const TextStyle(color: Colors.white, fontSize: 13),
                                    decoration: _buildInput('22:00'),
                                    validator: (v) => v == null || v.trim().isEmpty ? 'Nhập giờ đóng cửa' : null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        _buildLabel('Giá Credits mỗi giờ *'),
                        TextFormField(
                          controller: _creditCostController,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          keyboardType: TextInputType.number,
                          decoration: _buildInput('10'),
                          validator: (v) {
                            final p = int.tryParse(v ?? '');
                            if (p == null || p <= 0) return 'Nhập số lớn hơn 0';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        _buildLabel('Link ảnh chi nhánh (Thumbnail URL)'),
                        TextFormField(
                          controller: _thumbnailController,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: _buildInput('https://...'),
                        ),
                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.primaryColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () async {
                              if (!_formKey.currentState!.validate()) return;
                              Navigator.of(ctx).pop();

                              final body = {
                                'branchName': _nameController.text.trim(),
                                'address': _addressController.text.trim(),
                                'district': _districtController.text.trim(),
                                'city': _cityController.text.trim(),
                                'openTime': _openTimeController.text.trim(),
                                'closeTime': _closeTimeController.text.trim(),
                                'creditCost': int.tryParse(_creditCostController.text) ?? 10,
                                'thumbnailUrl': _thumbnailController.text.trim(),
                              };

                              try {
                                if (isEdit) {
                                  await widget.provider.updateBranch(branch.id, body);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Cập nhật chi nhánh thành công'), backgroundColor: Colors.green),
                                    );
                                  }
                                } else {
                                  if (widget.provider.gyms.isEmpty) {
                                    throw Exception('Chưa có thông tin cơ sở gym. Vui lòng cập nhật trong phần Cài đặt trước.');
                                  }
                                  body['gymId'] = widget.provider.gyms.first.id;
                                  await widget.provider.createBranch(body);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Thêm chi nhánh mới thành công'), backgroundColor: Colors.green),
                                    );
                                  }
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Lỗi: ${e.toString()}'), backgroundColor: Colors.red),
                                  );
                                }
                              }
                            },
                            child: Text(isEdit ? 'Lưu thay đổi' : 'Thêm mới', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, Branch branch) {
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
            'Xóa chi nhánh',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          content: Text(
            'Bạn có chắc chắn muốn xóa chi nhánh "${branch.name}"? Lớp học và nhân viên liên quan sẽ bị ảnh hưởng.',
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
                  await widget.provider.deleteBranch(branch.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã xóa chi nhánh thành công'), backgroundColor: Colors.green),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi: ${e.toString()}'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: const Text('Xác nhận', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppConstants.textSecondary)),
    );
  }

  InputDecoration _buildInput(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
      filled: true,
      fillColor: AppConstants.surfaceColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppConstants.borderColor)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppConstants.primaryColor)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppConstants.primaryColor,
        onPressed: () => _showBranchFormBottomSheet(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: RefreshIndicator(
        color: AppConstants.primaryColor,
        onRefresh: () => provider.fetchAllData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Danh sách cơ sở & chi nhánh',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 4),
              const Text(
                'Quản lý danh sách phòng tập và chi nhánh hoạt động hiện tại của bạn.',
                style: TextStyle(fontSize: 13, color: AppConstants.textSecondary),
              ),
              const SizedBox(height: 20),

              // Gyms Section
              const Text(
                'Phòng tập (Gyms)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 10),
              _buildGymsList(provider.gyms, provider.isLoadingGyms),

              const SizedBox(height: 24),

              // Branches Section
              const Text(
                'Chi nhánh (Branches)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 10),
              _buildBranchesList(provider.branches, provider.isLoadingBranches),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGymsList(List<Gym> gyms, bool isLoading) {
    if (isLoading && gyms.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(color: AppConstants.primaryColor),
        ),
      );
    }

    if (gyms.isEmpty) {
      return _buildEmptyState('Chưa có thông tin phòng tập');
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: gyms.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final gym = gyms[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppConstants.surfaceColor,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            border: Border.all(color: AppConstants.borderColor.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: gym.thumbnailUrl != null && gym.thumbnailUrl!.isNotEmpty
                    ? Image.network(gym.thumbnailUrl!, width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _fallbackGymImage())
                    : _fallbackGymImage(),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gym.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      gym.description ?? 'Phòng tập thể hình cao cấp FlexFit',
                      style: const TextStyle(fontSize: 12, color: AppConstants.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _fallbackGymImage() {
    return Container(
      width: 50,
      height: 50,
      color: AppConstants.cardColor,
      child: const Icon(Icons.fitness_center, color: Colors.white54),
    );
  }

  Widget _buildBranchesList(List<Branch> branches, bool isLoading) {
    if (isLoading && branches.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(color: AppConstants.primaryColor),
        ),
      );
    }

    if (branches.isEmpty) {
      return _buildEmptyState('Không có chi nhánh nào hoạt động');
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: branches.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final branch = branches[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppConstants.surfaceColor,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            border: Border.all(color: AppConstants.borderColor.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.greenAccent, blurRadius: 4, spreadRadius: 1)
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      branch.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 10, color: AppConstants.primaryColor),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${branch.address}, ${branch.district}',
                            style: const TextStyle(fontSize: 10, color: AppConstants.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent, size: 18),
                    onPressed: () => _showBranchFormBottomSheet(context, branch: branch),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                    onPressed: () => _showDeleteConfirmDialog(context, branch),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: AppConstants.borderColor.withOpacity(0.5)),
      ),
      child: Center(
        child: Text(message, style: const TextStyle(color: AppConstants.textSecondary)),
      ),
    );
  }
}

