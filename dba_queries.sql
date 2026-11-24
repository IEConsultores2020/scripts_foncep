---------ini privs

select * from dba_roles
;

select * from dba_role_privs
where GRANTEE like 'LM2%' 
    = 'LM2' AND GRANTED_ROLE like 'OGT%'
;

SELECT privilege 
FROM dba_sys_privs 
WHERE grantee = 'LM2';

SELECT * FROM dictionary
where table_name like '%PRIVS%';

select 'GRANT ' || privilege || ' ON ' || 'OGT_PK_PREDIS'|| ' TO ' || grantee ||';' AS grant_statement
from USER_TAB_PRIVS
where table_name like 'OGT_PK_PREDIS'
AND grantee in (select role from dba_roles);

select *
from user_tab_privs
where grantor = 'YDARBOLEDA';

---------fin privs

Forms funciona así: Forms_DDl('ALTER USER ' || mi_usuario || ' IDENTIFIED BY ' || :BL_CAMBIO_CLAVE.NUEVA_CLAVE);


execute immediate 'ALTER USER "' || u.username || '" IDENTIFIED BY "' || v_password || '" ACCOUNT UNLOCK PASSWORD EXPIRE';

alter user MCVERGARA  identified by "#FonceP2026#" account unlock


begin
    system.prc_cambiar_mi_clave('#FonceP2026*','#FonceP2026#');
end;


   ALTER USER smithj IDENTIFIED BY "MyNewPassword123#";

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
FROM all_cons_columns a
JOIN all_constraints b ON a.owner = b.owner AND a.constraint_name = b.constraint_name
JOIN all_cons_columns c ON b.r_owner = c.owner AND b.r_constraint_name = c.constraint_name
WHERE a.constraint_name = 'PK_SHD_TERCERO'
    AND a.owner = 'SHD';



---dba files
select * from v$session
;

SELECT sid, serial#, status, program 
select 'alter system kill session '||sid||','||serial#||';' FROM v$session 
WHERE program NOT LIKE '%oracle%' and status='ACTIVE';

/*
alter system kill session '326,40986'
alter system kill session '780,42264'
*/

alter system kill session '18,56962';
alter system kill session '941,13775';
alter system kill session '942,14123';
alter system kill session '1089,9430';


SELECT BLOCKING_SESSION, SID, SERIAL#, WAIT_CLASS, SECONDS_IN_WAIT, schemaname
FROM V$SESSION
WHERE --SCHEMANAME='SL' AND   
BLOCKING_SESSION IS NOT NULL
ORDER BY BLOCKING_SESSION;

SELECT sid, event, p1raw AS object_handle 
FROM v$session 
WHERE username = 'SL';

---
SELECT owner, object_name, object_type, status 
  FROM all_objects 
 WHERE object_name = 'PR_V_ORDEN_DE_PAGO_PREDIS';

SELECT granted_role --, default_role 
FROM dba_role_privs 
WHERE grantee='VVARGASN'
and  granted_role like 'OGT%'
MINUS
SELECT granted_role --, default_role 
FROM dba_role_privs 
WHERE grantee='YDARBOLEDA'
and  granted_role like 'OGT%';

select *
from user_role_privs
where granted_role like 'LM%';

--Privilegios de un rol
SELECT privilege, admin_option 
FROM role_sys_privs 
WHERE role = 'LM';


SELECT *
FROM role_sys_privs 
WHERE role = 'LM';

SELECT distinct role --* --table_name, privilege, grantor 
FROM role_tab_privs 
WHERE table_name='LM_SISTEMA'
;

SELECT *
FROM dba_role_privs 
WHERE grantee='YDARBOLEADA' --'GECRUZ' --'NYROA' --'FAGARCIA' --'MDPATINO' 
and granted_role like  'OG%'
and granted_role in (SELECT distinct role 
            FROM role_tab_privs 
            WHERE table_name='LM_SISTEMA')

LM2_ADMIN
LIMAY_CONSULTA_OIS

GRANT LIMAY_CONSULTA_OIS TO FAGARCIA;

GRANT SELECT ON LM_SISTEMA TO LM2_ADMIN

REVOKE SELECT ON LM_SISTEMA FROM LIMAY_CONSULTA_OIS;

select *
from seguridad;

--CURSOR CROL_USU IS
   SELECT GRANTED_ROLE FROM ROL_USU
   ;

-- CURSOR CSEGUR (Var_RolUsu Varchar2) IS
SELECT all TIPO_OBJETO, OBJETO_PADRE, OBJETO_A_VALIDAR,NULL 
FROM SEGURIDAD
WHERE ROL IN (SELECT * FROM ROL_USU WHERE GRANTED_ROLE LIKE 'OGT%')
AND ACTIVO = 1
GROUP BY TIPO_OBJETO, OBJETO_PADRE, OBJETO_A_VALIDAR;

SELECT *
FROM ROL_USU
WHERE GRANTED_ROLE LIKE 'OGT%'
AND GRANTED_ROLE NOT IN ('OGT_ADMIN',
'OGT_CONCILIADOR',
'OGT_CONCILIA_DSI',
'OGT_LEGALIZA_OP_SSF',
'OGT_OP_CONTABILIZAR',
'OGT_OP_IMPRIMIR',
'OGT_REPORTES',
'OGT_REPORTES_INGRESOS')

--		CURSOR CSEGURCAM (Var_RolUsu Varchar2) IS
		SELECT SEGURIDAD_CAMPOS.OBJETO_PADRE,
			SEGURIDAD_CAMPOS.OBJETO_A_VALIDAR,
			SEGURIDAD_CAMPOS.CAMPO,
			SEGURIDAD_CAMPOS.VALOR_INI,
			SEGURIDAD_CAMPOS.VALOR_FIN,
			SEGURIDAD_CAMPOS.ATRIBUTO,
			SEGURIDAD_CAMPOS.OBJETO_GUIA,
			SEGURIDAD_CAMPOS.mensaje
		FROM SEGURIDAD, SEGURIDAD_CAMPOS
		WHERE SEGURIDAD.ROL IN (select granted_role from rol_usu) AND
			SEGURIDAD.ACTIVO = 1 AND
			SEGURIDAD.ROL = SEGURIDAD_CAMPOS.ROL AND
			SEGURIDAD.TIPO_OBJETO = SEGURIDAD_CAMPOS.TIPO_OBJETO AND
			SEGURIDAD.OBJETO_PADRE = SEGURIDAD_CAMPOS.OBJETO_PADRE AND
			SEGURIDAD.OBJETO_A_VALIDAR = SEGURIDAD_CAMPOS.OBJETO_A_VALIDAR;

SELECT owner, object_name, object_type, status 
FROM all_objects 
WHERE object_name = 'PK_OGT_IMPUTACION';			

SELECT owner, synonym_name, table_owner, table_name 
FROM all_synonyms 
WHERE synonym_name = 'PK_OGT_IMPUTACION' 
   OR table_name = 'PK_OGT_IMPUTACION';

