--RHLM_RA_NOMINA
SELECT --/*
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
    SUM(decode(regimen,'3',a.valor,'1',0,'2',0))       valorn
     --*/
--select distinct c.descripcion --*
FROM rh_t_lm_valores  a, rh_lm_cuenta     b ,  pr_v_rubros  c,
    rh_personas p
WHERE p.interno_persona = a.nfuncionario
    AND  b.tipo_ra = 1 --:p_tipo_ra
    AND b.grupo_ra = '9' --P_GRUPO_RA
    AND b.scompania = 102 --P_COMPANIA
    AND b.stipo_funcionario = a.stipofuncionario
   -- and nfuncionario in (609,877,3153)
    AND a.sconcepto = b.sconcepto
    AND b.ncierre = 1
    AND c.interno_rubro = b.codigo_presupuesto
    AND c.vigencia = 2026 --:p_vigencia --2021 --P_VIGENCIA */
    AND a.ntipo_nomina = 1 --P_TIPONOMINA
    AND dfecha_inicio_vig <= to_date('30-04-2026','DD-MM-YYYY')
    AND ( dfecha_final_vig >= to_date('30-04-2026','DD-MM-YYYY')
       OR dfecha_final_vig IS NULL )
    AND b.codigo_presupuesto IS NOT NULL
    AND a.periodo = to_date('30-04-2026','DD-MM-YYYY')
  --and interno_rubro=23277
 -- AND        nro_ra            = :P_NRORA
GROUP BY c.descripcion,
    codigo_nivel1, codigo_nivel2, codigo_nivel3, codigo_nivel4,
    codigo_nivel5||'-'||codigo_nivel6||'-'||codigo_nivel7||'-'||codigo_nivel8,
    descripcion, interno_rubro, b.sconcepto
ORDER BY 2, 3, 4, 5
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
  order by /*n1,n2,n3,n4,*/ nresto                      
