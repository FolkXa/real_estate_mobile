const admin = require("firebase-admin");

// โหลด Service Account Key
const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// ฟังก์ชันลบ Collection ทั้งหมด
async function deleteCollection(collectionName) {
  const collectionRef = db.collection(collectionName);
  const snapshot = await collectionRef.get();

  if (snapshot.empty) {
    console.log(`❌ ไม่มีข้อมูลใน Collection: ${collectionName}`);
    return;
  }

  const batch = db.batch();
  snapshot.docs.forEach((doc) => {
    batch.delete(doc.ref);
  });

  await batch.commit();
  console.log(`✅ ลบข้อมูลทั้งหมดใน Collection: ${collectionName} แล้ว`);
}

// ฟังก์ชันหลักลบข้อมูลทั้งหมด
async function resetDatabase() {
  console.log("🚀 กำลังลบข้อมูลทั้งหมดใน Firestore...");
  
  await deleteCollection("users");
  await deleteCollection("real_estate");
  await deleteCollection("image_real_estate");
  await deleteCollection("favorite_real_estate");
  await deleteCollection("tags");
  await deleteCollection("tag_real_estate");

  console.log("🔥 Firestore ถูก Reset สำเร็จ!");
}

// รันฟังก์ชันลบข้อมูล
resetDatabase();
