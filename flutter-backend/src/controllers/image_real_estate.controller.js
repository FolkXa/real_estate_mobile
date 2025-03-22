const imageRealEstateService = require('../services/image_real_estate.service');

class ImageRealEstateController {
    async getAll(req, res) {
        try {
            const images = await imageRealEstateService.getAll();
            res.json(images);
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    }

    async getByRealEstateId(req, res) {
        try {
            const images = await imageRealEstateService.getByRealEstateId(req.params.realEstateId);
            res.json(images);
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    }

    async create(req, res) {
        try {
            const newImage = await imageRealEstateService.create(req.body);
            res.status(201).json(newImage);
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    }

    async delete(req, res) {
        try {
            const deletedImage = await imageRealEstateService.delete(req.params.id);
            res.json(deletedImage);
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    }
}

module.exports = new ImageRealEstateController();