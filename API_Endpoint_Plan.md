# RaceDay API Endpoint Plan

**Module:** PROG6212 – Programming 2B
**Student Number:** ST10184019
**GitHub:** TONII11
**Part:** 1 – System Planning and Database, Section B

This plan lists every endpoint the RaceDay API will expose in Part 2, grouped by
resource. It is built directly from the ERD in `ERD_RaceDay.png` and the SQL script
in `RaceDay_Database_Script.sql`. A few endpoints beyond the stated minimum
(logout, category deletion) have been added because they are needed for a
complete, usable system.

## 1. Authentication

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| POST | /api/auth/register | Registers a new account as either an Organiser or a Participant. | None (public) | `{ firstName, lastName, email, password, role, phoneNumber }` | 201 Created – new user's public profile · 400 Bad Request – validation failed · 409 Conflict – email already registered |
| POST | /api/auth/login | Authenticates a user and starts a session that stores their user ID and role. | None (public) | `{ email, password }` | 200 OK – session created, returns role and profile summary · 401 Unauthorized – invalid credentials |
| POST | /api/auth/logout | Ends the current user's session. | Any (logged in) | None | 200 OK – session cleared |

## 2. User Profile

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| GET | /api/users/me | Retrieves the profile of the currently logged-in user. | Any (logged in) | None | 200 OK – user profile · 401 Unauthorized – no active session |
| PUT | /api/users/me | Updates the profile details of the currently logged-in user. | Any (logged in) | `{ firstName, lastName, phoneNumber }` | 200 OK – updated profile · 400 Bad Request – invalid data |

## 3. Events

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| GET | /api/events | Lists all events, with optional query filters (date, type, location). | None (public) | None | 200 OK – array of events |
| GET | /api/events/{id} | Retrieves full details for a single event, including its categories. | None (public) | None | 200 OK – event details · 404 Not Found |
| POST | /api/events | Creates a new event owned by the logged-in Organiser. | Organiser | `{ eventName, description, eventDate, location, distanceKm, eventType }` | 201 Created – new event · 400 Bad Request – validation failed · 403 Forbidden – caller is not an Organiser |
| PUT | /api/events/{id} | Updates an event that belongs to the logged-in Organiser. | Organiser | `{ eventName, description, eventDate, location, distanceKm, eventType }` | 200 OK – updated event · 403 Forbidden – not the event owner · 404 Not Found |
| DELETE | /api/events/{id} | Deletes an event owned by the logged-in Organiser. | Organiser | None | 204 No Content · 403 Forbidden · 404 Not Found |

## 4. Categories

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| GET | /api/events/{eventId}/categories | Lists all categories available for a specific event. | None (public) | None | 200 OK – array of categories · 404 Not Found |
| POST | /api/events/{eventId}/categories | Adds a new age/distance category to an event owned by the logged-in Organiser. | Organiser | `{ categoryName, minAge, maxAge, categoryDistanceKm }` | 201 Created – new category · 403 Forbidden · 404 Not Found |
| DELETE | /api/categories/{id} | Removes a category from an event owned by the logged-in Organiser. | Organiser | None | 204 No Content · 403 Forbidden · 404 Not Found |

## 5. Event Enrolments

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| POST | /api/events/{eventId}/enrolments | Enrols the logged-in Participant into the event under a chosen category. | Participant | `{ categoryId }` | 201 Created – enrolment record · 400 Bad Request – already enrolled · 403 Forbidden – caller is not a Participant · 404 Not Found |
| GET | /api/users/me/enrolments | Lists every event the logged-in Participant has enrolled for, with status. | Participant | None | 200 OK – array of enrolments |
| GET | /api/events/{eventId}/enrolments | Lists all Participants enrolled for an event owned by the logged-in Organiser. | Organiser | None | 200 OK – array of enrolments · 403 Forbidden · 404 Not Found |

## 6. Results

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| POST | /api/enrolments/{enrolmentId}/results | Captures the finish time and position for a Participant's enrolment, for an event owned by the logged-in Organiser. | Organiser | `{ finishTimeSeconds, finishPosition, totalFinishers }` | 201 Created – result record · 403 Forbidden · 404 Not Found · 409 Conflict – result already captured |
| GET | /api/users/me/results | Retrieves the logged-in Participant's personal race history and results. | Participant | None | 200 OK – array of results with event name, date, category, finish time, and position |
| GET | /api/events/{eventId}/results | Retrieves all captured results for an event owned by the logged-in Organiser. | Organiser | None | 200 OK – array of results · 403 Forbidden · 404 Not Found |

## Notes on role enforcement

- **None (public):** no session required.
- **Any (logged in):** any authenticated user, Organiser or Participant.
- **Organiser / Participant:** the session's stored role must match, otherwise the
  API returns `403 Forbidden`. Ownership checks (e.g. an Organiser editing only
  their own events) are enforced in addition to the role check.
