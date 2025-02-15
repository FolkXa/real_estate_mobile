const realEstateService = require('../services/realestate.service');

class RealEstateController {
    async getAll(req, res) {
        try {
            const properties = await realEstateService.getAll();
            res.json(properties);
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    }

    async getById(req, res) {
        try {
            const property = await realEstateService.getById(req.params.id);
            if (!property) return res.status(404).json({ message: 'Property not found' });
            res.json(property);
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    }

    async create(req, res) {
        try {
            const newProperty = await realEstateService.create(req.body);
            res.status(201).json(newProperty);
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    }

    async update(req, res) {
        try {
            const updatedProperty = await realEstateService.update(req.params.id, req.body);
            res.json(updatedProperty);
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    }

    async delete(req, res) {
        try {
            const deletedProperty = await realEstateService.delete(req.params.id);
            res.json(deletedProperty);
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    }
    async reactivateRealEstate(req, res) {
        try {
            const realEstateId = req.params.id; 
            const updatedRealEstate = await realEstateService.reactivateRealEstate(realEstateId);
            if (!updatedRealEstate) {
                return res.status(404).json({ message: 'Real estate not found or already active' });
            }
            res.json(updatedRealEstate); 
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    }
    async activatePremiumPromotion(req, res) {
        try {
            const { id } = req.params;
            const { promotionDuration } = req.body;
            const updatedProperty = await realEstateService.activatePremiumPromotion(id, promotionDuration);
            if (!updatedProperty) {
                return res.status(404).json({ message: 'Real estate not found' });
            }
            res.json(updatedProperty);
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    }

    async deactivatePremiumPromotion(req, res) {
        try {
            const { id } = req.params;
            const updatedProperty = await realEstateService.deactivatePremiumPromotion(id);
            if (!updatedProperty) {
                return res.status(404).json({ message: 'Real estate not found' });
            }
            res.json(updatedProperty);
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    }
    async incrementView(req, res) {
        try {
            const { id } = req.params;
            const updatedProperty = await realEstateService.incrementView(id);
            if (!updatedProperty) {
                return res.status(404).json({ message: 'Real estate not found' });
            }
            res.json(updatedProperty);
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    }

}

module.exports = new RealEstateController();
