---
name: sql-formatting
description: Format SQL commands according to Alude team's standards.
---

# Database SQL Formatting Standards

## Purpose

This document defines the SQL formatting conventions used by our team. All
generated, reviewed, and manually written SQL should follow these standards. SQL
commands may appear in various contexts, including application code and database
migration scripts. Consistent formatting across all contexts improves
readability, maintainability, and collaboration.

Only formatting and style guidelines are covered here. Query optimization,
indexing, and database design do not fall within the scope of this document.

Do not inspect existing SQL files to determine formatting conventions. The rules
and examples in this skill are sufficient and authoritative.

Use this skill to format SQL code snippets in your comments. Use it for all SQL
code blocks, and do not use any other formatting language for SQL.

## Scope

These standards apply to **PostgreSQL** queries and scripts. While many
principles generalize to other SQL dialects, specific features (e.g., JSONB,
RETURNING, ON CONFLICT) are PostgreSQL-specific.

## Validation

These conventions are strict. Treat every example as a required layout, not a
suggestion. If a query does not match the exact clause structure shown in this
document, the change must be explicit.

## General Principles

Follow these principles when formatting SQL queries:

- Preserve query logic.
- After editing, compare the result against every formatting rule.
- Report any rule that could not be applied.
- Prioritize readability over brevity.
- Prefer consistency over personal preference.
- Optimize for code reviews and maintenance.
- Prefer terminating statements with a semicolon, but allow omission in
  application code strings.
- Treat this document as the sole formatting authority.

## Verification checklist

Use the Specific Rules section to verify that your SQL query adheres to the
formatting standards. Check each item below:

- [ ] Indentation uses 4 spaces (no tabs)
- [ ] FROM table is on its own indented line
- [ ] SQL keywords are uppercase
- [ ] Built-in SQL data types are uppercase
- [ ] Boolean and NULL literals are uppercase
- [ ] Columns are selected one per line
- [ ] Table aliases follow alias rules
- [ ] JOIN types are explicitly written
- [ ] JOIN table is on its own indented line beneath JOIN
- [ ] ON keyword is on its own line at JOIN indentation level
- [ ] JOIN ON conditions are correctly indented beneath ON
- [ ] WHERE/HAVING predicates are separated correctly
- [ ] Boolean operators are placed at line endings
- [ ] GROUP BY columns are one per line
- [ ] ORDER BY entries are one per line
- [ ] Column aliases use AS
- [ ] Aggregations have aliases
- [ ] INSERT/UPDATE/DELETE formatting matches examples
- [ ] RETURNING clauses follow formatting rules
- [ ] CTEs follow naming and indentation rules
- [ ] CASE expressions are vertically formatted
- [ ] No conflicting formatting rules exist
- [ ] Sub-clauses re-indented to 4 spaces after keyword reformatting
- [ ] Preserve parameter placeholders exactly as written (e.g., `:name`, `:id`).
- [ ] No trailing whitespace. End files with a single newline.

---

## Specific Rules

### Keyword Casing

Always use uppercase SQL keywords.

#### Good

```sql
SELECT
    landlord.id
FROM
    landlord
WHERE
    landlord.active = TRUE;
```

#### Bad

```sql
select
    landlord.id
from
    landlord
where
    landlord.active = true;
```

---

### Data Type Casing

Always write built-in SQL data types in uppercase (e.g., `VARCHAR`,
`TIMESTAMPTZ`, `INTEGER`, `UUID`, `BOOLEAN`). This applies to table definitions,
function signatures, and casts. Keep user-defined type identifiers as declared
in the schema.

#### Good

```sql
CREATE TABLE example_table (
    id INTEGER,
    created_at TIMESTAMPTZ,
    description VARCHAR(255)
);
```

```sql
CREATE OR REPLACE FUNCTION sample_fn(
    p_created_at TIMESTAMPTZ,
    p_name VARCHAR
)
    RETURNS INTEGER
```

```sql
SELECT
    CAST(:address AS TEXT) AS address_text,
    :id::UUID AS request_id;
```

#### Bad

