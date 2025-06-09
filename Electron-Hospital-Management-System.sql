 -- Patients
CREATE TABLE Patients (
    PatientID   CHAR(7) NOT NULL,
    PatientName VARCHAR2(50) NOT NULL,
    BirthDate   DATE NOT NULL,
    Gender      VARCHAR2(10) NOT NULL,
    Contact     VARCHAR2(15) NOT NULL
);

ALTER TABLE Patients 
    ADD CONSTRAINT Patients_PK PRIMARY KEY (PatientID);

-- Doctors
CREATE TABLE Doctors (
    DoctorID     CHAR(7) NOT NULL,
    DoctorName   VARCHAR2(50) NOT NULL,
    Phone        VARCHAR2(15) NOT NULL,
    WorkingHours VARCHAR2(150) NOT NULL
);

ALTER TABLE Doctors 
    ADD CONSTRAINT Doctors_PK PRIMARY KEY (DoctorID);

-- Services
CREATE TABLE Services (
    ServiceCode CHAR(6) NOT NULL,
    Specialty   VARCHAR2(150) NOT NULL,
    Price_Euro  NUMBER(10,2) NOT NULL,
    DoctorID Char(7) Not Null
);

ALTER TABLE Services 
    ADD CONSTRAINT Services_PK PRIMARY KEY (ServiceCode);

ALTER TABLE Services
    ADD CONSTRAINT Services_Doctors_FK FOREIGN KEY (DoctorID)
    REFERENCES Doctors (DoctorID);
    
-- Doctor_Service
CREATE TABLE Doctor_Service (
    Doctors_DoctorID     CHAR(7) NOT NULL,
    Services_ServiceCode CHAR(6) NOT NULL
);

ALTER TABLE Doctor_Service
    ADD CONSTRAINT Doctor_Service_PK PRIMARY KEY (Doctors_DoctorID, Services_ServiceCode);

ALTER TABLE Doctor_Service
    ADD CONSTRAINT Doctor_Service_Doctors_FK FOREIGN KEY (Doctors_DoctorID)
    REFERENCES Doctors (DoctorID);

ALTER TABLE Doctor_Service
    ADD CONSTRAINT Doctor_Service_Services_FK FOREIGN KEY (Services_ServiceCode)
    REFERENCES Services (ServiceCode);

-- Appointments
CREATE TABLE Appointments (
    AppointmentID CHAR(7) NOT NULL,
    Datetime      DATE NOT NULL,
    VisitReason   VARCHAR2(150), -- Optional
    PatientID     CHAR(7) NOT NULL,
    DoctorID      CHAR(7) NOT NULL
);

ALTER TABLE Appointments 
    ADD CONSTRAINT Appointments_PK PRIMARY KEY (AppointmentID);

ALTER TABLE Appointments 
    ADD CONSTRAINT Appointments_Doctors_FK FOREIGN KEY (DoctorID)
    REFERENCES Doctors (DoctorID);

ALTER TABLE Appointments 
    ADD CONSTRAINT Appointments_Patients_FK FOREIGN KEY (PatientID)
    REFERENCES Patients (PatientID);

-- Bills
CREATE TABLE Bills (
    BillID         CHAR(6) NOT NULL,
    Amount_Euro    NUMBER(10,2) NOT NULL,
    PaymentStatus  VARCHAR2(15) NOT NULL,
    "Date"         DATE NOT NULL,
    PatientID      CHAR(7) NOT NULL
);

ALTER TABLE Bills 
    ADD CONSTRAINT Bills_PK PRIMARY KEY (BillID);

ALTER TABLE Bills 
    ADD CONSTRAINT Bills_Patients_FK FOREIGN KEY (PatientID)
    REFERENCES Patients (PatientID);

-- MedicalRecords
CREATE TABLE MedicalRecords (
    RecordID     CHAR(6) NOT NULL,
    PatientID    CHAR(7) NOT NULL,
    Diagnosis    VARCHAR2(200) NOT NULL,
    "Date"       DATE NOT NULL,
    Prescription VARCHAR2(200) -- Optional
);

