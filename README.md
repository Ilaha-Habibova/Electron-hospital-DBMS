# Electron Hospital Management System
This repository contains a series of tasks for a Database Management Systems (DBMS) course, focusing on the design and implementation of an Electron Hospital Management System. Throughout assignments, I used <a href="https://www.oracle.com/database/sqldeveloper/technologies/sql-data-modeler/download/">Oracle SQL Developer Data Modeler </a> and <a href="https://www.oracle.com/database/sqldeveloper/technologies/download/">Oracle SQL Developer</a>.

## 📌 Logical Model Domain Overview
The system models key hospital operations:
- **Patients**: Includes PatientID (PK), Name, BirthDate, Gender, and Contact
- **MedicalRecords**: Contains RecordId(PK), PatientID (FK), Diagnosis, Date and optional 'Prescription'
- **Doctors**: Contains DoctorID(PK), DoctorName, Phone, WorkingHours
- **Services**: Contains ServiceCode(PK), Specialty, Price(Euro), DoctorID(FK)
- **Appointments**: Contains AppointmentID(PK), Datetime, PatientID(FK), DoctorID(FK), optional 'VisitReason'
- **Billing**: Contains BillID (PK), Amount(Euro), PaymentStatus, Date, PatientID(FK)
  
## 🔃 Relationships

- `Patients ↔ MedicalRecords` : One-to-One (Each patient has a unique medical record, and each medical record has a patient)
- `Doctors ↔ Services` : Many-to-Many  (Doctors can offer multiple services, and each service can be offered by multiple doctors.)
- `Doctors ↔ Appointments` : One-to-Many  (1 doctor can have multiple appointments.)
- `Patients ↔ Appointments` : One-to-Many  (1 patient can make as much as appointments (s)he wants.)
- `Patients ↔ Bills` : One-to-Many (1 patient can have multiple bills, for example each for different services.)

## 📁 Contents
- Detailed description, models, and implementation can be found in the <a href="https://github.com/Ilaha-Habibova/Electron-hospital-DBMS/blob/main/Electron%20Hospital%20Management%20System.docx">prepared documentation</a>. <br>
- Logical and relational models are available in the <a href="https://github.com/Ilaha-Habibova/Electron-hospital-DBMS/blob/main/Hospital-Logical_Model.dmd">DMD file</a>. <br>
- Complete PL/SQL implementation is included in the <a href="https://github.com/Ilaha-Habibova/Electron-hospital-DBMS/blob/main/Electron-Hospital-Management-System.sql">SQL file</a>.

## Author: [@Ilaha_Habibova](https://github.com/Ilaha-Habibova)

Unauthorized use, reproduction, modification, or distribution of this project, in whole or in part is strictly prohibited. <br>
Proper reference must be given if any part of this project is used:<br> 
Electron Hospital Management System using PL/SQL: Ilaha Habibova - https://github.com/Ilaha-Habibova/Electron-hospital-DBMS
