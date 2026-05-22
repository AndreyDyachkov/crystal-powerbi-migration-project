CREATE TABLE FactAttendance
(
    attendance_id INT IDENTITY PRIMARY KEY,
    student_id INT,
    attendance_date DATE,
    present_flag BIT
);