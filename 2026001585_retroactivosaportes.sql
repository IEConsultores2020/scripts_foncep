SELECT  periodo, 
        codigo_nivel5 || '-' || codigo_nivel6 || '-' || codigo_nivel7 || '-' || codigo_nivel8 nresto,
	    c.descripcion,
        c.interno_rubro,
	    sum(decode(regimen, '1', a.valor,'2',a.valor,'3',0)) valora,
	    sum(decode(regimen, '3', a.valor,'1',0,'2',0)) valorn,
        sum(decode(regimen, '1', a.valor,'2',a.valor,'3',0)) + sum(decode(regimen, '3', a.valor,'1',0,'2',0))  total
        select *
  FROM   rh_t_lm_valores a, rh_lm_cuenta b, pr_v_rubros c
  WHERE  tipo_ra                   = 2      --:P_TIPO_RA
  AND        grupo_ra              = '5'     --:P_GRUPO_RA
  AND        scompania             = 206    --:P_COMPANIA
  AND        stipo_funcionario     = stipofuncionario
  AND        a.sconcepto           = b.sconcepto
  AND        ncierre               = 1
  AND        c.interno_rubro       = b.codigo_presupuesto
  AND        c.vigencia            = 2026   --:P_VIGENCIA
  AND        a.ntipo_nomina        = 1      --:P_TIPONOMINA
  AND        dfecha_inicio_vig <= TO_DATE(:P_FECHA_FINAL,'YYYYMMDD')
  AND       (dfecha_final_vig  >= TO_DATE(:P_FECHA_FINAL,'YYYYMMDD') /*:P_FECHA_FINAL*/ OR dfecha_final_vig IS NULL)
  AND        b.codigo_presupuesto IS NOT NULL
  AND        periodo           = TO_DATE(:P_FECHA_FINAL,'YYYYMMDD') --:P_FECHA_FINAL
  AND        nro_ra            = :P_NRORA
  AND       nfuncionario =52
                      codigo_nivel2,
                      codigo_nivel3,
                      codigo_nivel4,
                      codigo_nivel5 || '-' || codigo_nivel6 || '-' || codigo_nivel7 || '-' || codigo_nivel8,
                      descripcion,
                      interno_rubro
  order by nresto                      


      select *
    from rh_historico_nomina_hoy
    where nhash=854032720 and dinicioperiodo>=20260101 and dfinalperiodo<=20260131
    and nfuncionario=52
    order by dfecharegistro desc
    ;

     select *
    from rh_historico_nomina_hoy
    where nhash=854032720 and dinicioperiodo>=20260101 and dfinalperiodo<=20260131
    and dfechanovedad >= 20260301 and dfechanovedad <= 20260331
    --and nfuncionario=52
    order by dfecharegistro desc;


    select *
from RH_PERSONAS
where numero_identificacion = 1010211471 --656
interno_persona = 52 ---52025918