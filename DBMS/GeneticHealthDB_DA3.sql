DROP DATABASE IF EXISTS GeneticHealthDBLab2;
CREATE DATABASE GeneticHealthDBLab2;
USE GeneticHealthDBLab2;

CREATE TABLE Genes (
    gene_id INT AUTO_INCREMENT PRIMARY KEY,
    gene_name VARCHAR(50) NOT NULL,
    `function` VARCHAR(200),
    chromosome VARCHAR(10)
);

CREATE TABLE Diseases (
    disease_id INT AUTO_INCREMENT PRIMARY KEY,
    disease_name VARCHAR(100) NOT NULL,
    severity VARCHAR(50),
    common_regions VARCHAR(100)
);

CREATE TABLE Mutations (
    mutation_id INT AUTO_INCREMENT PRIMARY KEY,
    gene_id INT NOT NULL,
    disease_id INT NOT NULL,
    mutation_description VARCHAR(255),
    FOREIGN KEY (gene_id) REFERENCES Genes(gene_id) ON DELETE CASCADE,
    FOREIGN KEY (disease_id) REFERENCES Diseases(disease_id) ON DELETE CASCADE
);

CREATE TABLE Family (
    family_id INT AUTO_INCREMENT PRIMARY KEY,
    region VARCHAR(50)
);

CREATE TABLE Patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    age INT CHECK (age >= 0),
    gender ENUM('Male', 'Female', 'Other') NOT NULL,
    region VARCHAR(50) NOT NULL,
    family_id INT,
    FOREIGN KEY (family_id) REFERENCES Family(family_id) ON DELETE SET NULL
);

CREATE TABLE Screening (
    screening_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    mutation_id INT NOT NULL,
    test_date DATE NOT NULL,
    result VARCHAR(50),
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id) ON DELETE CASCADE,
    FOREIGN KEY (mutation_id) REFERENCES Mutations(mutation_id) ON DELETE CASCADE
);

CREATE TABLE Awareness_Programs (
    program_id INT AUTO_INCREMENT PRIMARY KEY,
    program_name VARCHAR(100) NOT NULL,
    date DATE NOT NULL,
    region VARCHAR(50),
    organizer VARCHAR(50),
    attendees_count INT DEFAULT 0 CHECK (attendees_count >= 0)
);

CREATE TABLE Risk_Alerts (
    alert_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT,
    alert_type VARCHAR(255),
    region VARCHAR(50),
    details TEXT,
    alert_date DATE DEFAULT (CURRENT_DATE),
    status ENUM('Pending','Resolved') DEFAULT 'Pending',
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id) ON DELETE CASCADE
);

CREATE TABLE Region_Stats (
    region VARCHAR(50) PRIMARY KEY,
    total_attendees INT DEFAULT 0 CHECK (total_attendees >= 0)
);


DELIMITER $$
-- 1. screening_date_check
CREATE TRIGGER screening_date_check
BEFORE INSERT ON Screening
FOR EACH ROW
BEGIN
    IF NEW.test_date > CURDATE() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Screening date cannot be in the future';
    END IF;
END$$

-- 2. screening_date_update
CREATE TRIGGER screening_date_update
BEFORE UPDATE ON Screening
FOR EACH ROW
BEGIN
    IF NEW.test_date > CURDATE() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Screening date cannot be in the future';
    END IF;
END$$

-- 3. trg_family_risk
CREATE TRIGGER trg_family_risk
AFTER INSERT ON Screening
FOR EACH ROW
BEGIN
    IF NEW.result = 'Positive' THEN
        INSERT INTO Risk_Alerts(patient_id, alert_type, region, details, alert_date, status)
        SELECT p.patient_id,
               CONCAT('High Risk: Family member tested positive for mutation ID ', NEW.mutation_id),
               p.region,
               'Family-based risk propagation alert.',
               CURDATE(),
               'Pending'
        FROM Patients p
        WHERE p.family_id = (SELECT family_id FROM Patients WHERE patient_id = NEW.patient_id)
          AND p.patient_id != NEW.patient_id;
    END IF;
END$$

-- 4. trg_region_alert
CREATE TRIGGER trg_region_alert
AFTER INSERT ON Patients
FOR EACH ROW
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE disease_id_var INT;
    DECLARE disease_cursor CURSOR FOR
        SELECT disease_id FROM Diseases
        WHERE FIND_IN_SET(NEW.region, REPLACE(common_regions, ' ', '')) > 0;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    OPEN disease_cursor;
    read_loop: LOOP
        FETCH disease_cursor INTO disease_id_var;
        IF done = 1 THEN LEAVE read_loop; END IF;
        INSERT INTO Risk_Alerts (patient_id, alert_type, region, details, alert_date)
        VALUES (NEW.patient_id,
                CONCAT('Region Risk: Screening recommended for Disease ID ', disease_id_var),
                NEW.region,
                'Regional genetic risk detected based on prevalence data.',
                CURDATE());
    END LOOP;
    CLOSE disease_cursor;
