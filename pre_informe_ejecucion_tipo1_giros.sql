function CF_GirosMesFormula return Number is
  mi_valor_op         NUMBER(16, 2);
  mi_valor_op_anulado NUMBER(16, 2);
  mi_valor_op_mes     NUMBER(16, 2);
  mi_valor_ajustes    NUMBER(16, 2);
  mi_valor_reintegro  NUMBER(16, 2);

  mi_valor_op_ogt         NUMBER(16, 2);
  mi_valor_op_anulado_ogt NUMBER(16, 2);
  mi_valor_op_mes_ogt     NUMBER(16, 2);
  mi_valor_ajustes_ogt    NUMBER(16, 2);
  mi_valor_reintegro_ogt  NUMBER(16, 2);
  mi_valor_total          NUMBER(16, 2);
  mi_rubro_interno_sb       NUMBER; --GLP 256
begin

  mi_valor_op         := NULL;
  mi_valor_op_anulado := NULL;
  mi_valor_op_mes     := NULL;
  mi_valor_ajustes    := NULL;
  mi_valor_reintegro  := NULL;

  mi_valor_op_ogt         := NULL;
  mi_valor_op_anulado_ogt := NULL;
  mi_valor_op_mes_ogt     := NULL;
  mi_valor_ajustes_ogt    := NULL;
  mi_valor_reintegro_ogt  := NULL;

  mi_valor_total := NULL;
  -- Valor Total de OP registradas en el mes

  BEGIN

    SELECT rubro_interno, NVL(SUM(NVL(pr_v_orden_pago_regis_predis.valor, 0)), 0) total
      --INTO mi_valor_op
      --select *
      FROM PR_comun.PR_ORDEN_DE_PAGO_REGISTRO pr_v_orden_pago_regis_predis, 
           PR_comun.PR_ORDEN_DE_PAGO pr_v_orden_de_pago_predis
     WHERE pr_v_orden_pago_regis_predis.vigencia =
           pr_v_orden_de_pago_predis.vigencia
       AND pr_v_orden_pago_regis_predis.codigo_compania =
           pr_v_orden_de_pago_predis.codigo_compania
       AND pr_v_orden_pago_regis_predis.codigo_unidad_ejecutora =
           pr_v_orden_de_pago_predis.codigo_unidad_ejecutora
       AND pr_v_orden_pago_regis_predis.numero_registro =
           pr_v_orden_de_pago_predis.numero_registro
       AND pr_v_orden_pago_regis_predis.numero_disponibilidad =
           pr_v_orden_de_pago_predis.numero_disponibilidad
       AND pr_v_orden_pago_regis_predis.numero_orden =
           pr_v_orden_de_pago_predis.numero_orden
       AND pr_v_orden_pago_regis_predis.consecutivo_orden =
           pr_v_orden_de_pago_predis.consecutivo_orden
       AND pr_v_orden_pago_regis_predis.vigencia = :vigencia
       AND pr_v_orden_pago_regis_predis.codigo_compania = :codigo_compania
       AND pr_v_orden_pago_regis_predis.codigo_unidad_ejecutora =
           :codigo_unidad_ejecutora
       AND pr_v_orden_pago_regis_predis.rubro_interno between 1831 and 1834 --:rubro_interno
       AND TO_CHAR(pr_v_orden_de_pago_predis.fecha_registro, 'YYYY') =
           :vigencia
       AND TO_NUMBER(TO_CHAR(pr_v_orden_de_pago_predis.fecha_registro, 'MM')) =
           TO_NUMBER(:P_MES)
       AND pr_v_orden_de_pago_predis.ESTADO <> 'ANULADO'
       group by pr_v_orden_pago_regis_predis.rubro_interno  ;
  EXCEPTION
    WHEN OTHERS THEN
      mi_valor_op := 0;
  END;




    --GLP 256 FTV Alineacion CUD, 2. se suma los a los aportes se salud, pensión y solidaridad pago por emepleado de la nómina del mes anterior.
   
    
    begin
        select interno_rubro
          into mi_rubro_interno_sb
        from pr_v_rubros
        where descripcion = 'Sueldo básico'
        and vigencia = :vigencia;

        -- --5 es APORTE SALUD, 1285 es APORTE REGIMEN SOLIDARIDAD, 1267 es APORTE PENSION
        select *
        from ogt_centro_costos
        where entidad=206
        and unidad_ejecutora = '01'
        and vigencia = 2026
        and extract(month from fecha_desde) =5
        --and consecutivo=10
        and codigo_centro_costos IN (5, 1285, 1267);
        and exists (select 1 from ogt_relacion_autorizacion b
                    where b.consecutivo = ogt_centro_costos.consecutivo
                      and b.entidad_ra = ogt_centro_costos.entidad
                      and b.tipo_documento = ogt_centro_costos.tipo_documento
                      and b.unidad_ejecutora = ogt_centro_costos.unidad_ejecutora
                      and b.vigencia = ogt_centro_costos.vigencia
                      and b.tipo_ra = ogt_centro_costos.tipo_ra
                      and b.ind_aprobado = mi_valor_uno
                      and substr(b.estado, 4, 1) = mi_estado_uno
                      )
        and ogt_relacion_autorizacion.mes = ogt_centro_costos.mes
        and ogt_relacion_autorizacion.fecha_desde = ogt_centro_costos.fecha_desde

        
    exception
        valor_aportes_empleado_mes := 0;
    end;
  -- Valor Total de OP registradas en el mes por el sistema OPGET

  mi_valor_op_ogt := OGT_PK_PREDIS.ogt_fn_valor_mes(:vigencia,
                                                    :codigo_compania,
                                                    :codigo_unidad_ejecutora,
                                                    TO_NUMBER(:p_mes),
                                                    :rubro_interno);

  -- Valor de Ordenes del mes anuladas en el mismos mes

  BEGIN
    SELECT NVL(SUM(NVL(pr_v_orden_pago_regis_predis.valor, 0)), 0)
      INTO mi_valor_op_anulado
      FROM pr_v_orden_pago_regis_predis, pr_v_orden_de_pago_predis
     WHERE pr_v_orden_pago_regis_predis.vigencia =
           pr_v_orden_de_pago_predis.vigencia
       AND pr_v_orden_pago_regis_predis.codigo_compania =
           pr_v_orden_de_pago_predis.codigo_compania
       AND pr_v_orden_pago_regis_predis.codigo_unidad_ejecutora =
           pr_v_orden_de_pago_predis.codigo_unidad_ejecutora
       AND pr_v_orden_pago_regis_predis.numero_registro =
           pr_v_orden_de_pago_predis.numero_registro
       AND pr_v_orden_pago_regis_predis.numero_disponibilidad =
           pr_v_orden_de_pago_predis.numero_disponibilidad
       AND pr_v_orden_pago_regis_predis.numero_orden =
           pr_v_orden_de_pago_predis.numero_orden
       AND pr_v_orden_pago_regis_predis.consecutivo_orden =
           pr_v_orden_de_pago_predis.consecutivo_orden
       AND pr_v_orden_pago_regis_predis.vigencia = :vigencia
       AND pr_v_orden_pago_regis_predis.codigo_compania = :codigo_compania
       AND pr_v_orden_pago_regis_predis.codigo_unidad_ejecutora =
           :codigo_unidad_ejecutora
       AND pr_v_orden_pago_regis_predis.rubro_interno = :rubro_interno
       AND TO_CHAR(pr_v_orden_de_pago_predis.fecha_registro, 'YYYY') =
           :vigencia
       AND EXISTS
     (SELECT distinct vigencia
              FROM pr_v_anulaciones_predis
             WHERE vigencia = pr_v_orden_pago_regis_predis.vigencia
               AND codigo_compania =
                   pr_v_orden_pago_regis_predis.codigo_compania
               AND codigo_unidad_ejecutora =
                   pr_v_orden_pago_regis_predis.codigo_unidad_ejecutora
               AND documento_anulado = 'ORDEN'
               and numero_documento_anulado =
                   pr_v_orden_pago_regis_predis.numero_orden
               AND numero_registro =
                   pr_v_orden_pago_regis_predis.numero_registro
               AND consecutivo_orden =
                   pr_v_orden_pago_regis_predis.consecutivo_orden
               AND TO_NUMBER(TO_CHAR(fecha_registro, 'MM')) =
                   TO_NUMBER(:P_MES));
  EXCEPTION
    WHEN OTHERS THEN
      mi_valor_op_anulado := 0;
  END;

  -- Valor de Ordenes del mes anuladas por OPGET en el mismos mes
  mi_valor_op_anulado_ogt := OGT_PK_PREDIS.ogt_fn_anul_mes(:vigencia,
                                                           :codigo_compania,
                                                           :codigo_unidad_ejecutora,
                                                           TO_NUMBER(:p_mes),
                                                           :rubro_interno);

  -- Ajustes

  BEGIN
    SELECT NVL(SUM(NVL(pr_v_reint_ajust_rubro_predis.valor, 0)), 0)
      INTO mi_valor_ajustes
      FROM PR_V_REINT_AJUST_RUBRO_PREDIS, pr_v_reintegro_ajustes_predis
     WHERE pr_v_reint_ajust_rubro_predis.vigencia =
           pr_v_reintegro_ajustes_predis.vigencia
       AND pr_v_reint_ajust_rubro_predis.codigo_compania =
           pr_v_reintegro_ajustes_predis.codigo_compania
       AND pr_v_reint_ajust_rubro_predis.codigo_unidad_ejecutora =
           pr_v_reintegro_ajustes_predis.codigo_unidad_ejecutora
       AND pr_v_reint_ajust_rubro_predis.numero_disponibilidad =
           pr_v_reintegro_ajustes_predis.numero_disponibilidad
       AND pr_v_reint_ajust_rubro_predis.numero_registro =
           pr_v_reintegro_ajustes_predis.numero_registro
       AND pr_v_reint_ajust_rubro_predis.numero_orden =
           pr_v_reintegro_ajustes_predis.numero_orden
       AND pr_v_reint_ajust_rubro_predis.consecutivo_orden =
           pr_v_reintegro_ajustes_predis.consecutivo_orden
       AND pr_v_reint_ajust_rubro_predis.consecutivo_ajuste =
           pr_v_reintegro_ajustes_predis.consecutivo_ajuste
       AND pr_v_reint_ajust_rubro_predis.vigencia = :vigencia
       AND pr_v_reint_ajust_rubro_predis.codigo_compania = :codigo_compania
       AND pr_v_reint_ajust_rubro_predis.codigo_unidad_ejecutora =
           :codigo_unidad_ejecutora
       AND pr_v_reint_ajust_rubro_predis.rubro_interno = :rubro_interno
       AND TO_NUMBER(to_char(pr_v_reintegro_ajustes_predis.fecha_registro,
                             'mm')) = TO_NUMBER(:p_mes)
       AND pr_v_reintegro_ajustes_predis.tipo_movimiento = 'AJUSTE';
  EXCEPTION
    WHEN OTHERS THEN
      mi_valor_ajustes := 0;
  END;

  -- Ajustes de OPGET
  mi_valor_ajustes_ogt := OGT_PK_PREDIS.ogt_fn_ajuste_mes(:vigencia,
                                                          :codigo_compania,
                                                          :codigo_unidad_ejecutora,
                                                          TO_NUMBER(:p_mes),
                                                          :rubro_interno);
  -- Reintegro

  BEGIN
    SELECT NVL(SUM(NVL(pr_v_reint_ajust_rubro_predis.valor, 0)), 0)
      INTO mi_valor_reintegro
      FROM pr_v_reint_ajust_rubro_predis, pr_v_reintegro_ajustes_predis
     WHERE pr_v_reint_ajust_rubro_predis.vigencia =
           pr_v_reintegro_ajustes_predis.vigencia
       AND pr_v_reint_ajust_rubro_predis.codigo_compania =
           pr_v_reintegro_ajustes_predis.codigo_compania
       AND pr_v_reint_ajust_rubro_predis.codigo_unidad_ejecutora =
           pr_v_reintegro_ajustes_predis.codigo_unidad_ejecutora
       AND pr_v_reint_ajust_rubro_predis.numero_disponibilidad =
           pr_v_reintegro_ajustes_predis.numero_disponibilidad
       AND pr_v_reint_ajust_rubro_predis.numero_registro =
           pr_v_reintegro_ajustes_predis.numero_registro
       AND pr_v_reint_ajust_rubro_predis.numero_orden =
           pr_v_reintegro_ajustes_predis.numero_orden
       AND pr_v_reint_ajust_rubro_predis.consecutivo_orden =
           pr_v_reintegro_ajustes_predis.consecutivo_orden
       AND pr_v_reint_ajust_rubro_predis.consecutivo_ajuste =
           pr_v_reintegro_ajustes_predis.consecutivo_ajuste
       AND pr_v_reint_ajust_rubro_predis.vigencia = :vigencia
       AND pr_v_reint_ajust_rubro_predis.codigo_compania = :codigo_compania
       AND pr_v_reint_ajust_rubro_predis.codigo_unidad_ejecutora =
           :codigo_unidad_ejecutora
       AND pr_v_reint_ajust_rubro_predis.rubro_interno = :rubro_interno
       AND TO_NUMBER(to_char(pr_v_reintegro_ajustes_predis.fecha_registro,
                             'mm')) = TO_NUMBER(:p_mes)
       AND pr_v_reintegro_ajustes_predis.tipo_movimiento = 'REINTEGRO';
  EXCEPTION
    WHEN OTHERS THEN
      mi_valor_reintegro := 0;
  END;

  -- Reintegro de OPGET
  mi_valor_reintegro_ogt := OGT_PK_PREDIS.ogt_fn_reint_mes(:vigencia,
                                                           :codigo_compania,
                                                           :codigo_unidad_ejecutora,
                                                           TO_NUMBER(:p_mes),
                                                           :rubro_interno);

  -- Valor de Giros del Mes
  mi_valor_op_mes := NVL(mi_valor_op, 0) - NVL(mi_valor_op_anulado, 0) +
                     NVL(mi_valor_ajustes, 0) + NVL(mi_valor_reintegro, 0);

  mi_valor_op_mes_ogt := NVL(mi_valor_op_ogt, 0) -
                         NVL(mi_valor_op_anulado_ogt, 0) -
                         NVL(mi_valor_ajustes_ogt, 0) -
                         NVL(mi_valor_reintegro_ogt, 0);

  mi_valor_total := mi_valor_op_mes + mi_valor_op_mes_ogt;

  RETURN NVL(mi_valor_total, 0);

