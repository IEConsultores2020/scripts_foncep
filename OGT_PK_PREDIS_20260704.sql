create or replace PACKAGE BODY     Ogt_Pk_Predis IS
  -- 06-09-2004. Sergio.
  -- Se adiciono la linea
  --            AND TO_CHAR(FECHA_APROBACION,'YYYY') = TO_CHAR(una_vigencia)
  -- a todas las consultas excepto a las de reintegros para garantizar que la consulta se
  -- haga a los documentos tramitados en esa vigencia.
  -- Queda pendiente desarrollar los metodos para reservas.
  -- Se adiciono la linea
  --            AND NVL(A.VALOR_REGISTRO,0) > mi_valor_cero
  -- a las consultas de RAs para garantizar que no tome los ajustes.
  FUNCTION Ogt_Fn_Valor_Mes(una_vigencia         NUMBER,
                            una_entidad          VARCHAR2,
                            una_unidad_ejecutora VARCHAR2,
                            un_mes               NUMBER,
                            un_rubro_interno     NUMBER) RETURN NUMBER IS
  BEGIN
    -- 18-08-2004. Sergio.
    -- Se pone en comentario la instruccion AND SUBSTR(B.ESTADO,9,1) = mi_estado_cero
    -- por solicitud de Magda.
    SELECT NVL(SUM(VALOR_BRUTO), 0)
      INTO mi_valor_op
      FROM OGT_INFORMACION_EXOGENA A, OGT_ORDEN_PAGO B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO = B.CONSECUTIVO
       AND A.RUBRO_INTERNO = un_rubro_interno
       AND B.VIGENCIA = TO_CHAR(una_vigencia)
          --AND B.ENTIDAD > '0'
       AND B.UNIDAD_EJECUTORA = una_unidad_ejecutora
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_op
       AND B.ENTIDAD_PRESUPUESTO = una_entidad
       AND B.TIPO_OP != mi_tipo_caja_menor
       AND IND_APROBADO = mi_valor_uno
       AND TO_NUMBER(TO_CHAR(fecha_aprobacion, 'MM')) = un_mes
       AND TO_CHAR(FECHA_APROBACION, 'YYYY') = TO_CHAR(una_vigencia);
    SELECT NVL(SUM(VALOR_REGISTRO), 0)
      INTO mi_valor_ra
      FROM OGT_REGISTRO_PRESUPUESTAL A, OGT_RELACION_AUTORIZACION B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO = B.CONSECUTIVO
       AND A.RUBRO_INTERNO = un_rubro_interno
       AND B.VIGENCIA = TO_CHAR(una_vigencia)
       AND B.ENTIDAD = una_entidad
       AND B.UNIDAD_EJECUTORA = una_unidad_ejecutora
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_ra
       AND B.IND_APROBADO = mi_valor_uno
       AND SUBSTR(B.ESTADO, 4, 1) = mi_estado_uno
       AND TO_NUMBER(TO_CHAR(B.fecha_aprobacion, 'MM')) = un_mes
       AND TO_CHAR(B.FECHA_APROBACION, 'YYYY') = TO_CHAR(una_vigencia)
       AND NVL(A.VALOR_REGISTRO, 0) > mi_valor_cero;
    RETURN(NVL(mi_valor_op, 0) + NVL(mi_valor_ra, 0));
  END Ogt_Fn_Valor_Mes;
  --
  --
  FUNCTION OGT_FN_VALOR_ACUM(una_vigencia         NUMBER,
                             una_entidad          VARCHAR2,
                             una_unidad_ejecutora VARCHAR2,
                             un_mes               NUMBER,
                             un_rubro_interno     NUMBER) RETURN NUMBER IS
  BEGIN
    -- 18-08-2004. Sergio.
    -- Se pone en comentario la instruccion AND SUBSTR(B.ESTADO,9,1) = mi_estado_cero
    -- por solicitud de Magda.
    SELECT NVL(SUM(VALOR_BRUTO), 0)
      INTO mi_valor_op
      FROM OGT_INFORMACION_EXOGENA A, OGT_ORDEN_PAGO B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO = B.CONSECUTIVO
       AND A.RUBRO_INTERNO = un_rubro_interno
       AND B.VIGENCIA = TO_CHAR(una_vigencia)
          --AND B.ENTIDAD > '0'
       AND B.UNIDAD_EJECUTORA = una_unidad_ejecutora
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_op
       AND B.ENTIDAD_PRESUPUESTO = una_entidad
       AND nvl(B.TIPO_OP,0) != mi_tipo_caja_menor
       AND B.IND_APROBADO = mi_valor_uno
       AND TO_NUMBER(TO_CHAR(B.fecha_aprobacion, 'MM')) <= un_mes
       AND TO_CHAR(B.FECHA_APROBACION, 'YYYY') = TO_CHAR(una_vigencia);

    SELECT NVL(SUM(VALOR_REGISTRO), 0)
      INTO mi_valor_ra
      FROM OGT_REGISTRO_PRESUPUESTAL A, OGT_RELACION_AUTORIZACION B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO = B.CONSECUTIVO
       AND A.RUBRO_INTERNO = un_rubro_interno
       AND B.VIGENCIA = TO_CHAR(una_vigencia)
       AND B.ENTIDAD = una_entidad
       AND B.UNIDAD_EJECUTORA = una_unidad_ejecutora
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_ra
       AND B.IND_APROBADO = mi_valor_uno
       AND SUBSTR(B.ESTADO, 4, 1) = mi_estado_uno
       AND TO_NUMBER(TO_CHAR(B.fecha_aprobacion, 'MM')) <= un_mes
       AND TO_CHAR(B.FECHA_APROBACION, 'YYYY') = TO_CHAR(una_vigencia)
       AND NVL(A.VALOR_REGISTRO, 0) > mi_valor_cero;
    RETURN(NVL(mi_valor_op, 0) + NVL(mi_valor_ra, 0));
  END OGT_FN_VALOR_ACUM;
  FUNCTION Ogt_Fn_Anul_Mes(una_vigencia         NUMBER,
                           una_entidad          VARCHAR2,
                           una_unidad_ejecutora VARCHAR2,
                           un_mes               NUMBER,
                           un_rubro_interno     NUMBER) RETURN NUMBER IS
  BEGIN
    SELECT NVL(SUM(VALOR_BRUTO), 0)
      INTO mi_valor_op
      FROM OGT_INFORMACION_EXOGENA A, OGT_ORDEN_PAGO B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO = B.CONSECUTIVO
       AND A.RUBRO_INTERNO = un_rubro_interno
       AND B.VIGENCIA = TO_CHAR(una_vigencia)
          --AND B.ENTIDAD > '0'
       AND B.UNIDAD_EJECUTORA = una_unidad_ejecutora
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_op
       AND B.ENTIDAD_PRESUPUESTO = una_entidad
       AND B.TIPO_OP != mi_tipo_caja_menor
       AND B.IND_APROBADO = mi_valor_uno
       AND B.IND_ANULADO = mi_valor_uno
       AND SUBSTR(B.ESTADO, 9, 1) = mi_estado_uno
       AND TO_NUMBER(TO_CHAR(B.FECHA_ANULACION, 'MM')) = un_mes
       AND TO_CHAR(B.FECHA_ANULACION, 'YYYY') = TO_CHAR(una_vigencia);
    SELECT NVL(SUM(VALOR_REGISTRO), 0)
      INTO mi_valor_ra
      FROM OGT_REGISTRO_PRESUPUESTAL A, OGT_RELACION_AUTORIZACION B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO = B.CONSECUTIVO
       AND A.RUBRO_INTERNO = un_rubro_interno
       AND B.VIGENCIA = TO_CHAR(una_vigencia)
       AND B.ENTIDAD = una_entidad
       AND B.UNIDAD_EJECUTORA = una_unidad_ejecutora
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_ra
       AND B.IND_APROBADO = mi_valor_uno
       AND B.IND_ANULADO = mi_valor_uno
       AND SUBSTR(B.ESTADO, 4, 1) = mi_estado_uno
       AND SUBSTR(B.ESTADO, 9, 1) = mi_estado_uno
       AND TO_NUMBER(TO_CHAR(B.FECHA_ANULACION, 'MM')) = un_mes
       AND TO_CHAR(B.FECHA_ANULACION, 'YYYY') = TO_CHAR(una_vigencia)
       AND NVL(A.VALOR_REGISTRO, 0) > mi_valor_cero;
    RETURN(NVL(mi_valor_op, 0) + NVL(mi_valor_ra, 0));
  END Ogt_Fn_Anul_Mes;
  --
  --
  FUNCTION OGT_FN_ANUL_ACUM(una_vigencia         NUMBER,
                            una_entidad          VARCHAR2,
                            una_unidad_ejecutora VARCHAR2,
                            un_mes               NUMBER,
                            un_rubro_interno     NUMBER) RETURN NUMBER IS
  BEGIN
    SELECT NVL(SUM(VALOR_BRUTO), 0)
      INTO mi_valor_op
      FROM OGT_INFORMACION_EXOGENA A, OGT_ORDEN_PAGO B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO = B.CONSECUTIVO
       AND A.RUBRO_INTERNO = un_rubro_interno
       AND B.VIGENCIA = TO_CHAR(una_vigencia)
          -- AND B.ENTIDAD > '0'
       AND B.UNIDAD_EJECUTORA = una_unidad_ejecutora
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_op
       AND B.ENTIDAD_PRESUPUESTO = una_entidad
       AND B.TIPO_OP != mi_tipo_caja_menor
       AND B.IND_APROBADO = mi_valor_uno
       AND B.IND_ANULADO = mi_valor_uno
       AND SUBSTR(B.ESTADO, 9, 1) = mi_estado_uno
       AND TO_NUMBER(TO_CHAR(B.FECHA_ANULACION, 'MM')) <= un_mes
       AND TO_CHAR(B.FECHA_ANULACION, 'YYYY') = TO_CHAR(una_vigencia);

    SELECT NVL(SUM(VALOR_REGISTRO), 0)
      INTO mi_valor_ra
      FROM OGT_REGISTRO_PRESUPUESTAL A, OGT_RELACION_AUTORIZACION B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO = B.CONSECUTIVO
       AND A.RUBRO_INTERNO = un_rubro_interno
       AND B.VIGENCIA = TO_CHAR(una_vigencia)
       AND B.ENTIDAD = una_entidad
       AND B.UNIDAD_EJECUTORA = una_unidad_ejecutora
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_ra
       AND B.IND_APROBADO = mi_valor_uno
       AND B.IND_ANULADO = mi_valor_uno
       AND SUBSTR(B.ESTADO, 4, 1) = mi_estado_uno
       AND SUBSTR(B.ESTADO, 9, 1) = mi_estado_uno
       AND TO_NUMBER(TO_CHAR(B.FECHA_ANULACION, 'MM')) <= un_mes
       AND TO_CHAR(B.FECHA_ANULACION, 'YYYY') = TO_CHAR(una_vigencia)
       AND NVL(A.VALOR_REGISTRO, 0) > mi_valor_cero;
    RETURN(NVL(mi_valor_op, 0) + NVL(mi_valor_ra, 0));
  END OGT_FN_ANUL_ACUM;
  --
  --
  -- MODIFICADA POR FANNY MALAGON 12-01-2005 PARA SACAR LOR REEMBOLSOS DE CAJA MENOR
  -- MODIFICADA POR AAGUIRRE 13-05-2005 PARA ATENDER RQ 641

  FUNCTION Ogt_Fn_Reint_Mes(una_vigencia         NUMBER,
                            una_entidad          VARCHAR2,
                            una_unidad_ejecutora VARCHAR2,
                            un_mes               NUMBER,
                            un_rubro_interno     NUMBER) RETURN NUMBER IS
  BEGIN
    SELECT SUM(A.VALOR)
      INTO mi_valor_ar
      FROM OGT_DETALLE_ACTAS A, OGT_ACTAS B
     WHERE A.CONSECUTIVO = B.CONSECUTIVO
       AND A.VIGENCIA = B.VIGENCIA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       --AND B.VIGENCIA = TO_CHAR(una_vigencia)
       --AND B.ENTIDAD = mi_entidad_reintegros
       --AND B.UNIDAD_EJECUTORA = mi_unidad_ejecutora_reintegros
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_ar
       AND A.DOC_VIGENCIA = TO_CHAR(una_vigencia)
       AND A.DOC_ENTIDAD = una_entidad
       AND A.DOC_UNIDAD_EJECUTORA = una_unidad_ejecutora
       AND A.RUBRO_INTERNO = un_rubro_interno
       AND TO_NUMBER(TO_CHAR(B.fecha, 'MM')) = un_mes
       AND nvl(B.TIPO_OP,0) != mi_tipo_caja_menor;
       --AND A.TIPO_DOCUMENTO = mi_tipo_documento_ar;
    RETURN NVL(mi_valor_ar, 0);
  END Ogt_Fn_Reint_Mes;
  --
  --
  -- MODIFICADA POR FANNY MALAGON 12-01-2005 PARA SACAR LOR REEMBOLSOS DE CAJA MENOR
  -- MODIFCADA FANNY SE QUITARON CRITERIOS DEL WHERE DE OP Y SE ADICIONO LA INF DE LA NOMINA
  FUNCTION OGT_FN_REINT_ACUM(una_vigencia         NUMBER,
                             una_entidad          VARCHAR2,
                             una_unidad_ejecutora VARCHAR2,
                             un_mes               NUMBER,
                             un_rubro_interno     NUMBER) RETURN NUMBER IS
  BEGIN
    SELECT SUM(A.VALOR)
      INTO mi_valor_OP
      FROM OGT_DETALLE_ACTAS A, OGT_ACTAS B
     WHERE A.CONSECUTIVO = B.CONSECUTIVO
       AND A.VIGENCIA = B.VIGENCIA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
          /*      AND B.VIGENCIA = TO_CHAR(una_vigencia)
                AND B.ENTIDAD = mi_entidad_reintegros
                AND B.UNIDAD_EJECUTORA = mi_unidad_ejecutora_reintegros
                */
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_ar
       AND A.DOC_VIGENCIA = TO_CHAR(una_vigencia)
       AND A.DOC_ENTIDAD = una_entidad
       AND A.DOC_UNIDAD_EJECUTORA = una_unidad_ejecutora
       AND A.RUBRO_INTERNO = un_rubro_interno
       AND TO_NUMBER(TO_CHAR(B.fecha, 'MM')) <= un_mes
       AND NVL(B.TIPO_OP, 3) != mi_tipo_caja_menor
       AND A.TIPO_DOCUMENTO = mi_tipo_documento_ar;
    /*
    SELECT SUM(NVL(VALOR_REGISTRO,0))
    INTO MI_VALOR_RA
    FROM OGT_REGISTRO_PRESUPUESTAL A, OGT_RELACION_AUTORIZACION B
    WHERE  A.VIGENCIA = B.VIGENCIA
    AND A.ENTIDAD = B.ENTIDAD
    AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
    AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
    AND A.CONSECUTIVO = B.CONSECUTIVO
    AND A.RUBRO_INTERNO = un_rubro_interno
    AND B.VIGENCIA = TO_CHAR(una_vigencia)
    AND B.ENTIDAD = una_entidad
    AND B.UNIDAD_EJECUTORA = una_unidad_ejecutora
    AND B.IND_APROBADO = mi_valor_uno
    AND TO_NUMBER(TO_CHAR(B.fecha_aprobacion,'MM')) <= un_mes
    AND A.VALOR_REGISTRO < mi_valor_cero
    AND TO_CHAR(B.FECHA_APROBACION,'YYYY') = TO_CHAR(una_vigencia);
    */
    RETURN(NVL(MI_VALOR_OP, 0)); --  NVL(mi_valor_ar,0) ;
  END OGT_FN_REINT_ACUM;

  -- FANNY 05-08-04
  -- FUNCION QUE RETORNA EL VALOR AJUSTADO EN UN MES
  FUNCTION OGT_FN_AJUSTE_MES(una_vigencia         NUMBER,
                             una_entidad          VARCHAR2,
                             una_unidad_ejecutora VARCHAR2,
                             un_mes               NUMBER,
                             un_rubro_interno     NUMBER) RETURN NUMBER IS
  BEGIN
    SELECT SUM(NVL(VALOR_REGISTRO, 0))
      INTO MI_VALOR_RA
      FROM OGT_REGISTRO_PRESUPUESTAL A, OGT_RELACION_AUTORIZACION B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO = B.CONSECUTIVO
       AND A.RUBRO_INTERNO = un_rubro_interno
       AND B.VIGENCIA = TO_CHAR(una_vigencia)
       AND B.ENTIDAD = una_entidad
       AND B.UNIDAD_EJECUTORA = una_unidad_ejecutora
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_ra
       AND B.IND_APROBADO = mi_valor_uno
       AND SUBSTR(B.ESTADO, 4, 1) = mi_estado_uno
       AND SUBSTR(B.ESTADO, 9, 1) = mi_estado_cero
       AND TO_NUMBER(TO_CHAR(B.fecha_aprobacion, 'MM')) = un_mes
       AND A.VALOR_REGISTRO < mi_valor_cero
       AND TO_CHAR(B.FECHA_APROBACION, 'YYYY') = TO_CHAR(una_vigencia);
    RETURN NVL(MI_VALOR_RA, 0);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR('-20001',
                              'Error en OGT_FN_AJUSTE_MES ' || SQLERRM);
  END OGT_FN_AJUSTE_MES;
  --
  --
  -- FANNY 05-08-04
  -- FUNCION QUE RETORNA EL VALOR AJUSTADO ACUMULADO DE UN A?O A UN MES
  FUNCTION OGT_FN_ACUM_AJUSTE(una_vigencia         NUMBER,
                              una_entidad          VARCHAR2,
                              una_unidad_ejecutora VARCHAR2,
                              un_mes               NUMBER,
                              un_rubro_interno     NUMBER) RETURN NUMBER IS
  BEGIN
    SELECT SUM(NVL(VALOR_REGISTRO, 0))
      INTO MI_VALOR_RA
      FROM OGT_REGISTRO_PRESUPUESTAL A, OGT_RELACION_AUTORIZACION B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO = B.CONSECUTIVO
       AND A.RUBRO_INTERNO = un_rubro_interno
       AND B.VIGENCIA = TO_CHAR(una_vigencia)
       AND B.ENTIDAD = una_entidad
       AND B.UNIDAD_EJECUTORA = una_unidad_ejecutora
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_ra
       AND B.IND_APROBADO = mi_valor_uno
       AND SUBSTR(B.ESTADO, 4, 1) = mi_estado_uno
       AND SUBSTR(B.ESTADO, 9, 1) = mi_estado_cero
       AND TO_NUMBER(TO_CHAR(B.fecha_aprobacion, 'MM')) <= un_mes
       AND A.VALOR_REGISTRO < mi_valor_cero
       AND TO_CHAR(B.FECHA_APROBACION, 'YYYY') = TO_CHAR(una_vigencia);
    RETURN NVL(MI_VALOR_RA, 0);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR('-20001',
                              'Error en OGT_FN_ACUM_AJUSTE ' || SQLERRM);
  END OGT_FN_ACUM_AJUSTE;
  --
  --
  --AAGUIRRE 26-11-2004 O.K.
  --FUNCION QUE DEVUELVE EL VALOR DE LOS GIROS MENSUALES
  --DE UN RUBRO DE UNA RESERVA
  -- BASADA EN OGT_FN_VALOR_MES
  FUNCTION OGT_FN_GIROSMES_RESERVA(una_vigencia               NUMBER,
                                   un_codigo_compania         VARCHAR2,
                                   un_codigo_unidad_ejecutora VARCHAR2,
                                   un_mes                     VARCHAR2,
                                   un_interno                 NUMBER)
    RETURN NUMBER IS
  BEGIN
    SELECT NVL(SUM(VALOR_BRUTO), 0)
      INTO mi_valor_op
      FROM OGT_INFORMACION_EXOGENA A, OGT_ORDEN_PAGO B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO = B.CONSECUTIVO
       AND A.RUBRO_INTERNO = un_interno
       AND B.VIGENCIA = TO_CHAR(TO_NUMBER(una_vigencia) - 1)
          --AND B.ENTIDAD > '0'
       AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_op
       AND B.ENTIDAD_PRESUPUESTO = un_codigo_compania
       AND B.TIPO_OP != mi_tipo_caja_menor
       AND B.IND_APROBADO = mi_valor_uno
       AND TO_CHAR(B.fecha_aprobacion, 'MM') = un_mes
       AND TO_CHAR(B.FECHA_APROBACION, 'YYYY') = TO_CHAR(una_vigencia);

    SELECT NVL(SUM(VALOR_REGISTRO), 0)
      INTO mi_valor_ra
      FROM OGT_REGISTRO_PRESUPUESTAL A, OGT_RELACION_AUTORIZACION B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO = B.CONSECUTIVO
       AND A.RUBRO_INTERNO = un_interno
       AND B.VIGENCIA = TO_CHAR(TO_NUMBER(una_vigencia) - 1)
       AND B.ENTIDAD = un_codigo_compania
       AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_ra
       AND B.IND_APROBADO = mi_valor_uno
       AND TO_CHAR(B.fecha_aprobacion, 'MM') = un_mes
       AND TO_CHAR(B.FECHA_APROBACION, 'YYYY') = TO_CHAR(una_vigencia)
       AND SUBSTR(B.ESTADO, 4, 1) = mi_estado_uno
       AND NVL(A.VALOR_REGISTRO, 0) > mi_valor_cero;
    RETURN(NVL(mi_valor_op, 0) + NVL(mi_valor_ra, 0));
  END OGT_FN_GIROSMES_RESERVA;
  -- AAGUIRRE 23-11-2004 O.K.
  -- FUNCION QUE RETORNA EL VALOR DE LOS AJUSTES MENSUALES DE RUBRO
  -- BASADA EN OGT_FN_AJUSTE_MES
  FUNCTION OGT_FN_AJUSTESMES_RESERVA(una_vigencia               NUMBER,
                                     un_codigo_compania         VARCHAR2,
                                     un_codigo_unidad_ejecutora VARCHAR2,
                                     un_mes                     VARCHAR2,
                                     un_interno                 NUMBER)
    RETURN NUMBER IS
  BEGIN
    SELECT SUM(NVL(VALOR_REGISTRO, 0))
      INTO MI_VALOR_RA
      FROM OGT_REGISTRO_PRESUPUESTAL A, OGT_RELACION_AUTORIZACION B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO = B.CONSECUTIVO
       AND A.RUBRO_INTERNO = un_interno
       AND B.VIGENCIA = TO_CHAR(TO_NUMBER(una_vigencia) - 1)
       AND B.ENTIDAD = un_codigo_compania
       AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_ra
       AND B.IND_APROBADO = mi_valor_uno
       AND SUBSTR(B.ESTADO, 4, 1) = mi_estado_uno
       AND SUBSTR(B.ESTADO, 9, 1) = mi_estado_cero
       AND TO_CHAR(B.fecha_aprobacion, 'MM') = un_mes
       AND TO_NUMBER(TO_CHAR(B.FECHA_APROBACION, 'YYYY')) =
           TO_NUMBER(una_vigencia)
       AND A.VALOR_REGISTRO < mi_valor_cero;
    RETURN NVL(MI_VALOR_RA, 0);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR('-20001',
                              'Error en OGT_FN_AJUSTE_MES ' || SQLERRM);
  END OGT_FN_AJUSTESMES_RESERVA;
  --
  -- AAGUIRRE 23-11-2004 O.K.
  -- FUNCION QUE RETORNA EL VALOR DE LOS REINTEGROS MENSUALES DE RUBRO DE
  -- UNA RESERVA
  -- BASADA EN OGT_FN_REINT_MES
  -- MODIFICADA POR FANNY MALAGON 12-01-2005 PARA SACAR LOR REEMBOLSOS DE CAJA MENOR
  -- MODIFCADA FANNY 14-01-2005 SE QUITARON CRITERIOS DEL WHERE Y SE ADICIONO INF DE LA NOMINA
  FUNCTION OGT_FN_REINTEGROSMES_RESERVA(una_vigencia               NUMBER,
                                        un_codigo_compania         VARCHAR2 --una_entidad VARCHAR2
                                       ,
                                        un_codigo_unidad_ejecutora VARCHAR2 --una_unidad_ejecutora VARCHAR2
                                       ,
                                        un_mes                     VARCHAR2,
                                        un_interno                 VARCHAR2 --un_rubro_interno NUMBER
                                        ) RETURN NUMBER IS
  BEGIN
    SELECT SUM(A.VALOR)
      INTO mi_valor_OP
      FROM OGT_DETALLE_ACTAS A, OGT_ACTAS B
     WHERE A.CONSECUTIVO = B.CONSECUTIVO
       AND A.VIGENCIA = B.VIGENCIA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
          /*      AND B.VIGENCIA = TO_NUMBER(una_vigencia)
                AND B.ENTIDAD = mi_entidad_reintegros
                AND B.UNIDAD_EJECUTORA = mi_unidad_ejecutora_reintegros
                */
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_ar
       AND TO_CHAR(B.fecha, 'MM') = un_mes
       AND A.DOC_VIGENCIA = TO_CHAR(TO_NUMBER(una_vigencia) - 1)
       AND A.DOC_ENTIDAD = un_codigo_compania
       AND A.DOC_UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
       AND NVL(B.TIPO_OP, 3) != mi_tipo_caja_menor
       AND A.RUBRO_INTERNO = un_interno;
    /*
    SELECT SUM(NVL(VALOR_REGISTRO,0))
    INTO MI_VALOR_RA
    FROM OGT_REGISTRO_PRESUPUESTAL A, OGT_RELACION_AUTORIZACION B
    WHERE  A.VIGENCIA = B.VIGENCIA
    AND A.ENTIDAD = B.ENTIDAD
    AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
    AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
    AND A.CONSECUTIVO = B.CONSECUTIVO
    AND A.RUBRO_INTERNO = un_interno
    AND B.VIGENCIA = TO_CHAR(una_vigencia)
    AND B.ENTIDAD = un_codigo_compania
    AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
    AND B.IND_APROBADO = mi_valor_uno
    AND TO_NUMBER(TO_CHAR(B.fecha_aprobacion,'MM')) <= un_mes
    AND A.VALOR_REGISTRO < mi_valor_cero
    AND TO_CHAR(B.FECHA_APROBACION,'YYYY') = TO_CHAR(TO_NUMBER(una_vigencia)-1);
    */
    RETURN(NVL(MI_VALOR_OP, 0)); --NVL(mi_valor_ar,0)
  END OGT_FN_REINTEGROSMES_RESERVA;
  --AAGUIRRE 26-11-2004 O.K.
  --FUNCION QUE DEVUELVE EL VALOR DE LAS ANULACIONES MENSUALES DE RUBRO
  --DE UNA RESERVA
  -- BASADA EN OGT_FN_ANUL_MES
  FUNCTION OGT_FN_ANULGIROSMES_RESERVA(una_vigencia               NUMBER,
                                       un_codigo_compania         VARCHAR2 --una_entidad VARCHAR2
                                      ,
                                       un_codigo_unidad_ejecutora VARCHAR2 --una_unidad_ejecutora VARCHAR2
                                      ,
                                       un_mes                     VARCHAR2,
                                       un_interno                 NUMBER --un_rubro_interno NUMBER
                                       ) RETURN NUMBER IS
  BEGIN
    SELECT NVL(SUM(VALOR_BRUTO), 0)
      INTO mi_valor_op
      FROM OGT_INFORMACION_EXOGENA A, OGT_ORDEN_PAGO B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO = B.CONSECUTIVO
       AND A.RUBRO_INTERNO = un_interno
       AND B.VIGENCIA = TO_CHAR(TO_NUMBER(una_vigencia) - 1)
          -- AND B.ENTIDAD > '0'
       AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_op
       AND B.ENTIDAD_PRESUPUESTO = un_codigo_compania
       AND B.TIPO_OP != mi_tipo_caja_menor
       AND B.IND_APROBADO = mi_valor_uno
       AND B.IND_ANULADO = mi_valor_uno
       AND SUBSTR(B.ESTADO, 9, 1) = mi_estado_uno
       AND TO_CHAR(B.FECHA_ANULACION, 'MM') = un_mes
       AND TO_CHAR(B.FECHA_ANULACION, 'YYYY') = TO_CHAR(una_vigencia);
    SELECT NVL(SUM(VALOR_REGISTRO), 0)
      INTO mi_valor_ra
      FROM OGT_REGISTRO_PRESUPUESTAL A, OGT_RELACION_AUTORIZACION B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO = B.CONSECUTIVO
       AND A.RUBRO_INTERNO = un_interno
       AND B.VIGENCIA = TO_CHAR(TO_NUMBER(una_vigencia) - 1)
       AND B.ENTIDAD = un_codigo_compania
       AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_ra
       AND B.IND_APROBADO = mi_valor_uno
       AND B.IND_ANULADO = mi_valor_uno
       AND SUBSTR(B.ESTADO, 4, 1) = mi_estado_uno
       AND SUBSTR(B.ESTADO, 9, 1) = mi_estado_uno
       AND TO_CHAR(B.FECHA_ANULACION, 'MM') = un_mes
       AND TO_CHAR(B.FECHA_ANULACION, 'YYYY') = TO_CHAR(una_vigencia)
       AND NVL(A.VALOR_REGISTRO, 0) > mi_valor_cero;
    RETURN(NVL(mi_valor_op, 0) + NVL(mi_valor_ra, 0));
  END OGT_FN_ANULGIROSMES_RESERVA;
  --AAGUIRRE 26-11-2004 O.K.
  --FUNCION QUE DEVUELVE EL VALOR DE LOS GIROS ACUMULADOS A UN MES
  --DE UN RUBRO DE UNA RESERVA
  -- BASADA EN OGT_FN_VALOR_MES
  FUNCTION OGT_FN_GIROSACUM_RESERVA(una_vigencia               NUMBER,
                                    un_codigo_compania         VARCHAR2,
                                    un_codigo_unidad_ejecutora VARCHAR2,
                                    un_mes                     VARCHAR2,
                                    un_interno                 NUMBER)
    RETURN NUMBER IS
  BEGIN
    -- 18-08-2004. Sergio.
    -- Se pone en comentario la instruccion AND SUBSTR(B.ESTADO,9,1) = mi_estado_cero
    -- por solicitud de Magda.(En la funcion OGT_FN_VALOR_MES base de esta)
    --
    SELECT NVL(SUM(VALOR_BRUTO), 0)
      INTO mi_valor_op
      FROM OGT_INFORMACION_EXOGENA A, OGT_ORDEN_PAGO B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO = B.CONSECUTIVO
       AND A.RUBRO_INTERNO = un_interno
       AND A.VIGENCIA = TO_CHAR(TO_NUMBER(una_vigencia) - 1)
       AND A.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
       AND B.ENTIDAD_PRESUPUESTO = un_codigo_compania
       AND B.TIPO_OP != mi_tipo_caja_menor
       AND B.IND_APROBADO = mi_valor_uno
       AND TO_CHAR(B.fecha_aprobacion, 'MM') <= un_mes
       AND TO_CHAR(B.FECHA_APROBACION, 'YYYY') = TO_CHAR(una_vigencia);

    SELECT NVL(SUM(VALOR_REGISTRO), 0)
      INTO mi_valor_ra
      FROM OGT_REGISTRO_PRESUPUESTAL A, OGT_RELACION_AUTORIZACION B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO = B.CONSECUTIVO
       AND A.RUBRO_INTERNO = un_interno
       AND A.CONSECUTIVO > mi_estado_cero
       AND B.VIGENCIA = TO_CHAR(TO_NUMBER(una_vigencia) - 1)
       AND B.ENTIDAD = un_codigo_compania
       AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_ra
       AND B.IND_APROBADO = mi_valor_uno
       AND SUBSTR(B.ESTADO, 4, 1) = mi_estado_uno
       AND TO_CHAR(B.fecha_aprobacion, 'MM') <= un_mes
       AND TO_CHAR(B.FECHA_APROBACION, 'YYYY') = TO_CHAR(una_vigencia)
       AND NVL(A.VALOR_REGISTRO, 0) > mi_valor_cero;
    RETURN(NVL(mi_valor_op, 0) + NVL(mi_valor_ra, 0));
  END OGT_FN_GIROSACUM_RESERVA;
  --AAGUIRRE 26-11-2004 O.K.
  --FUNCION QUE DEVUELVE EL VALOR DE LOS AJUSTES ACUMULADOS  A UN MES
  --MENSUALES DE RUBRO DE UNA RESERVA
  --BASADA EN OGT_FN_ACUM_MES
  FUNCTION OGT_FN_AJUSTESACUM_RESERVA(una_vigencia               NUMBER,
                                      un_codigo_compania         VARCHAR2 --una_entidad VARCHAR2
                                     ,
                                      un_codigo_unidad_ejecutora VARCHAR2 --una_unidad_ejecutora VARCHAR2
                                     ,
                                      un_mes                     VARCHAR2,
                                      un_interno                 NUMBER --un_rubro_interno NUMBER
                                      ) RETURN NUMBER IS
  BEGIN
    SELECT SUM(NVL(VALOR_REGISTRO, 0))
      INTO MI_VALOR_RA
      FROM OGT_REGISTRO_PRESUPUESTAL A, OGT_RELACION_AUTORIZACION B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO = B.CONSECUTIVO
       AND A.RUBRO_INTERNO = un_interno
       AND B.VIGENCIA = TO_CHAR(TO_NUMBER(una_vigencia) - 1)
       AND B.ENTIDAD = un_codigo_compania
       AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_ra
       AND B.IND_APROBADO = mi_valor_uno
       AND SUBSTR(B.ESTADO, 4, 1) = mi_estado_uno
       AND SUBSTR(B.ESTADO, 9, 1) = mi_estado_cero
       AND TO_CHAR(B.fecha_aprobacion, 'MM') <= un_mes
       AND TO_CHAR(B.FECHA_APROBACION, 'YYYY') = TO_CHAR(una_vigencia)
       AND A.VALOR_REGISTRO < mi_valor_cero;
    RETURN NVL(MI_VALOR_RA, 0);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR('-20001',
                              'Error en OGT_FN_ACUM_AJUSTE ' || SQLERRM);
  END OGT_FN_AJUSTESACUM_RESERVA;
  --AAGUIRRE 26-11-2004 O.K.
  --FUNCION QUE DEVUELVE EL VALOR DE LOS REINTEGROS ACUMULADOS
  --DE RUBRO DE UNA RESERVA
  --BASADA EN OGT_FN_REINT_MES
  -- MODIFICADA POR FANNY MALAGON 12-01-2005 PARA SACAR LOR REEMBOLSOS DE CAJA MENOR
  -- MODIFCADA FANNY 14-01-2005 SE QUITO UN CRITERIO DEL WHERE Y SE ADICIONO LA INFORMACION DE NOMINA
  FUNCTION OGT_FN_REINTEGROSACUM_RESERVA(una_vigencia               NUMBER,
                                         un_codigo_compania         VARCHAR2 --una_entidad VARCHAR2
                                        ,
                                         un_codigo_unidad_ejecutora VARCHAR2 --una_unidad_ejecutora VARCHAR2
                                        ,
                                         un_mes                     VARCHAR2,
                                         un_interno                 NUMBER --un_rubro_interno NUMBER
                                         ) RETURN NUMBER IS
  BEGIN
    SELECT SUM(A.VALOR)
      INTO mi_valor_OP
      FROM OGT_DETALLE_ACTAS A, OGT_ACTAS B
     WHERE A.CONSECUTIVO = B.CONSECUTIVO
       AND A.VIGENCIA = B.VIGENCIA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
          /*      AND B.VIGENCIA = TO_CHAR(una_vigencia)
                AND B.ENTIDAD =  mi_entidad_reintegros
                AND B.UNIDAD_EJECUTORA = mi_unidad_ejecutora_reintegros
                */
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_ar
       AND TO_CHAR(B.fecha, 'MM') <= un_mes
       AND A.RUBRO_INTERNO = un_interno
       AND A.DOC_VIGENCIA = TO_CHAR(TO_NUMBER(una_vigencia) - 1)
       AND A.DOC_ENTIDAD = un_codigo_compania
       AND A.DOC_UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
       AND NVL(B.TIPO_OP, 3) != mi_tipo_caja_menor
       AND A.DOC_UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora;
    /*
    SELECT SUM(NVL(VALOR_REGISTRO,0))
    INTO MI_VALOR_RA
    FROM OGT_REGISTRO_PRESUPUESTAL A, OGT_RELACION_AUTORIZACION B
    WHERE  A.VIGENCIA = B.VIGENCIA
    AND A.ENTIDAD = B.ENTIDAD
    AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
    AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
    AND A.CONSECUTIVO = B.CONSECUTIVO
    AND A.RUBRO_INTERNO = un_interno
    AND B.VIGENCIA = TO_CHAR(una_vigencia)
    AND B.ENTIDAD = un_codigo_compania
    AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
    AND B.IND_APROBADO = mi_valor_uno
    AND TO_NUMBER(TO_CHAR(B.fecha_aprobacion,'MM')) <= un_mes
    AND A.VALOR_REGISTRO < mi_valor_cero
    AND TO_CHAR(B.FECHA_APROBACION,'YYYY') = TO_CHAR(TO_NUMBER(una_vigencia)-1);
    */
    RETURN(NVL(mi_valor_op, 0)); --NVL(MI_VALOR_ar,0))

  END OGT_FN_REINTEGROSACUM_RESERVA;

  --AAGUIRRE 26-11-2004
  --FUNCION QUE DEVUELVE EL VALOR DE LAS ANULACIONES ACUMULADAS DE RUBRO DE
  --UNA RESERVA
  --BASADA EN OGT_FN_VALOR_ACUM
  FUNCTION OGT_FN_ANULGIROSACUM_RESERVA(una_vigencia               NUMBER,
                                        un_codigo_compania         VARCHAR2,
                                        un_codigo_unidad_ejecutora VARCHAR2,
                                        un_mes                     VARCHAR2,
                                        un_interno                 NUMBER)
    RETURN NUMBER IS
  BEGIN
    SELECT NVL(SUM(VALOR_BRUTO), 0)
      INTO mi_valor_op
      FROM OGT_INFORMACION_EXOGENA A, OGT_ORDEN_PAGO B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO = B.CONSECUTIVO
       AND A.RUBRO_INTERNO = un_interno
       AND B.VIGENCIA = TO_CHAR(TO_NUMBER(una_vigencia) - 1)
          --AND B.ENTIDAD > '0'
       AND A.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
       AND B.ENTIDAD_PRESUPUESTO = un_codigo_compania
       AND B.TIPO_OP != mi_tipo_caja_menor
       AND B.IND_APROBADO = mi_valor_uno
       AND B.IND_ANULADO = mi_valor_uno
       AND SUBSTR(B.ESTADO, 9, 1) = mi_estado_uno
       AND TO_NUMBER(TO_CHAR(B.fecha_anulacion, 'MM')) <= un_mes
       AND TO_CHAR(B.FECHA_ANULACION, 'YYYY') = TO_CHAR(una_vigencia);

    SELECT NVL(SUM(VALOR_REGISTRO), 0)
      INTO mi_valor_ra
      FROM OGT_REGISTRO_PRESUPUESTAL A, OGT_RELACION_AUTORIZACION B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO = B.CONSECUTIVO
       AND A.RUBRO_INTERNO = un_interno
       AND B.VIGENCIA = TO_CHAR(TO_NUMBER(una_vigencia) - 1)
       AND B.ENTIDAD = un_codigo_compania
       AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
       AND B.IND_APROBADO = mi_valor_uno
       AND B.IND_ANULADO = mi_estado_uno
       AND SUBSTR(B.ESTADO, 4, 1) = mi_estado_uno
       AND SUBSTR(B.ESTADO, 9, 1) = mi_estado_uno
       AND TO_NUMBER(TO_CHAR(B.fecha_anulacion, 'MM')) <= un_mes
       AND TO_CHAR(B.FECHA_ANULACION, 'YYYY') = TO_CHAR(una_vigencia)
       AND NVL(A.VALOR_REGISTRO, 0) > mi_valor_cero;
    RETURN(NVL(mi_valor_op, 0) + NVL(mi_valor_ra, 0));
  END OGT_FN_ANULGIROSACUM_RESERVA;
  --AAGUIRRE 26-11-2004 O.K.
  --FUNCION QUE DEVUELVE EL VALOR ORDENES DE PAGO Y RELACIONES DE AUTORIZACION
  --ACUMULADO DE UNA RESERVA
  --BASADA EN OGT_FN_VALOR_ACUM
  FUNCTION OGT_FN_GIROSACUM_RESERVA_FC(una_vigencia                 NUMBER,
                                       un_codigo_compania           VARCHAR2,
                                       un_codigo_unidad_ejecutora   VARCHAR2,
                                       numero_registro_presupuestal NUMBER,
                                       un_interno                   NUMBER,
                                       fecha_corte                  DATE)
    RETURN NUMBER IS
  BEGIN
    -- 18-08-2004. Sergio.
    -- Se pone en comentario la instruccion AND SUBSTR(B.ESTADO,9,1) = mi_estado_cero
    -- por solicitud de Magda.
    SELECT NVL(SUM(VALOR_BRUTO), 0)
      INTO mi_valor_op
      FROM OGT_INFORMACION_EXOGENA A, OGT_ORDEN_PAGO B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO = B.CONSECUTIVO
       AND A.RUBRO_INTERNO = un_interno
       AND B.VIGENCIA = TO_CHAR(TO_NUMBER(una_vigencia) - 1)
          --AND B.ENTIDAD > '0'
       AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_op
       AND B.ENTIDAD_PRESUPUESTO = un_codigo_compania
       AND B.TIPO_OP != mi_tipo_caja_menor
       AND B.IND_APROBADO = mi_valor_uno
       AND B.FECHA_APROBACION <= fecha_corte
          --AND SUBSTR(B.ESTADO,9,1) = mi_estado_cero
       AND TO_CHAR(B.FECHA_APROBACION, 'YYYY') = TO_CHAR(una_vigencia);

    SELECT NVL(SUM(VALOR_REGISTRO), 0)
      INTO mi_valor_ra
      FROM OGT_REGISTRO_PRESUPUESTAL A, OGT_RELACION_AUTORIZACION B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO = B.CONSECUTIVO
       AND A.RUBRO_INTERNO = un_interno
       AND B.VIGENCIA = TO_CHAR(una_vigencia)
       AND B.ENTIDAD = un_codigo_compania
       AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_ra
       AND B.IND_APROBADO = mi_valor_uno
       AND B.FECHA_APROBACION <= fecha_corte
       AND SUBSTR(B.ESTADO, 4, 1) = mi_estado_uno
       AND TO_CHAR(B.FECHA_APROBACION, 'YYYY') = TO_CHAR(una_vigencia)
       AND NVL(A.VALOR_REGISTRO, 0) > mi_valor_cero;
    RETURN(NVL(mi_valor_op, 0) + NVL(mi_valor_ra, 0));
  END OGT_FN_GIROSACUM_RESERVA_FC;
  --AAGUIRRE 29-11-2004 O.K.
  --FUNCION QUE DEVUELVE EL VALOR DE LAS ANULACIONES MENSUALES DE ORDENES DE PAGO
  --Y RELACIONES DE AUTORIZACION DE UNA RESERVA
  --BASADA EN OGT_FN_ANUL_MES
  FUNCTION OGT_FN_ANULACUMGIRO_RESERVA_FC(una_vigencia                 NUMBER,
                                          un_codigo_compania           VARCHAR2,
                                          un_codigo_unidad_ejecutora   VARCHAR2,
                                          numero_registro_presupuestal NUMBER,
                                          un_interno                   NUMBER,
                                          fecha_corte                  DATE)
    RETURN NUMBER IS
  BEGIN
    SELECT NVL(SUM(VALOR_BRUTO), 0)
      INTO mi_valor_op
      FROM OGT_INFORMACION_EXOGENA A, OGT_ORDEN_PAGO B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO = B.CONSECUTIVO
       AND A.RUBRO_INTERNO = un_interno
       AND B.VIGENCIA = TO_CHAR(TO_NUMBER(una_vigencia) - 1)
       AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_op
       AND B.ENTIDAD_PRESUPUESTO = un_codigo_compania
       AND B.TIPO_OP != mi_tipo_caja_menor
       AND B.FECHA_APROBACION <= fecha_corte
       AND IND_APROBADO = mi_valor_uno
       AND IND_ANULADO = mi_valor_uno
       AND SUBSTR(B.ESTADO, 9, 1) = mi_estado_uno
       AND TO_CHAR(B.FECHA_ANULACION, 'YYYY') = TO_CHAR(una_vigencia);

    SELECT NVL(SUM(VALOR_REGISTRO), 0)
      INTO mi_valor_ra
      FROM OGT_REGISTRO_PRESUPUESTAL A, OGT_RELACION_AUTORIZACION B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO = B.CONSECUTIVO
       AND A.RUBRO_INTERNO = un_interno
       AND A.CONSECUTIVO > mi_estado_cero
       AND B.VIGENCIA = TO_CHAR(TO_NUMBER(una_vigencia) - 1)
       AND B.ENTIDAD = un_codigo_compania
       AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_ra
       AND B.IND_APROBADO = mi_valor_uno
       AND B.IND_ANULADO = mi_valor_uno
       AND B.FECHA_APROBACION <= fecha_corte
       AND SUBSTR(B.ESTADO, 4, 1) = mi_estado_uno
       AND SUBSTR(B.ESTADO, 9, 1) = mi_estado_uno
       AND TO_CHAR(FECHA_ANULACION, 'YYYY') = TO_CHAR(una_vigencia)
       AND NVL(A.VALOR_REGISTRO, 0) > mi_valor_cero;
    RETURN(NVL(mi_valor_op, 0) + NVL(mi_valor_ra, 0));
  END OGT_FN_ANULACUMGIRO_RESERVA_FC;
  --AAGUIRRE 29-11-2004 O.K
  --FUNCION QUE DEVUELVE EL VALOR DE LOS GIROS ACUMULADOS A UN MES
  --DE UN RUBRO
  -- BASADA EN OGT_FN_VALOR_MES
  FUNCTION OGT_FN_GIROSMES_VIGENCIA(una_vigencia               NUMBER,
                                    un_codigo_compania         VARCHAR2 --una_entidad VARCHAR2
                                   ,
                                    un_codigo_unidad_ejecutora VARCHAR2 --una_unidad_ejecutora VARCHAR2
                                   ,
                                    un_mes                     NUMBER --,un_rubro_interno NUMBER
                                   ,
                                    un_interno                 NUMBER)
    RETURN NUMBER IS
  BEGIN
    SELECT NVL(SUM(VALOR_BRUTO), 0)
      INTO mi_valor_op
      FROM OGT_INFORMACION_EXOGENA A, OGT_ORDEN_PAGO B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO = B.CONSECUTIVO
       AND A.RUBRO_INTERNO = un_interno
       AND B.VIGENCIA = TO_CHAR(una_vigencia)
          --AND B.ENTIDAD > '0'
       AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_op
       AND B.ENTIDAD_PRESUPUESTO = un_codigo_compania
       AND B.TIPO_OP != mi_tipo_caja_menor
       AND IND_APROBADO = mi_valor_uno
       AND TO_NUMBER(TO_CHAR(B.fecha_aprobacion, 'MM')) = un_mes
       AND TO_CHAR(B.FECHA_APROBACION, 'YYYY') = TO_CHAR(una_vigencia);

    SELECT NVL(SUM(VALOR_REGISTRO), 0)
      INTO mi_valor_ra
      FROM OGT_REGISTRO_PRESUPUESTAL A, OGT_RELACION_AUTORIZACION B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO = B.CONSECUTIVO
       AND A.RUBRO_INTERNO = un_interno
       AND B.VIGENCIA = TO_CHAR(una_vigencia)
       AND B.ENTIDAD = un_codigo_compania
       AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_ra
       AND B.IND_APROBADO = mi_valor_uno
       AND SUBSTR(B.ESTADO, 4, 1) = mi_estado_uno
       AND TO_NUMBER(TO_CHAR(B.fecha_aprobacion, 'MM')) = un_mes
       AND TO_CHAR(B.FECHA_APROBACION, 'YYYY') = TO_CHAR(una_vigencia)
       AND NVL(A.VALOR_REGISTRO, 0) > mi_valor_cero;
    RETURN(NVL(mi_valor_op, 0) + NVL(mi_valor_ra, 0));
  END OGT_FN_GIROSMES_VIGENCIA;
  --
  --AAGUIRRE 29-11-2004 OK
  --FUNCION QUE DEVUELVE EL VALOR DE LOS AJUSTES ACUMULADOS MENSUALES DE RUBRO
  --BASADA EN OGT_FN_ACUM_MES
  FUNCTION OGT_FN_AJUSTESMES_VIGENCIA(una_vigencia               NUMBER,
                                      un_codigo_compania         VARCHAR2 --una_entidad VARCHAR2
                                     ,
                                      un_codigo_unidad_ejecutora VARCHAR2 --una_unidad_ejecutora VARCHAR2
                                     ,
                                      un_mes                     NUMBER --,un_rubro_interno NUMBER
                                     ,
                                      un_interno                 NUMBER)
    RETURN NUMBER IS
  BEGIN
    SELECT SUM(NVL(VALOR_REGISTRO, 0))
      INTO MI_VALOR_RA
      FROM OGT_REGISTRO_PRESUPUESTAL A, OGT_RELACION_AUTORIZACION B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO = B.CONSECUTIVO
       AND A.RUBRO_INTERNO = un_interno
       AND B.VIGENCIA = TO_CHAR(una_vigencia)
       AND B.ENTIDAD = un_codigo_compania
       AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_ra
       AND B.IND_APROBADO = mi_valor_uno
       AND SUBSTR(B.ESTADO, 4, 1) = mi_estado_uno
       AND SUBSTR(B.ESTADO, 9, 1) = mi_estado_cero
       AND TO_NUMBER(TO_CHAR(B.fecha_aprobacion, 'MM')) = un_mes
       AND TO_CHAR(B.FECHA_APROBACION, 'YYYY') = TO_CHAR(una_vigencia)
       AND A.VALOR_REGISTRO < mi_valor_cero;
    RETURN NVL(MI_VALOR_RA, 0);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR('-20001',
                              'Error en OGT_FN_ACUM_AJUSTE ' || SQLERRM);
  END OGT_FN_AJUSTESMES_VIGENCIA;
  --
  --AAGUIRRE 29-11-2004 O.K.
  --FUNCION QUE DEVUELVE EL VALOR DE LOS REINTEGROS MENSUALES DE RUBRO
  --BASADA EN OGT_FN_REINT_MES
  -- MODIFICADA POR FANNY MALAGON 12-01-2005 PARA SACAR LOR REEMBOLSOS DE CAJA MENOR
  -- MODIFICADA POR FANNY 14-01-2005 SDE QUITO UN CRITERIO DEL WHERE YS E ADICIONO LA INFORMACION DE NOMINA
  FUNCTION OGT_FN_REINTEGROSMES_VIGENCIA(una_vigencia               NUMBER,
                                         un_codigo_compania         VARCHAR2 --una_entidad VARCHAR2
                                        ,
                                         un_codigo_unidad_ejecutora VARCHAR2 --una_unidad_ejecutora VARCHAR2
                                        ,
                                         un_mes                     NUMBER,
                                         un_interno                 NUMBER --un_rubro_interno NUMBER
                                         ) RETURN NUMBER IS
  BEGIN
    SELECT SUM(A.VALOR)
      INTO mi_valor_OP
      FROM OGT_DETALLE_ACTAS A, OGT_ACTAS B
     WHERE A.CONSECUTIVO = B.CONSECUTIVO
       AND A.VIGENCIA = B.VIGENCIA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
          /*      AND B.VIGENCIA = TO_NUMBER(una_vigencia)
                AND B.ENTIDAD = mi_entidad_reintegros
                AND B.UNIDAD_EJECUTORA = mi_unidad_ejecutora_reintegros
                */
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_ar
       AND TO_CHAR(B.fecha, 'MM') = un_mes
       AND A.DOC_VIGENCIA = TO_CHAR(una_vigencia)
       AND A.DOC_ENTIDAD = un_codigo_compania
       AND A.DOC_UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
       AND NVL(B.TIPO_OP, 0) != mi_tipo_caja_menor
       AND A.RUBRO_INTERNO = un_interno;
    /*
    SELECT SUM(NVL(VALOR_REGISTRO,0))
    INTO MI_VALOR_RA
    FROM OGT_REGISTRO_PRESUPUESTAL A, OGT_RELACION_AUTORIZACION B
    WHERE  A.VIGENCIA = B.VIGENCIA
    AND A.ENTIDAD = B.ENTIDAD
    AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
    AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
    AND A.CONSECUTIVO = B.CONSECUTIVO
    AND A.RUBRO_INTERNO = un_interno
    AND B.VIGENCIA = TO_CHAR(una_vigencia)
    AND B.ENTIDAD = un_codigo_compania
    AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
    AND B.IND_APROBADO = mi_valor_uno
    AND TO_NUMBER(TO_CHAR(B.fecha_aprobacion,'MM')) = un_mes
    AND A.VALOR_REGISTRO < mi_valor_cero
    AND TO_CHAR(B.FECHA_APROBACION,'YYYY') = TO_CHAR(TO_NUMBER(una_vigencia));
    */
    RETURN(NVL(MI_VALOR_OP, 0)); --NVL(mi_valor_ar,0)

  END OGT_FN_REINTEGROSMES_VIGENCIA;
  --
  --AAGUIRRE 29-11-2004 O.K.
  --FUNCION QUE DEVUELVE EL VALOR DE LAS ANULACIONES MENSUALES DE RUBRO
  --BASADA EN OGT_FN_ANUL_MES
  FUNCTION OGT_FN_ANULGIROSMES_VIGENCIA(una_vigencia               NUMBER,
                                        un_codigo_compania         VARCHAR2 --una_entidad VARCHAR2
                                       ,
                                        un_codigo_unidad_ejecutora VARCHAR2 --una_unidad_ejecutora VARCHAR2
                                       ,
                                        un_mes                     NUMBER,
                                        un_interno                 NUMBER --un_rubro_interno NUMBER
                                        ) RETURN NUMBER IS
  BEGIN
    SELECT NVL(SUM(VALOR_BRUTO), 0)
      INTO mi_valor_op
      FROM OGT_INFORMACION_EXOGENA A, OGT_ORDEN_PAGO B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO = B.CONSECUTIVO
       AND A.RUBRO_INTERNO = un_interno
       AND B.VIGENCIA = TO_CHAR(una_vigencia)
          --AND B.ENTIDAD > '0'
       AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
       AND B.ENTIDAD_PRESUPUESTO = un_codigo_compania
       AND B.TIPO_OP != mi_tipo_caja_menor
       AND B.IND_APROBADO = mi_valor_uno
       AND B.IND_ANULADO = mi_valor_uno
       AND SUBSTR(B.ESTADO, 9, 1) = mi_estado_uno
       AND TO_NUMBER(TO_CHAR(B.FECHA_ANULACION, 'MM')) = un_mes
       AND TO_CHAR(B.FECHA_ANULACION, 'YYYY') = TO_CHAR(una_vigencia);
    SELECT NVL(SUM(VALOR_REGISTRO), 0)
      INTO mi_valor_ra
      FROM OGT_REGISTRO_PRESUPUESTAL A, OGT_RELACION_AUTORIZACION B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO = B.CONSECUTIVO
       AND A.RUBRO_INTERNO = un_interno
       AND B.VIGENCIA = TO_CHAR(una_vigencia)
       AND B.ENTIDAD = un_codigo_compania
       AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_ra
       AND B.IND_APROBADO = mi_valor_uno
       AND B.IND_ANULADO = mi_valor_uno
       AND SUBSTR(B.ESTADO, 4, 1) = mi_estado_uno
       AND SUBSTR(B.ESTADO, 9, 1) = mi_estado_uno
       AND TO_NUMBER(TO_CHAR(B.FECHA_ANULACION, 'MM')) = un_mes
       AND TO_CHAR(B.FECHA_ANULACION, 'YYYY') = TO_CHAR(una_vigencia)
       AND NVL(A.VALOR_REGISTRO, 0) > mi_valor_cero;
    RETURN(NVL(mi_valor_op, 0) + NVL(mi_valor_ra, 0));
  END OGT_FN_ANULGIROSMES_VIGENCIA;
  --
  --AAGUIRRE 29-11-2004 O.K.
  --FUNCION QUE DEVUELVE EL VALOR DE LOS GIROS ACUMULADOS A UN MES
  --BASADA OGT_FN_GIROSMES_VIGENCIA
  FUNCTION OGT_FN_GIROSACUM_VIGENCIA(una_vigencia               NUMBER,
                                     un_codigo_compania         VARCHAR2,
                                     un_codigo_unidad_ejecutora VARCHAR2,
                                     un_mes                     NUMBER,
                                     un_interno                 NUMBER)
    RETURN NUMBER IS
  BEGIN
    SELECT NVL(SUM(VALOR_BRUTO), 0)
      INTO mi_valor_op
      FROM OGT_INFORMACION_EXOGENA A, OGT_ORDEN_PAGO B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO = B.CONSECUTIVO
       AND A.RUBRO_INTERNO = un_interno
       AND B.VIGENCIA = TO_CHAR(una_vigencia)
          --AND B.ENTIDAD > '0'
       AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_op
       AND B.ENTIDAD_PRESUPUESTO = un_codigo_compania
       AND B.TIPO_OP != mi_tipo_caja_menor
       AND B.IND_APROBADO = mi_valor_uno
       AND TO_NUMBER(TO_CHAR(B.fecha_aprobacion, 'MM')) <= un_mes
       AND TO_CHAR(B.FECHA_APROBACION, 'YYYY') = TO_CHAR(una_vigencia);

    SELECT NVL(SUM(VALOR_REGISTRO), 0)
      INTO mi_valor_ra
      FROM OGT_REGISTRO_PRESUPUESTAL A, OGT_RELACION_AUTORIZACION B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO = B.CONSECUTIVO
       AND A.RUBRO_INTERNO = un_interno
       AND B.VIGENCIA = TO_CHAR(una_vigencia)
       AND B.ENTIDAD = un_codigo_compania
       AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_ra
       AND B.IND_APROBADO = mi_valor_uno
       AND SUBSTR(B.ESTADO, 4, 1) = mi_estado_uno
       AND TO_NUMBER(TO_CHAR(B.fecha_aprobacion, 'MM')) <= un_mes
       AND TO_CHAR(B.FECHA_APROBACION, 'YYYY') = TO_CHAR(una_vigencia)
       AND NVL(A.VALOR_REGISTRO, 0) > mi_valor_cero;
    RETURN(NVL(mi_valor_op, 0) + NVL(mi_valor_ra, 0));
  END OGT_FN_GIROSACUM_VIGENCIA;
  --
  --AAGUIRRE 30-11-2004 O.K.
  --FUNCION QUE DEVUELVE EL VALOR DE LOS AJUSTES ACUMULADOS MENSUALES
  --DE RUBRO
  --BASADO EN OGT_FN_ACUM_AJUSTE
  FUNCTION OGT_FN_AJUSTESACUM_VIGENCIA(una_vigencia               NUMBER,
                                       un_codigo_compania         VARCHAR2,
                                       un_codigo_unidad_ejecutora VARCHAR2,
                                       un_mes                     NUMBER,
                                       un_interno                 VARCHAR2)
    RETURN NUMBER IS
  BEGIN
    SELECT SUM(NVL(VALOR_REGISTRO, 0))
      INTO MI_VALOR_RA
      FROM OGT_REGISTRO_PRESUPUESTAL A, OGT_RELACION_AUTORIZACION B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO = B.CONSECUTIVO
       AND A.RUBRO_INTERNO = un_interno
       AND B.VIGENCIA = TO_CHAR(una_vigencia)
       AND B.ENTIDAD = un_codigo_compania
       AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_ra
       AND B.IND_APROBADO = mi_valor_uno
       AND SUBSTR(B.ESTADO, 4, 1) = mi_estado_uno
       AND SUBSTR(B.ESTADO, 9, 1) = mi_estado_cero
       AND TO_NUMBER(TO_CHAR(B.fecha_aprobacion, 'MM')) <= un_mes
       AND A.VALOR_REGISTRO < mi_valor_cero
       AND TO_CHAR(B.FECHA_APROBACION, 'YYYY') = TO_CHAR(una_vigencia);
    RETURN NVL(MI_VALOR_RA, 0);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR('-20001',
                              'Error en OGT_FN_ACUM_AJUSTE ' || SQLERRM);
  END OGT_FN_AJUSTESACUM_VIGENCIA;
  --
  --AAGUIRRE 30-11-2004 O.K.
  --FUNCION QUE DEVUELVE EL VALOR DE LOS REINTEGROS ACUMULADOS
  --DE RUBRO
  --BASADO EN OGT_FN_REINT_MES
  -- MODIFICADA POR FANNY MALAGON 12-01-2005 PARA SACAR LOR REEMBOLSOS DE CAJA MENOR
  -- MODIFICADA FANNY 14-01-2005 SE QUITARON CRITERIOS DEL WHERE Y SE ADICIONO INF DE NOMINA
  FUNCTION OGT_FN_REINTEGROSACUM_VIGENCIA(una_vigencia               NUMBER,
                                          un_codigo_compania         VARCHAR2 --una_entidad VARCHAR2
                                         ,
                                          un_codigo_unidad_ejecutora VARCHAR2 --una_unidad_ejecutora VARCHAR2
                                         ,
                                          un_mes                     NUMBER,
                                          un_interno                 VARCHAR2 --un_rubro_interno NUMBER
                                          ) RETURN NUMBER IS
  BEGIN
    SELECT SUM(A.VALOR)
      INTO mi_valor_OP
      FROM OGT_DETALLE_ACTAS A, OGT_ACTAS B
     WHERE A.CONSECUTIVO = B.CONSECUTIVO
       AND A.VIGENCIA = B.VIGENCIA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND B.VIGENCIA = TO_CHAR(una_vigencia)
          /*      AND B.VIGENCIA = TO_CHAR(una_vigencia)
                AND B.ENTIDAD =  mi_entidad_reintegros
                AND B.UNIDAD_EJECUTORA = mi_unidad_ejecutora_reintegros
                */
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_ar
       AND TO_CHAR(B.fecha, 'MM') <= un_mes
       AND A.RUBRO_INTERNO = un_interno
       AND A.DOC_VIGENCIA = TO_CHAR(una_vigencia)
       AND A.DOC_ENTIDAD = un_codigo_compania
       AND A.DOC_UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
       AND NVL(B.TIPO_OP, 3) != mi_tipo_caja_menor;

    /*
    SELECT SUM(NVL(VALOR_REGISTRO,0))
    INTO MI_VALOR_RA
    FROM OGT_REGISTRO_PRESUPUESTAL A, OGT_RELACION_AUTORIZACION B
    WHERE  A.VIGENCIA = B.VIGENCIA
    AND A.ENTIDAD = B.ENTIDAD
    AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
    AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
    AND A.CONSECUTIVO = B.CONSECUTIVO
    AND A.RUBRO_INTERNO = un_interno
    AND B.VIGENCIA = TO_CHAR(una_vigencia)
    AND B.ENTIDAD = un_codigo_compania
    AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
    AND B.IND_APROBADO = mi_valor_uno
    AND TO_NUMBER(TO_CHAR(B.fecha_aprobacion,'MM')) <= un_mes
    AND A.VALOR_REGISTRO < mi_valor_cero
    AND TO_CHAR(B.FECHA_APROBACION,'YYYY') = TO_CHAR(una_vigencia);
    */
    RETURN(NVL(mi_valor_OP, 0)); --NVL(mi_valor_ar,0)+
  END OGT_FN_REINTEGROSACUM_VIGENCIA;
  --
  --AAGUIRRE 30-11-2004 O.K.
  --FUNCION QUE DEVUELVE EL VALOR DE LAS ANULACIONES ACUMULADAS
  --DE RUBRO
  --BASADO EN OGT_FN_ANUL_ACUM
  FUNCTION OGT_FN_ANULGIROSACUM_VIGENCIA(una_vigencia               NUMBER,
                                         un_codigo_compania         VARCHAR2,
                                         un_codigo_unidad_ejecutora VARCHAR2,
                                         un_mes                     NUMBER,
                                         un_interno                 NUMBER)
    RETURN NUMBER IS
  BEGIN
    SELECT NVL(SUM(VALOR_BRUTO), 0)
      INTO mi_valor_op
      FROM OGT_INFORMACION_EXOGENA A, OGT_ORDEN_PAGO B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO = B.CONSECUTIVO
       AND A.RUBRO_INTERNO = un_interno
       AND B.VIGENCIA = TO_CHAR(una_vigencia)
          --AND B.ENTIDAD > '0'
       AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_op
       AND B.ENTIDAD_PRESUPUESTO = un_codigo_compania
       AND B.TIPO_OP != mi_tipo_caja_menor
       AND B.IND_APROBADO = mi_valor_uno
       AND B.IND_ANULADO = mi_valor_uno
       AND SUBSTR(B.ESTADO, 9, 1) = mi_estado_uno
       AND TO_NUMBER(TO_CHAR(B.FECHA_ANULACION, 'MM')) <= un_mes
       AND TO_CHAR(B.FECHA_ANULACION, 'YYYY') = TO_CHAR(una_vigencia);
    SELECT NVL(SUM(VALOR_REGISTRO), 0)
      INTO mi_valor_ra
      FROM OGT_REGISTRO_PRESUPUESTAL A, OGT_RELACION_AUTORIZACION B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO = B.CONSECUTIVO
       AND A.RUBRO_INTERNO = un_interno
       AND B.VIGENCIA = TO_CHAR(una_vigencia)
       AND B.ENTIDAD = un_codigo_compania
       AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_ra
       AND B.IND_APROBADO = mi_valor_uno
       AND B.IND_ANULADO = mi_valor_uno
       AND SUBSTR(B.ESTADO, 4, 1) = mi_estado_uno
       AND SUBSTR(B.ESTADO, 9, 1) = mi_estado_uno
       AND TO_NUMBER(TO_CHAR(B.FECHA_ANULACION, 'MM')) <= un_mes
       AND TO_CHAR(B.FECHA_ANULACION, 'YYYY') = TO_CHAR(una_vigencia)
       AND NVL(A.VALOR_REGISTRO, 0) > mi_valor_cero;
    RETURN(NVL(mi_valor_op, 0) + NVL(mi_valor_ra, 0));
  END OGT_FN_ANULGIROSACUM_VIGENCIA;
  --
  --AAGUIRRE
  --FUNCION QUE DEVUELVE UN CURSOR CON LOS AJUSTES A ORDENES DE PAGO Y
  --RELACIONES DE AUTORIZACION DE VIGENCIA
  --
  FUNCTION OGT_FN_GIROS_RESERVAS(UNA_VIGENCIA               NUMBER,
                                 UN_CODIGO_COMPANIA         VARCHAR2,
                                 UN_CODIGO_UNIDAD_EJECUTORA VARCHAR2)
    RETURN CUR_GIROS_RESERVAS IS
    MI_CC CUR_GIROS_RESERVAS;
  BEGIN
    OPEN MI_CC FOR
      SELECT A.VIGENCIA,
             SUBSTR(A.ENTIDAD_PRESUPUESTO, 1, 3) CODIGO_COMPANIA,
             SUBSTR(A.UNIDAD_EJECUTORA, 1, 2) CODIGO_UNIDAD_EJECUTORA,
             A.RUBRO_INTERNO,
             B.FECHA_APROBACION FECHA_ORDEN,
             A.REGISTRO NUMERO_REGISTRO_PRESUPUESTAL,
             TO_NUMBER(A.CONSECUTIVO) NUMERO_ORDEN,
             TO_NUMBER(A.CONSECUTIVO) CONSECUTIVO_DE_ORDEN,
             DETALLE OBJETO,
             TO_NUMBER(A.CONSECUTIVO) CONSECUTIVO_ORDEN,
             Pk_Ogt_Op.FN_OGT_BRUTO_RP(A.VIGENCIA,
                                       A.ENTIDAD,
                                       A.UNIDAD_EJECUTORA,
                                       A.TIPO_DOCUMENTO,
                                       A.CONSECUTIVO,
                                       A.RUBRO_INTERNO,
                                       A.DISPONIBILIDAD,
                                       A.REGISTRO) VALOR
        FROM OGT_REGISTRO_PRESUPUESTAL A, OGT_ORDEN_PAGO B
       WHERE A.VIGENCIA = B.VIGENCIA
         AND A.ENTIDAD = B.ENTIDAD
         AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
         AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
         AND A.CONSECUTIVO = B.CONSECUTIVO
         AND B.VIGENCIA = TO_CHAR(una_vigencia - 1)
         AND B.ENTIDAD_PRESUPUESTO = un_codigo_compania
         AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
         AND B.TIPO_DOCUMENTO = mi_tipo_documento_op
         AND B.TIPO_VIGENCIA = mi_tipo_vigencia_reserva
         AND B.IND_APROBADO = mi_aprobado_uno
         AND SUBSTR(ESTADO, 4, 1) = mi_estado_uno
         AND B.TIPO_OP != mi_tipo_caja_menor
      UNION
      SELECT A.VIGENCIA,
             SUBSTR(A.ENTIDAD_PRESUPUESTO, 1, 3) CODIGO_COMPANIA,
             SUBSTR(A.UNIDAD_EJECUTORA, 1, 2) CODIGO_UNIDAD_EJECUTORA,
             A.RUBRO_INTERNO,
             B.FECHA_APROBACION FECHA_ORDEN,
             A.REGISTRO NUMERO_REGISTRO_PRESUPUESTAL,
             TO_NUMBER(A.CONSECUTIVO) NUMERO_ORDEN,
             TO_NUMBER(A.CONSECUTIVO) CONSECUTIVO_DE_ORDEN,
             B.DESCRIPCION OBJETO,
             TO_NUMBER(A.CONSECUTIVO) CONSECUTIVO_ORDEN,
             Pk_Ogt_Op.FN_OGT_BRUTO_RP(A.VIGENCIA,
                                       A.ENTIDAD,
                                       A.UNIDAD_EJECUTORA,
                                       A.TIPO_DOCUMENTO,
                                       A.CONSECUTIVO,
                                       A.RUBRO_INTERNO,
                                       A.DISPONIBILIDAD,
                                       A.REGISTRO) VALOR
        FROM OGT_REGISTRO_PRESUPUESTAL A, OGT_RELACION_AUTORIZACION B
       WHERE A.VIGENCIA = B.VIGENCIA
         AND A.ENTIDAD = B.ENTIDAD
         AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
         AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
         AND A.CONSECUTIVO = B.CONSECUTIVO
         AND B.VIGENCIA = TO_CHAR(una_vigencia - 1)
         AND B.ENTIDAD = un_codigo_compania
         AND B.TIPO_DOCUMENTO = mi_tipo_documento_ra
         AND B.IND_APROBADO = mi_aprobado_uno
         AND SUBSTR(B.ESTADO, 4, 1) = mi_estado_uno
         AND Pk_Ogt_Op.FN_OGT_TIPO_VIGENCIA(TO_NUMBER(B.VIGENCIA),
                                            TO_NUMBER(TO_CHAR(B.FECHA_APROBACION,
                                                              'YYYY')),
                                            TO_NUMBER(TO_CHAR(B.FECHA_RADICACION,
                                                              'YYYY'))) =
             mi_tipo_vigencia_reserva
         AND NVL(A.VALOR_REGISTRO, 0) > mi_valor_cero;
    RETURN MI_CC;
  END OGT_FN_GIROS_RESERVAS;
  --
  --AAGUIRRE
  --FUNCION QUE DEVUELVE UN CURSOR CON LOS ANULACIONES DE ORDENES DE PAGO Y
  --RELACIONES DE AUTORIZACION DE RESERVAS
  --
  FUNCTION OGT_FN_ANULGIROS_RESERVAS(UNA_VIGENCIA               NUMBER,
                                     UN_CODIGO_COMPANIA         VARCHAR2,
                                     UN_CODIGO_UNIDAD_EJECUTORA VARCHAR2)
    RETURN CUR_ANULGIROS_RESERVAS IS
    MI_CC CUR_ANULGIROS_RESERVAS;
  BEGIN
    OPEN MI_CC FOR
      SELECT TO_NUMBER(A.VIGENCIA) VIGENCIA,
             SUBSTR(A.ENTIDAD_PRESUPUESTO, 1, 3) CODIGO_COMPANIA,
             SUBSTR(A.UNIDAD_EJECUTORA, 1, 2) CODIGO_UNIDAD_EJECUTORA,
             A.RUBRO_INTERNO INTERNO,
             B.FECHA_ANULACION,
             A.REGISTRO NUMERO_REGISTRO_PRESUPUESTAL,
             TO_NUMBER(A.CONSECUTIVO) NUMERO_ORDEN,
             TO_NUMBER(A.CONSECUTIVO) CONSECUTIVO_DE_ORDEN,
             B.DESCRIPCION_ANULACION,
             SUM(Pk_Ogt_Op.FN_OGT_BRUTO_RP(A.VIGENCIA,
                                           A.ENTIDAD,
                                           A.UNIDAD_EJECUTORA,
                                           A.TIPO_DOCUMENTO,
                                           A.CONSECUTIVO,
                                           A.RUBRO_INTERNO,
                                           A.DISPONIBILIDAD,
                                           A.REGISTRO)) VALOR
        FROM OGT_REGISTRO_PRESUPUESTAL A, OGT_ORDEN_PAGO B
       WHERE A.VIGENCIA = B.VIGENCIA
         AND A.ENTIDAD = B.ENTIDAD
         AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
         AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
         AND A.CONSECUTIVO = B.CONSECUTIVO
         AND B.VIGENCIA = TO_CHAR(una_vigencia - 1)
         AND B.ENTIDAD_PRESUPUESTO = un_codigo_compania
         AND B.UNIDAD_EJECUTORA = UN_CODIGO_UNIDAD_EJECUTORA
         AND B.TIPO_DOCUMENTO = mi_tipo_documento_op
         AND B.TIPO_VIGENCIA = mi_tipo_vigencia_reserva
         AND B.IND_APROBADO = mi_valor_uno
         AND B.IND_ANULADO = mi_valor_uno
         AND B.TIPO_OP != mi_tipo_caja_menor
         AND SUBSTR(B.ESTADO, 4, 1) = mi_estado_uno
         AND SUBSTR(B.ESTADO, 9, 1) = mi_estado_uno
       GROUP BY TO_NUMBER(A.VIGENCIA),
                SUBSTR(A.ENTIDAD_PRESUPUESTO, 1, 3),
                SUBSTR(A.UNIDAD_EJECUTORA, 1, 2),
                A.RUBRO_INTERNO,
                B.FECHA_ANULACION,
                A.REGISTRO,
                TO_NUMBER(A.CONSECUTIVO),
                TO_NUMBER(A.CONSECUTIVO),
                B.DESCRIPCION_ANULACION
      UNION ALL
      SELECT TO_NUMBER(A.VIGENCIA) VIGENCIA,
             SUBSTR(A.ENTIDAD_PRESUPUESTO, 1, 3) CODIGO_COMPANIA,
             SUBSTR(A.UNIDAD_EJECUTORA, 1, 2) CODIGO_UNIDAD_EJECUTORA,
             A.RUBRO_INTERNO INTERNO,
             B.FECHA_ANULACION,
             A.REGISTRO NUMERO_REGISTRO,
             TO_NUMBER(A.CONSECUTIVO) NUMERO_ORDEN,
             TO_NUMBER(A.CONSECUTIVO) CONSECUTIVO_DE_ORDEN,
             DESCRIPCION_ANULACION DESCRIPCION,
             SUM(Pk_Ogt_Op.FN_OGT_BRUTO_RP(A.VIGENCIA,
                                           A.ENTIDAD,
                                           A.UNIDAD_EJECUTORA,
                                           A.TIPO_DOCUMENTO,
                                           A.CONSECUTIVO,
                                           A.RUBRO_INTERNO,
                                           A.DISPONIBILIDAD,
                                           A.REGISTRO)) VALOR
        FROM OGT_REGISTRO_PRESUPUESTAL A, OGT_RELACION_AUTORIZACION B
       WHERE A.VIGENCIA = B.VIGENCIA
         AND A.ENTIDAD = B.ENTIDAD
         AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
         AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
         AND A.CONSECUTIVO = B.CONSECUTIVO
         AND B.VIGENCIA = TO_CHAR(una_vigencia - 1)
         AND B.ENTIDAD = un_codigo_compania
         AND B.UNIDAD_EJECUTORA = UN_CODIGO_UNIDAD_EJECUTORA
         AND B.TIPO_DOCUMENTO = mi_tipo_documento_ra
         AND Pk_Ogt_Op.FN_OGT_TIPO_VIGENCIA(TO_NUMBER(B.VIGENCIA),
                                            TO_NUMBER(TO_CHAR(B.FECHA_APROBACION,
                                                              'YYYY')),
                                            TO_NUMBER(TO_CHAR(B.FECHA_RADICACION,
                                                              'YYYY'))) =
             mi_tipo_vigencia_reserva
         AND SUBSTR(B.ESTADO, 4, 1) = mi_estado_uno
         AND SUBSTR(B.ESTADO, 9, 1) = mi_estado_uno
         AND B.IND_APROBADO = mi_valor_uno
         AND B.IND_ANULADO = mi_valor_uno
       GROUP BY TO_NUMBER(A.VIGENCIA),
                SUBSTR(A.ENTIDAD_PRESUPUESTO, 1, 3),
                SUBSTR(A.UNIDAD_EJECUTORA, 1, 2),
                A.RUBRO_INTERNO,
                B.FECHA_ANULACION,
                A.REGISTRO,
                TO_NUMBER(A.CONSECUTIVO),
                TO_NUMBER(A.CONSECUTIVO),
                DESCRIPCION_ANULACION;
    RETURN MI_CC;
  END OGT_FN_ANULGIROS_RESERVAS;
  --
  --AAGUIRRE
  --FUNCION QUE DEVUELVE UN CURSOR CON LAS ORDENES DE PAGO Y
  --RELACIONES DE AUTORIZACION DE VIGENCIA
  -- FANNY OJO CON EL PLANE TABLE
  --
  FUNCTION OGT_FN_GIROS_VIGENCIA(UNA_VIGENCIA               NUMBER,
                                 UN_CODIGO_COMPANIA         VARCHAR2,
                                 UN_CODIGO_UNIDAD_EJECUTORA VARCHAR2)
    RETURN CUR_GIROS_VIGENCIA IS
    MI_CC CUR_GIROS_VIGENCIA;
  BEGIN
    OPEN MI_CC FOR
      SELECT A.VIGENCIA,
             SUBSTR(A.ENTIDAD_PRESUPUESTO, 1, 3) CODIGO_COMPANIA,
             SUBSTR(A.UNIDAD_EJECUTORA, 1, 2) CODIGO_UNIDAD_EJECUTORA,
             A.RUBRO_INTERNO,
             B.FECHA_APROBACION FECHA_ORDEN,
             A.REGISTRO NUMERO_REGISTRO_PRESUPUESTAL,
             TO_NUMBER(A.CONSECUTIVO) NUMERO_ORDEN,
             TO_NUMBER(A.CONSECUTIVO) CONSECUTIVO_DE_ORDEN,
             B.DETALLE OBJETO,
             TO_NUMBER(A.CONSECUTIVO) CONSECUTIVO_ORDEN,
             Pk_Ogt_Op.FN_OGT_BRUTO_RP(A.VIGENCIA,
                                       A.ENTIDAD,
                                       A.UNIDAD_EJECUTORA,
                                       A.TIPO_DOCUMENTO,
                                       A.CONSECUTIVO,
                                       A.RUBRO_INTERNO,
                                       A.DISPONIBILIDAD,
                                       A.REGISTRO) VALOR
        FROM OGT_REGISTRO_PRESUPUESTAL A, OGT_ORDEN_PAGO B
       WHERE A.VIGENCIA = B.VIGENCIA
         AND A.ENTIDAD = B.ENTIDAD
         AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
         AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
         AND A.CONSECUTIVO = B.CONSECUTIVO
         AND B.VIGENCIA = TO_CHAR(una_vigencia)
         AND A.ENTIDAD_PRESUPUESTO = un_codigo_compania
         AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
         AND B.TIPO_DOCUMENTO = mi_tipo_documento_op
         AND B.TIPO_VIGENCIA in
             (mi_tipo_vigencia_actual, mi_tipo_vigencia_c)
         AND B.IND_APROBADO = mi_aprobado_uno
         AND SUBSTR(ESTADO, 4, 1) = mi_estado_uno
         AND B.TIPO_OP != mi_tipo_caja_menor
      UNION
      SELECT A.VIGENCIA,
             SUBSTR(A.ENTIDAD_PRESUPUESTO, 1, 3) CODIGO_COMPANIA,
             SUBSTR(A.UNIDAD_EJECUTORA, 1, 2) CODIGO_UNIDAD_EJECUTORA,
             A.RUBRO_INTERNO,
             B.FECHA_APROBACION FECHA_ORDEN,
             A.REGISTRO NUMERO_REGISTRO_PRESUPUESTAL,
             TO_NUMBER(A.CONSECUTIVO) NUMERO_ORDEN,
             TO_NUMBER(A.CONSECUTIVO) CONSECUTIVO_DE_ORDEN,
             B.DESCRIPCION OBJETO,
             TO_NUMBER(A.CONSECUTIVO) CONSECUTIVO_ORDEN,
             Pk_Ogt_Op.FN_OGT_BRUTO_RP(A.VIGENCIA,
                                       A.ENTIDAD,
                                       A.UNIDAD_EJECUTORA,
                                       A.TIPO_DOCUMENTO,
                                       A.CONSECUTIVO,
                                       A.RUBRO_INTERNO,
                                       A.DISPONIBILIDAD,
                                       A.REGISTRO) VALOR
        FROM OGT_REGISTRO_PRESUPUESTAL A, OGT_RELACION_AUTORIZACION B
       WHERE A.VIGENCIA = B.VIGENCIA
         AND A.ENTIDAD = B.ENTIDAD
         AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
         AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
         AND A.CONSECUTIVO = B.CONSECUTIVO
         AND B.VIGENCIA = TO_CHAR(una_vigencia)
         AND B.ENTIDAD = un_codigo_compania
         AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
         AND B.TIPO_DOCUMENTO = mi_tipo_documento_ra
         AND B.IND_APROBADO = mi_aprobado_uno
         AND SUBSTR(B.ESTADO, 4, 1) = mi_estado_uno
         AND Pk_Ogt_Op.FN_OGT_TIPO_VIGENCIA(TO_NUMBER(B.VIGENCIA),
                                            TO_NUMBER(TO_CHAR(B.FECHA_APROBACION,
                                                              'YYYY')),
                                            TO_NUMBER(TO_CHAR(B.FECHA_RADICACION,
                                                              'YYYY'))) in
             (mi_tipo_vigencia_actual, mi_tipo_vigencia_c)
         AND NVL(A.VALOR_REGISTRO, 0) > mi_valor_cero;
    RETURN MI_CC;
  END OGT_FN_GIROS_VIGENCIA;
  --AAGUIRRE
  --FUNCION QUE DEVUELVE UN CURSOR CON LAS ANULACIONES DE ORDENES DE PAGO Y
  --RELACIONES DE AUTORIZACION DE VIGENCIA
  FUNCTION OGT_FN_ANULGIRO_VIGENCIA(UNA_VIGENCIA               NUMBER,
                                    UN_CODIGO_COMPANIA         VARCHAR2,
                                    UN_CODIGO_UNIDAD_EJECUTORA VARCHAR2)
    RETURN CUR_ANULGIRO_VIGENCIA IS
    MI_CC CUR_ANULGIRO_VIGENCIA;
  BEGIN
    OPEN MI_CC FOR
      SELECT TO_NUMBER(A.VIGENCIA) VIGENCIA,
             SUBSTR(A.ENTIDAD_PRESUPUESTO, 1, 3) CODIGO_COMPANIA,
             SUBSTR(A.UNIDAD_EJECUTORA, 1, 2) CODIGO_UNIDAD_EJECUTORA,
             A.RUBRO_INTERNO INTERNO,
             B.FECHA_ANULACION,
             A.REGISTRO NUMERO_REGISTRO_PRESUPUESTAL,
             TO_NUMBER(A.CONSECUTIVO) NUMERO_ORDEN,
             TO_NUMBER(A.CONSECUTIVO) CONSECUTIVO_DE_ORDEN,
             B.DESCRIPCION_ANULACION,
             SUM(Pk_Ogt_Op.FN_OGT_BRUTO_RP(A.VIGENCIA,
                                           A.ENTIDAD,
                                           A.UNIDAD_EJECUTORA,
                                           A.TIPO_DOCUMENTO,
                                           A.CONSECUTIVO,
                                           A.RUBRO_INTERNO,
                                           A.DISPONIBILIDAD,
                                           A.REGISTRO)) VALOR
        FROM OGT_REGISTRO_PRESUPUESTAL A, OGT_ORDEN_PAGO B
       WHERE A.VIGENCIA = B.VIGENCIA
         AND A.ENTIDAD = B.ENTIDAD
         AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
         AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
         AND A.CONSECUTIVO = B.CONSECUTIVO
         AND B.VIGENCIA = TO_CHAR(una_vigencia)
         AND B.ENTIDAD_PRESUPUESTO = un_codigo_compania
         AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
         AND B.TIPO_DOCUMENTO = mi_tipo_documento_op
         AND B.TIPO_VIGENCIA = mi_tipo_vigencia_actual
         AND B.IND_APROBADO = mi_valor_uno
         AND B.IND_ANULADO = mi_valor_uno
         AND B.TIPO_OP != mi_tipo_caja_menor
         AND SUBSTR(B.ESTADO, 4, 1) = mi_estado_uno
         AND SUBSTR(B.ESTADO, 9, 1) = mi_estado_uno
       GROUP BY TO_NUMBER(A.VIGENCIA),
                SUBSTR(A.ENTIDAD_PRESUPUESTO, 1, 3),
                SUBSTR(A.UNIDAD_EJECUTORA, 1, 2),
                A.RUBRO_INTERNO,
                B.FECHA_ANULACION,
                A.REGISTRO,
                TO_NUMBER(A.CONSECUTIVO),
                TO_NUMBER(A.CONSECUTIVO),
                B.DESCRIPCION_ANULACION
      UNION ALL
      SELECT TO_NUMBER(A.VIGENCIA) VIGENCIA,
             SUBSTR(A.ENTIDAD_PRESUPUESTO, 1, 3) CODIGO_COMPANIA,
             SUBSTR(A.UNIDAD_EJECUTORA, 1, 2) CODIGO_UNIDAD_EJECUTORA,
             A.RUBRO_INTERNO INTERNO,
             B.FECHA_ANULACION,
             A.REGISTRO NUMERO_REGISTRO,
             TO_NUMBER(A.CONSECUTIVO) NUMERO_ORDEN,
             TO_NUMBER(A.CONSECUTIVO) CONSECUTIVO_DE_ORDEN,
             DESCRIPCION_ANULACION DESCRIPCION,
             SUM(Pk_Ogt_Op.FN_OGT_BRUTO_RP(A.VIGENCIA,
                                           A.ENTIDAD,
                                           A.UNIDAD_EJECUTORA,
                                           A.TIPO_DOCUMENTO,
                                           A.CONSECUTIVO,
                                           A.RUBRO_INTERNO,
                                           A.DISPONIBILIDAD,
                                           A.REGISTRO)) VALOR
        FROM OGT_REGISTRO_PRESUPUESTAL A, OGT_RELACION_AUTORIZACION B
       WHERE A.VIGENCIA = B.VIGENCIA
         AND A.ENTIDAD = B.ENTIDAD
         AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
         AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
         AND A.CONSECUTIVO = B.CONSECUTIVO
         AND B.VIGENCIA = TO_CHAR(una_vigencia)
         AND B.ENTIDAD = un_codigo_compania
         AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
         AND B.TIPO_DOCUMENTO = mi_tipo_documento_ra
         AND Pk_Ogt_Op.FN_OGT_TIPO_VIGENCIA(TO_NUMBER(B.VIGENCIA),
                                            TO_NUMBER(TO_CHAR(B.FECHA_APROBACION,
                                                              'YYYY')),
                                            TO_NUMBER(TO_CHAR(B.FECHA_RADICACION,
                                                              'YYYY'))) =
             mi_tipo_vigencia_actual
         AND SUBSTR(B.ESTADO, 4, 1) = mi_estado_uno
         AND SUBSTR(B.ESTADO, 9, 1) = mi_estado_uno
         AND B.IND_ANULADO = mi_valor_uno
       GROUP BY TO_NUMBER(A.VIGENCIA),
                SUBSTR(A.ENTIDAD_PRESUPUESTO, 1, 3),
                SUBSTR(A.UNIDAD_EJECUTORA, 1, 2),
                A.RUBRO_INTERNO,
                B.FECHA_ANULACION,
                A.REGISTRO,
                TO_NUMBER(A.CONSECUTIVO),
                TO_NUMBER(A.CONSECUTIVO),
                DESCRIPCION_ANULACION;
    RETURN MI_CC;
  END OGT_FN_ANULGIRO_VIGENCIA;
  --AAGUIRRE
  --FUNCION QUE DEVUELVE UN CURSOR CON LOS AJUSTES A ORDENES DE PAGO
  -- Y RELACIONES DE AUTORIZACION DE VIGENCIA
  FUNCTION OGT_FN_AJUSTES_VIGENCIA(UNA_VIGENCIA               NUMBER,
                                   UN_CODIGO_COMPANIA         VARCHAR2,
                                   UN_CODIGO_UNIDAD_EJECUTORA VARCHAR2)
    RETURN CUR_AJUS_VIGENCIA IS
    MI_CC CUR_AJUS_VIGENCIA;
  BEGIN
    OPEN MI_CC FOR
      SELECT TO_NUMBER(A.VIGENCIA) VIGENCIA,
             SUBSTR(A.ENTIDAD, 1, 3) CODIGO_COMPANIA,
             SUBSTR(A.UNIDAD_EJECUTORA, 1, 2) CODIGO_UNIDAD_EJECUTORA,
             A.RUBRO_INTERNO,
             B.FECHA_APROBACION FECHA_AJUSTE,
             A.REGISTRO NUMERO_REGISTRO_PRESUPUESTAL,
             TO_NUMBER(A.CONSECUTIVO) NUMERO_ORDEN,
             TO_NUMBER(A.CONSECUTIVO) CONSECUTIVO_DE_ORDEN,
             B.DESCRIPCION OBJETO,
             TO_NUMBER(A.CONSECUTIVO) CONSECUTIVO_ORDEN,
             SUM(A.VALOR_REGISTRO)
        FROM OGT_REGISTRO_PRESUPUESTAL A, OGT_RELACION_AUTORIZACION B
       WHERE A.VIGENCIA = B.VIGENCIA
         AND A.ENTIDAD = B.ENTIDAD
         AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
         AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
         AND A.CONSECUTIVO = B.CONSECUTIVO
         AND B.VIGENCIA = una_vigencia
         AND B.ENTIDAD = un_codigo_compania
         AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
         AND B.TIPO_DOCUMENTO = mi_tipo_documento_ra
         AND B.IND_APROBADO = mi_valor_uno
         AND SUBSTR(B.ESTADO, 4, 1) = mi_estado_uno
         AND SUBSTR(B.ESTADO, 9, 1) = mi_estado_cero
         AND A.VALOR_REGISTRO < mi_valor_cero
         AND Pk_Ogt_Op.FN_OGT_TIPO_VIGENCIA(TO_NUMBER(A.VIGENCIA),
                                            TO_NUMBER(TO_CHAR(B.FECHA_DESDE,
                                                              'YYYY')),
                                            TO_NUMBER(TO_CHAR(B.FECHA_RADICACION,
                                                              'YYYY'))) in
             (mi_tipo_vigencia_actual, mi_tipo_vigencia_c)
       GROUP BY TO_NUMBER(A.VIGENCIA),
                SUBSTR(A.ENTIDAD, 1, 3),
                SUBSTR(A.UNIDAD_EJECUTORA, 1, 2),
                A.RUBRO_INTERNO,
                B.FECHA_APROBACION,
                A.REGISTRO,
                TO_NUMBER(A.CONSECUTIVO),
                TO_NUMBER(A.CONSECUTIVO),
                B.DESCRIPCION,
                TO_NUMBER(A.CONSECUTIVO);
    RETURN MI_CC;
  END OGT_FN_AJUSTES_VIGENCIA;
  --AAGUIRRE
  --FUNCION QUE DEVUELVE UN CURSOR CON LOS REINTEGROS DE ORDENES DE PAGO
  -- Y RELACIONES DE AUTORIZACION DE VIGENCIA
  -- MODIFICADA FANNY SE ADICIONO LA INFORMACXION DE NOMINA
  FUNCTION OGT_FN_REINTEGROS_VIGENCIA(UNA_VIGENCIA               NUMBER,
                                      UN_CODIGO_COMPANIA         VARCHAR2,
                                      UN_CODIGO_UNIDAD_EJECUTORA VARCHAR2)
    RETURN CUR_REINT_VIGENCIA IS
    MI_CC CUR_REINT_VIGENCIA;
  BEGIN
    OPEN MI_CC FOR
      SELECT TO_NUMBER(B.DOC_VIGENCIA) VIGENCIA,
             SUBSTR(B.DOC_ENTIDAD, 1, 3) CODIGO_COMPANIA,
             SUBSTR(B.DOC_UNIDAD_EJECUTORA, 1, 2) CODIGO_UNIDAD_EJECUTORA,
             B.RUBRO_INTERNO,
             C.FECHA FECHA_AJUSTE,
             B.REGISTRO NUMERO_REGISTRO_PRESUPUESTAL,
             TO_NUMBER(B.DOC_CONSECUTIVO) NUMERO_ORDEN,
             TO_NUMBER(B.DOC_CONSECUTIVO) CONSECUTIVO_DE_ORDEN,
             SUBSTR(C.JUSTIFICACION, 1, 120) OBJETO,
             TO_NUMBER(B.DOC_CONSECUTIVO) CONSECUTIVO_ORDEN,
             SUM(B.VALOR)
        FROM OGT_ORDEN_PAGO A, OGT_DETALLE_ACTAS B, OGT_ACTAS C
       WHERE A.VIGENCIA = B.DOC_VIGENCIA
         AND A.ENTIDAD = B.DOC_ENTIDAD
         AND A.UNIDAD_EJECUTORA = B.DOC_UNIDAD_EJECUTORA
         AND A.TIPO_DOCUMENTO = B.DOC_TIPO_DOCUMENTO
         AND A.CONSECUTIVO = B.DOC_CONSECUTIVO
         AND B.CONSECUTIVO = C.CONSECUTIVO
         AND B.VIGENCIA = C.VIGENCIA
         AND B.TIPO_DOCUMENTO = C.TIPO_DOCUMENTO
         AND B.ENTIDAD = C.ENTIDAD
         AND B.UNIDAD_EJECUTORA = C.UNIDAD_EJECUTORA
            /*  AND C.VIGENCIA = TO_CHAR(una_vigencia)
              AND C.ENTIDAD = mi_entidad_reintegros
              AND C.UNIDAD_EJECUTORA = mi_unidad_ejecutora_reintegros
              */
         AND C.TIPO_DOCUMENTO = mi_tipo_documento_ar
         AND B.DOC_VIGENCIA = TO_CHAR(una_vigencia)
         AND B.DOC_ENTIDAD = un_codigo_compania
         AND B.DOC_UNIDAD_EJECUTORA = UN_CODIGO_UNIDAD_EJECUTORA
         AND A.TIPO_VIGENCIA in
             (mi_tipo_vigencia_actual, mi_tipo_vigencia_c)
         AND A.IND_APROBADO = mi_valor_uno
         AND nvl(A.TIPO_OP,0) != mi_tipo_caja_menor
       GROUP BY TO_NUMBER(B.DOC_VIGENCIA),
                SUBSTR(B.DOC_ENTIDAD, 1, 3),
                SUBSTR(B.DOC_UNIDAD_EJECUTORA, 1, 2),
                B.RUBRO_INTERNO,
                C.FECHA,
                B.REGISTRO,
                TO_NUMBER(B.DOC_CONSECUTIVO),
                TO_NUMBER(B.DOC_CONSECUTIVO),
                SUBSTR(C.JUSTIFICACION, 1, 120),
                TO_NUMBER(B.DOC_CONSECUTIVO);
    /*
    UNION
        SELECT
      TO_NUMBER(B.VIGENCIA) VIGENCIA
      ,SUBSTR(B.ENTIDAD,1,3) CODIGO_COMPANIA
      ,SUBSTR(B.UNIDAD_EJECUTORA,1,2) CODIGO_UNIDAD_EJECUTORA
      ,A.RUBRO_INTERNO
      ,B.FECHA_APROBACION FECHA_AJUSTE
      ,A.REGISTRO NUMERO_REGISTRO_PRESUPUESTAL
      ,TO_NUMBER(B.CONSECUTIVO) NUMERO_ORDEN
      ,TO_NUMBER(B.CONSECUTIVO) CONSECUTIVO_DE_ORDEN
      ,SUBSTR(B.DESCRIPCION,1,120) OBJETO
      ,TO_NUMBER(B.CONSECUTIVO) CONSECUTIVO_ORDEN
        ,SUM(A.VALOR_registro)
          FROM OGT_REGISTRO_PRESUPUESTAL A, OGT_RELACION_AUTORIZACION B
          WHERE  A.VIGENCIA = B.VIGENCIA
          AND A.ENTIDAD = B.ENTIDAD
          AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
          AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
          AND A.CONSECUTIVO = B.CONSECUTIVO
          AND B.VIGENCIA = TO_CHAR(una_vigencia)
          AND B.ENTIDAD = un_codigo_compania
          AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
          AND B.IND_APROBADO = mi_valor_uno
          AND A.VALOR_REGISTRO < mi_valor_cero
          AND TO_CHAR(B.FECHA_APROBACION,'YYYY') = TO_CHAR(TO_NUMBER(una_vigencia))
          GROUP BY    TO_NUMBER(B.VIGENCIA)
      ,SUBSTR(B.ENTIDAD,1,3)
      ,SUBSTR(B.UNIDAD_EJECUTORA,1,2)
      ,A.RUBRO_INTERNO
      ,B.FECHA_APROBACION
      ,A.REGISTRO
      ,TO_NUMBER(B.CONSECUTIVO)
      ,TO_NUMBER(B.CONSECUTIVO)
      ,SUBSTR(B.DESCRIPCION,1,120)
      ,TO_NUMBER(B.CONSECUTIVO) ;*/
    RETURN MI_CC;
  END OGT_FN_REINTEGROS_VIGENCIA;
  --AAGUIRRE 30-11-2004 O.K.
  --FUNCION QUE DEVUELVE EL VALOR ORDENES DE PAGO Y RELACIONES DE AUTORIZACION ACUMULADO
  --DE UN REGISTRO PRESUPUESTAL
  --BASADO EN OGT_FN_ANUL_ACUM
  FUNCTION OGT_FN_GIROSACUM_REGISTRO(una_vigencia                 NUMBER,
                                     un_codigo_compania           VARCHAR2,
                                     un_codigo_unidad_ejecutora   VARCHAR2,
                                     numero_registro_presupuestal NUMBER,
                                     un_interno                   NUMBER,
                                     fecha_corte                  DATE)
    RETURN NUMBER IS
  BEGIN
    -- 18-08-2004. Sergio.
    -- Se pone en comentario la instruccion AND SUBSTR(B.ESTADO,9,1) = mi_estado_cero
    -- por solicitud de Magda.
    --16-02-2004 Alejo.
    -- Se adicina hints para mejorar rendimiento
    SELECT /*+ index(a inex_pk) */
     NVL(SUM(a.VALOR_BRUTO), 0)
      INTO mi_valor_op
      FROM OGT_INFORMACION_EXOGENA A, OGT_ORDEN_PAGO B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO = B.CONSECUTIVO
       AND A.RUBRO_INTERNO = un_interno
       AND A.VIGENCIA_PRESUPUESTO > mi_valor_cero
       AND A.REGISTRO = numero_registro_presupuestal
       AND A.DISPONIBILIDAD > mi_valor_cero
       AND A.NUMERO_DOCUMENTO != 'A'
       AND A.ITEM > mi_valor_cero
       AND B.VIGENCIA = TO_CHAR(una_vigencia)
       AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_op
       AND B.ENTIDAD_PRESUPUESTO = un_codigo_compania
       AND B.TIPO_OP != mi_tipo_caja_menor
       AND B.IND_APROBADO = mi_valor_uno
       AND B.fecha_aprobacion <= fecha_corte
       AND TO_CHAR(B.FECHA_APROBACION, 'YYYY') = TO_CHAR(una_vigencia);

    SELECT NVL(SUM(VALOR_REGISTRO), 0)
      INTO mi_valor_ra
      FROM OGT_REGISTRO_PRESUPUESTAL A, OGT_RELACION_AUTORIZACION B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO = B.CONSECUTIVO
       AND A.RUBRO_INTERNO = un_interno
       AND A.REGISTRO = numero_registro_presupuestal
       AND B.VIGENCIA = TO_CHAR(una_vigencia)
       AND B.ENTIDAD = un_codigo_compania
       AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_ra
       AND B.IND_APROBADO = mi_valor_uno
       AND SUBSTR(B.ESTADO, 4, 1) = mi_estado_uno
       AND fecha_aprobacion <= fecha_corte
       AND TO_CHAR(FECHA_APROBACION, 'YYYY') = TO_CHAR(una_vigencia)
       AND NVL(A.VALOR_REGISTRO, 0) > mi_valor_cero;
    RETURN(NVL(mi_valor_op, 0) + NVL(mi_valor_ra, 0));
  END OGT_FN_GIROSACUM_REGISTRO;
  --AAGUIRRE 06-12-2004 O.K.
  --FUNCION QUE DEVUELVE EL VALOR DE ANULACIONES ACUMULADAS DE ORDENES DE PAGO
  --Y RELACIONES DE AUTORIZACION
  --BASADO EN OGT_FN_ANUL_ACUM
  FUNCTION OGT_FN_ANULACUMGIRO_REGISTRO(una_vigencia                 NUMBER,
                                        un_codigo_compania           VARCHAR2,
                                        un_codigo_unidad_ejecutora   VARCHAR2,
                                        numero_registro_presupuestal NUMBER,
                                        un_interno                   NUMBER,
                                        fecha_corte                  DATE)
    RETURN NUMBER IS
  BEGIN
    --
    SELECT /*+ index(a inex_pk) */
     NVL(SUM(a.VALOR_BRUTO), 0)
      INTO mi_valor_op
      FROM OGT_INFORMACION_EXOGENA A, OGT_ORDEN_PAGO B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO = B.CONSECUTIVO
       AND A.RUBRO_INTERNO = un_interno
       AND A.VIGENCIA_PRESUPUESTO > mi_valor_cero
       AND A.REGISTRO = numero_registro_presupuestal
       AND A.DISPONIBILIDAD > mi_valor_cero
       AND A.NUMERO_DOCUMENTO != 'A'
       AND A.ITEM > mi_valor_cero
       AND B.VIGENCIA = TO_CHAR(una_vigencia)
       AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_op
       AND B.ENTIDAD_PRESUPUESTO = un_codigo_compania
       AND B.TIPO_OP != mi_tipo_caja_menor
       AND B.IND_APROBADO = mi_valor_uno
       AND B.IND_ANULADO = mi_valor_uno
       AND SUBSTR(B.ESTADO, 9, 1) = mi_estado_uno
       AND B.fecha_anulacion <= fecha_corte
       AND TO_CHAR(B.fecha_anulacion, 'YYYY') = TO_CHAR(una_vigencia);
    --
    SELECT NVL(SUM(VALOR_REGISTRO), 0)
      INTO mi_valor_ra
      FROM OGT_REGISTRO_PRESUPUESTAL A, OGT_RELACION_AUTORIZACION B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO = B.CONSECUTIVO
       AND A.RUBRO_INTERNO = un_interno
       AND A.REGISTRO = numero_registro_presupuestal
       AND B.VIGENCIA = TO_CHAR(una_vigencia)
       AND B.ENTIDAD = un_codigo_compania
       AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_ra
       AND B.IND_APROBADO = mi_valor_uno
       AND B.IND_ANULADO = mi_valor_uno
       AND SUBSTR(B.ESTADO, 4, 1) = mi_estado_uno
       AND SUBSTR(B.ESTADO, 9, 1) = mi_estado_uno
       AND B.FECHA_ANULACION <= fecha_corte
       AND TO_CHAR(B.FECHA_ANULACION, 'YYYY') = TO_CHAR(una_vigencia)
       AND NVL(A.VALOR_REGISTRO, 0) > mi_valor_cero;
    RETURN(NVL(mi_valor_op, 0) + NVL(mi_valor_ra, 0));
  END OGT_FN_ANULACUMGIRO_REGISTRO;
  --AAGUIRRE 06-12-2004 O.K.
  --FUNCION QUE DEVUELVE EL VALOR DE AJUSTES ACUMULADOS DE ORDENES DE PAGO
  --Y RELACIONES DE AUTORIZACION
  --BASADO EN OGT_FN_ACUM_AJUSTE
  FUNCTION OGT_FN_AJUSTEACUM_REGISTRO(una_vigencia                 NUMBER,
                                      un_codigo_compania           VARCHAR2,
                                      un_codigo_unidad_ejecutora   VARCHAR2,
                                      numero_registro_presupuestal NUMBER,
                                      un_interno                   NUMBER,
                                      fecha_corte                  DATE)
    RETURN NUMBER IS
  BEGIN
    SELECT SUM(NVL(VALOR_REGISTRO, 0))
      INTO MI_VALOR_RA
      FROM OGT_REGISTRO_PRESUPUESTAL A, OGT_RELACION_AUTORIZACION B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO = B.CONSECUTIVO
       AND A.RUBRO_INTERNO = un_interno
       AND A.REGISTRO = numero_registro_presupuestal
       AND B.VIGENCIA = TO_CHAR(una_vigencia)
       AND B.ENTIDAD = un_codigo_compania
       AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_ra
       AND B.IND_APROBADO = mi_valor_uno
       AND SUBSTR(B.ESTADO, 4, 1) = mi_estado_uno
       AND SUBSTR(B.ESTADO, 9, 1) = mi_estado_cero
       AND B.fecha_aprobacion <= fecha_corte
       AND A.VALOR_REGISTRO < mi_valor_cero
       AND TO_CHAR(FECHA_APROBACION, 'YYYY') = TO_CHAR(una_vigencia);
    RETURN NVL(MI_VALOR_RA, 0);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR('-20001',
                              'Error en OGT_FN_ACUM_AJUSTE ' || SQLERRM);
  END OGT_FN_AJUSTEACUM_REGISTRO;
  --AAGUIRRE 06-12-2004 O.K.
  --FUNCION QUE DEVUELVE EL VALOR DE REINTEGROS
  --ACUMULADOS A UNA FECHA DE CORTE
  --BASADO EN OGT_FN_REINT_ACUM
  -- MODIFICADA POR FANNY MALAGON 12-01-2005 PARA SACAR LOR REEMBOLSOS DE CAJA MENOR
  -- MODIFICADA POR FANNY 14-01-2005 SE QUITO EL CRITERIO DE WHERE Y ASE ADICIONO INF DE LA NOMINA
  FUNCTION OGT_FN_REINTACUM_REGISTRO(una_vigencia                 NUMBER,
                                     un_codigo_compania           VARCHAR2,
                                     un_codigo_unidad_ejecutora   VARCHAR2,
                                     numero_registro_presupuestal NUMBER,
                                     un_interno                   NUMBER,
                                     fecha_corte                  DATE)
    RETURN NUMBER IS
  BEGIN
    SELECT SUM(A.VALOR)
      INTO mi_valor_OP
      FROM OGT_DETALLE_ACTAS A, OGT_ACTAS B
     WHERE A.CONSECUTIVO = B.CONSECUTIVO
       AND A.VIGENCIA = B.VIGENCIA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
          /*      AND B.VIGENCIA = TO_CHAR(una_vigencia)
                AND B.ENTIDAD = mi_entidad_reintegros
                AND B.UNIDAD_EJECUTORA = mi_unidad_ejecutora_reintegros
                */
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_ar
       AND A.RUBRO_INTERNO = un_interno
       AND A.REGISTRO = numero_registro_presupuestal
       AND A.DOC_VIGENCIA = TO_CHAR(una_vigencia)
       AND A.DOC_ENTIDAD = un_codigo_compania
       AND A.DOC_UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
       AND A.DOC_TIPO_DOCUMENTO = mi_tipo_documento_op
       AND NVL(B.TIPO_OP, 3) != mi_tipo_caja_menor
       AND B.fecha <= fecha_corte;
    RETURN(NVL(MI_VALOR_OP, 0)); --NVL(mi_valor_ar,0)
  END OGT_FN_REINTACUM_REGISTRO;
  --REQ 79-2005
  --AAGUIRRE 24-02-2005
  --FUNCION QUE DEVUELVE EL VALOR DE LOS AJUSTES EN LA VIGENCIA
  --A UNA FECHA DE CORTE
  --
  FUNCTION OGT_FN_AJUSTEACUM(una_vigencia               NUMBER,
                             un_codigo_compania         VARCHAR2,
                             un_codigo_unidad_ejecutora VARCHAR2,
                             un_rubro_interno           NUMBER,
                             fecha_corte                DATE) RETURN NUMBER IS
  MI_FECHA1 DATE;
  MI_FECHA2 DATE;

  BEGIN

  MI_FECHA1 := TO_DATE('01-01-'||TO_CHAR(UNA_VIGENCIA),'DD-MM-YYYY');
  MI_FECHA2 := TO_DATE(FECHA_CORTE,'DD-MM-YYYY');

    IF TO_NUMBER(TO_CHAR(fecha_corte,'YYYY'))= una_vigencia THEN
       BEGIN
          SELECT NVL(SUM(VALOR_REGISTRO), 0)
            INTO MI_VALOR_RA
            FROM OGT_REGISTRO_PRESUPUESTAL A, OGT_RELACION_AUTORIZACION B
           WHERE A.VIGENCIA = B.VIGENCIA
             AND A.ENTIDAD = B.ENTIDAD
             AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
             AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
             AND A.CONSECUTIVO = B.CONSECUTIVO
             AND A.RUBRO_INTERNO = un_rubro_interno
             AND B.VIGENCIA = TO_CHAR(una_vigencia)
             AND A.ENTIDAD_PRESUPUESTO = un_codigo_compania
             AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
             AND B.TIPO_DOCUMENTO = mi_tipo_documento_ra
             AND B.IND_APROBADO = mi_valor_uno
             AND SUBSTR(B.ESTADO, 4, 1) = mi_estado_uno
             AND TO_DATE(B.fecha_aprobacion,'DD-MM-RRRR') >=  TO_DATE(MI_FECHA1,'DD-MM-RRRR')
             AND TO_DATE(B.fecha_aprobacion,'DD-MM-RRRR') <=  TO_DATE(MI_FECHA2,'DD-MM-RRRR')
             AND NVL(A.VALOR_REGISTRO, 0) < 0;

             RETURN NVL(MI_VALOR_RA, 0);

        EXCEPTION
           WHEN OTHERS THEN
           RETURN 0;
       END;
    ELSE
           RETURN 0;
    END IF;

  END OGT_FN_AJUSTEACUM;
  --REQ 79-2005
  --AAGUIRRE 24-02-2005
  --FUNCION QUE DEVUELVE EL VALOR DE LOS AJUSTES EN LA VIGENCIA
  --EN UN RANGO DE FECHAS
  FUNCTION OGT_FN_AJUSTEACUMF(una_vigencia               NUMBER,
                              un_codigo_compania         VARCHAR2,
                              un_codigo_unidad_ejecutora VARCHAR2,
                              un_rubro_interno           NUMBER,
                              fecha_inicial              DATE,
                              fecha_final                DATE) RETURN NUMBER IS
  BEGIN
          SELECT NVL(SUM(VALOR_REGISTRO), 0)
            INTO MI_VALOR_RA
            FROM OGT_REGISTRO_PRESUPUESTAL A, OGT_RELACION_AUTORIZACION B
           WHERE A.VIGENCIA = B.VIGENCIA
             AND A.ENTIDAD = B.ENTIDAD
             AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
             AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
             AND A.CONSECUTIVO = B.CONSECUTIVO
             AND A.RUBRO_INTERNO = un_rubro_interno
             AND B.VIGENCIA = TO_CHAR(una_vigencia)
             AND A.ENTIDAD_PRESUPUESTO = un_codigo_compania
             AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
             AND B.TIPO_DOCUMENTO = mi_tipo_documento_ra
             AND B.IND_APROBADO = mi_valor_uno
             AND SUBSTR(B.ESTADO, 4, 1) = mi_estado_uno
             AND TO_DATE(B.fecha_aprobacion,'DD-MM-RRRR') >=  TO_DATE(fecha_inicial ,'DD-MM-RRRR')
             AND TO_DATE(B.fecha_aprobacion,'DD-MM-RRRR') <=  TO_DATE(fecha_final,'DD-MM-RRRR')
             AND NVL(A.VALOR_REGISTRO, 0) < 0;
             RETURN NVL(MI_VALOR_RA, 0);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END OGT_FN_AJUSTEACUMF;
