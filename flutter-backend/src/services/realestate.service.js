const realEstateRepository = require('../repositories/realestate.repository');

class RealEstateService {
    async getAll() {
        return await realEstateRepository.getAll();
    }

    async getById(id) {
        return await realEstateRepository.getById(id);
    }

    async create(data) {
        return await realEstateRepository.create(data);
    }

    async update(id, data) {
        return await realEstateRepository.update(id, data);
    }

    async delete(id) {
        return await realEstateRepository.softDelete(id);
    }
    async reactivateRealEstate(realEstateId) {
        return await realEstateRepository.reactivateRealEstate(realEstateId);
    }
    async activatePremiumPromotion(id, promotionDuration) {
        return await realEstateRepository.activatePremiumPromotion(id, promotionDuration);
    }
    async deactivatePremiumPromotion(id) {
        return await realEstateRepository.deactivatePremiumPromotion(id);
    }

    async incrementView(id) {
        return await realEstateRepository.incrementView(id);
    }

}

module.exports = new RealEstateService();