ALTER TABLE MedicalRecords 
    ADD CONSTRAINT MedicalRecords_PK PRIMARY KEY (RecordID);

ALTER TABLE MedicalRecords 
    ADD CONSTRAINT MedicalRecords_Patients_FK FOREIGN KEY (PatientID)
    REFERENCES Patients (PatientID);

-- Now, we’ll add 2 more table throughout SQL Developer:
-- Insurance
CREATE TABLE Insurance (
    InsuranceID CHAR(6) NOT NULL,
    ProviderName VARCHAR2(100) NOT NULL,
    PolicyNumber VARCHAR2(50) NOT NULL UNIQUE,
    Coverage NUMBER(10,2) CHECK (Coverage >= 0) NOT NULL,
    ExpiryDate DATE NOT NULL,
    PatientID CHAR(7) NOT NULL,
    CONSTRAINT Insurance_PK PRIMARY KEY (InsuranceID),
    CONSTRAINT Insurance_Patients_FK FOREIGN KEY (PatientID) REFERENCES Patients (PatientID)
);

CREATE OR REPLACE TRIGGER Check_ExpiryDate
BEFORE INSERT OR UPDATE ON Insurance
FOR EACH ROW
BEGIN
    IF :NEW.ExpiryDate <= SYSDATE THEN
        RAISE_APPLICATION_ERROR(-20001, 'Expiry date must be in the future.');
    END IF;
END;

-- Prescriptions
CREATE TABLE Prescriptions (
    PrescriptionID CHAR(6) NOT NULL,
    RecordID CHAR(6) NOT NULL,
    DoctorID CHAR(7) NOT NULL,
    PatientID CHAR(7) NOT NULL,
    Medication VARCHAR2(200) NOT NULL,
    Dosage VARCHAR2(200) NOT NULL,
    IssueDate DATE NOT NULL,
    CONSTRAINT Prescriptions_PK PRIMARY KEY (PrescriptionID),
    CONSTRAINT Prescriptions_Records_FK FOREIGN KEY (RecordID) REFERENCES MedicalRecords (RecordID),
    CONSTRAINT Prescriptions_Doctors_FK FOREIGN KEY (DoctorID) REFERENCES Doctors (DoctorID),
    CONSTRAINT Prescriptions_Patients_FK FOREIGN KEY (PatientID) REFERENCES Patients (PatientID)
);

-- Patients (150 records-randomly)
BEGIN
    FOR i IN 1..150 LOOP
        INSERT INTO Patients (
            PatientID, 
            PatientName, 
            BirthDate, 
            Gender, 
            Contact
        ) VALUES (
            'P' || LPAD(i, 6, '0'), -- P000001 to P000150
            'Patient_' || i,
            TO_DATE('1930-01-01', 'YYYY-MM-DD') + TRUNC(DBMS_RANDOM.VALUE(0, 365 * 95)), -- BirthDate between 1930–2025
            CASE 
                WHEN DBMS_RANDOM.VALUE < 0.5 THEN 'Male' 
                ELSE 'Female' 
            END,
            '555-' || 
            LPAD(TO_CHAR(TRUNC(DBMS_RANDOM.VALUE(100, 999))), 3, '0') || '-' || 
            LPAD(TO_CHAR(TRUNC(DBMS_RANDOM.VALUE(1000, 9999))), 4, '0') -- Phone format
        );
    END LOOP;
    COMMIT;
END;
/

-- Doctors
INSERT INTO DOCTORS (DOCTORID, DOCTORNAME, PHONE, WORKINGHOURS) 
VALUES ('D000001', 'Dr. Alice Brown', '555-1234', '09:00-17:00');

INSERT INTO DOCTORS (DOCTORID, DOCTORNAME, PHONE, WORKINGHOURS) 
VALUES ('D000002', 'Dr. Bob White', '555-5678', '10:00-18:00');

INSERT INTO DOCTORS (DOCTORID, DOCTORNAME, PHONE, WORKINGHOURS) 
VALUES ('D000003', 'Dr. Charlie Green', '545-3671', '08:00-14:00');

-- MedicalRecords:
INSERT INTO MEDICALRECORDS (RECORDID, PATIENTID, DIAGNOSIS,"Date", PRESCRIPTION)
VALUES ('MR0001', 'P000001', 'Flu', TO_DATE('01-JAN-24', 'DD-MON-YY'), 'Paracetamol');

INSERT INTO MEDICALRECORDS (RECORDID, PATIENTID, DIAGNOSIS, "DATE", PRESCRIPTION)
VALUES ('MR0002', 'P000002', 'Cold', TO_DATE('05-FEB-24', 'DD-MON-YY'), NULL);

INSERT INTO MEDICALRECORDS (RECORDID, PATIENTID, DIAGNOSIS,"Date", PRESCRIPTION)
VALUES ('MR0003', 'P000003', 'Fever', TO_DATE('10-MAR-24', 'DD-MON-YY'), 'Ibuprofen');

INSERT INTO MEDICALRECORDS (RECORDID, PATIENTID, DIAGNOSIS,"Date", PRESCRIPTION)
VALUES ('MR0004', 'P000004', 'Allergy', TO_DATE('12-APR-24', 'DD-MON-YY'), 'Antihistamine');

INSERT INTO MEDICALRECORDS (RECORDID, PATIENTID, DIAGNOSIS,"Date", PRESCRIPTION)
VALUES ('MR0005', 'P000005', 'Headache', TO_DATE('18-MAY-24', 'DD-MON-YY'), 'Aspirin');

INSERT INTO MEDICALRECORDS (RECORDID, PATIENTID, DIAGNOSIS,"Date", PRESCRIPTION)
VALUES ('MR0006', 'P000006', 'Fever', TO_DATE('12-JUN-24', 'DD-MON-YY'), 'Ibuprofen');

-- Bills
INSERT INTO BILLS (BILLID, AMOUNT_EURO, PAYMENTSTATUS,"Date", PATIENTID) 
VALUES ('B00001', 150.75, 'Unpaid', TO_DATE('05-JAN-24', 'DD-MON-YY'), 'P000001');

INSERT INTO BILLS (BILLID, AMOUNT_EURO, PAYMENTSTATUS, "Date", PATIENTID) 
VALUES ('B00002', 145.80, 'Pending', TO_DATE('17-JUN-24', 'DD-MON-YY'), 'P000002');

INSERT INTO BILLS (BILLID, AMOUNT_EURO, PAYMENTSTATUS,"Date", PATIENTID) 
VALUES ('B00003', 75.50, 'Unpaid', TO_DATE('15-MAR-24', 'DD-MON-YY'), 'P000003');

INSERT INTO BILLS (BILLID, AMOUNT_EURO, PAYMENTSTATUS,"Date", PATIENTID) 
VALUES ('B00004', 300.00, 'Pending', TO_DATE('20-APR-24', 'DD-MON-YY'), 'P000004');

INSERT INTO BILLS (BILLID, AMOUNT_EURO, PAYMENTSTATUS,"Date", PATIENTID) 
VALUES ('B00005', 125.25, 'Paid', TO_DATE('25-MAY-24', 'DD-MON-YY'), 'P000005');

INSERT INTO BILLS (BILLID, AMOUNT_EURO, PAYMENTSTATUS,"Date", PATIENTID) 
VALUES ('B00006', 16.00, 'Paid', TO_DATE('27-FEB-24', 'DD-MON-YY'), 'P000004');

