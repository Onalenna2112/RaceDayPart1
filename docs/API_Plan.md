# RaceDay - API Endpoint Plan

## Overview
The RaceDay API provides a RESTful interface for managing sports events, categories, user enrolments, payments, and race results. 

### Roles & Security
- **Organiser**: Full administrative CRUD access to events, categories, and results.
- **Participant**: Read-only access to events/categories; write access to personal enrolments and payment queries.

---

## 1. Authentication Endpoints (`/api/auth`)

| Method | Endpoint | Access | Description | Request Body / Parameters | Success Response |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `POST` | `/api/auth/register` | Public | Register a new user account | `{ "fullName", "email", "password", "role" }` | `201 Created` - User object |
| `POST` | `/api/auth/login` | Public | Authenticate user & return JWT token | `{ "email", "password" }` | `200 OK` - `{ "token", "user" }` |

---

## 2. Event Management Endpoints (`/api/events`)

| Method | Endpoint | Access | Description | Request Body / Parameters | Success Response |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `GET` | `/api/events` | Public | List all upcoming events | Query filters: `eventType`, `location` | `200 OK` - Array of Events |
| `GET` | `/api/events/{id}` | Public | Get detailed event info by ID | Path param: `id` | `200 OK` - Event details |
| `POST` | `/api/events` | Organiser | Create a new race event | `{ "name", "description", "eventDate", "location", "distance", "eventType" }` | `201 Created` - Created Event |
| `PUT` | `/api/events/{id}` | Organiser | Update an existing event | Path param: `id`, Body: Event fields | `200 OK` - Updated Event |
| `DELETE` | `/api/events/{id}` | Organiser | Cancel/Delete an event | Path param: `id` | `204 No Content` |

---

## 3. Event Categories Endpoints (`/api/categories`)

| Method | Endpoint | Access | Description | Request Body / Parameters | Success Response |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `GET` | `/api/events/{eventId}/categories` | Public | Get categories for a specific event | Path param: `eventId` | `200 OK` - Array of Categories |
| `POST` | `/api/categories` | Organiser | Add a category to an event | `{ "eventId", "name", "minAge", "maxAge", "distanceKm", "entryFee" }` | `201 Created` - Created Category |
| `DELETE` | `/api/categories/{id}` | Organiser | Remove an event category | Path param: `id` | `204 No Content` |

---

## 4. Enrolment Endpoints (`/api/enrolments`)

| Method | Endpoint | Access | Description | Request Body / Parameters | Success Response |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `POST` | `/api/enrolments` | Participant | Register for an event category | `{ "eventId", "categoryId" }` | `201 Created` - Enrolment record |
| `GET` | `/api/enrolments/me` | Participant | Get current user's active enrolments | Bearer Token required | `200 OK` - List of Enrolments |
| `GET` | `/api/events/{eventId}/enrolments` | Organiser | View all participants in an event | Path param: `eventId` | `200 OK` - Participant list |

---

## 5. Payments Endpoints (`/api/payments`)

| Method | Endpoint | Access | Description | Request Body / Parameters | Success Response |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `POST` | `/api/payments` | Participant | Process entry fee payment | `{ "enrolmentId", "amount", "transactionReference" }` | `201 Created` - Payment receipt |
| `GET` | `/api/payments/{enrolmentId}` | Participant/Organiser | Query payment status for enrolment | Path param: `enrolmentId` | `200 OK` - Payment record |

---

## 6. Results Endpoints (`/api/results`)

| Method | Endpoint | Access | Description | Request Body / Parameters | Success Response |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `POST` | `/api/results` | Organiser | Record participant finish time | `{ "enrolmentId", "finishTime", "position" }` | `201 Created` - Result record |
| `GET` | `/api/events/{eventId}/results` | Public | View leaderboards for an event | Path param: `eventId` | `200 OK` - Ranked Results |
