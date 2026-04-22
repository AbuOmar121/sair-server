# SAIR Accident Reporting API Documentation

## Overview

The SAIR (Smart Accident Incident Reporting) API is a comprehensive REST API designed for reporting and managing accident incidents. It provides endpoints for user authentication, accident report management, media uploads, and real-time notifications.

**Base URL:** `http://localhost:8080`

**API Version:** 1.0.0

---

## Table of Contents

1. [Authentication](#authentication)
2. [Status Codes](#status-codes)
3. [Error Handling](#error-handling)
4. [Endpoints](#endpoints)
   - [Health & Documentation](#health--documentation)
   - [Authentication](#authentication-endpoints)
   - [User Management](#user-management)
   - [Reports](#reports)
   - [Notifications](#notifications)

---

## Authentication

Most endpoints require JWT (JSON Web Token) authentication. There are two ways to provide the authentication token:

### Method 1: Bearer Token (Recommended)
```
Authorization: Bearer <token>
```

### Method 2: Custom Header
```
x-auth-token: <token>
```

**Token Acquisition:**
Obtain a token by logging in with user credentials at the `/auth/login` endpoint.

---

## Status Codes

| Code | Status | Description |
|------|--------|-------------|
| 200 | OK | Request successful |
| 201 | Created | Resource created successfully |
| 400 | Bad Request | Invalid request data |
| 401 | Unauthorized | Missing or invalid authentication token |
| 403 | Forbidden | Insufficient permissions for the resource |
| 404 | Not Found | Resource not found |
| 405 | Method Not Allowed | HTTP method not allowed for this endpoint |
| 409 | Conflict | Resource conflict (e.g., duplicate email) |
| 500 | Internal Server Error | Server error |

---

## Error Handling

All error responses follow this format:

```json
{
  "error": "ERROR_CODE",
  "message": "Human-readable error message"
}
```

**Example:**
```json
{
  "error": "VALIDATION_ERROR",
  "message": "email and password are required."
}
```

---

## Endpoints

### Health & Documentation

#### 1. Health Check
Get the API health status and version information.

**Endpoint:** `GET /`

**Authentication:** None

**Response:** 200 OK
```json
{
  "service": "SAIR Accident Reporting API",
  "version": "1.0.0",
  "status": "healthy",
  "timestamp": "2026-04-22T21:59:52.478038"
}
```

---

#### 2. API Documentation (Swagger UI)
Access the interactive Swagger UI documentation.

**Endpoint:** `GET /docs`

**Authentication:** None

**Response:** 200 OK (HTML page)

---

#### 3. OpenAPI Specification
Get the OpenAPI specification in YAML format.

**Endpoint:** `GET /openapi`

**Authentication:** None

**Response:** 200 OK (YAML format)

---

### Authentication Endpoints

#### 4. User Registration
Register a new user account.

**Endpoint:** `POST /auth/register`

**Authentication:** None

**Request Body:**
```json
{
  "fullName": "John Doe",
  "email": "john@example.com",
  "phone": "1234567890",
  "nationalId": "12345678",
  "password": "securePassword123",
  "role": "citizen"
}
```

**Required Fields:**
- `fullName` (string)
- `email` (string) - Must be unique
- `phone` (string)
- `nationalId` (string)
- `password` (string)
- `role` (string, optional) - Default: "citizen"

**Available Roles:**
- `citizen` - Regular user reporting accidents
- `officer` - Police officer managing reports
- `admin` - System administrator

**Response:** 201 Created
```json
{
  "uid": "user_123456",
  "email": "john@example.com",
  "fullName": "John Doe",
  "phone": "1234567890",
  "nationalId": "12345678",
  "role": "citizen",
  "createdAt": "2026-04-22T10:00:00Z"
}
```

**Error Responses:**

409 Conflict - Email already exists
```json
{
  "error": "EMAIL_ALREADY_EXISTS",
  "message": "Email already registered."
}
```

400 Bad Request - Missing fields
```json
{
  "error": "VALIDATION_ERROR",
  "message": "Missing required registration fields."
}
```

---

#### 5. User Login
Authenticate and obtain a JWT token.

**Endpoint:** `POST /auth/login`

**Authentication:** None

**Request Body:**
```json
{
  "email": "john@example.com",
  "password": "securePassword123"
}
```

**Response:** 200 OK
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "uid": "user_123456",
    "email": "john@example.com",
    "fullName": "John Doe",
    "role": "citizen"
  }
}
```

**Error Responses:**

401 Unauthorized - Invalid credentials
```json
{
  "error": "INVALID_CREDENTIALS",
  "message": "Invalid email or password."
}
```

---

#### 6. User Logout
Logout and invalidate the current token.

**Endpoint:** `POST /auth/logout`

**Authentication:** Required (Bearer Token or x-auth-token header)

**Response:** 200 OK
```json
{
  "message": "Logged out successfully."
}
```

---

### User Management

#### 7. Get Current User
Retrieve authenticated user's profile information.

**Endpoint:** `GET /me`

**Authentication:** Required

**Response:** 200 OK
```json
{
  "uid": "user_123456",
  "email": "john@example.com",
  "fullName": "John Doe",
  "phone": "1234567890",
  "nationalId": "12345678",
  "role": "citizen"
}
```

---

#### 8. Get All Users (Admin Only)
Retrieve all registered users in the system.

**Endpoint:** `GET /admin/users`

**Authentication:** Required (Admin role)

**Response:** 200 OK
```json
[
  {
    "uid": "user_123456",
    "email": "john@example.com",
    "fullName": "John Doe",
    "role": "citizen",
    "createdAt": "2026-04-22T10:00:00Z"
  },
  {
    "uid": "user_123457",
    "email": "officer@example.com",
    "fullName": "Officer Smith",
    "role": "officer",
    "createdAt": "2026-04-22T11:00:00Z"
  }
]
```

**Error Responses:**

403 Forbidden - Non-admin user
```json
{
  "error": "FORBIDDEN",
  "message": "Admin role required."
}
```

---

### Reports

#### 9. Create Accident Report
Submit a new accident report.

**Endpoint:** `POST /reports`

**Authentication:** Required

**Request Body:**
```json
{
  "lat": 24.7136,
  "lng": 46.6753,
  "description": "Car collision at main intersection",
  "accidentType": "collision",
  "locationSource": "gps",
  "occurredAt": "2026-04-22T20:00:00Z"
}
```

**Required Fields:**
- `lat` (number) - Latitude coordinate
- `lng` (number) - Longitude coordinate
- `description` (string) - Accident description
- `accidentType` (string) - Type of accident
- `locationSource` (string) - "gps" or "manual"
- `occurredAt` (string, optional) - ISO 8601 timestamp, defaults to current time

**Valid Accident Types:**
- collision
- hit_and_run
- injury
- fatality
- property_damage
- other

**Response:** 201 Created
```json
{
  "id": "1776883793763",
  "citizenId": "user_123456",
  "lat": 24.7136,
  "lng": 46.6753,
  "description": "Car collision at main intersection",
  "accidentType": "collision",
  "locationSource": "gps",
  "status": "submitted",
  "mediaUrls": [],
  "createdAt": "2026-04-22T20:30:00Z",
  "updatedAt": "2026-04-22T20:30:00Z"
}
```

**Error Responses:**

400 Bad Request - Missing or invalid fields
```json
{
  "error": "VALIDATION_ERROR",
  "message": "lat, lng, description, and accidentType are required."
}
```

---

#### 10. Get User's Reports
Retrieve all reports submitted by the authenticated user.

**Endpoint:** `GET /reports/my`

**Authentication:** Required

**Query Parameters:**
- `status` (optional) - Filter by status: submitted, acknowledged, in_progress, resolved, rejected
- `from` (optional) - ISO 8601 start date
- `to` (optional) - ISO 8601 end date

**Example:** `GET /reports/my?status=submitted&from=2026-04-01T00:00:00Z&to=2026-04-30T23:59:59Z`

**Response:** 200 OK
```json
[
  {
    "id": "1776883793763",
    "citizenId": "user_123456",
    "lat": 24.7136,
    "lng": 46.6753,
    "description": "Car collision at main intersection",
    "accidentType": "collision",
    "status": "in_progress",
    "mediaUrls": [
      "https://example.com/photo1.jpg"
    ],
    "createdAt": "2026-04-22T20:30:00Z",
    "updatedAt": "2026-04-22T21:00:00Z"
  }
]
```

---

#### 11. Get Report by ID
Retrieve a specific report by its ID.

**Endpoint:** `GET /reports/{id}`

**Authentication:** Required

**Path Parameters:**
- `id` (string) - Report ID

**Permissions:**
- Citizens can only view their own reports
- Officers and admins can view all reports

**Response:** 200 OK
```json
{
  "id": "1776883793763",
  "citizenId": "user_123456",
  "officerId": "officer_123",
  "zoneId": "zone_1",
  "lat": 24.7136,
  "lng": 46.6753,
  "address": "Main Street, Riyadh",
  "description": "Car collision at main intersection",
  "accidentType": "collision",
  "locationSource": "gps",
  "status": "in_progress",
  "mediaUrls": [
    "https://example.com/photo1.jpg",
    "https://example.com/photo2.jpg"
  ],
  "occurredAt": "2026-04-22T20:00:00Z",
  "createdAt": "2026-04-22T20:30:00Z",
  "updatedAt": "2026-04-22T21:00:00Z"
}
```

**Error Responses:**

404 Not Found
```json
{
  "error": "NOT_FOUND",
  "message": "Report not found"
}
```

403 Forbidden - Citizen viewing another's report
```json
{
  "error": "FORBIDDEN",
  "message": "You can only view your own reports."
}
```

---

#### 12. Add Media to Report
Attach photos or videos to an accident report.

**Endpoint:** `POST /reports/{id}/media`

**Authentication:** Required

**Path Parameters:**
- `id` (string) - Report ID

**Request Body:**
```json
{
  "mediaUrls": [
    "https://example.com/photo1.jpg",
    "https://example.com/photo2.jpg"
  ]
}
```

Or use a single URL:
```json
{
  "mediaUrl": "https://example.com/photo1.jpg"
}
```

**Response:** 200 OK
```json
{
  "id": "1776883793763",
  "description": "Car collision at main intersection",
  "status": "submitted",
  "mediaUrls": [
    "https://example.com/photo1.jpg",
    "https://example.com/photo2.jpg"
  ],
  "updatedAt": "2026-04-22T21:05:00Z"
}
```

**Error Responses:**

400 Bad Request - No media URLs provided
```json
{
  "error": "VALIDATION_ERROR",
  "message": "mediaUrl or mediaUrls is required."
}
```

404 Not Found - Report doesn't exist
```json
{
  "error": "NOT_FOUND",
  "message": "Report not found."
}
```

---

#### 13. Update Report Status (Officer/Admin Only)
Change the status of an accident report.

**Endpoint:** `PATCH /reports/{id}/status`

**Authentication:** Required (Officer or Admin role)

**Path Parameters:**
- `id` (string) - Report ID

**Request Body:**
```json
{
  "status": "in_progress"
}
```

**Valid Status Values:**
- submitted
- acknowledged
- in_progress
- resolved
- rejected

**Response:** 200 OK
```json
{
  "id": "1776883793763",
  "description": "Car collision at main intersection",
  "status": "in_progress",
  "updatedAt": "2026-04-22T21:10:00Z"
}
```

Notifications are automatically sent to the citizen when status is updated.

**Error Responses:**

403 Forbidden - Citizen trying to update status
```json
{
  "error": "FORBIDDEN",
  "message": "Only officers/admins can update status."
}
```

400 Bad Request - Invalid status
```json
{
  "error": "VALIDATION_ERROR",
  "message": "Invalid status value."
}
```

404 Not Found
```json
{
  "error": "NOT_FOUND",
  "message": "Report not found."
}
```

---

### Notifications

#### 14. Get User Notifications
Retrieve all notifications for the authenticated user.

**Endpoint:** `GET /notifications`

**Authentication:** Required

**Response:** 200 OK
```json
[
  {
    "id": "notif_123",
    "userId": "user_123456",
    "title": "Report Status Updated",
    "message": "Your report 1776883793763 is now in_progress.",
    "reportId": "1776883793763",
    "read": false,
    "createdAt": "2026-04-22T21:10:00Z"
  },
  {
    "id": "notif_124",
    "userId": "user_123456",
    "title": "Report Submitted",
    "message": "Your accident report has been successfully submitted.",
    "reportId": "1776883793763",
    "read": true,
    "createdAt": "2026-04-22T20:30:00Z"
  }
]
```

---

## Usage Examples

### Example 1: Complete Report Flow

```bash
# 1. Register a user
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "fullName": "John Doe",
    "email": "john@example.com",
    "phone": "1234567890",
    "nationalId": "12345678",
    "password": "securePassword123",
    "role": "citizen"
  }'

# 2. Login to get token
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "securePassword123"
  }'

# Response includes: "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

# 3. Create a report
curl -X POST http://localhost:8080/reports \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "lat": 24.7136,
    "lng": 46.6753,
    "description": "Car accident on main street",
    "accidentType": "collision",
    "locationSource": "gps"
  }'

# 4. Add media to report
curl -X POST http://localhost:8080/reports/1776883793763/media \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "mediaUrls": ["https://example.com/photo.jpg"]
  }'

# 5. Check your reports
curl -X GET http://localhost:8080/reports/my \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

# 6. Logout
curl -X POST http://localhost:8080/auth/logout \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

---

## Rate Limiting

Currently, there are no rate limits implemented. This may be added in future versions.

---

## Data Storage

- **Default:** JSON file storage (for development)
- **Production:** Firestore (via environment variables):
  - `FIRESTORE_PROJECT_ID` - Firebase project ID
  - `FIRESTORE_CREDENTIAL_PATH` - Path to service account credentials JSON

---

## Support & Issues

For API issues or feature requests, please contact the development team or check the GitHub repository.

**Repository:** https://github.com/majedzeyad/sair

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-04-22 | Initial release |

---

## License

All rights reserved.
