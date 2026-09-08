# Manufacturing Line Efficiency Analysis: Identifying the Root Causes of Downtime

SQL and Python portfolio project analyzing downtime and productivity data from a soda bottling production line, identifying the biggest drivers of downtime and how actual line performance compares to the production standard.

## Project Information

Role: Data Analyst, Independent Project
Tools: Excel (Power Query), PostgreSQL, Power BI
Completed: July 2026

This project uses the [Manufacturing Downtime](https://mavenanalytics.io/data-playground/manufacturing-downtime) dataset from Maven Analytics. The business case, questions, and analysis are my own, built on top of this public dataset.

## Business Problem

A soda bottling production line was experiencing significant downtime, but management didn't have a clear picture of which factors were most often causing it, which operators were contributing to inefficiency, or how far actual line performance was deviating from the expected production standard.

## Objective

Analyze downtime and productivity data from the production line to help the operations team identify the root causes of downtime and build targeted improvement recommendations.

## Business Questions

- What is the current production line efficiency (actual time vs. the minimum standard time)?
- Are there operators whose performance lags behind others?
- What are the main factors causing downtime?
- Do certain operators tend to experience certain types of operator error more than others?

## Dataset

Three tables: `downtime_master` (61 rows, downtime events with factor and operator detail), `productivity` (38 rows, one row per batch produced), `products` (6 rows, product-level minimum batch time standard).

Worth flagging upfront: this covers a single production line over a limited window with only four operators and six products, so the patterns found here describe this specific line and period rather than a general manufacturing benchmark. The analysis is also correlational: it points to areas worth investigating further, not confirmed root causes.

## Tools and Concepts Used

Excel (Power Query, unpivoting, PivotTable), PostgreSQL (JOINs, window functions, conditional aggregation with CASE WHEN), Power BI.

## Analysis Process

- Cleaned and restructured the downtime data from wide to long format using Power Query, unpivoting 12 factor columns into individual rows.
- Combined three data sources (downtime, factor descriptions, and batch productivity data) into a single master table in Excel.
- Detected and corrected a data anomaly: batches whose production time crossed midnight, which produced negative durations.
- Built an early analysis using an Excel PivotTable for a quick sanity check before moving to SQL.
- Imported the cleaned data into PostgreSQL, including fixing the table structure and adjusting the CSV delimiter.
- Wrote SQL in layers, starting with simple aggregation, then window functions, then conditional aggregation, to answer the four business questions above.

## Key Findings

**Production line efficiency.** Overall line efficiency sits at 64.02% (3,858 actual minutes vs. 2,470 minimum standard minutes). More than a third of production time is spent beyond the minimum standard.

Efficiency varies quite a bit by product: OR-600 is the least efficient at 44.44%, while LE-600 is the most efficient at 68.05%. This gap suggests the problem isn't evenly distributed. There's likely a product-specific factor (process complexity, batch-change frequency, etc.) worth investigating further.

**Main drivers of downtime.** The top three factors (machine adjustment at 332 minutes, machine failure at 254 minutes, and inventory shortage at 225 minutes) together account for 58% of the 1,388 total downtime minutes. This points to equipment issues and material readiness as the two main problem areas, rather than individual operator error alone.

**Operator performance.** Charlie logged the highest total downtime (384 minutes across 17 incidents), followed by Dee (370 minutes across 19 incidents). But looking at average duration per incident, Dennis and Mac actually have the longest average (~25 minutes/incident) despite occurring less often. That points to two different problem patterns: Dee and Charlie experience frequent but short downtime, while Dennis and Mac experience it less often but for longer when it happens.

**Preventable downtime.** 55.9% of total downtime (776 of 1,388 minutes) is classified as preventable, tied to operator actions or decisions during the process (e.g., batch change, product spill, machine adjustment, calibration error) that could be improved through training or SOP adjustments. The remaining 44.1% comes from factors outside an operator's direct control, like machine failure, inventory shortage, and emergency stops.

The most notable and most actionable pattern is Mac on the "Batch change" process (130 minutes), which represents 68% of Mac's own total preventable downtime, far ahead of any other operator-process combination. This points to a very specific, immediately actionable training gap, unlike other operators whose downtime is spread across several processes. Charlie, for example, is split across machine adjustment, batch coding error, and calibration error, so he likely needs a broader training approach rather than one focused fix.

## What I Learned

- To calculate a summary metric like overall efficiency, the data source needs to cover the full unit of analysis (every batch), not just the subset that happens to have a specific event (downtime). Otherwise the result ends up biased or underestimated.
- Window functions (`SUM() OVER ()`) are useful for calculating group-level totals or aggregates without collapsing the row-level detail, for example calculating each row's percentage contribution to the overall total.
- Conditional aggregation (`SUM(CASE WHEN...)`) makes it possible to calculate several category breakdowns in a single query, without needing a separate subquery for each category.
- `GROUP BY` isn't mandatory in every aggregate query. Whether to use it depends on the level of detail the output needs (per-category vs. a total summary).
- The ETL process done upfront (unpivoting, combining multiple tables) determines how valid the downstream analysis is. A small mistake like rows dropped during unpivoting can meaningfully affect the aggregate calculations that follow.

## Mistakes I Found and Fixed

- When first calculating batch duration from a time difference, I didn't account for batches whose production crossed midnight, which produced an error or negative result. Fixed by adding conditional logic for that case.
- Picked the wrong CSV delimiter (comma vs. semicolon) when importing into PostgreSQL, since Indonesia's regional Excel settings produce a different CSV format from the international default.
- Initially used the wrong data source (`downtime_master`, which only contains batches that had downtime) to calculate overall line efficiency, when it should have used the `productivity` data (which covers every batch). Left uncorrected, the efficiency number would have been underestimated because batches without downtime wouldn't be counted at all.

## What I'd Do Differently Next Time

- Analyze downtime trends over time (e.g., by date) to see whether the problem is getting better or worse, rather than only looking at the aggregate total.
- Document the data cleaning process alongside the work itself, rather than after it's done, so it's easier to trace back if an anomaly shows up later.

## Recommendations

Prioritize equipment maintenance. Machine adjustment (preventable) and machine failure (outside operator control) together account for almost 42% of total downtime. This needs further investigation to separate what's a purely mechanical equipment issue from what's an operator calibration skill gap that could be closed through training.

Targeted training for Mac. With 68% of Mac's error concentrated in a single factor (batch change), the main recommendation is SOP training focused specifically on the batch-change process for this operator, rather than general training.

Review the OR-600 time standard. OR-600's efficiency is far below other products (44% vs. an average of 64%) and warrants a closer look at whether its Min Batch Time standard was set too strictly, or whether there's a process issue specific to this product.

Inventory management. Inventory shortage as the third-largest downtime factor (225 minutes) points to a need to evaluate the procurement and material-scheduling system, separate from operator performance issues.

## SQL Files

- 01_downtime_by_factor.sql: total downtime minutes by factor description.
- 02_downtime_by_operator.sql: total downtime, incident count, and average duration per incident by operator.
- 03_operator_error_breakdown.sql: downtime breakdown by operator and factor, filtered to operator-error incidents.
- 04_overall_line_efficiency.sql: overall line efficiency (actual time vs. minimum standard time).
- 05_operator_error_summary.sql: total downtime and percentage split between preventable (operator error) and non-preventable downtime.
- 06_operator_error_percentage.sql: downtime and operator-error percentage broken down by operator.
- 07_efficiency_by_product.sql: line efficiency broken down by product.

## Data Source

Dataset: [Manufacturing Downtime](https://mavenanalytics.io/data-playground/manufacturing-downtime), Maven Analytics.

## Author

Data Analyst Portfolio: [sayedfurqan.lovable.app](https://sayedfurqan.lovable.app/)
