   SELECT 
      '7990990000' cuenta_credito,
      sum(decode(regimen, '3', a.valor,'1',0,'2',0)) valor_crp,
      '5000001965' rp_doc_presupuestal
      decode(c.descripcion,'Sueldo básico','0001',c.codigo_nivel7) posicion_doc_presupuestal
  FROM     rh_t_lm_valores a, rh_lm_cuenta b, pr_v_rubros c
  WHERE tipo_ra             = '1'           --:P_TIPO_RA
  AND   grupo_ra            = '5'           --:P_GRUPO_RA
  AND   scompania           = 206           --:P_COMPANIA
  AND   stipo_funcionario   = stipofuncionario
  AND   a.sconcepto         = b.sconcepto
  AND   ncierre             = 1
  AND   c.interno_rubro     = b.codigo_presupuesto
  AND   c.vigencia          = 2025          --:P_VIGENCIA
  AND   a.ntipo_nomina      = '0'           --:P_TIPONOMINA
  AND   dfecha_inicio_vig   <= '31-MAY-25'       --:P_FECHA_FINAL
  AND   (dfecha_final_vig   >= '31-MAY-25' /*:P_FECHA_FINAL*/ OR dfecha_final_vig IS NULL) 
  AND   b.codigo_presupuesto IS NOT NULL
  AND   periodo             = '31-MAY-25'   --:P_FECHA_FINAL
  --AND   nro_ra              = 14            ---:P_NRORA
  GROUP BY codigo_nivel1,
                      codigo_nivel2,
                      codigo_nivel3,
                      codigo_nivel4,
                      codigo_nivel7,
                      codigo_nivel5 || '-' || codigo_nivel6 || '-' || codigo_nivel7 || '-' || codigo_nivel8,
                      descripcion,
                      interno_rubro
  ORDER BY codigo_nivel5 || '-' || codigo_nivel6 || '-' || codigo_nivel7 || '-' || codigo_nivel8
