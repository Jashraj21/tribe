import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import { config } from './config/env.js';
import { paymentRoutes } from './modules/payments/payments.routes.js';
import { passRoutes } from './modules/passes/passes.routes.js';
import { eventRoutes } from './modules/events/events.routes.js';
import { errorHandler } from './middleware/error.middleware.js';

export function createApp() {
  const app = express();

  // Security & Utility Middlewares
  app.use(helmet());
  app.use(cors({ origin: config.corsOrigin }));
  app.use(morgan('dev'));

  // Body Parsers
  app.use(express.json({ limit: '10mb' }));
  app.use(express.urlencoded({ extended: true }));

  // Root & Healthcheck
  app.get('/', (_req, res) => {
    res.json({
      name: 'TRIBE Experiences Backend API',
      version: '1.0.0',
      status: 'operational',
      environment: config.nodeEnv,
      timestamp: new Date().toISOString(),
      activeRazorpayKey: config.razorpay.keyId,
      endpoints: {
        health: '/health',
        events: `${config.apiPrefix}/events`,
        cities: `${config.apiPrefix}/events/cities`,
        createPaymentOrder: `${config.apiPrefix}/payments/create-order`,
        verifyPayment: `${config.apiPrefix}/payments/verify`,
        webhook: `${config.apiPrefix}/payments/webhook`,
        verifyGateScan: `${config.apiPrefix}/passes/verify-gate-scan`,
      },
    });
  });

  app.get('/health', (_req, res) => {
    res.status(200).json({ status: 'ok', uptime: process.uptime() });
  });

  // API Routes
  app.use(`${config.apiPrefix}/payments`, paymentRoutes);
  app.use(`${config.apiPrefix}/passes`, passRoutes);
  app.use(`${config.apiPrefix}/events`, eventRoutes);

  // Global Error Handler
  app.use(errorHandler);

  return app;
}