--req 79-2005
--aaguirre 24-02-2005
--funcion que devuelve el valor de los reintegros en la vigencia
--en una fecha de corte
FUNCTION OGT_FN_REINTEGROSACUM(una_vigencia                NUMBER
                               ,un_codigo_compania         VARCHAR2
                               ,un_codigo_unidad_ejecutora VARCHAR2
                               ,un_rubro_interno           NUMBER
                               ,fecha_corte                DATE
                               ) RETURN NUMBER IS
  MI_FECHA1 DATE;
  MI_FECHA2 DATE;
  BEGIN
  MI_FECHA1 := TO_DATE('01-01-'||TO_CHAR(UNA_VIGENCIA),'DD-MM-YYYY');
  MI_FECHA2 := TO_DATE(FECHA_CORTE,'DD-MM-YYYY');   IF TO_NUMBER(TO_CHAR(fecha_corte,'YYYY'))= una_vigencia THEN
    BEGIN
    SELECT SUM(A.VALOR)
      INTO mi_valor_OP
      FROM OGT_DETALLE_ACTAS A, OGT_ACTAS B
     WHERE A.CONSECUTIVO = B.CONSECUTIVO
       AND A.VIGENCIA = B.VIGENCIA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND B.VIGENCIA = TO_CHAR(una_vigencia)
       AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_ar
       AND TO_CHAR(B.fecha,'DD-MM-YYYY') >=  TO_CHAR(MI_FECHA1,'DD-MM-YYYY')
       AND TO_CHAR(B.fecha,'DD-MM-YYYY') <=  TO_CHAR(MI_FECHA2,'DD-MM-YYYY')
       AND A.RUBRO_INTERNO = un_rubro_interno
       AND A.DOC_VIGENCIA = TO_CHAR(una_vigencia)
       AND A.DOC_ENTIDAD = un_codigo_compania
       AND A.DOC_UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
       AND NVL(B.TIPO_OP, 3) != mi_tipo_caja_menor;
    RETURN(NVL(mi_valor_OP, 0));
    EXCEPTION
           WHEN OTHERS THEN
           RETURN 0;
    END;
    ELSE
           RETURN 0;
    END IF;

  END OGT_FN_REINTEGROSACUM;
