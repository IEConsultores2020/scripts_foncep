
	  SELECT b.codigo_presupuesto, c.descripcion, c.codigo_maestro , SUM(a.valor) valor
	  --select a.*
	  FROM   rh_t_lm_valores a, rh_lm_cuenta b, rh_lm_centros_costo c
	  WHERE  b.stipo_funcionario = a.stipofuncionario
	  AND    b.sconcepto         = a.sconcepto
	  AND    b.cc                      = c.codigo
      AND   TO_CHAR(periodo,'YYYYMMDD')           = 20260531 --TO_CHAR(:P_FECHA_FIN,'YYYYMMDD')
	  AND    a.ntipo_nomina     = 0
	  AND    a.nro_ra           = 12
	  AND    b.scompania        = 206
	  AND    b.tipo_ra          = 1 	--:P_TIPO_RA
	  AND    b.grupo_ra         = '5'  -- IN (:P_GRUPO_RA)
	  AND    b.ncierre          = 1
      AND   dfecha_inicio_vig <= '01-MAY-26'  --:P_FECHA_FIN
      AND   (dfecha_final_vig  >= '31-MAY-26'  /*:P_FECHA_FIN*/ OR dfecha_final_vig IS NULL) 
	  AND    c.codigo_maestro in ('2-4-24-01-01','2-4-24-02-01','2-4-24-02-01')
	  AND    a.nfuncionario       = 11
	  GROUP BY b.codigo_presupuesto, c.descripcion, c.codigo_maestro 
      ORDER BY c.codigo_maestro
	  ;

--sueldo 3338526
int 11 cc 79484354

SELECT USERENV ('language') FROM DUAL


select to_char(sysdate,'YYYY') from dual;