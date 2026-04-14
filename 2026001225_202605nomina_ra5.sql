/*
ppto 987.987.745
rh   915.200.640,01
*/

--CURSOR cur_distribucion IS
	SELECT NVL(SUM(valor),0)
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
    AND   b.codigo_presupuesto IS NOT NULL;


--Modificado para revisar
    SELECT --a.sconcepto, NVL(SUM(valor),0) valor
    --a.sconcepto, 
    c.descripcion, 
    b.codigo_presupuesto, NVL(SUM(valor),0) valor
    --a.sconcepto, b.codigo_presupuesto, c.descripcion 
    FROM  rh_t_lm_valores a, rh_lm_cuenta b, pr_v_rubros c
    WHERE b.stipo_funcionario = a.stipofuncionario
    AND   b.sconcepto         = a.sconcepto
    AND   c.interno_rubro     = b.codigo_presupuesto
    AND   c.vigencia          = 2026 --una_vigencia
    AND   a.periodo           = '31-MAR-2026' --una_fecha_final
    AND   a.ntipo_nomina      = 0   --un_tipo_nomina
    AND   a.nro_ra            = 5   --un_nro_ra
    AND   b.scompania         = 206 --una_compania
    AND   b.tipo_ra           = 1   --un_tipo_ra
    AND   b.grupo_ra          = '5'   --un_grupo_ra
    AND   b.ncierre           = 1
    -- RQ2523-2005   05/12/2005
    AND   b.dfecha_inicio_vig <= '31-MAR-2026'
    AND  (b.dfecha_final_vig  >= '31-MAR-2026' OR b.dfecha_final_vig IS NULL)
    --and codigo_presupuesto = 1396
    -- Fin RQ2523
    AND   b.codigo_presupuesto IS not NULL
    group by --a.sconcepto --,
        c.descripcion, b.codigo_presupuesto
   order by 1
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
   order by 1
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
--and descripcion like 'Indemni%'
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


select *
from bintablas
where grupo='NOMINA'
and nombre = 'T_NOMBRAMIENTO'
and resultado like '%LIBRE%';

select *
from bintablas
where grupo='NOMINA'
and nombre = 'T_FUNCIONARIO'
and resultadO like '%PLANTA%';