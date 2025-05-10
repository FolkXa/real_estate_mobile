const express = require('express');
const router = express.Router();
const realEstateController = require('../controllers/realestate.controller');

router.get('/', realEstateController.getAll);
router.get('/:id', realEstateController.getById);
router.post('/', realEstateController.create);
router.put('/:id', realEstateController.update);
router.delete('/:id', realEstateController.delete);
router.put('/:id/reactivate', realEstateController.reactivateRealEstate);
router.put('/:id/activate_premium', realEstateController.activatePremiumPromotion);
router.put('/:id/deactivate_premium', realEstateController.deactivatePremiumPromotion);
router.put('/:id/increment_view', realEstateController.incrementView);

module.exports = router;
