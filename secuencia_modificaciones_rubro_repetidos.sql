select *
from pr_apropiacion
where vigencia =2026
and rubro_interno in (1759,1948) for update;

select *
from pr_v_rubros
where descripcion like '%ervicios%' --interno_rubro in  (1715,1893)
;

select *
from pr.pr_disponibilidad_rubro
where vigencia =2026
and rubro_interno in (1759,1948) 
order by numero_disponibilidad for update;

SELECT constraint_name, constraint_type, table_name
FROM user_constraints
WHERE constraint_name = 'FK_PR_REGIS_REF_5094_PR_DISPO'

select *
from pr.pr_registro_disponibilidad
where vigencia=2026
and codigo_compania=206
and codigo_unidad_ejecutora='01'
and rubro_interno in (1759,1948) for update
;



select *
from PR.pr_disponibilidades
where numero_disponibilidad=192
and vigencia=2026
and codigo_compania=206
and codigo_unidad_ejecutora='01'
;

select *
from pr_modificacion_presupuestal
where vigencia = 2026
and codigo_compania=206
and codigo_unidad_ejecutora = '01'
--and documentos_numero = '000014'
and rubro_interno in (1759,1948) 
for update
;

select *
from pr_documentos
where tipo_movimiento = 'TRASLADO'
and vigencia = 2026
--and numero = '000014'
and tipo_documento = '02' for update ---RESOLUCION
;
