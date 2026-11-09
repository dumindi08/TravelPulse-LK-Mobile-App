# TravelPulse LK — REST API Contracts & Specification

**Project:** SE5104 Mini Project — Group 10  
**Base URL:** `http://localhost:5000/api/v1` (Development)  
**Specification Standard:** JSON REST API (HTTP 1.1 / JSON over HTTPS)  
**Status:** Proposal for Team Review

---

## 1. Global API Standards

### 1.1. Standard Success Response Format
All successful responses return HTTP status `200 OK` or `201 Created` with the following envelope:

```json
{
  "success": true,
  "statusCode": 200,
  "message": "Human-readable summary of the operation",
  "data": { ... },
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 142
  }
}
```
*(The `meta` object is included for paginated collections).*

### 1.2. Standard Error Response Format
All error responses return standard HTTP 4xx or 5xx codes with this envelope:

```json
{
  "success": false,
  "statusCode": 400,
  "message": "Validation failed on the submitted data",
  "error": {
    "code": "VALIDATION_ERROR",
    "details": [
      { "field": "email", "issue": "Invalid email format" }
    ]
  }
}
```

Common Error Codes:
* `400 BAD REQUEST` (`VALIDATION_ERROR`, `BAD_REQUEST`)
* `401 UNAUTHORIZED` (`UNAUTHORIZED`, `TOKEN_EXPIRED`, `INVALID_TOKEN`)
* `403 FORBIDDEN` (`FORBIDDEN_RESOURCE`, `INSUFFICIENT_ROLE`)
* `404 NOT FOUND` (`RESOURCE_NOT_FOUND`)
* `409 CONFLICT` (`DUPLICATE_ENTRY`, `ALREADY_VOTED`)
* `500 INTERNAL SERVER ERROR` (`SERVER_ERROR`)

### 1.3. Authorization Header
Protected endpoints require a Bearer token:
```http
Authorization: Bearer <JWT_ACCESS_TOKEN>
```

---

## 2. API Endpoints by Module

---

### 2.1. Module 1: Nisal — User, Transport Route & Journey Management

#### 2.1.1. Register Commuter
* **Method:** `POST`
* **URL:** `/api/v1/auth/register`
* **Owning Module:** Nisal
* **Auth Requirement:** Public (None)
* **Purpose:** Create a new commuter account.
* **Request Body:**
```json
{
  "name": "Kamal Perera",
  "email": "kamal@example.com",
  "password": "Password123!",
  "phoneNumber": "+94771234567"
}
```
* **Success Response (`201 Created`):**
```json
{
  "success": true,
  "statusCode": 201,
  "message": "User registered successfully",
  "data": {
    "user": {
      "id": 1,
      "name": "Kamal Perera",
      "email": "kamal@example.com",
      "role": "commuter"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```
* **Error Responses:**
  * `400 Bad Request`: Validation error (invalid email format or weak password).
  * `409 Conflict`: Email already registered (`code: "EMAIL_ALREADY_EXISTS"`).

---

#### 2.1.2. Login User
* **Method:** `POST`
* **URL:** `/api/v1/auth/login`
* **Owning Module:** Nisal
* **Auth Requirement:** Public (None)
* **Purpose:** Authenticate user credentials and return JWT token.
* **Request Body:**
```json
{
  "email": "kamal@example.com",
  "password": "Password123!"
}
```
* **Success Response (`200 OK`):**
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Login successful",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": 1,
      "name": "Kamal Perera",
      "email": "kamal@example.com",
      "role": "commuter"
    }
  }
}
```
* **Error Responses:**
  * `401 Unauthorized`: Invalid credentials (`code: "INVALID_CREDENTIALS"`).

---

#### 2.1.3. Register Device FCM Token
* **Method:** `POST`
* **URL:** `/api/v1/users/device-token`
* **Owning Module:** Nisal
* **Auth Requirement:** Authenticated (`Bearer <JWT>`)
* **Purpose:** Register or update Firebase Cloud Messaging device token.
* **Request Body:**
```json
{
  "fcmToken": "cE38xk7zQq-...",
  "deviceType": "android"
}
```
* **Success Response (`200 OK`):**
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Device token updated successfully",
  "data": {
    "userId": 1,
    "deviceType": "android"
  }
}
```
* **Error Responses:**
  * `401 Unauthorized`: Missing or invalid token.

---

#### 2.1.4. Query Public Transport Routes
* **Method:** `GET`
* **URL:** `/api/v1/routes`
* **Owning Module:** Nisal
* **Auth Requirement:** Public (Optional Auth)
* **Purpose:** Search routes by number, cities, or transport mode.
* **Query Parameters:**
  * `search` (string, optional): e.g. "138" or "Maharagama"
  * `type` (string, optional): "bus" or "train"
* **Success Response (`200 OK`):**
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Routes retrieved successfully",
  "data": [
    {
      "id": 12,
      "routeNumber": "138",
      "name": "Colombo Fort - Maharagama",
      "transportType": "bus",
      "operator": "SLTB",
      "originCity": "Colombo Fort",
      "destinationCity": "Maharagama",
      "isActive": true
    }
  ]
}
```

---

#### 2.1.5. Get Route Details with Stops
* **Method:** `GET`
* **URL:** `/api/v1/routes/:id`
* **Owning Module:** Nisal
* **Auth Requirement:** Public
* **Purpose:** Fetch route information along with ordered stops in sequence.
* **Success Response (`200 OK`):**
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Route details retrieved successfully",
  "data": {
    "id": 12,
    "routeNumber": "138",
    "name": "Colombo Fort - Maharagama",
    "transportType": "bus",
    "stops": [
      {
        "stopId": 101,
        "name": "Colombo Fort Station",
        "stopOrder": 1,
        "latitude": 6.9344,
        "longitude": 79.8540,
        "distanceFromPrevKm": 0.0,
        "estMinutesFromPrev": 0
      },
      {
        "stopId": 102,
        "name": "Town Hall",
        "stopOrder": 2,
        "latitude": 6.9147,
        "longitude": 79.8653,
        "distanceFromPrevKm": 3.4,
        "estMinutesFromPrev": 12
      }
    ]
  }
}
```
* **Error Responses:**
  * `404 Not Found`: Route ID does not exist.

---

#### 2.1.6. Create Commuter Journey
* **Method:** `POST`
* **URL:** `/api/v1/journeys`
* **Owning Module:** Nisal
* **Auth Requirement:** Authenticated
* **Purpose:** Log a travel journey for commuter travel history and personalized alerts.
* **Request Body:**
```json
{
  "routeId": 12,
  "originStopId": 101,
  "destinationStopId": 102,
  "startTime": "2026-11-09T08:30:00Z"
}
```
* **Success Response (`201 Created`):**
```json
{
  "success": true,
  "statusCode": 201,
  "message": "Journey created successfully",
  "data": {
    "journeyId": 501,
    "status": "planned",
    "routeId": 12,
    "startTime": "2026-11-09T08:30:00Z"
  }
}
```

---

### 2.2. Module 2: Dumindi — Community Reporting & Transport Disruption Management

