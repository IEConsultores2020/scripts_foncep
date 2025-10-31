--pk_secuencial.fn_traer_consecutivo('RH','ACTOS_ADVOS','0000','0')


SELECT *
   -- SECUENCIAL
FROM
    BINCONSECUTIVO
WHERE
    GRUPO = 'OPGET'
    AND NOMBRE = 'ACTA_LEGAL_ID'
    AND VIGENCIA = '0000'
    AND CODIGO_COMPANIA = '000'
    AND CODIGO_UNIDAD_EJECUTORA = '00'
    ;

    SELECT NUMERO FROM OGT_DOCUMENTO
    ORDER BY 1 DESC
    ;

SELECT *
FROM BINTABLAS
WHERE GRUPO='NOMINA'
AND RESULTADO ='CIERTO'
AND NOMBRE='PATH'
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
where numero_identificacion in (1030592799,79693028) --651, 652
or interno_persona= 643   --  20730522
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
;

Select min(cuin_nid), max(cuin_nid) from lm_relacion_cuenta where extract(year from prio_dincio)=2025
;

Select *from lm_relacion_cuenta where cuin_nid=1180
;


select * from ogt_detalle_documento where doc_numero=54948
;
-----
insert into ogt_documento (
               numero,              tipo,                   estado, 
               fecha,               ter_id_receptor,        unte_codigo, 
               bin_tipo_cuenta,     bin_tipo_titulo,        cuba_numero, 
               numero_timbre,       observaciones,          usuario_elaboro,
               usuario_reviso,      con_id,                 bin_tipo_emisor_titulo
               fecha_compra_titulo, fecha_emision_titulo,   fecha_ventimiento_titulo
               tasa_cambio_titulo,  valor_actual_titulo,    valor_intereses_titulo,
               valor_ingreso_titulo valor_esperado_titulo,  valor_compra_titulo,
               numero_legal,        tipo_legal,             valor_reinversion_titulo,
               numero_soporte,      tipo_soporte,           fecha_soporte,
               ter_id_emiso,        ter_id_comprador,       bin_ciudad,
               fecha_venta_titulo,  fecha_pacto_titulo,     forma_pago,
               situacion_fondos,   destination_especifica,  descripcion,
               entidad,             unidad_ejecutora,       numero_externo
            ) values
            (  mi_numero_documento,    'XYZ',               'RE',
               sysdate,                p_rec_pago.id_banco, null,
               null,                   null,                '482800043630',

                 )
;

SELECT * FROM OGT_DOCUMENTO;

SELECT * FROM SL_PCP_CUENTA_COBRO;

SELECT * FROM SL_RELACION_TAC
WHERE CODIGO_COMPA =107766
;

SELECT pk_sit_infentidades.sit_fn_id_entidad(107766, SYSDATE)
FROM DUAL;


select *
from sl_pcp_cuenta_cobro
;

 SELECT descripcion
 -- INTO   :ogt_detalle_documento.concepto
  FROM   ogt_concepto_tesoreria
  WHERE  id = 'RECAUDO A FAVOR DE TERCERO' --:ogt_detalle_documento.cote_id;



 :ogt_detalle_documento.numero:=
    p_bintablas.TBuscar(:ogt_detalle_documento.cote_id,'OPGET','IMPUESTO_CONCEPTO',to_char(SYSDATE,'DD/MM/YYYY'));

select *
from BINTABLAS
where grupo ='OPGET'
AND nombre='RECAUDO_TERCERO';

select *
from BINTABLAS
where grupo ='OPGET'
AND NOMBRE='IMPUESTO_CONCEPTO';    

select *
from BINTABLAS
where grupo ='OPGET'
AND NOMBRE='TERCERO_DESTINO';    

select *
from BINTABLAS
where grupo ='OPGET'
AND NOMBRE= 'RECAUDO_TERCERO';   

select *
from BINTABLAS
where grupo ='OPGET'
AND NOMBRE= 'CENTROS_COSTO_INGRESOS' ;   

select *
from BINTABLAS
where grupo ='OPGET'
AND NOMBRE= 'ESTADO_RECAUDO_SISLA' ;   

SELECT *
FROM OGT_DOCUMENTO 
--WHERE NUMERO_SOPORTE='54948'
ORDER BY NUMERO_SOPORTE DESC NULLS LAST ;

s
;

select id, descripcion 
from (
SELECT id,
               descripcion
FROM ogt_concepto_tesoreria
WHERE afecta_ingreso <> 8 AND concepto_hoja = 1 AND fecha_final IS NULL
CONNECT BY PRIOR  id = cote_id
START WITH id = (SELECT id
   FROM ogt_concepto_tesoreria
   WHERE cote_id IS NULL
     AND ROWNUM = 1))
