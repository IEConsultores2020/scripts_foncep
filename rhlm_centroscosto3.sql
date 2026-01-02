
	  SELECT c.descripcion, c.codigo_maestro , SUM(a.valor) valor
	  FROM   rh_t_lm_valores a, rh_lm_cuenta b, rh_lm_centros_costo c
	  WHERE  b.stipo_funcionario = a.stipofuncionario
	  AND    b.sconcepto         = a.sconcepto
	  AND    b.cc                      = c.codigo
                  AND   TO_CHAR(periodo,'YYYYMMDD')           = 20250630 --TO_CHAR(:P_FECHA_FIN,'YYYYMMDD')
	  AND    a.ntipo_nomina     = '0'
	--  AND    a.nro_ra           = 14
	  AND    b.scompania        = 206
	  AND    b.tipo_ra          = 1 --:P_TIPO_RA
--	  AND    b.grupo_ra            IN (:P_GRUPO_RA)
	  AND    b.ncierre          = 1
                  AND   dfecha_inicio_vig <= '01-DEC-25'  --:P_FECHA_FIN
                  AND   (dfecha_final_vig  >= '31-DEC-25'  /*:P_FECHA_FIN*/ OR dfecha_final_vig IS NULL) 
	  GROUP BY c.descripcion, c.codigo_maestro 
      ORDER BY c.codigo_maestro
