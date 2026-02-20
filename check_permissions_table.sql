-- Ver estructura de la tabla permissions
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name='permissions' 
ORDER BY ordinal_position;

-- Ver si hay datos
SELECT * FROM permissions LIMIT 5;