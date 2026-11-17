/**
 * TravelPulse LK — Backend HTTP Server Bootstrap
 */

try {
  require('dotenv').config();
} catch (_) {}

// Production security safeguard: Exit immediately if JWT_SECRET or DB_HOST is not configured
if (process.env.NODE_ENV === 'production') {
  if (!process.env.JWT_SECRET || process.env.JWT_SECRET.trim() === '') {
    console.error('[FATAL] Missing required environment variable: JWT_SECRET must be set in production mode.');
    process.exit(1);
  }
  if (!process.env.DB_HOST || process.env.DB_HOST.trim() === '') {
    console.error('[FATAL] Missing required environment variable: DB_HOST must be set in production mode. MemoryStore fallback is strictly disabled in production.');
    process.exit(1);
  }
}

const app = require('./app');

const PORT = process.env.PORT || 5000;

const server = app.listen(PORT, () => {
  console.log(`[TravelPulse LK] Backend service running on http://localhost:${PORT}`);
  console.log(`[TravelPulse LK] Health endpoint: http://localhost:${PORT}/health`);
  console.log(`[TravelPulse LK] Reports API: http://localhost:${PORT}/api/v1/reports`);
});

module.exports = server;