INSERT INTO BILLS (BILLID, AMOUNT_EURO, PAYMENTSTATUS, "Date", PATIENTID) 
VALUES ('B00007', 48.00, 'Pending', TO_DATE('11-NOV-24', 'DD-MON-YY'), 'P000001');

INSERT INTO BILLS (BILLID, AMOUNT_EURO, PAYMENTSTATUS,"Date", PATIENTID) 
VALUES ('B00008', 89.99, 'Unpaid', TO_DATE('10-JAN-24', 'DD-MON-YY'), 'P000003');

INSERT INTO BILLS (BILLID, AMOUNT_EURO, PAYMENTSTATUS, "Date", PATIENTID) 
VALUES ('B00009', 190.00, 'Unpaid', TO_DATE('15-APR-24', 'DD-MON-YY'), 'P000004');

INSERT INTO BILLS (BILLID, AMOUNT_EURO, PAYMENTSTATUS, "Date", PATIENTID) 
VALUES ('B00010', 165.75, 'Paid', TO_DATE('17-JUN-24', 'DD-MON-YY'), 'P000006');

INSERT INTO BILLS (BILLID, AMOUNT_EURO, PAYMENTSTATUS,"Date", PATIENTID) 
VALUES ('B00011', 167.75, 'Unpaid', TO_DATE('04-OCT-24', 'DD-MON-YY'), 'P000007');

INSERT INTO BILLS (BILLID, AMOUNT_EURO, PAYMENTSTATUS,"Date", PATIENTID) 
VALUES ('B00012', 25.00, 'Paid', TO_DATE('04-OCT-24', 'DD-MON-YY'), 'P000006');

INSERT INTO BILLS (BILLID, AMOUNT_EURO, PAYMENTSTATUS,"Date", PATIENTID) 
VALUES ('B00013', 132.00, 'Pending', TO_DATE('04-NOV-24', 'DD-MON-YY'), 'P000006');

INSERT INTO BILLS (BILLID, AMOUNT_EURO, PAYMENTSTATUS,"Date", PATIENTID) 
VALUES ('B00014', 42.00, 'Unpaid', TO_DATE('14-NOV-24', 'DD-MON-YY'), 'P000005');

INSERT INTO BILLS (BILLID, AMOUNT_EURO, PAYMENTSTATUS,"Date", PATIENTID) 
VALUES ('B00015', 42.00, 'Unpaid', TO_DATE('24-DEC-24', 'DD-MON-YY'), 'P000001');


-- Services
INSERT INTO SERVICES (SERVICECODE, SPECIALTY, PRICE_EURO, DOCTORID)
VALUES ('S00001', 'General Checkup', 50, 'D000001');

INSERT INTO SERVICES (SERVICECODE, SPECIALTY, PRICE_EURO, DOCTORID)
VALUES ('S00002', 'Cardiology', 200, 'D000002');

INSERT INTO SERVICES (SERVICECODE, SPECIALTY, PRICE_EURO, DOCTORID)
VALUES ('S00003', 'Dermatology', 75, 'D000003');

-- Doctor_Service:
INSERT INTO DOCTOR_SERVICE (DOCTORS_DOCTORID, SERVICES_SERVICECODE)
VALUES ('D000001', 'S00001');

INSERT INTO DOCTOR_SERVICE (DOCTORS_DOCTORID, SERVICES_SERVICECODE)
VALUES ('D000002', 'S00002');

INSERT INTO DOCTOR_SERVICE (DOCTORS_DOCTORID, SERVICES_SERVICECODE)
VALUES ('D000003', 'S00003');

-- Appointments
INSERT INTO APPOINTMENTS (APPOINTMENTID, DATETIME, VISITREASON, PATIENTID, DOCTORID)
VALUES ('A000001', TO_DATE('05-JAN-24', 'DD-MON-YY'), 'Routine Checkup', 'P000001', 'D000001');

INSERT INTO APPOINTMENTS (APPOINTMENTID, DATETIME, VISITREASON, PATIENTID, DOCTORID)
VALUES ('A000002', TO_DATE('15-FEB-24', 'DD-MON-YY'), 'Heart Checkup', 'P000002', 'D000002');

