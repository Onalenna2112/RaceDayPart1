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
