 OGT_PK_PREDIS.ogt_fn_valor_mes(:vigencia,
                                :codigo_compania,
                                :codigo_unidad_ejecutora,
                                TO_NUMBER(:p_mes),
                                :rubro_interno);


 /*FUNCTION Ogt_Fn_Valor_Mes(una_vigencia         NUMBER,
                            una_entidad          VARCHAR2,
                            una_unidad_ejecutora VARCHAR2,
                            un_mes               NUMBER,
                            un_rubro_interno     NUMBER) RETURN NUMBER IS
  BEGIN*/
    SELECT * --NVL(SUM(VALOR_BRUTO), 0)
      --INTO mi_valor_op
      FROM OGT_INFORMACION_EXOGENA A, OGT_ORDEN_PAGO B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA     = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO       = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO          = B.CONSECUTIVO
      -- AND A.RUBRO_INTERNO = un_rubro_interno
       AND B.VIGENCIA             = TO_CHAR(2026)
       AND B.UNIDAD_EJECUTORA     = '01'                        --una_unidad_ejecutora
       AND B.TIPO_DOCUMENTO       = 'RA'                          --mi_tipo_documento_op
       AND B.ENTIDAD_PRESUPUESTO  = 206                      --una_entidad
       --AND B.TIPO_OP != mi_tipo_caja_menor
       AND IND_APROBADO           = 1         --mi_valor_uno
       AND TO_NUMBER(TO_CHAR(fecha_aprobacion, 'MM')) = '02'  --un_mes
       AND TO_CHAR(FECHA_APROBACION, 'YYYY') = TO_CHAR(2026) --una_vigencia);

   SELECT --.rubro_interno, r.descripcion, 
    SUM(NVL(A.VALOR_REGISTRO,0)), COUNT(1)
      --INTO mi_valor_ra
      FROM OGT_REGISTRO_PRESUPUESTAL A, OGT_RELACION_AUTORIZACION B, pr_rubro r
     WHERE A.VIGENCIA         = B.VIGENCIA
       AND A.ENTIDAD          = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO   = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO      = B.CONSECUTIVO
       AND A.RUBRO_INTERNO   =  R.INTERNO --un_rubro_interno
       AND B.VIGENCIA         = TO_CHAR(2026)
       AND B.ENTIDAD          = 206    --una_entidad
       AND A.CONSECUTIVO      = 1
       AND B.UNIDAD_EJECUTORA = '01'    ---una_unidad_ejecutora
       AND B.TIPO_DOCUMENTO   = 'RA'  --mi_tipo_documento_ra
       AND B.IND_APROBADO     = 1       --mi_valor_uno
       AND SUBSTR(B.ESTADO, 4, 1) = 1   --mi_estado_uno
       AND TO_NUMBER(TO_CHAR(B.fecha_aprobacion, 'MM')) = '01'  ---un_mes
       AND TO_CHAR(B.FECHA_APROBACION, 'YYYY') = TO_CHAR(2026)
       AND NVL(A.VALOR_REGISTRO, 0) > 0   ---mi_valor_cero;
       grOUP BY A.RUBRO_INTERNO, r.descripcion
      
  ;

    RETURN(NVL(mi_valor_op, 0) + NVL(mi_valor_ra, 0));
--  END Ogt_Fn_Valor_Mes;

merge into ogt_relacion_autorizacion b
using ogt_registro_presupuestal a
on a.vigencia= b.vigencia
  and a.entidad          = b.entidad
  and a.unidad_ejecutora = b.unidad_ejecutora
  and a.tipo_documento   = b.tipo_documento
  and a.consecutivo      = b.consecutivo
  and b.vigencia         = to_char(2026)
when matched then update 
  set b.ind_aprobado  = 1,
      b.fecha_aprobacion = to_date('30/01/2026','dd/mm/yyyy')
where a.consecutivo      = 1
  and b.unidad_ejecutora = '01'    ---una_unidad_ejecutora
    and b.tipo_documento   = 'ra'  --mi_tipo_documento_ra
  -- and b.ind_aprobado     = 1       --mi_valor_uno
    and substr(b.estado, 4, 1) = 1   --mi_estado_uno
   -- and to_number(to_char(b.fecha_aprobacion, 'mm')) = '02'  ---un_mes
   -- and to_char(b.fecha_aprobacion, 'yyyy') = to_char(2026)
    and nvl(a.valor_registro, 0) > 0   ---mi_valor_cero;

    --Actualización manual

    select b.* --, rowid
from  ogt_relacion_autorizacion b
where exists (select 1 
             from ogt_registro_presupuestal a
             where a.vigencia= b.vigencia
              and a.entidad          = b.entidad
              and a.unidad_ejecutora = b.unidad_ejecutora
              and a.tipo_documento   = b.tipo_documento
              and a.consecutivo      = b.consecutivo
              and b.vigencia         = to_char(2026)
              and a.consecutivo      = 1
               and nvl(a.valor_registro, 0) > 0
               )
               and b.unidad_ejecutora = '01'    ---una_unidad_ejecutora
    and b.tipo_documento   = 'RA'  --mi_tipo_documento_ra
  -- and b.ind_aprobado     = 1       --mi_valor_uno
    and substr(b.estado, 4, 1) = 1   --mi_estado_uno
   -- and to_number(to_char(b.fecha_aprobacion, 'mm')) = '02'  ---un_mes
   -- and to_char(b.fecha_aprobacion, 'yyyy') = to_char(2026)
       ---mi_valor_cero;


--Para modificacion manual uselo en plsql para editar y cambio manual
select b.* --, rowid
from  ogt_relacion_autorizacion b
where exists (select 1 
             from ogt_registro_presupuestal a
             where a.vigencia= b.vigencia
              and a.entidad          = b.entidad
              and a.unidad_ejecutora = b.unidad_ejecutora
              and a.tipo_documento   = b.tipo_documento
              and a.consecutivo      = b.consecutivo
              and b.vigencia         = to_char(2026)
              and a.consecutivo      = 3
               and nvl(a.valor_registro, 0) > 0
               )
               and b.unidad_ejecutora = '01'    ---una_unidad_ejecutora
    and b.tipo_documento   = 'RA'  --mi_tipo_documento_ra
  -- and b.ind_aprobado     = 1       --mi_valor_uno
    and substr(b.estado, 4, 1) = 1   --mi_estado_uno
   -- and to_number(to_char(b.fecha_aprobacion, 'mm')) = '02'  ---un_mes
   -- and to_char(b.fecha_aprobacion, 'yyyy') = to_char(2026)
       ---mi_valor_cero;       