```sql
CREATE TABLE example_table (
    id integer,
    created_at timestamptz,
    description varchar(255)
);
```

```sql
SELECT
    CAST(:address AS text) AS address_text,
    :id::uuid AS request_id;
```

---

### Column Selection

Select one column per line.

#### Good

```sql
SELECT
    landlord.id,
    landlord.name,
    landlord.document
FROM
    landlord;
```

#### Bad

```sql
SELECT landlord.id, landlord.name, landlord.document
FROM
    landlord;
```

---

### Table References

Use full table names whenever practical. Use `AS` for table aliases if it is
necessary and prefer explicit alias names that improve readability, avoid being
redundant.

#### Good

```sql
SELECT
    landlord.id,
    landlord.name
FROM
    landlord;
```

#### Acceptable

```sql
SELECT
    l.id,
    l.name
FROM
    landlord AS l;
```

#### Avoid

```sql
SELECT
    a.id,
    a.name
FROM
    landlord AS a;
```

#### Bad

```sql
SELECT
    landlord.id,
    landlord.name
FROM
    landlord AS landlord;
```

Simple aliases should only be used when joining multiple tables or when the
query would otherwise become difficult to read.

---

### FROM Formatting

Place the table name on its own line, indented one level beneath the `FROM`
keyword.

#### Good

```sql
SELECT
    landlord.id
FROM
    landlord;
```

#### Bad

```sql
SELECT
    landlord.id
FROM landlord;
```

---

### JOIN Formatting

Each JOIN clause should appear on its own line. The joined table name goes on
the next line, indented one level. The `ON` keyword goes on its own line at the
same indentation level as the JOIN, and its condition(s) go on the next line,
indented one level deeper.

#### Good

```sql
SELECT
    landlord.id,
    contract_rental.id AS contract_id
FROM
    landlord
INNER JOIN
    contract_rental
ON
    contract_rental.landlord_id = landlord.id;
```

When the `ON` condition spans multiple predicates, each goes on its own line
with boolean operators at the end:

```sql
INNER JOIN
    split_parameters
ON
    split_parameters.contract_id = billing.contract_id AND
    split_parameters.removed_at IS NULL
```

#### Bad

```sql
SELECT
    landlord.id,
    contract_rental.id
FROM landlord INNER JOIN contract_rental ON contract_rental.landlord_id = landlord.id;
```

```sql
INNER JOIN contract_rental
    ON contract_rental.landlord_id = landlord.id;
```

---

### JOIN Types

Always write the JOIN type explicitly, including `LEFT JOIN`, `INNER JOIN`,
`RIGHT JOIN`, `FULL JOIN`, `CROSS JOIN`, and `LEFT JOIN LATERAL` when
applicable.

#### Good

```sql
INNER JOIN contract_rental
```

```sql
LEFT JOIN receivable
```

```sql
LEFT JOIN LATERAL (
    SELECT
        1
) AS something
```

#### Avoid

```sql
JOIN contract_rental
```

---

### Boolean Expressions

When a WHERE or JOIN condition contains multiple predicates, place each
predicate on its own line and keep boolean operators (`AND`, `OR`) at the end of
the line. Use parentheses to group related predicates clearly.

#### Good

```sql
WHERE
    landlord.active = TRUE AND
    landlord.deleted_at IS NULL AND (
        contract.status = 'approved' OR
        contract.status = 'signed'
    )
```

#### Bad

```sql
WHERE landlord.active = TRUE AND landlord.deleted_at IS NULL AND (contract.status = 'approved' OR contract.status = 'signed')
```

---

### WHERE Clauses

Place each condition on its own line when multiple conditions exist. Put boolean
operators at the end of the line so new conditions can be added cleanly.

#### Good

```sql
WHERE
    landlord.active = TRUE AND
    landlord.deleted_at IS NULL AND
    landlord.document IS NOT NULL
```

#### Bad

```sql
WHERE landlord.active = TRUE AND landlord.deleted_at IS NULL AND landlord.document IS NOT NULL
```

---

### HAVING Clauses

