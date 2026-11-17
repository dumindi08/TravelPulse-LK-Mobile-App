/**
 * TravelPulse LK — Repository Index
 * Central access point for all persistent repository services across Modules 1-4.
 */

const userRepository = require('./user.repository');
const routeRepository = require('./route.repository');
const journeyRepository = require('./journey.repository');
const reportRepository = require('./report.repository');
const crowdRepository = require('./crowd.repository');
const incidentRepository = require('./incident.repository');
const alertRepository = require('./alert.repository');

module.exports = {
  userRepository,
  routeRepository,
  journeyRepository,
  reportRepository,
  crowdRepository,
  incidentRepository,
  alertRepository,
};

