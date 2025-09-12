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

SELECT *
FROM BINTABLAS
WHERE GRUPO=''

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

select interno_persona, numero_identificacion
from rh_personas
where numero_identificacion in (1030592799,79693028) --651, 652
or interno_persona= 588   --  20730522
--649 --1030575813
;

SELECT * FROM RH_LM_RA_CC_OGT;

GRANT SELECT ON OGT TO RH_M_RA_CC_OGT;


GRANT SELECT ON SCHEMA_B.TABLE_X TO PACKAGE_OWNER_SCHEMA;

ALTER USER GECALDERON ACCOUNT UNLOCK;

select * from OGT_PROVEEDORES_TERCEROS
where CODIGO_IDENTIFICACION like  '8600%'
;

select *
from OGT_REGISTRO_PRESUPUESTAL;


select *
from ogt_anexo_nomina
where tipo_ra = 1
and tipo_documento = 'RA'
and unidad_ejecutora = '01'
and entidad = 206
;





select SUM (APORTE_EMPLEADO)
from ogt_anexo_nomina
where vigencia = 2025
and consecutivo = 12
AND CODIGO_CENTRO_COSTOS IN ( 5, 1285, 1267)
;
 
select * from OGT_terceros
where codigo_identificacion like '8300537%';

DESCRIBE OGT_DOCUMENTO
;


select *
 from ogt_documento 
where numero = 54948 or 
numero_soporte = '54948'
;

select * from sl_pcp_pago
id_banco = 51
;

select * from ogt_cuenta_bancaria
where id_banco = 51

pk_sit_infentidades.sit_fn_id_superbancaria(:ogt_documento.id_receptor, SYSDATE);


SELECT *
FROM shd_informacion_entidades
      WHERE id = 51 AND ie_fecha_inicial <= SYSDATE AND
      (ie_fecha_final >= SYSDATE OR ie_fecha_final IS NULL);

SELECT *
FROM sl_pcp_usuarios
;


select *
from ogt_tipo_operacion
where unte_codigo='FINANCIERO'
and cltr_nombre='INGRESOS'
; ---REGISTRAR CUENTA AQUI

ogt_tipo_cuenta_contable

ogt_tipo_transaccion

select *
from bintablas
where grupo='PREDIS'
AND ARGUMENTO LIKE '%REPOR%';
--'Parametros archivo favidi'


select PK_OGT_OP.FN_OGT_VALOR_BINTABLAS
                                        ('OPGET'
                                        ,'VALIDA_PREDIS'
                                        ,'INDICATIVO_VALIDA_PREDIS'
                                        ,SYSDATE) from dual


--UPDATE bintablas
SET RESULTADO = 'SS'
where grupo='NOMINA'
AND ARGUMENTO ='CODIGO_FAVIDI';
--'Parametros archivo favidi'

ROLLBACK;


select *
from rh_personas
where numero_identificacion = 79315507 

