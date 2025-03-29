import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final oldPassController = TextEditingController();
  final newPassController = TextEditingController();
  final confirmPassController = TextEditingController();
  bool isLoading = false;

  void _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      _showSnack("เกิดข้อผิดพลาด: ไม่พบผู้ใช้งาน");
      return;
    }

    setState(() => isLoading = true);

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: oldPassController.text,
    );

    try {
      // 🔐 Re-authenticate
      await user.reauthenticateWithCredential(credential);

      // 🔄 Update password in Firebase Auth
      await user.updatePassword(newPassController.text);

      // ✅ Update password field in Firestore (ถ้ามีเก็บไว้ หรือแฮชไว้)
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        final docId = userSnapshot.docs.first.id;

        await FirebaseFirestore.instance
            .collection('users')
            .doc(docId)
            .update({"password": newPassController.text}); // หรือ hash ก่อน
      }

      _showSnack("เปลี่ยนรหัสผ่านเรียบร้อยแล้ว", isSuccess: true);
      Navigator.pop(context); // หรือไปหน้าอื่น
    } on FirebaseAuthException catch (e) {
      _showSnack("รหัสผ่านเดิมไม่ถูกต้องหรือเกิดข้อผิดพลาด");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSnack(String msg, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isSuccess ? Colors.green : Colors.red,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("เปลี่ยนรหัสผ่าน")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: oldPassController,
                      obscureText: true,
                      decoration: InputDecoration(labelText: "รหัสผ่านเดิม"),
                      validator: (val) => val == null || val.isEmpty
                          ? "กรุณากรอกรหัสผ่านเดิม"
                          : null,
                    ),
                    TextFormField(
                      controller: newPassController,
                      obscureText: true,
                      decoration: InputDecoration(labelText: "รหัสผ่านใหม่"),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return "กรุณากรอกรหัสผ่านใหม่";
                        }
                        if (val.length < 6) {
                          return "รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: confirmPassController,
                      obscureText: true,
                      decoration:
                          InputDecoration(labelText: "ยืนยันรหัสผ่านใหม่"),
                      validator: (val) => val != newPassController.text
                          ? "รหัสผ่านไม่ตรงกัน"
                          : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _resetPassword,
                      child: Text("บันทึกรหัสผ่านใหม่"),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
