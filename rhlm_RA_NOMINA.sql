   SELECT c.codigo_nivel1 n1,
    c.codigo_nivel2 n2,
	c.codigo_nivel3 n3,
	c.codigo_nivel4 n4,
    c.codigo_nivel7 n7,
    c.codigo_nivel5 || '-' || c.codigo_nivel6 || '-' || c.codigo_nivel7 || '-' || c.codigo_nivel8 nresto,
	c.descripcion,
    c.interno_rubro,
	 sum(decode(regimen, '1', a.valor,'2',a.valor,'3',0)) valora,
	 sum(decode(regimen, '3', a.valor,'1',0,'2',0)) valorn
     select distinct c.* -- DESCRIPCION, INTERNO_RUBRO, TIPO_PLAN
  FROM     rh_t_lm_valores a, rh_lm_cuenta b, pr_v_rubros c
  WHERE tipo_ra             = '1'           --:P_TIPO_RA
  AND   grupo_ra            = '5'             --:P_GRUPO_RA
  AND   scompania           = 206           --:P_COMPANIA
  AND   stipo_funcionario   = stipofuncionario
  AND   a.sconcepto         = b.sconcepto
  AND   ncierre             = 1
  AND   c.interno_rubro     = b.codigo_presupuesto
  AND   c.vigencia          = 2025        --:P_VIGENCIA
  AND   a.ntipo_nomina      = '0'           --:P_TIPONOMINA
  AND   dfecha_inicio_vig   <= '01-JAN-25'       --:P_FECHA_FINAL
  AND   (dfecha_final_vig   >= '31-DEC-25' /*:P_FECHA_FINAL*/ OR dfecha_final_vig IS NULL) 
  AND   b.codigo_presupuesto IS NOT NULL
  AND   periodo              = to_date('31-12-2025','dd/mm/yyyy')   --:P_FECHA_FINAL
  --AND   nro_ra              = 1            ---:P_NRORA
  GROUP BY codigo_nivel1,
                      codigo_nivel2,
                      codigo_nivel3,
                      codigo_nivel4,
                      codigo_nivel7,
                      codigo_nivel5 || '-' || codigo_nivel6 || '-' || codigo_nivel7 || '-' || codigo_nivel8,
                      descripcion,
                      interno_rubro
  ORDER BY c.codigo_nivel1 ASC, c.codigo_nivel2 ASC, c.codigo_nivel3 ASC, c.codigo_nivel4 ASC, codigo_nivel5 || '-' || codigo_nivel6 || '-' || codigo_nivel7 || '-' || codigo_nivel8 ASC


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
where vigencia=2025