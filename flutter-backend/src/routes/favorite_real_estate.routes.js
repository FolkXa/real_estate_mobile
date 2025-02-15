const express = require('express');
const router = express.Router();
const favoriteRealEstateController = require('../controllers/favorite_real_estate.controller');

router.post('/', favoriteRealEstateController.addFavorite);
router.get('/', favoriteRealEstateController.getFavorites);
router.get('/:id', favoriteRealEstateController.getFavoriteById);
router.delete('/:id', favoriteRealEstateController.removeFavorite);

module.exports = router;