import 'dart:io';

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/widgets/image_picker_field.dart';
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
                'Quản lý phòng tập và chi nhánh hoạt động của bạn.',
                style: TextStyle(fontSize: 13, color: AppConstants.textSecondary),
              ),
              const SizedBox(height: 20),

              // Gyms
              const Text('Phòng tập (Gyms)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 10),
              _buildGymsList(provider.gyms, provider.isLoadingGyms),

              const SizedBox(height: 24),

              // Branches
              const Text('Chi nhánh (Branches)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 10),
              _buildBranchesList(provider.branches, provider.isLoadingBranches),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────── GYM LIST ───────────────
  Widget _buildGymsList(List<Gym> gyms, bool isLoading) {
    if (isLoading && gyms.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: AppConstants.primaryColor)));
    }
    if (gyms.isEmpty) return _emptyState('Chưa có thông tin phòng tập');

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: gyms.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final gym = gyms[i];
        return Container(
          decoration: BoxDecoration(
            color: AppConstants.surfaceColor,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            border: Border.all(color: AppConstants.borderColor.withOpacity(0.5)),
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail banner
              _thumbnailBanner(gym.thumbnailUrl, height: 130, fallbackIcon: Icons.fitness_center),
              // Info row
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(gym.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                          if (gym.description != null && gym.description!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(gym.description!,
                                  style: const TextStyle(fontSize: 11, color: AppConstants.textSecondary),
                                  maxLines: 2, overflow: TextOverflow.ellipsis),
                            ),
                          if (gym.email != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(children: [
                                const Icon(Icons.mail_outline, size: 11, color: AppConstants.textSecondary),
                                const SizedBox(width: 4),
                                Text(gym.email!, style: const TextStyle(fontSize: 11, color: AppConstants.textSecondary)),
                              ]),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        gym.status.isEmpty ? 'Active' : gym.status,
                        style: const TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
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

  // ─────────────── BRANCH LIST ───────────────
  Widget _buildBranchesList(List<Branch> branches, bool isLoading) {
    if (isLoading && branches.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: AppConstants.primaryColor)));
    }
    if (branches.isEmpty) return _emptyState('Không có chi nhánh nào hoạt động');

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: branches.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final branch = branches[i];
        return Container(
          decoration: BoxDecoration(
            color: AppConstants.surfaceColor,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            border: Border.all(color: AppConstants.borderColor.withOpacity(0.5)),
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail banner
              _thumbnailBanner(branch.thumbnailUrl, height: 110, fallbackIcon: Icons.storefront),
              // Info row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    // Status dot
                    Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(
                        color: branch.isActive ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                        boxShadow: branch.isActive
                            ? const [BoxShadow(color: Colors.greenAccent, blurRadius: 4, spreadRadius: 1)]
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(branch.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                          const SizedBox(height: 2),
                          Row(children: [
                            const Icon(Icons.location_on, size: 11, color: AppConstants.primaryColor),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${branch.address ?? ''}, ${branch.district ?? ''}',
                                style: const TextStyle(fontSize: 11, color: AppConstants.textSecondary),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ]),
                          if (branch.openTime != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Row(children: [
                                const Icon(Icons.access_time, size: 11, color: AppConstants.textSecondary),
                                const SizedBox(width: 4),
                                Text('${branch.openTime} – ${branch.closeTime}',
                                    style: const TextStyle(fontSize: 11, color: AppConstants.textSecondary)),
                                const SizedBox(width: 10),
                                const Icon(Icons.monetization_on, size: 11, color: Colors.amber),
                                const SizedBox(width: 3),
                                Text('${branch.creditCost} cr/h',
                                    style: const TextStyle(fontSize: 11, color: Colors.amber)),
                              ]),
                            ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent, size: 20),
                          onPressed: () => _showBranchFormBottomSheet(context, branch: branch),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                          onPressed: () => _showDeleteDialog(context, branch),
                        ),
                      ],
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

  // ─────────────── THUMBNAIL HELPER ───────────────
  Widget _thumbnailBanner(String? url, {required double height, required IconData fallbackIcon}) {
    if (url != null && url.isNotEmpty) {
      return SizedBox(
        height: height,
        width: double.infinity,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          loadingBuilder: (_, child, progress) =>
              progress == null ? child : SizedBox(height: height, child: const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor))),
          errorBuilder: (_, __, ___) => _fallbackBanner(height: height, icon: fallbackIcon),
        ),
      );
    }
    return _fallbackBanner(height: height, icon: fallbackIcon);
  }

  Widget _fallbackBanner({required double height, required IconData icon}) {
    return Container(
      width: double.infinity, height: height,
      color: AppConstants.cardColor,
      child: Center(child: Icon(icon, color: Colors.white24, size: 42)),
    );
  }

  // ─────────────── BOTTOM SHEET FORM ───────────────
  void _showBranchFormBottomSheet(BuildContext context, {Branch? branch}) {
    final isEdit = branch != null;
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: branch?.name ?? '');
    final addressCtrl = TextEditingController(text: branch?.address ?? '');
    final districtCtrl = TextEditingController(text: branch?.district ?? '');
    final cityCtrl = TextEditingController(text: branch?.city ?? '');
    final openCtrl = TextEditingController(text: branch?.openTime ?? '06:00');
    final closeCtrl = TextEditingController(text: branch?.closeTime ?? '22:00');
    final creditCtrl = TextEditingController(text: (branch?.creditCost ?? 10).toString());

    String? currentThumbnailUrl = branch?.thumbnailUrl;
    File? pickedImageFile;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheet) {
          final kb = MediaQuery.of(ctx).viewInsets.bottom;

          Future<void> submit() async {
            if (!formKey.currentState!.validate()) return;
            Navigator.of(ctx).pop();

            try {
              if (pickedImageFile != null) {
                // Gửi multipart khi có ảnh mới
                final fields = <String, String>{
                  'branchName': nameCtrl.text.trim(),
                  'address': addressCtrl.text.trim(),
                  'district': districtCtrl.text.trim(),
                  'city': cityCtrl.text.trim(),
                  'openTime': openCtrl.text.trim(),
                  'closeTime': closeCtrl.text.trim(),
                  'creditCost': creditCtrl.text.trim(),
                };
                if (isEdit) {
                  fields['isActive'] = branch.isActive.toString();
                  await widget.provider.partnerRepository.updateBranchWithImage(branch.id, fields, pickedImageFile!);
                } else {
                  if (widget.provider.gyms.isEmpty) throw Exception('Chưa có gym. Vui lòng thêm phòng gym trước.');
                  fields['gymId'] = widget.provider.gyms.first.id;
                  await widget.provider.partnerRepository.createBranchWithImage(fields, pickedImageFile!);
                }
                await widget.provider.fetchBranches();
              } else {
                // Gửi JSON thường khi không đổi ảnh
                final body = <String, dynamic>{
                  'branchName': nameCtrl.text.trim(),
                  'address': addressCtrl.text.trim(),
                  'district': districtCtrl.text.trim(),
                  'city': cityCtrl.text.trim(),
                  'openTime': openCtrl.text.trim(),
                  'closeTime': closeCtrl.text.trim(),
                  'creditCost': int.tryParse(creditCtrl.text) ?? 10,
                  if (currentThumbnailUrl != null) 'thumbnailUrl': currentThumbnailUrl,
                };
                if (isEdit) {
                  await widget.provider.updateBranch(branch.id, body);
                } else {
                  if (widget.provider.gyms.isEmpty) throw Exception('Chưa có gym.');
                  body['gymId'] = widget.provider.gyms.first.id;
                  await widget.provider.createBranch(body);
                }
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(isEdit ? 'Cập nhật chi nhánh thành công' : 'Thêm chi nhánh thành công'),
                  backgroundColor: Colors.green,
                ));
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
                );
              }
            }
          }

          return Container(
            height: MediaQuery.of(ctx).size.height * 0.92,
            margin: EdgeInsets.only(bottom: kb),
            decoration: const BoxDecoration(
              color: AppConstants.backgroundColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(2)),
                ),
                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEdit ? 'Chỉnh sửa chi nhánh' : 'Thêm chi nhánh mới',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.of(ctx).pop()),
                    ],
                  ),
                ),
                const Divider(color: AppConstants.borderColor),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image picker
                          _label('Hình ảnh chi nhánh'),
                          ImagePickerField(
                            currentUrl: currentThumbnailUrl,
                            pickedFile: pickedImageFile,
                            onFilePicked: (file) => setSheet(() => pickedImageFile = file),
                            onClear: () => setSheet(() {
                              pickedImageFile = null;
                              currentThumbnailUrl = null;
                            }),
                          ),
                          const SizedBox(height: 16),

                          _label('Tên chi nhánh *'),
                          TextFormField(
                            controller: nameCtrl,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            decoration: _input('VD: FlexFit Quận 9'),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Nhập tên chi nhánh' : null,
                          ),
                          const SizedBox(height: 12),

                          _label('Địa chỉ *'),
                          TextFormField(
                            controller: addressCtrl,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            decoration: _input('Số nhà, tên đường...'),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Nhập địa chỉ' : null,
                          ),
                          const SizedBox(height: 12),

                          Row(children: [
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              _label('Quận / Huyện *'),
                              TextFormField(
                                controller: districtCtrl,
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                                decoration: _input('VD: Thủ Đức'),
                                validator: (v) => v == null || v.trim().isEmpty ? 'Bắt buộc' : null,
                              ),
                            ])),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              _label('Thành phố *'),
                              TextFormField(
                                controller: cityCtrl,
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                                decoration: _input('TP. Hồ Chí Minh'),
                                validator: (v) => v == null || v.trim().isEmpty ? 'Bắt buộc' : null,
                              ),
                            ])),
                          ]),
                          const SizedBox(height: 12),

                          Row(children: [
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              _label('Giờ mở cửa *'),
                              TextFormField(
                                controller: openCtrl,
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                                decoration: _input('06:00'),
                                validator: (v) => v == null || v.trim().isEmpty ? 'Bắt buộc' : null,
                              ),
                            ])),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              _label('Giờ đóng cửa *'),
                              TextFormField(
                                controller: closeCtrl,
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                                decoration: _input('22:00'),
                                validator: (v) => v == null || v.trim().isEmpty ? 'Bắt buộc' : null,
                              ),
                            ])),
                          ]),
                          const SizedBox(height: 12),

                          _label('Giá Credits mỗi giờ *'),
                          TextFormField(
                            controller: creditCtrl,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            decoration: _input('10'),
                            validator: (v) {
                              final p = int.tryParse(v ?? '');
                              return (p == null || p <= 0) ? 'Nhập số > 0' : null;
                            },
                          ),
                          const SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity, height: 50,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppConstants.primaryColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: submit,
                              icon: Icon(isEdit ? Icons.save_outlined : Icons.add_circle_outline, color: Colors.white, size: 18),
                              label: Text(
                                isEdit ? 'Lưu thay đổi' : 'Thêm chi nhánh',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  // ─────────────── DELETE DIALOG ───────────────
  void _showDeleteDialog(BuildContext context, Branch branch) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppConstants.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          side: const BorderSide(color: AppConstants.borderColor),
        ),
        title: const Text('Xóa chi nhánh', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        content: Text(
          'Bạn có chắc muốn xóa "${branch.name}"? Lớp học và nhân viên liên quan sẽ bị ảnh hưởng.',
          style: const TextStyle(color: AppConstants.textSecondary),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await widget.provider.deleteBranch(branch.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã xóa chi nhánh'), backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
                }
              }
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ─────────────── HELPERS ───────────────
  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppConstants.textSecondary)),
  );

  InputDecoration _input(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
    filled: true,
    fillColor: AppConstants.surfaceColor,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppConstants.borderColor)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppConstants.primaryColor)),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.redAccent)),
    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.redAccent)),
  );

  Widget _emptyState(String msg) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
    decoration: BoxDecoration(
      color: AppConstants.surfaceColor,
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      border: Border.all(color: AppConstants.borderColor.withOpacity(0.5)),
    ),
    child: Center(child: Text(msg, style: const TextStyle(color: AppConstants.textSecondary))),
  );
}
