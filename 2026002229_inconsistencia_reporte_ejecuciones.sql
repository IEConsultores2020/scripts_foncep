select vigencia, count(1) 
from pr.PR_ORDEN_DE_PAGO_REGISTRO
where codigo_compania=206
and codigo_unidad_ejecutora='01'
group by vigencia
order by 1;

select *
from usuarios_compania
where sistema='PREDIS'
and usuario='VVARGASN';

SELECT * /*distinct vigencia /*+ INDEX(PR_ORDEN_DE_PAGO_REGISTRO,PK_PR_ORDEN_DE_PAGO_REGISTRO) +
"VIGENCIA","RUBRO_INTERNO","CODIGO_COMPANIA","CODIGO_UNIDAD_EJECUTORA",
"NUMERO_DISPONIBILIDAD","NUMERO_ORDEN","NUMERO_REGISTRO","VALOR","CONSECUTIVO_ORDEN","ID_LIMAY"*/
FROM pr_v_orden_de_pago_predis
where vigencia = 2019
;


SELECT count(1)
FROM PR.PR_ORDEN_DE_PAGO
where codigo_compania=206
and codigo_unidad_ejecutora='01'
and vigencia = 2019
and extract(month from fecha_registro) = 12
--group by vigencia
;



select *
from usuarios_compania
where usuario='FTORRESV'
and codigo_unidad_ejecutora = '01'
;


SELECT * --owner, object_type
FROM all_objects
WHERE object_name = 'PR_ORDEN_DE_PAGO';


SELECT text
FROM all_views
WHERE owner = 'PR_COMUN'
  AND view_name = 'pr_v_orden_pago_regis_predis';


SELECT policy_name, object_owner, object_name
FROM dba_policies
WHERE object_name = 'PR_ORDEN_DE_PAGO'
  AND object_owner = 'PR';


---Vista PR_ORDE_DE_PAGO
  SELECT  /*+ INDEX(PR_ORDEN_DE_PAGO,PK_PR_ORDEN_DE_PAGO) +*/
VIGENCIA,CODIGO_COMPANIA,CODIGO_UNIDAD_EJECUTORA,NUMERO_ORDEN,
NUMERO_REGISTRO,NUMERO_DISPONIBILIDAD,ORIGEN,FECHA_ORDEN,FECHA_REGISTRO,
TIPO_PAGO,ESTADO,OBJETO,NUMERO_RELACION,CONSECUTIVO_ORDEN,TIPO_DOCUMENTO,
NUMERO_DOCUMENTO, CODIGO_ENTIDAD,DIGITO_VERIFICACION, ID_INTERNO,ID_LIMAY,ID_LIMAY_PL,'PREDIS' SISTEMA
FROM PR.PR_ORDEN_DE_PAGO
WHERE EXISTS (SELECT CODIGO_COMPANIA, CODIGO_UNIDAD_EJECUTORA
   FROM USUARIOS_COMPANIA
   WHERE USUARIO = USER AND
     SISTEMA = 'PREDIS' AND
     CODIGO_COMPANIA = PR.PR_ORDEN_DE_PAGO.CODIGO_COMPANIA AND
     CODIGO_UNIDAD_EJECUTORA = PR.PR_ORDEN_DE_PAGO.CODIGO_UNIDAD_EJECUTORA)
