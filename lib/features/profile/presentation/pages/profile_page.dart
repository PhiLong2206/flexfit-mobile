import 'package:flutter/material.dart';

import '../../../../core/services/local_storage.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../notification/presentation/widgets/notification_bell_button.dart';
import '../../data/models/member_profile_model.dart';
import '../../data/repositories/profile_repository.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const Color _backgroundColor = Color(0xFF070B14);
  static const Color _cardColor = Color(0xFF111827);
  static const Color _inputColor = Color(0xFF070B14);
  static const Color _primaryOrange = Color(0xFFFF6B16);

  final _repository = ProfileRepository();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _genderController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _goalController = TextEditingController();
  final _bioController = TextEditingController();

  late Future<MemberProfileModel> _future;
  MemberProfileModel? _profile;

  bool _isSaving = false;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _genderController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _goalController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<MemberProfileModel> _load() async {
    final profile = await _repository.getMe();
    _applyProfile(profile);

    return profile;
  }

  void _applyProfile(MemberProfileModel profile) {
    _profile = profile;
    _syncControllers(profile);
  }

  void _syncControllers(MemberProfileModel profile) {
    _nameController.text = profile.fullName;
    _phoneController.text = profile.phoneNumber ?? '';
    _genderController.text = profile.gender ?? '';
    _heightController.text = profile.heightCm?.toString() ?? '';
    _weightController.text = profile.weightKg?.toString() ?? '';
    _goalController.text = profile.fitnessGoal ?? '';
    _bioController.text = profile.bio ?? '';
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  Future<void> _save() async {
    final current = _profile;
    if (current == null || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      final updated = current.copyWith(
        fullName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        gender: _genderController.text.trim(),
        heightCm: _parseHeightCm(_heightController.text),
        weightKg: _parseNumber(_weightController.text),
        fitnessGoal: _goalController.text.trim(),
        bio: _bioController.text.trim(),
      );

      final saved = await _repository.updateMe(updated);

      if (!mounted) return;
      setState(() {
        _applyProfile(saved);
        _future = Future.value(saved);
      });

      final persisted = await _repository.getMe();
      _logNotPersistedFields(requested: updated, persisted: persisted);

      if (!mounted) return;
      setState(() {
        _applyProfile(persisted);
        _future = Future.value(persisted);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật hồ sơ thành công.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _logNotPersistedFields({
    required MemberProfileModel requested,
    required MemberProfileModel persisted,
  }) {
    final fields = <String>[];

    void checkString(String field, String? sent, String? loaded) {
      final sentText = sent?.trim();
      if (sentText == null || sentText.isEmpty) return;
      if (sentText != loaded?.trim()) fields.add(field);
    }

    void checkNumber(String field, double? sent, double? loaded) {
      if (sent == null) return;
      if (loaded == null || (sent - loaded).abs() > 0.01) fields.add(field);
    }

    checkString('fullName', requested.fullName, persisted.fullName);
    checkString('phoneNumber', requested.phoneNumber, persisted.phoneNumber);
    checkString('dateOfBirth', requested.dateOfBirth, persisted.dateOfBirth);
    checkString('gender', requested.gender, persisted.gender);
    checkNumber('heightCm', requested.heightCm, persisted.heightCm);
    checkNumber('weightKg', requested.weightKg, persisted.weightKg);
    checkString('fitnessGoal', requested.fitnessGoal, persisted.fitnessGoal);
    checkString(
      'activityLevel',
      requested.activityLevel,
      persisted.activityLevel,
    );
    checkString(
      'preferredWorkoutTime',
      requested.preferredWorkoutTime,
      persisted.preferredWorkoutTime,
    );
    checkString('bio', requested.bio, persisted.bio);

    if (fields.isEmpty) {
      debugPrint(
        'UPDATE PROFILE PERSISTENCE CHECK: all sent fields persisted.',
      );
      return;
    }

    debugPrint(
      'UPDATE PROFILE PERSISTENCE CHECK: backend did not persist fields: '
      '${fields.join(', ')}',
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _cardColor,
        title: const Text('Đăng xuất?'),
        content: const Text('Bạn có chắc muốn đăng xuất khỏi FlexFit không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Huỷ'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await LocalStorage.removeToken();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  String _initials(MemberProfileModel profile) {
    final name = profile.fullName.trim();
    if (name.isEmpty) return 'FF';

    final parts = name.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      final text = parts.first;
      return text.substring(0, text.length >= 2 ? 2 : 1).toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text('Hồ sơ & Cài đặt'),
        backgroundColor: _backgroundColor,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(child: NotificationBellButton()),
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<MemberProfileModel>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _ProfileLoadingState();
            }

            if (snapshot.hasError) {
              return _StateMessage(
                title: 'Không tải được hồ sơ',
                message: snapshot.error.toString(),
                onRetry: _reload,
              );
            }

            final profile = snapshot.data!;

            return LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 760;

                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1180),
                      child: isWide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 340,
                                  child: Column(
                                    children: [
                                      _ProfileCard(
                                        initials: _initials(profile),
                                        name: profile.fullName,
                                        email: profile.email,
                                        avatarUrl: profile.avatarUrl,
                                      ),
                                      const SizedBox(height: 16),
                                      _MenuCard(
                                        selectedTab: _selectedTab,
                                        onSelectTab: (index) {
                                          setState(() => _selectedTab = index);
                                        },
                                        onLogout: _logout,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 22),
                                Expanded(
                                  child: _ContentCard(
                                    selectedTab: _selectedTab,
                                    nameController: _nameController,
                                    phoneController: _phoneController,
                                    genderController: _genderController,
                                    heightController: _heightController,
                                    weightController: _weightController,
                                    goalController: _goalController,
                                    bioController: _bioController,
                                    email: profile.email,
                                    isSaving: _isSaving,
                                    onSave: _save,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                _ProfileCard(
                                  initials: _initials(profile),
                                  name: profile.fullName,
                                  email: profile.email,
                                  avatarUrl: profile.avatarUrl,
                                ),
                                const SizedBox(height: 16),
                                _MenuCard(
                                  selectedTab: _selectedTab,
                                  onSelectTab: (index) {
                                    setState(() => _selectedTab = index);
                                  },
                                  onLogout: _logout,
                                ),
                                const SizedBox(height: 16),
                                _ContentCard(
                                  selectedTab: _selectedTab,
                                  nameController: _nameController,
                                  phoneController: _phoneController,
                                  genderController: _genderController,
                                  heightController: _heightController,
                                  weightController: _weightController,
                                  goalController: _goalController,
                                  bioController: _bioController,
                                  email: profile.email,
                                  isSaving: _isSaving,
                                  onSave: _save,
                                ),
                              ],
                            ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.initials,
    required this.name,
    required this.email,
    required this.avatarUrl,
  });

  final String initials;
  final String name;
  final String email;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF161F2E), Color(0xFF111827), Color(0xFF241A14)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _ProfilePageState._primaryOrange.withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        children: [
          _AvatarBadge(initials: initials, avatarUrl: avatarUrl),
          const SizedBox(height: 18),
          Text(
            name.isEmpty ? 'FlexFit Member' : name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            email,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white60,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: _ProfilePageState._primaryOrange.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _ProfilePageState._primaryOrange.withValues(alpha: 0.35),
              ),
            ),
            child: const Text(
              'Thành viên FLEXFIT Elite',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _ProfilePageState._primaryOrange,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarBadge extends StatelessWidget {
  const _AvatarBadge({required this.initials, required this.avatarUrl});

  final String initials;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl?.trim();
    return Container(
      width: 100,
      height: 100,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: _ProfilePageState._primaryOrange.withValues(alpha: 0.9),
          width: 3,
        ),
        color: Colors.black,
      ),
      child: ClipOval(
        child: url == null || url.isEmpty
            ? _InitialsAvatar(initials: initials)
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _InitialsAvatar(initials: initials),
              ),
      ),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: const Color(0xFF070B14),
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.selectedTab,
    required this.onSelectTab,
    required this.onLogout,
  });

  final int selectedTab;
  final ValueChanged<int> onSelectTab;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _boxDecoration(),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _MenuItem(
            icon: Icons.person_outline_rounded,
            title: 'Thông tin cá nhân',
            selected: selectedTab == 0,
            onTap: () => onSelectTab(0),
          ),
          _MenuItem(
            icon: Icons.favorite_border_rounded,
            title: 'Sức khỏe & Mục tiêu',
            selected: selectedTab == 1,
            onTap: () => onSelectTab(1),
          ),
          Divider(color: Colors.white.withValues(alpha: 0.08)),
          _MenuItem(
            icon: Icons.logout_rounded,
            title: 'Đăng xuất',
            danger: true,
            selected: false,
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final bool selected;
  final bool danger;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = danger
        ? Colors.redAccent
        : selected
        ? Colors.white
        : Colors.white60;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white.withValues(alpha: 0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  const _ContentCard({
    required this.selectedTab,
    required this.nameController,
    required this.phoneController,
    required this.genderController,
    required this.heightController,
    required this.weightController,
    required this.goalController,
    required this.bioController,
    required this.email,
    required this.isSaving,
    required this.onSave,
  });

  final int selectedTab;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController genderController;
  final TextEditingController heightController;
  final TextEditingController weightController;
  final TextEditingController goalController;
  final TextEditingController bioController;
  final String email;
  final bool isSaving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: _boxDecoration(),
          child: selectedTab == 0
              ? _PersonalInfoForm(
                  nameController: nameController,
                  phoneController: phoneController,
                  email: email,
                )
              : _HealthGoalForm(
                  genderController: genderController,
                  heightController: heightController,
                  weightController: weightController,
                  goalController: goalController,
                  bioController: bioController,
                ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: FilledButton.icon(
            onPressed: isSaving ? null : onSave,
            style: FilledButton.styleFrom(
              backgroundColor: _ProfilePageState._primaryOrange,
              foregroundColor: Colors.white,
              disabledBackgroundColor: _ProfilePageState._primaryOrange
                  .withValues(alpha: 0.42),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(
              isSaving ? 'Đang lưu...' : 'Lưu thay đổi',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ],
    );
  }
}

class _PersonalInfoForm extends StatelessWidget {
  const _PersonalInfoForm({
    required this.nameController,
    required this.phoneController,
    required this.email,
  });

  final TextEditingController nameController;
  final TextEditingController phoneController;
  final String email;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Thông tin cá nhân'),
        const SizedBox(height: 18),
        _Field(controller: nameController, label: 'Họ và tên'),
        _ReadOnlyField(label: 'Email', value: email, icon: Icons.mail_outline),
        _Field(
          controller: phoneController,
          label: 'Số điện thoại',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }
}

class _HealthGoalForm extends StatelessWidget {
  const _HealthGoalForm({
    required this.genderController,
    required this.heightController,
    required this.weightController,
    required this.goalController,
    required this.bioController,
  });

  final TextEditingController genderController;
  final TextEditingController heightController;
  final TextEditingController weightController;
  final TextEditingController goalController;
  final TextEditingController bioController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Chỉ số sức khỏe & Mục tiêu'),
        const SizedBox(height: 18),
        _Field(controller: genderController, label: 'Giới tính'),
        _GoalChips(controller: goalController),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _Field(
                controller: heightController,
                label: 'Chiều cao (cm)',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Field(
                controller: weightController,
                label: 'Cân nặng (kg)',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        _Field(controller: goalController, label: 'Mục tiêu tập luyện'),
        _Field(
          controller: bioController,
          label: 'Giới thiệu bản thân (Bio)',
          maxLines: 3,
        ),
      ],
    );
  }
}

class _GoalChips extends StatelessWidget {
  const _GoalChips({required this.controller});

  static const _goals = [
    'Tăng cơ',
    'Giảm mỡ',
    'Giữ dáng',
    'Cải thiện sức bền',
    'Tập luyện linh hoạt',
  ];

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final selected = value.text.trim();
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final goal in _goals)
              ChoiceChip(
                label: Text(goal),
                selected: selected == goal,
                onSelected: (_) => controller.text = goal,
                selectedColor: _ProfilePageState._primaryOrange,
                backgroundColor: Colors.white.withValues(alpha: 0.06),
                side: BorderSide(
                  color: selected == goal
                      ? _ProfilePageState._primaryOrange
                      : Colors.white.withValues(alpha: 0.08),
                ),
                labelStyle: TextStyle(
                  color: selected == goal ? Colors.white : Colors.white70,
                  fontWeight: FontWeight.w800,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    this.icon,
    this.keyboardType,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        decoration: _inputDecoration(label: label, icon: icon),
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({required this.label, required this.value, this.icon});

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        enabled: false,
        controller: TextEditingController(text: value),
        style: const TextStyle(
          color: Colors.white60,
          fontWeight: FontWeight.w700,
        ),
        decoration: _inputDecoration(label: label, icon: icon),
      ),
    );
  }
}

InputDecoration _inputDecoration({required String label, IconData? icon}) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(
      color: Colors.white60,
      fontWeight: FontWeight.w700,
    ),
    prefixIcon: icon == null ? null : Icon(icon, color: Colors.white54),
    filled: true,
    fillColor: _ProfilePageState._inputColor,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: _ProfilePageState._primaryOrange),
    ),
  );
}

