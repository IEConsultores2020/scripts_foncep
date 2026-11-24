/* 
   El funcionario 639 esta registrando el tercero COOPEBIS en una libranza 
   y debe ser tercero DAVIVIENDA, aquí se valida la auditoria del mes 10 
   con respecto a libranzas
*/
select auditoria.sistema, 
   auditoria.usuario, 
   TO_CHAR(auditoria.fecha, 'DD/MM/YYYY HH24:MI:SS') fechahora, 
   auditoria.columna, 
   auditoria.operacion, 
   auditoria.valor_ant, 
   auditoria.valor_nuevo  
from auditoria
where codigo in
   ( select codigo
      from auditoria
    where tabla like 'RH_DESCUENTOS%' --'RH_T_LM_VALORES'
      and extract(year from fecha) = 2026
      and extract(month from fecha) = 10
      and columna in ('FUNCIONARIO','TIPO')
      and valor_ant in ('639','LIBRANZA')
   )
order by codigo asc;