Format `HAVING` clauses like `WHERE` clauses—place conditions on separate lines
with boolean operators at the end.

#### Good

```sql
SELECT
    landlord.id,
    COUNT(contract_rental.id) AS contract_count
FROM
    landlord
LEFT JOIN
    contract_rental
ON
    contract_rental.landlord_id = landlord.id
GROUP BY
    landlord.id
HAVING
    COUNT(contract_rental.id) > 0 AND
    MAX(contract_rental.created_at) >= '2025-01-01';
```

#### Bad

```sql
HAVING COUNT(contract_rental.id) > 0 AND MAX(contract_rental.created_at) >= '2025-01-01'
```

---

### DISTINCT Keyword

Use `DISTINCT` sparingly and only when necessary. Place it immediately after
`SELECT`. If using `DISTINCT ON` (PostgreSQL feature), format it clearly.

#### Good

```sql
SELECT DISTINCT
    landlord.id,
    landlord.name
FROM
    landlord;
```

```sql
SELECT DISTINCT ON (landlord.id)
    landlord.id,
    landlord.name,
    landlord.created_at
FROM
    landlord;
```

---

### IN and BETWEEN Operators

Format `IN` lists vertically when they contain more than 3 items. Use `BETWEEN`
for range queries to improve readability.

#### IN Operator

**Good (few items):**

```sql
WHERE landlord.status IN ('active', 'pending')
```

**Good (many items):**

```sql
WHERE landlord.id IN (
    1,
    2,
    3,
    4,
    5
)
```

#### BETWEEN Operator

```sql
WHERE
    landlord.created_at BETWEEN '2025-01-01' AND '2025-12-31'
```

---

### Aggregations

Place aggregate expressions on separate lines.

#### Good

```sql
SELECT
    landlord.id,
    COUNT(contract_rental.id) AS contract_count,
    MAX(contract_rental.created_at) AS latest_contract_date
FROM
    landlord
LEFT JOIN
    contract_rental
ON
    contract_rental.landlord_id = landlord.id
GROUP BY
    landlord.id;
```

---

### GROUP BY

Each grouped column should be on its own line.

#### Good

```sql
GROUP BY
    landlord.id,
    landlord.name;
```

---

### ORDER BY

Each ordering rule should be on its own line.

#### Good

```sql
ORDER BY
    landlord.name ASC,
    landlord.created_at DESC;
```

---

### Common Table Expressions (CTEs)

Use CTEs for complex transformations. Prefer CTEs over deeply nested subqueries
whenever possible. Place the `WITH` clause at the top of the query and keep each
CTE section clearly separated. Use clear, descriptive names.

#### Good

```sql
WITH active_landlords AS (
    SELECT
        landlord.id,
        landlord.name
    FROM
        landlord
    WHERE
        landlord.active = TRUE
),
approved_contracts AS (
    SELECT
        contract_rental.id,
        contract_rental.landlord_id
    FROM
        contract_rental
    WHERE
        contract_rental.status = 'approved'
)
SELECT
    active_landlords.id,
    active_landlords.name
FROM
    active_landlords;
```

---

### Subqueries and Derived Tables

Use nested queries and derived tables sparingly. When needed, indent them
clearly and keep each logical block separated.

#### Good

```sql
SELECT
    recent_landlords.id,
    recent_landlords.name
FROM (
    SELECT
        landlord.id,
        landlord.name
    FROM
        landlord
    WHERE
        landlord.created_at >= '2025-01-01'
) AS recent_landlords;
```

---

### INSERT / UPDATE / DELETE

Format DML statements clearly with one column or value per line.

#### INSERT

```sql
INSERT INTO landlord (
    name,
    document,
    active
)
VALUES (
    'John Doe',
    '12345678900',
    TRUE
);
```

#### INSERT with ON CONFLICT / RETURNING

```sql
INSERT INTO subscription (
    notification_group_slug,
    address_type,
    address,
    subscription_state,
    channel
)
VALUES (
    :notification_group_slug,
    :address_type,
    :address,
    :subscription_state,
    :channel
)
ON CONFLICT (notification_group_slug, address_type, address)
DO UPDATE SET
    subscription_state = EXCLUDED.subscription_state,
    updated_at = NOW()
RETURNING
    *;
```

