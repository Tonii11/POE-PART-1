/* =================================================================
   RaceDay Event Management System
   Database Creation & Seed Script
   Module: PROG6212 - Programming 2B
   Student Number: ST10184019
   Part 1 - System Planning and Database, Section C

   Run this script against a clean SQL Server instance using SSMS.
   It creates the RaceDayDB database, all six tables from the ERD
   in ERD_RaceDay.png, and seeds realistic sample data.
   ================================================================= */

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

/* -----------------------------------------------------------------
   Table: Roles
   Lookup table distinguishing Organiser and Participant accounts.
   ----------------------------------------------------------------- */
CREATE TABLE Roles (
    RoleID      INT IDENTITY(1,1) NOT NULL,
    RoleName    VARCHAR(20)       NOT NULL,
    CONSTRAINT PK_Roles PRIMARY KEY (RoleID),
    CONSTRAINT UQ_Roles_RoleName UNIQUE (RoleName)
);
GO

/* -----------------------------------------------------------------
   Table: Users
   Stores both Organisers and Participants, differentiated by RoleID.
   ----------------------------------------------------------------- */
CREATE TABLE Users (
    UserID              INT IDENTITY(1,1) NOT NULL,
    RoleID              INT               NOT NULL,
    FirstName           VARCHAR(50)       NOT NULL,
    LastName            VARCHAR(50)       NOT NULL,
    Email               VARCHAR(100)      NOT NULL,
    PasswordHash        VARCHAR(255)      NOT NULL,
    PhoneNumber         VARCHAR(20)       NULL,
    ProfileImageUrl     VARCHAR(255)      NULL,
    DateRegistered      DATETIME          NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_Users PRIMARY KEY (UserID),
    CONSTRAINT UQ_Users_Email UNIQUE (Email),
    CONSTRAINT FK_Users_Roles FOREIGN KEY (RoleID) REFERENCES Roles(RoleID)
);
GO

/* -----------------------------------------------------------------
   Table: Events
   Created and managed by Organisers.
   ----------------------------------------------------------------- */
CREATE TABLE Events (
    EventID         INT IDENTITY(1,1)   NOT NULL,
    OrganiserID     INT                 NOT NULL,
    EventName       VARCHAR(100)        NOT NULL,
    Description     VARCHAR(1000)       NULL,
    EventDate       DATETIME            NOT NULL,
    Location        VARCHAR(150)        NOT NULL,
    DistanceKM      DECIMAL(6,2)        NOT NULL,
    EventType       VARCHAR(10)         NOT NULL,
    BannerImageUrl  VARCHAR(255)        NULL,
    CreatedAt       DATETIME            NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_Events PRIMARY KEY (EventID),
    CONSTRAINT FK_Events_Organiser FOREIGN KEY (OrganiserID) REFERENCES Users(UserID),
    CONSTRAINT CK_Events_EventType CHECK (EventType IN ('Run', 'Walk', 'Cycle')),
    CONSTRAINT CK_Events_DistanceKM CHECK (DistanceKM > 0)
);
GO

/* -----------------------------------------------------------------
   Table: Categories
   Age / distance categories defined per event.
   ----------------------------------------------------------------- */
CREATE TABLE Categories (
    CategoryID          INT IDENTITY(1,1) NOT NULL,
    EventID             INT               NOT NULL,
    CategoryName        VARCHAR(50)       NOT NULL,
    MinAge              INT               NULL,
    MaxAge              INT               NULL,
    CategoryDistanceKM  DECIMAL(6,2)      NULL,
    CONSTRAINT PK_Categories PRIMARY KEY (CategoryID),
    CONSTRAINT FK_Categories_Events FOREIGN KEY (EventID)
        REFERENCES Events(EventID) ON DELETE CASCADE,
    CONSTRAINT CK_Categories_AgeRange CHECK (MinAge IS NULL OR MaxAge IS NULL OR MinAge <= MaxAge)
);
GO

/* -----------------------------------------------------------------
   Table: Enrolments
   Links a Participant to an Event under a chosen Category.
   ----------------------------------------------------------------- */
CREATE TABLE Enrolments (
    EnrolmentID     INT IDENTITY(1,1) NOT NULL,
    ParticipantID   INT               NOT NULL,
    EventID         INT               NOT NULL,
    CategoryID      INT               NOT NULL,
    EnrolmentDate   DATETIME          NOT NULL DEFAULT GETDATE(),
    EnrolmentStatus VARCHAR(20)       NOT NULL DEFAULT 'Pending',
    CONSTRAINT PK_Enrolments PRIMARY KEY (EnrolmentID),
    CONSTRAINT FK_Enrolments_Participant FOREIGN KEY (ParticipantID) REFERENCES Users(UserID),
    CONSTRAINT FK_Enrolments_Event FOREIGN KEY (EventID) REFERENCES Events(EventID),
    CONSTRAINT FK_Enrolments_Category FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID),
    CONSTRAINT UQ_Enrolments_ParticipantEvent UNIQUE (ParticipantID, EventID),
    CONSTRAINT CK_Enrolments_Status CHECK (EnrolmentStatus IN ('Pending', 'Confirmed', 'Cancelled'))
);
GO

