/*
ppto 987.987.745
rh   915.200.640,01
*/

--CURSOR cur_distribucion IS
	SELECT * -- NVL(SUM(valor),0)
    FROM  rh_t_lm_valores a, rh_lm_cuenta b, pr_v_rubros c
    WHERE b.stipo_funcionario = a.stipofuncionario
    AND   b.sconcepto         = a.sconcepto
    AND   c.interno_rubro     = b.codigo_presupuesto
    AND   c.vigencia          = 2026
    AND   a.periodo           = '31-MAR-2026'
    AND   a.ntipo_nomina      = 0
    AND   a.nro_ra            = 5
    AND   b.scompania         = 206
    AND   b.tipo_ra           = 1
    AND   b.grupo_ra          = '5'
    AND   b.ncierre           = 1
    AND   b.dfecha_inicio_vig <= '31-MAR-2026'
    AND  (b.dfecha_final_vig  >= '31-MAR-2026' OR b.dfecha_final_vig IS NULL)
    AND   b.codigo_presupuesto IS NOT NULL
    AND  c.interno_rubro=1396;


--Modificado para revisar
    SELECT --a.sconcepto, NVL(SUM(valor),0) valor
    a.sconcepto, c.descripcion,
    b.codigo_presupuesto, NVL(SUM(valor),0) valor
    --a.sconcepto, b.codigo_presupuesto, c.descripcion
    --SELECT *
    FROM  rh_t_lm_valores a, rh_lm_cuenta b, pr_v_rubros c
    WHERE b.stipo_funcionario = a.stipofuncionario
    AND   b.sconcepto         = a.sconcepto
    AND   c.interno_rubro     = b.codigo_presupuesto
    --and c.interno_rubro = 1396
    and   c.vigencia          = 2026 --una_vigencia
    and EXTRACT(MONTH FROM periodo) = 3 --un_mes
    AND EXTRACT(YEAR FROM periodo) = 2026 --un_mes
    AND   a.periodo           = TO_DATE('31/03/2026', 'DD/MM/YYYY') --una_fecha_final
    AND   a.ntipo_nomina      = 0   --un_tipo_nomina
  --  AND   a.nro_ra            = 16   --un_nro_ra
    AND   b.scompania         = 206 --una_compania
    AND   b.tipo_ra           = 1   --un_tipo_ra
    AND   b.grupo_ra          = '5'   --un_grupo_ra
   -- AND   b.ncierre           = 1
    -- RQ2523-2005   05/12/2005
    AND   b.dfecha_inicio_vig <= TO_DATE('31/03/2026', 'DD/MM/YYYY') 
    AND  (b.dfecha_final_vig  >= TO_DATE('31/03/2026', 'DD/MM/YYYY') OR b.dfecha_final_vig IS NULL)
    -- Fin RQ2523
    AND   b.codigo_presupuesto IS not NULL
    group by a.sconcepto, c.descripcion,
     b.codigo_presupuesto
   order by 1
   ;

   select *
   from pr_v_rubros
    where vigencia = 2026
    and interno_rubro =1396
    ;


    --Modificado sin código de presupuesto.
    SELECT --a.sconcepto, 
    b.codigo_presupuesto, NVL(SUM(valor),0) valor
    FROM  rh_t_lm_valores a, rh_lm_cuenta b
    WHERE b.stipo_funcionario = a.stipofuncionario
    AND   b.sconcepto         = a.sconcepto
    AND   a.periodo           = '31-MAR-2026' --una_fecha_final
    AND   a.ntipo_nomina      = 0   --un_tipo_nomina
    AND   a.nro_ra            = 5   --un_nro_ra
    AND   b.scompania         = 206 --una_compania
    AND   b.tipo_ra           = 1   --un_tipo_ra
    AND   b.grupo_ra          = '5'   --un_grupo_ra
    AND   b.ncierre           = 1
    AND   b.dfecha_inicio_vig <= '31-MAR-2026'
    AND  (b.dfecha_final_vig  >= '31-MAR-2026' OR b.dfecha_final_vig IS NULL)
    AND   b.codigo_presupuesto IS not NULL
    --and codigo_presupuesto = 1804
    and a.sconcepto <> 'VACACIONESDINERO' --'DIAS_LICENCIA'
    group by --a.sconcepto, 
    b.codigo_presupuesto
   order by 2
   ;

    select *
    from rh_lm_cuenta
    where sconcepto = 'DIAS_VACACIONES' --'DIAS_LICENCIA' 
    /*in ('SCONCEPTO','APORTEFONDOGARANTIA','APORTEREGIMENSOLIDARIDAD',
    'CAPORTEAFC','CAPORTEAFP','CAPORTES','CEMBARGO','CEMBARGOCIVIL','CLIBRANZA',
    'CPLANCOMPLEMENTARIO','CSINDICATO','RETENCIONFUENTE')*/
