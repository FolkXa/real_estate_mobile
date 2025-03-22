const express = require('express');
const router = express.Router();
const tagRealEstateController = require('../controllers/tag_real_estate.controller');

router.get('/', tagRealEstateController.getAll);
router.get('/real_estate/:realEstateId', tagRealEstateController.getByRealEstateId);
router.get('/tag/:tagId', tagRealEstateController.getRealEstateByTagId);
router.post('/', tagRealEstateController.create);
router.delete('/:id', tagRealEstateController.delete);

module.exports = router;
