const express = require('express');
const router = express.Router();
const tagController = require('../controllers/tag.controller');

router.get('/', tagController.getAll);
router.get('/:id', tagController.getById);
router.post('/', tagController.create);
router.delete('/:id', tagController.delete);

module.exports = router;
