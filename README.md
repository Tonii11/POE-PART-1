# RaceDay — Part 1: System Planning and Database

**Module:** PROG6212 – Programming 2B
**Student Number:** ST10184019
**GitHub:** [TONII11](https://github.com/TONII11)
**Email:** ST10184019@rcconnect.edu.za
**Part:** 1 of 3 — System Planning and Database (100 Marks)

## System description

RaceDay is a full-stack event management platform for the South African road
running, walking, and cycling community. It replaces the paper-based
registration and spreadsheet tracking many community events currently rely on.
Event Organisers can create events, define age/distance categories, capture
participant results, and view enrolments. Participants can browse upcoming
events, enter an event under a chosen category, and track their personal
race history.

This part of the Portfolio of Evidence covers the planning phase only — no
API code is written here. It contains the Entity Relationship Diagram, the
API endpoint plan, and the SQL script that Part 2 will be built against.

## Roles

- **Organiser** — creates, edits, and deletes events; manages event
  categories; captures participant results; views all enrolments for their
  events.
- **Participant** — creates an account; browses events; enrols in an event
  under a chosen category; views their own enrolments and results.

## Contents of `/docs`

| File | Section | Description |
|---|---|---|
| `ERD_RaceDay.png` | A | Entity Relationship Diagram — 6 entities (Roles, Users, Events, Categories, Enrolments, Results) with primary keys, foreign keys, and cardinality. |
| `API_Endpoint_Plan.md` | B | Full endpoint plan covering Authentication, User Profile, Events, Categories, Event Enrolments, and Results. |
| `RaceDay_Database_Script.sql` | C | SQL Server script that creates the `RaceDayDB` database and seeds it with sample Organisers, Participants, Events, Categories, Enrolments, and a Result. |

## How to run the SQL script

1. Open **SQL Server Management Studio (SSMS)** and connect to a local or
   clean SQL Server instance.
2. Open `docs/RaceDay_Database_Script.sql`.
3. Execute the script (F5). It drops any existing `RaceDayDB` database,
   recreates it, creates all six tables with their constraints, and seeds
   sample data.
4. Confirm the seed data with, for example:
   ```sql
   USE RaceDayDB;
   SELECT * FROM Users;
   SELECT * FROM Events;
   ```

## Design notes

- `Roles` is a lookup table rather than an enum column so that the
  Organiser/Participant split matches how ASP.NET Core Identity roles will
  be modelled in Part 2.
- `Enrolments` has a unique constraint on `(ParticipantID, EventID)` so a
  Participant cannot enrol in the same event twice.
- `Results` has a one-to-one relationship with `Enrolments` (enforced with a
  unique constraint on `EnrolmentID`) since a single enrolment produces at
  most one result.
- The seed data includes one event dated in the past
  (`Joburg Sunrise 10K`, 2026-08-02) with a captured result, and two
  upcoming events with pending/confirmed enrolments only — this mirrors how
  the real system behaves, since results can only exist for events that
  have already taken place.

## GitHub and CI/CD

- A minimum of 20 meaningful commits has been made to this repository for
  Part 1 under the `TONII11` GitHub account.
- The GitHub Actions workflow at `.github/workflows/part1-docs-validation.yml`
  checks that the `/docs` folder exists and contains the ERD, endpoint plan,
  and SQL script, and that this README is present.
- CI/CD screenshot: *add a screenshot of the green Actions build here once
  pushed to GitHub* → `docs/cicd-screenshot.png`.

## Video

Unlisted YouTube walkthrough: *add link here* — the video should walk
through the ERD decisions, the endpoint plan choices, and run the SQL
script live in SSMS, as required by the brief.

## AI usage disclosure

As required by the assignment instructions, this note discloses that an AI
assistant (Claude) was used during the planning process to help structure
the ERD, draft the API endpoint table, and write the SQL script. All design
decisions — entity choices, relationships, and endpoint scope — were
reviewed and are understood by the student. *Expand or adjust this
disclosure to accurately reflect how you actually used AI tools before
submitting.*
