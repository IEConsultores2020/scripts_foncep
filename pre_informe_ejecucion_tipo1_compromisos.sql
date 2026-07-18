function CF_Compromisos_MesFormula return Number is
  mi_valor_registro        NUMBER(16, 2);
  mi_valor_rp_anulados     NUMBER(16, 2);
  mi_valor_rp_parciales    NUMBER(16, 2);
  mi_valor_compromisos_mes NUMBER(16, 2);
  mi_valor_ajustes         NUMBER(16, 2);
  mi_valor_reintegro       NUMBER(16, 2);
  mi_valor_ajuste_rp       NUMBER(16, 2);
begin

  mi_valor_registro        := NULL; -- Valor Total Registros del Mes
  mi_valor_rp_anulados     := NULL; -- Valor Total RP Anulados del Mes
  mi_valor_rp_parciales    := NULL; -- Valor Liberaciones Parciales de RP del Mes
  mi_valor_compromisos_mes := NULL; -- Compromisos del Mes
  mi_valor_ajustes         := NULL;
  mi_valor_reintegro       := NULL;

  -- Calcula el Valor Total de Registros del Mes
  BEGIN
    SELECT * --NVL(SUM(NVL(pr_registro_disponibilidad.valor,0)),0) valor_registro --INTO mi_valor_registro
      FROM pr_registro_disponibilidad, pr_registro_presupuestal
     WHERE pr_registro_disponibilidad.vigencia =
           pr_registro_presupuestal.vigencia
       AND pr_registro_disponibilidad.codigo_compania =
           pr_registro_presupuestal.codigo_compania
       AND pr_registro_disponibilidad.codigo_unidad_ejecutora =
           pr_registro_presupuestal.codigo_unidad_ejecutora
       AND pr_registro_disponibilidad.numero_disponibilidad =
           pr_registro_presupuestal.numero_disponibilidad
       AND pr_registro_disponibilidad.numero_registro =
           pr_registro_presupuestal.numero_registro
       AND pr_registro_disponibilidad.vigencia = :vigencia
       AND pr_registro_disponibilidad.codigo_compania = :codigo_compania
       AND pr_registro_disponibilidad.codigo_unidad_ejecutora =
           :codigo_unidad_ejecutora
       AND pr_registro_disponibilidad.rubro_interno /*= :rubro_interno AND*/
           in (1831, 1832)
       AND --
           TO_NUMBER(TO_CHAR(pr_registro_presupuestal.fecha_registro, 'MM')) =
           TO_NUMBER(:P_MES);
  EXCEPTION
    WHEN OTHERS THEN
      mi_valor_registro := 0;
  END;

  BEGIN
    SELECT NVL(SUM(NVL(pr_registro_disponibilidad.valor, 0)), 0)
      INTO mi_valor_rp_anulados
      FROM pr_registro_disponibilidad, pr_registro_presupuestal
     WHERE pr_registro_disponibilidad.vigencia =
           pr_registro_presupuestal.vigencia
       AND pr_registro_disponibilidad.codigo_compania =
           pr_registro_presupuestal.codigo_compania
       AND pr_registro_disponibilidad.codigo_unidad_ejecutora =
           pr_registro_presupuestal.codigo_unidad_ejecutora
       AND pr_registro_disponibilidad.numero_disponibilidad =
           pr_registro_presupuestal.numero_disponibilidad
       AND pr_registro_disponibilidad.numero_registro =
           pr_registro_presupuestal.numero_registro
       AND pr_registro_disponibilidad.vigencia = :vigencia
       AND pr_registro_disponibilidad.codigo_compania = :codigo_compania
       AND pr_registro_disponibilidad.codigo_unidad_ejecutora =
           :codigo_unidad_ejecutora
       AND pr_registro_disponibilidad.rubro_interno = :rubro_interno
       AND EXISTS
     (SELECT numero_documento_anulado
              FROM pr_anulaciones
             WHERE vigencia = :vigencia
               AND codigo_compania = :codigo_compania
               AND codigo_unidad_ejecutora = :codigo_unidad_ejecutora
               AND documento_anulado = 'REGISTRO'
               and numero_documento_anulado =
                   pr_registro_presupuestal.numero_registro
               AND TO_NUMBER(TO_CHAR(fecha_registro, 'MM')) =
                   TO_NUMBER(:P_MES));
  EXCEPTION
    WHEN OTHERS THEN
      mi_valor_rp_anulados := 0;
  END;

  -- Liberaciones Parciales del Mes

  BEGIN
    SELECT NVL(SUM(NVL(pr_rp_anulados.valor_anulado, 0)), 0)
      INTO mi_valor_rp_parciales
      FROM pr_rp_anulados
     WHERE vigencia = :vigencia
       AND codigo_compania = :codigo_compania
       AND codigo_unidad_ejecutora = :codigo_unidad_ejecutora
       AND rubro_interno = :rubro_interno
       AND TO_NUMBER(TO_CHAR(fecha_anulacion, 'MM')) = TO_NUMBER(:P_MES)
       AND EXISTS
     (SELECT numero_registro
              FROM pr_registro_presupuestal
             WHERE vigencia = pr_rp_anulados.vigencia
               AND codigo_compania = pr_rp_anulados.codigo_compania
               AND codigo_unidad_ejecutora =
                   pr_rp_anulados.codigo_unidad_ejecutora
               AND numero_registro = pr_rp_anulados.numero_registro
               AND TO_NUMBER(TO_CHAR(fecha_registro, 'MM')) <=
                   TO_NUMBER(:P_MES));
  EXCEPTION
    WHEN OTHERS THEN
      mi_valor_rp_parciales := 0;
  END;

  -- Ajustes/Reintegros Acumulados

  BEGIN
    SELECT NVL(SUM(NVL(pr_reintegro_ajustes_rubro.valor, 0)), 0)
      INTO mi_valor_ajustes
      FROM pr_reintegro_ajustes_rubro, pr_reintegro_ajustes
     WHERE pr_reintegro_ajustes_rubro.vigencia =
           pr_reintegro_ajustes.vigencia
       AND pr_reintegro_ajustes_rubro.codigo_compania =
           pr_reintegro_ajustes.codigo_compania
       AND pr_reintegro_ajustes_rubro.codigo_unidad_ejecutora =
           pr_reintegro_ajustes.codigo_unidad_ejecutora
       AND pr_reintegro_ajustes_rubro.numero_disponibilidad =
           pr_reintegro_ajustes.numero_disponibilidad
       AND pr_reintegro_ajustes_rubro.numero_registro =
           pr_reintegro_ajustes.numero_registro
       AND pr_reintegro_ajustes_rubro.numero_orden =
           pr_reintegro_ajustes.numero_orden
       AND pr_reintegro_ajustes_rubro.consecutivo_orden =
           pr_reintegro_ajustes.consecutivo_orden
       AND pr_reintegro_ajustes_rubro.consecutivo_ajuste =
           pr_reintegro_ajustes.consecutivo_ajuste
       AND pr_reintegro_ajustes_rubro.vigencia = :vigencia
       AND pr_reintegro_ajustes_rubro.codigo_compania = :codigo_compania
       AND pr_reintegro_ajustes_rubro.codigo_unidad_ejecutora =
           :codigo_unidad_ejecutora
       AND pr_reintegro_ajustes_rubro.rubro_interno = :rubro_interno
       AND TO_NUMBER(to_char(pr_reintegro_ajustes.fecha_registro, 'mm')) =
           TO_NUMBER(:p_mes)
       AND pr_reintegro_ajustes.tipo_movimiento = 'AJUSTE';
  EXCEPTION
    WHEN OTHERS THEN
      mi_valor_ajustes := 0;
  END;

  -- Se incluye manejo de ajuste a compromiso, no afecta giros
  BEGIN
    SELECT NVL(SUM(NVL(pr_reintegro_ajustes_rubro.valor, 0)), 0)
      INTO mi_valor_ajuste_rp
      FROM pr_reintegro_ajustes, pr_reintegro_ajustes_rubro
     WHERE pr_reintegro_ajustes_rubro.vigencia =
           pr_reintegro_ajustes.vigencia
       AND pr_reintegro_ajustes_rubro.codigo_compania =
           pr_reintegro_ajustes.codigo_compania
       AND pr_reintegro_ajustes_rubro.codigo_unidad_ejecutora =
           pr_reintegro_ajustes.codigo_unidad_ejecutora
       AND pr_reintegro_ajustes_rubro.numero_disponibilidad =
           pr_reintegro_ajustes.numero_disponibilidad
       AND pr_reintegro_ajustes_rubro.numero_registro =
           pr_reintegro_ajustes.numero_registro
       AND pr_reintegro_ajustes_rubro.numero_orden =
           pr_reintegro_ajustes.numero_orden
       AND pr_reintegro_ajustes_rubro.consecutivo_orden =
           pr_reintegro_ajustes.consecutivo_orden
       AND pr_reintegro_ajustes_rubro.consecutivo_ajuste =
           pr_reintegro_ajustes.consecutivo_ajuste
       AND pr_reintegro_ajustes_rubro.vigencia = :vigencia
       AND pr_reintegro_ajustes_rubro.codigo_compania = :codigo_compania
       AND pr_reintegro_ajustes_rubro.codigo_unidad_ejecutora =
           :codigo_unidad_ejecutora
       AND pr_reintegro_ajustes_rubro.rubro_interno = :rubro_interno
       AND TO_NUMBER(to_char(pr_reintegro_ajustes.fecha_registro, 'mm')) =
           TO_NUMBER(:p_mes)
       AND pr_reintegro_ajustes.tipo_movimiento = 'RP_AJUSTE'
       AND pr_reintegro_ajustes.cerrado = 9;
  EXCEPTION
    WHEN OTHERS THEN
      mi_valor_ajuste_rp := 0;
  END;

  -- inicio RQ 2023000806 famanjarres
  --  mi_valor_ajustes :=0;
  mi_valor_reintegro := 0;
  --  mi_valor_ajuste_rp := 0;
  -- fin RQ 2023000806

  mi_valor_compromisos_mes := NVL(mi_valor_registro, 0) -
                              NVL(mi_valor_rp_anulados, 0) -
                              NVL(mi_valor_rp_parciales, 0) +
                              NVL(mi_valor_ajustes, 0) +
                              NVL(mi_valor_reintegro, 0) +
                              NVL(mi_valor_ajuste_rp, 0);

  RETURN NVL(mi_valor_compromisos_mes, 0);

