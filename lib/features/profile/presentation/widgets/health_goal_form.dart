import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/profile_notifier.dart';

class HealthGoalForm extends StatefulWidget {
  const HealthGoalForm({super.key});

  @override
  State<HealthGoalForm> createState() => _HealthGoalFormState();
}

class _HealthGoalFormState extends State<HealthGoalForm>
    with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();

  late String _selectedGender;
  DateTime? _selectedBirthDate;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late String _selectedGoal;
  late String _selectedActivityLevel;
  late String _selectedPreferredTime;
  late TextEditingController _bioController;

  bool _isSaving = false;

  final List<String> _genders = ['Nam', 'Nữ', 'Khác'];
  final List<String> _goals = ['Giảm cân', 'Tăng cơ', 'Giữ dáng', 'Tăng sức bền'];
  final List<String> _activityLevels = [
    'Ít hoạt động',
    'Vừa phải',
    'Năng động',
    'Hoạt động rất tích cực (VĐV)',
  ];
  final List<String> _timeSlots = [
    'Linh hoạt / Tự do',
    'Buổi sáng',
    'Buổi chiều',
    'Buổi tối',
  ];

  late ProfileNotifier _profileNotifier;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _profileNotifier = context.read<ProfileNotifier>();
    _profileNotifier.addListener(_onProfileChanged);
    _initFields();
  }

  void _initFields() {
    final profile = _profileNotifier.profile;
    _selectedGender =
        _genders.contains(profile.gender) ? profile.gender : _genders.first;
    _selectedBirthDate = profile.birthDate;
    _heightController = TextEditingController(
        text: profile.height.toString().replaceAll('.', ','));
    _weightController =
        TextEditingController(text: profile.weight.toStringAsFixed(0));
    _selectedGoal = _goals.contains(profile.fitnessGoal)
        ? profile.fitnessGoal
        : _goals.first;
    _selectedActivityLevel = _activityLevels.contains(profile.activityLevel)
        ? profile.activityLevel
        : _activityLevels.first;
    _selectedPreferredTime = _timeSlots.contains(profile.preferredTimeSlot)
        ? profile.preferredTimeSlot
        : _timeSlots.first;
    _bioController = TextEditingController(text: profile.bio);
  }

  void _onProfileChanged() {
    if (!mounted) return;
    final profile = _profileNotifier.profile;
    setState(() {
      _selectedGender =
          _genders.contains(profile.gender) ? profile.gender : _genders.first;
      _selectedBirthDate = profile.birthDate;
      _heightController.text = profile.height.toString().replaceAll('.', ',');
      _weightController.text = profile.weight.toStringAsFixed(0);
      _selectedGoal = _goals.contains(profile.fitnessGoal)
          ? profile.fitnessGoal
          : _goals.first;
      _selectedActivityLevel = _activityLevels.contains(profile.activityLevel)
          ? profile.activityLevel
          : _activityLevels.first;
      _selectedPreferredTime = _timeSlots.contains(profile.preferredTimeSlot)
          ? profile.preferredTimeSlot
          : _timeSlots.first;
      _bioController.text = profile.bio;
    });
  }

  @override
  void dispose() {
    _profileNotifier.removeListener(_onProfileChanged);
    _heightController.dispose();
    _weightController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Chọn ngày sinh';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.card,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedBirthDate) {
      setState(() => _selectedBirthDate = picked);
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    final heightText = _heightController.text.trim().replaceAll(',', '.');
    final weightText = _weightController.text.trim().replaceAll(',', '.');
    final height = double.tryParse(heightText) ?? 0.0;
    final weight = double.tryParse(weightText) ?? 0.0;
    context.read<ProfileNotifier>().updateHealthGoal(
          gender: _selectedGender,
          birthDate: _selectedBirthDate,
          height: height,
          weight: weight,
          fitnessGoal: _selectedGoal,
          activityLevel: _selectedActivityLevel,
          preferredTimeSlot: _selectedPreferredTime,
          bio: _bioController.text.trim(),
        );
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'Đã lưu chỉ số sức khỏe & mục tiêu thành công!',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        backgroundColor: AppColors.completed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chỉ số sức khỏe & Mục tiêu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _ProfileDropdownField(
                    label: 'Giới tính',
                    value: _selectedGender,
                    items: _genders,
                    onChanged: (value) {
                      if (value != null) setState(() => _selectedGender = value);
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ngày sinh',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _selectBirthDate(context),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          height: 52,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.background.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDate(_selectedBirthDate),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              const Icon(
                                Icons.calendar_today_rounded,
                                color: AppColors.textSecondary,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ProfileTextField(
                    controller: _heightController,
                    label: 'Chiều cao (cm hoặc m)',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Yêu cầu điền chiều cao';
                      }
                      final v =
                          double.tryParse(value.trim().replaceAll(',', '.'));
                      if (v == null) return 'Không hợp lệ';
                      if (v <= 0 || v >= 300) return 'Phải từ 0 đến 300';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _ProfileTextField(
                    controller: _weightController,
                    label: 'Cân nặng (kg)',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Yêu cầu điền cân nặng';
                      }
                      final v =
                          double.tryParse(value.trim().replaceAll(',', '.'));
                      if (v == null) return 'Không hợp lệ';
                      if (v <= 0 || v >= 500) return 'Phải từ 0 đến 500';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _ProfileDropdownField(
              label: 'Mục tiêu tập luyện',
              value: _selectedGoal,
              items: _goals,
              onChanged: (value) {
                if (value != null) setState(() => _selectedGoal = value);
              },
            ),
            const SizedBox(height: 16),
            _ProfileDropdownField(
              label: 'Mức độ hoạt động',
              value: _selectedActivityLevel,
              items: _activityLevels,
              onChanged: (value) {
                if (value != null) setState(() => _selectedActivityLevel = value);
              },
            ),
            const SizedBox(height: 16),
            _ProfileDropdownField(
              label: 'Khung giờ tập luyện ưa thích',
              value: _selectedPreferredTime,
              items: _timeSlots,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedPreferredTime = value);
                }
              },
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Giới thiệu bản thân (Bio)',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _bioController,
                  maxLines: 4,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                  cursorColor: AppColors.primary,
                  decoration: InputDecoration(
                    hintText:
                        'Chia sẻ một chút về hành trình fitness của bạn...',
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w500,
                    ),
                    filled: true,
                    fillColor: AppColors.background.withValues(alpha: 0.4),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 1.4),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      AppColors.primary.withValues(alpha: 0.6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save_outlined, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Lưu thay đổi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const _ProfileTextField({
    required this.controller,
    required this.label,
    this.validator,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          cursorColor: AppColors.primary,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.background.withValues(alpha: 0.4),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  BorderSide(color: Colors.white.withValues(alpha: 0.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.4),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AppColors.cancelled, width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AppColors.cancelled, width: 1.4),
            ),
            errorStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: AppColors.cancelled,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileDropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _ProfileDropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                item,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.background.withValues(alpha: 0.4),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  BorderSide(color: Colors.white.withValues(alpha: 0.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.4),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AppColors.cancelled, width: 1.2),
            ),
          ),
          dropdownColor: AppColors.card,
          iconEnabledColor: AppColors.textSecondary,
        ),
      ],
    );
  }
}
