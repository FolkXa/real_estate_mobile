#!/bin/bash

echo "🚀 กำลังลบข้อมูล Firestore..."
node deleteFirestoreData.js

clear

echo "🔥 กำลังนำเข้าข้อมูล Firestore..."
node importData.js
clear

echo "✅ เสร็จสิ้น! Firestore ถูกรีเซ็ตและนำเข้าข้อมูลใหม่เรียบร้อย 🎯"
