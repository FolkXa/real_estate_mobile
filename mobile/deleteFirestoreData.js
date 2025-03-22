import dotenv from "dotenv";
dotenv.config();

import fs from "fs";
import { initializeApp, cert } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import { getStorage } from "firebase-admin/storage";

// ✅ เรียกใช้ Firebase Admin ด้วย service account
const serviceAccount = JSON.parse(fs.readFileSync("serviceAccountKey.json", "utf8"));

initializeApp({
  credential: cert(serviceAccount),
  storageBucket: process.env.FIREBASE_STORAGE_BUCKET,
});

const db = getFirestore();
const bucket = getStorage().bucket();

// ✅ ฟังก์ชันลบรูปจาก Firebase Storage
async function deleteImageFromFirebaseStorage(filePath) {
  try {
    await bucket.file(filePath).delete();
    console.log(`✅ ลบรูปจาก Firebase Storage: ${filePath}`);
    return true;
  } catch (error) {
    console.error(`❌ ลบรูปไม่สำเร็จ: ${filePath}`, error.message);
    return false;
  }
}

// ✅ ฟังก์ชันลบข้อมูลจาก Firestore + ลบรูปจาก Firebase Storage
async function deleteCollectionWithImages(collectionName) {
  const snapshot = await db.collection(collectionName).get();

  if (snapshot.empty) {
    console.log(`🚀 ไม่มีข้อมูลใน ${collectionName}`);
    return;
  }

  console.log(`🗑 กำลังลบข้อมูลใน ${collectionName} (${snapshot.size} รายการ)...`);

  for (const docRef of snapshot.docs) {
    const data = docRef.data();
    let imagePath = data.image_path;

    if (imagePath && imagePath.startsWith("https://firebasestorage.googleapis.com")) {
      const matched = imagePath.match(/%2F(.+)\?alt=/); // ดึง path จาก public URL
      if (matched && matched[1]) {
        imagePath = decodeURIComponent(matched[1]);
      } else {
        console.warn(`⚠️ หา path ไม่เจอจาก URL: ${imagePath}`);
        imagePath = null;
      }
    }

    if (imagePath) {
      const success = await deleteImageFromFirebaseStorage(imagePath);
      if (!success) {
        console.warn(`⚠️ ข้ามเอกสาร: ${docRef.id}`);
        continue;
      }
    } else {
      console.warn(`⚠️ ไม่มี image_path ที่ถูกต้องในเอกสาร: ${docRef.id}`);
    }

    try {
      await docRef.ref.delete();
      console.log(`✅ ลบเอกสาร Firestore: ${docRef.id}`);
    } catch (error) {
      console.error(`❌ ลบเอกสารไม่สำเร็จ (${docRef.id}):`, error.message);
    }
  }

  console.log(`✅ ลบข้อมูลใน ${collectionName} เสร็จสิ้น`);
}

// ✅ ฟังก์ชันลบข้อมูลจาก Firestore (ไม่เกี่ยวกับรูป)
async function deleteCollection(collectionName) {
  const snapshot = await db.collection(collectionName).get();

  if (snapshot.empty) {
    console.log(`🚀 ไม่มีข้อมูลใน ${collectionName}`);
    return;
  }

  console.log(`🗑 ลบข้อมูลใน ${collectionName} (${snapshot.size} รายการ)...`);

  let count = 0;
  for (const docRef of snapshot.docs) {
    try {
      await docRef.ref.delete();
      count++;
      console.log(`✅ ลบเอกสาร: ${docRef.id} (${count}/${snapshot.size})`);
    } catch (error) {
      console.error(`❌ ลบเอกสารไม่สำเร็จ (${docRef.id}):`, error.message);
    }
  }

  console.log(`✅ ลบข้อมูลใน ${collectionName} เสร็จสิ้น`);
}

// ✅ ลบหลายคอลเล็กชัน
async function deleteAllCollections() {
  const collections = [
    "users",
    "real_estate",
    "image_real_estate",
    "favorite_real_estate",
    "tags",
    "tag_real_estate",
  ];

  for (const name of collections) {
    if (["users", "image_real_estate"].includes(name)) {
      await deleteCollectionWithImages(name);
    } else {
      await deleteCollection(name);
    }
  }

  console.log("🔥 ลบข้อมูลและรูปทั้งหมดเรียบร้อย!");
}

// 🚀 Start
deleteAllCollections()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("❌ เกิดข้อผิดพลาด:", err);
    process.exit(1);
  });