#### 2.2.1. Get Disruption / Report Categories
* **Method:** `GET`
* **URL:** `/api/v1/reports/categories`
* **Owning Module:** Dumindi
* **Auth Requirement:** Public
* **Purpose:** Retrieve active incident categories for report creation dropdowns.
* **Success Response (`200 OK`):**
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Categories retrieved successfully",
  "data": [
    {
      "id": 1,
      "code": "BREAKDOWN",
      "name": "Vehicle Breakdown",
      "defaultSeverity": "medium"
    },
    {
      "id": 2,
      "code": "DELAY",
      "name": "Excessive Transit Delay",
      "defaultSeverity": "low"
    },
    {
      "id": 3,
      "code": "WEATHER_HAZARD",
      "name": "Road Flooding / Landslide",
      "defaultSeverity": "high"
    }
  ]
}
```

---

#### 2.2.2. Submit Community Report
* **Method:** `POST`
* **URL:** `/api/v1/reports`
* **Owning Module:** Dumindi
* **Auth Requirement:** Authenticated
* **Purpose:** Commuter submits an incident or disruption report.
* **Request Body:**
```json
{
  "categoryId": 1,
  "routeId": 12,
  "stopId": 102,
  "latitude": 6.9147,
  "longitude": 79.8653,
  "locationDescription": "Near Town Hall roundabout",
  "title": "Bus broken down blocking middle lane",
  "description": "Route 138 bus broken down near Town Hall, heavy traffic developing towards Borella.",
  "mediaUrl": "https://storage.travelpulse.lk/reports/img_1234.jpg"
}
```
* **Success Response (`201 Created`):**
```json
{
  "success": true,
  "statusCode": 201,
  "message": "Report submitted successfully",
  "data": {
    "reportId": 1045,
    "status": "submitted",
    "reliability": {
      "score": 10.0,
      "confidenceStatus": "unverified"
    },
    "createdAt": "2026-11-09T20:15:00Z"
  }
}
```
* **Error Responses:**
  * `400 Bad Request`: Missing mandatory coordinates or category ID.
  * `401 Unauthorized`: Token missing or invalid.

---

#### 2.2.3. Query Community Reports
* **Method:** `GET`
* **URL:** `/api/v1/reports`
* **Owning Module:** Dumindi
* **Auth Requirement:** Public (Optional Auth)
* **Purpose:** List community reports filtered by route, category, status, or location radius.
* **Query Parameters:**
  * `routeId` (int, optional): Filter by route
  * `status` (string, optional): e.g. "submitted", "verified", "active"
  * `lat` (float, optional) & `lng` (float, optional) & `radiusKm` (float, optional, default: 5)
  * `page` (int, default: 1), `limit` (int, default: 20)
* **Success Response (`200 OK`):**
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Reports fetched successfully",
  "data": [
    {
      "id": 1045,
      "title": "Bus broken down blocking middle lane",
      "categoryName": "Vehicle Breakdown",
      "routeNumber": "138",
      "latitude": 6.9147,
      "longitude": 79.8653,
      "status": "submitted",
      "reliabilityScore": 65.0,
      "confidenceStatus": "plausible",
      "upvotes": 4,
      "downvotes": 0,
      "createdAt": "2026-11-09T20:15:00Z"
    }
  ],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 1
  }
}
```

---

#### 2.2.4. Get Active Disruptions
* **Method:** `GET`
* **URL:** `/api/v1/disruptions`
* **Owning Module:** Dumindi
* **Auth Requirement:** Public
* **Purpose:** Fetch official active transport disruptions affecting routes.
* **Success Response (`200 OK`):**
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Active disruptions retrieved",
  "data": [
    {
      "id": 22,
      "routeId": 12,
      "routeNumber": "138",
      "disruptionType": "Vehicle Breakdown",
      "severity": "medium",
      "headline": "Severe delay on Route 138 near Town Hall",
      "details": "Major delays of 20-30 minutes due to bus obstruction.",
      "status": "active",
      "startedAt": "2026-11-09T20:15:00Z"
    }
  ]
}
```

---

### 2.3. Module 3: Suneth — Crowd Intelligence & Report Reliability Engine

#### 2.3.1. Vote on Community Report
* **Method:** `POST`
* **URL:** `/api/v1/reports/:id/vote`
* **Owning Module:** Suneth
* **Auth Requirement:** Authenticated
* **Purpose:** Peer confirmation or debunking of a submitted report.
* **Request Body:**
```json
{
  "voteType": "upvote"
}
```
*(Valid `voteType` values: `upvote`, `downvote`, `confirm_resolved`)*
* **Success Response (`200 OK`):**
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Vote recorded and reliability recalculated",
  "data": {
    "reportId": 1045,
    "userVote": "upvote",
    "updatedReliability": {
      "reliabilityScore": 75.5,
      "confidenceStatus": "verified",
      "upvotes": 5,
      "downvotes": 0
    }
  }
}
```
* **Error Responses:**
  * `400 Bad Request`: Invalid vote type.
  * `404 Not Found`: Report does not exist.
  * `409 Conflict`: User has already voted on this report (`code: "ALREADY_VOTED"`).

