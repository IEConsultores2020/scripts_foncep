select vigencia, entidad, unidad_ejecutora ue, consecutivo numero, estado, acta_de_recibo, codigo_contable_bruto, codigo_contable_neto
from  ogt_orden_pago
where entidad=206
and consecutivo = 1964
and vigencia = 2025
and unidad_ejecutora='01'
;


1. Acta de recibo
CODIGO_CONTABLE_BRUTO: '2-4-01-01-02-02'
se cambia por '1-9-08-01-01'

CODIGO_CONTABLE_NETO: '1-9-08-01-01'
se cambia por: '2-4-01-01-02-02'


update ogt_orden_pago
set CODIGO_CONTABLE_BRUTO='1-9-08-01-01',
    CODIGO_CONTABLE_NETO='2-4-01-01-02-02'
where entidad=206
and consecutivo = 1964
and vigencia = 2025
and unidad_ejecutora='01'
;


commit;