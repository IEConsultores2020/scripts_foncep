select distinct to_number(b.doc_vigencia) vigencia,
                substr(b.doc_entidad,1,3) codigo_compania,
                substr(b.doc_unidad_ejecutora,1,2) codigo_unidad_ejecutora,
                to_number(b.doc_consecutivo) numero_orden,
                to_number(b.doc_consecutivo) consecutivo_orden,
                b.disponibilidad numero_disponibilidad,
                b.registro numero_registro,
                to_number(b.consecutivo) consecutivo_ajuste,
                c.fecha fecha_registro,
                'REINTEGRO' tipo_movimiento,
                c.fecha_oficio,
                substr(c.resolucion,1,10) numero_oficio,
                substr(c.justificacion,1,120) descripcion,
                '1' cerrado
  from ogt_orden_pago a,
       ogt_detalle_actas b,
       ogt_actas c
 where a.vigencia = b.doc_vigencia
   and a.entidad = b.doc_entidad
   and a.unidad_ejecutora = b.doc_unidad_ejecutora
   and a.tipo_documento = b.doc_tipo_documento
   and a.consecutivo = b.doc_consecutivo
   and b.consecutivo = c.consecutivo
   and b.vigencia = c.vigencia
   and b.tipo_documento = c.tipo_documento
   and b.entidad = c.entidad
   and b.unidad_ejecutora = c.unidad_ejecutora
   and b.doc_vigencia >= '2003'
   and b.doc_entidad > '0'
   and b.tipo_documento = 'AR'
   and a.tipo_vigencia = 'V'
   and a.ind_aprobado = 1
   and a.tipo_op != 2;

--Datos a mdificar
SELECT C.*
FROM OGT_DETALLE_ACTAS B, OGT_ACTAS C
WHERE B.VIGENCIA = C.VIGENCIA
AND B.TIPO_DOCUMENTO = C.TIPO_DOCUMENTO
AND B.ENTIDAD = C.ENTIDAD
AND B.UNIDAD_EJECUTORA = C.UNIDAD_EJECUTORA
AND B.DOC_VIGENCIA= 2025
AND B.DOC_ENTIDAD=206
AND B.CONSECUTIVO_DET_ACTA = 3997
AND B.CONSECUTIVO IN (1080,2,314,70,887)
;

--Reemplazo DOC_ENTIDAD por 9999
SELECT *
FROM 
--UPDATE
OGT_DETALLE_ACTAS
SET DOC_ENTIDAD = 999  --206
where tipo_documento = 'AR'
  AND VIGENCIA=2025
  AND UNIDAD_EJECUTORA='01'
  AND ENTIDAD=206
  AND DOC_CONSECUTIVO IN (1080,2,314,70,887)
  AND DOC_ENTIDAD = 206
--and CONSECUTIVO_DET_ACTA = 3997
;

COMMIT;

SELECT *
FROM 
--UPDATE 
OGT_ACTAS
--SET ESTADO = 'AP'  --AP
WHERE CONSECUTIVO BETWEEN 1 AND 5
  and tipo_documento = 'AR'
  AND VIGENCIA=2025
  AND UNIDAD_EJECUTORA='01'
  AND ESTADO = 'AP'
  AND ENTIDAD=206
  ;

commit;  

SELECT *
FROM PR_DISPONIBILIDADES
WHERE CODIGO_COMPANIA=206
  AND VIGENCIA=2025
  AND CODIGO_UNIDAD_EJECUTORA='01'
  AND NUMERO_DISPONIBILIDAD=10
  ;

SELECT *
FROM PR_DISPONIBILIDAD_RUBRO
WHERE CODIGO_COMPANIA=206
  AND VIGENCIA=2025
  AND CODIGO_UNIDAD_EJECUTORA='01'
  AND NUMERO_DISPONIBILIDAD=10
  ;  


  SELECT *
LTRIM(RTRIM(pr_disponibilidades.objeto)) objeto
 FROM pr_disponibilidades
WHERE
pr_disponibilidades.vigencia = :P_VIGENCIA AND
pr_disponibilidades.codigo_compania =  :P_COMPANIA  AND
pr_disponibilidades.codigo_unidad_ejecutora =:P_UNIDAD  AND
pr_disponibilidades.fecha_registro >= :P_FECHA_DESDE AND
pr_disponibilidades.fecha_registro <= :P_FECHA_HASTA AND
pr_disponibilidad_rubro.rubro_interno = :P_RUBRO_INTERNO
order by pr_disponibilidades.fecha_registro,pr_disponibilidades.numero_disponibilidad
;
