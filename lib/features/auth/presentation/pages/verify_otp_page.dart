import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/auth_button.dart';
import '../widgets/auth_theme.dart';
import 'login_page.dart';

class VerifyOtpPage extends StatefulWidget {
  const VerifyOtpPage({super.key});

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(6, (_) => TextEditingController());
    _focusNodes = List.generate(6, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
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
              const SizedBox(height: 54),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AuthTheme.primary.withAlpha(30),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AuthTheme.primary.withAlpha(80)),
                ),
                child: const Icon(
                  Icons.mark_email_read_outlined,
                  color: AuthTheme.primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 26),
              const Text(
                'Xác thực OTP',
                style: TextStyle(
                  color: AuthTheme.text,
                  fontSize: 30,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Nhập mã xác thực được gửi đến email của bạn',
                style: TextStyle(
                  color: AuthTheme.secondaryText,
                  fontSize: 15,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 34),
              Row(
                children: List.generate(
                  6,
                  (index) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: index == 5 ? 0 : 8),
                      child: _OtpBox(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 5) {
                            _focusNodes[index + 1].requestFocus();
                          }
                          if (value.isEmpty && index > 0) {
                            _focusNodes[index - 1].requestFocus();
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Center(
                child: TextButton(
                  onPressed: () {
                    debugPrint('Resend OTP tapped');
                  },
                  child: const Text('Gửi lại OTP'),
                ),
              ),
              const SizedBox(height: 28),
              AuthButton(
                label: 'Xác nhận',
                onPressed: () async {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Xác thực thành công!')),
                  );
                  await Future<void>.delayed(const Duration(milliseconds: 600));
                  if (!context.mounted) {
                    return;
                  }
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(builder: (_) => const LoginPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(1),
      ],
      style: const TextStyle(
        color: AuthTheme.text,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
      cursorColor: AuthTheme.primary,
      decoration: InputDecoration(
        counterText: '',
        filled: true,
        fillColor: AuthTheme.card,
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AuthTheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AuthTheme.primary, width: 1.4),
        ),
      ),
    );
  }
}
