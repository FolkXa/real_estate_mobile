import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:real_estate_project/CameraScreen.dart';
import 'package:real_estate_project/services/user_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/widgets.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserService _userService = UserService();
  Map<String, dynamic> originalData = {};

  Map<String, TextEditingController> controllers = {};
  bool isEditing = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    for (var controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (!isEditing) return true;

    bool hasChanged = controllers.entries.any((entry) {
      return entry.value.text !=
          (_userService.cachedUserData?[entry.key]?.toString() ?? '');
    });

    if (!hasChanged) return true;

    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("คุณแน่ใจหรือไม่?"),
        content:
            Text("คุณได้แก้ไขข้อมูล แต่ยังไม่ได้บันทึก ต้องการออกหรือไม่?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text("อยู่ต่อ"),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text("ออก"),
          ),
        ],
      ),
    );

    return shouldLeave ?? false;
  }

  Future<void> _loadData() async {
    final data = await _userService.getCurrentUserData();
    if (data != null) {
      originalData = Map<String, dynamic>.from(data);
      data.forEach((key, value) {
        controllers[key] = TextEditingController(text: value?.toString() ?? '');
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _pickAndPreviewImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile == null) return;

    final imageFile = File(pickedFile.path);

    // แสดง preview
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('ยืนยันการเปลี่ยนรูปโปรไฟล์'),
        content: Image.file(imageFile),
        actions: [
          TextButton(
            child: Text("ยกเลิก"),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            child: Text("ยืนยัน"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // เรียกใช้ service เพื่ออัปโหลด และอัปเดต Firestore
      final newImageUrl = await _userService.changeProfileImage(
        controllers["image_path"]?.text ?? "",
        imageFile,
      );

      if (newImageUrl != null) {
        setState(() {
          controllers["image_path"]?.text = newImageUrl;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เปลี่ยนรูปโปรไฟล์สำเร็จ')),
        );
      }
    }
  }

  Future<void> _saveChanges() async {
    final updatedData = {
      for (var entry in controllers.entries) entry.key: entry.value.text,
    };

    await _userService.updateUserData(updatedData);

    setState(() {
      isEditing = false;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("อัปเดตข้อมูลเรียบร้อยแล้ว")));
  }

  Future<DocumentSnapshot?> _getUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: user.email)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty ? snapshot.docs.first : null;
  }

  void _onEditPressed(BuildContext context, Map<String, dynamic> userData) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('ไปหน้าแก้ไขข้อมูล (ยังไม่ทำ)')),
    );
  }

  void _onImageTapped(BuildContext context, String imageUrl) {
    final picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.visibility),
              title: Text('ดูรูปโปรไฟล์'),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    content: Image.network(imageUrl),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_camera),
              title: Text('ถ่ายรูปใหม่'),
              onTap: () {
                Navigator.pop(context);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CameraScreen(
                        onImageTaken: (imagePath) async {
                          final imageFile = File(imagePath);

                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text('ยืนยันการเปลี่ยนรูปโปรไฟล์'),
                              content: Image.file(imageFile),
                              actions: [
                                TextButton(
                                  child: Text("ยกเลิก"),
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                ),
                                ElevatedButton(
                                  child: Text("ยืนยัน"),
                                  onPressed: () => Navigator.pop(context, true),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            final newImageUrl =
                                await _userService.changeProfileImage(
                              controllers["image_path"]?.text ?? "",
                              imageFile,
                            );

                            if (newImageUrl != null) {
                              setState(() {
                                controllers["image_path"]?.text = newImageUrl;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('เปลี่ยนรูปโปรไฟล์สำเร็จ')),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  );
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('เลือกรูปจากแกลเลอรี'),
              onTap: () {
                Navigator.pop(context);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _pickAndPreviewImage(ImageSource.gallery);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text("My Profile")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final imageUrl = controllers["image_path"]?.text ??
        "https://i.ibb.co/7C5jfjq/placeholder.jpg";

    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (didPop) return;

          final hasChanges = isEditing &&
              controllers.entries.any((entry) =>
                  entry.value.text.trim() !=
                  (_userService.cachedUserData?[entry.key]?.toString() ?? ''));

          if (hasChanges) {
            final shouldLeave = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text("คุณแน่ใจหรือไม่?"),
                content: const Text("คุณมีข้อมูลที่ยังไม่ได้บันทึก"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text("อยู่ต่อ"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text("ออกเลย"),
                  ),
                ],
              ),
            );

            if (shouldLeave == true) {
              // ✅ ใช้ pop แทน maybePop เพื่อให้กลับทันที
              Navigator.of(context).pop();
            }
          } else {
            Navigator.of(context).pop();
          }
        },
        child: Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            title: Text("My Profile"),
            backgroundColor: Colors.purple,
            actions: [
              IconButton(
                icon: Icon(isEditing ? Icons.cancel : Icons.edit),
                onPressed: () => setState(() => isEditing = !isEditing),
              )
            ],
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => _onImageTapped(context, imageUrl),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(imageUrl),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "${controllers["first_name"]?.text ?? ''} ${controllers["last_name"]?.text ?? ''}",
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  "@${controllers["username"]?.text ?? '-'}",
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),
                Chip(
                  label: Text(controllers["role"]?.text ?? "user"),
                  backgroundColor: Colors.purple.shade100,
                  labelStyle: TextStyle(color: Colors.purple[900]),
                ),
                const SizedBox(height: 20),
                Divider(),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      isEditing
                          ? _buildEditableField(
                              "first_name", "ชื่อ", Icons.person)
                          : _buildInfoCard(
                              "ชื่อ",
                              controllers["first_name"]?.text ?? "-",
                              Icons.person),
                      isEditing
                          ? _buildEditableField(
                              "last_name", "นามสกุล", Icons.person)
                          : _buildInfoCard(
                              "นามสกุล",
                              controllers["last_name"]?.text ?? "-",
                              Icons.person),
                      isEditing
                          ? _buildEditableField(
                              "nick_name", "ชื่อเล่น", Icons.face)
                          : _buildInfoCard(
                              "ชื่อเล่น",
                              controllers["nick_name"]?.text ?? "-",
                              Icons.face),
                      isEditing
                          ? _buildEditableField("email", "อีเมล", Icons.email)
                          : _buildInfoCard("อีเมล",
                              controllers["email"]?.text ?? "-", Icons.email),
                      isEditing
                          ? _buildEditableField(
                              "phone_number", "เบอร์โทร", Icons.phone)
                          : _buildInfoCard(
                              "เบอร์โทร",
                              controllers["phone_number"]?.text ?? "-",
                              Icons.phone),
                      const SizedBox(height: 16),
                      if (isEditing)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: _saveChanges,
                              child: Text("บันทึก"),
                            ),
                            OutlinedButton(
                              onPressed: () {
                                // ✅ รีเซ็ตค่ากลับเป็น original
                                originalData.forEach((key, value) {
                                  if (controllers.containsKey(key)) {
                                    controllers[key]?.text =
                                        value?.toString() ?? '';
                                  }
                                });

                                setState(() => isEditing = false);
                              },
                              child: Text("ยกเลิก"),
                            ),
                          ],
                        )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildEditableField(String key, String label, IconData iconData) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
      child: Card(
        key: ValueKey(key + "_field"),
        color: Colors.purple.shade50,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(iconData, color: Colors.purple),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: controllers[key],
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: "กรอก $label",
                    labelText: label,
                    labelStyle: TextStyle(color: Colors.purple.shade700),
                    filled: true,
                    fillColor: Colors.white,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.purple.shade200, width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.purple.shade700, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData iconData) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: Icon(iconData, color: Colors.purple),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
