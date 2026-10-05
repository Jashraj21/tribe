import { Router } from 'express';
import { PaymentsController } from './payments.controller.js';

const router = Router();
const controller = new PaymentsController();

router.post('/create-order', controller.createOrder);
router.post('/verify', controller.verifyPayment);
router.post('/webhook', controller.handleWebhook);

export const paymentRoutes = router;
