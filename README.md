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
* Correct Screenshot of the workflow: ** [https://github.com/Onalenna2112/RaceDayPart1/blob/main/docs/Screenshot%202026-09-04%20194540.png?raw=true]
  
  
  

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


# RaceDay API (Part 2 - RESTful API Development)

The RaceDay API is the back end of the RaceDay system. It handles users, events, categories,
enrolments and results, and it enforces role-based access for **Organisers** and **Participants**.

- **Video demo (YouTube, unlisted):** [PASTE YOUR YOUTUBE LINK HERE]
- **Build status:** ![Green build](docs/green-build.png) *(add your screenshot of the green GitHub Actions run as `docs/green-build.png`)*

## Technology

ASP.NET Core 8 Web API (C#), Entity Framework Core 8 (Code-First), SQL Server (LocalDB),
JWT bearer authentication, Swagger (Swashbuckle), xUnit tests, GitHub Actions.

## Setup and run

You need: Visual Studio 2022 (with the ASP.NET workload), the .NET 8 SDK and SQL Server LocalDB
(installed with Visual Studio).

1. Clone the repository and open `RaceDayApi.sln`.
2. Check the connection string in `RaceDayApi/appsettings.json` (default: LocalDB, database `RaceDayDb`).
3. Create the database from the models (Code-First).
   In Visual Studio open **Tools > NuGet Package Manager > Package Manager Console**, set the
   default project to `RaceDayApi`, and run:
   ```
   Add-Migration InitialCreate
   Update-Database
   ```
   Or with the command line, from the solution folder:
   ```
   dotnet ef migrations add InitialCreate --project RaceDayApi
   dotnet ef database update --project RaceDayApi
   ```
   *(If you created the database with an older migration earlier, run `Drop-Database` first.)*
4. Press **F5** (or `dotnet run --project RaceDayApi`). Swagger opens in the browser at `/swagger`.

### Settings you can change (`appsettings.json`)

| Setting | Meaning |
|---|---|
| `Jwt:Key` | Secret used to sign login tokens (use a long random value; in real life keep it in user-secrets). |
| `Jwt:ExpiryMinutes` | How long a login token stays valid. |
| `Auth:OrganiserRegistrationCode` | Secret code required to register as an Organiser. |

## The two roles

| | Organiser | Participant |
|---|---|---|
| How to register | `POST /api/auth/register` with `role: "Organiser"` **and** the secret `organiserCode` | `POST /api/auth/register` with `role: "Participant"` |
| Events | Create, update and delete **own** events; view all events | View events |
| Categories | Create, update and delete categories of **own** events | View categories |
| Enrolments | View all enrolments for **own** events; remove an enrolment from own event | Enrol in an event by choosing a category; view and cancel **own** enrolments |
| Results | Capture finish time and position; view all results of **own** events | View **own** results |
| Profile | View and update own profile | View and update own profile |

An Organiser cannot use Participant functions and a Participant cannot use Organiser functions
(the API answers **403 Forbidden**). Requests without a valid token get **401 Unauthorized**.
Only `register` and `login` are public.

Why the organiser code? Anyone can sign up on the public API, so an Organiser account must not be
available to everybody. The code is known only to the system owner.

## How authentication works

1. `POST /api/auth/register` creates the account. The password is hashed with ASP.NET Core's
   `PasswordHasher` and only the hash is stored.
2. `POST /api/auth/login` checks the password and returns a signed **JWT token** that contains the
   user's id and role.
3. In Swagger click **Authorize** and paste the token. Every later request carries the token, and
   `[Authorize]` / `[Authorize(Roles = "...")]` attributes decide what the user may do.

## Endpoints

| Method | Route | Who |
|---|---|---|
| POST | `/api/auth/register` | Public |
| POST | `/api/auth/login` | Public |
| GET, PUT | `/api/users/{id}` | Logged in (own profile only) |
| GET | `/api/events`, `/api/events/{id}` | Both roles |
| POST | `/api/events` | Organiser |
| PUT, DELETE | `/api/events/{id}` | Organiser (own event) |
| GET | `/api/events/{eventId}/categories` | Both roles |
| POST | `/api/events/{eventId}/categories` | Organiser (own event) |
| PUT, DELETE | `/api/categories/{id}` | Organiser (own event) |
| POST | `/api/events/{id}/enrolments` | Participant |
| GET | `/api/events/{id}/enrolments` | Organiser (own event) |
| GET | `/api/participants/{id}/enrolments` | Participant (own) |
| DELETE | `/api/enrolments/{id}` | Participant (own) or Organiser (own event) |
| POST | `/api/enrolments/{enrolmentId}/results` | Organiser (own event) |
| GET | `/api/events/{eventId}/results` | Organiser (own event) |
| GET | `/api/participants/{id}/results` | Participant (own) |

Every endpoint shows its description, expected data and possible responses in Swagger.

## Tests

```
dotnet test
```

- **Unit tests** (`AuthControllerTests`, `EventsControllerTests`) call the controllers directly.
- **API tests** (`AuthApiTests`, `EventApiTests`, `EnrolmentApiTests`, `ResultApiTests`) start the real
  API in memory (real JWT authentication and role checks, in-memory database) and check
  both success and failure cases: registration and login, authenticated vs. unauthenticated requests,
  Organiser-only and Participant-only actions, enrolment records, and results.

## CI/CD

`.github/workflows/dotnet.yml` builds the solution and runs all tests on every push.

![CI build](docs/green-build.png)

## Project structure

```
RaceDayApi/                API project
  Controllers/             Auth, Users, Events, Categories, Enrollment, Results
  Models/                  Entities, request DTOs, response DTOs, Roles
  Services/                TokenService (JWT), claim helpers
  Data/                    RaceDayDbContext
RaceDayApi.Tests/          xUnit tests
.github/workflows/         GitHub Actions workflow
```