where descripcion like '%RECAUDO%CUOTAS%PARTES%'     
ORDER BY descripcion 
;

select * from ogt_concepto_tesoreria
where  descripcion like 'RECAUDO%CUOTAS PARTES POR APLICAR FIDUDAVIVIENDA'  

/*
    ID                      DESCRIPCION
--00-02-37-11-00-00-00      RECAUDO CUOTAS PARTES POR APLICAR FIDUDAVIVIENDA PA PENSIONES 2024
*/

ID   descripcion
1-3-84-08-01    FIDUDAVIVIENDA
1-3-84-08-01

GRUPO   NOMBRE              ARGUMENTO                                   RESULTADO
OPGET   IMPUTACION_PORTALP  RECAUDO_CAPITAL_CUOTASPARTES_POR_IMPUTAR    00-02-37-11-00-00-00
OPGET   IMPUTACION_PORTALP  RECAUDO_INTERESES_CUOTASPARTES_POR_IMPUTAR  00-02-37-11-00-00-00

insert into bintablas
(grupo, recaudo_tercero, argumento, resultado,vig_inicial,vig_final)
values
('OPGET','IMPUTACION_PORTALP','RECAUDO_CAPITAL_CUOTASPARTES_POR_IMPUTAR','00-02-37-11-00-00-00','01-JAN-2025',NULL)


select *
from BINTABLAS
where grupo ='OPGET'
AND NOMBRE='IMPUTACION_PORTALP';   

 insert into ogt_documento (numero) values (1);

 rollback 


select  from dual;

select *
from rh_personas
where  nombres like 'MARGARITA%' --numero_identificacion= 79693028
;


    select substr(DESCRIPCION,1,20)
    from ogt_concepto_tesoreria
    where id = :concepto;

    --Consulta del acta
    select *
    from ogt_documento
    where numero in (15617,54948)
      and tipo_legal = 'ALE' 
      and unte_codigo = 'FINANCIERO'
        ;

    --Consulta documento
    /*OGT_DOCUMENTO.NUM_LEGAL = OGT_ACTA.NUMERO AND
    OGT_DOCUMENTO.TIPO_LEGAL = OGT_ACTA.TIPO*/
    select *   54861 56715
    from ogt_documento
    where '15617' in (numero_soporte,numero_legal) 
      or '54948' in (numero_soporte,numero_legal)
      and tipo_legal = 'ALE' 
        ;        
        --or '54948'=numero_legal;

    select *
    from ogt_detalle_documento
    where 54948 = doc_numero ;

    select *
    from ogt_ingreso
    where doc_numero = '54948'
    and doc_tipo ='XYZ';

    select *
    from 
    where numero_identificacion in (1030592799,79693028,20730522);

    SELECT NVL(ing.cuba_tipo,'0'),
          NVL(ing.cote_id,'0'),
          NVL(ing.unte_codigo,'0'),
          NVL(ing.ter_id,0),
          NVL(ing.tipo_titulo,'0'),
          ing.valor,
          NVL(doc.bin_tipo_emisor_titulo,'0'), 
          DECODE('INGRESO' /*mi_tipo_transaccion_contable*/,'NO_AJUSTE',ing.doc_numero,ing.num_doc_legalizacion),
          DECODE('INGRESO' /*mi_tipo_transaccion_contable*/,'NO_AJUSTE',ing.doc_tipo,ing.tipo_doc_legalizacion),
          ing.ter_id_destino, 
          ing.vigencia,
          ing.fecha_consignacion,
          ing.ing_id,
          NVL(ing.cuba_numero,'0'),
          NVL(ing.cuba_sucu_ter_id,0),
          --RQ1885-2006 07-11-2006 campos para reintegros-reembolsos
          doc.tipo_soporte,
          doc.numero_soporte,
          doc.fecha_soporte
     FROM ogt_ingreso ing,
          ogt_documento doc
    WHERE DECODE('INGRESO' /*mi_tipo_transaccion_contable*/,'NO_AJUSTE',ing.doc_numero,ing.num_doc_legalizacion) = doc.numero
      AND DECODE('INGRESO' /*mi_tipo_transaccion_contable*/,'NO_AJUSTE',ing.doc_tipo,ing.tipo_doc_legalizacion) = doc.tipo
      AND ing.id = 507179; -- un_ingreso;    


    select *
    from ogt_detalle_pensionado;

select id
from ogt_concepto_tesoreria;


  select cod_centro_costo
        from ogt_tercero_cc;

select *
from all_constraints where constraint_name='INCU_DEIN_FK'
;


--Se actualiza a estado elaborado Solicitud Mario Chadid 10/31/2025

select *
from  --update
ogt_documento
--set estado = 'EL'
where tipo='ALE'
--and estado='AP'
and unte_codigo='FINANCIERO'
and numero in (56931);

COMMIT;