import dotenv from "dotenv";
dotenv.config();
import { S3Client, DeleteObjectCommand } from "@aws-sdk/client-s3";
import { initializeApp } from "firebase/app";
import { getFirestore, collection, getDocs, deleteDoc, doc } from "firebase/firestore";

// ✅ ตรวจสอบการโหลดค่า `.env`
if (!process.env.CLOUDFLARE_R2_BUCKET || !process.env.CLOUDFLARE_R2_ENDPOINT || !process.env.CLOUDFLARE_ACCESS_KEY || !process.env.CLOUDFLARE_SECRET_KEY) {
  console.error("❌ ค่าจาก .env ไม่ถูกต้อง กรุณาตรวจสอบไฟล์ .env");
  process.exit(1);
}

// ✅ ตั้งค่า Firebase
const firebaseConfig = {
  apiKey: process.env.FIREBASE_API_KEY,
  authDomain: process.env.FIREBASE_AUTH_DOMAIN,
  projectId: process.env.FIREBASE_PROJECT_ID,
  storageBucket: process.env.FIREBASE_STORAGE_BUCKET,
  messagingSenderId: process.env.FIREBASE_MESSAGING_SENDER_ID,
  appId: process.env.FIREBASE_APP_ID
};

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

// ✅ ตั้งค่า Cloudflare R2
const R2_BUCKET_NAME = process.env.CLOUDFLARE_R2_BUCKET;
const R2_PUBLIC_URL = process.env.CLOUDFLARE_R2_PUBLIC_URL;
const s3Client = new S3Client({
  region: "auto",
  endpoint: process.env.CLOUDFLARE_R2_ENDPOINT,
  credentials: {
    accessKeyId: process.env.CLOUDFLARE_ACCESS_KEY,
    secretAccessKey: process.env.CLOUDFLARE_SECRET_KEY
  }
});

// ✅ ฟังก์ชันลบรูปจาก Cloudflare R2
async function deleteImageFromR2(filePath) {
  if (!R2_BUCKET_NAME) {
    console.error("❌ ไม่พบค่า R2_BUCKET_NAME");
    return false;
  }

  console.log(`🗑 กำลังลบรูป: ${filePath} จากบัคเก็ต: ${R2_BUCKET_NAME}`);
  try {
    await s3Client.send(new DeleteObjectCommand({ Bucket: R2_BUCKET_NAME, Key: filePath }));
    console.log(`✅ ลบรูปจาก R2 สำเร็จ: ${filePath}`);
    return true;
  } catch (error) {
    console.error(`❌ เกิดข้อผิดพลาดในการลบรูปจาก R2: ${filePath}`, error.message);
    return false;
  }
}

// ✅ ฟังก์ชันลบข้อมูลจาก Firestore + ลบรูปจาก R2
async function deleteCollectionWithImages(collectionName) {
  const collectionRef = collection(db, collectionName);
  const snapshot = await getDocs(collectionRef);

  if (snapshot.empty) {
    console.log(`🚀 ไม่มีข้อมูลใน ${collectionName}`);
    return;
  }

  console.log(`🗑 กำลังลบข้อมูลใน ${collectionName} (${snapshot.size} รายการ)...`);

  for (const docRef of snapshot.docs) {
    const data = docRef.data();
    let imageUrl = data.image_path;

    if (imageUrl) {
      // ✅ ดึง filePath จาก URL จริง
      if (imageUrl.startsWith(R2_PUBLIC_URL)) {
        imageUrl = imageUrl.replace(`${R2_PUBLIC_URL}/`, "");
      } else {
        console.warn(`⚠️ URL ไม่ใช่ของ R2: ${imageUrl}`);
      }

      console.log(`🔍 เตรียมลบไฟล์: ${imageUrl}`);
      const success = await deleteImageFromR2(imageUrl);
      if (!success) {
        console.warn(`⚠️ ข้ามเอกสาร: ${docRef.id}`);
        continue;
      }
    } else {
      console.warn(`⚠️ ไม่มี image_path ในเอกสาร: ${docRef.id}`);
    }

    try {
      await deleteDoc(doc(db, collectionName, docRef.id));
      console.log(`✅ ลบเอกสาร Firestore: ${docRef.id}`);
    } catch (error) {
      console.error(`❌ ลบเอกสารไม่สำเร็จ (${docRef.id}):`, error);
    }
  }

  console.log(`✅ ลบข้อมูลใน ${collectionName} เสร็จสิ้น`);
}

// ✅ ฟังก์ชันลบข้อมูลทีละคอลเล็กชัน (สำหรับข้อมูลอื่นที่ไม่ใช่รูปภาพ)
async function deleteCollection(collectionName) {
  const collectionRef = collection(db, collectionName);
  const snapshot = await getDocs(collectionRef);

  if (snapshot.empty) {
    console.log(`🚀 ไม่มีข้อมูลใน ${collectionName}`);
    return;
  }

  console.log(`🗑 กำลังลบข้อมูลใน ${collectionName} (${snapshot.size} รายการ)...`);

  let count = 0;
  for (const docRef of snapshot.docs) {
    try {
      await deleteDoc(doc(db, collectionName, docRef.id));
      count++;
      console.log(`✅ ลบเอกสาร: ${docRef.id} (${count}/${snapshot.size})`);
      await new Promise(resolve => setTimeout(resolve, 50)); // ✅ ป้องกัน Rate Limit
    } catch (error) {
      console.error(`❌ ลบเอกสารไม่สำเร็จ (${docRef.id}):`, error);
    }
  }

  console.log(`✅ ลบข้อมูลใน ${collectionName} เสร็จสิ้น`);
}

// ✅ ฟังก์ชันลบทุกคอลเล็กชัน
async function deleteAllCollections() {
  const collections = ["users", "real_estate", "image_real_estate", "favorite_real_estate", "tags", "tag_real_estate"];

  for (const collectionName of collections) {
    if (collectionName === "image_real_estate") {
      console.log(`🖼 ลบรูปจาก Cloudflare R2 ก่อน`);
      await deleteCollectionWithImages(collectionName);
    } else {
      await deleteCollection(collectionName);
    }
    await new Promise(resolve => setTimeout(resolve, 200)); // ✅ ป้องกัน Rate Limit ระหว่างคอลเล็กชัน
  }
}

// 🚀 เริ่มกระบวนการลบข้อมูล
deleteAllCollections()
  .then(() => {
    console.log("🔥 ลบข้อมูลและรูปทั้งหมดเรียบร้อย!");
    process.exit(0);
  })
  .catch((error) => {
    console.error("❌ เกิดข้อผิดพลาด:", error);
    process.exit(1);
  });
