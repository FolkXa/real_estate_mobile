const express = require('express');
const router = express.Router();
const userController = require('../controllers/user.controller');

router.get('/', userController.getUsers);
router.get('/:id', userController.getUser);
router.post('/', userController.createUser);
router.put('/:id', userController.updateUser);
router.put('/:id/reactivate', userController.reactivateUser);
router.delete('/:id', userController.deleteUser);

module.exports = router;

