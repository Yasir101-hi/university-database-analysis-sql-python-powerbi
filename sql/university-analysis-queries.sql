-- Part B

--1.Enrollment snapshots

-- Total students by major, start_year.

SELECT 
    m.name AS major_name,
    s.start_year,
    COUNT(s.student_id) AS total_students
FROM students s
JOIN majors m ON s.major_id = m.major_id
GROUP BY m.name, s.start_year
ORDER BY m.name, s.start_year;

-- Headcount per course_offering vs. capacity; flag over/under utilization..

SELECT 
    co.offering_id,
    c.course_code,
    co.semester,
    co.year,
    co.capacity,
    COUNT(e.student_id) AS enrolled,
    CASE 
        WHEN COUNT(e.student_id) > co.capacity THEN 'Over-enrolled'
        WHEN COUNT(e.student_id) = 0 THEN 'Empty'
        WHEN COUNT(e.student_id) < 0.5 * co.capacity THEN 'Underutilized'
        ELSE 'OK'
    END AS utilization_status
FROM course_offerings co
JOIN courses c ON co.course_id = c.course_id
LEFT JOIN enrollments e ON co.offering_id = e.offering_id
GROUP BY co.offering_id, c.course_code, co.semester, co.year, co.capacity
ORDER BY co.year DESC, co.semester, c.course_code;

-- 2.Progression & prerequisites

-- For courses with prerequisites, list students who enrolled in the child course without 
    -- previously completing its prereq (grade A–D considered complete).

SELECT 
    s.student_id,
    child.course_code AS child_course,
    prereq.course_code AS prereq_course
  
FROM enrollments e
JOIN course_offerings co 
    ON e.offering_id = co.offering_id
JOIN courses child 
    ON co.course_id = child.course_id
JOIN prerequisites p 
    ON p.course_id = child.course_id
JOIN courses prereq 
    ON p.prereq_course_id = prereq.course_id
JOIN students s 
    ON e.student_id = s.student_id
WHERE NOT EXISTS (
    SELECT 1
    FROM enrollments e2
    JOIN course_offerings co2 
        ON e2.offering_id = co2.offering_id
    WHERE e2.student_id = s.student_id
      AND co2.course_id = prereq.course_id
      AND e2.grade IN ('A','B','C','D')   -- completed prerequisite
      AND (co2.year < co.year OR (co2.year = co.year AND co2.semester < co.semester)) 
)
ORDER BY s.student_id, child.course_code;

-- 3. Grades & GPA

-- Offering-level grade distribution and average GPA

SELECT 
    c.course_code,
    co.semester,
    co.year,
    COUNT(*) AS total_students,
    AVG(e.gpa_points) AS avg_gpa,
    SUM(CASE WHEN e.grade = 'A' THEN 1 ELSE 0 END) AS A_count,
    SUM(CASE WHEN e.grade = 'B' THEN 1 ELSE 0 END) AS B_count,
    SUM(CASE WHEN e.grade = 'C' THEN 1 ELSE 0 END) AS C_count,
    SUM(CASE WHEN e.grade = 'D' THEN 1 ELSE 0 END) AS D_count,
    SUM(CASE WHEN e.grade = 'F' THEN 1 ELSE 0 END) AS F_count
FROM enrollments e
JOIN course_offerings co ON e.offering_id = co.offering_id
JOIN courses c ON co.course_id = c.course_id
GROUP BY co.offering_id, c.course_code, co.semester, co.year
ORDER BY co.year DESC, co.semester, c.course_code;

-- Top 10 students by average GPA across their enrollments.

SELECT TOP 10
    s.student_id,
    m.name AS major,
    AVG(e.gpa_points) AS cumulative_gpa,
    COUNT(e.enrollment_id) AS courses_completed
FROM students s
JOIN majors m ON s.major_id = m.major_id
JOIN enrollments e ON s.student_id = e.student_id
WHERE e.grade IN ('A','B','C')
GROUP BY s.student_id, m.name
HAVING COUNT(e.enrollment_id) >= 4
ORDER BY cumulative_gpa DESC;

-- 4.Teaching evaluations

-- Join evaluations with evaluation_summary; validate aggregation (resp_rate recompute).

