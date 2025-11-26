--De acuerdo al instructivo, debe borrarse el reintegro desde la pantalla donde se creó
--Para este caso, solo se asigna otra dato en DOC_ENTIDAD .
--Reemplaza DOC_ENTIDAD por 9999
SELECT -- sum(valor)
     --/*
      consecutivo_det_Acta, consecutivo, tipo_documento, doc_consecutivo, 
      disponibilidad, registro, valor, recibo_caja --*/
FROM 
--UPDATE
OGT_DETALLE_ACTAS
--SET DOC_ENTIDAD = 206  --VALOR ANTERIOR. 206
where tipo_documento = 'AR'
  AND VIGENCIA=2025
  AND UNIDAD_EJECUTORA='01'
  AND ENTIDAD=206
  AND DOC_CONSECUTIVO IN (1080,2,314,70,887)
  AND DOC_ENTIDAD = 206
;

COMMIT;

--Apropiación
select *
from pr_apropiacion
where vigencia=2025
and rubro_interno=1491
;

--Valido el CDP
select *
  from pr_disponibilidad_rubro
 where vigencia = 2025
   and rubro_interno = 1491; --1604

--Valido RP anulados
select numero_disponibilidad, numero_registro, consecutivo_anulacion, numero_oficio, fecha_oficio, motivo, valor_anulado
  from pr_rp_anulados
  where vigencia=2025
  and rubro_interno=1491
  ;

--CDP Anulados
select numero_disponibilidad, numero_registro, numero_compromiso, valor_anulado, numero_oficio, fecha_oficio, motivo
from pr_cdp_anulados
where vigencia=2025
and rubro_interno=1491
;

select * 
from ogt_pago
;

---PAGOS
select *
from ogt_radicacion_cuenta_cobro
;

select * --tipo_documento, consecutivo, numero_de_compromiso compromiso, num_radicacion
from ogt_orden_pago
where vigencia=2025
--and numero_de_compromiso=2
and upper(detalle) like '%PARQUEAD%'
;


--ogt_registro_presupuestal
select rp.registro, rp.valor_registro, rp.rubro_interno, op.consecutivo, op.codigo_compromiso, 
      op.tipo_vigencia, op.estado, op.numero_de_compromiso, op.acta_de_recibo, 
      op.num_radicacion
from ogt_orden_pago op, ogt_registro_presupuestal rp 
where op.vigencia=rp.vigencia 
  and op.entidad=rp.entidad 
  and op.unidad_ejecutora=rp.unidad_ejecutora 
  and op.tipo_documento=rp.tipo_documento 
  and op.consecutivo = rp.consecutivo 
  and op.vigencia=2025
  and rp.rubro_interno = 1491
 -- and rp.consecutivo = 70
;

--ogt_imputacion
select *
from ogt_imputacion
where vigencia=2025
and rubro_interno = 1491
;


select registro,  valor_bruto, consecutivo, tipo_documento, disponibilidad
  --sum(valor_bruto)
from ogt_informacion_exogena
where vigencia=2025
--and consecutivo=70
and rubro_interno=1491
;
--7845000

--NO
--EGRESOS
select *
from ogt_detalle_pago
where extract(year from fecha_pago) = 2025
;

select *
from ogt_detalle_egreso
where vigencia=2025
;

