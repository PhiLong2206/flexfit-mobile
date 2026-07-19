import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/widgets/image_picker_field.dart';
import '../../../../catalog/domain/entities/fitness_class.dart';
import '../../providers/partner_provider.dart';

class PartnerClassesSubpage extends StatefulWidget {
  final PartnerProvider provider;

  const PartnerClassesSubpage({super.key, required this.provider});

  @override
  State<PartnerClassesSubpage> createState() => _PartnerClassesSubpageState();
}

class _PartnerClassesSubpageState extends State<PartnerClassesSubpage> {
  String? _selectedBranchFilter;

  void _showCreateClassBottomSheet(BuildContext context, {FitnessClass? fitnessClass}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _CreateClassBottomSheet(
          partnerProvider: widget.provider,
          fitnessClass: fitnessClass,
        );
      },
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, FitnessClass cls) {
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
            'Hủy lớp học',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          content: Text(
            'Bạn có chắc chắn muốn hủy lớp học "${cls.name}"? Hành động này sẽ hoàn trả credit cho hội viên đã đặt chỗ.',
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                Navigator.of(ctx).pop();
                try {
                  await widget.provider.deleteClass(cls.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã hủy lớp học thành công'),
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

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;
    final classes = _selectedBranchFilter == null || _selectedBranchFilter == 'All'
        ? provider.classes
        : provider.classes.where((c) => c.branchId == _selectedBranchFilter).toList();

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppConstants.primaryColor,
        onPressed: () => _showCreateClassBottomSheet(context),
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
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Quản lý lớp học',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Danh sách lớp: ${classes.length}',
                    style: const TextStyle(fontSize: 12, color: AppConstants.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Lập lịch, quản lý sĩ số và hủy các buổi tập đang diễn ra.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppConstants.textSecondary,
                ),
              ),
              const SizedBox(height: 16),

              // Filter Dropdown
              _buildBranchFilterDropdown(),

              const SizedBox(height: 16),

              // Classes list
              _buildClassesList(classes, provider.isLoadingClasses),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBranchFilterDropdown() {
    final branches = widget.provider.branches;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppConstants.borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: AppConstants.surfaceColor,
          value: _selectedBranchFilter ?? 'All',
          hint: const Text('Lọc theo chi nhánh', style: TextStyle(color: Colors.white70, fontSize: 13)),
          items: [
            const DropdownMenuItem<String>(
              value: 'All',
              child: Text('Tất cả chi nhánh', style: TextStyle(color: Colors.white, fontSize: 13)),
            ),
            ...branches.map((b) {
              return DropdownMenuItem<String>(
                value: b.id,
                child: Text(b.name, style: const TextStyle(color: Colors.white, fontSize: 13)),
              );
            }),
          ],
          onChanged: (val) {
            setState(() {
              _selectedBranchFilter = val;
            });
          },
        ),
      ),
    );
  }

  Widget _buildClassesList(List<FitnessClass> classes, bool isLoading) {
    if (isLoading && classes.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(color: AppConstants.primaryColor),
        ),
      );
    }
    if (classes.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
        decoration: BoxDecoration(
          color: AppConstants.surfaceColor,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: Border.all(color: AppConstants.borderColor.withOpacity(0.5)),
        ),
        child: const Column(
          children: [
            Icon(Icons.calendar_month, color: AppConstants.textSecondary, size: 40),
            SizedBox(height: 12),
            Text(
              'Không có lớp học nào được lên lịch.',
              style: TextStyle(color: AppConstants.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: classes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final cls = classes[index];
        final start = cls.startTime;
        final end = cls.endTime;
        final dateStr = DateFormat('dd/MM/yyyy').format(start);
        final timeStr = '${DateFormat('HH:mm').format(start)} - ${DateFormat('HH:mm').format(end)}';

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
                child: SizedBox(
                  width: 54,
                  height: 54,
                  child: _buildClassImage(cls.thumbnailUrl),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cls.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'HLV: ${cls.coachName ?? "Chưa có"} • ${cls.branchName}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppConstants.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 12, color: AppConstants.primaryColor),
                        const SizedBox(width: 4),
                        Text(
                          '$timeStr ($dateStr)',
                          style: const TextStyle(fontSize: 11, color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: cls.status == 'Cancelled'
                          ? Colors.red.withOpacity(0.2)
                          : Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      cls.status == 'Cancelled' ? 'Hủy' : '0/${cls.capacity}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: cls.status == 'Cancelled' ? Colors.redAccent : Colors.greenAccent,
                      ),
                    ),
                  ),
                  if (cls.status != 'Cancelled') ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent, size: 20),
                          onPressed: () => _showCreateClassBottomSheet(context, fitnessClass: cls),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                          onPressed: () => _showDeleteConfirmDialog(context, cls),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildClassImage(String? url) {
    if (url == null || url.isEmpty) {
      return Container(
        color: AppConstants.cardColor,
        child: const Icon(Icons.fitness_center, color: AppConstants.textSecondary, size: 24),
      );
    }
    if (url.startsWith('data:image/')) {
      try {
        final base64String = url.split(',').last;
        final bytes = base64Decode(base64String);
        return Image.memory(bytes, fit: BoxFit.cover);
      } catch (_) {
        return Container(
          color: AppConstants.cardColor,
          child: const Icon(Icons.broken_image, color: AppConstants.textSecondary, size: 24),
        );
      }
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: AppConstants.cardColor,
          child: const Icon(Icons.broken_image, color: AppConstants.textSecondary, size: 24),
        );
      },
    );
  }
}

// Category mapping defined on web
final List<Map<String, String>> _categories = [
  {"name": "Boxing", "id": "d210424b-de26-4fb8-afe7-1374f32063dc"},
  {"name": "Crossfit", "id": "aa7ff679-6857-4f7c-959f-8cb7fde50e71"},
  {"name": "Dance", "id": "ed8f4d96-f264-4962-a7ff-5279f3bf3f3a"},
  {"name": "HIIT", "id": "45ad01af-eefe-4a80-bc13-d8ee99cece2b"},
  {"name": "Kickboxing", "id": "619e7582-a00e-46bb-b710-f42e472112c6"},
  {"name": "Pilates", "id": "19117d26-6a16-4d35-a5fc-6fd029abda08"},
  {"name": "Yoga", "id": "f7af0324-45fd-4484-89be-d7b1aacf670a"},
  {"name": "Zumba", "id": "7da8aef0-1e51-42dd-9c33-6a1f37ea630d"},
];

class _CreateClassBottomSheet extends StatefulWidget {
  final PartnerProvider partnerProvider;
  final FitnessClass? fitnessClass;

  const _CreateClassBottomSheet({required this.partnerProvider, this.fitnessClass});

  @override
  State<_CreateClassBottomSheet> createState() => _CreateClassBottomSheetState();
}

class _CreateClassBottomSheetState extends State<_CreateClassBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _coachController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _capacityController = TextEditingController(text: '20');
  final _creditCostController = TextEditingController(text: '4');
  final _caloriesController = TextEditingController(text: '500');

  String? _selectedBranchId;
  String _selectedCategoryId = _categories.first['id']!;
  String _selectedDifficulty = 'Trung bình';

  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);

  // Image state
  String? _currentThumbnailUrl;
  File? _pickedImageFile;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final editClass = widget.fitnessClass;
    if (editClass != null) {
      _nameController.text = editClass.name;
      _coachController.text = editClass.coachName ?? '';
      _descriptionController.text = editClass.description ?? '';
      _capacityController.text = editClass.capacity.toString();
      _creditCostController.text = editClass.creditCost.toString();
      _caloriesController.text = (editClass.caloriesBurnEstimate ?? 500).toString();
      _currentThumbnailUrl = editClass.thumbnailUrl;
      _selectedBranchId = editClass.branchId;
      _selectedCategoryId = editClass.categoryId;
      _selectedDifficulty = editClass.difficultyLevel ?? 'Trung bình';
      _startDate = editClass.startTime;
      _startTime = TimeOfDay.fromDateTime(editClass.startTime);
      _endDate = editClass.endTime;
      _endTime = TimeOfDay.fromDateTime(editClass.endTime);
    } else {
      if (widget.partnerProvider.branches.isNotEmpty) {
        _selectedBranchId = widget.partnerProvider.branches.first.id;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _coachController.dispose();
    _descriptionController.dispose();
    _capacityController.dispose();
    _creditCostController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppConstants.primaryColor,
            onPrimary: Colors.white,
            surface: AppConstants.surfaceColor,
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate;
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppConstants.primaryColor,
            onPrimary: Colors.white,
            surface: AppConstants.surfaceColor,
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (_selectedBranchId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn chi nhánh'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final startDateTime = DateTime(
      _startDate.year,
      _startDate.month,
      _startDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    final endDateTime = DateTime(
      _endDate.year,
      _endDate.month,
      _endDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    if (endDateTime.isBefore(startDateTime) || endDateTime.isAtSameMomentAs(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thời gian kết thúc phải sau thời gian bắt đầu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final body = {
      'branchId': _selectedBranchId,
      'categoryId': _selectedCategoryId,
      'className': _nameController.text.trim(),
      'coachName': _coachController.text.trim(),
      'description': _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      'startTime': startDateTime.toUtc().toIso8601String(),
      'endTime': endDateTime.toUtc().toIso8601String(),
      'capacity': int.tryParse(_capacityController.text) ?? 20,
      'creditCost': int.tryParse(_creditCostController.text) ?? 4,
      'difficultyLevel': _selectedDifficulty,
      'caloriesBurnEstimate': int.tryParse(_caloriesController.text) ?? 500,
      if (_currentThumbnailUrl != null && _currentThumbnailUrl!.isNotEmpty)
        'thumbnailUrl': _currentThumbnailUrl,
    };

    try {
      if (widget.fitnessClass != null) {
        body['status'] = widget.fitnessClass!.status;
        if (_pickedImageFile != null) {
          final fields = body.map((k, v) => MapEntry(k, v?.toString() ?? ''));
          await widget.partnerProvider.partnerRepository
              .updateClassWithImage(widget.fitnessClass!.id, fields, _pickedImageFile!);
          await widget.partnerProvider.fetchClasses();
        } else {
          await widget.partnerProvider.updateClass(widget.fitnessClass!.id, body);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật lớp học thành công!'), backgroundColor: Colors.green),
          );
          Navigator.of(context).pop();
        }
      } else {
        if (_pickedImageFile != null) {
          final fields = body.map((k, v) => MapEntry(k, v?.toString() ?? ''));
          await widget.partnerProvider.partnerRepository
              .createClassWithImage(fields, _pickedImageFile!);
          await widget.partnerProvider.fetchClasses();
        } else {
          await widget.partnerProvider.createClass(body);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tạo lớp học mới thành công!'), backgroundColor: Colors.green),
          );
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tạo lớp học: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final branches = widget.partnerProvider.branches;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      margin: EdgeInsets.only(bottom: keyboardHeight),
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
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.fitnessClass != null ? 'Chỉnh sửa lớp học' : 'Tạo lớp học mới',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
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
                    _buildLabel('Tên lớp học *'),
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration('Ví dụ: HIIT Performance'),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Nhập tên lớp học' : null,
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Huấn luyện viên *'),
                    TextFormField(
                      controller: _coachController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration('Ví dụ: HLV. Nguyễn Văn A'),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Nhập tên HLV' : null,
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Chi nhánh *'),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: AppConstants.surfaceColor,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppConstants.borderColor),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    dropdownColor: AppConstants.surfaceColor,
                                    value: _selectedBranchId,
                                    items: branches.map((b) {
                                      return DropdownMenuItem<String>(
                                        value: b.id,
                                        child: Text(
                                          b.name,
                                          style: const TextStyle(color: Colors.white, fontSize: 13),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      setState(() {
                                        _selectedBranchId = val;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Thể loại *'),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: AppConstants.surfaceColor,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppConstants.borderColor),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    dropdownColor: AppConstants.surfaceColor,
                                    value: _selectedCategoryId,
                                    items: _categories.map((c) {
                                      return DropdownMenuItem<String>(
                                        value: c['id'],
                                        child: Text(
                                          c['name']!,
                                          style: const TextStyle(color: Colors.white, fontSize: 13),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() {
                                          _selectedCategoryId = val;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Thời gian bắt đầu *'),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
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
                                  Text(
                                    DateFormat('dd/MM/yyyy').format(_startDate),
                                    style: const TextStyle(color: Colors.white, fontSize: 13),
                                  ),
                                  const Icon(Icons.calendar_month, color: AppConstants.textSecondary, size: 18),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: _pickStartTime,
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
                                  Text(
                                    _startTime.format(context),
                                    style: const TextStyle(color: Colors.white, fontSize: 13),
                                  ),
                                  const Icon(Icons.access_time, color: AppConstants.textSecondary, size: 18),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Thời gian kết thúc *'),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
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
                                  Text(
                                    DateFormat('dd/MM/yyyy').format(_endDate),
                                    style: const TextStyle(color: Colors.white, fontSize: 13),
                                  ),
                                  const Icon(Icons.calendar_month, color: AppConstants.textSecondary, size: 18),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: _pickEndTime,
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
                                  Text(
                                    _endTime.format(context),
                                    style: const TextStyle(color: Colors.white, fontSize: 13),
                                  ),
                                  const Icon(Icons.access_time, color: AppConstants.textSecondary, size: 18),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Sức chứa *'),
                              TextFormField(
                                controller: _capacityController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: Colors.white),
                                decoration: _buildInputDecoration('20'),
                                validator: (v) => v == null || int.tryParse(v) == null || int.parse(v) <= 0
                                    ? 'Lỗi'
                                    : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Credits *'),
                              TextFormField(
                                controller: _creditCostController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: Colors.white),
                                decoration: _buildInputDecoration('4'),
                                validator: (v) => v == null || int.tryParse(v) == null || int.parse(v) <= 0
                                    ? 'Lỗi'
                                    : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Độ khó'),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: AppConstants.surfaceColor,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppConstants.borderColor),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    dropdownColor: AppConstants.surfaceColor,
                                    value: _selectedDifficulty,
                                    items: ['Cơ bản', 'Trung bình', 'Nâng cao'].map((d) {
                                      return DropdownMenuItem<String>(
                                        value: d,
                                        child: Text(
                                          d,
                                          style: const TextStyle(color: Colors.white, fontSize: 12),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() {
                                          _selectedDifficulty = val;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Calo tiêu hao ước tính'),
                    TextFormField(
                      controller: _caloriesController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration('Ví dụ: 500'),
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Hình ảnh lớp học'),
                    ImagePickerField(
                      currentUrl: _currentThumbnailUrl,
                      pickedFile: _pickedImageFile,
                      onFilePicked: (f) => setState(() => _pickedImageFile = f),
                      onClear: () => setState(() {
                        _pickedImageFile = null;
                        _currentThumbnailUrl = null;
                      }),
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Mô tả lớp học'),
                    TextFormField(
                      controller: _descriptionController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 3,
                      decoration: _buildInputDecoration('Mô tả nội dung lớp học...'),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                          ),
                        ),
                        onPressed: _isSubmitting ? null : _submit,
                        child: _isSubmitting
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Lưu & Xuất bản',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
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
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppConstants.textSecondary,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
      filled: true,
      fillColor: AppConstants.surfaceColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppConstants.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppConstants.primaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }
}
