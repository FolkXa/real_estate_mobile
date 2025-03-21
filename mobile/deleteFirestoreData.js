import dotenv from "dotenv";
dotenv.config();
import { S3Client, DeleteObjectCommand } from "@aws-sdk/client-s3";
import { initializeApp } from "firebase/app";
import { getFirestore, collection, getDocs, deleteDoc, doc } from "firebase/firestore";

// ✅ ตั้งค่า Firebase
const firebaseConfig = {
  apiKey: "AIzaSyChHwsM17SBFySEgtHIJtzqRWI0kkJ6kWo",
  authDomain: "pj-realestate.firebaseapp.com",
  projectId: "pj-realestate",
  storageBucket: "pj-realestate.firebasestorage.app",
  messagingSenderId: "266614568627",
  appId: "1:266614568627:android:042069257b56d65dffa2c6"
};

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

const R2_BUCKET_NAME = process.env.CLOUDFLARE_R2_BUCKET;

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
    const imageUrl = data.image_path; // 🔥 ใช้ image_path ที่เก็บไว้

    if (imageUrl) {
      const filePath = imageUrl.replace("https://pub-33d01538ba524615b21478ed0f03e519.r2.dev/", "");
      const success = await deleteImageFromR2(filePath);
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

// ✅ ฟังก์ชันลบทุกคอลเล็กชัน
async function deleteAllCollections() {
  const collections = ["users", "real_estate", "image_real_estate", "favorite_real_estate", "tags", "tag_real_estate"];

  for (const collectionName of collections) {
    if (collectionName === "image_real_estate") {
      // 🔥 ลบรูปจาก R2 ก่อนลบข้อมูล Firestore
      await deleteCollectionWithImages(collectionName);
    } else {
      await deleteCollection(collectionName);
    }
    await new Promise(resolve => setTimeout(resolve, 200)); // ✅ ป้องกัน Rate Limit ระหว่างคอลเล็กชัน
  }
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
