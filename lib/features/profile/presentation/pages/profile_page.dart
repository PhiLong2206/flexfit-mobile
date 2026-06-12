import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const Color _backgroundColor = Color(0xFF070B14);
  static const Color _cardColor = Color(0xFF111827);
  static const Color _primaryOrange = Color(0xFFFF6B16);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: _backgroundColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: _primaryOrange,
                  child: Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'FlexFit Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Thông tin cá nhân và hoạt động tập luyện sẽ hiển thị tại đây.',
                  style: TextStyle(
                    color: Colors.white70,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
