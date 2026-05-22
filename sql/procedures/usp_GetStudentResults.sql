CREATE OR ALTER PROCEDURE dbo.usp_GetStudentResults
    @ExamYear INT
AS
BEGIN
    SELECT s.student_name, s.school_name, sub.subject_name, r.exam_year, r.credits, r.score
	FROM FactStudentResults r
	JOIN DimStudent s ON r.student_id = s.student_id
	JOIN DimSubject sub ON r.student_id = sub.subject_id 
    WHERE r.exam_year = @ExamYear
END;