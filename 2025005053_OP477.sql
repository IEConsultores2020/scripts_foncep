select * 
from  ogt_orden_pago
where entidad=206
and consecutivo = 477
and vigencia = 2025
and unidad_ejecutora='02'
;


1. el campo detalle, 
PAGO DE CUOTAS PARTES PENSIONALES, SEGÚN RESOLUCIÓN NO. GBCP - 001297 DE 13 DE NOVIEMBRE DE 2025. ID 3-2025-09648. MARCA SAP 5000949831
se cambia por
PAGO DE CUOTAS PARTES PENSIONALES, SEGÚN RESOLUCIÓN NO. GBCP - 001300 DE 13 DE NOVIEMBRE DE 2025. ID 3-2025-09649. MARCA SAP 5000949831

update ogt_orden_pago
set Detalle='PAGO DE CUOTAS PARTES PENSIONALES, SEGÚN RESOLUCIÓN NO. GBCP - 001300 DE 13 DE NOVIEMBRE DE 2025. ID 3-2025-09649. MARCA SAP 5000949831'
where entidad=206
and consecutivo = 477
and vigencia = 2025
and unidad_ejecutora='02'
;

commit

2.el campo acta de recibo
3-2025-09648
se cambia por 
3-2025-09649

update ogt_orden_pago
set acta_de_recibo='3-2025-09649'
where entidad=206
and consecutivo = 477
and vigencia = 2025
and unidad_ejecutora='02'
;

commit;

/*fk ogt_documento
VIGENCIA ENTIDAD UNIDA_EJECUTORA TIPO_DOCUMENTO CONSECUTIVO
fk ogt_tercero TER_ID
fk ogt_tipo_compromiso CODIGO_COMPROMISO
fk ogt_tipo_op TIPO_OP
*/


select *
from ogt_paquete_envio
where entidad=206
and numero_envio=587
and vigencia =2025
and unidad_ejecutora='02'
;

select *
from ogt_detalle_envio
where vigencia = 2025
and nro_envio=587
and entidad=206
and unidad_ejecutora='02'
and consecutivo = 477
;
/*fk paquete_envio
ENTIDAD
UNIDAD_EJECUTORA
NRO_ENVIO
*/

select *
from ogt_egreso
where vigencia=2025
and entidad=206
and unidad_ejecutora='02'
;

select *
from OGT_BANCOS_ACH
;
