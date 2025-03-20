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

// 🔥 เริ่มต้น Firebase
const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

// ✅ ฟังก์ชันลบข้อมูลทีละคอลเล็กชัน
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
    await deleteCollection(collectionName);
    await new Promise(resolve => setTimeout(resolve, 200)); // ✅ ป้องกัน Rate Limit ระหว่างคอลเล็กชัน
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