---

#### 2.3.2. Get Report Reliability Breakdown
* **Method:** `GET`
* **URL:** `/api/v1/reports/:id/reliability`
* **Owning Module:** Suneth
* **Auth Requirement:** Public
* **Purpose:** Inspect algorithm scoring factors (votes, corroborations, reporter reputation).
* **Success Response (`200 OK`):**
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Reliability breakdown retrieved",
  "data": {
    "reportId": 1045,
    "reliabilityScore": 75.5,
    "confidenceStatus": "verified",
    "metrics": {
      "upvotes": 5,
      "downvotes": 0,
      "corroborations": 2,
      "reporterReputationScore": 82.0
    },
    "lastCalculatedAt": "2026-11-09T20:20:00Z"
  }
}
```

---

#### 2.3.3. Submit Crowd Estimate
* **Method:** `POST`
* **URL:** `/api/v1/crowd/estimates`
* **Owning Module:** Suneth
* **Auth Requirement:** Authenticated
* **Purpose:** Commuter reports quick crowd congestion level for a route or stop.
* **Request Body:**
```json
{
  "routeId": 12,
  "stopId": 102,
  "crowdLevel": "crowded",
  "passengerWaitTimeMinutes": 15
}
```
*(Valid `crowdLevel`: `empty`, `moderate`, `crowded`, `very_crowded`)*
* **Success Response (`201 Created`):**
```json
{
  "success": true,
  "statusCode": 201,
  "message": "Crowd estimate recorded",
  "data": {
    "estimateId": 892,
    "routeId": 12,
    "stopId": 102,
    "crowdLevel": "crowded"
  }
}
```

---

#### 2.3.4. Query Aggregated Crowd Status
* **Method:** `GET`
* **URL:** `/api/v1/crowd/status`
* **Owning Module:** Suneth
* **Auth Requirement:** Public
* **Purpose:** Get real-time aggregated crowd status for a transit stop or route.
* **Query Parameters:**
  * `targetType`: `stop` or `route`
  * `targetId`: integer
* **Success Response (`200 OK`):**
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Aggregated crowd status retrieved",
  "data": {
    "targetType": "stop",
    "targetId": 102,
    "currentCrowdLevel": "crowded",
    "sampleCount": 8,
    "confidenceScore": 88.0,
    "timeSlot": "2026-11-09T20:15:00Z"
  }
}
```

---

### 2.4. Module 4: Thimaya — Road Conditions, Maps & Travel Alert System

#### 2.4.1. Get Map Road Incidents (Geospatial Bounding Box)
* **Method:** `GET`
* **URL:** `/api/v1/maps/incidents`
* **Owning Module:** Thimaya
* **Auth Requirement:** Public
* **Purpose:** Retrieve road condition hazards within current Google Maps camera viewport.
* **Query Parameters:**
  * `minLat` (float, required): Minimum latitude
  * `maxLat` (float, required): Maximum latitude
  * `minLng` (float, required): Minimum longitude
  * `maxLng` (float, required): Maximum longitude
