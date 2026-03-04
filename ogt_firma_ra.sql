MI_ESTADO_APROBADO := PK_PRE_TESORERIA.FN_PRE_CAMBIA_ESTADO_RP
   	                    (TO_NUMBER(:OGT_RELACION_AUTORIZACION.VIGENCIA)
   	                    ,MI_REG_REGISTRO.MI_ENTIDAD
   	                    ,:OGT_RELACION_AUTORIZACION.UNIDAD_EJECUTORA
   	                    ,MI_REG_REGISTRO.MI_REGISTRO   	                                                
                        ,MI_REG_REGISTRO.MI_DISPONIBILIDAD
--   	                ,MI_TOTAL_RP);  
																								 ,MI_BRUTO_APROBADO); 


 UPDATE OGT_IMPUTACION
 
FN_OGT_RP_PAGO                                                                                                  

 OPEN MI_CURSOR_RP FOR
         SELECT RUBRO_INTERNO
               ,UNIDAD_EJECUTORA_PRESUPUESTO
               ,DISPONIBILIDAD
               ,VIGENCIA_PRESUPUESTO
               ,TIPO_DOCUMENTO
               ,UNIDAD_EJECUTORA
               ,ENTIDAD
               ,VIGENCIA
               ,CONSECUTIVO
               ,ENTIDAD_PRESUPUESTO
               ,REGISTRO
               ,VALOR_REGISTRO
               ,ID_LIMAY_GIRO_PRESUPUESTAL
               ,FECHA_GIRO_PRESUPUESTAL
               ,USUARIO_GIRO_PRESUPUESTAL
               ,ID_LIMAY_PAGO
               ,FECHA_PAGO
               ,USUARIO_PAGO
               ,ID_LIMAY_ANULACION_GIRO
               ,FECHA_ANULACION_GIRO
               ,USUARIO_ANULACION_GIRO
               ,ID_LIMAY_ANULACION_PAGO
               ,FECHA_ANULACION_PAGO
               ,USUARIO_ANULACION_PAGO
           FROM OGT_REGISTRO_PRESUPUESTAL
          WHERE REGISTRO >= 		0 		--MI_VALOR_CERO
            AND TIPO_DOCUMENTO = 	'RA'	--UN_TIPO_DOCUMENTO
            AND DISPONIBILIDAD >= 	0 		--MI_VALOR_CERO
            AND CONSECUTIVO = 		1 		--UN_CONSECUTIVO
            AND ENTIDAD = 			206 	--UNA_ENTIDAD
            AND UNIDAD_EJECUTORA = '01'		--UNA_UNIDAD_EJECUTORA
            AND VIGENCIA = 			2026	--UNA_VIGENCIA
            ;

select *
from --pr_v_rubros 
  pr_rubro
where (descripcion like '%Gastos%unciona%'			
or descripcion like '%SueldoB%sico%'		)	
and tipo_plan='PLAN_ADMONCENTRAL'
and vigencia= 2026
order by vigencia desc;

/*
Beneficios a los empleados a corto plazo
Auxilio de transporte
Bonificación por servicios prestados
Aportes de cesantías a fondos públicos
Sueldo básico
Prima técnica salarial
Prima secretarial
Gastos de representación
Prima de navidad
Horas extras, dominicales, festivos y recargos
Subsidio de alimentación
Prima de vacaciones
Bonificación especial de recreación
Reconocimiento por permanencia en el servicio público - Bogotá D.C.

*/

select *
from pr_disponibilidades
where vigencia = 2026
and codigo_compania = 206
and codigo_unidad_ejecutora = '01'
and numero_disponibilidad = 39;

select *
from pr_disponibilidad_rubro
where vigencia = 2026
and codigo_compania = 206
and codigo_unidad_ejecutora = '01'
and numero_disponibilidad = 39