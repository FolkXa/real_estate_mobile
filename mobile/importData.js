import fs from "fs";
import path from "path";
import mime from "mime-types";
import dotenv from "dotenv";
import { initializeApp, cert } from "firebase-admin/app";
import { getStorage } from "firebase-admin/storage";
import { getFirestore } from "firebase-admin/firestore";

// Load env
dotenv.config();

// ✅ Initialize Firebase Admin
const serviceAccount = JSON.parse(
  fs.readFileSync("serviceAccountKey.json", "utf8")
);

initializeApp({
  credential: cert(serviceAccount),
  storageBucket: process.env.FIREBASE_STORAGE_BUCKET,
});

const db = getFirestore();
const bucket = getStorage().bucket();

// ✅ Read data.json
const rawData = fs.readFileSync("./assets/data/data.json", "utf8");
const jsonData = JSON.parse(rawData);

// ✅ Upload Image to Firebase Storage
async function uploadImage(localPath, destinationPath) {
  const contentType = mime.lookup(localPath) || "application/octet-stream";

  await bucket.upload(localPath, {
    destination: destinationPath,
    metadata: {
      contentType,
    },
  });

  const file = bucket.file(destinationPath);
  await file.makePublic(); // Or use signed URL
  return file.publicUrl(); // 🔁 return public URL
}

// ✅ Upload Firestore Data
async function uploadData(collectionName, dataList, primaryKey) {
  if (!Array.isArray(dataList)) {
    console.error(`❌ Invalid data format in ${collectionName}`);
    return;
  }

  for (const item of dataList) {
    try {
      if (!item[primaryKey]) {
        console.warn(`⚠️ Missing ${primaryKey}:`, item);
        continue;
      }

      const docId = String(item[primaryKey]);
      const data = { ...item };

      // 📸 Handle image upload for users / image_real_estate
      if (
        (collectionName === "users" || collectionName === "image_real_estate") &&
        data.image_path &&
        data.image_path !== "default.jpg"
      ) {
        const localImagePath = path.join("./assets/images", data.image_path);
        if (fs.existsSync(localImagePath)) {
          const firebasePath = `${collectionName}/${data.image_path}`;
          const uploadedUrl = await uploadImage(localImagePath, firebasePath);
          data.image_path = uploadedUrl;
        } else {
          console.warn(`⚠️ Image not found: ${localImagePath}`);
          continue;
        }
      }

      await db.collection(collectionName).doc(docId).set(data);
      console.log(`✅ Uploaded ${collectionName}/${docId}`);
    } catch (error) {
      console.error(`❌ Error uploading ${collectionName}/${item[primaryKey]}`, error);
    }
  }
}

// 🚀 Start Upload Process
(async () => {
  await uploadData("users", jsonData.users, "user_id");
  await uploadData("real_estate", jsonData.real_estate, "real_estate_id");
  await uploadData("image_real_estate", jsonData.image_real_estate, "image_id");
  await uploadData("favorite_real_estate", jsonData.favorite_real_estate, "favorite_id");
  await uploadData("tags", jsonData.tags, "tag_id");
  await uploadData("tag_real_estate", jsonData.tag_real_estate, "tag_real_id");

  console.log("🎉 All data uploaded successfully!");
})();
