select vigencia, entidad, unidad_ejecutora ue, consecutivo numero, estado, acta_de_recibo, nombre_interventor, detalle
from  ogt_orden_pago
where entidad=206
and consecutivo = 489
and vigencia = 2025
and unidad_ejecutora='02'
;


1. Acta de recibo
Valor Actual: (vacio)
se cambia por
3-2025-09818

update ogt_orden_pago
set acta_de_recibo='3-2025-09818'
where entidad=206
and consecutivo = 489
and vigencia = 2025
and unidad_ejecutora='02'
;


1. Nombre del Interventor (si aclara que no hay supervisor en la tabla)
Valor Actual: (vacio)
se cambia por
Ivan Enrique Quasth Torres

update ogt_orden_pago
set nombre_interventor='Ivan Enrique Quasth Torres'
where entidad=206
and consecutivo = 489
and vigencia = 2025
and unidad_ejecutora='02'
;

commit;