--REQ 79-2005
--AAGUIRRE 24-02-2005
--FUNCION QUE DEVUELVE EL VALOR DE LOS REINTEGROS EN LA VIGENCIA
--EN UN RANGO DE FECHAS
  FUNCTION OGT_FN_REINTEGROSACUMF(una_vigencia               NUMBER
                                 ,un_codigo_compania         VARCHAR2
                                 ,un_codigo_unidad_ejecutora VARCHAR2
                                 ,un_rubro_interno           NUMBER
                                 ,fecha_inicial              DATE
                                 ,fecha_final                DATE
                                 ) RETURN NUMBER IS
  BEGIN
    BEGIN
    SELECT SUM(A.VALOR)
      INTO mi_valor_OP
      FROM OGT_DETALLE_ACTAS A, OGT_ACTAS B
     WHERE A.CONSECUTIVO = B.CONSECUTIVO
       AND A.VIGENCIA = B.VIGENCIA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND B.VIGENCIA = TO_CHAR(una_vigencia)
       AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_ar
       AND B.fecha BETWEEN fecha_final AND fecha_final
       AND A.RUBRO_INTERNO = un_rubro_interno
       AND A.DOC_VIGENCIA = TO_CHAR(una_vigencia)
       AND A.DOC_ENTIDAD = un_codigo_compania
       AND A.DOC_UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
       AND NVL(B.TIPO_OP, 3) != mi_tipo_caja_menor;
       RETURN(NVL(mi_valor_OP, 0));
     EXCEPTION
           WHEN OTHERS THEN
           RETURN 0;
     END;
  END OGT_FN_REINTEGROSACUMF;
