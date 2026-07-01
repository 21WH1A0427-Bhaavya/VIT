CREATE DATABASE UniHackathon;
USE UniHackathon;

CREATE TABLE Participants (
id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(50) UNIQUE,
    phone VARCHAR(10)
);
CREATE TABLE Student (
studentID INT PRIMARY KEY,
dept VARCHAR(70),
    uni VARCHAR(120),
    FOREIGN KEY (studentID) REFERENCES Participants(id) ON DELETE CASCADE
);
CREATE TABLE Mentor (
mentorID INT PRIMARY KEY,
    exp INT CHECK (exp > 0),
    specialization VARCHAR(50),
    FOREIGN KEY (mentorID) REFERENCES Participants(id) ON DELETE CASCADE
);
CREATE TABLE Competition (
compID INT PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    venue VARCHAR(150) NOT NULL,
    date DATE DEFAULT (CURRENT_DATE)
);
CREATE TABLE Organisers (
orgID INT PRIMARY KEY,
    comp INT NOT NULL,
    FOREIGN KEY (orgID) REFERENCES Participants(id) ON DELETE CASCADE,
    FOREIGN KEY (comp) REFERENCES Competition(compID) ON DELETE CASCADE
);
CREATE TABLE Mentorship (
	studentID INT NOT NULL,
    mentorID INT NOT NULL,
	PRIMARY KEY (studentID, mentorID),
    FOREIGN KEY (studentID) REFERENCES Student(studentID),
    FOREIGN KEY (mentorID) REFERENCES Mentor(MentorID)
);
CREATE TABLE MentorHierarchy (
    seniorID INT,
    juniorID INT,
    PRIMARY KEY (seniorID, juniorID),
    FOREIGN KEY (seniorID) REFERENCES Mentor(mentorID),
    FOREIGN KEY (juniorID) REFERENCES Mentor(mentorID)
);
CREATE TABLE ParticipatesIN (
studentId INT NOT NULL,
    compID INT NOT NULL,
    mentorID INT NOT NULL,
    PRIMARY KEY (studentID, compID, mentorID),
    role VARCHAR(20) DEFAULT "Contestant" CHECK (role in ('Contestant', 'TeamLead')),
    FOREIGN KEY (studentID) REFERENCES Student(studentID) ON DELETE CASCADE,
    FOREIGN KEY (compID) REFERENCES Competition(compID) ON DELETE CASCADE,
    FOREIGN KEY (mentorID) REFERENCES Mentor(mentorID) ON DELETE CASCADE
);
CREATE TABLE Awards (
	studentID INT,
	compID INT,
    PRIMARY KEY (compID, studentID),
	position INT CHECK (position IN (1, 2, 3)),
    FOREIGN KEY (studentID) REFERENCES Student(studentID) ON DELETE CASCADE,
    FOREIGN KEY (compID) REFERENCES Competition(compID) ON DELETE CASCADE
);

INSERT INTO Participants (id, name, email, phone) VALUES
(1, 'Arjun', 'arjun1@example.com', '987650001'),
(2, 'Karthik', 'karthik2@example.com', '987650002'),
(3, 'Suresh', 'suresh3@example.com', '987650003'),
(4, 'Manoj', 'manoj4@example.com', '987650004'),
(5, 'Ravi', 'ravi5@example.com', '987650005'),
(6, 'Vignesh', 'vignesh6@example.com', '987650006'),
(7, 'Anand', 'anand7@example.com', '987650007'),
(8, 'Mohan', 'mohan8@example.com', '987650008'),
(9, 'Balaji', 'balaji9@example.com', '987650009'),
(10, 'Krishna', 'krishna10@example.com', '987650010'),
(11, 'Hari', 'hari11@example.com', '987650011'),
(12, 'Praveen', 'praveen12@example.com', '987650012'),
(13, 'Sandhya', 'sandhya13@example.com', '987650013'),
(14, 'Sathish', 'sathish14@example.com', '987650014'),
(15, 'Gopal', 'gopal15@example.com', '987650015'),
(16, 'Ramesh', 'ramesh16@example.com', '987650016'),
(17, 'Vijay', 'vijay17@example.com', '987650017'),
(18, 'Ajay', 'ajay18@example.com', '987650018'),
(19, 'Muthu', 'muthu19@example.com', '987650019'),
(20, 'Aravind', 'aravind20@example.com', '987650020');

INSERT INTO Student (studentID, dept, uni) VALUES
(1, 'CSE', 'Anna University'),
(2, 'ECE', 'IIT Madras'),
(3, 'EEE', 'Osmania University'),
(4, 'MECH', 'NIT Trichy'),
(5, 'IT', 'VIT Vellore'),
(6, 'Civil', 'SRM University'),
(7, 'CSE', 'BITS Hyderabad'),
(8, 'EEE', 'Andhra University'),
(9, 'ECE', 'JNTU Hyderabad'),
(10, 'MECH', 'PSG Tech');

INSERT INTO Mentor (mentorID, exp, specialization) VALUES
(11, 5, 'AI'),
(12, 7, 'IoT'),
(13, 3, 'Blockchain'),
(14, 10, 'Embedded'),
(15, 6, 'CyberSecurity'),
(16, 8, 'Cloud'),
(17, 4, 'Data Science'),
(18, 12, 'Robotics'),
(19, 15, 'VLSI'),
(20, 9, 'Networking');

