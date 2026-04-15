SELECT SECUENCIAL
FROM     BINCONSECUTIVO
WHERE   GRUPO = 'OPGET'
    AND NOMBRE = 'ACTA_LEGAL_ID'
    AND VIGENCIA = '0000'
    AND CODIGO_COMPANIA = '000'
    AND CODIGO_UNIDAD_EJECUTORA = '00'
    ;

    SELECT NUMERO FROM OGT_DOCUMENTO
    ORDER BY 1 DESC
    ;

SELECT *
FROM 
--UPDATE 
BINTABLAS
--SET RESULTADO='RptSvr_seul_asinst_2'
WHERE GRUPO in ('GENERAL')
AND NOMBRE='IDENTIFICACION'
--AND ARGUMENTO='REPORTSERVER'
AND VIG_INICIAL <= SYSDATE
AND (VIG_FINAL IS NULL OR VIG_FINAL >= SYSDATE)
;



select * from rh_maestro_personas
where nfuncionario in 
(select * --interno_persona, numero_identificacion, nombres, primer_apellido, segundo_apellido
 from rh_personas
--where nombres ='DIANA MARCELA' and primer_apellido='SANABRIA'
where numero_identificacion in (52116283)) --651, 652
--or interno_persona= 643   --  20730522
--649 --1030575813
;


SELECT *
FROM shd_informacion_entidades
      WHERE id = 51 AND ie_fecha_inicial <= SYSDATE AND
      (ie_fecha_final >= SYSDATE OR ie_fecha_final IS NULL);

select *
from bintablas
where grupo='OPGET'
AND ARGUMENTO = 'REPORTSERVER'
AND SYSDATE BETWEEN VIG_INICIAL AND NVL(VIG_FINAL,SYSDATE);
--'Parametros archivo favidi'


select *
from rh_personas
where interno_persona in (646,588) --20730522, 52876090
nombres like 'MARGARITA%' --numero_identificacion= 79693028
;

select *
from pr_rubro
where interno = 1547
;



select *
from rh_personas
where numero_identificacion in (51604666);
/*
JF 79355621 65 PUBLICO
SUESCA 52316271 595 PRIVADO
SANDOVAL 1049606827 607 PRIVADO
*/
;

select *
from rh_concepto
where nombre like '%EMBAR%'
;

select * 
from rh_historico_nomina
where dinicioperiodo = 20260301
and nhash in (561030782,2979462679,1190232691,3247840384)
and ncorrida = 1;

   select resultado
                  from bintablas
                  where grupo = 'OPGET'
                  and nombre = 'LIMAY_INGRESO_PORTAL'
                  and argumento ='CENTRO CONTABLE';


select *
from ogt_ingreso 
where num_doc_legalizacion = 55533;                  

select *
from sl_pcp_pago
;
select max(id)

  FROM ogt_ingreso;

  select *
  from rh_personas
  where interno_persona in (624,61) --numero_identificacion = 1049606827
  :

sl_id_tercero_y_centro_costo(
                  373, --mi_rec_cuenta_cobro.codigo_entidad,
                  mi_id_tercero_tac,
                  mi_nit_origen,
                  mi_centro_costo,
                  p_resp
               );

select * --id_limay, nit,id_sisla
        --into p_id_tercero_origen, p_nit_origen,  p_centro_costo
        from sl_relacion_tac
       where codigo_compa = 373 --p_codigo_compa;

select * from ogt_detalle_documento
--update ogt_detalle_documento set ter_id_origen=400210
 where doc_numero||'-'||doc_tipo in (
   select numero ||'-'||tipo
     from ogt_documento
    where numero_legal in (
      select numero
        from ogt_documento
       where tipo = 'ALE'
         --and estado='RE'
         and unte_codigo = 'FINANCIERO'
        --and numero in ( 55503) --, 54861 )
         and numero_externo in ( '2026000057'/*, '2025000003', '2025000012'*/ )
   )
      and tipo = 'XYZ'
)
   and doc_tipo = 'XYZ'       
   and ter_id_origen= 69
   ;


INSERT INTO BINTABLAS (GRUPO,NOMBRE,ARGUMENTO,RESULTADO,VIG_INICIAL)
VALUES ('GENERAL','IDENTIFICACION','TAC','TAC',TO_DATE('01/01/2026','DD/MM/YYYY'));

UPDATE BINTABLAS
SET VIG_INICIAL = '01/JAN/2026'
WHERE GRUPO='GENERAL' AND NOMBRE='IDENTIFICACION' AND ARGUMENTO='TAC';

---commit;


select *
from bintablas
where grupo='NOMINA' AND nombre='NOVEDADPILA'
;

SELECT distinct grupo
FROM bintablas
order by 1
WHERE GRUPO='SISLA';

select *
from binconsecutivo
where grupo = 'SISLA'
AND VIGENCIA=2026;


select *
from bintablas
where grupo = 'NOMINA' and upper(resultado) like '%LIQUIDADOR%' 
-- 'E:\SICAPITAL\PERNO\TEMP\Soporte\'


F:\ERP\RH\LIQUIDADOR\soporte\0000143666
PATH
COMPILADOR

PERSO
E:\SICAPITAL\PERNO\temp;


select * from rh_conceptos;


select * from ogt_Documento

ogt.docu_pk

select *
delete
--from
ogt_documento_pago
where vigencia=2026 
and entidad=206 
and unidad_ejecutora='01'
and tipo_documento='RA'
and consecutivo=2;

commit;



select *  --personas_interno
from rh_funcionario
where personas_interno=33
/*and  codigo_fondo_pensiones <>61
and estado_funcionario =1*/
order by personas_interno asc
;


select TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS')  as fysdate from dual
;

select *
from pr_rubro;

select *
from rh_concepto   
where codigo_hash = 2091789934