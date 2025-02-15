const tagRealEstateRepository = require('../repositories/tag_real_estate.repository');

class TagRealEstateService {
    async getAll() {
        return await tagRealEstateRepository.getAll();
    }

    async getByRealEstateId(realEstateId) {
        return await tagRealEstateRepository.getByRealEstateId(realEstateId);
    }

    async getRealEstateByTagId(tagId) {
        return await tagRealEstateRepository.getRealEstateByTagId(tagId);
    }

    async create(data) {
        return await tagRealEstateRepository.create(data);
    }

    async delete(id) {
        return await tagRealEstateRepository.delete(id);
    }
}

module.exports = new TagRealEstateService();