--REQ 79-2005
--AAGUIRRE 24-02-2005
--funcion que devuelve el valor de las ordenes de pago de una vigencia
--a una fecha de corte
FUNCTION OGT_FN_GIROSFC(una_vigencia               NUMBER
                        ,un_codigo_compania         VARCHAR2
                        ,un_codigo_unidad_ejecutora VARCHAR2
                        ,un_rubro_interno           NUMBER
                        ,fecha_corte                DATE
                        ) RETURN NUMBER IS

     MI_FECHA1 DATE;
     MI_FECHA2 DATE;
  BEGIN
  MI_FECHA1 := TO_DATE('01-01-'||TO_CHAR(UNA_VIGENCIA),'DD-MM-YYYY');
  MI_FECHA2 := TO_DATE(FECHA_CORTE,'DD-MM-YYYY');
  IF TO_NUMBER(TO_CHAR(fecha_corte,'YYYY'))= una_vigencia THEN
    BEGIN
    SELECT NVL(SUM(VALOR_BRUTO), 0)
      INTO mi_valor_op
      FROM OGT_INFORMACION_EXOGENA A, OGT_ORDEN_PAGO B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO = B.CONSECUTIVO
       AND A.RUBRO_INTERNO = un_rubro_interno
       AND B.VIGENCIA = TO_CHAR(una_vigencia)
       AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_op
       AND B.ENTIDAD_PRESUPUESTO = un_codigo_compania
       AND B.TIPO_OP != mi_tipo_caja_menor
       AND IND_APROBADO = mi_valor_uno
       AND TO_DATE(B.fecha_aprobacion,'DD-MM-RRRR')>= TO_DATE(MI_FECHA1,'DD-MM-RRRR')
       AND TO_DATE(B.fecha_aprobacion,'DD-MM-RRRR') <= TO_DATE(MI_FECHA2,'DD-MM-RRRR')
       AND NVL(A.VALOR_BRUTO, 0) > 0;
    EXCEPTION
           WHEN OTHERS THEN
           mi_valor_op := 0;
       END;
    BEGIN
    SELECT NVL(SUM(VALOR_REGISTRO), 0)
      INTO mi_valor_ra
      FROM OGT_REGISTRO_PRESUPUESTAL A, OGT_RELACION_AUTORIZACION B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO = B.CONSECUTIVO
       AND A.RUBRO_INTERNO = un_rubro_interno
       AND B.VIGENCIA = TO_CHAR(una_vigencia)
       AND A.ENTIDAD_PRESUPUESTO = un_codigo_compania
       AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_ra
       AND B.IND_APROBADO = mi_valor_uno
       AND SUBSTR(B.ESTADO, 4, 1) = mi_estado_uno
       AND TO_DATE(B.fecha_aprobacion,'DD-MM-RRRR') >=  TO_DATE(MI_FECHA1,'DD-MM-RRRR')
       AND TO_DATE(B.fecha_aprobacion,'DD-MM-RRRR') <=  TO_DATE(MI_FECHA2,'DD-MM-RRRR')
       AND NVL(A.VALOR_REGISTRO, 0) > 0;
       EXCEPTION
           WHEN OTHERS THEN
           mi_valor_ra := 0;
       END;
       RETURN(NVL(mi_valor_op, 0) + NVL(mi_valor_ra, 0));
    ELSE
           RETURN 0;
    END IF;

  END OGT_FN_GIROSFC;
