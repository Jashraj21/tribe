import dotenv from 'dotenv';
import path from 'path';

dotenv.config();

export const config = {
  port: parseInt(process.env.PORT || '4000', 10),
  nodeEnv: process.env.NODE_ENV || 'development',
  apiPrefix: process.env.API_PREFIX || '/api/v1',
  corsOrigin: process.env.CORS_ORIGIN || '*',

  razorpay: {
    keyId: process.env.RAZORPAY_KEY_ID || 'rzp_test_TjoMcngj0CGZMk',
    keySecret: process.env.RAZORPAY_KEY_SECRET || 'rzp_test_secret_placeholder_replace_with_actual',
    webhookSecret: process.env.RAZORPAY_WEBHOOK_SECRET || 'tribe_webhook_secret_key_demo_2026',
  },

  redis: {
    url: process.env.REDIS_URL || 'redis://localhost:6379',
    seatLockTtlSeconds: 600, // 10 minutes lock duration
  },

  jwt: {
    secret: process.env.JWT_SECRET || 'tribe_jwt_super_secret_key_production_grade_99824',
    expiresIn: process.env.JWT_EXPIRES_IN || '30d',
  },
};
