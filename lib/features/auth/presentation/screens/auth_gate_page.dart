import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/local_storage.dart';
import '../routing/role_routing.dart';
import 'login_page.dart';

class AuthGatePage extends StatefulWidget {
  const AuthGatePage({super.key});

  @override
  State<AuthGatePage> createState() => _AuthGatePageState();
}

class _AuthGatePageState extends State<AuthGatePage> {
  late final Future<_AuthGateResult> _sessionFuture;

  @override
  void initState() {
    super.initState();
    _sessionFuture = _loadSession();
  }

  Future<_AuthGateResult> _loadSession() async {
    final isValid = await LocalStorage.hasValidAuthToken();
    if (!isValid) return const _AuthGateResult(isValid: false, roles: []);
    final roles = await LocalStorage.getRoles();
    debugPrint('Auth roles resolved: $roles');
    debugPrint('Route target: ${RoleRouting.targetName(roles)}');
    return _AuthGateResult(isValid: true, roles: roles);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_AuthGateResult>(
      future: _sessionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _SplashView();
        }

        final session = snapshot.data;
        if (session?.isValid == true) {
          return RoleRouting.pageFor(session!.roles);
        }

        return const LoginPage();
      },
    );
  }
}

class _AuthGateResult {
  const _AuthGateResult({required this.isValid, required this.roles});

  final bool isValid;
  final List<String> roles;
}

class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: Center(
        child: CircularProgressIndicator(color: AppConstants.primaryColor),
      ),
    );
  }
}
