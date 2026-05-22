CREATE TABLE FactStudentResults(
result_id INT IDENTITY PRIMARY KEY,
student_id INT, 
subject_id INT,
exam_year INT, 
credits INT,
score DECIMAL(5,2),
FOREIGN KEY (student_id) REFERENCES DimStudent(student_id),
FOREIGN KEY (subject_id) REFERENCES DimSubject(subject_id)
);