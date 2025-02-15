const tagRealEstateService = require('../services/tag_real_estate.service');

class TagRealEstateController {
    async getAll(req, res) {
        try {
            const tags = await tagRealEstateService.getAll();
            res.json(tags);
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    }

    async getByRealEstateId(req, res) {
        try {
            const tags = await tagRealEstateService.getByRealEstateId(req.params.realEstateId);
            res.json(tags);
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    }

    async getRealEstateByTagId(req, res) {
        try {
            const realEstates = await tagRealEstateService.getRealEstateByTagId(req.params.tagId);
            res.json(realEstates);
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    }

    async create(req, res) {
        try {
            const newTagRealEstate = await tagRealEstateService.create(req.body);
            res.status(201).json(newTagRealEstate);
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    }

    async delete(req, res) {
        try {
            const deletedTagRealEstate = await tagRealEstateService.delete(req.params.id);
            res.json(deletedTagRealEstate);
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    }
}

module.exports = new TagRealEstateController();
