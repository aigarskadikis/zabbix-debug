
--browse all fields
SELECT * FROM graphs_items;

--check how many lines come with source color:
SELECT * FROM graphs_items WHERE color='1A7C11';

--check if destination color does not exist:
SELECT * FROM graphs_items WHERE color='40BFB4';

--replace 1A7C11 with 40BFB4
UPDATE graphs_items SET color='40BFB4' WHERE color='1A7C11';

SELECT COUNT(*),color FROM graphs_items GROUP BY color ORDER BY COUNT(*) ASC;

