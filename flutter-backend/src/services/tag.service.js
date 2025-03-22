const tagRepository = require('../repositories/tag.repository');

class TagService {
    async getAll() {
        return await tagRepository.getAll();
    }

    async getById(id) {
        return await tagRepository.getById(id);
    }

    async create(tagName) {
        return await tagRepository.create(tagName);
    }

    async delete(id) {
        return await tagRepository.delete(id);
    }
}

module.exports = new TagService();