--REQ 79-2005
--AAGUIRRE 24-02-2005
--funcion que devuelve el valor de las ordenes de pago de una vigencia
--en un rango de fechas
FUNCTION OGT_FN_GIROS(una_vigencia               NUMBER
                      ,un_codigo_compania         VARCHAR2
                      ,un_codigo_unidad_ejecutora VARCHAR2
                      ,un_rubro_interno           NUMBER
                      ,fecha_inicial              DATE
                      ,fecha_final                DATE
                      ) RETURN NUMBER IS
BEGIN
    BEGIN
    SELECT NVL(SUM(VALOR_BRUTO), 0)
      INTO mi_valor_op
      FROM OGT_INFORMACION_EXOGENA A, OGT_ORDEN_PAGO B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO = B.CONSECUTIVO
       AND A.RUBRO_INTERNO = un_rubro_interno
       AND B.VIGENCIA = TO_CHAR(una_vigencia)
       AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_op
       AND B.ENTIDAD_PRESUPUESTO = un_codigo_compania
       AND B.TIPO_OP != mi_tipo_caja_menor
       AND IND_APROBADO = mi_valor_uno
       AND TO_DATE(B.fecha_aprobacion,'DD-MM-RRRR') >=  TO_DATE(fecha_inicial,'DD-MM-RRRR')
       AND TO_DATE(B.fecha_aprobacion,'DD-MM-RRRR') <=  TO_DATE(fecha_final,'DD-MM-RRRR')
       AND TO_CHAR(B.FECHA_APROBACION, 'YYYY') = TO_CHAR(una_vigencia)
       AND NVL(A.VALOR_BRUTO, 0) > 0;
    EXCEPTION
           WHEN OTHERS THEN
           mi_valor_op := 0;
       END;
    BEGIN
    SELECT NVL(SUM(VALOR_REGISTRO), 0)
      INTO mi_valor_ra
      FROM OGT_REGISTRO_PRESUPUESTAL A, OGT_RELACION_AUTORIZACION B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO = B.CONSECUTIVO
       AND A.RUBRO_INTERNO = un_rubro_interno
       AND B.VIGENCIA = TO_CHAR(una_vigencia)
       AND B.ENTIDAD = un_codigo_compania
       AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_ra
       AND B.IND_APROBADO = mi_valor_uno
       AND SUBSTR(B.ESTADO, 4, 1) = mi_estado_uno
       AND TO_DATE(B.fecha_aprobacion,'DD-MM-RRRR') >=  TO_DATE(fecha_inicial,'DD-MM-RRRR')
       AND TO_DATE(B.fecha_aprobacion,'DD-MM-RRRR') <=  TO_DATE(fecha_final,'DD-MM-RRRR')
       AND NVL(A.VALOR_REGISTRO, 0) > 0;
       EXCEPTION
           WHEN OTHERS THEN
           mi_valor_ra := 0;
       END;
       RETURN(NVL(mi_valor_op, 0) + NVL(mi_valor_ra, 0));
  END OGT_FN_GIROS;