UNION ALL
SELECT
VIGENCIA,
CODIGO_COMPANIA,
CODIGO_UNIDAD_EJECUTORA,
NUMERO_ORDEN,
NUMERO_REGISTRO,
NUMERO_DISPONIBILIDAD,
ORIGEN,
FECHA_ORDEN,
FECHA_REGISTRO,
TIPO_PAGO,
ESTADO,
OBJETO,
NUMERO_RELACION,
CONSECUTIVO_ORDEN,
TIPO_DOCUMENTO,
NUMERO_DOCUMENTO,
0 CODIGO_ENTIDAD,
DIGITO_VERIFICACION,
ID_INTERNO,
ID_LIMAY,
ID_LIMAY_PL,
'OPGET' SISTEMA
FROM OGT_V_PREDIS_MAESTRO
WHERE EXISTS (SELECT CODIGO_COMPANIA, CODIGO_UNIDAD_EJECUTORA
   FROM USUARIOS_COMPANIA
   WHERE USUARIO = USER AND
     SISTEMA = 'PREDIS' AND
     CODIGO_COMPANIA = OGT_V_PREDIS_MAESTRO.CODIGO_COMPANIA AND
     CODIGO_UNIDAD_EJECUTORA = OGT_V_PREDIS_MAESTRO.CODIGO_UNIDAD_EJECUTORA)
WITH CHECK OPTION
;


SELECT FECHA_REGISTRO, COUNT(1)
FROM OGT_V_PREDIS_MAESTRO
WHERE EXISTS (SELECT CODIGO_COMPANIA, CODIGO_UNIDAD_EJECUTORA
   FROM USUARIOS_COMPANIA
   WHERE USUARIO = USER AND
     SISTEMA = 'PREDIS' AND
     CODIGO_COMPANIA = OGT_V_PREDIS_MAESTRO.CODIGO_COMPANIA AND
     CODIGO_UNIDAD_EJECUTORA = OGT_V_PREDIS_MAESTRO.CODIGO_UNIDAD_EJECUTORA)
AND VIGENCIA=2019
GROUP BY FECHA_REGISTRO
ORDER BY 1
;



--Se validan giros
 SELECT pr_v_orden_pago_regis_predis.vigencia, /*pr_v_orden_pago_regis_predis.rubro_interno,  */ count(1) total
    --rubro_interno, NVL(SUM(NVL(pr_v_orden_pago_regis_predis.valor, 0)), 0) total
      FROM  pr_v_orden_pago_regis_predis, pr_v_orden_de_pago_predis
     WHERE pr_v_orden_pago_regis_predis.vigencia                = pr_v_orden_de_pago_predis.vigencia
       AND pr_v_orden_pago_regis_predis.codigo_compania         = pr_v_orden_de_pago_predis.codigo_compania
       AND pr_v_orden_pago_regis_predis.codigo_unidad_ejecutora = pr_v_orden_de_pago_predis.codigo_unidad_ejecutora
       AND pr_v_orden_pago_regis_predis.numero_registro         = pr_v_orden_de_pago_predis.numero_registro
       AND pr_v_orden_pago_regis_predis.numero_disponibilidad   = pr_v_orden_de_pago_predis.numero_disponibilidad
       AND pr_v_orden_pago_regis_predis.numero_orden            = pr_v_orden_de_pago_predis.numero_orden
       AND pr_v_orden_pago_regis_predis.consecutivo_orden       = pr_v_orden_de_pago_predis.consecutivo_orden
       --AND pr_v_orden_pago_regis_predis.vigencia = :vigencia
       AND pr_v_orden_pago_regis_predis.codigo_compania = :codigo_compania
       AND pr_v_orden_pago_regis_predis.codigo_unidad_ejecutora = :codigo_unidad_ejecutora
       --AND pr_v_orden_pago_regis_predis.rubro_interno between 1831 and 1834 --:rubro_interno
       --AND TO_CHAR(pr_v_orden_de_pago_predis.fecha_registro, 'YYYY')            = :vigencia
       --AND TO_NUMBER(TO_CHAR(pr_v_orden_de_pago_predis.fecha_registro, 'MM')) = TO_NUMBER(:P_MES)
       AND pr_v_orden_de_pago_predis.ESTADO                                     <> 'ANULADO'
       group by pr_v_orden_pago_regis_predis.vigencia --, pr_v_orden_pago_regis_predis.rubro_interno 
       ;

    select vigencia, count(1)
    from pr_v_orden_pago_regis_predis   
    group by vigencia