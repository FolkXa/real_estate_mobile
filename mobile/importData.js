import 'dotenv/config';
import fs from "fs";
import path from "path";
import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3";
import { initializeApp } from "firebase/app";
import { getFirestore, collection, addDoc } from "firebase/firestore";

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

// ✅ ใช้ environment variables
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

      // ✅ กรณีอัปโหลด image_real_estate → อัปโหลดไป R2
      if (collectionName === "image_real_estate") {
        if (!item.image_id) {
          console.warn(`⚠️ image_id หายไปใน item:`, item);
          continue;
        }
      
        const localPath = path.join("./", item.image_path);
        const fileName = `real_estate/${item.image_id}.jpg`;
      
        console.log(`📷 เตรียมอัปโหลด: ${localPath} → ${fileName}`);
      
        const uploadedUrl = await uploadToR2(localPath, fileName);
      
        if (uploadedUrl) {
          sanitizedItem.image_path = uploadedUrl;
          console.log(`✅ image_path ที่ได้: ${uploadedUrl}`);
        } else {
          console.warn(`⚠️ ข้ามรูป real_estate_id ${item.real_estate_id}`);
          continue;
        }
      }
      

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