#### UPDATE

```sql
UPDATE landlord
SET
    active = FALSE,
    updated_at = NOW()
WHERE
    landlord.id = 123;
```

#### DELETE

```sql
DELETE FROM landlord
WHERE
    landlord.id = 456;
```

---

### RETURNING

When using `RETURNING`, place it on its own line and list returned columns
clearly.

#### Good

```sql
UPDATE
    subscription
SET
    removed_at = NOW()
WHERE
    id = :id
RETURNING
    *;
```

---

### ON CONFLICT

When using `ON CONFLICT`, place it on its own line and clearly specify the
conflict target and action. The action can be `DO NOTHING` or
`DO UPDATE SET ...`. If using `DO UPDATE`, list the updated columns clearly.

#### Good

```sql
ON CONFLICT (id)
DO NOTHING;
```

```sql
ON CONFLICT (id)
DO UPDATE SET
    updated_at = NOW();
```

---

### Functions and Casts

Format multiline function arguments vertically and keep casts concise. Use
`CAST(... AS TYPE)` or `::TYPE` consistently with the surrounding codebase.

#### Good

```sql
SELECT
    COALESCE(
        params.bucket_size,
        default_params.bucket_size
    ) AS bucket_size,
    CAST(:address AS TEXT) AS address_text
FROM
    auto_reply;
```

#### Bad

```sql
SELECT
    COALESCE(params.bucket_size, default_params.bucket_size) AS bucket_size,
    CAST(:address AS text) AS address_text
FROM
    auto_reply;
```

#### Type Casts

Use PostgreSQL's double-colon notation (`::`) for concise type casts when the
code style aligns with it:

```sql
CAST(:channel AS channel_t)
```

Or equivalently:

```sql
:channel::channel_t
```

---

### LIMIT / OFFSET

When used, place `LIMIT` and `OFFSET` on separate lines.

#### Good

```sql
ORDER BY
    landlord.created_at DESC
LIMIT 50
OFFSET 0;
```

---

### UNION Operations

Use `UNION ALL` when duplicate rows are acceptable (more performant). Use
`UNION` only when deduplication is required. Format each SELECT query following
standard conventions.

#### Good

```sql
SELECT
    landlord.id,
    landlord.name
FROM
    landlord
WHERE
    landlord.active = TRUE
UNION ALL
SELECT
    contractor.id,
    contractor.name
FROM
    contractor
WHERE
    contractor.active = TRUE
ORDER BY
    name ASC;
```

---

### CASE Expressions

Format CASE expressions vertically.

#### Good

```sql
CASE
    WHEN status = 'approved' THEN 'success'
    WHEN status = 'rejected' THEN 'failure'
    ELSE 'unknown'
END AS result
```

---

### Aliases

Always use AS for column aliases. Avoid leaving aggregation functions without
aliases.

#### Good

```sql
SELECT
    COUNT(*) AS contract_count,
    MAX(contract_rental.created_at) AS latest_contract_date
```

#### Bad

```sql
SELECT
    COUNT(*) contract_count,
    MAX(contract_rental.created_at)
```

---

### Commas

Place commas at the end of lines.

#### Good

```sql
SELECT
    landlord.id,
    landlord.name,
    landlord.document
FROM
    landlord;
```

#### Bad

```sql
SELECT
    landlord.id
    , landlord.name
    , landlord.document
FROM
    landlord;
```

### Indentation after reformatting

When reformatting a statement (e.g., collapsing `INSERT INTO\n    table` into
`INSERT INTO table`), **always re-indent all subsequent lines** so they sit
exactly one level (4 spaces) deeper than the statement keyword. Do not carry
over stale indentation from the previous layout.

#### Bad (stale indentation after reformatting)

```sql
INSERT INTO operation_request (
        id,
        workspace_id,
        amount
    )
```

#### Good (re-indented correctly)

```sql
INSERT INTO operation_request (
    id,
    workspace_id,
    amount
)
```
