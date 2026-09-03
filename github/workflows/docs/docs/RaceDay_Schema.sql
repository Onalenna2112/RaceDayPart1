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
