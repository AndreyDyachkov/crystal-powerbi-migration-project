CREATE OR ALTER PROCEDURE dbo.usp_GetSchoolPerformance
	@ExamYear INT
AS
BEGIN
	WITH StudentTotals AS (
		SELECT
			s.student_id, s.student_name, s.school_name, SUM(r.credits) AS TotalCredits, AVG(r.score) AS AvgScore
		FROM FactStudentResults r
		JOIN DimStudent s ON r.student_id = s.student_id
		WHERE r.exam_year = @ExamYear
		GROUP BY s.student_id, s.student_name, s.school_name
	)
	SELECT school_name, AVG(TotalCredits) AS AvgCredits, AVG(AvgScore) AS AvgStudentScore
	FROM StudentTotals
	GROUP BY school_name
END;