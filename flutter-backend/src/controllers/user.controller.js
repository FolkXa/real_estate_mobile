const userService = require('../services/user.service');

class UserController {
    async getUsers(req, res) {
        try {
            const users = await userService.getUsers();
            res.json(users);
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    }

    async getUser(req, res) {
        try {
            const user = await userService.getUser(req.params.id);
            if (!user) return res.status(404).json({ message: 'User not found' });
            res.json(user);
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    }

    async createUser(req, res) {
        try {
            const newUser = await userService.createUser(req.body);
            res.status(201).json(newUser);
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    }

    async updateUser(req, res) {
        try {
            const updatedUser = await userService.updateUser(req.params.id, req.body);
            res.json(updatedUser);
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    }

    async deleteUser(req, res) {
        try {
            const deletedUser = await userService.deleteUser(req.params.id);
            res.json(deletedUser);
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    }

    async reactivateUser(req, res) {
        try {
            const user_id = req.params.id;
            const user = await userService.reactivateUser(user_id);
            if (!user) {
                return res.status(404).json({ message: 'User not found or already active' });
            }
            return res.status(200).json(user);
        } catch (error) {
            console.error(error);
            return res.status(500).json({ message: 'Error reactivating user' });
        }
    }
}

module.exports = new UserController();