;


--Consulta el RP
select c.descripcion, r.rubro_interno, r.valor
from pr_registro_disponibilidad r, pr_v_rubros c
where r.vigencia=2026
and r.codigo_compania=206
and r.codigo_unidad_ejecutora='01'
and r.numero_disponibilidad=39
and r.numero_registro = 239
and c.vigencia=r.vigencia
and c.interno_rubro=r.rubro_interno;

select * 
from pr_v_rubros
where vigencia >= 2025
and descripcion like 'Indemni%'
and interno_rubro in (1396,1804)
;

select *
from rh_lm_cuenta
where scompania=206
and stipo_funcionario='PLANTA'
--and codigo_presupuesto is null order by 3
and sconcepto='VACACIONESDINERO' ; --'DIAS_LICENCIA';

select *
from rh_t_lm_valores
where periodo='31-MAR-2026'
and abs(valor) =101929

----Valida PAC
select distinct vigencia --sum (nvl (valor, 0))
           from pac_distribucion_pac
          where codigo_compania = 206 --una_compania
            and codigo_unidad_ejecutora = '01' --una_unidad
            and mes = 3 --un_mes
            and vigencia = 2026 --una_vigencia
            and interno = un_interno;

select *
from ogt_centro_costos
where entidad=206
and unidad_ejecutora='01'
and tipo_documento='RA'
and tipo_ra=1
and mes=3
and vigencia=2026
and consecutivo=5
;

select *
from ogt_anexo_nomina
where entidad=206
and unidad_ejecutora='01'
and tipo_documento='RA'
and tipo_ra=1
and mes=3
and vigencia=2026
and consecutivo=5
;

select vigencia, mes, consecutivo, oficina_destino, length(oficina_destino)
from ogt_anexo_embargo
where entidad=206
and unidad_ejecutora='01'
and tipo_documento='RA'
and tipo_ra=1
and vigencia=2025
and mes=6
--and consecutivo=5
order by 1,2,3,4
;

select aa.*
from ogt_centro_costos cc, ogt_anexo_nomina aa
where cc.entidad=206
and cc.unidad_ejecutora='01'
and cc.tipo_documento='RA'
and cc.tipo_ra=1
and cc.mes=3
and cc.vigencia=2026
and cc.consecutivo=5
and cc.entidad=206
and cc.unidad_ejecutora =   aa.unidad_ejecutora
and cc.tipo_documento   =   aa.tipo_documento
and cc.tipo_ra          =   aa.tipo_ra
and cc.mes              =   aa.mes
and cc.vigencia         =   aa.vigencia
and cc.consecutivo      =   aa.consecutivo;

select *
from rh_concepto
where nombre like '%EMBARGO%'
;

select * 
from rh_historico_nomina
where dinicioperiodo like '2025%' and nhash in
(561030782,
2979462679,
1190232691,
3247840384)
AND nfuncionario not in (646,588)
;--internos 646, 588

select *
from rh_personas where interno_persona in (646, 588,573)
--52876090, 20730522, 79837126
;

select *
  from ogt_imputacion ogti
 where ogti.unidad_ejecutora = '01'	--UNA_UNIDAD
   and ogti.entidad = '206'	--UNA_ENTIDAD
   and ogti.ano_pac = 2026    --UNA_VIGENCIA_PAC
   and ogti.mes_pac = 3      --UN_MES_PAC
   and ogti.rubro_interno = 1804; --UN_RUBRO
   ;

   select *
   from pr_v_rubros
   where vigencia = 2026
    and interno_rubro = 1843
    ;

select * from 
--update 
ogt_relacion_autorizacion  
set estado =  '00000000001'      
where vigencia=2026
and tipo_ra = 1
and consecutivo= 5 
and fecha_desde = '01-MAR-2026';

