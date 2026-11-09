# TravelPulse LK — Module Ownership & Responsibilities

**Project:** SE5104 Mini Project — Group 10  
**Application:** TravelPulse LK (Smart Public Transport & Road Condition Platform)  
**Status:** Initial Architectural Proposal (Under Review)

---

## 1. Executive Summary

TravelPulse LK integrates public transit tracking, community-driven disruption reporting, automated crowd and reliability analytics, and geospatial hazard mapping with push notifications. To ensure clean separation of concerns, zero code/table duplication, and manageable collaboration for four team members, this document formalizes the division of responsibilities, data ownership, API boundaries, and consensus rules.

---

## 2. Team Roster & Module Assignment

| Member | Module Name | Domain Scope |
| :--- | :--- | :--- |
| **Nisal** | **Module 1: User, Transport Route & Journey Management** | Identity, authentication (JWT/bcrypt), commuter profiles, master transport network (routes, stops, timetables), journey logging, and device token storage. |
| **Dumindi** | **Module 2: Community Reporting & Transport Disruption Management** | Incident reporting ingestion, disruption categorization, incident lifecycle tracking, and disruption event logging. |
| **Suneth** | **Module 3: Crowd Intelligence & Report Reliability Engine** | Peer verification voting, reliability scoring algorithms, user reputation indexing, real-time crowd level reports, and time-window crowd aggregations. |
| **Thimaya** | **Module 4: Road Conditions, Maps & Travel Alert System** | Road hazard management, Google Maps geospatial bounding-box queries, travel alert creation, alert subscriptions, and Firebase Cloud Messaging (FCM) dispatch. |

---

## 3. Detailed Module Breakdown

### 3.1. Module 1: Nisal — User, Transport Route & Journey Management

* **Core Purpose:** Manages user authentication, profile preferences, device registrations, transport network master data, and user travel journeys.
* **Frontend Scope (Flutter):**
  * Authentication screens (Sign In, Sign Up, Password Reset).
  * User profile & preferences management.
  * Public transit route explorer & schedule viewer.
  * Journey planner & personal journey history screen.
* **Backend Scope (Node.js/Express):**
  * `auth.middleware.js`: Central JWT authentication & token verification.
  * `role.middleware.js`: Role-based access control (Commuter, Moderator, Admin).
  * User management controller & service (CRUD operations, bcrypt hashing).
  * Transit routes, stops, and schedule service.
  * Journey tracking service.
  * FCM device token registration endpoint.
* **Database Tables Owned:**
  * `users`
  * `user_profiles`
  * `device_tokens`
  * `transport_routes`
  * `route_stops`
  * `route_stop_sequences`
  * `route_schedules`
  * `user_journeys`

---

### 3.2. Module 2: Dumindi — Community Reporting & Transport Disruption Management

* **Core Purpose:** Empowers commuters to report transit incidents, delays, breakdowns, and general disruptions, and tracks disruption events affecting routes.
* **Frontend Scope (Flutter):**
  * Report submission form (category selector, route/stop picker, GPS location picker, image attachment, description).
  * Community feed / active disruption list view.
  * Disruption detail screen with timeline updates.
  * Moderator status management controls (for users with Moderator/Admin role).
* **Backend Scope (Node.js/Express):**
  * Report categories controller & service.
  * Community report submission & lifecycle controller.
  * Disruption event tracking controller (aggregation of reports into official disruptions).
* **Database Tables Owned:**
  * `report_categories`
  * `community_reports`
  * `transport_disruptions`

---

### 3.3. Module 3: Suneth — Crowd Intelligence & Report Reliability Engine

* **Core Purpose:** Solves the "fake news / stale reports" problem in crowd-sourced apps by scoring report trustworthiness and calculating real-time crowd congestion at stops and on transit vehicles.
* **Frontend Scope (Flutter):**
  * Upvote / Downvote / "Confirm Resolved" interactive widget on reports.
  * Report reliability badge (e.g., Unverified, Plausible, Verified, Disputed).
  * Quick crowd status submission modal (Empty, Moderate, Crowded, Packed).
  * Real-time crowd density indicator on stop/route details.
  * User trust / reputation badge on user profile.
* **Backend Scope (Node.js/Express):**
  * Voting controller & service (idempotent user voting).
  * Report reliability engine (scoring algorithm factoring vote ratio, reporter reputation, and spatio-temporal corroboration).
  * User reputation service (updates user score based on accuracy of historical reports).
  * Crowd estimate ingestion and periodic aggregation engine (15-30 min sliding window).
* **Database Tables Owned:**
  * `user_reputations`
  * `report_votes`
  * `report_reliability`
  * `crowd_estimates`
  * `crowd_aggregations`