EXCEPTION
  WHEN OTHERS THEN
    RETURN 0;
end CF_Compromisos_MesFormula;

function CF_CompromisosAcumuladoFormula return Number is

  mi_valor_registro        NUMBER(16, 2);
  mi_valor_rp_anulados     NUMBER(16, 2);
  mi_valor_rp_parciales    NUMBER(16, 2);
  mi_valor_comp_acumulados NUMBER(16, 2);
  mi_valor_ajustes         NUMBER(16, 2);
  mi_valor_reintegro       NUMBER(16, 2);
  mi_valor_ajuste_rp       NUMBER(16, 2);

begin

  mi_valor_registro        := NULL; -- Valor Total Registros  Acumulado
  mi_valor_rp_anulados     := NULL; -- Valor Total RP Anulados Acumulado 
  mi_valor_rp_parciales    := NULL; -- Valor Liberaciones Parciales de RP Acumulados
  mi_valor_comp_acumulados := NULL; -- Compromisos Acumulados
  mi_valor_ajustes         := NULL;
  mi_valor_reintegro       := NULL;

  -- Calcula el Valor Total de Registros Acumulados

  BEGIN
    SELECT NVL(SUM(NVL(pr_registro_disponibilidad.valor, 0)), 0)
      INTO mi_valor_registro
      FROM pr_registro_disponibilidad, pr_registro_presupuestal
     WHERE pr_registro_disponibilidad.vigencia =
           pr_registro_presupuestal.vigencia
       AND pr_registro_disponibilidad.codigo_compania =
           pr_registro_presupuestal.codigo_compania
       AND pr_registro_disponibilidad.codigo_unidad_ejecutora =
           pr_registro_presupuestal.codigo_unidad_ejecutora
       AND pr_registro_disponibilidad.numero_disponibilidad =
           pr_registro_presupuestal.numero_disponibilidad
       AND pr_registro_disponibilidad.numero_registro =
           pr_registro_presupuestal.numero_registro
       AND pr_registro_disponibilidad.vigencia = :vigencia
       AND pr_registro_disponibilidad.codigo_compania = :codigo_compania
       AND pr_registro_disponibilidad.codigo_unidad_ejecutora =
           :codigo_unidad_ejecutora
       AND pr_registro_disponibilidad.rubro_interno = :rubro_interno
       AND TO_NUMBER(TO_CHAR(pr_registro_presupuestal.fecha_registro, 'MM')) <=
           TO_NUMBER(:P_MES);
  EXCEPTION
    WHEN OTHERS THEN
      mi_valor_registro := 0;
  END;

  -- Anulaciones de RP Acumuladas
  BEGIN
    SELECT NVL(SUM(NVL(pr_registro_disponibilidad.valor, 0)), 0)
      INTO mi_valor_rp_anulados
      FROM pr_registro_disponibilidad, pr_registro_presupuestal
     WHERE pr_registro_disponibilidad.vigencia =
           pr_registro_presupuestal.vigencia
       AND pr_registro_disponibilidad.codigo_compania =
           pr_registro_presupuestal.codigo_compania
       AND pr_registro_disponibilidad.codigo_unidad_ejecutora =
           pr_registro_presupuestal.codigo_unidad_ejecutora
       AND pr_registro_disponibilidad.numero_disponibilidad =
           pr_registro_presupuestal.numero_disponibilidad
       AND pr_registro_disponibilidad.numero_registro =
           pr_registro_presupuestal.numero_registro
       AND pr_registro_disponibilidad.vigencia = :vigencia
       AND pr_registro_disponibilidad.codigo_compania = :codigo_compania
       AND pr_registro_disponibilidad.codigo_unidad_ejecutora =
           :codigo_unidad_ejecutora
       AND pr_registro_disponibilidad.rubro_interno = :rubro_interno
       AND TO_NUMBER(TO_CHAR(pr_registro_presupuestal.fecha_registro, 'MM')) <=
           TO_NUMBER(:P_MES)
       AND EXISTS (SELECT numero_documento_anulado
              FROM pr_anulaciones
             WHERE vigencia = pr_registro_presupuestal.vigencia
               AND codigo_compania =
                   pr_registro_presupuestal.codigo_compania
               AND codigo_unidad_ejecutora =
                   pr_registro_presupuestal.codigo_unidad_ejecutora
               AND documento_anulado = 'REGISTRO'
               and numero_documento_anulado =
                   pr_registro_presupuestal.numero_registro
               AND TO_NUMBER(TO_CHAR(fecha_registro, 'MM')) <=
                   TO_NUMBER(:P_MES));
  EXCEPTION
    WHEN OTHERS THEN
      mi_valor_rp_anulados := 0;
  END;

  -- Liberaciones Parciales Acumuladas
  BEGIN
    SELECT NVL(SUM(NVL(pr_rp_anulados.valor_anulado, 0)), 0)
      INTO mi_valor_rp_parciales
      FROM pr_rp_anulados
     WHERE vigencia = :vigencia
       AND codigo_compania = :codigo_compania
       AND codigo_unidad_ejecutora = :codigo_unidad_ejecutora
       AND rubro_interno = :rubro_interno
       AND TO_NUMBER(TO_CHAR(fecha_anulacion, 'MM')) <= TO_NUMBER(:P_MES)
       AND EXISTS
     (SELECT numero_registro
              FROM pr_registro_presupuestal
             WHERE vigencia = pr_rp_anulados.vigencia
               AND codigo_compania = pr_rp_anulados.codigo_compania
               AND codigo_unidad_ejecutora =
                   pr_rp_anulados.codigo_unidad_ejecutora
               AND numero_registro = pr_rp_anulados.numero_registro
               AND TO_NUMBER(TO_CHAR(fecha_registro, 'MM')) <=
                   TO_NUMBER(:P_MES));
  EXCEPTION
    WHEN OTHERS THEN
      mi_valor_rp_parciales := 0;
  END;

  -- Ajustes
  BEGIN
    SELECT NVL(SUM(NVL(pr_reintegro_ajustes_rubro.valor, 0)), 0)
      INTO mi_valor_ajustes
      FROM pr_reintegro_ajustes_rubro, pr_reintegro_ajustes
     WHERE pr_reintegro_ajustes_rubro.vigencia =
           pr_reintegro_ajustes.vigencia
       AND pr_reintegro_ajustes_rubro.codigo_compania =
           pr_reintegro_ajustes.codigo_compania
       AND pr_reintegro_ajustes_rubro.codigo_unidad_ejecutora =
           pr_reintegro_ajustes.codigo_unidad_ejecutora
       AND pr_reintegro_ajustes_rubro.numero_disponibilidad =
           pr_reintegro_ajustes.numero_disponibilidad
       AND pr_reintegro_ajustes_rubro.numero_registro =
           pr_reintegro_ajustes.numero_registro
       AND pr_reintegro_ajustes_rubro.numero_orden =
           pr_reintegro_ajustes.numero_orden
       AND pr_reintegro_ajustes_rubro.consecutivo_ajuste =
           pr_reintegro_ajustes.consecutivo_ajuste
       AND pr_reintegro_ajustes_rubro.consecutivo_orden =
           pr_reintegro_ajustes.consecutivo_orden
       AND pr_reintegro_ajustes_rubro.vigencia = :vigencia
       AND pr_reintegro_ajustes_rubro.codigo_compania = :codigo_compania
       AND pr_reintegro_ajustes_rubro.codigo_unidad_ejecutora =
           :codigo_unidad_ejecutora
       AND pr_reintegro_ajustes_rubro.rubro_interno = :rubro_interno
       AND TO_NUMBER(to_char(pr_reintegro_ajustes.fecha_registro, 'mm')) <=
           TO_NUMBER(:p_mes)
       AND pr_reintegro_ajustes.tipo_movimiento = 'AJUSTE';
  EXCEPTION
    WHEN OTHERS THEN
      mi_valor_ajustes := 0;
  END;
  -- Reintegro

  BEGIN
    SELECT NVL(SUM(NVL(pr_reintegro_ajustes_rubro.valor, 0)), 0)
      INTO mi_valor_reintegro
      FROM pr_reintegro_ajustes_rubro, pr_reintegro_ajustes
     WHERE pr_reintegro_ajustes_rubro.vigencia =
           pr_reintegro_ajustes.vigencia
       AND pr_reintegro_ajustes_rubro.codigo_compania =
           pr_reintegro_ajustes.codigo_compania
       AND pr_reintegro_ajustes_rubro.codigo_unidad_ejecutora =
           pr_reintegro_ajustes.codigo_unidad_ejecutora
       AND pr_reintegro_ajustes_rubro.numero_disponibilidad =
           pr_reintegro_ajustes.numero_disponibilidad
       AND pr_reintegro_ajustes_rubro.numero_registro =
           pr_reintegro_ajustes.numero_registro
       AND pr_reintegro_ajustes_rubro.numero_orden =
           pr_reintegro_ajustes.numero_orden
       AND pr_reintegro_ajustes_rubro.consecutivo_ajuste =
           pr_reintegro_ajustes.consecutivo_ajuste
       AND pr_reintegro_ajustes_rubro.consecutivo_orden =
           pr_reintegro_ajustes.consecutivo_orden
       AND pr_reintegro_ajustes_rubro.vigencia = :vigencia
       AND pr_reintegro_ajustes_rubro.codigo_compania = :codigo_compania
       AND pr_reintegro_ajustes_rubro.codigo_unidad_ejecutora =
           :codigo_unidad_ejecutora
       AND pr_reintegro_ajustes_rubro.rubro_interno = :rubro_interno
       AND TO_NUMBER(to_char(pr_reintegro_ajustes.fecha_registro, 'mm')) <=
           TO_NUMBER(:p_mes)
       AND pr_reintegro_ajustes.tipo_movimiento = 'REINTEGRO';
  EXCEPTION
    WHEN OTHERS THEN
      mi_valor_reintegro := 0;
  END;

  --Se incluye manejo ajuste compromisos, no influye giros 30/12/2002
  BEGIN
    SELECT NVL(SUM(NVL(pr_reintegro_ajustes_rubro.valor, 0)), 0)
      INTO mi_valor_ajuste_rp
      FROM pr_reintegro_ajustes_rubro, pr_reintegro_ajustes
     WHERE pr_reintegro_ajustes_rubro.vigencia =
           pr_reintegro_ajustes.vigencia
       AND pr_reintegro_ajustes_rubro.codigo_compania =
           pr_reintegro_ajustes.codigo_compania
       AND pr_reintegro_ajustes_rubro.codigo_unidad_ejecutora =
           pr_reintegro_ajustes.codigo_unidad_ejecutora
       AND pr_reintegro_ajustes_rubro.numero_disponibilidad =
           pr_reintegro_ajustes.numero_disponibilidad
       AND pr_reintegro_ajustes_rubro.numero_registro =
           pr_reintegro_ajustes.numero_registro
       AND pr_reintegro_ajustes_rubro.numero_orden =
           pr_reintegro_ajustes.numero_orden
       AND pr_reintegro_ajustes_rubro.consecutivo_ajuste =
           pr_reintegro_ajustes.consecutivo_ajuste
       AND pr_reintegro_ajustes_rubro.consecutivo_orden =
           pr_reintegro_ajustes.consecutivo_orden
       AND pr_reintegro_ajustes_rubro.vigencia = :vigencia
       AND pr_reintegro_ajustes_rubro.codigo_compania = :codigo_compania
       AND pr_reintegro_ajustes_rubro.codigo_unidad_ejecutora =
           :codigo_unidad_ejecutora
       AND pr_reintegro_ajustes_rubro.rubro_interno = :rubro_interno
       AND TO_NUMBER(to_char(pr_reintegro_ajustes.fecha_registro, 'mm')) <=
           TO_NUMBER(:p_mes)
       AND pr_reintegro_ajustes.tipo_movimiento = 'RP_AJUSTE'
       AND pr_reintegro_ajustes.cerrado = 9;
  EXCEPTION
    WHEN OTHERS THEN
      mi_valor_ajuste_rp := 0;
  END;
  -- inicio RQ 2023000806 famanjarres
  mi_valor_reintegro := 0;
  -- fin RQ 2023000806
  mi_valor_comp_acumulados := NVL(mi_valor_registro, 0) -
                              NVL(mi_valor_rp_anulados, 0) -
                              NVL(mi_valor_rp_parciales, 0) +
                              NVL(mi_valor_ajustes, 0) +
                              NVL(mi_valor_reintegro, 0) +
                              NVL(mi_valor_ajuste_rp, 0);

  RETURN NVL(mi_valor_comp_acumulados, 0);

EXCEPTION
  WHEN OTHERS THEN
    RETURN 0;
end CF_CompromisosAcumuladoFormula;

