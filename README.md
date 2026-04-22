# SAIR APIs

[![style: dart_frog_lint][dart_frog_lint_badge]][dart_frog_lint_link]
[![License: MIT][license_badge]][license_link]
[![Powered by Dart Frog](https://img.shields.io/endpoint?url=https://tinyurl.com/dartfrog-badge)](https://dart-frog.dev)

Professional backend API for accident reporting workflows based on the functional requirements in `FR.txt`.

## Overview

This API supports:
- citizen registration/login/logout
- creating and tracking accident reports
- media attachment to reports
- status lifecycle management by officers/admins
- user notifications on status changes
- admin user listing

The current implementation uses a persistent JSON database (`data/db.json`) and is structured to swap to Firestore-backed adapters.

## Functional Requirements Coverage

- FR-1 User Registration: `POST /auth/register`
- FR-2 User Login: `POST /auth/login`
- FR-3 User Logout: `POST /auth/logout`
- FR-4 Create Accident Report: `POST /reports`
- FR-5 Automatic Location Detection: `locationSource` (`gps` or `manual`) + editable `lat/lng`
- FR-6 Upload Media: `POST /reports/:id/media`
- FR-7 Validate Report Data: strict body validation + descriptive `400` responses
- FR-8 View Submitted Reports: `GET /reports/my`
- FR-9 View Report Details: `GET /reports/:id`
- FR-10 Track Report Status: lifecycle values enforced
- FR-11 Filter Reports: `GET /reports/my?status=&from=&to=`
- FR-12 Status Update Notifications: `GET /notifications` + notification generated on status updates

## Architecture

- `routes/`: HTTP transport layer (Dart Frog routes/middleware)
- `lib/src/domain/`: core entities, constants, interfaces
- `lib/src/application/`: use cases
- `lib/src/infrastructure/`: security, persistence, repository implementations

Key design choices:
- JWT-based auth (`Authorization: Bearer <token>`)
- clear separation between route handlers and domain logic
- deterministic status lifecycle constants
- consistent JSON error shape for validation/authorization issues

## Authentication and Role Flow

Auth token:
- login returns a JWT token
- send token using header: `Authorization: Bearer <token>` (or `x-auth-token` fallback)
- middleware verifies JWT and resolves the current user

Roles:
- `citizen`: create/view own reports
- `officer`: update report status
- `admin`: update report status and list all users

If no token is provided, a guest citizen context is used for local testing.

## Report Status Lifecycle

Allowed statuses:
- `submitted`
- `under_review`
- `verified`
- `in_progress`
- `resolved`
- `rejected`

## API Endpoints

### Health

- `GET /`
  - Returns service metadata and health status.

### Auth

- `POST /auth/register`
  - Body:
    - `fullName` (string, required)
    - `email` (string, required)
    - `phone` (string, required)
    - `nationalId` (string, required)
    - `password` (string, required)
    - `role` (string, optional, defaults to `citizen`)

- `POST /auth/login`
  - Body:
    - `email` (string, required)
    - `password` (string, required)
  - Response:
    - `token`
    - `user`

- `POST /auth/logout`
  - Header: `Authorization: Bearer <token>` required.

### User Context

- `GET /me`
  - Returns currently resolved identity from middleware.

### Reports

- `POST /reports`
  - Header: `Authorization: Bearer <token>` optional (recommended)
  - Body:
    - `lat` (number, required)
    - `lng` (number, required)
    - `description` (string, required)
    - `accidentType` (string, required)
    - `occurredAt` (ISO datetime, optional, defaults to now)
    - `locationSource` (`gps` or `manual`, optional, defaults to `gps`)
  - Returns `201` with report.

- `GET /reports/my`
  - Query params:
    - `status` (optional)
    - `from` ISO datetime (optional)
    - `to` ISO datetime (optional)
  - Returns caller's reports.

- `GET /reports/:id`
  - Citizen can only view own reports.
  - Officer/admin can view any.

- `PATCH /reports/:id/status`
  - Roles: officer/admin only.
  - Body:
    - `status` required and must be one of the allowed statuses.
  - Creates a notification for the report owner.

- `POST /reports/:id/media`
  - Body:
    - `mediaUrl` (string) or
    - `mediaUrls` (array of strings)
  - Appends media to existing report.

### Notifications

- `GET /notifications`
  - Returns notifications for the authenticated user.

### Admin

- `GET /admin/users`
  - Role: admin only.
  - Returns list of registered users.

## Example Flow (End-to-End)

1. Register citizen.
2. Login and store token.
3. Create report with location, description, type.
4. Attach media to created report.
5. Officer logs in and updates status (`under_review`, `verified`, etc.).
6. Citizen checks `GET /notifications` for status update notifications.
7. Citizen filters own reports by status/date via `GET /reports/my`.
8. API docs available through Swagger UI at `GET /docs`.

## OpenAPI / Swagger

- OpenAPI spec: `openapi.yaml`
- Raw spec endpoint: `GET /openapi`
- Swagger UI: `GET /docs`

## Postman Guide

Import these files into Postman:
- `postman/SAIR_APIs.postman_collection.json`
- `postman/SAIR_APIs.postman_environment.json`

Steps:
1. Select environment **SAIR APIs (Local)**.
2. Start the server, then run requests in this order:
   - **Health** → `GET /`
   - **Auth** → `POST /auth/register (citizen)` (first time only)
   - **Auth** → `POST /auth/login (citizen) -> save token` (saves `token`)
   - **User Context** → `GET /me`
   - **Reports** → `POST /reports -> save reportId` (saves `reportId`)
   - **Reports** → `GET /reports/my`
   - **Reports** → `GET /reports/:id`
   - **Auth** → `POST /auth/login (officer) -> save token`
   - **Reports** → `PATCH /reports/:id/status`
   - **Auth** → `POST /auth/login (citizen) -> save token`
   - **Notifications** → `GET /notifications`
3. Optional:
   - **Auth** → `POST /auth/login (admin) -> save token`
   - **Admin** → `GET /admin/users`

## Sample Requests

### Register

```bash
curl -X POST http://localhost:8085/auth/register \
  -H "Content-Type: application/json" \
  -d "{\"fullName\":\"Ali Ahmad\",\"email\":\"ali@example.com\",\"phone\":\"0790000000\",\"nationalId\":\"1234567890\",\"password\":\"Pass@123\"}"
```

### Login

```bash
curl -X POST http://localhost:8085/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"ali@example.com\",\"password\":\"Pass@123\"}"
```

### Create Report

```bash
curl -X POST http://localhost:8085/reports \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <TOKEN>" \
  -d "{\"lat\":37.7749,\"lng\":-122.4194,\"description\":\"Traffic accident on Main Street\",\"accidentType\":\"collision\",\"locationSource\":\"gps\"}"
```

### Update Status (Officer/Admin)

```bash
curl -X PATCH http://localhost:8085/reports/<REPORT_ID>/status \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <OFFICER_OR_ADMIN_TOKEN>" \
  -d "{\"status\":\"under_review\"}"
```

## Local Run

Install dependencies:

```bash
dart pub get
```

Optional environment variables:

```bash
JWT_SECRET=replace-with-strong-secret
FIRESTORE_PROJECT_ID=<your-project-id>
FIRESTORE_CREDENTIAL_PATH=<service-account-json-path>
```

Start server (recommended on Windows to avoid VM service conflicts):

```bash
dart_frog dev -p 8085 -d 0
```

If a port is in use:
- change `-p` to another port (`8086`, `8087`, ...)
- or stop the owning process.

## Testing

Run full endpoint integration tests:

```bash
dart test
```

The suite covers health, auth, report creation/details/filtering/media, status updates, notifications, admin listing, and OpenAPI/docs endpoints.

## Notes

- Storage persists in `data/db.json`.
- Firestore integration is provided via `lib/src/persistence/firestore_backend.dart`.
- Keep role checks at handler level for every privileged endpoint.

[dart_frog_lint_badge]: https://img.shields.io/badge/style-dart_frog_lint-1DF9D2.svg
[dart_frog_lint_link]: https://pub.dev/packages/dart_frog_lint
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT