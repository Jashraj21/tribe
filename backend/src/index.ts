import { createApp } from './app.js';
import { config } from './config/env.js';

const app = createApp();

app.listen(config.port, () => {
  console.log(`\n======================================================`);
  console.log(`⚡ TRIBE Backend Engine running on port ${config.port}`);
  console.log(`🔗 Local URL: http://localhost:${config.port}`);
  console.log(`🛡️  Razorpay Key: ${config.razorpay.keyId}`);
  console.log(`📦 Environment: ${config.nodeEnv}`);
  console.log(`======================================================\n`);
});
