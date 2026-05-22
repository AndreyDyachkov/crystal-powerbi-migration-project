CREATE OR ALTER PROCEDURE dbo.usp_GetSchoolAnalytics
(
    @ExamYear INT,
    @SchoolName NVARCHAR(100) = NULL
)
AS
BEGIN

    SET NOCOUNT ON;

    ---------------------------------------------------
    -- STEP 1: Build temp table with attendance metrics
    ---------------------------------------------------

    IF OBJECT_ID('tempdb..#AttendanceMetrics') IS NOT NULL
        DROP TABLE #AttendanceMetrics;

    SELECT
        student_id,

        COUNT(*) AS TotalDays,

        SUM(CASE
                WHEN present_flag = 1
                THEN 1
                ELSE 0
            END) AS DaysPresent,

        100.0 *
        SUM(CASE
                WHEN present_flag = 1
                THEN 1
                ELSE 0
            END)
        / COUNT(*) AS AttendancePct

    INTO #AttendanceMetrics

    FROM FactAttendance

    GROUP BY student_id;

    ---------------------------------------------------
    -- STEP 2: Nested CTE #1
    -- Student academic performance
    ---------------------------------------------------

    WITH StudentPerformance AS
    (
        SELECT
            s.student_id,
            s.student_name,
            s.school_name,
            s.year_level,

            SUM(r.Credits) AS TotalCredits,

            AVG(r.Score) AS AvgScore

        FROM FactStudentResults r

        JOIN DimStudent s
            ON r.student_id = s.student_id

        WHERE r.exam_year = @ExamYear

        GROUP BY
            s.student_id,
            s.student_name,
            s.school_name,
            s.year_level
    ),

    ---------------------------------------------------
    -- STEP 3: Nested CTE #2
    -- Combine performance + attendance + business logic
    ---------------------------------------------------

    StudentFinal AS
    (
        SELECT
            sp.student_id,
            sp.student_name,
            sp.school_name,
            sp.year_level,
            sp.TotalCredits,
            sp.AvgScore,

            att.AttendancePct,

            ------------------------------------------------
            -- Pass / Fail logic
            ------------------------------------------------

            CASE
                WHEN sp.TotalCredits >= 40
                     AND sp.AvgScore >= 75
                     AND att.AttendancePct >= 90
                THEN 'Excellence'

                WHEN sp.AvgScore >= 50
                THEN 'Pass'

                ELSE 'Fail'
            END AS ResultStatus,

            ------------------------------------------------
            -- Ranking inside school
            ------------------------------------------------

            RANK() OVER
            (
                PARTITION BY sp.school_name
                ORDER BY sp.AvgScore DESC
            ) AS SchoolRank

        FROM StudentPerformance sp

        LEFT JOIN #AttendanceMetrics att
            ON sp.student_id = att.student_id
    )

    ---------------------------------------------------
    -- STEP 4: Final output
    ---------------------------------------------------

    SELECT
        student_id,
        student_name,
        school_name,
        year_level,
        TotalCredits,
        AvgScore,
        AttendancePct,
        ResultStatus,
        SchoolRank

    FROM StudentFinal

    WHERE
        (
            @SchoolName IS NULL
            OR school_name = @SchoolName
        )

    ORDER BY
        school_name,
        SchoolRank;

END;