import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isSending = false;

  Future<void> _sendPasswordResetEmail() async {
    setState(() => _isSending = true);
    final email = _emailController.text.trim();

    try {
      if (email.isEmpty) {
        _showSnackBar("กรุณากรอกอีเมล", Colors.red);
        setState(() => _isSending = false);
        return;
      }

      await _auth.sendPasswordResetEmail(email: email);
      _showSnackBar("ส่งลิงก์รีเซ็ตรหัสผ่านไปที่ $email แล้ว", Colors.green);
    } catch (e) {
      _showSnackBar("เกิดข้อผิดพลาด: ${e.toString()}", Colors.red);
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _showSnackBar(String message, Color bgColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: bgColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("ลืมรหัสผ่าน"),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(
              "กรุณากรอกอีเมลของคุณเพื่อรับลิงก์รีเซ็ตรหัสผ่าน",
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Email",
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSending ? null : _sendPasswordResetEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSending
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "ส่งลิงก์รีเซ็ตรหัสผ่าน",
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
