# KPI and Analysis Reference

This reference distinguishes verified project findings from analytical indicators that require the PBIX or underlying data for an exact value.

## Verified Findings

| Indicator | Business meaning | Documented result |
|---|---|---:|
| Top-performing major | Major with the highest average GPA | **Computer Science** |
| A–C grade share | Students receiving grades from A through C | **≈68%** |
| Prerequisite exceptions | Students enrolled without completing required prerequisites | **203** |
| Dashboard pages | Management reporting views | **3** |

## Student Success Indicators

| Indicator | Definition | Management use |
|---|---|---|
| Average GPA | Mean GPA in the selected major, cohort, or period | Compare academic performance |
| Grade distribution | Share or count of students by grade band | Identify achievement and support needs |
| Student count | Distinct students in the selected context | Establish reporting denominator |
| Course completion rate | Completed enrollments divided by eligible enrollments | Monitor academic progression |
| At-risk student count | Students below an agreed GPA or grade threshold | Target advising and intervention |

## Course and Capacity Indicators

| Indicator | Definition | Management use |
|---|---|---|
| Enrollment count | Students registered in a course offering | Measure demand |
| Capacity utilization | Enrollment divided by available course or classroom capacity | Rebalance resources |
| Available seats | Capacity minus enrollment | Support registration planning |
| Over-capacity offerings | Offerings where enrollment exceeds capacity | Flag operational risk |
| Under-utilized offerings | Offerings below an agreed utilization threshold | Identify consolidation opportunities |

## Teaching Quality Indicators

| Indicator | Definition | Management use |
|---|---|---|
| Average evaluation score | Mean valid teaching-evaluation score | Monitor student feedback |
| Evaluation response rate | Submitted evaluations divided by eligible enrollments | Assess reliability |
| Professor-level score | Evaluation score grouped by professor | Support development conversations |
| Score-performance relationship | Association between teaching score and student final score | Explore instructional patterns |

## Compliance and Data Quality Indicators

| Indicator | Definition | Management use |
|---|---|---|
| Prerequisite exception count | Enrollments missing required prerequisite completion | Registration control |
| Missing assessment count | Expected assessment records without a valid score | Data completeness |
| Foreign-key exception count | Child records without a matching parent key | Database integrity |
| Schedule conflict count | Overlapping assignments for a student, professor, or classroom | Timetable quality |

## Validation Rules

- Use consistent student and enrollment denominators across SQL, Python, and Power BI.
- Recompute final scores from component weights before comparing them with stored results.
- Count prerequisite exceptions at the student-enrollment level before presenting a distinct-student total.
- Interpret evaluation scores together with response rate.
- Define utilization thresholds explicitly before labeling an offering under- or over-utilized.
- Keep qualitative descriptions when an exact numeric result has not been independently verified.

## Current Documentation Boundary

The repository supports exact reporting for the top-performing major, the approximate A–C grade share, and 203 prerequisite exceptions. Other indicators are included as analytical definitions; consult the PBIX, PDF report, and source data before publishing exact values.
