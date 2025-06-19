--pk_secuencial.fn_traer_consecutivo('RH','ACTOS_ADVOS','0000','0')


SELECT *
   -- SECUENCIAL
FROM
    BINCONSECUTIVO
WHERE
    GRUPO = 'RH'
    AND NOMBRE = 'ACTOS_ADVOS'
    AND VIGENCIA = '0000'
    AND CODIGO_COMPANIA = '000'
    AND CODIGO_UNIDAD_EJECUTORA = '00'
    ;

set serveroutput on ;
DECLARE
    v_centro_costo NUMBER;
    v_descripcion VARCHAR2(500);
    v_cursor SYS_REFCURSOR;
BEGIN
    pk_sl_pcp_usuarios.LISTAR_CENTRO_COSTO(v_cursor);
    LOOP
        FETCH v_cursor INTO v_centro_costo, v_descripcion;
        EXIT WHEN v_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE( v_centro_costo||' '||v_descripcion);
    END LOOP;

    CLOSE v_cursor;
END;
/

select *
from rh_personas
where interno_persona= 649 --1030575813