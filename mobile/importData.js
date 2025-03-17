const admin = require("firebase-admin");
const fs = require("fs");

// โหลด Service Account Key (ดาวน์โหลดจาก Firebase Console)
const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// อ่าน JSON ไฟล์
const rawData = fs.readFileSync("assets/data/data.json", "utf8");
const jsonData = JSON.parse(rawData);

async function importCollection(collectionName, data) {
    const batch = db.batch();
    data.forEach((item) => {
      // ถ้า `item.id` มีค่าให้ใช้เป็น doc ID, ถ้าไม่มีให้ Firestore สร้างอัตโนมัติ
      const docRef = item.id ? db.collection(collectionName).doc(item.id.toString()) : db.collection(collectionName).doc();
      batch.set(docRef, item);
    });
  
    await batch.commit();
    console.log(`✅ ข้อมูล ${collectionName} ถูกนำเข้าสู่ Firestore สำเร็จ!`);
  }
  

// ฟังก์ชันหลักสำหรับนำเข้าข้อมูลทั้งหมด
async function importData() {
  try {
    await importCollection("users", jsonData.users);
    await importCollection("real_estate", jsonData.real_estate);
    await importCollection("image_real_estate", jsonData.image_real_estate);
    await importCollection("favorite_real_estate", jsonData.favorite_real_estate);
    await importCollection("tags", jsonData.tags);
    await importCollection("tag_real_estate", jsonData.tag_real_estate);

    console.log("🔥 ข้อมูลทั้งหมดถูกอัปโหลดไปยัง Firestore แล้ว!");
  } catch (error) {
    console.error("❌ เกิดข้อผิดพลาดระหว่างการนำเข้าข้อมูล:", error);
  }
}

// รันฟังก์ชันนำเข้าข้อมูล
importData();
