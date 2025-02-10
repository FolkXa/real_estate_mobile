const express = require('express');
const dotenv = require('dotenv');
const userRoutes = require('./routes/user.routes');
const realEstateRoutes = require('./routes/realestate.routes');
const ImageRealEstateRoutes = require('./routes/image_real_estate.routes');
const FovoriteRealEstateRoutes = require('./routes/favorite_real_estate.routes');
const tagRoutes = require('./routes/tag.routes');
const tagRealEstateRoutes = require('./routes/tag_real_estate.routes');

dotenv.config();
const app = express();
const PORT = process.env.PORT || 8080;

app.use(express.json());
app.use('/users', userRoutes);
app.use('/real_estates', realEstateRoutes);
app.use('/image_real_estates', ImageRealEstateRoutes);
app.use('/favorites_real_estates', FovoriteRealEstateRoutes);
app.use('/tags', tagRoutes);
app.use('/tag_real_estates', tagRealEstateRoutes);
app.listen(PORT, () => {
    console.log(`🚀 Server running on http://localhost:${PORT}`);
});