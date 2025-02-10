const tagService = require('../services/tag.service');

class TagController {
    async getAll(req, res) {
        try {
            const tags = await tagService.getAll();
            res.json(tags);
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    }

    async getById(req, res) {
        try {
            const tag = await tagService.getById(req.params.id);
            if (!tag) return res.status(404).json({ message: 'Tag not found' });
            res.json(tag);
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    }

    async create(req, res) {
        try {
            const { tag_name } = req.body;
            if (!tag_name) return res.status(400).json({ message: 'Tag name is required' });

            const newTag = await tagService.create(tag_name);
            res.status(201).json(newTag);
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    }

    async delete(req, res) {
        try {
            const deletedTag = await tagService.delete(req.params.id);
            if (!deletedTag) return res.status(404).json({ message: 'Tag not found' });

            res.json({ message: 'Tag deleted successfully', deletedTag });
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    }
}

module.exports = new TagController();
