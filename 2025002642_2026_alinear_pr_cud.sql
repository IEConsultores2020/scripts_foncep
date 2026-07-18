--Visto desde RH
SELECT b.codigo_presupuesto,
 c.descripcion, c.codigo_maestro, SUM(a.valor) valor
--select c.*
  FROM rh_t_lm_valores a, rh_lm_cuenta b, rh_lm_centros_costo c
 WHERE b.stipo_funcionario = a.stipofuncionario
   AND b.sconcepto = a.sconcepto
   AND b.cc = c.codigo
   AND TO_CHAR(periodo, 'YYYYMMDD') = 20260430 	
   									--20260531 --TO_CHAR(:P_FECHA_FIN,'YYYYMMDD')
   AND a.ntipo_nomina 				= 1 		
   									          --0
   AND a.nro_ra         		= 10        
   	--								        --12
   AND b.scompania 		= 206
   AND b.tipo_ra 		= 1 --:P_TIPO_RA
   AND b.grupo_ra		= '5' -- IN (:P_GRUPO_RA)
   AND b.ncierre 		= 1
   AND dfecha_inicio_vig <= '01-MAY-26'   --'01-APR-26' --:P_FECHA_FIN
   AND (dfecha_final_vig >= '31-MAY-26'   --'30-APR-26' /*:P_FECHA_FIN*/
       OR dfecha_final_vig IS NULL)
   AND c.codigo_maestro in ('2-4-24-01-01',  -- APORTES A FONDOS PENSIONALES        2
                            '2-4-24-02-01',  -- FONDO DE SOLIDARIDAD                4
                            '2-4-24-02-01')  ---APORTES A SEGURIDAD SOCIAL EN SALUD 3
 GROUP BY b.codigo_presupuesto, 
          c.descripcion,
          c.codigo_maestro
--ORDER BY c.codigo_maestro
;

--Consulta desde OPGET
select CODIGO_CENTRO_COSTOS, SUM(APORTE_EMPLEADO)
  from ogt_anexo_nomina
 where vigencia = 2026
   and consecutivo = 10
   AND CODIGO_CENTRO_COSTOS IN (5,      --APORTE SALUD
                                1285,   --APORTE REGIMEN SOLIDARIDAD
                                1267    --APORTE PENSION
                                )
group by codigo_centro_costos   
;


select codigo_centro_costos, cuenta_contable_entidad, valor
from ogt_centro_costos
where entidad=206
  and vigencia = 2026
  and extract(month from fecha_desde) =5
  --and consecutivo=10
  AND CODIGO_CENTRO_COSTOS IN (5, 1285, 1267)