INSERT INTO Competition (compID, name, venue, date) VALUES
(101, 'HackathonX', 'Chennai Trade Center', '2025-09-01'),
(102, 'TechNova', 'IIT Madras', '2025-09-05'),
(103, 'CodeFest', 'Anna University', '2025-09-10'),
(104, 'InnoJam', 'Hyderabad Convention', '2025-09-15'),
(105, 'DevSprint', 'VIT Vellore', '2025-09-20'),
(106, 'RoboRace', 'NIT Trichy', '2025-09-25'),
(107, 'AlgoMania', 'Osmania University', '2025-09-30'),
(108, 'SmartCity', 'SRM University', '2025-10-02'),
(109, 'HackSphere', 'JNTU Hyderabad', '2025-10-07'),
(110, 'CodeStorm', 'BITS Hyderabad', '2025-10-12'),
(111, 'TechThon', 'PSG Tech', '2025-10-17'),
(112, 'CloudHack', 'IIT Madras', '2025-10-22'),
(113, 'CyberWarriors', 'Anna University', '2025-10-27'),
(114, 'DeepHack', 'IIIT Hyderabad', '2025-11-01'),
(115, 'RoboVision', 'NIT Warangal', '2025-11-06'),
(116, 'DataThon', 'IIT Hyderabad', '2025-11-11'),
(117, 'SecureCode', 'JNTU Kakinada', '2025-11-16'),
(118, 'AIJam', 'SRM Chennai', '2025-11-21'),
(119, 'MegaHack', 'Andhra University', '2025-11-26'),
(120, 'TechBlast', 'Chennai Trade Center', '2025-12-01');

INSERT INTO Organisers (orgID, comp) VALUES
(6, 101),
(7, 102),
(8, 103),
(9, 104),
(10, 105),
(16, 106),
(17, 107),
(18, 108),
(19, 109),
(20, 110),
(1, 111),
(2, 112),
(3, 113),
(4, 114),
(5, 115),
(11, 116),
(12, 117),
(13, 118),
(14, 119),
(15, 120);

INSERT INTO Mentorship (studentID, mentorID) VALUES
(1, 11), (2, 12), (3, 13), (4, 14), (5, 15),
(6, 16), (7, 17), (8, 18), (9, 19), (10, 20),
(1, 12), (2, 13), (3, 14), (4, 15), (5, 16),
(6, 17), (7, 18), (8, 19), (9, 20), (10, 11);

INSERT INTO MentorHierarchy (seniorID, juniorID) VALUES
(11, 12), (12, 13), (13, 14), (14, 15), (15, 16),
(16, 17), (17, 18), (18, 19), (19, 20), (20, 11),
(11, 13), (12, 14), (13, 15), (14, 16), (15, 17),
(16, 18), (17, 19), (18, 20), (19, 11), (20, 12);

INSERT INTO ParticipatesIN (studentID, compID, mentorID, role) VALUES
(1, 101, 11, 'Contestant'),
(2, 102, 12, 'TeamLead'),
(3, 103, 13, 'Contestant'),
(4, 104, 14, 'TeamLead'),
(5, 105, 15, 'Contestant'),
(6, 106, 16, 'TeamLead'),
(7, 107, 17, 'Contestant'),
(8, 108, 18, 'TeamLead'),
(9, 109, 19, 'Contestant'),
(10, 110, 20, 'TeamLead'),
(1, 111, 12, 'Contestant'),
(2, 112, 13, 'Contestant'),
(3, 113, 14, 'Contestant'),
(4, 114, 15, 'Contestant'),
(5, 115, 16, 'Contestant'),
(6, 116, 17, 'Contestant'),
(7, 117, 18, 'Contestant'),
(8, 118, 19, 'Contestant'),
(9, 119, 20, 'Contestant'),
(10, 120, 11, 'Contestant');

INSERT INTO Awards (studentID, compID, position) VALUES
(1, 101, 1),
(2, 102, 2),
(3, 103, 3),
(4, 104, 1),
(5, 105, 2),
(6, 106, 3),
(7, 107, 1),
(8, 108, 2),
(9, 109, 3),
(10, 110, 1),
(1, 111, 2),
(2, 112, 3),
(3, 113, 1),
(4, 114, 2),
(5, 115, 3),
(6, 116, 1),
(7, 117, 2),
(8, 118, 3),
(9, 119, 1),
(10, 120, 2);

SELECT * FROM Participants;
SELECT * FROM Student;
SELECT * FROM Mentor;
SELECT * FROM Competition;
SELECT * FROM Organisers;
SELECT * FROM Mentorship;
SELECT * FROM MentorHierarchy;
SELECT * FROM ParticipatesIN;
SELECT * FROM Awards;

-- AGGREGATE FUNCTIONS
-- Count how many students are in each department
SELECT dept, COUNT(*) AS total_students
FROM Student
GROUP BY dept;

-- Find the average experience of mentors
SELECT AVG(exp) AS avg_exp
FROM Mentor;

-- Get the maximum and minimum experience among mentors
SELECT MAX(exp) AS max_exp,
       MIN(exp) AS min_exp
FROM Mentor;

-- Find how many competitions each student participated in
SELECT studentID, COUNT(compID) AS comp_attended
FROM ParticipatesIN
GROUP BY studentID;

-- Total awards given in each competition
SELECT compID, COUNT(studentID) AS total_awards
FROM Awards
GROUP BY compID;

-- GROUP BY
-- Mentors with average student count >= 2
SELECT mentorID, COUNT(studentID) AS total_students
FROM Mentorship
GROUP BY mentorID
HAVING COUNT(studentID) >= 2;

-- Competitions that gave at least 2 awards
SELECT compID, COUNT(studentID) AS awards_count
FROM Awards
GROUP BY compID
HAVING COUNT(studentID) >= 2;

CREATE USER 'user1'@'localhost' IDENTIFIED BY 'user123';
GRANT SELECT ON UniHackathon.* TO 'user1'@'localhost';
FLUSH PRIVILEGES;

USE UniHackathon;



