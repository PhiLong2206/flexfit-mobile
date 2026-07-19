import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/network/local_storage.dart';
import '../../../auth/presentation/screens/login_page.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../notification/presentation/widgets/notification_bell_button.dart';
import '../../../workout/presentation/pages/workout_history_page.dart';
import '../../../workout/presentation/pages/workout_statistics_page.dart';
import '../../domain/entities/profile.dart';
import '../providers/profile_provider.dart';
import '../../../../core/presentation/widgets/main_bottom_navigation_bar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => sl<ProfileProvider>()..fetchProfile(),
        ),
        ChangeNotifierProvider(create: (_) => sl<AuthProvider>()),
      ],
      child: const _ProfilePageView(),
    );
  }
}

class _ProfilePageView extends StatefulWidget {
  const _ProfilePageView();

  @override
  State<_ProfilePageView> createState() => _ProfilePageViewState();
}

class _ProfilePageViewState extends State<_ProfilePageView> {
  static const Color _backgroundColor = Color(0xFF070B14);
  static const Color _cardColor = Color(0xFF111827);
  static const Color _inputColor = Color(0xFF070B14);
  static const Color _primaryOrange = Color(0xFFFF6B16);

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _genderController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _goalController = TextEditingController();
  final _bioController = TextEditingController();
  final _targetWeightController = TextEditingController();
  final _workoutSessionsController = TextEditingController();