EXCEPTION
  WHEN OTHERS THEN
    RETURN 0;
end CF_GirosMesFormula;

function CF_GirosAcumuladosFormula return Number is
  mi_valor_op           NUMBER(16, 2);
  mi_valor_op_anulado   NUMBER(16, 2);
  mi_valor_op_acumulado NUMBER(16, 2);
  mi_valor_ajustes      NUMBER(16, 2);
  mi_valor_reintegro    NUMBER(16, 2);

  mi_valor_op_ogt           NUMBER(16, 2);
  mi_valor_op_anulado_ogt   NUMBER(16, 2);
  mi_valor_op_acumulado_ogt NUMBER(16, 2);
  mi_valor_ajustes_ogt      NUMBER(16, 2);
  mi_valor_reintegro_ogt    NUMBER(16, 2);
  mi_valor_total            NUMBER(16, 2);
begin

  mi_valor_op           := NULL;
  mi_valor_op_anulado   := NULL;
  mi_valor_op_acumulado := NULL;
  mi_valor_ajustes      := NULL;
  mi_valor_reintegro    := NULL;

  mi_valor_op_ogt           := NULL;
  mi_valor_op_anulado_ogt   := NULL;
  mi_valor_op_acumulado_ogt := NULL;
  mi_valor_ajustes_ogt      := NULL;
  mi_valor_reintegro_ogt    := NULL;

  mi_valor_total := NULL;

  -- Valor Total de OP registradas acumulados
  BEGIN
    SELECT NVL(SUM(NVL(pr_v_orden_pago_regis_predis.valor, 0)), 0)
      INTO mi_valor_op
      FROM pr_v_orden_pago_regis_predis, pr_v_orden_de_pago_predis
     WHERE pr_v_orden_pago_regis_predis.vigencia =
           pr_v_orden_de_pago_predis.vigencia
       AND pr_v_orden_pago_regis_predis.codigo_compania =
           pr_v_orden_de_pago_predis.codigo_compania
       AND pr_v_orden_pago_regis_predis.codigo_unidad_ejecutora =
           pr_v_orden_de_pago_predis.codigo_unidad_ejecutora
       AND pr_v_orden_pago_regis_predis.numero_disponibilidad =
           pr_v_orden_de_pago_predis.numero_disponibilidad
       AND pr_v_orden_pago_regis_predis.numero_registro =
           pr_v_orden_de_pago_predis.numero_registro
       AND pr_v_orden_pago_regis_predis.numero_orden =
           pr_v_orden_de_pago_predis.numero_orden
       AND pr_v_orden_pago_regis_predis.consecutivo_orden =
           pr_v_orden_de_pago_predis.consecutivo_orden
       AND pr_v_orden_pago_regis_predis.vigencia = :vigencia
       AND pr_v_orden_pago_regis_predis.codigo_compania = :codigo_compania
       AND pr_v_orden_pago_regis_predis.codigo_unidad_ejecutora =
           :codigo_unidad_ejecutora
       AND pr_v_orden_pago_regis_predis.rubro_interno = :rubro_interno
       AND TO_CHAR(pr_v_orden_de_pago_predis.fecha_registro, 'YYYY') =
           :vigencia
       AND TO_NUMBER(TO_CHAR(pr_v_orden_de_pago_predis.fecha_registro, 'MM')) <=
           TO_NUMBER(:P_MES)
       AND pr_v_orden_de_pago_predis.ESTADO <> 'ANULADO';
  EXCEPTION
    WHEN OTHERS THEN
      mi_valor_op := 0;
  END;

  -- Valor Total de OP registradas en OPGET acumulados
  mi_valor_op_ogt := OGT_PK_PREDIS.ogt_fn_valor_acum(:vigencia,
                                                     :codigo_compania,
                                                     :codigo_unidad_ejecutora,
                                                     TO_NUMBER(:p_mes),
                                                     :rubro_interno);

  -- Valor de Ordenes del mes anuladas acumuladas
  BEGIN
    SELECT NVL(SUM(NVL(pr_v_orden_pago_regis_predis.valor, 0)), 0)
      INTO mi_valor_op_anulado
      FROM pr_v_orden_pago_regis_predis, pr_v_orden_de_pago_predis
     WHERE pr_v_orden_pago_regis_predis.vigencia =
           pr_v_orden_de_pago_predis.vigencia
       AND pr_v_orden_pago_regis_predis.codigo_compania =
           pr_v_orden_de_pago_predis.codigo_compania
       AND pr_v_orden_pago_regis_predis.codigo_unidad_ejecutora =
           pr_v_orden_de_pago_predis.codigo_unidad_ejecutora
       AND pr_v_orden_pago_regis_predis.numero_disponibilidad =
           pr_v_orden_de_pago_predis.numero_disponibilidad
       AND pr_v_orden_pago_regis_predis.numero_registro =
           pr_v_orden_de_pago_predis.numero_registro
       AND pr_v_orden_pago_regis_predis.numero_orden =
           pr_v_orden_de_pago_predis.numero_orden
       AND pr_v_orden_pago_regis_predis.consecutivo_orden =
           pr_v_orden_de_pago_predis.consecutivo_orden
       AND pr_v_orden_pago_regis_predis.vigencia = :vigencia
       AND pr_v_orden_pago_regis_predis.codigo_compania = :codigo_compania
       AND pr_v_orden_pago_regis_predis.codigo_unidad_ejecutora =
           :codigo_unidad_ejecutora
       AND pr_v_orden_pago_regis_predis.rubro_interno = :rubro_interno
       AND TO_CHAR(pr_v_orden_de_pago_predis.fecha_registro, 'YYYY') =
           :vigencia
       AND TO_NUMBER(TO_CHAR(pr_v_orden_de_pago_predis.fecha_registro, 'MM')) <=
           TO_NUMBER(:P_MES)
       AND EXISTS
     (SELECT numero_documento_anulado,
                   numero_registro,
                   consecutivo_orden
              FROM pr_v_anulaciones_predis
             WHERE vigencia = pr_v_orden_pago_regis_predis.vigencia
               AND codigo_compania =
                   pr_v_orden_pago_regis_predis.codigo_compania
               AND codigo_unidad_ejecutora =
                   pr_v_orden_pago_regis_predis.codigo_unidad_ejecutora
               AND documento_anulado = 'ORDEN'
               and numero_documento_anulado =
                   pr_v_orden_pago_regis_predis.numero_orden
               AND numero_registro =
                   pr_v_orden_pago_regis_predis.numero_registro
               AND consecutivo_orden =
                   pr_v_orden_pago_regis_predis.consecutivo_orden
               AND TO_NUMBER(TO_CHAR(fecha_registro, 'MM')) <=
                   TO_NUMBER(:P_MES));
  EXCEPTION
    WHEN OTHERS THEN
      mi_valor_op_anulado := 0;
  END;

  -- Valor de Ordenes del mes anuladas por OPGET en el mismos mes
  mi_valor_op_anulado_ogt := OGT_PK_PREDIS.ogt_fn_anul_acum(:vigencia,
                                                            :codigo_compania,
                                                            :codigo_unidad_ejecutora,
                                                            TO_NUMBER(:p_mes),
                                                            :rubro_interno);

  -- Ajustes
  BEGIN
    SELECT NVL(SUM(NVL(pr_v_reint_ajust_rubro_predis.valor, 0)), 0)
      INTO mi_valor_ajustes
      FROM pr_v_reint_ajust_rubro_predis, pr_v_reintegro_ajustes_predis
     WHERE pr_v_reint_ajust_rubro_predis.vigencia =
           pr_v_reintegro_ajustes_predis.vigencia
       AND pr_v_reint_ajust_rubro_predis.codigo_compania =
           pr_v_reintegro_ajustes_predis.codigo_compania
       AND pr_v_reint_ajust_rubro_predis.codigo_unidad_ejecutora =
           pr_v_reintegro_ajustes_predis.codigo_unidad_ejecutora
       AND pr_v_reint_ajust_rubro_predis.numero_disponibilidad =
           pr_v_reintegro_ajustes_predis.numero_disponibilidad
       AND pr_v_reint_ajust_rubro_predis.numero_registro =
           pr_v_reintegro_ajustes_predis.numero_registro
       AND pr_v_reint_ajust_rubro_predis.numero_orden =
           pr_v_reintegro_ajustes_predis.numero_orden
       AND pr_v_reint_ajust_rubro_predis.consecutivo_orden =
           pr_v_reintegro_ajustes_predis.consecutivo_orden
       AND pr_v_reint_ajust_rubro_predis.consecutivo_ajuste =
           pr_v_reintegro_ajustes_predis.consecutivo_ajuste
       AND pr_v_reint_ajust_rubro_predis.vigencia = :vigencia
       AND pr_v_reint_ajust_rubro_predis.codigo_compania = :codigo_compania
       AND pr_v_reint_ajust_rubro_predis.codigo_unidad_ejecutora =
           :codigo_unidad_ejecutora
       AND pr_v_reint_ajust_rubro_predis.rubro_interno = :rubro_interno
       AND TO_NUMBER(to_char(pr_v_reintegro_ajustes_predis.fecha_registro,
                             'mm')) <= TO_NUMBER(:p_mes)
       AND pr_v_reintegro_ajustes_predis.tipo_movimiento = 'AJUSTE';
  EXCEPTION
    WHEN OTHERS THEN
      mi_valor_ajustes := 0;
  END;

  -- Ajustes de OPGET
  mi_valor_ajustes_ogt := OGT_PK_PREDIS.ogt_fn_acum_ajuste(:vigencia,
                                                           :codigo_compania,
                                                           :codigo_unidad_ejecutora,
                                                           TO_NUMBER(:p_mes),
                                                           :rubro_interno);

  -- Reintegro
  BEGIN
    SELECT NVL(SUM(NVL(pr_v_reint_ajust_rubro_predis.valor, 0)), 0)
      INTO mi_valor_reintegro
      FROM pr_v_reint_ajust_rubro_predis, pr_v_reintegro_ajustes_predis
     WHERE pr_v_reint_ajust_rubro_predis.vigencia =
           pr_v_reintegro_ajustes_predis.vigencia
       AND pr_v_reint_ajust_rubro_predis.codigo_compania =
           pr_v_reintegro_ajustes_predis.codigo_compania
       AND pr_v_reint_ajust_rubro_predis.codigo_unidad_ejecutora =
           pr_v_reintegro_ajustes_predis.codigo_unidad_ejecutora
       AND pr_v_reint_ajust_rubro_predis.numero_disponibilidad =
           pr_v_reintegro_ajustes_predis.numero_disponibilidad
       AND pr_v_reint_ajust_rubro_predis.numero_registro =
           pr_v_reintegro_ajustes_predis.numero_registro
       AND pr_v_reint_ajust_rubro_predis.numero_orden =
           pr_v_reintegro_ajustes_predis.numero_orden
       AND pr_v_reint_ajust_rubro_predis.consecutivo_orden =
           pr_v_reintegro_ajustes_predis.consecutivo_orden
       AND pr_v_reint_ajust_rubro_predis.consecutivo_ajuste =
           pr_v_reintegro_ajustes_predis.consecutivo_ajuste
       AND pr_v_reint_ajust_rubro_predis.vigencia = :vigencia
       AND pr_v_reint_ajust_rubro_predis.codigo_compania = :codigo_compania
       AND pr_v_reint_ajust_rubro_predis.codigo_unidad_ejecutora =
           :codigo_unidad_ejecutora
       AND pr_v_reint_ajust_rubro_predis.rubro_interno = :rubro_interno
       AND TO_NUMBER(to_char(pr_v_reintegro_ajustes_predis.fecha_registro,
                             'mm')) <= TO_NUMBER(:p_mes)
       AND pr_v_reintegro_ajustes_predis.tipo_movimiento = 'REINTEGRO';
  EXCEPTION
    WHEN OTHERS THEN
      mi_valor_reintegro := 0;
  END;

  -- Reintegro de OPGET
  mi_valor_reintegro_ogt := OGT_PK_PREDIS.ogt_fn_reint_acum(:vigencia,
                                                            :codigo_compania,
                                                            :codigo_unidad_ejecutora,
                                                            TO_NUMBER(:p_mes),
                                                            :rubro_interno);

  -- Valor de Giros Acumulados

  mi_valor_op_acumulado := NVL(mi_valor_op, 0) -
                           NVL(mi_valor_op_anulado, 0) +
                           NVL(mi_valor_ajustes, 0) +
                           NVL(mi_valor_reintegro, 0);

  mi_valor_op_acumulado_ogt := NVL(mi_valor_op_ogt, 0) -
                               NVL(mi_valor_op_anulado_ogt, 0) -
                               NVL(mi_valor_ajustes_ogt, 0) -
                               NVL(mi_valor_reintegro_ogt, 0);

  mi_valor_total := mi_valor_op_acumulado + mi_valor_op_acumulado_ogt;

  RETURN NVL(mi_valor_total, 0);

