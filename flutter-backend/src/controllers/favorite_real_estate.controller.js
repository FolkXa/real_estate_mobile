const favoriteRealEstateService = require('../services/favorite_real_estate.service');
class FavoriteRealEstateController {
    async addFavorite(req, res) {
        try {
            const { userId, realEstateId } = req.body;
            const favorite = await favoriteRealEstateService.addFavorite(userId, realEstateId);
            res.status(201).json(favorite);
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    }

    async getFavorites(req, res) {
        try {
            const favorites = await favoriteRealEstateService.getFavorites();
            res.json(favorites);
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    }

    async getFavoriteById(req, res) {
        try {
            const { id } = req.params;
            const favorite = await favoriteRealEstateService.getFavoriteById(id);
            if (!favorite) return res.status(404).json({ message: 'Favorite not found' });
            res.json(favorite);
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    }

    async removeFavorite(req, res) {
        try {
            const { id } = req.params;
            await favoriteRealEstateService.removeFavorite(id);
            res.status(204).send();
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    }
}

module.exports = new FavoriteRealEstateController();
