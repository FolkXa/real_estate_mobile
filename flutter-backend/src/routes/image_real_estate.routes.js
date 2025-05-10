const express = require('express');
const router = express.Router();
const imageRealEstateController = require('../controllers/image_real_estate.controller');

router.get('/', imageRealEstateController.getAll);
router.get('/:realEstateId', imageRealEstateController.getByRealEstateId);
router.post('/', imageRealEstateController.create);
router.delete('/:id', imageRealEstateController.delete);

module.exports = router;