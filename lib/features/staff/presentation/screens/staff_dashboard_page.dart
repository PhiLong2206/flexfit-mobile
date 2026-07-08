import 'package:flutter/material.dart';

import '../../../../core/network/local_storage.dart';
import '../../../auth/presentation/screens/login_page.dart';

class StaffDashboardPage extends StatelessWidget {
  const StaffDashboardPage({super.key});

  Future<void> _logout(BuildContext context) async {
    await LocalStorage.removeToken();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Staff')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Welcome to the FlexFit Staff area.'),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
