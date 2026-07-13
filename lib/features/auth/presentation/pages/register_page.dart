import 'package:flutter/material.dart';

import '../widgets/auth_button.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_social_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_theme.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../../home/presentation/pages/home_page.dart';
import 'verify_otp_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authRepository = AuthRepositoryImpl();
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_rounded),
                color: AuthTheme.text,
                tooltip: 'Quay lại',
              ),
              const SizedBox(height: 8),
              const AuthHeader(
                title: 'Tạo tài khoản mới',
                subtitle: 'Tham gia mạng lưới fitness hàng đầu Việt Nam',
                showLogo: false,
              ),
              const SizedBox(height: 28),
              AuthTextField(
                controller: _nameController,
                label: 'Họ và tên',
                icon: Icons.person_outline,
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 14),
              AuthTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),
              AuthTextField(
                controller: _phoneController,
                label: 'Số điện thoại',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 14),
              AuthTextField(
                controller: _passwordController,
                label: 'Mật khẩu',
                icon: Icons.lock_outline,
                obscureText: _hidePassword,
                suffixIcon: IconButton(
                  tooltip: _hidePassword ? 'Hiện mật khẩu' : 'Ẩn mật khẩu',
                  onPressed: () {
                    setState(() => _hidePassword = !_hidePassword);
                  },
                  icon: Icon(
                    _hidePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AuthTheme.secondaryText,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              AuthTextField(
                controller: _confirmPasswordController,
                label: 'Xác nhận mật khẩu',
                icon: Icons.verified_user_outlined,
                obscureText: _hideConfirmPassword,
                suffixIcon: IconButton(
                  tooltip: _hideConfirmPassword
                      ? 'Hiện mật khẩu'
                      : 'Ẩn mật khẩu',
                  onPressed: () {
                    setState(
                      () => _hideConfirmPassword = !_hideConfirmPassword,
                    );
                  },
                  icon: Icon(
                    _hideConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AuthTheme.secondaryText,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              AuthButton(
                label: 'Đăng ký',
                isLoading: _isLoading,
                onPressed: _isLoading || _isGoogleLoading ? null : _register,
              ),
              const SizedBox(height: 24),
              const _DividerText(text: 'Hoặc đăng ký bằng'),
              const SizedBox(height: 18),
              AuthSocialButton(
                label: 'Đăng ký với Google',
                isLoading: _isGoogleLoading,
                onPressed: _isLoading || _isGoogleLoading ? null : _loginWithGoogle,
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Flexible(
                    child: Text(
                      'Đã có tài khoản?',
                      style: TextStyle(
                        color: AuthTheme.secondaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: const Text('Đăng nhập'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _register() async {
    if (_isLoading || _isGoogleLoading) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final validationMessage = _validateRegister(
      name: name,
      email: email,
      phone: phone,
      password: password,
      confirmPassword: confirmPassword,
    );
    if (validationMessage != null) {
      _showSnackBar(validationMessage);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authRepository.register(
        fullName: name,
        email: email,
        password: password,
        phoneNumber: phone,
      );
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => VerifyOtpPage(email: email)),
      );
    } catch (error) {
      if (!mounted) return;
      _showSnackBar(_registerErrorMessage(error));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loginWithGoogle() async {
    if (_isLoading || _isGoogleLoading) return;

    setState(() => _isGoogleLoading = true);
    try {
      await _authRepository.loginWithGoogle();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          settings: const RouteSettings(name: HomePage.routeName),
          builder: (_) => const HomePage(),
        ),
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;
      _showSnackBar('Đăng nhập bằng Google thất bại');
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  String? _validateRegister({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) {
    if (name.isEmpty) {
      return 'Vui lòng nhập họ và tên';
    }
    if (email.isEmpty) {
      return 'Vui lòng nhập email';
    }
    if (!email.contains('@')) {
      return 'Email không hợp lệ';
    }
    if (phone.isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }
    if (password.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (confirmPassword.isEmpty) {
      return 'Vui lòng xác nhận mật khẩu';
    }
    if (password != confirmPassword) {
      return 'Mật khẩu không khớp';
    }
    return null;
  }

  String _registerErrorMessage(Object error) {
    final message = error.toString();
    if (message.trim().isNotEmpty) {
      return message;
    }
    return 'Đăng ký thất bại';
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _DividerText extends StatelessWidget {
  const _DividerText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AuthTheme.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            text,
            style: const TextStyle(
              color: AuthTheme.secondaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AuthTheme.border)),
      ],
    );
  }
}
