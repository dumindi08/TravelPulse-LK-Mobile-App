/**
 * TravelPulse LK — Community Reporting Routes
 * Module 2: Community Reporting & Transport Disruption Management (Dumindi)
 * Base URL: /api/v1/reports
 */

const express = require('express');
const router = express.Router();

const {
  getCategories,
  getPublicReports,
  getReportById,
  getMyReports,
  createReport,
  updateReport,
  deleteReport,
} = require('../controllers/report.controller');

const { requireAuth, optionalAuth } = require('../middleware/auth.middleware');
const { validateCreateReport, validateUpdateReport } = require('../validators/report.validator');

// 1. Master Categories Taxonomy (Public)
router.get('/categories', getCategories);

// 2. Commuter's Authored Reports (Protected — Requires Authentication)
router.get('/my-reports', requireAuth, getMyReports);

// 3. Public Community Feed (Public with optional auth for personal indicators)
router.get('/', optionalAuth, getPublicReports);

// 4. Single Report Details (Public with optional auth)
router.get('/:id', optionalAuth, getReportById);

// 5. Submit New Community Report (Protected — Requires Authentication)
router.post('/', requireAuth, validateCreateReport, createReport);

// 6. Update Report (Protected — Author or Moderator)
router.patch('/:id', requireAuth, validateUpdateReport, updateReport);

// 7. Delete Report (Protected — Strictly Author or Moderator)
router.delete('/:id', requireAuth, deleteReport);

module.exports = router;

