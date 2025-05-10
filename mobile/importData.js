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

// ✅ ฟังก์ชันนำเข้าข้อมูล real_estate
async function uploadRealEstateData() {
  const realEstateData = jsonData.real_estate;

  if (!realEstateData || !Array.isArray(realEstateData)) {
    console.error("❌ ข้อมูล real_estate ไม่ถูกต้อง");
    return;
  }

  console.log(`🚀 กำลังนำเข้าข้อมูล real_estate (${realEstateData.length} รายการ)...`);

  const uploadPromises = realEstateData.map(async (item, index) => {
    try {
      // ✅ ป้องกัน Rate Limit โดยเพิ่มดีเลย์
      await new Promise(resolve => setTimeout(resolve, index * 100));

      // ✅ แปลงค่าที่เป็น null เป็นค่าเริ่มต้น
      const sanitizedItem = {
        ...item,
        promote_at: item.promote_at || "", // แทนที่ null ด้วย string ว่าง
        promote_end: item.promote_end || ""
      };

      // ✅ เพิ่มข้อมูลเข้า Firestore
      const docRef = await addDoc(collection(db, "real_estate"), sanitizedItem);
      console.log(`✅ เพิ่ม real_estate ID ${item.real_estate_id} -> Firestore ID: ${docRef.id}`);
    } catch (error) {
      console.error(`❌ เกิดข้อผิดพลาดที่ ID ${item.real_estate_id}:`, error);
    }
  });

  await Promise.all(uploadPromises);
  console.log("🔥 อัปโหลดข้อมูล real_estate สำเร็จ!");
}

// 🚀 เริ่มกระบวนการนำเข้า
uploadRealEstateData().then(() => {
  console.log("🎉 ข้อมูล real_estate ถูกอัปโหลดครบถ้วน! ปิดโปรแกรม...");
  process.exit(0);
}).catch((error) => {
  console.error("❌ เกิดข้อผิดพลาด:", error);
  process.exit(1);
});
