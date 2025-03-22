import express from 'express';
import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";

const router = express.Router();

const s3 = new S3Client({
  region: "auto",
  endpoint: process.env.CLOUDFLARE_R2_ENDPOINT,
  credentials: {
    accessKeyId: process.env.CLOUDFLARE_ACCESS_KEY,
    secretAccessKey: process.env.CLOUDFLARE_SECRET_KEY,
  },
});

router.get('/presigned-url', async (req, res) => {
  const fileName = req.query.fileName;
  const contentType = req.query.contentType;

  const command = new PutObjectCommand({
    Bucket: process.env.CLOUDFLARE_R2_BUCKET,
    Key: fileName,
    ContentType: contentType,
  });

  const url = await getSignedUrl(s3, command, { expiresIn: 60 }); // 60 วินาที
  res.json({ url });
});

export default router;
