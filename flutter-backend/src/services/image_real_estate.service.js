const imageRealEstateRepository = require('../repositories/image_real_estate.repository');

class ImageRealEstateService {
    async getAll() {
        return await imageRealEstateRepository.getAll();
    }

    async getByRealEstateId(realEstateId) {
        return await imageRealEstateRepository.getByRealEstateId(realEstateId);
    }

    async create(data) {
        return await imageRealEstateRepository.create(data);
    }

    async delete(id) {
        return await imageRealEstateRepository.delete(id);
    }
}

module.exports = new ImageRealEstateService();