INSERT INTO APPOINTMENTS (APPOINTMENTID, DATETIME, VISITREASON, PATIENTID, DOCTORID)
VALUES ('A000003', TO_DATE('20-MAR-24', 'DD-MON-YY'), 'Skin Allergy', 'P000003', 'D000003');

INSERT INTO APPOINTMENTS 
VALUES ('A000004', TO_DATE('18-JUN-24', 'DD-MON-YY'), 'Heart Surgery', 'P000004', 'D000002');

-- Insurance
INSERT INTO INSURANCE (INSURANCEID, PROVIDERNAME, POLICYNUMBER, COVERAGE, EXPIRYDATE, PATIENTID)
VALUES ('INS001', 'Blue Cross Blue Shield', 'BCBS123456', 5000, TO_DATE('31-DEC-25', 'DD-MON-YY'), 'P000001');

INSERT INTO INSURANCE (INSURANCEID, PROVIDERNAME, POLICYNUMBER, COVERAGE, EXPIRYDATE, PATIENTID)
VALUES ('INS002', 'UnitedHealthcare', 'UHC789012', 7500, TO_DATE('15-NOV-27', 'DD-MON-YY'), 'P000002');

INSERT INTO INSURANCE (INSURANCEID, PROVIDERNAME, POLICYNUMBER, COVERAGE, EXPIRYDATE, PATIENTID)
VALUES ('INS003', 'Aetna', 'AET345678', 10000, TO_DATE('20-OCT-26', 'DD-MON-YY'), 'P000003');

INSERT INTO INSURANCE (INSURANCEID, PROVIDERNAME, POLICYNUMBER, COVERAGE, EXPIRYDATE, PATIENTID)
VALUES ('INS004', 'Cigna', 'CIG901234', 3000, TO_DATE('30-SEP-27', 'DD-MON-YY'), 'P000004');


-- Prescriptions
INSERT INTO PRESCRIPTIONS (PRESCRIPTIONID, RECORDID, DOCTORID, PATIENTID, MEDICATION, DOSAGE, ISSUEDATE)
VALUES ('RX0006', 'MR0005', 'D000001', 'P000005', 'Ibuprofen', '200mg', TO_DATE('05-JUN-24', 'DD-MON-YY'));

INSERT INTO PRESCRIPTIONS (PRESCRIPTIONID, RECORDID, DOCTORID, PATIENTID, MEDICATION, DOSAGE, ISSUEDATE)
VALUES ('RX0001', 'MR0001', 'D000001', 'P000001', 'Paracetamol', '500mg', TO_DATE('01-JAN-24', 'DD-MON-YY'));

INSERT INTO PRESCRIPTIONS (PRESCRIPTIONID, RECORDID, DOCTORID, PATIENTID, MEDICATION, DOSAGE, ISSUEDATE)
VALUES ('RX0003', 'MR0003', 'D000003', 'P000003', 'Ibuprofen', '400mg', TO_DATE('10-MAR-24', 'DD-MON-YY'));

INSERT INTO PRESCRIPTIONS (PRESCRIPTIONID, RECORDID, DOCTORID, PATIENTID, MEDICATION, DOSAGE, ISSUEDATE)
VALUES ('RX0004', 'MR0004', 'D000003', 'P000004', 'Antihistamine', '20mg', TO_DATE('12-APR-24', 'DD-MON-YY'));

INSERT INTO PRESCRIPTIONS (PRESCRIPTIONID, RECORDID, DOCTORID, PATIENTID, MEDICATION, DOSAGE, ISSUEDATE)
VALUES ('RX0005', 'MR0005', 'D000001', 'P000005', 'Aspirin', '325mg', TO_DATE('18-MAY-24', 'DD-MON-YY'));

