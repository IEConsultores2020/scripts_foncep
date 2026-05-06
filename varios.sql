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

select *
from RH_PERSONAS
where interno_persona = 52


select * from rh_maestro_personas
where nfuncionario in 
(select * --interno_persona, numero_identificacion, nombres, primer_apellido, segundo_apellido
 from rh_personas
--where nombres ='DIANA MARCELA' and primer_apellido='SANABRIA'
where --numero_identificacion in (52116283)) --651, 652
--or 
interno_persona IN (519,614)   --  20730522
--649 --1030575813
;


SELECT *
FROM shd_informacion_entidades
      WHERE id = 51 AND ie_fecha_inicial <= SYSDATE AND
      (ie_fecha_final >= SYSDATE OR ie_fecha_final IS NULL);

select *
from bintablas
where grupo='OPGET'
AND ARGUMENTO = 'INDICATIVO_VALIDA_PAC' --'VALIDA_PAC'
AND SYSDATE BETWEEN VIG_INICIAL AND NVL(VIG_FINAL,SYSDATE);
--'Parametros archivo favidi'


select *
from rh_personas
where interno_persona in (11) --20730522, 52876090
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
where nombre like '%PAGO  APORTE CAJA DE COMPENSACION FAMILIAR%'
;
select hn.*
from 
--delete 
rh_historico_nomina hn
where hn.nfuncionario=633
and nhash like '1994%'
and hn.dinicioperiodo = 20260401
and sproceso = 'NEWNOVELTIES'
and hn.ncorrida=1   1994
;

commit

select *
from rh_novedad
;



select *
from rh_concepto
where nombre like '%VACACIONES%' and codigo_hash  in (335110026, 726156787,942401950)  --= 1128917309
;

select c.nombre, hn.*
from rh_historico_nomina hn, rh_concepto c
where hn.nfuncionario=633
and hn.dinicioperiodo = 20260401
and hn.ncorrida=1
and hn.nhash = c.codigo_hash
--nhash 3168394695
;

select *
from rh_actos_administrativos
where funcionario = 633
;

select *
from rh_movimientos_planta
where funcionario=633
;

--commit

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

select *


select *  --personas_interno
from rh_funcionario
where personas_interno=613
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
;

SELECT
    a.stercero,
    SUM(valor) valor,
    SUM(valor_saldo) valor_saldo
FROM
    rh_t_lm_valores a,
    rh_lm_cuenta b,
    rh_lm_centros_costo c
WHERE
    b.stipo_funcionario = a.stipofuncionario
    AND b.sconcepto = a.sconcepto
    AND b.cc = c.codigo
    AND a.periodo = TO_DATE(
        '30-04-2026 12:00:00 AM',
        'DD-MM-YYYY HH:MI:SS AM'
    )
    AND a.ntipo_nomina = 1
    AND a.sdevengado IN (0, 1)
    AND c.codigo not IN (2, 3, 4)
    AND a.nro_ra = 10
    AND b.scompania = '206'
    AND b.tipo_ra = '1'
    AND b.grupo_ra IN ('5')
    AND b.ncierre = 1
    AND b.dfecha_inicio_vig <= TO_DATE(
        '30-04-2026 12:00:00 AM',
        'DD-MM-YYYY HH:MI:SS AM'
    )
    AND (
        b.dfecha_final_vig >= TO_DATE(
            '30-04-2026 12:00:00 AM',
            'DD-MM-YYYY HH:MI:SS AM'
        )
        OR b.dfecha_final_vig IS NULL
    )
    AND b.cc = 5
GROUP BY
    a.stercero;


    select *
    from rh_concepto
    where nombre_corto like '%ICBF%' --121290711
    ;

    select *
    from rh_tipos_acto_nove
    where nombre = 'INFO_PLANILLA_ENTIDAD' --854032720
    --'INFOAPORTEPARAF' --543977345

    select *
    from rh_historico_nomina
    where nhash=543977345 and dinicioperiodo>=20260101 and dfinalperiodo<=20260131
    and nfuncionario=33
    ;


    select *
    from rh_historico_nomina_hoy
    where nhash=854032720 and dinicioperiodo>=20260101 and dfinalperiodo<=20260131
    and nfuncionario=52
    order by dfecharegistro desc
    ;
    
    select nfuncionario, count(1)
    from rh_historico_nomina_hoy
    where nhash=854032720 and dinicioperiodo>=20260101 and dfinalperiodo<=20260131
    group by nfuncionario
    having count(1)>2
    ;