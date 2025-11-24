

CREATE TABLE IF NOT EXISTS tempTable (full_text text);

--extracting data from the file
COPY tempTable FROM 'C:\Program Files\PostgreSQL\18\data\task1_d.json' (format text);

--processing data with regex
UPDATE tempTable
SET full_text = regexp_replace(full_text, ':(\w+)=>', '"\1":', 'g');
-- () - creates a group
-- \w+ - any alphanumeric, one or more
-- "\1" - first group
-- g - all occurences

--splitting array into separate JSON objects
CREATE TABLE IF NOT EXISTS tempTable2 (split_text text);
INSERT INTO tempTable2 (split_text)
SELECT json_array_elements(full_text::json) 
FROM tempTable;

--splitting objects into individual columns
CREATE TABLE IF NOT EXISTS extracted_data AS
    SELECT  
    (split_text::json ->>'id')::numeric AS id,
    split_text::json ->>'title'         AS title,
    split_text::json ->>'author'        AS author,
    split_text::json ->>'genre'         AS genre,
    split_text::json ->>'publisher'     AS publisher,
    (split_text::json ->>'year')::int   AS year,
    split_text::json ->>'price'         AS price
    FROM tempTable2;

CREATE TABLE IF NOT EXISTS summary AS
    SELECT 
        "year" AS publication_year,
        COUNT(id) AS book_count,
        avg(CASE
            WHEN price LIKE '$%' THEN TRIM('$' FROM price)::decimal(4,2)
            ELSE TRIM('€' FROM price)::decimal(4,2) * 1.2
        END)::decimal(4,2) AS average_price
    FROM extracted_data
    GROUP BY "year"
    ORDER BY "year";
    
SELECT * FROM extracted_data;

SELECT * FROM summary;

