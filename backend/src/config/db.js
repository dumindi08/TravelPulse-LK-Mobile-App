/**
 * TravelPulse LK — Database Configuration & Data Store
 * Module 2: Community Reporting & Transport Disruption Management (Dumindi)
 * ---------------------------------------------------------------------------
 * Connects to MySQL 8.0+ when available, or provides a structured in-memory
 * relational store matching MySQL 8.0 schema for offline development & testing.
 */

const categoriesSeed = [
  { id: 1, code: 'CROWD', name: 'Crowd Report', description: 'Real-time transit crowd density and wait times', default_severity: 'low', is_active: true },
  { id: 2, code: 'ROAD_CONDITION', name: 'Road Condition', description: 'Potholes, flooding, road closures, and hazards', default_severity: 'medium', is_active: true },
  { id: 3, code: 'TRANSPORT_TRACKING', name: 'Transport/Route Tracking', description: 'Bus and train operational movement and tracking', default_severity: 'low', is_active: true },
  { id: 4, code: 'SERVICE_DISRUPTION', name: 'Service Disruption', description: 'Cancellations, breakdowns, delays, and service interruptions', default_severity: 'high', is_active: true },
  { id: 5, code: 'ACCIDENT_INCIDENT', name: 'Accident/Incident', description: 'Traffic collisions, emergencies, and safety incidents', default_severity: 'critical', is_active: true },
  { id: 6, code: 'OTHER', name: 'Other', description: 'General commuter notices, lost & found, and feedback', default_severity: 'low', is_active: true },
];

const initialReportsSeed = [
  {
    id: 101,
    user_id: 1,
    user_name: 'Kamal Perera',
    user_email: 'kamal@example.com',
    is_anonymous: false,
    category_id: 4,
    category_name: 'Service Disruption',
    route_id: 1,
    route_number: '138',
    stop_id: 104,
    stop_name: 'Town Hall / Viharamahadevi Park',
    latitude: 6.9147,
    longitude: 79.8653,
    location_description: 'Town Hall roundabout near Public Library',
    title: 'Bus Breakdown Blocking Center Lane',
    description: 'Route 138 SLTB bus broke down right after the roundabout. Traffic backing up towards Maradana and Borella.',
    disruption_reason: 'Vehicle Breakdown',
    media_url: null,
    status: 'verified',
    reliability_score: 84.0,
    confidence_status: 'verified',
    upvotes_count: 8,
    downvotes_count: 1,
    created_at: new Date(Date.now() - 25 * 60 * 1000).toISOString(),
    resolved_at: null,
  },
  {
    id: 102,
    user_id: 2,
    user_name: 'Dilshan Silva',
    user_email: 'dilshan@example.com',
    is_anonymous: true, // Anonymous report
    category_id: 2,
    category_name: 'Road Condition',
    route_id: 2,
    route_number: '100',
    stop_id: null,
    stop_name: null,
    latitude: 6.8920,
    longitude: 79.8580,
    location_description: 'Bauddhaloka Mawatha near Thunmulla',
    title: 'Severe Waterlogging / Flash Flood',
    description: 'Heavy rain has flooded the junction with 1.5 feet of water. Low clearance three-wheelers and cars cannot pass. Buses moving slowly.',
    disruption_reason: 'Road Inundation / Flooding',
    media_url: null,
    status: 'verified',
    reliability_score: 92.0,
    confidence_status: 'verified',
    upvotes_count: 14,
    downvotes_count: 0,
    created_at: new Date(Date.now() - 70 * 60 * 1000).toISOString(),
    resolved_at: null,
  },
  {
    id: 103,
    user_id: 1,
    user_name: 'Kamal Perera',
    user_email: 'kamal@example.com',
    is_anonymous: false,
    category_id: 1,
    category_name: 'Crowd Report',
    route_id: 1,
    route_number: '138',
    stop_id: 101,
    stop_name: 'Pettah Main Bus Stand',
    latitude: 6.9355,
    longitude: 79.8530,
    location_description: 'Route 138 bus bay',
    title: 'Heavy Evening Rush Hour Overcrowding',
    description: 'Huge queue extending over 50 meters. Buses arriving every 10 minutes but fill immediately.',
    disruption_reason: null,
    media_url: null,
    status: 'submitted',
    reliability_score: 60.0,
    confidence_status: 'plausible',
    upvotes_count: 3,
    downvotes_count: 0,
    created_at: new Date(Date.now() - 15 * 60 * 1000).toISOString(),
    resolved_at: null,
  },
];

// In-Memory Database Store (active when MySQL server is not connected)
class MemoryStore {
  constructor() {
    this.categories = [...categoriesSeed];
    this.reports = [...initialReportsSeed];
    this.nextReportId = 104;
  }

  getCategories() {
    return this.categories.filter((c) => c.is_active);
  }

  getCategoryById(id) {
    return this.categories.find((c) => c.id === Number(id));
  }

  getReports({ categoryId, status, routeId }) {
    let result = [...this.reports];
    if (categoryId) {
      result = result.filter((r) => r.category_id === Number(categoryId));
    }
    if (status && status.toLowerCase() !== 'all') {
      result = result.filter((r) => r.status.toLowerCase() === status.toLowerCase());
    }
    if (routeId) {
      result = result.filter((r) => r.route_id === Number(routeId));
    }
    return result.sort((a, b) => new Date(b.created_at) - new Date(a.created_at));
  }

  getReportById(id) {
    return this.reports.find((r) => r.id === Number(id));
  }

  getReportsByUserId(userId) {
    return this.reports
      .filter((r) => r.user_id === Number(userId))
      .sort((a, b) => new Date(b.created_at) - new Date(a.created_at));
  }

  createReport(data) {
    const category = this.getCategoryById(data.category_id);
    const newReport = {
      id: this.nextReportId++,
      user_id: data.user_id,
      user_name: data.user_name || 'Commuter',
      user_email: data.user_email || 'commuter@travelpulse.lk',
      is_anonymous: Boolean(data.is_anonymous),
      category_id: data.category_id,
      category_name: category ? category.name : 'General Report',
      route_id: data.route_id ? Number(data.route_id) : null,
      route_number: data.route_number || null,
      stop_id: data.stop_id ? Number(data.stop_id) : null,
      stop_name: data.stop_name || null,
      latitude: Number(data.latitude),
      longitude: Number(data.longitude),
      location_description: data.location_description || '',
      title: data.title,
      description: data.description,
      disruption_reason: data.disruption_reason || null,
      media_url: data.media_url || null,
      status: 'submitted',
      reliability_score: 20.0,
      confidence_status: 'unverified',
      upvotes_count: 1,
      downvotes_count: 0,
      created_at: new Date().toISOString(),
      resolved_at: null,
    };
    this.reports.unshift(newReport);
    return newReport;
  }

  updateReport(id, updates) {
    const report = this.getReportById(id);
    if (!report) return null;
    Object.assign(report, updates);
    return report;
  }

  deleteReport(id) {
    const index = this.reports.findIndex((r) => r.id === Number(id));
    if (index === -1) return false;
    this.reports.splice(index, 1);
    return true;
  }

  reset() {
    this.reports = [...initialReportsSeed];
    this.nextReportId = 104;
  }
}

const memoryStore = new MemoryStore();

module.exports = {
  memoryStore,
  isLiveDb: false, // Set to true once verified with a live MySQL connection pool
};

