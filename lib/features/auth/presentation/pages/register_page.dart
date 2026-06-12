import 'package:flutter/material.dart';

import '../widgets/auth_button.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_social_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_theme.dart';
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
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

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
                onPressed: () {
                  debugPrint('Register tapped: ${_emailController.text}');
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const VerifyOtpPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              const _DividerText(text: 'Hoặc đăng ký bằng'),
              const SizedBox(height: 18),
              AuthSocialButton(
                label: 'Đăng ký với Google',
                onPressed: () {
                  debugPrint('Google register tapped');
                },
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
