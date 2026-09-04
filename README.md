# RaceDay - Event Management System (Part 1)

## 1. System Description
RaceDay is an event management platform built specifically for road running, cycling, and walking events across South Africa. The system allows event organizers to create, host, and manage competitive events and categories, while enabling participants to register, enrol, process payments, and track their official finish times and leaderboard standings.

---

## 2. User Roles & System Permissions

###  Organiser
* **Event & Category Management:** Create, update, and cancel events as well as define sub-categories (e.g., age limits, distances, and entry fees).
* **Participant Management:** View all user enrolments and registration details across their hosted events.
* **Results Entry:** Record and update official finish times and leaderboard positions for participants.

###  Participant
* **Event Browsing:** View details of upcoming events and their respective categories/entry criteria.
* **Enrolment & Payment:** Register for chosen event categories and generate transaction payment references.
* **Result Tracking:** Access personal finish times and overall race rankings post-event.

---

## 3. Repository & Documentation Structure
All required planning, database, and architectural documentation are maintained within the `/docs` folder:

* **Entity Relationship Diagram (ERD):** [`/docs/ERD.pdf`](./docs/ERD.pdf)
* **API Endpoint Plan:** [`/docs/API_Plan.md`](./docs/API_Plan.md)
* **SQL Database Schema Script:** [`/docs/RaceDay_Schema.sql`](./docs/RaceDay_Schema.sql)
* YouTube video:** [https://youtu.be/6Gpf01Pnj_U]
* Screenshot of the green check mark:** [https://github.com/Onalenna2112/RaceDayPart1/blob/main/docs/Screenshot%202026-09-04%20160453.png]
  
  

---

## 4. Setup & Verification Instructions (SSMS)

To restore and test the database schema in **Microsoft SQL Server Management Studio (SSMS)**:

1. Clone or download this repository.
2. Open **SSMS** and connect to your local SQL Server instance.
3. Open the file located at `docs/RaceDay_Schema.sql`.
4. Execute the script (`F5`).
5. Verify execution output:
   * Recreates `RaceDayDB`.
   * Defines 6 core relational entities (`Users`, `Events`, `Categories`, `Enrolments`, `Payments`, `Results`).
   * Enforces all primary/foreign key relationships and `CHECK` constraints.
   * Populates initial seed data across all 6 tables.

To verify populated data, run:
```sql
USE RaceDayDB;
SELECT * FROM Users;
SELECT * FROM Events;
SELECT * FROM Categories;
SELECT * FROM Enrolments;
SELECT * FROM Payments;
SELECT * FROM Results;