BoxDecoration _boxDecoration() {
  return BoxDecoration(
    color: _ProfilePageState._cardColor,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
  );
}

class _ProfileLoadingState extends StatelessWidget {
  const _ProfileLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: _ProfilePageState._primaryOrange),
          SizedBox(height: 14),
          Text(
            'Đang tải hồ sơ...',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.title,
    required this.message,
    required this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              color: _ProfilePageState._primaryOrange,
              size: 42,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ),
      ),
    );
  }
}

double? _parseNumber(String value) {
  final normalized = value.trim().replaceAll(',', '.');
  if (normalized.isEmpty) return null;
  return double.tryParse(normalized);
}

double? _parseHeightCm(String value) {
  final number = _parseNumber(value);
  if (number == null) return null;

  if (number > 0 && number < 3) {
    return number * 100;
  }

  return number;
}

// ignore: unused_element
String? _normalizeFitnessGoal(String value) {
  final text = value.trim().toLowerCase();
  if (text.isEmpty) return null;

  if (text.contains('giảm') || text.contains('giam')) return 'WeightLoss';
  if (text.contains('tăng') || text.contains('tang')) return 'MuscleGain';
  if (text.contains('sức khỏe') || text.contains('suc khoe')) {
    return 'Health';
  }

  return value.trim();
}