-- commit;
		--CURSOR  C_RUBROS_RA IS
		SELECT * -- distinct R.DESCRIPCION        DESCRIPCION_RUBRO
     /*     ,O.RUBRO_INTERNO      RUBRO
					,O.MES_PAC            MES
					,O.ANO_PAC            ANO
		      ,O.DISPONIBILIDAD     DISPONIBILIDAD
		      ,P.REGISTRO           REGISTRO
          ,O.VALOR_BRUTO        VALOR_BRUTO
          ,PK_PAC.FN_PAC_DESP_VALOR_MES(O.ENTIDAD, O.UNIDAD_EJECUTORA, O.VIGENCIA, O.CONSECUTIVO, O.RUBRO_INTERNO) VALOR*/
    FROM   OGT_IMPUTACION       		O
    JOIN OGT_REGISTRO_PRESUPUESTAL	P
    ON  P.DISPONIBILIDAD     = O.DISPONIBILIDAD
    AND    P.ENTIDAD            = O.ENTIDAD
    AND    P.UNIDAD_EJECUTORA   = O.UNIDAD_EJECUTORA
    AND    P.VIGENCIA           = O.VIGENCIA
    AND    P.CONSECUTIVO        = O.CONSECUTIVO
    AND    P.RUBRO_INTERNO      = O.RUBRO_INTERNO    
    JOIN PR_V_RUBROS			R
    ON R.INTERNO_RUBRO      = O.RUBRO_INTERNO
    AND R.VIGENCIA          = O.VIGENCIA
    WHERE  O.TIPO_DOCUMENTO     = 'RA'  --MI_CON_TIPO_DOCUMENTO
    AND    O.ENTIDAD            = 206 --UNA_ENTIDAD
    AND    O.UNIDAD_EJECUTORA   = '01' --UNA_UNIDAD
    AND    O.VIGENCIA           = 2024 --UNA_VIGENCIA
    AND    O.VIGENCIA_PRESUPUESTO = 2024
    AND    O.MES_PAC=12
    AND    O.CONSECUTIVO = 31
   -- AND p.rubro_interno = 1396
    order by 1
  --  AND    O.CONSECUTIVO        = 5 --UN_CONSECUTIVO_RA
    ;

--PK_PAC.FN_PAC_DESP_VALOR_MES
select distinct vigencia --sum(nvl( valor,0))
  --into valor_mes
  from pac_distribucion_pac
 where codigo_compania = 206            --una_compania
   and codigo_unidad_ejecutora = '01'   --una_unidad
   and vigencia = 2011                 -- una_vigencia
   and mes = 5                          -- un_mes
   and interno --= 1831                  --un_interno
   in (1804,
1821,
1822,
1823,
1824,
1825,
1826,
1827,
1828,
1829,
1830,
1835,
1841,
1842,
1843)
   ;


   MI_INDICATIVO_VALIDA_PREDIS := PK_OGT_OP.FN_OGT_VALOR_BINTABLAS
                                     ('OPGET'
                                     ,'VALIDA_PREDIS'
                                     ,'INDICATIVO_VALIDA_PREDIS'
                                     ,SYSDATE);
   MI_INDICATIVO_VALIDA_PAC := PK_OGT_OP.FN_OGT_VALOR_BINTABLAS
                                     ('OPGET'
                                     ,'VALIDA_PAC'
                                     ,'INDICATIVO_VALIDA_PAC'
                                     ,SYSDATE);

select * --sum(valor_registro)
from ogt_registro_presupuestal           
where entidad=206
and unidad_ejecutora='01'
and tipo_documento='RA'
and disponibilidad = 39
and vigencia_presupuesto=2026
and consecutivo=5
and rubro_interno=1396
order by valor_registro
;
--978885816

select * --codigo_centro_costos, valor
from ogt_centro_costos
where entidad=206
and consecutivo=5
and tipo_ra=1
and tipo_documento='RA'
and unidad_ejecutora='01'
and mes = 3
and vigencia = 2026
order by valor
;
--987987745

select *
from rh_lm_ra_cc_ogt
where ra=1
and grupo_ra='5'
and cc=140;

select *
from rh_lm_cuenta
where scompania=206
and codigo_presupuesto=1396
and cc in  (320,140)
and stipo_funcionario='PLANTA'
and sconcepto='%VAC%';


select *
from rh_lm_centros_costo
where codigo in (320,140)

;



 --CURSOR c_imputacion IS
    SELECT a.ano_pac,
           a.mes_pac,
           b.interno_rubro,
           b.disponibilidad,
           b.valor_bruto,
           b.registro_presupuestal,
           b.valor_rp,
           a.ntipo_nomina
    FROM   rh_lm_ra a, rh_lm_ra_presupuesto b
    WHERE  a.scompania              = b.compania
    AND    a.vigencia               = b.vigencia
    AND    a.vigencia_presupuesto   = b.vigencia_presupuesto
    AND    a.unidad_ejecutora       = b.unidad_ejecutora
    AND    a.nro_ra                 = b.nro_ra
    AND    a.scompania              = 206
    AND    a.vigencia               = 2024
    AND    a.vigencia_presupuesto   = 2024
    AND    a.unidad_ejecutora       = '01'
   -- AND    a.nro_ra                 = 16
    AND    a.tipo_ra                = 1
    AND    a.grupo_ra               = 5
    AND    a.ntipo_nomina           = 0
    AND    a.dfecha_inicial_periodo = '01/DEC/2024'
    AND    a.dfecha_final_periodo   = '31/DEC/2024';
    
select *
from rh_lm_ra_presupuesto
where vigencia               = 2026
and registro_presupuestal = 239
and disponibilidad=39
;

select *
from pr_v_rubros
where interno_rubro in (1396)