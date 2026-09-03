-- RaceDay Database Schema Script

-- =========================================================
-- RaceDay Event Management System - Database Schema
-- Target RDBMS: Microsoft SQL Server (SSMS)
-- Entities: Users, Events, Categories, Enrolments, Payments, Results
-- =========================================================

IF DB_ID('RaceDayDB') IS NOT NULL
BEGIN
    ALTER DATABASE RaceDayDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE RaceDayDB;
END
GO

CREATE DATABASE RaceDayDB;
GO

USE RaceDayDB;
GO

-- 1. Users Table
CREATE TABLE Users (
    userId INT IDENTITY(1,1) PRIMARY KEY,
    fullName VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('Organiser', 'Participant')),
    createdAt DATETIME NOT NULL DEFAULT GETDATE()
);

-- 2. Events Table
CREATE TABLE Events (
    eventId INT IDENTITY(1,1) PRIMARY KEY,
    organiserId INT NOT NULL,
    name VARCHAR(150) NOT NULL,
    description NVARCHAR(MAX) NULL,
    eventDate DATETIME NOT NULL,
    location VARCHAR(150) NOT NULL,
    distance DECIMAL(5,2) NOT NULL CHECK (distance > 0),
    eventType VARCHAR(20) NOT NULL CHECK (eventType IN ('Walk', 'Run', 'Cycle')),
    createdAt DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Events_Users FOREIGN KEY (organiserId) REFERENCES Users(userId)
);

-- 3. Categories Table
CREATE TABLE Categories (
    categoryId INT IDENTITY(1,1) PRIMARY KEY,
    eventId INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    minAge INT NULL CHECK (minAge >= 0),
    maxAge INT NULL CHECK (maxAge >= minAge),
    distanceKm DECIMAL(5,2) NOT NULL CHECK (distanceKm > 0),
    entryFee DECIMAL(10,2) NOT NULL DEFAULT 0.00 CHECK (entryFee >= 0),
    CONSTRAINT FK_Categories_Events FOREIGN KEY (eventId) REFERENCES Events(eventId) ON DELETE CASCADE
);

-- 4. Event Enrolments Table
CREATE TABLE Enrolments (
    enrolmentId INT IDENTITY(1,1) PRIMARY KEY,
    userId INT NOT NULL,
    eventId INT NOT NULL,
    categoryId INT NOT NULL,
    enrolmentDate DATETIME NOT NULL DEFAULT GETDATE(),
    status VARCHAR(20) NOT NULL DEFAULT 'Confirmed' CHECK (status IN ('Pending', 'Confirmed', 'Cancelled')),
    CONSTRAINT FK_Enrolments_Users FOREIGN KEY (userId) REFERENCES Users(userId),
    CONSTRAINT FK_Enrolments_Events FOREIGN KEY (eventId) REFERENCES Events(eventId),
    CONSTRAINT FK_Enrolments_Categories FOREIGN KEY (categoryId) REFERENCES Categories(categoryId),
    CONSTRAINT UQ_User_Event UNIQUE (userId, eventId)
);

-- 5. Payments Table
CREATE TABLE Payments (
    paymentId INT IDENTITY(1,1) PRIMARY KEY,
    enrolmentId INT NOT NULL UNIQUE,
    amount DECIMAL(10,2) NOT NULL CHECK (amount >= 0),
    paymentStatus VARCHAR(20) NOT NULL CHECK (paymentStatus IN ('Paid', 'Pending', 'Failed')),
    paymentDate DATETIME NOT NULL DEFAULT GETDATE(),
    transactionReference VARCHAR(100) NOT NULL UNIQUE,
    CONSTRAINT FK_Payments_Enrolments FOREIGN KEY (enrolmentId) REFERENCES Enrolments(enrolmentId) ON DELETE CASCADE
);

-- 6. Results Table
CREATE TABLE Results (
    resultId INT IDENTITY(1,1) PRIMARY KEY,
    enrolmentId INT NOT NULL UNIQUE,
    finishTime VARCHAR(20) NOT NULL,
    position INT NOT NULL CHECK (position > 0),
    recordedAt DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Results_Enrolments FOREIGN KEY (enrolmentId) REFERENCES Enrolments(enrolmentId) ON DELETE CASCADE
);
GO

-- =========================================================
-- SEED DATA
-- =========================================================

INSERT INTO Users (fullName, email, password, role) VALUES
('Sipho Nkosi', 'sipho.organiser@raceday.co.za', 'hashed_pass_123', 'Organiser'),
('Anika van Zyl', 'anika.organiser@raceday.co.za', 'hashed_pass_456', 'Organiser'),
('David Smith', 'david.runner@gmail.com', 'hashed_pass_789', 'Participant'),
('Zanele Khumalo', 'zanele.cyclist@gmail.com', 'hashed_pass_012', 'Participant');

INSERT INTO Events (organiserId, name, description, eventDate, location, distance, eventType) VALUES
(1, 'Soweto Marathon', 'Iconic road running event across historical landmarks.', '2026-11-01 06:00:00', 'Soweto, Johannesburg', 42.20, 'Run'),
(2, 'Cape Town Cycle Challenge', 'Premier road cycling event along coastal routes.', '2026-03-08 06:30:00', 'Cape Town', 109.00, 'Cycle'),
(1, 'Durban Promenade Walk', 'Scenic 10km coastal walk.', '2026-10-15 07:00:00', 'Durban', 10.00, 'Walk');

INSERT INTO Categories (eventId, name, minAge, maxAge, distanceKm, entryFee) VALUES
(1, 'Open Senior 42km', 20, 49, 42.20, 350.00),
(1, 'Under 20 Half Marathon', 15, 19, 21.10, 250.00),
(2, '109km Main Challenge', 18, 70, 109.00, 650.00),
(3, '10km Family Walk', 5, 80, 10.00, 100.00);

INSERT INTO Enrolments (userId, eventId, categoryId, status) VALUES
(3, 1, 1, 'Confirmed'),
(4, 2, 3, 'Confirmed');

INSERT INTO Payments (enrolmentId, amount, paymentStatus, transactionReference) VALUES
(1, 350.00, 'Paid', 'TXN-SOWETO-001'),
(2, 650.00, 'Paid', 'TXN-CTCYCLE-002');

INSERT INTO Results (enrolmentId, finishTime, position) VALUES
(1, '03:15:42', 12),
(2, '02:48:10', 45);
GO
