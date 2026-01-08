select *
from ogt_relacion_autorizacion
where vigencia = 2025
and unidad_ejecutora = '01'
and entidad = 206
--and tipo_ra = 1
and tipo_documento ='RA'
and mes = 12
and (descripcion like '%PREDIS%27%'
or descripcion like '%PREDIS%28%')
;

select *
from ogt_detalle_relacion_autorizacion
where vigencia = 2025