/* -----------------------------------------------------------------
   Table: Results
   Captured by Organisers once an event has concluded.
   One-to-one with Enrolments (each enrolment has at most one result).
   ----------------------------------------------------------------- */
CREATE TABLE Results (
    ResultID            INT IDENTITY(1,1) NOT NULL,
    EnrolmentID         INT               NOT NULL,
    FinishTimeSeconds   INT               NOT NULL,
    FinishPosition      INT               NOT NULL,
    TotalFinishers      INT               NOT NULL,
    CapturedByUserID    INT               NOT NULL,
    DateCaptured        DATETIME          NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_Results PRIMARY KEY (ResultID),
    CONSTRAINT UQ_Results_Enrolment UNIQUE (EnrolmentID),
    CONSTRAINT FK_Results_Enrolment FOREIGN KEY (EnrolmentID) REFERENCES Enrolments(EnrolmentID),
    CONSTRAINT FK_Results_CapturedBy FOREIGN KEY (CapturedByUserID) REFERENCES Users(UserID),
    CONSTRAINT CK_Results_Position CHECK (FinishPosition > 0 AND FinishPosition <= TotalFinishers)
);
GO

/* =================================================================
   SEED DATA
   2 Organisers, 2 Participants, 3 Events, categories per event,
   sample enrolments, and one captured result.
   ================================================================= */

INSERT INTO Roles (RoleName) VALUES ('Organiser'), ('Participant');
GO

-- Organisers (2)
INSERT INTO Users (RoleID, FirstName, LastName, Email, PasswordHash, PhoneNumber, DateRegistered)
VALUES
(1, 'Naledi', 'Khumalo',        'naledi.khumalo@raceday.co.za', 'X9f3KQpL2mZ7vH1n$hashed', '0821234567', '2026-01-14'),
(1, 'Pieter', 'van der Merwe',  'pieter.vdm@raceday.co.za',     'R4tY8wEq5nB2sD0k$hashed', '0837654321', '2026-02-03');
GO

-- Participants (2)
INSERT INTO Users (RoleID, FirstName, LastName, Email, PasswordHash, PhoneNumber, DateRegistered)
VALUES
(2, 'Thandeka', 'Mokoena', 'thandeka.mokoena@gmail.com', 'L6cV1jUo9xA3pM7q$hashed', '0712223333', '2026-03-10'),
(2, 'Ryan',     'Botha',   'ryan.botha@gmail.com',       'H2sZ5rTn8kW0eF4d$hashed', '0794445555', '2026-04-22');
GO

-- Events (3) - OrganiserID 1 owns two events, OrganiserID 2 owns one
INSERT INTO Events (OrganiserID, EventName, Description, EventDate, Location, DistanceKM, EventType, BannerImageUrl)
VALUES
(1, 'Joburg Sunrise 10K',
    'A fast, flat 10km road run through Sandton starting at sunrise.',
    '2026-08-02 06:00:00', 'Sandton, Johannesburg', 10.00, 'Run', NULL),
(1, 'Vaal Dam Cycle Classic',
    'A scenic road cycling race around the Vaal Dam for all skill levels.',
    '2026-11-08 07:00:00', 'Vaal Dam, Gauteng', 60.00, 'Cycle', NULL),
(2, 'Cape Winelands Charity Walk',
    'A family-friendly charity walk through the Cape Winelands raising funds for local schools.',
    '2026-10-18 08:00:00', 'Stellenbosch, Western Cape', 5.00, 'Walk', NULL);
GO

-- Categories - at least one per event, two for the more competitive events
INSERT INTO Categories (EventID, CategoryName, MinAge, MaxAge, CategoryDistanceKM)
VALUES
(1, 'Open 10km',        16, 99, 10.00),
(1, 'Junior 10km',      12, 15, 10.00),
(2, '60km Individual',  18, 99, 60.00),
(2, '60km Team Relay',  18, 99, 60.00),
(3, '5km Family Walk',   0, 99,  5.00);
GO

-- Enrolments - Event 1 already happened (2026-08-02), so it has a Confirmed
-- enrolment ready to receive a Result. Events 2 and 3 are still upcoming.
INSERT INTO Enrolments (ParticipantID, EventID, CategoryID, EnrolmentStatus)
VALUES
(3, 1, 1, 'Confirmed'),  -- Thandeka in Joburg Sunrise 10K, Open 10km
(4, 2, 3, 'Confirmed'),  -- Ryan in Vaal Dam Cycle Classic, 60km Individual
(3, 3, 5, 'Pending');    -- Thandeka in Cape Winelands Charity Walk
GO

-- Results - captured by Naledi (OrganiserID 1) for the completed Joburg Sunrise 10K
INSERT INTO Results (EnrolmentID, FinishTimeSeconds, FinishPosition, TotalFinishers, CapturedByUserID)
VALUES
(1, 2415, 47, 312, 1);  -- 40:15 finish time, 47th out of 312 finishers, captured by Naledi (Organiser)
GO
