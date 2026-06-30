   -- Esta consulta es usada para cargar datos en archivo excel control_presupuestal
   SELECT 'FCP' fuente,
    b.tipo_ra,
    a.ntipo_nomina,
    a.nro_ra,
    a.periodo, 
    null   cdp,
    null   rp,
    dfecha_inicio_vig,
    dfecha_final_vig,
    c.descripcion,
    c.interno_rubro,
    c.codigo_nivel1 n1,
    c.codigo_nivel2 n2,
	c.codigo_nivel3 n3,
	c.codigo_nivel4 n4,
    c.codigo_nivel7 n7,
    c.codigo_nivel5 || '-' || c.codigo_nivel6 || '-' || c.codigo_nivel7 || '-' || c.codigo_nivel8 nresto,
	sum(decode(regimen, '1', a.valor,'2',a.valor,'3',0)) valora,
	sum(decode(regimen, '3', a.valor,'1',0,'2',0)) valorn,
    sum(a.valor) valor
    -- select distinct c.* -- DESCRIPCION, INTERNO_RUBRO, TIPO_PLAN
  FROM     rh_t_lm_valores a, rh_lm_cuenta b, pr_v_rubros c
  WHERE b.tipo_ra             = '1'           --:P_TIPO_RA  1 nomina 2 aportes
  AND   b.grupo_ra            = '5'             --:P_GRUPO_RA
  AND   b.scompania           = 206           --:P_COMPANIA
  AND   b.stipo_funcionario   = stipofuncionario
  AND   a.sconcepto         = b.sconcepto
  AND   b.ncierre             = 1
  AND   c.interno_rubro     = b.codigo_presupuesto
  AND   c.vigencia          = 2026        --:P_VIGENCIA
  AND   a.ntipo_nomina      = '0'           --:P_TIPONOMINA
  AND   dfecha_inicio_vig   <= '01-MAY-26'       --:P_FECHA_FINAL
  AND   (dfecha_final_vig   >= '31-MAY-26' /*:P_FECHA_FINAL*/ OR dfecha_final_vig IS NULL) 
  AND   b.codigo_presupuesto IS NOT NULL
  AND   a.periodo              = to_date('31-MAY-2026','dd/mm/yyyy')   --:P_FECHA_FINAL
  --AND   a.nro_ra              = 12            ---:P_NRORA
  GROUP BY  b.tipo_ra,   a.nro_ra,  a.periodo,          dfecha_inicio_vig,  dfecha_final_vig,   a.ntipo_nomina,
            c.codigo_nivel1,        c.codigo_nivel2,    c.codigo_nivel3,    c.codigo_nivel4,    c.codigo_nivel7,
            c.codigo_nivel5 || '-' || c.codigo_nivel6 || '-' || c.codigo_nivel7 || '-' || c.codigo_nivel8,
            descripcion, interno_rubro
  ORDER BY c.codigo_nivel1 ASC, c.codigo_nivel2 ASC, c.codigo_nivel3 ASC, c.codigo_nivel4 ASC, codigo_nivel5 || '-' || codigo_nivel6 || '-' || codigo_nivel7 || '-' || codigo_nivel8 ASC
;

SELECT * FROM --rh_lm_cuenta
pr_v_rubros
where vigencia = 2025
minus
SELECT * FROM --rh_lm_cuenta
pr_v_rubros
where vigencia = 2026
and tipo_plan ='PLAN_ADMONCENTRAL'


select *
from pr_nivel_7
where vigencia=2025;


