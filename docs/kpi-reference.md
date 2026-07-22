# KPI and Validation Reference

This reference documents the verified definitions used in the corrected university dashboards.

## Verified KPIs

| Indicator | Grain and calculation | Verified result |
|---|---|---:|
| Student roster | Distinct `student_id` in `students` | **600** |
| Enrolled students | Distinct `student_id` in `enrollments` | **591** |
| Enrollments | Count of `enrollment_id` | **2,065** |
| Average final score | Mean valid `final_score` | **73.90** |
| Average GPA points | Mean `gpa_points` by enrollment | **1.90** |
| Pass rate | Enrollment grades A-D / all enrollment records | **87.36%** |
| A-C outcome rate | Enrollment grades A-C / all enrollment records | **60.77%** |
| Prerequisite exceptions | Enrollments missing evidence of a passing prerequisite | **203** |
| Students affected by prerequisite exceptions | Distinct students among exception enrollments | **183** |
| Courses | Distinct `course_id` | **108** |
| Delivered sections | Distinct `offering_id` | **61** |
| Section capacity | Sum of section `capacity` | **3,137** |
| Weighted section-seat utilization | Enrollments / summed section capacity | **65.83%** |
| Classrooms | Distinct `classroom_id` | **28** |
| Evaluation responses | Count of `evaluation_id` | **1,499** |
| Weighted evaluation response rate | Total responses / total enrolled from evaluation summary | **72.59%** |
| Average overall evaluation | Mean `q_overall` | **3.98 / 5** |
| Active instructors | Distinct professors assigned to analyzed sections | **29** |
| Professor roster | Distinct `professor_id` in professor table | **41** |

## Grade Distribution

| Grade | Enrollment records | Share |
|---|---:|---:|
| A | **209** | **10.12%** |
| B | **447** | **21.65%** |
| C | **599** | **29.01%** |
| D | **549** | **26.59%** |
| F | **261** | **12.64%** |

## Dashboard Rules

- Never label enrollment-record counts as student counts.
- State whether pass means A-C or A-D; the corrected dashboard uses A-D.
- Calculate weighted utilization from total enrollments divided by total section capacity.
- Report section capacity and classroom capacity separately.
- Show evaluation scores together with response counts or response rate.
- Apply a minimum of 20 responses to public instructor rankings.
- Preserve anonymized major labels unless an approved mapping table exists.

## Prerequisite Screening Boundary

The screen joins enrollment courses to their prerequisite requirements and looks for a passing A-D enrollment for the same student and prerequisite course. It identifies **203 enrollment exceptions affecting 183 students**.

The result is not a final academic-compliance judgment because the supplied data does not include:

- transferred credit;
- prerequisite waivers;
- course equivalencies;
- authoritative term-sequence history.

## Data Quality Checks

- Enrollment IDs are unique.
- No orphan student or offering keys were found in enrollments.
- Two enrollment records have missing `final_score`; they are excluded from the average score.
- Grade values are complete across all 2,065 enrollment records.