-- Indexing
Create Index idx_patientid ON Prescriptions(PatientID);

-- 1. Identifies all medications(without repetition) used to treat fever
SELECT DISTINCT PRESCRIPTION
FROM MEDICALRECORDS
WHERE DIAGNOSIS = 'Fever';

-- 2. Find doctors whose phone numbers end with '71' 
SELECT DoctorID, DoctorName, Phone
FROM Doctors
WHERE Phone LIKE '%71';

-- 3. Search elderly male patients born before 1965 and phone number with ‘555-6’:
SELECT *
FROM PATIENTS
WHERE
    GENDER = 'Male'
    AND TO_DATE(BIRTHDATE, 'DD-MON-YY') < TO_DATE('01-JAN-65', 'DD-MON-YY')
    AND CONTACT LIKE '555-6%';

-- 4. Find prescriptions in which the prescription date is earlier than 15 April 2024 AND medication dosage is higher than 300 mg or Antihistamine medication  
SELECT PRESCRIPTIONID, MEDICATION, DOSAGE, ISSUEDATE
FROM PRESCRIPTIONS
WHERE TO_DATE(ISSUEDATE, 'DD-MON-YY') < TO_DATE('15-APR-24', 'DD-MON-YY')
AND (TO_NUMBER(SUBSTR(DOSAGE, 1, INSTR(DOSAGE, 'mg')-1))) > 300 
OR MEDICATION LIKE '%Antihistamine%';

-- 5. Find how many bills you have in Paid and Pending categories and total amount of payment –income by these categories (since pending means partially paid)
SELECT 
    PAYMENTSTATUS, 
    SUM(AMOUNT_EURO) AS "Total Amount",
    COUNT(BILLID) AS "Number of Bills"
FROM BILLS
WHERE PAYMENTSTATUS IN ('Paid', 'Pending')
GROUP BY PAYMENTSTATUS
ORDER BY "Total Amount" DESC;

-- 6. Which doctors had more than 1 patient visit:
SELECT 
    DOCTORID, 
    COUNT(PATIENTID) AS "Patient Visits"
FROM PRESCRIPTIONS
GROUP BY DOCTORID
HAVING COUNT(PATIENTID) > 1;

-- 7. Displays PAYMENTSTATUS (Paid, Unpaid, Pending) having the sum of all bills for that status is between 250 and 500 euro:
SELECT 
    PAYMENTSTATUS, 
    SUM(AMOUNT_EURO) AS "Total Amount"
FROM BILLS
GROUP BY PAYMENTSTATUS
HAVING SUM(AMOUNT_EURO) BETWEEN 250 AND 500;

-- 8. This query identifies diagnoses that were treated with medications in 2 or more cases:
SELECT 
    DIAGNOSIS, 
    COUNT(RECORDID) AS "Case_Count"
FROM MEDICALRECORDS
WHERE PRESCRIPTION IS NOT NULL
GROUP BY DIAGNOSIS
HAVING COUNT(RECORDID) >= 2;

--9. Shows only patients that have matching bill records
SELECT P.PATIENTID, P.PATIENTNAME, b.BILLID, b.AMOUNT_EURO, b.PAYMENTSTATUS, b."Date" AS BILL_DATE
FROM PATIENTS p
JOIN BILLS b ON p.PATIENTID = b.PATIENTID
ORDER BY b."Date" DESC;

--10. Bills that may or may not have associated insurance entries:
SELECT b.BILLID, b.PATIENTID, b.AMOUNT_EURO, b.PAYMENTSTATUS, i.InsuranceID, i.PROVIDERNAME, i.COVERAGE
FROM BILLS b
LEFT JOIN INSURANCE i ON b.PATIENTID = i.PATIENTID;

--11. Creates a human-readable schedule by mentioning patient and doctor names clearly on appointments
SELECT a.APPOINTMENTID, P.PATIENTNAME, d.DOCTORNAME, a.VISITREASON, a.DATETIME
FROM APPOINTMENTS a
JOIN PATIENTS P ON a.PATIENTID = p.PATIENTID
JOIN DOCTORS d ON a.DOCTORID = d.DOCTORID;

