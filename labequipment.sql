

CREATE DATABASE IF NOT EXISTS LabEquipmentDB;
USE LabEquipmentDB;

-- 1. STUDENTS TABLE
CREATE TABLE IF NOT EXISTS Students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    student_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    department VARCHAR(50),
    password_hash VARCHAR(255) NOT NULL
);

-- 2. COMPONENTS TABLE
CREATE TABLE IF NOT EXISTS Components (
    component_id INT PRIMARY KEY AUTO_INCREMENT,
    component_name VARCHAR(100) NOT NULL,
    quantity INT NOT NULL DEFAULT 0,
    condition_status VARCHAR(30) NOT NULL DEFAULT 'Working',
    CHECK (quantity >= 0)
);

-- 3. COMPONENT REQUESTS TABLE
CREATE TABLE IF NOT EXISTS ComponentRequests (
    request_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    component_id INT NOT NULL,
    request_quantity INT NOT NULL DEFAULT 1,
    request_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    request_status VARCHAR(20) NOT NULL DEFAULT 'Pending',
    FOREIGN KEY (student_id)
        REFERENCES Students(student_id),
    FOREIGN KEY (component_id)
        REFERENCES Components(component_id),
    CHECK (request_quantity > 0)
);

-- 4. COMPONENT RETURNS TABLE
CREATE TABLE IF NOT EXISTS ComponentReturns (
    return_id INT PRIMARY KEY AUTO_INCREMENT,
    request_id INT NOT NULL,
    return_quantity INT NOT NULL,
    return_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    return_status VARCHAR(20) NOT NULL DEFAULT 'Pending',
    FOREIGN KEY (request_id)
        REFERENCES ComponentRequests(request_id),
    CHECK (return_quantity > 0)
);

-- 5. SAMPLE COMPONENTS
INSERT INTO Components
    (component_name, quantity, condition_status)
SELECT 'Computer', 20, 'Working'
WHERE NOT EXISTS (
    SELECT 1 FROM Components
    WHERE component_name = 'Computer'
);

INSERT INTO Components
    (component_name, quantity, condition_status)
SELECT 'Keyboard', 25, 'Working'
WHERE NOT EXISTS (
    SELECT 1 FROM Components
    WHERE component_name = 'Keyboard'
);

INSERT INTO Components
    (component_name, quantity, condition_status)
SELECT 'Monitor', 2, 'Damaged'
WHERE NOT EXISTS (
    SELECT 1 FROM Components
    WHERE component_name = 'Monitor'
);

-- 6. CREATE ADMIN AND STUDENT DATABASE ACCOUNTS
CREATE USER IF NOT EXISTS 'lab_admin'@'localhost'
IDENTIFIED BY 'Admin@123';

CREATE USER IF NOT EXISTS 'lab_student'@'localhost'
IDENTIFIED BY 'Student@123';

-- 7. ADMIN PERMISSIONS
GRANT SELECT, INSERT, UPDATE, DELETE
ON LabEquipmentDB.Students
TO 'lab_admin'@'localhost';

GRANT SELECT, INSERT, UPDATE, DELETE
ON LabEquipmentDB.Components
TO 'lab_admin'@'localhost';

GRANT SELECT, INSERT, UPDATE, DELETE
ON LabEquipmentDB.ComponentRequests
TO 'lab_admin'@'localhost';

GRANT SELECT, INSERT, UPDATE, DELETE
ON LabEquipmentDB.ComponentReturns
TO 'lab_admin'@'localhost';

-- 8. STUDENT PERMISSIONS
GRANT SELECT
ON LabEquipmentDB.Components
TO 'lab_student'@'localhost';

GRANT SELECT, INSERT
ON LabEquipmentDB.ComponentRequests
TO 'lab_student'@'localhost';

GRANT SELECT, INSERT
ON LabEquipmentDB.ComponentReturns
TO 'lab_student'@'localhost';

-- 9. DEMONSTRATE REVOKE AND GRANT
REVOKE INSERT
ON LabEquipmentDB.ComponentRequests
FROM 'lab_student'@'localhost';

-- Restore request permission
GRANT INSERT
ON LabEquipmentDB.ComponentRequests
TO 'lab_student'@'localhost';

-- 10. ADMIN FUNCTIONS

-- View students
SELECT * FROM Students;

-- Add a student (demo password hash placeholder)
-- Replace the placeholder with a real secure password hash
INSERT INTO Students
    (student_name, email, department, password_hash)
VALUES
    ('Vedant Dhule', 'vedant@example.com',
     'Computer Science', 'REPLACE_WITH_SECURE_HASH');

-- View components
SELECT * FROM Components;

-- Add a component
INSERT INTO Components
    (component_name, quantity, condition_status)
VALUES
    ('Mouse', 15, 'Working');

-- Update component stock
UPDATE Components
SET quantity = 30
WHERE component_id = 2;

-- View all requests
SELECT * FROM ComponentRequests;

-- View all return requests
SELECT * FROM ComponentReturns;

-- 11. STUDENT FUNCTIONS

-- View available working components
SELECT component_id, component_name, quantity
FROM Components
WHERE quantity > 0
  AND condition_status = 'Working';

-- Submit a component request (example IDs)
-- Run only after the student and component exist
INSERT INTO ComponentRequests
    (student_id, component_id, request_quantity)
VALUES (1, 1, 1);

-- View a student's requests (example student ID)
SELECT *
FROM ComponentRequests
WHERE student_id = 1;

-- Submit a return request (example request ID)
INSERT INTO ComponentReturns
    (request_id, return_quantity)
VALUES (1, 1);

-- 12. ADMIN APPROVAL DEMONSTRATION
-- Check the request and stock before approving
SELECT r.request_id, r.request_quantity,
       r.request_status, c.component_name, c.quantity
FROM ComponentRequests r
JOIN Components c
    ON c.component_id = r.component_id
WHERE r.request_id = 1;

-- 13. VERIFY USER PERMISSIONS
SHOW GRANTS FOR 'lab_admin'@'localhost';
SHOW GRANTS FOR 'lab_student'@'localhost';

-- 14. DISPLAY ALL TABLES
SHOW TABLES;

SELECT * FROM Equipment
WHERE condition_status = 'Damaged';

UPDATE Equipment
SET condition_status = 'Working'
WHERE equipment_id = 4;