SELECT 
    es.offering_id,
    es.responses,
    es.n_enrolled, 
    es.avg_overall,
    es.avg_clarity,
    es.avg_organization,
    es.avg_engagement,
    es.avg_feedback, 
    es.avg_difficulty,
    COUNT(e.evaluation_id) as computed_responses,
    AVG(CAST(e.q_overall AS FLOAT)) as computed_avg_overall,
    AVG(CAST(e.q_clarity AS FLOAT)) as computed_avg_clarity,
    AVG(CAST(e.q_organization AS FLOAT)) as computed_avg_organization,
    AVG(CAST(e.q_engagement AS FLOAT)) as computed_avg_engagement,
    AVG(CAST(e.q_feedback AS FLOAT)) as computed_avg_feedback,
    AVG(CAST(e.q_difficulty AS FLOAT)) as computed_avg_difficulty,
    es.resp_rate * 100 AS provided_resp_rate,
    ROUND(CAST(COUNT(e.evaluation_id) AS FLOAT) / NULLIF(es.n_enrolled, 0) * 100, 0) AS computed_resp_rate,
    CASE 
        WHEN es.resp_rate * 100 = ROUND(CAST(COUNT(e.evaluation_id) AS FLOAT) / NULLIF(es.n_enrolled, 0) * 100, 0)
            THEN 'Valid'
        ELSE 'Not Valid'
    END AS validation_status
FROM evaluation_summary es
JOIN evaluations e ON es.offering_id = e.offering_id
GROUP BY 
    es.offering_id,
    es.responses,
    es.n_enrolled,
    es.resp_rate, 
    es.avg_overall,
    es.avg_clarity,
    es.avg_organization,
    es.avg_engagement,
    es.avg_feedback,
    es.avg_difficulty
ORDER BY es.offering_id;


-- Correlate avg_overall with avg_final_score at the offering level (hint: join Enrollments aggregate).

SELECT 
    es.offering_id,
    es.avg_overall,
    AVG(e.final_score) AS avg_final_score,
    COUNT(e.final_score) AS n_students
FROM evaluation_summary es
JOIN enrollments e ON es.offering_id = e.offering_id
JOIN course_offerings co ON es.offering_id = co.offering_id
JOIN courses c ON co.course_id = c.course_id
JOIN departments d ON c.department_id = d.department_id
GROUP BY 
    es.offering_id, es.avg_overall, 
    d.dept_code, c.course_code, 
    co.semester, co.year
HAVING COUNT(e.final_score) >= 5
ORDER BY es.offering_id;

-- 5.Scheduling

-- (a) double-booked classrooms (same timeslot)

SELECT 
    ot1.classroom_id,
    cl.building,
    cl.room_number,
    ts.day_of_week,
    ts.start_time,
    ts.end_time,
    COUNT(*) AS bookings
FROM offering_timeslots ot1
JOIN offering_timeslots ot2 
    ON ot1.classroom_id = ot2.classroom_id
    AND ot1.timeslot_id = ot2.timeslot_id
    AND ot1.offering_id != ot2.offering_id
JOIN classrooms cl ON ot1.classroom_id = cl.classroom_id
JOIN timeslots ts ON ot1.timeslot_id = ts.timeslot_id
GROUP BY ot1.classroom_id, cl.building, cl.room_number, ts.day_of_week, ts.start_time, ts.end_time
HAVING COUNT(*) > 1;

-- (b) professors teaching two offerings at the same timeslot

SELECT 
    p.professor_id,
    p.first_name, p.last_name,
    ts.day_of_week, ts.start_time, ts.end_time,
    co1.offering_id AS course_1,
    co2.offering_id AS course_2
FROM course_offerings co1
JOIN course_offerings co2 
    ON co1.professor_id = co2.professor_id
    AND co1.offering_id < co2.offering_id  -- avoid duplicates
JOIN offering_timeslots ot1 ON co1.offering_id = ot1.offering_id
JOIN offering_timeslots ot2 ON co2.offering_id = ot2.offering_id
JOIN timeslots ts ON ot1.timeslot_id = ts.timeslot_id
JOIN professors p ON co1.professor_id = p.professor_id
WHERE ot1.timeslot_id = ot2.timeslot_id;

-- (c) students enrolled in two offerings that share a timeslot.

SELECT 
    e1.student_id,
    ts.day_of_week, ts.start_time, ts.end_time,
    e1.offering_id AS course_1,
    e2.offering_id AS course_2
FROM enrollments e1
JOIN enrollments e2 
    ON e1.student_id = e2.student_id
    AND e1.offering_id < e2.offering_id
JOIN offering_timeslots ot1 ON e1.offering_id = ot1.offering_id
JOIN offering_timeslots ot2 ON e2.offering_id = ot2.offering_id
JOIN timeslots ts ON ot1.timeslot_id = ts.timeslot_id
WHERE ot1.timeslot_id = ot2.timeslot_id;