--REQ 79-2005
--AAGUIRRE 24-02-2005
--funcion que devuelve el valor de las anulaciones de ordenes de pago de una vigencia
--en una fecha de corte
FUNCTION OGT_FN_ANULGIROFC(una_vigencia                NUMBER
                           ,un_codigo_compania         VARCHAR2
                           ,un_codigo_unidad_ejecutora VARCHAR2
                           ,un_rubro_interno           NUMBER
                           ,fecha_corte                DATE
                           ) RETURN NUMBER IS
  MI_FECHA1 DATE;
  MI_FECHA2 DATE;
  BEGIN
  MI_FECHA1 := TO_DATE('01-01-'||TO_CHAR(UNA_VIGENCIA),'DD-MM-YYYY');
  MI_FECHA2 := TO_DATE(FECHA_CORTE,'DD-MM-YYYY');
   IF TO_NUMBER(TO_CHAR(fecha_corte,'YYYY'))= una_vigencia THEN
    BEGIN
    SELECT NVL(SUM(VALOR_BRUTO), 0)
      INTO mi_valor_op
      FROM OGT_INFORMACION_EXOGENA A, OGT_ORDEN_PAGO B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO = B.CONSECUTIVO
       AND A.RUBRO_INTERNO = un_rubro_interno
       AND B.VIGENCIA = TO_CHAR(una_vigencia)
       AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
       AND B.ENTIDAD_PRESUPUESTO = un_codigo_compania
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_op
       AND B.TIPO_OP != mi_tipo_caja_menor
       AND B.IND_APROBADO = mi_valor_uno
       AND B.IND_ANULADO = mi_valor_uno
       AND SUBSTR(B.ESTADO, 9, 1) = mi_estado_uno
       AND TO_DATE(B.fecha_anulacion,'DD-MM-YYYY') >=  TO_DATE(MI_FECHA1,'DD-MM-YYYY')
       AND TO_DATE(B.fecha_anulacion,'DD-MM-YYYY') <=  TO_DATE(MI_FECHA2,'DD-MM-YYYY');
        EXCEPTION
           WHEN OTHERS THEN
           mi_valor_op :=0;
       END;

    BEGIN
    SELECT NVL(SUM(VALOR_REGISTRO), 0)
      INTO mi_valor_ra
      FROM OGT_REGISTRO_PRESUPUESTAL A, OGT_RELACION_AUTORIZACION B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO = B.CONSECUTIVO
       AND A.RUBRO_INTERNO = un_rubro_interno
       AND B.VIGENCIA = TO_CHAR(una_vigencia)
       AND A.ENTIDAD_PRESUPUESTO = un_codigo_compania
       AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_ra
       AND B.IND_APROBADO = mi_valor_uno
       AND B.IND_ANULADO = mi_valor_uno
       AND SUBSTR(B.ESTADO, 4, 1) = mi_estado_uno
       AND SUBSTR(B.ESTADO, 9, 1) = mi_estado_uno
       AND TO_DATE(B.fecha_anulacion,'DD-MM-YYYY') >=  TO_DATE(MI_FECHA1,'DD-MM-YYYY')
       AND TO_DATE(B.fecha_anulacion,'DD-MM-YYYY') <=  TO_DATE(MI_FECHA2,'DD-MM-YYYY');
       EXCEPTION
           WHEN OTHERS THEN
           mi_valor_ra :=0;
       END;
       RETURN(NVL(mi_valor_op, 0) + NVL(mi_valor_ra, 0));
    ELSE
           RETURN 0;
    END IF;
 END OGT_FN_ANULGIROFC;

