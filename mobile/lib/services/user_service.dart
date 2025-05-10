import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image/image.dart' as img;

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? cachedUserData;

  Future<Map<String, dynamic>?> getCurrentUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final snapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        cachedUserData = snapshot.docs.first.data();
        return cachedUserData;
      }
    }
    return null;
  }

  Future<void> updateUserData(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user != null) {
      final docRef = await _firestore
          .collection('users')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();

      if (docRef.docs.isNotEmpty) {
        final sanitizedData = data.map((key, value) {
          if (key == 'user_id') {
            return MapEntry(key, int.tryParse(value.toString()) ?? 0);
          } else if (key == 'active') {
            return MapEntry(key, value == 'true' || value == true);
          } else {
            return MapEntry(key, value);
          }
        });

        await docRef.docs.first.reference.update(sanitizedData);
        cachedUserData = sanitizedData;
      }
    }
  }

  Future<File> compressImage(File file) async {
    final originalBytes = await file.readAsBytes();
    final decodedImage = img.decodeImage(originalBytes);

    final resized = img.copyResize(decodedImage!, width: 800); // ลดความกว้าง
    final compressedBytes = img.encodeJpg(resized, quality: 85); // บีบอัด

    final tempDir = Directory.systemTemp;
    final compressedFile = File('${tempDir.path}/${path.basename(file.path)}');
    await compressedFile.writeAsBytes(compressedBytes);

    return compressedFile;
  }

  Future<String?> changeProfileImage(String oldImageUrl, File file) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    // ✅ ค้นหา document ID จาก email
    final snapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: user.email)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      print("❌ ไม่พบผู้ใช้ใน Firestore ด้วย email นี้");
      return null;
    }

    final docRef = snapshot.docs.first.reference;

    // ✅ Compress รูปก่อนอัปโหลด
    final compressedFile = await compressImage(file);

    final fileName =
        "${user.uid}_${DateTime.now().millisecondsSinceEpoch}${path.extension(file.path)}";
    final mimeType =
        lookupMimeType(compressedFile.path) ?? 'application/octet-stream';

    final bucket = dotenv.env['FIREBASE_STORAGE_BUCKET']!;
    final storage = FirebaseStorage.instance;
    final ref = storage.ref().child('users/$fileName');

    // ✅ อัปโหลด
    await ref.putFile(compressedFile, SettableMetadata(contentType: mimeType));
    final newImageUrl = await ref.getDownloadURL();

    if (oldImageUrl.isNotEmpty) {
      try {
        // ดึง path ระหว่าง `o/` กับ `?alt=media` และถอดรหัส
        final start = oldImageUrl.indexOf("/o/") + 3;
        final end = oldImageUrl.indexOf("?alt=");
        final encodedPath = oldImageUrl.substring(start, end);
        final decodedPath = Uri.decodeFull(encodedPath); // users/xxxx.jpg

        final oldRef = FirebaseStorage.instance.ref().child(decodedPath);
        await oldRef.delete();

        print("✅ ลบรูปเก่าสำเร็จ: $decodedPath");
      } catch (e) {
        print("⚠️ ลบรูปเก่าไม่สำเร็จ: $e");
      }
    }

    // ✅ อัปเดตเฉพาะ image_path โดยใช้ doc ที่หาได้จาก email
    await docRef.update({
      'image_path': newImageUrl,
    });

    return newImageUrl;
  }
}