END$$

-- 5. trg_positive_test_outreach
CREATE TRIGGER trg_positive_test_outreach
AFTER INSERT ON Screening
FOR EACH ROW
BEGIN
    DECLARE patient_region VARCHAR(50);
    IF NEW.result = 'Positive' THEN
        SELECT region INTO patient_region FROM Patients WHERE patient_id = NEW.patient_id;
        IF NOT EXISTS (SELECT 1 FROM Awareness_Programs WHERE region = patient_region AND date = CURDATE()) THEN
            INSERT INTO Awareness_Programs (program_name, date, region, organizer, attendees_count)
            VALUES (CONCAT('Awareness Program for Mutation ID ', NEW.mutation_id, ' in ', patient_region),
                    CURDATE(), patient_region, 'Health Dept/NGO', 0);
        END IF;
    END IF;
END$$

-- 6. trg_screening_update
CREATE TRIGGER trg_screening_update
AFTER UPDATE ON Screening
FOR EACH ROW
BEGIN
    DECLARE fam_id INT;
    IF OLD.result != NEW.result THEN
        SELECT family_id INTO fam_id FROM Patients WHERE patient_id = NEW.patient_id;
        IF NEW.result = 'Positive' THEN
            INSERT INTO Risk_Alerts (patient_id, alert_type, region, details, alert_date)
            VALUES (NEW.patient_id, CONCAT('High Risk: Mutation ID ', NEW.mutation_id),
                    (SELECT region FROM Patients WHERE patient_id = NEW.patient_id),
                    'Positive test detected — triggering new family risk alerts.',
                    CURDATE());
        ELSEIF NEW.result = 'Negative' THEN
            UPDATE Risk_Alerts
            SET status = 'Resolved'
            WHERE patient_id = NEW.patient_id
              AND alert_type LIKE CONCAT('%Mutation ID ', NEW.mutation_id, '%')
              AND status = 'Pending';
        END IF;
    END IF;
END$$

-- 7. trg_region_stats_update
CREATE TRIGGER trg_region_stats_update
AFTER UPDATE ON Awareness_Programs
FOR EACH ROW
BEGIN
    DECLARE total INT;
    SELECT SUM(attendees_count) INTO total FROM Awareness_Programs WHERE region = NEW.region;
    IF EXISTS (SELECT 1 FROM Region_Stats WHERE region = NEW.region) THEN
        UPDATE Region_Stats SET total_attendees = total WHERE region = NEW.region;
    ELSE
        INSERT INTO Region_Stats(region, total_attendees) VALUES (NEW.region, total);
    END IF;
    IF total < 10 THEN
        INSERT INTO Risk_Alerts (patient_id, alert_type, region, details, alert_date)
        SELECT patient_id, 'Low community participation alert',
               NEW.region, 'Less than 10 participants in awareness programs.', CURDATE()
        FROM Patients WHERE region = NEW.region;
    END IF;
END$$

-- 8. trg_mutation_hotspot_detection
CREATE TRIGGER trg_mutation_hotspot_detection
AFTER INSERT ON Screening
FOR EACH ROW
BEGIN
    DECLARE region_name VARCHAR(50);
    DECLARE positive_count INT;
    SELECT region INTO region_name FROM Patients WHERE patient_id = NEW.patient_id;
    SELECT COUNT(*) INTO positive_count
    FROM Screening s
    JOIN Patients p ON s.patient_id = p.patient_id
    WHERE s.mutation_id = NEW.mutation_id
      AND s.result = 'Positive'
      AND s.test_date >= DATE_SUB(NEW.test_date, INTERVAL 30 DAY)
      AND p.region = region_name;
    IF positive_count >= 5 THEN
        INSERT INTO Risk_Alerts (alert_type, region, details, alert_date)
        VALUES ('Mutation Hotspot',
                region_name,
                CONCAT('Mutation ID ', NEW.mutation_id,
                       ' recorded ', positive_count,
                       ' positives in ', region_name,
                       ' within 30 days. Potential hotspot detected.'),
                CURDATE());
    END IF;
END$$

