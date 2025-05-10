import { initializeApp } from "firebase/app";
import { getFirestore, collection, getDocs, deleteDoc, doc, addDoc } from "firebase/firestore";

// ✅ ตั้งค่า Firebase (ใช้ค่าจาก google-services.json)
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

// ✅ ฟังก์ชันลบข้อมูลทั้งหมด
async function deleteAllCollections() {
  const collections = ["users", "real_estate", "image_real_estate", "favorite_real_estate", "tags", "tag_real_estate"];

  for (const collectionName of collections) {
    const collectionRef = collection(db, collectionName);
    const snapshot = await getDocs(collectionRef);

    if (snapshot.empty) {
      console.log(`🚀 ไม่มีข้อมูลใน ${collectionName}`);
      continue;
    }

    console.log(`🗑 กำลังลบข้อมูลใน ${collectionName} (${snapshot.size} รายการ)...`);

    const deletePromises = snapshot.docs.map((docRef) => deleteDoc(doc(db, collectionName, docRef.id)));
    await Promise.all(deletePromises);

    console.log(`✅ ลบข้อมูลใน ${collectionName} เสร็จสิ้น`);
  }
}

deleteAllCollections()
  .then(() => {
    console.log("🔥 ลบข้อมูลทั้งหมดเรียบร้อย!");
    process.exit(0);
  })
  .catch((error) => {
    console.error("❌ เกิดข้อผิดพลาด:", error);
    process.exit(1);
  });
