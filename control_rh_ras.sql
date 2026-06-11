--RHLM_RA_NOMINA
SELECT --/*
    'FCP' fuente,
    b.tipo_ra,
    a.ntipo_nomina,
    a.nro_ra,
    a.periodo,
    b.dfecha_inicio_vig,
    b.dfecha_final_vig,
    c.descripcion,
    c.codigo_nivel1    n1, c.codigo_nivel2    n2, c.codigo_nivel3    n3,
    c.codigo_nivel4    n4,
    codigo_nivel5||'-'||codigo_nivel6||'-'||codigo_nivel7||'-'|| codigo_nivel8
                                                       nresto, --*/
    /*
    a.nfuncionario,
    p.tipo_documento, p.numero_identificacion,
    c.descripcion, c.interno_rubro, b.sconcepto,
    --a.valor, -- */
    SUM(decode(regimen,'1',a.valor,'2',a.valor,'3',0)) valora,
    SUM(decode(regimen,'3',a.valor,'1',0,'2',0))       valorn,
    SUM(a.valor)                                valor
     --*/
-- select A.*
FROM rh_t_lm_valores  a, rh_lm_cuenta     b ,  pr_v_rubros  c,
    rh_personas p
WHERE p.interno_persona = a.nfuncionario
   -- AND  b.tipo_ra      = 1 --:p_tipo_ra
   -- AND b.grupo_ra      = '5' --P_GRUPO_RA
    AND b.scompania     = 206 --P_COMPANIA
    AND b.stipo_funcionario = a.stipofuncionario
    AND a.sconcepto     = b.sconcepto
    --INI CUD
    --AND a.sconcepto in ('APORTEPENSION','APORTESALUD','APORTEFONDOGARANTIA','APORTEREGIMENSOLIDARIDAD')
    --FIN CUD
    AND b.ncierre       = 1
    AND c.interno_rubro = b.codigo_presupuesto
    AND c.vigencia      = 2026 --:p_vigencia --2021 
    --AND a.ntipo_nomina  = 1 --P_TIPONOMINA
    --AND b.dfecha_inicio_vig <= to_date('01-04-2026','DD-MM-YYYY')
    --AND ( b.dfecha_final_vig >= to_date('30-04-2026','DD-MM-YYYY')
    --   OR b.dfecha_final_vig IS NULL )
    AND b.codigo_presupuesto IS NOT NULL
    and extract(year from a.periodo)=2026
    --AND a.periodo       = to_date('30-04-2026','DD-MM-YYYY')
  --and interno_rubro=23277
  and a.nro_ra = 7 --NOT IN (2,4,8,9,10,12) --:P_NRORA
  --order by 1 desc
GROUP BY b.tipo_ra, a.ntipo_nomina, a.nro_ra, a.periodo, b.dfecha_inicio_vig, b.dfecha_final_vig,
  c.descripcion,
    codigo_nivel1, codigo_nivel2, codigo_nivel3, codigo_nivel4,
    codigo_nivel5||'-'||codigo_nivel6||'-'||codigo_nivel7||'-'||codigo_nivel8,
    descripcion, interno_rubro, b.sconcepto
ORDER BY 1,2, 3, 4, 5, 6, 7, 8, 9, 10, 11,12
--*/
;


