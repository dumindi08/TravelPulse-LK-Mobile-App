/**
 * TravelPulse LK — Backend HTTP Server Bootstrap
 */

const app = require('./app');

const PORT = process.env.PORT || 5000;

const server = app.listen(PORT, () => {
  console.log(`[TravelPulse LK] Backend service running on http://localhost:${PORT}`);
  console.log(`[TravelPulse LK] Health endpoint: http://localhost:${PORT}/health`);
  console.log(`[TravelPulse LK] Reports API: http://localhost:${PORT}/api/v1/reports`);
});

module.exports = server;

