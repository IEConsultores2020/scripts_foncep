--RHLM_RA_NOMINA
SELECT --/*
    b.tipo_ra,
    a.ntipo_nomina,
    a.nro_ra,
    b.dfecha_inicio_vig,
    b.dfecha_final_vig,
    c.descripcion,
    a.sconcepto,
    c.codigo_nivel1    n1, c.codigo_nivel2    n2, c.codigo_nivel3    n3,
    c.codigo_nivel4    n4,
    codigo_nivel5||'-'||codigo_nivel6||'-'||codigo_nivel7||'-'|| codigo_nivel8
                                                       nresto, --*/
    SUM(decode(regimen,'1',a.valor,'2',a.valor,'3',0)) valora,
    SUM(decode(regimen,'3',a.valor,'1',0,'2',0))       valorn
     --*/
-- select c.*
FROM rh_t_lm_valores  a, rh_lm_cuenta     b ,  pr_v_rubros  c,
    rh_personas p
WHERE p.interno_persona = a.nfuncionario
   -- AND  b.tipo_ra      = 0 --:p_tipo_ra
    AND b.grupo_ra      = '5' --P_GRUPO_RA
    AND b.scompania     = 206 --P_COMPANIA
    AND b.stipo_funcionario = a.stipofuncionario
    AND a.sconcepto     = b.sconcepto
    --INI CUD
    --AND a.sconcepto in ('APORTEPENSION','APORTESALUD','APORTEFONDOGARANTIA','APORTEREGIMENSOLIDARIDAD')
    --FIN CUD
    AND b.ncierre       = 1
    AND c.interno_rubro = b.codigo_presupuesto
    AND c.vigencia      = 2026 --:p_vigencia --2021 
    AND a.ntipo_nomina  = 0 --P_TIPONOMINA
    --AND b.dfecha_inicio_vig <= to_date('01-04-2026','DD-MM-YYYY')
    --AND ( b.dfecha_final_vig >= to_date('30-04-2026','DD-MM-YYYY')
    --   OR b.dfecha_final_vig IS NULL )
    AND b.codigo_presupuesto IS NOT NULL
    and extract(year from a.periodo)=2026
    --AND a.periodo       = to_date('30-04-2026','DD-MM-YYYY')
  --and interno_rubro=23277
 -- and a.nro_ra = 9 --:P_NRORA
 -- order by a.sconcepto
GROUP BY b.tipo_ra, a.ntipo_nomina, a.nro_ra, b.dfecha_inicio_vig, b.dfecha_final_vig,
  c.descripcion,
    codigo_nivel1, codigo_nivel2, codigo_nivel3, codigo_nivel4,
    codigo_nivel5||'-'||codigo_nivel6||'-'||codigo_nivel7||'-'||codigo_nivel8,
    descripcion, interno_rubro, a.sconcepto
ORDER BY 1,2, 3, 4, 5, 6, 7, 8, 9, 10, 11
--*/
;

select *
from rh_lm_cuenta C, RH_LM_CENTROS_COSTO CC
where sconcepto like '%CESANTIAS%'
AND C.CC = CC.CODIGO
ORDER BY CODIGO_PRESUPUESTO

;

select *
from pr_v_rubros      c
where vigencia=2026
;

----VERSION CON TODOS LOS PARAMETROS
SELECT periodo, /*c.codigo_nivel1 n1,
                 c.codigo_nivel2 n2,
	 c.codigo_nivel3 n3,
	 c.codigo_nivel4 n4,*/
                 codigo_nivel5 || '-' || codigo_nivel6 || '-' || codigo_nivel7 || '-' || codigo_nivel8 nresto,
	 c.descripcion,
                 c.interno_rubro,
	 sum(decode(regimen, '1', a.valor,'2',a.valor,'3',0)) valora,
	 sum(decode(regimen, '3', a.valor,'1',0,'2',0)) valorn,
      sum(decode(regimen, '1', a.valor,'2',a.valor,'3',0)) + sum(decode(regimen, '3', a.valor,'1',0,'2',0))  total
  FROM   rh_t_lm_valores a, rh_lm_cuenta b, pr_v_rubros c
  WHERE  tipo_ra                   = :P_TIPO_RA
  AND        grupo_ra              = :P_GRUPO_RA
  AND        scompania             = :P_COMPANIA
  AND        stipo_funcionario     = stipofuncionario
  AND        a.sconcepto           = b.sconcepto
  AND        ncierre               = 1
  AND        c.interno_rubro       = b.codigo_presupuesto
  AND        c.vigencia            = :P_VIGENCIA
  AND        a.ntipo_nomina        = :P_TIPONOMINA
  AND        dfecha_inicio_vig <= TO_DATE(:P_FECHA_FINAL,'YYYYMMDD')
  AND       (dfecha_final_vig  >= TO_DATE(:P_FECHA_FINAL,'YYYYMMDD') /*:P_FECHA_FINAL*/ OR dfecha_final_vig IS NULL)
  AND        b.codigo_presupuesto IS NOT NULL
  AND        periodo           = TO_DATE(:P_FECHA_FINAL,'YYYYMMDD') --:P_FECHA_FINAL
  AND        nro_ra            = :P_NRORA
  GROUP BY periodo,codigo_nivel1,
                      codigo_nivel2,
                      codigo_nivel3,
                      codigo_nivel4,
                      codigo_nivel5 || '-' || codigo_nivel6 || '-' || codigo_nivel7 || '-' || codigo_nivel8,
                      descripcion,
                      interno_rubro
  order by n1,n2,n3,n4, nresto                      
;
--nomina
select /*sconcepto,*/ sum(valor)
from rh_t_lm_valores a
where a.ntipo_nomina = 0 --0 normal, 1 adicional
  and a.periodo = to_date('30-04-2026','DD-MM-YYYY')
  --and interno_rubro=23277
  and sconcepto in ('APORTEPENSION','APORTESALUD','APORTEFONDOGARANTIA','APORTEREGIMENSOLIDARIDAD')
 and        nro_ra            = 7
 group by sconcepto;
 --71101356