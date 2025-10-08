select *
  from 
--UPDATE
   ogt_detalle_actas
--SET DOC_ENTIDAD = 206  --VALOR ANTERIOR. 206
 where tipo_documento = 'AR'
   and vigencia = 2025
   and unidad_ejecutora = '01'
   and entidad = 206
   and doc_consecutivo in ( 1080,
                            2,
                            314,
                            70,
                            887 )
   and doc_entidad = 999;

rollback;

commit;

select *
  from ogt_actas
 where vigencia = 2025
   and consecutivo = 4
   and tipo_documento = 'AR';

--CRP ANULADOS
SELECT pr_rubro.descripcion descripcion_rubro, 
PR_CDP_ANULADOS.VIGENCIA , 
PR_CDP_ANULADOS.CODIGO_COMPANIA, 
PR_CDP_ANULADOS.CODIGO_UNIDAD_EJECUTORA, 
PR_CDP_ANULADOS.NUMERO_DISPONIBILIDAD, 
PR_CDP_ANULADOS.RUBRO_INTERNO, 
PR_CDP_ANULADOS.NUMERO_REGISTRO, 
PR_CDP_ANULADOS.NUMERO_COMPROMISO,
PR_CDP_ANULADOS.CONSECUTIVO_ANULACION, 
PR_CDP_ANULADOS.TIPO_COMPROMISO , 
PR_CDP_ANULADOS.FECHA_ANULACION , 
PR_CDP_ANULADOS.MOTIVO, 
PR_CDP_ANULADOS.VALOR_ANULADO, 
PR_CDP_ANULADOS.ID_PERSONA, 
PR_CDP_ANULADOS.NUMERO_OFICIO, 
PR_CDP_ANULADOS.FECHA_OFICIO, 
codigo_tipo, 
codigo_componente, 
codigo_objeto, 
codigo_fuente, 
codigo_det_fuente 
FROM PR_CDP_ANULADOS, pr_rubro 
WHERE PR_CDP_ANULADOS.rubro_interno = pr_rubro.interno 
AND PR_CDP_ANULADOS.vigencia = pr_rubro.vigencia 
AND PR_CDP_ANULADOS.VIGENCIA = 2025
AND PR_CDP_ANULADOS.CODIGO_COMPANIA = 206
AND PR_CDP_ANULADOS.CODIGO_UNIDAD_EJECUTORA = '01'
AND pr_rubro.descripcion LIKE '%Servicios%parqueaderos%'