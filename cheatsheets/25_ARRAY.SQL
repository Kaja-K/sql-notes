-- ── ARRAY CASTING ────────────────────────────────────────────
SELECT ARRAY['Trailers', 'Deleted Scenes']::text[];
-- → {Trailers,Deleted Scenes}   casts an array literal to text[] type

SELECT '{Trailers, Deleted Scenes}'::text[];
-- → {Trailers,Deleted Scenes}   casts a PostgreSQL-format string to text[]

-- ── WHAT IS text[] ───────────────────────────────────────────
-- text[]  — array type: a one-dimensional array of text values
-- Each element is a plain text value
-- Stored in format: {element1, element2, ...}

-- ── ARRAY COMPARISON ─────────────────────────────────────────
SELECT special_features = ARRAY['Trailers', 'Deleted Scenes']::text[]
FROM film;
-- → true/false   compares the entire array (order matters!)

SELECT special_features = '{Trailers, Deleted Scenes}'::text[]
FROM film;
-- → true/false   same result, different syntax

-- ── CONTAINMENT ──────────────────────────────────────────────
SELECT special_features @> ARRAY['Trailers']::text[]
FROM film;
-- → true   if array CONTAINS 'Trailers' (may have other elements too)

SELECT special_features <@ ARRAY['Trailers', 'Deleted Scenes']::text[]
FROM film;
-- → true   if array is a SUBSET of the given list (nothing beyond it)

-- Together @> and <@ = exact match regardless of element order:
SELECT film_id FROM film
WHERE special_features @> ARRAY['Trailers', 'Deleted Scenes']::text[]
  AND special_features <@ ARRAY['Trailers', 'Deleted Scenes']::text[];

-- ── INTEGER ARRAYS ───────────────────────────────────────────
SELECT ARRAY[1, 2, 3]::integer[];
SELECT ARRAY[1, 2, 3]::int[];          -- int[] is shorthand for integer[]

-- ── NUMERIC / DECIMAL ────────────────────────────────────────
SELECT ARRAY[1.5, 2.7, 3.14]::numeric[];
SELECT ARRAY[1.5, 2.7]::decimal[];

-- ── BOOLEAN ──────────────────────────────────────────────────
SELECT ARRAY[true, false, true]::boolean[];

-- ── DATE / TIMESTAMP ─────────────────────────────────────────
SELECT ARRAY['2024-01-01', '2024-12-31']::date[];
SELECT ARRAY['2024-01-01 12:00', '2024-06-15 08:30']::timestamp[];

-- ── UUID ─────────────────────────────────────────────────────
SELECT ARRAY['a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11']::uuid[];

-- ── INET (from note 24!) ──────────────────────────────────────
SELECT ARRAY['192.168.1.1', '10.0.0.1']::inet[];

-- ── CHECKING FOR AN ELEMENT ──────────────────────────────────
SELECT 'Trailers' = ANY(special_features)
FROM film;
-- → true   if 'Trailers' is ANY element of the array

SELECT 'Trailers' = ALL(special_features)
FROM film;
-- → true   if ALL elements of the array are 'Trailers'

-- ── INDEXING ─────────────────────────────────────────────────
SELECT special_features[1] FROM film;
-- → 'Trailers'   first element (PostgreSQL arrays are 1-indexed, not 0!)

SELECT special_features[2] FROM film;
-- → 'Deleted Scenes'   second element

-- ── ARRAY LENGTH ─────────────────────────────────────────────
SELECT array_length(special_features, 1) FROM film;
-- → 2   number of elements in the first dimension of the array

-- ── UNNEST – expand array into rows ──────────────────────────
SELECT film_id, unnest(special_features) AS feature
FROM film;
-- → each array element becomes a separate row
-- film_id | feature
--    1    | Trailers
--    1    | Deleted Scenes