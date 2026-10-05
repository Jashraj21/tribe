import { Router } from 'express';
import { PassesController } from './passes.controller.js';

const router = Router();
const controller = new PassesController();

router.post('/verify-gate-scan', controller.verifyGateScan);
router.get('/:passNumber', controller.getPassStatus);

export const passRoutes = router;
