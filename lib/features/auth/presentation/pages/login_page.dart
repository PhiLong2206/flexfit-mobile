import 'package:flutter/material.dart';

import '../widgets/auth_button.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_social_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_theme.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../../home/presentation/pages/home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authRepository = AuthRepositoryImpl();
  bool _rememberMe = true;
  bool _hidePassword = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
              const AuthHeader(
                title: 'Chào mừng trở lại',
                subtitle: 'Đăng nhập để tiếp tục hành trình tập luyện của bạn',
              ),
              const SizedBox(height: 28),
              AuthTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
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
              const SizedBox(height: 8),
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    activeColor: AuthTheme.primary,
                    checkColor: AuthTheme.text,
                    side: const BorderSide(color: AuthTheme.border),
                    onChanged: (value) {
                      setState(() => _rememberMe = value ?? false);
                    },
                  ),
                  const Expanded(
                    child: Text(
                      'Ghi nhớ đăng nhập',
                      style: TextStyle(
                        color: AuthTheme.secondaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      debugPrint('Forgot password tapped');
                    },
                    child: const Text('Quên mật khẩu?'),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              AuthButton(
                label: 'Đăng nhập',
                isLoading: _isLoading,
                onPressed: _isLoading || _isGoogleLoading ? null : _login,
              ),
              const SizedBox(height: 24),
              const _DividerText(text: 'Hoặc tiếp tục với'),
              const SizedBox(height: 18),
              AuthSocialButton(
                label: 'Tiếp tục với Google',
                isLoading: _isGoogleLoading,
                onPressed: _isLoading || _isGoogleLoading ? null : _loginWithGoogle,
              ),
              const SizedBox(height: 28),
              _BottomPrompt(
                text: 'Chưa có tài khoản?',
                action: 'Đăng ký ngay',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const RegisterPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (_isLoading || _isGoogleLoading) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final validationMessage = _validateLogin(email: email, password: password);
    if (validationMessage != null) {
      _showSnackBar(validationMessage);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authRepository.login(email: email, password: password);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          settings: const RouteSettings(name: HomePage.routeName),
          builder: (_) => const HomePage(),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      _showSnackBar(_loginErrorMessage(error));
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
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          settings: const RouteSettings(name: HomePage.routeName),
          builder: (_) => const HomePage(),
        ),
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

  String? _validateLogin({required String email, required String password}) {
    if (email.isEmpty && password.isEmpty) {
      return 'Vui lòng nhập email và mật khẩu';
    }
    if (email.isEmpty) {
      return 'Vui lòng nhập email';
    }
    if (!email.contains('@')) {
      return 'Email không hợp lệ';
    }
    if (password.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (password.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    return null;
  }

  String _loginErrorMessage(Object error) {
    final message = error.toString().toLowerCase();
    if (message.contains('email') &&
        (message.contains('không tồn tại') ||
            message.contains('khong ton tai') ||
            message.contains('not exist') ||
            message.contains('not found'))) {
      return 'Email không tồn tại';
    }
    if (message.contains('mật khẩu') ||
        message.contains('mat khau') ||
        message.contains('password')) {
      return 'Mật khẩu không đúng';
    }
    return 'Đăng nhập thất bại';
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

class _BottomPrompt extends StatelessWidget {
  const _BottomPrompt({
    required this.text,
    required this.action,
    required this.onPressed,
  });

  final String text;
  final String action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              color: AuthTheme.secondaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextButton(onPressed: onPressed, child: Text(action)),
      ],
    );
  }
}
