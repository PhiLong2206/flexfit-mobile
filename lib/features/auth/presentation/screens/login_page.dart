import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_google_web_button.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_social_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_theme.dart';
import '../../../../core/network/local_storage.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/usecases/google_login_with_id_token_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../data/services/google_login_exception.dart';
import '../providers/auth_provider.dart';
import '../routing/role_routing.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _loginUseCase = sl<LoginUseCase>();
  final _authProvider = sl<AuthProvider>();
  StreamSubscription<GoogleSignInAuthenticationEvent>? _googleAuthSubscription;
  bool _isGoogleWebLoading = false;
  bool _rememberMe = true;
  bool _hidePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    debugPrint('LoginPage initState');

    try {
      _authProvider.addListener(_handleAuthProviderChanged);
      if (kIsWeb) {
        unawaited(_initializeGoogleSignInForWeb());
        _googleAuthSubscription = GoogleSignIn.instance.authenticationEvents
            .listen(_handleGoogleAuthEvent, onError: _handleGoogleAuthError);
      }
    } catch (error, stackTrace) {
      debugPrint('LoginPage async init failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }

    unawaited(_loadRememberedCredentials());
  }

  @override
  void dispose() {
    _googleAuthSubscription?.cancel();
    _authProvider.removeListener(_handleAuthProviderChanged);
    _authProvider.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('LoginPage build start');
    debugPrint(
      kIsWeb
          ? 'before rendering Google button: web'
          : 'before rendering Google button: mobile',
    );

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
                onPressed: _login,
              ),
              const SizedBox(height: 24),
              const _DividerText(text: 'Hoặc tiếp tục với'),
              const SizedBox(height: 18),
              if (kIsWeb)
                AuthGoogleWebButton(isLoading: _isGoogleWebLoading)
              else
                AuthSocialButton(
                  label: 'Tiếp tục với Google',
                  isLoading: _authProvider.isGoogleLoading,
                  onPressed: _loginWithGoogle,
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
    if (_isLoading) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final validationMessage = _validateLogin(email: email, password: password);
    if (validationMessage != null) {
      _showSnackBar(validationMessage);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final session = await _loginUseCase(email: email, password: password);
      if (_rememberMe) {
        await LocalStorage.saveRememberedCredentials(
          email: email,
          password: password,
        );
      } else {
        await LocalStorage.clearRememberedCredentials();
      }
      if (!mounted) return;
      _openRolePage(session.roles);
    } catch (error) {
      if (!mounted) return;
      _showSnackBar(_loginErrorMessage(error));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadRememberedCredentials() async {
    try {
      final credentials = await LocalStorage.getRememberedCredentials();
      if (!mounted) return;
      setState(() {
        _rememberMe = credentials.rememberMe;
        _emailController.text = credentials.email;
        _passwordController.text = credentials.password;
      });
    } catch (error, stackTrace) {
      debugPrint('Loading remembered credentials failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  void _handleAuthProviderChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _initializeGoogleSignInForWeb() async {
    final clientId = AppConstants.googleClientId.trim();
    if (clientId.isEmpty) {
      _showSnackBar('Google đăng nhập chưa được cấu hình.');
      return;
    }

    try {
      await GoogleSignIn.instance.initialize(clientId: clientId);
      if (kDebugMode) {
        debugPrint('Google ClientId used: $clientId');
        debugPrint('Google OAuth origin: ${AppConstants.googleOAuthOrigin}');
      }
    } on StateError catch (error) {
      if (!error.toString().contains('init() has already been called')) {
        rethrow;
      }
    } catch (error) {
      if (!mounted) return;
      _showSnackBar(_googleLoginErrorMessage(error));
    }
  }

  Future<void> _handleGoogleAuthEvent(
    GoogleSignInAuthenticationEvent event,
  ) async {
    if (event is! GoogleSignInAuthenticationEventSignIn) {
      return;
    }
    await _completeGoogleWebLogin(event.user);
  }

  void _handleGoogleAuthError(Object error) {
    if (!mounted) return;
    _showSnackBar(_googleLoginErrorMessage(error));
  }

  Future<void> _completeGoogleWebLogin(GoogleSignInAccount account) async {
    if (_isGoogleWebLoading) {
      return;
    }

    setState(() => _isGoogleWebLoading = true);
    try {
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw const GoogleLoginException('Không lấy được Google ID Token.');
      }

      final session = await sl<GoogleLoginWithIdTokenUseCase>()(idToken);
      if (!mounted) return;
      _openRolePage(session.roles);
    } catch (error) {
      if (!mounted) return;
      _showSnackBar(_googleLoginErrorMessage(error));
    } finally {
      if (mounted) {
        setState(() => _isGoogleWebLoading = false);
      }
    }
  }

  Future<void> _loginWithGoogle() async {
    try {
      final session = await _authProvider.googleLogin();
      if (!mounted) return;
      _openRolePage(session.roles);
    } catch (error) {
      if (!mounted) return;
      _showSnackBar(_googleLoginErrorMessage(error));
    }
  }

  void _openRolePage(Iterable<String> roles) {
    final resolvedRoles = roles.toList(growable: false);
    debugPrint('Auth roles resolved: $resolvedRoles');
    debugPrint('Route target: ${RoleRouting.targetName(resolvedRoles)}');
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => RoleRouting.pageFor(resolvedRoles),
      ),
      (_) => false,
    );
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

  String _googleLoginErrorMessage(Object error) {
    if (error is GoogleLoginException) {
      return error.message;
    }
    if (error is ApiException) {
      final body = error.body?.trim();
      if (body != null && body.isNotEmpty) {
        return body;
      }
      return error.message;
    }
    return error.toString();
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
