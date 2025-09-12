select distinct ( FECHA )
  from auditoria
 where tabla = 'RH_DESCUENTOS_F'
   --and fecha >= to_date('14/08/2025','dd/mm/yyyy')
   --and columna = 'FUNCIONARIO'
   --and VALOR_ANT = 41
   AND FECHA = '14/08/2025'
   ORDER BY 1 DESC
   and ( valor_ant is not null
    or valor_nuevo is not null )
--and operacion not in ('INSERTAR','ELIMINAR')
 group by operacion
 order by fecha desc;

-- Myriam silva Obando -- 51653368 INT 41

select count(1), descuentos_tipo, descuentos_numero /*, numero_pago*/, fecha_pago, monto, clase 
from  rh_detalle_pagos_f --RH_DESCUENTOS_F
where funcionario = 41
group by descuentos_tipo, descuentos_numero/*, numero_pago*/, fecha_pago, monto, clase
having count(1)>1
;


select *
from RH_PERSONAS
where numero_identificacion = '51653368';