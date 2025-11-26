--Triggers of a table
SELECT trigger_name, triggering_event, trigger_type, table_name, status
FROM user_triggers
WHERE table_name = 'OGT_DETALLE_ACTAS';

select *
from dictionary
where table_name like '%CENTRO%COSTO%'
;

SELECT *
FROM all_cons_columns
where constraint_name like '%INCU_DEIN_FK'
;

SELECT distinct
    a.table_name AS child_table,
    a.column_name AS child_column,
    c.table_name AS parent_table,
    c.column_name AS parent_column
FROM
    all_cons_columns a
JOIN
    all_constraints b ON a.owner = b.owner AND a.constraint_name = b.constraint_name
JOIN
    all_cons_columns c ON b.r_owner = c.owner AND b.r_constraint_name = c.constraint_name
WHERE
    a.constraint_name = 'PK_SHD_TERCERO'
    AND a.owner = 'SHD';