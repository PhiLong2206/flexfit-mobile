import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../data/models/partner_promotion_model.dart';
import '../../providers/partner_provider.dart';

class PartnerPromotionsSubpage extends StatefulWidget {
  final PartnerProvider provider;

  const PartnerPromotionsSubpage({super.key, required this.provider});

  @override
  State<PartnerPromotionsSubpage> createState() => _PartnerPromotionsSubpageState();
}

class _PartnerPromotionsSubpageState extends State<PartnerPromotionsSubpage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.provider.fetchPromotions();
    });
  }

  void _showCreatePromotionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _CreatePromotionBottomSheet(provider: widget.provider);
      },
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, PartnerPromotionModel promotion) {
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
            'Xóa khuyến mãi',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          content: Text(
            'Bạn có chắc chắn muốn xóa khuyến mãi "${promotion.title}"? Hành động này không thể hoàn tác.',
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
                  await widget.provider.deletePromotion(promotion.promotionId);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Xóa khuyến mãi thành công'),
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
              child: const Text('Xác nhận', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showPromotionDetailDialog(BuildContext context, PartnerPromotionModel promotion) {
    showDialog(
      context: context,
      builder: (ctx) {
        final startStr = DateFormat('dd/MM/yyyy').format(promotion.startDate);
        final endStr = DateFormat('dd/MM/yyyy').format(promotion.endDate);

        return AlertDialog(
          backgroundColor: AppConstants.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            side: const BorderSide(color: AppConstants.borderColor),
          ),
          title: Text(
            promotion.title,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailItem('Mức giảm', '${promotion.discountPercent}% OFF'),
              _buildDetailItem('Thời gian áp dụng', '$startStr - $endStr'),
              _buildDetailItem('Trạng thái', promotion.isActive ? 'Đang hoạt động' : 'Đã ẩn', color: promotion.isActive ? Colors.greenAccent : Colors.grey),
              const SizedBox(height: 10),
              const Text(
                'Mô tả chi tiết:',
                style: TextStyle(fontSize: 12, color: AppConstants.textSecondary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                promotion.description.isEmpty ? 'Không có mô tả chi tiết.' : promotion.description,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Đóng', style: TextStyle(color: AppConstants.primaryColor)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailItem(String label, String val, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppConstants.textSecondary, fontSize: 12)),
          Text(val, style: TextStyle(color: color ?? Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final promotions = widget.provider.promotions;

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppConstants.primaryColor,
        onPressed: () => _showCreatePromotionBottomSheet(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: RefreshIndicator(
        color: AppConstants.primaryColor,
        onRefresh: () => widget.provider.fetchPromotions(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Quản lý khuyến mãi',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    'Tổng số: ${promotions.length}',
                    style: const TextStyle(fontSize: 12, color: AppConstants.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Thiết lập các chương trình ưu đãi giảm giá hội viên cho phòng tập.',
                style: TextStyle(fontSize: 13, color: AppConstants.textSecondary),
              ),
              const SizedBox(height: 20),

              if (widget.provider.isLoadingPromotions && promotions.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(color: AppConstants.primaryColor),
                  ),
                )
              else if (promotions.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppConstants.surfaceColor,
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    border: Border.all(color: AppConstants.borderColor.withOpacity(0.5)),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.local_offer_outlined, color: AppConstants.textSecondary, size: 40),
                      SizedBox(height: 12),
                      Text(
                        'Chưa có chương trình khuyến mãi nào.',
                        style: TextStyle(color: AppConstants.textSecondary),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: promotions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, idx) {
                    final promo = promotions[idx];
                    final startStr = DateFormat('dd/MM/yyyy').format(promo.startDate);
                    final endStr = DateFormat('dd/MM/yyyy').format(promo.endDate);

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppConstants.surfaceColor,
                        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                        border: Border.all(color: AppConstants.borderColor.withOpacity(0.5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                promo.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: promo.isActive ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  promo.isActive ? 'Hoạt động' : 'Đã ẩn',
                                  style: TextStyle(fontSize: 10, color: promo.isActive ? Colors.greenAccent : Colors.grey, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            promo.description.isEmpty ? 'Không có mô tả' : promo.description,
                            style: const TextStyle(fontSize: 12, color: AppConstants.textSecondary),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          const Divider(color: AppConstants.borderColor, height: 1),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${promo.discountPercent}% OFF',
                                style: const TextStyle(color: AppConstants.primaryColor, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              Text(
                                '$startStr - $endStr',
                                style: const TextStyle(color: AppConstants.textSecondary, fontSize: 11),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(60, 30)),
                                onPressed: () => _showPromotionDetailDialog(context, promo),
                                icon: const Icon(Icons.visibility_outlined, size: 14, color: Colors.blueAccent),
                                label: const Text('Chi tiết', style: TextStyle(color: Colors.blueAccent, fontSize: 12)),
                              ),
                              const SizedBox(width: 8),
                              TextButton.icon(
                                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(60, 30)),
                                onPressed: () => _showDeleteConfirmDialog(context, promo),
                                icon: const Icon(Icons.delete_outline, size: 14, color: Colors.redAccent),
                                label: const Text('Xóa', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreatePromotionBottomSheet extends StatefulWidget {
  final PartnerProvider provider;

  const _CreatePromotionBottomSheet({required this.provider});

  @override
  State<_CreatePromotionBottomSheet> createState() => _CreatePromotionBottomSheetState();
}

class _CreatePromotionBottomSheetState extends State<_CreatePromotionBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _discountController = TextEditingController(text: '10');

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));

  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate.add(const Duration(days: 7));
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_endDate.isBefore(_startDate) || _endDate.isAtSameMomentAs(_startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ngày kết thúc phải sau ngày bắt đầu'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final body = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'discountPercent': int.tryParse(_discountController.text) ?? 10,
      'startDate': _startDate.toUtc().toIso8601String(),
      'endDate': _endDate.toUtc().toIso8601String(),
    };

    try {
      await widget.provider.createPromotion(body);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tạo khuyến mãi mới thành công'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final kb = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Tạo khuyến mãi mới',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
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
                    _buildLabel('Mã / Tiêu đề khuyến mãi *'),
                    TextFormField(
                      controller: _titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInput('VD: GIAM20, TET2026'),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Nhập mã khuyến mãi' : null,
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Mô tả khuyến mãi'),
                    TextFormField(
                      controller: _descriptionController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 2,
                      decoration: _buildInput('Mô tả chương trình ưu đãi...'),
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Phần trăm giảm (%) *'),
                    TextFormField(
                      controller: _discountController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: _buildInput('VD: 15'),
                      validator: (v) {
                        final parsed = int.tryParse(v ?? '');
                        if (parsed == null || parsed < 1 || parsed > 100) return 'Giảm từ 1 đến 100%';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Từ ngày *'),
                              InkWell(
                                onTap: _pickStartDate,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppConstants.surfaceColor,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppConstants.borderColor),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(DateFormat('dd/MM/yyyy').format(_startDate), style: const TextStyle(color: Colors.white, fontSize: 13)),
                                      const Icon(Icons.calendar_today, size: 16, color: AppConstants.textSecondary),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Đến ngày *'),
                              InkWell(
                                onTap: _pickEndDate,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppConstants.surfaceColor,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppConstants.borderColor),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(DateFormat('dd/MM/yyyy').format(_endDate), style: const TextStyle(color: Colors.white, fontSize: 13)),
                                      const Icon(Icons.calendar_today, size: 16, color: AppConstants.textSecondary),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _isSubmitting ? null : _submit,
                        child: _isSubmitting
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Tạo khuyến mãi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
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
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppConstants.textSecondary)),
    );
  }

  InputDecoration _buildInput(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
      filled: true,
      fillColor: AppConstants.surfaceColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppConstants.borderColor)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppConstants.primaryColor)),
    );
  }
}
