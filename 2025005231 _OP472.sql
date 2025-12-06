-- OGT - Actualización fecha de pago giro egreso 2025-206-02-472
select *
from ogt_v_egresos_pagos
where vigencia=2025
and entidad=206
and unidad_ejecutora='02'
and consecutivo=472
;

select fecha_pago fecha_pago_giro, ogt_detalle_pago.*
from ogt_detalle_pago
where id_pago = (
select id_pago
from ogt_detalle_egreso
where vigencia=2025
and entidad=206
and unidad_ejecutora='02'
and consecutivo=472
);

/*  Se actualiza 
    fecha_pago
    valor anterior 28/12/2025
    valor nuevo 28/11/2025  */


update ogt_detalle_pago 
set fecha_pago = to_date('28/11/2025','dd/mm/yyyy')
where id_pago = 
    (
select id_pago
from ogt_detalle_egreso
where vigencia=2025
and entidad=206
and unidad_ejecutora='02'
and consecutivo=472
    )
and fecha_pago = to_date('28/12/2025','dd/mm/yyyy');

commit;