const userRepository = require('../repositories/user.repository');

class UserService {
    async getUsers() {
        return await userRepository.getAllUsers();
    }

    async getUser(user_id) {
        return await userRepository.getUserById(user_id);
    }

    async createUser(userData) {
        return await userRepository.createUser(userData);
    }

    async updateUser(user_id, userData) {
        return await userRepository.updateUser(user_id, userData);
    }
    async reactivateUser(user_id) {
        return await userRepository.reactivateUser(user_id);
    }

    async deleteUser(user_id) {
        return await userRepository.softDeleteUser(user_id);
    }
}

module.exports = new UserService();
