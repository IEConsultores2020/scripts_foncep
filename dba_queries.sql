--Triggers of a table
SELECT trigger_name, triggering_event, trigger_type, table_name, status
FROM user_triggers
WHERE table_name = 'OGT_DETALLE_ACTAS';

select *
from dictionary
where table_name like 'PR_ORDEN_DE_PAGO_REGISTRO'
;

SELECT *
FROM all_cons_columns
where constraint_name like 'FK_PR_REGIS_REF_5094_PR_DISPO'
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



---dba files
select * from v$session
;

SELECT sid, serial#, status, program FROM v$session WHERE program NOT LIKE '%oracle%';

/*
alter system kill session '326,40986'
alter system kill session '780,42264'
*/


SELECT BLOCKING_SESSION, SID, SERIAL#, WAIT_CLASS, SECONDS_IN_WAIT, schemaname
FROM V$SESSION
WHERE --SCHEMANAME='SL' AND   
BLOCKING_SESSION IS NOT NULL
ORDER BY BLOCKING_SESSION;

SELECT sid, event, p1raw AS object_handle 
FROM v$session 
WHERE username = 'SL';