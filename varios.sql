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
where numero_identificacion = 79384072 --interno_persona = 578
;


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


    
 cursor reg40(un_nro_ra NUMBER) is
    SELECT 
      '7990990000' cuenta_credito,
      --INI 2025005004 
      --sum(decode(regimen, '3', a.valor,'1',0,'2',0)) 
      sum(nvl(a.valor,0)) valor_rubro,
      --FIN 2025005004 
      --INI 2025004504
      NVL(:B_RA.cta_x_nomina,'5000001965') rp_doc_presupuestal,
      --FIN 2025004504
      decode(c.descripcion,'Sueldo básico','0001',c.codigo_nivel7) posicion_doc_presupuestal
    FROM     rh_t_lm_valores a, rh_lm_cuenta b, pr_v_rubros c
      WHERE tipo_ra             = '1' 
      AND   grupo_ra            = '5'
      AND   scompania           = 206
      AND   stipo_funcionario   = stipofuncionario
      AND   a.sconcepto         = b.sconcepto
      AND   ncierre             = 1
      AND   c.interno_rubro     = b.codigo_presupuesto
      AND   c.vigencia          = extract(year from 2026)
      AND   a.ntipo_nomina      = '0'
      AND   dfecha_inicio_vig   <= '30/APR/2026' 
      AND   (dfecha_final_vig   >= '30/APR/2026'  OR dfecha_final_vig IS NULL) 
      AND   b.codigo_presupuesto IS NOT NULL
      AND   periodo             = '30/APR/2026'   --:P_FECHA_FINAL
      --AND   nro_ra              = un_nro_ra            ---:P_NRORA
      GROUP BY codigo_nivel1,
                          codigo_nivel2,
                          codigo_nivel3,
                          codigo_nivel4,
                          codigo_nivel7,
                          codigo_nivel5 || '-' || codigo_nivel6 || '-' || codigo_nivel7 || '-' || codigo_nivel8,
                          descripcion,
                          interno_rubro
      ORDER BY codigo_nivel5 || '-' || codigo_nivel6 || '-' || codigo_nivel7 || '-' || codigo_nivel8;





grant execute,debug on shd.pk_sit_infentidades to ogt_admin;
grant execute,debug on shd.pk_sit_infbasica to ogt_admin;
grant execute,debug on shd.pk_secuencial to ogt_admin;

select *
from dba_role_privs
where granted_role = 'OGT_ADMIN'

where grantee = 'OGT_ADMIN'
and table_name like 'FN_ACTUALIZA%'
;

select *
from ALL_TAB_PRIVS
where table_schema = 'SL'
and table_name like 'SL_PCP_CUENTA%';


SELECT RTRIM(TO_CHAR(sysdate, 'MONTH', 'NLS_DATE_LANGUAGE = SPANISH')) 
                || ' ' || TO_CHAR(sysdate, 'DD') 
                || ' DE ' || TO_CHAR(sysdate, 'RRRR') resp
    FROM dual;

pk_sl_interfaz_opget_cp.extraer_resumen_cuentas

select *
from sl_pcp_usuarios
;



   SELECT /*c.codigo_nivel1 n1,
    c.codigo_nivel2 n2,
	c.codigo_nivel3 n3,
	c.codigo_nivel4 n4,
    c.codigo_nivel7 n7,*/
    b.sconcepto,
    c.codigo_nivel5 || '-' || c.codigo_nivel6 || '-' || c.codigo_nivel7 || '-' || c.codigo_nivel8 nresto,
	c.descripcion,
    c.interno_rubro,
	-- sum(decode(regimen, '1', a.valor,'2',a.valor,'3',0)) valora,
	-- sum(decode(regimen, '3', a.valor,'1',0,'2',0)) valorn
    sum(a.valor) valor
    -- select *
  FROM     rh_t_lm_valores a, rh_lm_cuenta b, pr_v_rubros c
  WHERE tipo_ra             = '1'           --:P_TIPO_RA
  AND   grupo_ra            = '5'             --:P_GRUPO_RA
  AND   scompania           = 206           --:P_COMPANIA
  AND   stipo_funcionario   = stipofuncionario
  AND   a.sconcepto         = b.sconcepto
  AND   ncierre             = 1
  AND   c.interno_rubro     = b.codigo_presupuesto
  AND   c.vigencia          = 2026        --:P_VIGENCIA
  AND   a.ntipo_nomina      = '0'           --:P_TIPONOMINA
  AND   dfecha_inicio_vig   <= '01-MAY-26'       --:P_FECHA_FINAL
  AND   (dfecha_final_vig   >= '31-MAY-26' /*:P_FECHA_FINAL*/ OR dfecha_final_vig IS NULL) 
  AND   b.codigo_presupuesto IS NOT NULL
  AND   periodo              = to_date('31-MAY-2026','dd/mm/yyyy')   --:P_FECHA_FINAL
  --AND   nro_ra              = 1            ---:P_NRORA
  and interno_rubro=1804
  --AND codigo_nivel1 || '-' || codigo_nivel2 || '-' || codigo_niveL3 || '-' || codigo_nivel4 || '-' ||codigo_nivel5 || '-' || codigo_nivel6 || '-' || codigo_nivel7 || '-' || codigo_nivel8
  ---= '2-1-01-01-0001-01-001-0001-0000000'
   GROUP BY  b.sconcepto, 
            codigo_nivel5 || '-' || codigo_nivel6 || '-' || codigo_nivel7 || '-' || codigo_nivel8,
            descripcion,
            interno_rubro
  --ORDER BY c.codigo_nivel1 ASC, c.codigo_nivel2 ASC, c.codigo_nivel3 ASC, c.codigo_nivel4 ASC, codigo_nivel5 || '-' || codigo_nivel6 || '-' || codigo_nivel7 || '-' || codigo_nivel8 ASC
;


select id, descripcion
    --    into mi_id
        from ogt_concepto_tesoreria
       where descripcion in ('RECAUDO CAPITAL CUOTAS PARTES POR APLICAR FIDUDAVIVIENDA',
       'RECAUDO INTERESES CUOTAS PARTES POR APLICAR FIDUDAVIVIENDA',
       'CAUSACION INTERESES CUOTAS PARTES POR APLICAR FIDUDAVIVIENDA');



mi_concepto_capital := fn_ogt_traer_code_concepto('RECAUDO CAPITAL CUOTAS PARTES POR APLICAR FIDUDAVIVIENDA');
mi_concepto_interes := fn_ogt_traer_code_concepto('RECAUDO INTERESES CUOTAS PARTES POR APLICAR FIDUDAVIVIENDA');
      --00-02-37-19-00-00-00
mi_concepto_causa_interes := fn_ogt_traer_code_concepto('CAUSACION INTERESES CUOTAS PARTES POR APLICAR FIDUDAVIVIENDA');
    