EXCEPTION
  WHEN OTHERS THEN
    RETURN 0;
end CF_GirosAcumuladosFormula;



	  SELECT b.codigo_presupuesto, c.descripcion, c.codigo_maestro , SUM(a.valor) valor
	  --select a.*
	  FROM   rh_t_lm_valores a, rh_lm_cuenta b, rh_lm_centros_costo c
	  WHERE  b.stipo_funcionario = a.stipofuncionario
	  AND    b.sconcepto         = a.sconcepto
	  AND    b.cc                = c.codigo
      AND   TO_CHAR(periodo,'YYYYMMDD')           = 20260531 --TO_CHAR(:P_FECHA_FIN,'YYYYMMDD')
	  AND    a.ntipo_nomina      = 1
	  --AND    a.nro_ra          = 12
	  AND    b.scompania         = 206
	  AND    b.tipo_ra           = 1 	--:P_TIPO_RA
	  AND    b.grupo_ra          = '5'  -- IN (:P_GRUPO_RA)
	  AND    b.ncierre           = 1
      AND   dfecha_inicio_vig    <= '01-APR-26'  --:P_FECHA_FIN
      AND   (dfecha_final_vig    >= '30-APR-26'  /*:P_FECHA_FIN*/ OR dfecha_final_vig IS NULL) 
	  AND    c.codigo_maestro in ('2-4-24-01-01','2-4-24-02-01','2-4-24-02-01')
	  GROUP BY b.codigo_presupuesto, c.descripcion, c.codigo_maestro 
      ORDER BY c.codigo_maestro