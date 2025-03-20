import { initializeApp } from "firebase/app";
import { getFirestore, collection, addDoc } from "firebase/firestore";
import fs from "fs";

// ✅ ตั้งค่า Firebase
const firebaseConfig = {
  apiKey: "AIzaSyChHwsM17SBFySEgtHIJtzqRWI0kkJ6kWo",
  authDomain: "pj-realestate.firebaseapp.com",
  projectId: "pj-realestate",
  storageBucket: "pj-realestate.firebasestorage.app",
  messagingSenderId: "266614568627",
  appId: "1:266614568627:android:042069257b56d65dffa2c6"
};

// 🔥 เริ่มต้น Firebase
const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

// ✅ อ่านไฟล์ JSON
const rawData = fs.readFileSync("./assets/data/data.json", "utf8");
const jsonData = JSON.parse(rawData);

// ✅ ฟังก์ชันนำเข้าข้อมูลเข้า Firestore
async function uploadData(collectionName, dataList, primaryKey) {
  if (!dataList || !Array.isArray(dataList)) {
    console.error(`❌ ข้อมูล ${collectionName} ไม่ถูกต้อง`);
    return;
  }

  console.log(`🚀 กำลังนำเข้าข้อมูล ${collectionName} (${dataList.length} รายการ)...`);

  const uploadPromises = dataList.map(async (item, index) => {
    try {
      // ✅ ป้องกัน Rate Limit โดยเพิ่มดีเลย์
      await new Promise(resolve => setTimeout(resolve, index * 100));

      // ✅ แปลงค่าที่เป็น null เป็นค่าเริ่มต้น
      const sanitizedItem = Object.fromEntries(
        Object.entries(item).map(([key, value]) => [key, value ?? ""])
      );

      // ✅ เพิ่มข้อมูลเข้า Firestore
      const docRef = await addDoc(collection(db, collectionName), sanitizedItem);
      console.log(`✅ เพิ่ม ${collectionName} ID ${item[primaryKey]} -> Firestore ID: ${docRef.id}`);
    } catch (error) {
      console.error(`❌ เกิดข้อผิดพลาดที่ ${collectionName} ID ${item[primaryKey]}:`, error);
    }
  });

  await Promise.all(uploadPromises);
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

// 🚀 เริ่มกระบวนการอัปโหลดทั้งหมด
startUploadProcess();