  int _selectedTab = 0;
  bool _isInitialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _genderController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _goalController.dispose();
    _bioController.dispose();
    _targetWeightController.dispose();
    _workoutSessionsController.dispose();
    super.dispose();
  }

  void _syncControllers(Profile profile) {
    if (_isInitialized) return;
    _nameController.text = profile.fullName;
    _phoneController.text = profile.phoneNumber ?? '';
    _genderController.text = profile.gender ?? '';
    _heightController.text = profile.heightCm?.toString() ?? '';
    _weightController.text = profile.weightKg?.toString() ?? '';
    _goalController.text = profile.fitnessGoal ?? '';
    _bioController.text = profile.bio ?? '';
    _targetWeightController.text = profile.targetWeight?.toString() ?? '';
    _workoutSessionsController.text = profile.workoutSessionsPerWeek?.toString() ?? '';
    _isInitialized = true;
  }

  void _reload() {
    _isInitialized = false;
    context.read<ProfileProvider>().fetchProfile();
  }

  Future<void> _save() async {
    final provider = context.read<ProfileProvider>();
    if (provider.isSaving) return;

    try {
      await provider.updateProfile(
        fullName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        gender: _genderController.text.trim(),
        heightCm: _parseHeightCm(_heightController.text),
        weightKg: _parseNumber(_weightController.text),
        fitnessGoal: _goalController.text.trim(),
        bio: _bioController.text.trim(),
        targetWeight: _parseNumber(_targetWeightController.text),
        workoutSessionsPerWeek: _parseInt(_workoutSessionsController.text),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật hồ sơ thành công.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
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

  Future<void> _openChangePassword() async {
    final changed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<AuthProvider>(),
        child: const _ChangePasswordDialog(),
      ),
    );

    if (changed == true && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đổi mật khẩu thành công.')));
    }
  }

  Future<void> _pickAndUploadAvatar(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (image == null) return;

    final provider = context.read<ProfileProvider>();
    try {
      await provider.updateAvatar(File(image.path));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật ảnh đại diện thành công.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải ảnh đại diện: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  String _initials(Profile profile) {
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
    final provider = context.watch<ProfileProvider>();

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
        child: Builder(
          builder: (context) {
            if (provider.isLoading && provider.profile == null) {
              return const _ProfileLoadingState();
            }

            if (provider.error != null && provider.profile == null) {
              return _StateMessage(
                title: 'Không tải được hồ sơ',
                message: provider.error!,
                onRetry: _reload,
              );
            }

            final profile = provider.profile;
            if (profile == null) return const SizedBox();

            _syncControllers(profile);

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
                                        onAvatarTap: () => _pickAndUploadAvatar(context),
                                      ),
                                      const SizedBox(height: 16),
                                      _MenuCard(
                                        selectedTab: _selectedTab,
                                        onSelectTab: (index) {
                                          setState(() => _selectedTab = index);
                                        },
                                        onChangePassword: _openChangePassword,
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
                                    targetWeightController: _targetWeightController,
                                    workoutSessionsController: _workoutSessionsController,
                                    email: profile.email,
                                    isSaving: provider.isSaving,
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
                                  onAvatarTap: () => _pickAndUploadAvatar(context),
                                ),
                                const SizedBox(height: 16),
                                _MenuCard(
                                  selectedTab: _selectedTab,
                                  onSelectTab: (index) {
                                    setState(() => _selectedTab = index);
                                  },
                                  onChangePassword: _openChangePassword,
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
                                  targetWeightController: _targetWeightController,
                                  workoutSessionsController: _workoutSessionsController,
                                  email: profile.email,
                                  isSaving: provider.isSaving,
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
      bottomNavigationBar: const MainBottomNavigationBar(currentIndex: 5),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.initials,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.onAvatarTap,
  });

  final String initials;
  final String name;
  final String email;
  final String? avatarUrl;
  final VoidCallback onAvatarTap;

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
          color: _ProfilePageViewState._primaryOrange.withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        children: [
          _AvatarBadge(
            initials: initials,
            avatarUrl: avatarUrl,
            onTap: onAvatarTap,
          ),
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
              color: _ProfilePageViewState._primaryOrange.withValues(
                alpha: 0.09,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _ProfilePageViewState._primaryOrange.withValues(
                  alpha: 0.35,
                ),
              ),
            ),
            child: const Text(
              'Thành viên FLEXFIT Elite',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _ProfilePageViewState._primaryOrange,
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
  const _AvatarBadge({
    required this.initials,
    required this.avatarUrl,
    required this.onTap,
  });

  final String initials;
  final String? avatarUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl?.trim();
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _ProfilePageViewState._primaryOrange.withValues(alpha: 0.9),
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
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint('ERROR LOADING AVATAR FROM URL: $url - Error: $error');
                        return _InitialsAvatar(initials: initials);
                      },
                    ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: _ProfilePageViewState._primaryOrange,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
        ],
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
    required this.onChangePassword,
    required this.onLogout,
  });

  final int selectedTab;
  final ValueChanged<int> onSelectTab;
  final VoidCallback onChangePassword;
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
            icon: Icons.fitness_center_rounded,
            title: 'Lịch sử tập luyện',
            selected: false,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const WorkoutHistoryPage(),
                ),
              );
            },
          ),
          _MenuItem(
            icon: Icons.analytics_outlined,
            title: 'Thống kê thể chất',
            selected: false,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const WorkoutStatisticsPage(),
                ),
              );
            },
          ),
          _MenuItem(
            icon: Icons.lock_outline_rounded,
            title: 'Đổi mật khẩu',
            selected: false,
            onTap: onChangePassword,
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

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePasswords = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    try {
      await context.read<AuthProvider>().changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      // AuthProvider exposes the backend message for the dialog to display.
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuthProvider>();

    return AlertDialog(
      backgroundColor: _ProfilePageViewState._cardColor,
      title: const Text('Đổi mật khẩu'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _passwordField(
                  controller: _currentPasswordController,
                  label: 'Mật khẩu hiện tại',
                  validator: (value) => value == null || value.isEmpty
                      ? 'Vui lòng nhập mật khẩu hiện tại.'
                      : null,
                ),
                const SizedBox(height: 14),
                _passwordField(
                  controller: _newPasswordController,
                  label: 'Mật khẩu mới',
                  validator: (value) => value == null || value.length < 6
                      ? 'Mật khẩu mới phải có ít nhất 6 ký tự.'
                      : null,
                ),
                const SizedBox(height: 14),
                _passwordField(
                  controller: _confirmPasswordController,
                  label: 'Xác nhận mật khẩu mới',
                  validator: (value) => value != _newPasswordController.text
                      ? 'Mật khẩu xác nhận không khớp.'
                      : null,
                ),
                if (provider.error != null) ...[
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      provider.error!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: provider.isChangingPassword
              ? null
              : () => Navigator.of(context).pop(false),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: provider.isChangingPassword ? null : _submit,
          child: provider.isChangingPassword
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Đổi mật khẩu'),
        ),
      ],
    );
  }

  TextFormField _passwordField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: _obscurePasswords,
      autocorrect: false,
      enableSuggestions: false,
      textInputAction: TextInputAction.next,
      validator: validator,
      decoration: _inputDecoration(label: label, icon: Icons.lock_outline)
          .copyWith(
            suffixIcon: IconButton(
              onPressed: () =>
                  setState(() => _obscurePasswords = !_obscurePasswords),
              icon: Icon(
                _obscurePasswords
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
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
    required this.targetWeightController,
    required this.workoutSessionsController,
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
  final TextEditingController targetWeightController;
  final TextEditingController workoutSessionsController;
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
                  targetWeightController: targetWeightController,
                  workoutSessionsController: workoutSessionsController,
                ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: FilledButton.icon(
            onPressed: isSaving ? null : onSave,
            style: FilledButton.styleFrom(
              backgroundColor: _ProfilePageViewState._primaryOrange,
              foregroundColor: Colors.white,
              disabledBackgroundColor: _ProfilePageViewState._primaryOrange
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
    required this.targetWeightController,
    required this.workoutSessionsController,
  });

  final TextEditingController genderController;
  final TextEditingController heightController;
  final TextEditingController weightController;
  final TextEditingController goalController;
  final TextEditingController bioController;
  final TextEditingController targetWeightController;
  final TextEditingController workoutSessionsController;

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
        Row(
          children: [
            Expanded(
              child: _Field(
                controller: targetWeightController,
                label: 'Cân nặng mục tiêu (kg)',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Field(
                controller: workoutSessionsController,
                label: 'Số buổi tập/tuần',
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
                selectedColor: _ProfilePageViewState._primaryOrange,
                backgroundColor: Colors.white.withValues(alpha: 0.06),
                side: BorderSide(
                  color: selected == goal
                      ? _ProfilePageViewState._primaryOrange
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
    fillColor: _ProfilePageViewState._inputColor,
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
      borderSide: const BorderSide(color: _ProfilePageViewState._primaryOrange),
    ),
  );
}

BoxDecoration _boxDecoration() {
  return BoxDecoration(
    color: _ProfilePageViewState._cardColor,
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
          CircularProgressIndicator(
            color: _ProfilePageViewState._primaryOrange,
          ),
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
              color: _ProfilePageViewState._primaryOrange,
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

int? _parseInt(String value) {
  final clean = value.trim();
  if (clean.isEmpty) return null;
  return int.tryParse(clean);
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
