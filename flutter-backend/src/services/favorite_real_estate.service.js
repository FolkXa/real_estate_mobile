const favoriteRealEstateRepository = require('../repositories/favorite_real_estate.repository');

class FavoriteRealEstateService {
    async addFavorite(userId, realEstateId) {
        return await favoriteRealEstateRepository.create(userId, realEstateId);
    }

    async getFavorites() {
        return await favoriteRealEstateRepository.getAll();
    }

    async getFavoriteById(id) {
        return await favoriteRealEstateRepository.getById(id);
    }

    async removeFavorite(id) {
        await favoriteRealEstateRepository.delete(id);
    }
}

module.exports = new FavoriteRealEstateService();