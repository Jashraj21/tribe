import { Router } from 'express';
import { EventsController } from './events.controller.js';

const router = Router();
const controller = new EventsController();

router.get('/', controller.getEvents);
router.get('/cities', controller.getCities);
router.get('/:id', controller.getEventById);

export const eventRoutes = router;