--REQ 79-2005
--AAGUIRRE 24-02-2005
--funcion que devuelve el valor de las anulaciones de ordenes de pago de una vigencia
--en un rango de fechas
FUNCTION OGT_FN_ANULGIRO(una_vigencia                NUMBER
                           ,un_codigo_compania       VARCHAR2
                           ,un_codigo_unidad_ejecutora VARCHAR2
                           ,un_rubro_interno         NUMBER
                           ,fecha_inicial            DATE
                           ,fecha_final              DATE ) RETURN NUMBER IS
 BEGIN
  BEGIN
    SELECT NVL(SUM(VALOR_BRUTO), 0)
      INTO mi_valor_op
      FROM OGT_INFORMACION_EXOGENA A, OGT_ORDEN_PAGO B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO = B.CONSECUTIVO
       AND A.RUBRO_INTERNO = un_rubro_interno
       AND B.VIGENCIA = TO_CHAR(una_vigencia)
       AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
       AND B.ENTIDAD_PRESUPUESTO = un_codigo_compania
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_op
       AND B.TIPO_OP != mi_tipo_caja_menor
       AND B.IND_APROBADO = mi_valor_uno
       AND B.IND_ANULADO = mi_valor_uno
       AND SUBSTR(B.ESTADO, 9, 1) = mi_estado_uno
       AND TO_DATE(B.fecha_anulacion,'DD-MM-YYYY') >=  TO_DATE(fecha_inicial ,'DD-MM-YYYY')
       AND TO_DATE(B.fecha_anulacion,'DD-MM-YYYY') <=  TO_DATE(fecha_final ,'DD-MM-YYYY');
    EXCEPTION
           WHEN OTHERS THEN
           mi_valor_op :=0;
    END;
    BEGIN
    SELECT NVL(SUM(VALOR_REGISTRO), 0)
      INTO mi_valor_ra
      FROM OGT_REGISTRO_PRESUPUESTAL A, OGT_RELACION_AUTORIZACION B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO = B.CONSECUTIVO
       AND A.RUBRO_INTERNO = un_rubro_interno
       AND B.VIGENCIA = TO_CHAR(una_vigencia)
       AND B.ENTIDAD = un_codigo_compania
       AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_ra
       AND B.IND_APROBADO = mi_valor_uno
       AND B.IND_ANULADO = mi_valor_uno
       AND SUBSTR(B.ESTADO, 4, 1) = mi_estado_uno
       AND SUBSTR(B.ESTADO, 9, 1) = mi_estado_uno
       AND TO_DATE(B.fecha_anulacion,'DD-MM-YYYY') >=  TO_DATE(fecha_inicial ,'DD-MM-YYYY')
       AND TO_DATE(B.fecha_anulacion,'DD-MM-YYYY') <=  TO_DATE(fecha_final ,'DD-MM-YYYY')
       AND NVL(A.VALOR_REGISTRO, 0) > mi_valor_cero;
    EXCEPTION
           WHEN OTHERS THEN
           mi_valor_ra :=0;
    END;
    RETURN(NVL(mi_valor_op, 0) + NVL(mi_valor_ra, 0));
  END OGT_FN_ANULGIRO;