-- 9. trg_genetic_correlation_detection
CREATE TRIGGER trg_genetic_correlation_detection
AFTER INSERT ON Mutations
FOR EACH ROW
BEGIN
    DECLARE disease_count INT;
    SELECT COUNT(DISTINCT disease_id) INTO disease_count
    FROM Mutations WHERE gene_id = NEW.gene_id;
    IF disease_count > 1 THEN
        INSERT INTO Risk_Alerts (alert_type, details, alert_date)
        VALUES ('Genetic Correlation',
                CONCAT('Gene ID ', NEW.gene_id, ' is associated with ', 
                disease_count, ' diseases — multi-pathogenic correlation detected.'),
                CURDATE());
    END IF;
END$$

-- 10. trg_family_risk_alert
CREATE TRIGGER trg_family_risk_alert
AFTER INSERT ON Screening
FOR EACH ROW
BEGIN
    DECLARE fam_id INT;
    SELECT family_id INTO fam_id 
    FROM Patients 
    WHERE patient_id = NEW.patient_id;
    IF EXISTS (
        SELECT 1 
        FROM Screening s
        JOIN Patients p ON s.patient_id = p.patient_id
        WHERE p.family_id = fam_id
          AND p.patient_id <> NEW.patient_id
          AND s.result = 'Positive'
    ) THEN
        INSERT INTO Risk_Alerts (patient_id, alert_type, region, details, alert_date)
        VALUES (
            NEW.patient_id,
            'Family Genetic Correlation Alert',
            (SELECT region FROM Patients WHERE patient_id = NEW.patient_id),
            'A family member tested positive — genetic linkage suspected. Recommend correlation analysis.',
            CURDATE()
        );
    END IF;
END$$
DELIMITER ;

INSERT INTO Family (family_id, region) VALUES
(1, 'Delhi'), (2, 'Maharashtra'), (3, 'Telangana'), (4, 'Karnataka'), (5, 'Delhi');

INSERT INTO Patients (name, age, gender, region, family_id) VALUES
('Amit Sharma', 25, 'Male', 'Delhi', 1),
('Priya Verma', 30, 'Female', 'Maharashtra', 2),
('Rohit Reddy', 28, 'Male', 'Telangana', 3),
('Sanya Gupta', 35, 'Female', 'Karnataka', 4),
('Vikram Singh', 22, 'Male', 'Delhi', 1),
('Anjali Joshi', 40, 'Female', 'Maharashtra', 2),
('Karan Mehta', 27, 'Male', 'Telangana', 3),
('Neha Patil', 33, 'Female', 'Karnataka', 4),
('Rina Nair', 29, 'Female', 'Delhi', 1),
('Meera Kapoor', 24, 'Female', 'Delhi', 1);

INSERT INTO Genes (gene_name, `function`, chromosome) VALUES
('CFTR', 'Ion transport', '7'),
('HTT', 'Neurodegeneration', '4'),
('DMD', 'Muscle function', 'X'),
('FMR1', 'Neuronal development', 'X'),
('HBB', 'Hemoglobin formation', '11');

INSERT INTO Diseases (disease_name, severity, common_regions) VALUES
('Cystic Fibrosis', 'Severe', 'Telangana'),
('Huntington’s Disease', 'Severe', 'Telangana, Karnataka'),
('Duchenne Muscular Dystrophy', 'Severe', 'Delhi, Maharashtra'),
('Fragile X Syndrome', 'Moderate', 'Karnataka, Delhi'),
('Sickle Cell Anemia', 'Critical', 'Maharashtra, Telangana');

INSERT INTO Mutations (gene_id, disease_id, mutation_description) VALUES
(1, 1, 'CFTR deltaF508 deletion'),
(2, 2, 'HTT CAG repeat expansion'),
(3, 3, 'DMD nonsense mutation'),
(4, 4, 'FMR1 CGG repeat expansion'),
(5, 5, 'HBB point mutation');

INSERT INTO Awareness_Programs (program_name, date, region, organizer, attendees_count) VALUES
('Cystic Fibrosis Seminar', '2025-04-15', 'Telangana', 'MedInstitute', 30),
('Huntington’s Disease Webinar', '2025-07-10', 'Telangana', 'GeneLabs', 25),
('Duchenne Muscular Dystrophy Awareness', '2025-05-01', 'Delhi', 'HealthOrg', 50),
('Fragile X Syndrome Workshop', '2025-06-20', 'Karnataka', 'NeuroCare', 40),
('Sickle Cell Anemia Campaign', '2025-03-05', 'Maharashtra', 'HealthOrg', 60);

