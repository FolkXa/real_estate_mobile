# ใช้ Node.js LTS เป็น Base Image
FROM node:18

# กำหนด Working Directory
WORKDIR /app

# คัดลอกไฟล์ package.json และติดตั้ง dependencies
COPY package.json package-lock.json ./
RUN npm install

# คัดลอกโค้ดทั้งหมดเข้าไปใน container
COPY . .

# กำหนด Port
EXPOSE 8080

# คำสั่งเริ่มต้น
CMD ["npm", "run", "dev"]