--REQ 324-2005
--AAGUIRRE 28-03-2005
--funcion que devuelve el valor de las ordenes de pago de una vigencia
--en un rango de fechas y que efectivamente se pagaron por tesoreria
FUNCTION OGT_FN_GIROS_PAGADOS(una_vigencia               NUMBER
                      ,un_codigo_compania         VARCHAR2
                      ,un_codigo_unidad_ejecutora VARCHAR2
                      ,un_rubro_interno           NUMBER
                      ,fecha_inicial              DATE
                      ,fecha_final                DATE
                      ) RETURN NUMBER IS
BEGIN
    BEGIN
    SELECT NVL(SUM(VALOR_BRUTO), 0)
      INTO mi_valor_op
      FROM OGT_INFORMACION_EXOGENA A, OGT_ORDEN_PAGO B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO = B.CONSECUTIVO
       AND A.RUBRO_INTERNO = un_rubro_interno
       AND B.VIGENCIA = TO_CHAR(una_vigencia)
       AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_op
       AND B.ENTIDAD_PRESUPUESTO = un_codigo_compania
       AND B.TIPO_OP != mi_tipo_caja_menor
       AND SUBSTR(B.ESTADO, 8, 1) = mi_estado_uno
       AND B.IND_APROBADO = mi_valor_uno
       AND TO_DATE(PK_OGT_GIROS.FN_OGT_MINIMA_FECHA_PAGO(A.VIGENCIA,A.ENTIDAD,A.UNIDAD_EJECUTORA,A.TIPO_DOCUMENTO,A.CONSECUTIVO),'DD-MM-RRRR') >=  TO_DATE(fecha_inicial,'DD-MM-RRRR')
       AND TO_DATE(PK_OGT_GIROS.FN_OGT_MINIMA_FECHA_PAGO(A.VIGENCIA,A.ENTIDAD,A.UNIDAD_EJECUTORA,A.TIPO_DOCUMENTO,A.CONSECUTIVO),'DD-MM-RRRR') <=  TO_DATE(fecha_final,'DD-MM-RRRR')
       --AND TO_DATE(B.fecha_aprobacion,'DD-MM-RRRR') >=  TO_DATE(fecha_inicial,'DD-MM-RRRR')
       -- AND TO_DATE(B.fecha_aprobacion,'DD-MM-RRRR') <=  TO_DATE(fecha_final,'DD-MM-RRRR')
       AND TO_CHAR(B.FECHA_APROBACION, 'YYYY') = TO_CHAR(una_vigencia)
       AND NVL(A.VALOR_BRUTO, 0) > 0;
    EXCEPTION
           WHEN OTHERS THEN
           mi_valor_op := 0;
       END;
    BEGIN
    SELECT NVL(SUM(VALOR_REGISTRO), 0)
      INTO mi_valor_ra
      FROM OGT_REGISTRO_PRESUPUESTAL A, OGT_RELACION_AUTORIZACION B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO = B.CONSECUTIVO
       AND A.RUBRO_INTERNO = un_rubro_interno
       AND B.VIGENCIA = TO_CHAR(una_vigencia)
       AND B.ENTIDAD = un_codigo_compania
       AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_ra
       AND B.IND_APROBADO = mi_valor_uno
       AND SUBSTR(B.ESTADO, 8, 1) = mi_estado_uno
       AND SUBSTR(B.ESTADO, 4, 1) = mi_estado_uno
       AND TO_DATE(PK_OGT_GIROS.FN_OGT_MINIMA_FECHA_PAGO(A.VIGENCIA,A.ENTIDAD,A.UNIDAD_EJECUTORA,A.TIPO_DOCUMENTO,A.CONSECUTIVO),'DD-MM-RRRR') >=  TO_DATE(fecha_inicial,'DD-MM-RRRR')
       AND TO_DATE(PK_OGT_GIROS.FN_OGT_MINIMA_FECHA_PAGO(A.VIGENCIA,A.ENTIDAD,A.UNIDAD_EJECUTORA,A.TIPO_DOCUMENTO,A.CONSECUTIVO),'DD-MM-RRRR') <=  TO_DATE(fecha_final,'DD-MM-RRRR')
       --AND TO_DATE(B.fecha_aprobacion,'DD-MM-RRRR') >=  TO_DATE(fecha_inicial,'DD-MM-RRRR')
       --AND TO_DATE(B.fecha_aprobacion,'DD-MM-RRRR') <=  TO_DATE(fecha_final,'DD-MM-RRRR')
       AND NVL(A.VALOR_REGISTRO, 0) > 0;
       EXCEPTION
           WHEN OTHERS THEN
           mi_valor_ra := 0;
       END;
       RETURN(NVL(mi_valor_op, 0) + NVL(mi_valor_ra, 0));
  END OGT_FN_GIROS_PAGADOS;
--REQ 375-2005
--AAGUIRRE 01-04-2005
--funcion que retorna el valor total (incluyendo las anuladas) de las ordenes
--de pago de reservas a una fecha de corte.
FUNCTION OGT_FN_GIROSFC_RESERVA(una_vigencia               NUMBER
                        ,un_codigo_compania         VARCHAR2
                        ,un_codigo_unidad_ejecutora VARCHAR2
                        ,un_rubro_interno           NUMBER
                        ,fecha_corte                DATE
                        ) RETURN NUMBER IS

  MI_FECHA1 DATE;
  MI_FECHA2 DATE;

  BEGIN
  MI_FECHA1 := TO_DATE('01-01-'||TO_CHAR(UNA_VIGENCIA),'DD-MM-YYYY');
  MI_FECHA2 := TO_DATE(FECHA_CORTE,'DD-MM-YYYY');
  BEGIN
    SELECT NVL(SUM(VALOR_BRUTO), 0)
      INTO mi_valor_op
      FROM OGT_INFORMACION_EXOGENA A, OGT_ORDEN_PAGO B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO = B.CONSECUTIVO
       AND A.RUBRO_INTERNO = un_rubro_interno
       AND B.VIGENCIA = TO_CHAR(TO_NUMBER(una_vigencia) - 1)
       AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_op
       AND B.ENTIDAD_PRESUPUESTO = un_codigo_compania
       AND B.TIPO_OP != mi_tipo_caja_menor
       AND IND_APROBADO = mi_valor_uno
       AND TO_DATE(B.fecha_aprobacion,'DD-MM-RRRR') >= TO_DATE(MI_FECHA1,'DD-MM-RRRR')
       AND TO_DATE(B.fecha_aprobacion,'DD-MM-RRRR') <= TO_DATE(MI_FECHA2,'DD-MM-RRRR')
       AND NVL(A.VALOR_BRUTO, 0) > 0;
    EXCEPTION
           WHEN OTHERS THEN
           mi_valor_op := 0;
  END;
  BEGIN
    SELECT NVL(SUM(VALOR_REGISTRO), 0)
      INTO mi_valor_ra
      FROM OGT_REGISTRO_PRESUPUESTAL A, OGT_RELACION_AUTORIZACION B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO = B.CONSECUTIVO
       AND A.RUBRO_INTERNO = un_rubro_interno
       AND B.VIGENCIA = TO_CHAR(TO_NUMBER(una_vigencia) - 1)
       AND A.ENTIDAD_PRESUPUESTO = un_codigo_compania
       AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_ra
       AND B.IND_APROBADO = mi_valor_uno
       AND SUBSTR(B.ESTADO, 4, 1) = mi_estado_uno
       AND TO_DATE(B.fecha_aprobacion,'DD-MM-RRRR') >= TO_DATE(MI_FECHA1,'DD-MM-RRRR')
       AND TO_DATE(B.fecha_aprobacion,'DD-MM-RRRR') <=  TO_DATE(MI_FECHA2,'DD-MM-RRRR')
       AND NVL(A.VALOR_REGISTRO, 0) > 0;
       EXCEPTION
           WHEN OTHERS THEN
           mi_valor_ra := 0;
  END;
  RETURN(NVL(mi_valor_op, 0) + NVL(mi_valor_ra, 0));

  END OGT_FN_GIROSFC_RESERVA;
--REQ 375-2005
--AAGUIRRE 01-04-2005
--funcion que retorna el valor de las ordenes de pago anuladas
--de reservas a una fecha de corte
FUNCTION OGT_FN_ANULGIROFC_RESERVA(una_vigencia                NUMBER
                           ,un_codigo_compania         VARCHAR2
                           ,un_codigo_unidad_ejecutora VARCHAR2
                           ,un_rubro_interno           NUMBER
                           ,fecha_corte                DATE
                           ) RETURN NUMBER IS
  MI_FECHA1 DATE;
  MI_FECHA2 DATE;

  BEGIN
  MI_FECHA1 := TO_DATE('01-01-'||TO_CHAR(UNA_VIGENCIA),'DD-MM-YYYY');
  MI_FECHA2 := TO_DATE(FECHA_CORTE,'DD-MM-YYYY');
  BEGIN
    SELECT NVL(SUM(VALOR_BRUTO), 0)
      INTO mi_valor_op
      FROM OGT_INFORMACION_EXOGENA A, OGT_ORDEN_PAGO B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO = B.CONSECUTIVO
       AND A.RUBRO_INTERNO = un_rubro_interno
       AND B.VIGENCIA = TO_CHAR(TO_NUMBER(una_vigencia) - 1)
       AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
       AND B.ENTIDAD_PRESUPUESTO = un_codigo_compania
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_op
       AND B.TIPO_OP != mi_tipo_caja_menor
       AND B.IND_APROBADO = mi_valor_uno
       AND B.IND_ANULADO = mi_valor_uno
       AND SUBSTR(B.ESTADO, 9, 1) = mi_estado_uno
       AND TO_DATE(B.fecha_anulacion,'DD-MM-YYYY') >=  TO_DATE(MI_FECHA1,'DD-MM-YYYY')
       AND TO_DATE(B.fecha_anulacion,'DD-MM-YYYY') <=  TO_DATE(MI_FECHA2,'DD-MM-YYYY');
        EXCEPTION
           WHEN OTHERS THEN
           mi_valor_op :=0;
  END;
  BEGIN
    SELECT NVL(SUM(VALOR_REGISTRO), 0)
      INTO mi_valor_ra
      FROM OGT_REGISTRO_PRESUPUESTAL A, OGT_RELACION_AUTORIZACION B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO = B.CONSECUTIVO
       AND A.RUBRO_INTERNO = un_rubro_interno
       AND B.VIGENCIA = TO_CHAR(TO_NUMBER(una_vigencia) - 1)
       AND A.ENTIDAD_PRESUPUESTO = un_codigo_compania
       AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_ra
       AND B.IND_APROBADO = mi_valor_uno
       AND B.IND_ANULADO = mi_valor_uno
       AND SUBSTR(B.ESTADO, 4, 1) = mi_estado_uno
       AND SUBSTR(B.ESTADO, 9, 1) = mi_estado_uno
       AND TO_DATE(B.fecha_anulacion,'DD-MM-YYYY') >=  TO_DATE(MI_FECHA1,'DD-MM-YYYY')
       AND TO_DATE(B.fecha_anulacion,'DD-MM-YYYY') <=  TO_DATE(MI_FECHA2,'DD-MM-YYYY');
       EXCEPTION
           WHEN OTHERS THEN
           mi_valor_ra :=0;
  END;
       RETURN(NVL(mi_valor_op, 0) + NVL(mi_valor_ra, 0));
  END OGT_FN_ANULGIROFC_RESERVA;
  --REQ 375-2005
  --AAGUIRRE 01-04-2005
  --FUNCION QUE DEVUELVE EL VALOR DE LOS AJUSTES DE RESERVAS
  --A UNA FECHA DE CORTE
  FUNCTION OGT_FN_AJUSTEFC_RESERVA(una_vigencia         NUMBER,
                             un_codigo_compania         VARCHAR2,
                             un_codigo_unidad_ejecutora VARCHAR2,
                             un_rubro_interno           NUMBER,
                             fecha_corte                DATE) RETURN NUMBER IS

  MI_FECHA1  DATE;
  MI_FECHA2  DATE;

  BEGIN
  MI_FECHA1 := TO_DATE('01-01-'||TO_CHAR(UNA_VIGENCIA),'DD-MM-YYYY');
  MI_FECHA2 := TO_DATE(FECHA_CORTE,'DD-MM-YYYY');
  BEGIN
          SELECT NVL(SUM(VALOR_REGISTRO), 0)
            INTO MI_VALOR_RA
            FROM OGT_REGISTRO_PRESUPUESTAL A, OGT_RELACION_AUTORIZACION B
           WHERE A.VIGENCIA = B.VIGENCIA
             AND A.ENTIDAD = B.ENTIDAD
             AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
             AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
             AND A.CONSECUTIVO = B.CONSECUTIVO
             AND A.RUBRO_INTERNO = un_rubro_interno
             AND B.VIGENCIA = TO_CHAR(TO_NUMBER(una_vigencia) - 1)
             AND A.ENTIDAD_PRESUPUESTO = un_codigo_compania
             AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
             AND B.TIPO_DOCUMENTO = mi_tipo_documento_ra
             AND B.IND_APROBADO = mi_valor_uno
             AND SUBSTR(B.ESTADO, 4, 1) = mi_estado_uno
             AND TO_DATE(B.fecha_aprobacion,'DD-MM-YYYY') >=  TO_DATE(MI_FECHA1,'DD-MM-YYYY')
             AND TO_DATE(B.fecha_aprobacion,'DD-MM-RRRR') <=  TO_DATE(MI_FECHA2,'DD-MM-RRRR')
             AND NVL(A.VALOR_REGISTRO, 0) < 0;
             RETURN NVL(MI_VALOR_RA, 0);
        EXCEPTION
           WHEN OTHERS THEN
           RETURN 0;
   END;

  END OGT_FN_AJUSTEFC_RESERVA;
--req 375-2005
--aaguirre 01-04-2005
--funcion que devuelve el valor de los reintegros de reservas
--en una fecha de corte
FUNCTION OGT_FN_REINTEGROFC_RESERVA(una_vigencia                NUMBER
                               ,un_codigo_compania         VARCHAR2
                               ,un_codigo_unidad_ejecutora VARCHAR2
                               ,un_rubro_interno           NUMBER
                               ,fecha_corte                DATE
                               ) RETURN NUMBER IS
  MI_FECHA2 DATE;
  BEGIN
    MI_FECHA2 := TO_DATE(FECHA_CORTE,'DD-MM-YYYY');
    BEGIN
    SELECT SUM(A.VALOR)
      INTO mi_valor_OP
      FROM OGT_DETALLE_ACTAS A, OGT_ACTAS B
     WHERE A.CONSECUTIVO = B.CONSECUTIVO
       AND A.VIGENCIA = B.VIGENCIA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND B.VIGENCIA = TO_CHAR(TO_NUMBER(una_vigencia) - 1)
       AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_ar
       AND TO_CHAR(B.fecha,'DD-MM-YYYY') <=  TO_CHAR(MI_FECHA2,'DD-MM-YYYY')
       AND A.RUBRO_INTERNO = un_rubro_interno
       AND A.DOC_VIGENCIA = TO_CHAR(TO_NUMBER(una_vigencia) - 1)
       AND A.DOC_ENTIDAD = un_codigo_compania
       AND A.DOC_UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
       AND NVL(B.TIPO_OP, 3) != mi_tipo_caja_menor;
    RETURN(NVL(mi_valor_OP, 0));
    EXCEPTION
           WHEN OTHERS THEN
           RETURN 0;
    END;

  END OGT_FN_REINTEGROFC_RESERVA;
END;