INSERT INTO Screening (patient_id, mutation_id, test_date, result) VALUES
(1, 1, '2025-03-15', 'Positive'),
(2, 2, '2025-03-20', 'Negative'),
(3, 3, '2025-03-25', 'Positive'),
(4, 4, '2025-04-01', 'Negative'),
(5, 5, '2025-04-05', 'Positive');

-- Helper: confirm current max patient_id (for your awareness)
SELECT MAX(patient_id) AS current_max_patient_id FROM Patients;

-- 1. screening_date_check: Expect ERROR (date in future) 
INSERT INTO Screening (patient_id, mutation_id, test_date, result)
VALUES (1, 1, DATE_ADD(CURDATE(), INTERVAL 5 DAY), 'Positive');

-- 2. screening_date_update: updating an existing screening to a future date 
UPDATE Screening
SET test_date = DATE_ADD(CURDATE(), INTERVAL 2 DAY)
WHERE screening_id = 1;

-- 3. trg_family_risk (family propagation)
INSERT INTO Screening (patient_id, mutation_id, test_date, result)
VALUES (9, 1, CURDATE(), 'Positive');
SELECT * FROM Screening;
-- Check family propagation alerts
SELECT * FROM Risk_Alerts WHERE alert_type LIKE 'High Risk%';

-- 4. trg_region_alert: Insert a new patient from Telangana 
INSERT INTO Patients (name, age, gender, region, family_id)
VALUES ('Ujwala', 31, 'Female', 'Telangana', 3);
SELECT * FROM Risk_Alerts WHERE alert_type LIKE 'Region Risk%';

-- 5. trg_positive_test_outreach: Positive test in a region 
INSERT INTO Screening (patient_id, mutation_id, test_date, result)
VALUES (10, 3, CURDATE(), 'Positive');
SELECT * FROM Awareness_Programs ORDER BY program_id DESC LIMIT 1;

-- 6. trg_screening_update:
UPDATE Screening SET result = 'Positive' WHERE screening_id = 2;
SELECT * FROM Screening;
SELECT * FROM Risk_Alerts WHERE patient_id = 2;
UPDATE Screening SET result = 'Negative' WHERE screening_id = 2;
SELECT * FROM Screening;
SELECT * FROM Risk_Alerts WHERE patient_id = 2;

-- 7. trg_region_stats_update: Update awareness program attendance to low number (<10) to trigger low participation alerts
SELECT * FROM Awareness_Programs;
UPDATE Awareness_Programs
SET attendees_count = 1
WHERE region = 'Telangana';
SELECT * FROM Region_Stats;
SELECT * FROM Risk_Alerts WHERE alert_type LIKE 'Low community%';

-- 8. trg_mutation_hotspot_detection: 
INSERT INTO Screening (patient_id, mutation_id, test_date, result)
VALUES
(1, 1, CURDATE(), 'Positive'),
(5, 1, CURDATE(), 'Positive'),
(9, 1, CURDATE(), 'Positive'),
(10, 1, CURDATE(), 'Positive');
SELECT * FROM Risk_Alerts WHERE alert_type = 'Mutation Hotspot';

-- 9. trg_genetic_correlation_detection: link existing gene to a new disease to create correlation alert
INSERT INTO Mutations (gene_id, disease_id, mutation_description)
VALUES (1, 3, 'CFTR associated with new disease');
SELECT * FROM Risk_Alerts WHERE alert_type = 'Genetic Correlation';
-- Insert two new family members (same family_id = 1 used here to reuse existing Family)
-- 10. trg_family_risk_alert: demo family correlation without hardcoding IDs -- insert screening for Rohan (positive baseline) using SELECT to find assigned id -- insert screening for Meera (should trigger family correlation alert)

INSERT INTO Patients (name, age, gender, region, family_id)
VALUES
('Rohan Kumar', 35, 'Male', 'Karnataka', 1),
('Meera Kumar', 32, 'Female', 'Karnataka', 1);
INSERT INTO Screening (patient_id, mutation_id, test_date, result)
VALUES (
    (SELECT patient_id FROM Patients WHERE name = 'Rohan Kumar' LIMIT 1),
    1, CURDATE(), 'Positive'
);
INSERT INTO Screening (patient_id, mutation_id, test_date, result)
VALUES (
    (SELECT patient_id FROM Patients WHERE name = 'Meera Kumar' LIMIT 1),
    1, CURDATE(), 'Negative'
);

-- Final checks: alerts, awareness programs and region stats
SELECT * FROM Risk_Alerts ORDER BY alert_date DESC;
SELECT * FROM Awareness_Programs;
SELECT * FROM Region_Stats;

-- View alerts created today
SELECT * FROM Risk_Alerts
WHERE alert_date = CURDATE()
ORDER BY alert_id DESC;