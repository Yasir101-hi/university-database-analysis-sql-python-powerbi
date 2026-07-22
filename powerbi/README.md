# Power BI metric corrections

The report layout uses the original university theme. Its visual labels distinguish
student, enrollment, section, and evaluation grains.

The packaged PBIX was created with Power BI Desktop and its semantic model cannot be
safely rewritten by ordinary ZIP or text tooling. Before publishing from Desktop,
replace the portfolio response-rate measure with the weighted definition below and
format it as a percentage with two decimals:

```DAX
Weighted Response Rate % =
DIVIDE(
    SUM(evaluation_summary[responses]),
    SUM(evaluation_summary[n_enrolled])
)
```

For the supplied snapshot the result is **72.59%** (`1,499 / 2,065`), not the
unweighted average of offering-level response rates. Keep the following labels:

- `Enrolled Students` for the distinct enrolled-student card.
- `Enrollment Records by Grade` for the grade distribution.
- `Difficulty vs Engagement by Course` for the teaching-quality stacked chart.
- `Enrollment vs Evaluation Responses by Faculty` for the faculty comparison.

The exported dashboard images, presentation, PDF, SQL, and notebook already use
these corrected definitions.
