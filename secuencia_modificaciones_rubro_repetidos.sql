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

------------------------------------------------------------------------
-----ORDENES DE PAGO---------ORDENES DE PAGO---------ORDENES DE PAGO----
------------------------------------------------------------------------

--pr_ogt_orden_de_pago_registro vista de PR.PR_ORDEN_DE_PAGO_REGISTRO y ogt_v_predis_detalle
select *
from pr_orden_de_pago_registro
where vigencia = 2026
and codigo_compania = 206
and codigo_unidad_ejecutora ='01'
and numero_disponibilidad in (157,160,192)
--and rubro_interno=1948   --1917
;

--pr.pr_orden_de_pago_registro
select *
from pr.pr_orden_de_pago_registro
where vigencia = 2026
and codigo_compania = 206
and codigo_unidad_ejecutora ='01'
and numero_disponibilidad in (157,160,192)


/* OGT_V_PREDIS_DETALLE  vista de ogt_registro_presupuestal y ogt_orden_pago 
                                  unido 
                                  ogt.ogt_registro_presupuestal a, ogt.ogt_relacion_autorizacion b
                                  unido
                                  ogt.OGT_DETALLE_ACTAS A, ogt.OGT_ACTAS B */
select *
from OGT_V_PREDIS_DETALLE 
where vigencia = 2026
and codigo_compania = 206
and codigo_unidad_ejecutora ='01'
and numero_disponibilidad=192
and numero_registro=173
;

select *
from ogt_registro_presupuestal
where vigencia_presupuesto = 2026
and entidad = 206
and rubro_interno =1759                       --RUBRO INTERNO
and unidad_ejecutora_presupuesto ='01'
and disponibilidad=192
and registro=173
and tipo_documento='OP' for update
;

select *
from ogt_orden_pago
where vigencia=2026
and entidad=206
and unidad_ejecutora='01'
and tipo_documento='OP'
and consecutivo=266
and numero_de_compromiso=151;


pk_ogt_op.fn_ogt_bruto_rp (a.vigencia,
                                     a.entidad,
                                     a.unidad_ejecutora,
                                     a.tipo_documento,
                                     a.consecutivo,
                                     rubro_interno,
                                     disponibilidad,
                                     registro
                                    ) valor,

ALTER TRIGGER OGT.OGT_TRG_ACTUALIZA_IE DISABLE;
ALTER TRIGGER OGT.OGT_TRG_ACTUALIZA_IE ENABLE;

    SELECT * --NVL(SUM(NVL(VALOR_BRUTO,0)),0)
        FROM OGT_INFORMACION_EXOGENA
       WHERE VIGENCIA = 2026
         AND ENTIDAD = 206
         AND UNIDAD_EJECUTORA = '01'
         AND TIPO_DOCUMENTO = 'OP' --MI_TIPO_DOCUMENTO_OP
         AND CONSECUTIVO = 266 --UN_CONSECUTIVO
         AND RUBRO_INTERNO = 1759    --CAMBIA A 1948                                    --N_RUBRO_INTERNO
         AND VIGENCIA_PRESUPUESTO = 2026 --UNA_VIGENCIA
         AND REGISTRO = 173
         AND DISPONIBILIDAD = 192 for update