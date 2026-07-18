import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../catalog/domain/entities/gym.dart';
import '../../providers/partner_provider.dart';

class PartnerSettingsSubpage extends StatefulWidget {
  final PartnerProvider provider;

  const PartnerSettingsSubpage({super.key, required this.provider});

  @override
  State<PartnerSettingsSubpage> createState() => _PartnerSettingsSubpageState();
}

class _PartnerSettingsSubpageState extends State<PartnerSettingsSubpage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _descController = TextEditingController();
  final _thumbController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _descController.dispose();
    _thumbController.dispose();
    super.dispose();
  }

  void _showEditGymDialog(BuildContext context, Gym gym) {
    _nameController.text = gym.name;
    _phoneController.text = gym.phoneNumber ?? '';
    _emailController.text = gym.email ?? '';
    _descController.text = gym.description ?? '';
    _thumbController.text = gym.thumbnailUrl ?? '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppConstants.surfaceColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                side: const BorderSide(color: AppConstants.borderColor),
              ),
              title: const Text(
                'Cập nhật phòng gym',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Tên phòng gym *'),
                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: _buildInput('Ví dụ: FlexFit Central'),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Nhập tên phòng gym' : null,
                        ),
                        const SizedBox(height: 12),

                        _buildLabel('Số điện thoại *'),
                        TextFormField(
                          controller: _phoneController,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          keyboardType: TextInputType.phone,
                          decoration: _buildInput('Ví dụ: 0909999999'),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Nhập số điện thoại' : null,
                        ),
                        const SizedBox(height: 12),

                        _buildLabel('Email *'),
                        TextFormField(
                          controller: _emailController,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          keyboardType: TextInputType.emailAddress,
                          decoration: _buildInput('Ví dụ: contact@flexfit.io'),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Nhập email';
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim())) {
                              return 'Email không hợp lệ';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        _buildLabel('Link hình ảnh nền (Thumbnail URL)'),
                        TextFormField(
                          controller: _thumbController,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: _buildInput('URL hình ảnh...'),
                        ),
                        const SizedBox(height: 12),

                        _buildLabel('Mô tả phòng gym'),
                        TextFormField(
                          controller: _descController,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          maxLines: 3,
                          decoration: _buildInput('Mô tả chi tiết, tiện ích...'),
                        ),
                      ],
                    ),
                  ),
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

                    final body = {
                      'gymName': _nameController.text.trim(),
                      'description': _descController.text.trim(),
                      'thumbnailUrl': _thumbController.text.trim(),
                      'phoneNumber': _phoneController.text.trim(),
                      'email': _emailController.text.trim(),
                    };

                    try {
                      await widget.provider.updateGym(gym.id, body);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cập nhật phòng gym thành công'),
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
                  child: const Text('Cập nhật', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
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
      fillColor: AppConstants.backgroundColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppConstants.borderColor)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppConstants.primaryColor)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;
    final gyms = provider.gyms;
    final branches = provider.branches;
    final classes = provider.classes;
    final customers = provider.customers;

    return RefreshIndicator(
      color: AppConstants.primaryColor,
      onRefresh: () => provider.fetchAllData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cài đặt đối tác',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 4),
            const Text(
              'Quản lý thông tin hệ thống, phòng gym thương hiệu của bạn.',
              style: TextStyle(fontSize: 13, color: AppConstants.textSecondary),
            ),
            const SizedBox(height: 20),

            // Statistics Grid (System Management)
            const Text(
              'Quản lý hệ thống',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                _buildStatCard('Tổng số cơ sở', gyms.length.toString(), Icons.business),
                _buildStatCard('Tổng số chi nhánh', branches.length.toString(), Icons.storefront),
                _buildStatCard('Tổng số lớp học', classes.length.toString(), Icons.calendar_today),
                _buildStatCard('Tổng số hội viên', customers.length.toString(), Icons.people),
              ],
            ),

            const SizedBox(height: 28),

            // Gym details Editor
            const Text(
              'Thông tin phòng gym',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),

            if (provider.isLoadingGyms && gyms.isEmpty)
              const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor))
            else if (gyms.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppConstants.surfaceColor,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
                child: const Center(
                  child: Text('Chưa có thông tin phòng gym để cập nhật', style: TextStyle(color: AppConstants.textSecondary)),
                ),
              )
            else
              ...gyms.map((gym) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppConstants.surfaceColor,
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    border: Border.all(color: AppConstants.borderColor.withOpacity(0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Gym Name and Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              gym.name,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Approved',
                              style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Image preview
                      if (gym.thumbnailUrl != null && gym.thumbnailUrl!.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: double.infinity,
                            height: 130,
                            child: Image.network(
                              gym.thumbnailUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: AppConstants.cardColor,
                                child: const Icon(Icons.fitness_center, color: AppConstants.textSecondary),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),

                      Text(
                        gym.description ?? 'FlexFit Gym mang lại môi trường tập luyện thể hình chuyên nghiệp hàng đầu.',
                        style: const TextStyle(fontSize: 12, color: AppConstants.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: AppConstants.borderColor),
                      const SizedBox(height: 10),

                      _buildInfoRow(Icons.phone, gym.phoneNumber ?? 'N/A'),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.mail_outline, gym.email ?? 'N/A'),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.star_outline, '${gym.ratingAverage.toStringAsFixed(1)} (${gym.totalReviews} đánh giá)'),

                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.primaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => _showEditGymDialog(context, gym),
                          icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                          label: const Text('Chỉnh sửa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppConstants.borderColor.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
            radius: 18,
            child: Icon(icon, color: AppConstants.primaryColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(fontSize: 10, color: AppConstants.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String val) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppConstants.primaryColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            val,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
