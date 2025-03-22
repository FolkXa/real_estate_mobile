import dotenv from "dotenv";
dotenv.config();
import fs from "fs";
import path from "path";
import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3";
import { initializeApp } from "firebase/app";
import { getFirestore, collection, addDoc } from "firebase/firestore";

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
    secretAccessKey: process.env.CLOUDFLARE_SECRET_KEY,
  },
});

// ✅ อ่านไฟล์ JSON
const rawData = fs.readFileSync("./assets/data/data.json", "utf8");
const jsonData = JSON.parse(rawData);

// ✅ ฟังก์ชันอัปโหลดรูปไป R2
async function uploadToR2(localImagePath, fileName) {
  if (!fs.existsSync(localImagePath)) {
    console.warn(`⚠️ ไม่พบไฟล์: ${localImagePath}`);
    return null;
  }

  try {
    const fileBuffer = fs.readFileSync(localImagePath);
    const uploadParams = {
      Bucket: R2_BUCKET_NAME,
      Key: fileName,
      Body: fileBuffer,
      ContentType: "image/jpeg",
    };

    await s3Client.send(new PutObjectCommand(uploadParams));
    return `${R2_PUBLIC_URL}/${fileName}`;
  } catch (error) {
    console.error("❌ อัปโหลดไป R2 ไม่สำเร็จ:", error.message);
    return null;
  }
}

// ✅ ฟังก์ชันอัปโหลดข้อมูลเข้า Firestore
async function uploadData(collectionName, dataList, primaryKey) {
  if (!dataList || !Array.isArray(dataList)) {
    console.error(`❌ ข้อมูล ${collectionName} ไม่ถูกต้อง`);
    return;
  }

  console.log(`🚀 กำลังนำเข้าข้อมูล ${collectionName} (${dataList.length} รายการ)...`);

  for (const item of dataList) {
    try {
      let sanitizedItem = { ...item };

      // ✅ ตรวจสอบว่า `primaryKey` มีค่าหรือไม่
      if (!item[primaryKey]) {
        console.warn(`⚠️ ${primaryKey} หายไปใน item:`, item);
        continue;
      }

      // ✅ กรณีอัปโหลดรูป `image_real_estate`
      if (collectionName === "image_real_estate") {
        if (!item.image_id) {
          console.warn(`⚠️ image_id หายไปใน item:`, item);
          continue;
        }
        const localPath = path.join("./assets/images/", item.image_path);
        const fileName = `real_estate/${item.image_path}`;
        

        const uploadedUrl = await uploadToR2(localPath, fileName);
        if (uploadedUrl) {
          sanitizedItem.image_path = uploadedUrl;
        } else {
          console.warn(`⚠️ ข้ามรูป real_estate_id ${item.real_estate_id}`);
          continue;
        }
      }

      // ✅ กรณีอัปโหลดรูป `users`
if (collectionName === "users") {
  if (!item.user_id) {
    console.warn(`⚠️ user_id หายไปใน item:`, item);
    continue;
  }

  // ✅ ถ้าเป็น default.jpg ให้ข้ามการอัปโหลดและใช้ path เดิม
  if (item.image_path === "default.jpg") {
    console.log(`ℹ️ user_id ${item.user_id} ใช้รูป default.jpg - ข้ามการอัปโหลด`);
  } else {
    const localPath = path.join("./assets/images/", item.image_path);
    const fileName = `users/${item.image_path}`;

    const uploadedUrl = await uploadToR2(localPath, fileName);
    if (uploadedUrl) {
      sanitizedItem.image_path = uploadedUrl;
    } else {
      console.warn(`⚠️ ข้ามรูป user_id ${item.user_id}`);
      continue;
    }
  }
}


      // ✅ เพิ่มข้อมูลเข้า Firestore
      const docRef = await addDoc(collection(db, collectionName), sanitizedItem);
      console.log(`✅ เพิ่ม ${collectionName} ID ${item[primaryKey]} -> Firestore ID: ${docRef.id}`);
    } catch (error) {
      console.error(`❌ เกิดข้อผิดพลาดที่ ${collectionName} ID ${item[primaryKey]}:`, error);
    }
  }

  console.log(`🔥 อัปโหลดข้อมูล ${collectionName} สำเร็จ!`);
}

// 🚀 เริ่มกระบวนการนำเข้า
async function startUploadProcess() {
  try {
    await uploadData("users", jsonData.users, "user_id");
    await uploadData("real_estate", jsonData.real_estate, "real_estate_id");
    await uploadData("image_real_estate", jsonData.image_real_estate, "image_id");
    await uploadData("favorite_real_estate", jsonData.favorite_real_estate, "favorite_id");
    await uploadData("tags", jsonData.tags, "tag_id");
    await uploadData("tag_real_estate", jsonData.tag_real_estate, "tag_real_id");

    console.log("🎉 ข้อมูลทั้งหมดถูกอัปโหลดเรียบร้อยแล้ว! ปิดโปรแกรม...");
    process.exit(0);
  } catch (error) {
    console.error("❌ เกิดข้อผิดพลาดระหว่างการอัปโหลดข้อมูล:", error);
    process.exit(1);
  }
}

startUploadProcess();
