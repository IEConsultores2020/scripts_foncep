/*
No fue Posible Registrar los Descuentos Calculados en la Nómina.
No fue Posible Clausurar la Nómina Anterior
*/
select *
  from rh_actos_administrativos
 where funcionario = 644
   and tipo_acto = 171
   for update; ---1 cambiar fecha acto de 13 a 14

select *
  from rh_historico_nomina
 where nfuncionario = 644
   and nhash = 1994756444
   for update; --2 Cambiar DFECHAFINAL a 20260714

select *
  from rh_detalle_vacaciones
 where funcionario = 644
   for update
--3. Cambiar fecha fin vacaciones

PK_RH_Detalle_Pagos.FN_RH_Registrar_Detalle_Pagos;

Select Nombre From Rh_Procesos;

SELECT Definitiva, Fecha_Inicial_Periodo, Fecha_Final_Periodo
--INTO mi_definitiva, mi_fecha1, mi_fecha2
  FROM rh_Nomina
 WHERE Proceso = 'NOMINA_DE_EMPLEADOS_PLANTA' --:Bl_Nomina.Proceso 
   AND Version = 0
   AND Fecha_Final_Periodo = '30/JUN/2026'

 NOT
        PK_RH_Detalle_Pagos.FN_RH_Registrar_Detalle_Pagos(:Bl_nomina.Proceso,
                                                          0,
                                                          To_Number(to_Char(mi_fecha1,
                                                                            'YYYYMMDD.SSSSS'),
                                                                    '99999999.99999'),
                                                          To_Number(to_Char(mi_fecha2,
                                                                            'YYYYMMDD.SSSSS'),
                                                                    '99999999.99999'))


begin
  PK_RH_VALIDACIONES.PR_RH_VALIDAR_Detalle_Pagos('NOMINA_DE_EMPLEADOS_PLANTA',
                              0,
                              20260601.00000,
                              20260630.00000);
                              
end;                              

                                                          To_Number(to_Char(mi_fecha1,
                                                                            'YYYYMMDD.SSSSS'),
                                                                    '99999999.99999'),
                                                          To_Number(to_Char(mi_fecha2,
                                                                            'YYYYMMDD.SSSSS'),
                                                                    '99999999.99999'))

