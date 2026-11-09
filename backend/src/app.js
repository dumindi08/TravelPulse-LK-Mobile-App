/**
 * TravelPulse LK — Express Application Entry
 * API Base URL: /api/v1
 */

const express = require('express');
const reportRoutes = require('./routes/report.routes');
const crowdRoutes = require('./routes/crowd.routes');

const app = express();

// Parse JSON bodies
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Standard CORS & Security Headers
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PATCH, DELETE, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization');
  if (req.method === 'OPTIONS') {
    return res.sendStatus(200);
  }
  next();
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'ok',
    service: 'TravelPulse LK Backend',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
  });
});

// Module 2 Routes (Dumindi)
app.use('/api/v1/reports', reportRoutes);

// Module 3 Routes (Suneth)
app.use('/api/v1/crowd', crowdRoutes);

// Fallback for undefined routes
app.use((req, res) => {
  res.status(404).json({
    success: false,
    statusCode: 404,
    message: `Endpoint ${req.method} ${req.originalUrl} not found.`,
    error: { code: 'ENDPOINT_NOT_FOUND' },
  });
});

// Central error handler
app.use((err, req, res, next) => {
  console.error('[TravelPulse Backend Error]', err);
  res.status(err.statusCode || 500).json({
    success: false,
    statusCode: err.statusCode || 500,
    message: err.message || 'Internal Server Error',
    error: {
      code: err.code || 'SERVER_ERROR',
      details: err.details || null,
    },
  });
});

module.exports = app;