---

### 3.4. Module 4: Thimaya — Road Conditions, Maps & Travel Alert System

* **Core Purpose:** Delivers interactive geospatial map visualization of road hazards and transport delays, and orchestrates targeted push notifications via Firebase Cloud Messaging (FCM).
* **Frontend Scope (Flutter):**
  * Interactive Google Map view with custom markers for road hazards, route stops, and disruptions.
  * Viewport bounding-box dynamic loading as user pans/zooms the map.
  * Alert notification center & alert history.
  * Alert preference settings (subscribed routes, geo-radius around home/work).
* **Backend Scope (Node.js/Express):**
  * Map controller with spatial bounding-box / radius queries for hazards and incidents.
  * Road incident management controller (hazards such as floods, road closures, potholes).
  * Travel alert publishing service (escalating verified disruptions/hazards to push alerts).
  * FCM dispatch pipeline (resolving target users via device tokens and subscriptions).
* **Database Tables Owned:**
  * `road_incidents`
  * `travel_alerts`
  * `alert_subscriptions`
  * `alert_deliveries`

---

## 4. Responsibility Boundaries & Overlap Resolution

| Area of Potential Overlap | Competing Modules | Agreed Responsibility & Boundary |
| :--- | :--- | :--- |
| **Community Reports vs. Road Incidents** | Dumindi (Reports) vs. Thimaya (Roads) | **Dumindi** owns all user-facing incident submissions (`community_reports`). **Thimaya** owns curated/verified geospatial hazards displayed on Google Maps (`road_incidents`). If a community report relates to a physical road hazard (e.g. flooded road) and is verified, it is promoted to `road_incidents` referencing `source_report_id`. |
| **Crowd Reports vs. Disruption Reports** | Dumindi (Disruptions) vs. Suneth (Crowd) | **Dumindi** handles discrete events (e.g. bus breakdown, train cancelled). **Suneth** handles continuous high-frequency metrics (crowd level, passenger wait time) via lightweight `crowd_estimates` and periodic `crowd_aggregations`. |
| **Device Tokens vs. Travel Alerts** | Nisal (User Auth) vs. Thimaya (FCM Alerts) | **Nisal** owns `device_tokens` because tokens are bound to user device sessions registered during login/startup. **Thimaya** reads `device_tokens` to dispatch FCM notifications when publishing `travel_alerts`. |
| **Routes/Stops Master Data vs. Map Display** | Nisal (Routes) vs. Thimaya (Maps) | **Nisal** maintains the master data (`transport_routes`, `route_stops`, `route_stop_sequences`). **Thimaya** consumes this data to render polyline routes and custom stop markers on Google Maps. |
| **Voting vs. Report Status** | Dumindi (Report lifecycle) vs. Suneth (Voting engine) | **Suneth** manages votes in `report_votes` and computes `report_reliability`. When reliability crosses defined thresholds (e.g., score >= 75%), Suneth's service triggers an update to `community_reports.status` (e.g. to `verified`). |

---

## 5. Assumptions & Decisions Requiring Team Approval

> [!IMPORTANT]
> The following items require formal review and approval by all four team members before development commences.

1. **Authentication Token Lifecycle:**
   * *Assumption:* Access tokens will be short-lived JWTs (24 hours for university prototype) without refresh token rotation to minimize complexity.
   * *Status:* **Requires Team Approval (Nisal to confirm)**.
2. **Moderator Roles & Permissions:**
   * *Assumption:* Reports can be verified automatically via Suneth's algorithm OR manually overridden by users with role `'moderator'` or `'admin'`.
   * *Status:* **Requires Team Approval (Dumindi & Suneth to confirm)**.
3. **Geospatial Coordinate Storage:**
   * *Assumption:* Use standard `DECIMAL(10, 8)` for latitude and `DECIMAL(11, 8)` for longitude with B-tree composite indexing, rather than MySQL `SPATIAL POINT` and R-Tree indexes, to keep local development and seed exports simple across different MySQL versions.
   * *Status:* **Requires Team Approval (Thimaya to confirm)**.
4. **Push Notification Triggers:**
   * *Assumption:* Push notifications via FCM will be sent automatically only for high-severity alerts (`severity: 'critical'` or `'high'`), while `'info'` alerts appear in the in-app notification center.
   * *Status:* **Requires Team Approval (Thimaya to confirm)**.
5. **Image Storage for Reports:**
   * *Assumption:* Reports store a media URL (`media_url`). For the prototype, media can be hosted on Firebase Storage or Cloudinary, and the API receives only the final public URL.
   * *Status:* **Requires Team Approval (Dumindi to confirm)**.

