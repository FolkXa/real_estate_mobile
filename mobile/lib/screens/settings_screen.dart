import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:real_estate_project/screens/Reset_password_screen.dart';
import '../theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _sendResetPasswordEmail(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: user.email!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('ลิงก์เปลี่ยนรหัสผ่านถูกส่งไปยัง ${user.email}')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              title: Text("Dark Mode"),
              secondary: Icon(Icons.dark_mode),
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.toggleTheme(value);
              },
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.lock),
              title: Text("เปลี่ยนรหัสผ่าน"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ResetPasswordScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