* **Success Response (`200 OK`):**
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Map incidents retrieved",
  "data": [
    {
      "id": 401,
      "incidentType": "flooding",
      "severity": "high",
      "latitude": 6.9012,
      "longitude": 79.8601,
      "addressText": "Bauddhaloka Mawatha near Thunmulla",
      "radiusMeters": 250,
      "isActive": true,
      "startTime": "2026-11-09T18:00:00Z"
    }
  ]
}
```
* **Error Responses:**
  * `400 Bad Request`: Missing bounding-box query parameters.

---

#### 2.4.2. Create Road Hazard Incident
* **Method:** `POST`
* **URL:** `/api/v1/maps/incidents`
* **Owning Module:** Thimaya
* **Auth Requirement:** Authenticated (`role: moderator` or `admin`)
* **Purpose:** Publish or curate a physical road hazard incident on the map.
* **Request Body:**
```json
{
  "sourceReportId": 1045,
  "incidentType": "road_closure",
  "severity": "critical",
  "latitude": 6.9147,
  "longitude": 79.8653,
  "addressText": "Town Hall Roundabout",
  "radiusMeters": 150,
  "startTime": "2026-11-09T20:20:00Z"
}
```
* **Success Response (`201 Created`):**
```json
{
  "success": true,
  "statusCode": 201,
  "message": "Road incident published to map",
  "data": {
    "incidentId": 402,
    "incidentType": "road_closure",
    "isActive": true
  }
}
```
* **Error Responses:**
  * `403 Forbidden`: User does not hold moderator/admin role.

---

#### 2.4.3. List Travel Alerts
* **Method:** `GET`
* **URL:** `/api/v1/alerts`
* **Owning Module:** Thimaya
* **Auth Requirement:** Public (Optional Auth)
* **Purpose:** Commuter alert inbox and broadcast feed.
* **Query Parameters:**
  * `routeId` (int, optional)
  * `severity` (string, optional: `info`, `warning`, `critical`)
* **Success Response (`200 OK`):**
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Alerts fetched successfully",
  "data": [
    {
      "id": 88,
      "title": "Severe Flooding — Thunmulla Junction",
      "message": "Water levels reaching 1.5 ft. Bus routes 138 and 120 diverted via Havelock Road.",
      "alertType": "road_condition",
      "severity": "critical",
      "targetRouteId": 12,
      "createdAt": "2026-11-09T19:00:00Z"
    }
  ]
}
```

---

#### 2.4.4. Create & Broadcast Travel Alert
* **Method:** `POST`
* **URL:** `/api/v1/alerts`
* **Owning Module:** Thimaya
* **Auth Requirement:** Authenticated (`role: moderator` or `admin`)
* **Purpose:** Create travel alert and trigger Firebase Cloud Messaging (FCM) dispatch.
* **Request Body:**
```json
{
  "title": "Severe Flooding — Thunmulla Junction",
  "message": "Water levels reaching 1.5 ft. Bus routes 138 and 120 diverted via Havelock Road.",
  "alertType": "road_condition",
  "severity": "critical",
  "targetRouteId": 12,
  "targetLatitude": 6.8920,
  "targetLongitude": 79.8580,
  "targetRadiusKm": 3.0,
  "expiresAt": "2026-11-10T02:00:00Z"
}
```
* **Success Response (`201 Created`):**
```json
{
  "success": true,
  "statusCode": 201,
  "message": "Alert created and push notification broadcast queued",
  "data": {
    "alertId": 89,
    "status": "active",
    "dispatchedTokensCount": 142
  }
}
```
* **Error Responses:**
  * `403 Forbidden`: Unauthorized to broadcast alerts.

---

#### 2.4.5. Manage Alert Subscriptions
* **Method:** `POST`
* **URL:** `/api/v1/alerts/subscriptions`
* **Owning Module:** Thimaya
* **Auth Requirement:** Authenticated
* **Purpose:** Commuter registers interest in alerts for specific routes or home/work radii.
* **Request Body:**
```json
{
  "subscriptionType": "route",
  "routeId": 12
}
```
* **Success Response (`201 Created`):**
```json
{
  "success": true,
  "statusCode": 201,
  "message": "Subscribed to Route 138 travel alerts",
  "data": {
    "subscriptionId": 312,
    "subscriptionType": "route",
    "routeId": 12,
    "isActive": true
  }
}
```