--12. How many prescriptions each doctor issued to each patient
SELECT d.DOCTORNAME, p.PATIENTNAME, COUNT(*) AS "Prescriptions number"
FROM PRESCRIPTIONS pr
JOIN DOCTORS d ON pr.DOCTORID = d.DOCTORID
JOIN PATIENTS p ON pr.PATIENTID = p.PATIENTID
GROUP BY d.DOCTORNAME, p.PATIENTNAME;

--13. Retrieve all patients who have unpaid bills.
SELECT PATIENTID, PATIENTNAME, CONTACT
FROM PATIENTS
WHERE PATIENTID IN (
    SELECT PATIENTID
    FROM BILLS
    WHERE PAYMENTSTATUS = 'Unpaid'
);

-- 14. Doctors who have more appointments than the average number of appointments per doctor:
SELECT d.DOCTORNAME, COUNT(a.APPOINTMENTID) AS AppointmentCount
FROM DOCTORS d
JOIN APPOINTMENTS a ON d.DOCTORID = a.DOCTORID
GROUP BY d.DOCTORNAME
HAVING COUNT(a.APPOINTMENTID) > (
    SELECT AVG(AppointmentCount)
    FROM (
        SELECT COUNT(APPOINTMENTID) AS AppointmentCount
        FROM APPOINTMENTS
        GROUP BY DOCTORID
    )
);

-- 15. What percentage each insurance provider's coverage represents out of the toal covarage across all providers to compare market share:
SELECT 
    PROVIDERNAME, 
    COVERAGE,
    ROUND(COVERAGE * 100 / total_coverage.total, 2) as percentage
FROM INSURANCE,
    (SELECT SUM(COVERAGE) as total FROM INSURANCE) total_coverage
ORDER BY percentage DESC;

-- 16. Prescription patterns using ROLLUP to show:
-- Counts for each specific medication+dosage combination
-- Subtotals for each medication (all dosages combined)
-- Grand total of all prescriptions
SELECT 
    MEDICATION, 
    DOSAGE, 
    COUNT(*) as prescription_count
FROM PRESCRIPTIONS
GROUP BY ROLLUP(MEDICATION, DOSAGE)  
ORDER BY MEDICATION, DOSAGE;


-- 17. Appointment counts by doctor and distributed across months
SELECT * FROM (
    SELECT 
        DOCTORID, 
        PATIENTID, 
        TO_CHAR(DATETIME, 'YYYY-MM') as month
    FROM APPOINTMENTS
)
PIVOT (
    COUNT(PATIENTID)  
    FOR month IN (    
        '2024-01' as Jan,  
        '2024-02' as Feb,
        '2024-03' as Mar,
        '2024-04' as Apr,
        '2024-05' as May
    )
)
ORDER BY DOCTORID;

-- 18. Sets insurance coverage amounts for the next two years assuming a 10% annual increase
-- Ex: If Blue Cross has €5000 coverage in 2024, what will it be in 2026 with 10% yearly growth?
SELECT PROVIDERNAME, YEAR, COVERAGE
FROM (
    SELECT PROVIDERNAME, 2024 as YEAR, COVERAGE
    FROM INSURANCE
)
MODEL
PARTITION BY (PROVIDERNAME)
DIMENSION BY (YEAR)
MEASURES (COVERAGE)
RULES (
    COVERAGE[2025] = COVERAGE[2024] * 1.1,
    COVERAGE[2026] = COVERAGE[2025] * 1.1
)
ORDER BY PROVIDERNAME, YEAR;

--19. PL/SQL Function: The total amount of unpaid bills for a specific patient
CREATE OR REPLACE FUNCTION get_unpaid_bills_total(
  p_patient_id IN CHAR 
) RETURN NUMBER IS
  v_total_amount NUMBER(10,2); 
  
