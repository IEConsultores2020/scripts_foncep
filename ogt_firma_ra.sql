MI_ESTADO_APROBADO := PK_PRE_TESORERIA.FN_PRE_CAMBIA_ESTADO_RP
   	                    (TO_NUMBER(:OGT_RELACION_AUTORIZACION.VIGENCIA)
   	                    ,MI_REG_REGISTRO.MI_ENTIDAD
   	                    ,:OGT_RELACION_AUTORIZACION.UNIDAD_EJECUTORA
   	                    ,MI_REG_REGISTRO.MI_REGISTRO   	                                                
                        ,MI_REG_REGISTRO.MI_DISPONIBILIDAD
--   	                ,MI_TOTAL_RP);  
																								 ,MI_BRUTO_APROBADO); 


 UPDATE OGT_IMPUTACION
 
                                                                                                  