BEGIN
  SELECT SUM(Amount_Euro)
  INTO v_total_amount
  FROM Bills
  WHERE PatientID = p_patient_id
    AND PaymentStatus = 'Unpaid';
    
  RETURN NVL(v_total_amount, 0);

EXCEPTION
  WHEN OTHERS THEN
    RETURN -1;
END get_unpaid_bills_total;
/

-- Test the function
DECLARE
  v_result NUMBER;
BEGIN
  v_result := get_unpaid_bills_total('P000003');
  DBMS_OUTPUT.PUT_LINE('Total unpaid bills for P000003: ' || v_result || ' Euro');
  v_result := get_unpaid_bills_total('P000001');
  DBMS_OUTPUT.PUT_LINE('Total unpaid bills for P000001: ' || v_result || ' Euro');
  v_result := get_unpaid_bills_total('P000004');
  DBMS_OUTPUT.PUT_LINE('Total unpaid bills for P000004: ' || v_result || ' Euro');
END;
/

-- 20. Procedure  for patients with unpaid bills
CREATE OR REPLACE PROCEDURE list_patients_with_unpaid_bills IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Patients with unpaid bills:');
    DBMS_OUTPUT.PUT_LINE('---');

    FOR patient_rec IN (
        SELECT p.PatientID, p.PatientName,
        get_unpaid_bills_total(p.PatientID) AS UnpaidTotal -- (a) Uses the function from Task 19
        FROM Patients p
        WHERE get_unpaid_bills_total(p.PatientID) > 0
    )
    LOOP
        -- (b) Query retrieves multiple rows; results are printed
        DBMS_OUTPUT.PUT_LINE(
        'Patient ID: ' || patient_rec.PatientID ||
        ', Name: ' || patient_rec.PatientName ||
        ', Unpaid Total: ' || patient_rec.UnpaidTotal || ' Euro'
        );
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('---');
    DBMS_OUTPUT.PUT_LINE('End of report');

EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error in list_patients_with_unpaid_bills: ' || SQLERRM);
END list_patients_with_unpaid_bills;
/
BEGIN
    list_patients_with_unpaid_bills();
END;
/

-- 21. Trigger for bill status before and after an update
CREATE OR REPLACE TRIGGER update_payment_status  
BEFORE UPDATE OF AMOUNT_EURO ON BILLS  
FOR EACH ROW  

BEGIN  
  -- If the amount is being set to 0, automatically mark the bill as paid
  IF :NEW.AMOUNT_EURO = 0 AND :OLD.AMOUNT_EURO != 0 THEN 
    :NEW.PAYMENTSTATUS := 'Paid';  
  END IF;  
END;  
/

BEGIN
    -- Display status before update
    DBMS_OUTPUT.PUT_LINE('Before update:');
    FOR bill_rec IN (
        SELECT BILLID, AMOUNT_EURO, PAYMENTSTATUS
        FROM BILLS
        WHERE BILLID = 'B00003'
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Bill ' || bill_rec.BILLID || ': ' || bill_rec.AMOUNT_EURO || ' Euro, Status: ' || bill_rec.PAYMENTSTATUS);
    END LOOP;

    -- Update the amount to 0 — this should activate the trigger
    UPDATE BILLS SET AMOUNT_EURO = 0 WHERE BILLID = 'B00003';

    -- Display status after update
    DBMS_OUTPUT.PUT_LINE('After update:');
    FOR bill_rec IN (
        SELECT BILLID, AMOUNT_EURO, PAYMENTSTATUS
        FROM BILLS
        WHERE BILLID = 'B00003'
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Bill ' || bill_rec.BILLID || ': ' || bill_rec.AMOUNT_EURO || ' Euro, Status: ' || bill_rec.PAYMENTSTATUS);
    END LOOP;

    ROLLBACK;
END;
/
