   function cf_girosacumuladosformula return number is
      mi_valor_op           number(
         16,
         2
      );
      mi_valor_op_anulado   number(
         16,
         2
      );
      mi_valor_op_acumulado number(
         16,
         2
      );
      mi_valor_ajustes      number(
         16,
         2
      );
      mi_valor_reintegro    number(
         16,
         2
      );
   begin
      mi_valor_op := null;
      mi_valor_op_anulado := null;
      mi_valor_op_acumulado := null;
      mi_valor_ajustes := null;
      mi_valor_reintegro := null;

  -- Valor Total de OP registradas acumulados

      select nvl(
         sum(nvl(
            pr_orden_de_pago_registro.valor,
            0
         )),
         0
      )
        into mi_valor_op
        from pr_orden_de_pago,
             pr_orden_de_pago_registro
       where ( pr_orden_de_pago_registro.consecutivo_orden = pr_orden_de_pago.consecutivo_orden
         and pr_orden_de_pago_registro.numero_orden = pr_orden_de_pago.numero_orden
         and pr_orden_de_pago_registro.codigo_unidad_ejecutora = pr_orden_de_pago.codigo_unidad_ejecutora
         and pr_orden_de_pago_registro.codigo_compania = pr_orden_de_pago.codigo_compania
         and pr_orden_de_pago_registro.vigencia = pr_orden_de_pago.vigencia )
         and pr_orden_de_pago_registro.codigo_compania = :codigo_compania
         and pr_orden_de_pago_registro.codigo_unidad_ejecutora = :codigo_unidad_ejecutora
         and pr_orden_de_pago_registro.vigencia = :vigencia
         and pr_orden_de_pago_registro.rubro_interno = :rubro_interno
         and to_char(
         pr_orden_de_pago.fecha_registro,
         'YYYY'
      ) = :vigencia
         and to_char(
         pr_orden_de_pago.fecha_registro,
         'MM'
      ) <= :p_mes;

  -- Valor de Ordenes del mes anuladas acumuladas

      select nvl(
         sum(nvl(
            pr_orden_de_pago_registro.valor,
            0
         )),
         0
      )
        into mi_valor_op_anulado
        from pr_orden_de_pago,
             pr_orden_de_pago_registro
       where ( pr_orden_de_pago_registro.consecutivo_orden = pr_orden_de_pago.consecutivo_orden
         and pr_orden_de_pago_registro.numero_orden = pr_orden_de_pago.numero_orden
         and pr_orden_de_pago_registro.codigo_unidad_ejecutora = pr_orden_de_pago.codigo_unidad_ejecutora
         and pr_orden_de_pago_registro.codigo_compania = pr_orden_de_pago.codigo_compania
         and pr_orden_de_pago_registro.vigencia = pr_orden_de_pago.vigencia )
         and pr_orden_de_pago_registro.codigo_compania = :codigo_compania
         and pr_orden_de_pago_registro.codigo_unidad_ejecutora = :codigo_unidad_ejecutora
         and pr_orden_de_pago_registro.vigencia = :vigencia
         and to_char(
         pr_orden_de_pago.fecha_registro,
         'YYYY'
      ) = :vigencia
         and pr_orden_de_pago_registro.rubro_interno = :rubro_interno
         and to_char(
         pr_orden_de_pago.fecha_registro,
         'MM'
      ) <= :p_mes
         and ( pr_orden_de_pago_registro.numero_orden in (
         select numero_documento_anulado
           from pr_anulaciones
          where vigencia = :vigencia
            and codigo_compania = :codigo_compania
            and codigo_unidad_ejecutora = :codigo_unidad_ejecutora
            and documento_anulado = 'ORDEN'
            and to_char(
            fecha_registro,
            'MM'
         ) <= :p_mes
      )
         and pr_orden_de_pago_registro.numero_registro in (
         select numero_registro
           from pr_anulaciones
          where vigencia = :vigencia
            and codigo_compania = :codigo_compania
            and codigo_unidad_ejecutora = :codigo_unidad_ejecutora
            and documento_anulado = 'ORDEN'
            and to_char(
            fecha_registro,
            'MM'
         ) <= :p_mes
      )
         and pr_orden_de_pago_registro.consecutivo_orden in (
         select consecutivo_orden
           from pr_anulaciones
          where vigencia = :vigencia
            and codigo_compania = :codigo_compania
            and codigo_unidad_ejecutora = :codigo_unidad_ejecutora
            and documento_anulado = 'ORDEN'
            and to_char(
            fecha_registro,
            'MM'
         ) <= :p_mes
      ) );

    -- Ajustes

      select nvl(
         sum(nvl(
            pr_reintegro_ajustes_rubro.valor,
            0
         )),
         0
      )
        into mi_valor_ajustes
        from pr_reintegro_ajustes,
             pr_reintegro_ajustes_rubro
       where ( pr_reintegro_ajustes_rubro.consecutivo_ajuste = pr_reintegro_ajustes.consecutivo_ajuste
         and pr_reintegro_ajustes_rubro.numero_registro = pr_reintegro_ajustes.numero_registro
         and pr_reintegro_ajustes_rubro.numero_disponibilidad = pr_reintegro_ajustes.numero_disponibilidad
         and pr_reintegro_ajustes_rubro.consecutivo_orden = pr_reintegro_ajustes.consecutivo_orden
         and pr_reintegro_ajustes_rubro.numero_orden = pr_reintegro_ajustes.numero_orden
         and pr_reintegro_ajustes_rubro.codigo_unidad_ejecutora = pr_reintegro_ajustes.codigo_unidad_ejecutora
         and pr_reintegro_ajustes_rubro.codigo_compania = pr_reintegro_ajustes.codigo_compania
         and pr_reintegro_ajustes_rubro.vigencia = pr_reintegro_ajustes.vigencia )
         and pr_reintegro_ajustes_rubro.codigo_compania = :codigo_compania
         and pr_reintegro_ajustes_rubro.codigo_unidad_ejecutora = :codigo_unidad_ejecutora
         and pr_reintegro_ajustes_rubro.vigencia = :vigencia
         and pr_reintegro_ajustes_rubro.rubro_interno = :rubro_interno
         and to_char(
         pr_reintegro_ajustes.fecha_registro,
         'mm'
      ) <= :p_mes
         and pr_reintegro_ajustes.tipo_movimiento = 'AJUSTE';

    -- Reintegro

      select nvl(
         sum(nvl(
            pr_reintegro_ajustes_rubro.valor,
            0
         )),
         0
      )
        into mi_valor_reintegro
        from pr_reintegro_ajustes,
             pr_reintegro_ajustes_rubro
       where ( pr_reintegro_ajustes_rubro.consecutivo_ajuste = pr_reintegro_ajustes.consecutivo_ajuste
         and pr_reintegro_ajustes_rubro.numero_registro = pr_reintegro_ajustes.numero_registro
         and pr_reintegro_ajustes_rubro.numero_disponibilidad = pr_reintegro_ajustes.numero_disponibilidad
         and pr_reintegro_ajustes_rubro.consecutivo_orden = pr_reintegro_ajustes.consecutivo_orden
         and pr_reintegro_ajustes_rubro.numero_orden = pr_reintegro_ajustes.numero_orden
         and pr_reintegro_ajustes_rubro.codigo_unidad_ejecutora = pr_reintegro_ajustes.codigo_unidad_ejecutora
         and pr_reintegro_ajustes_rubro.codigo_compania = pr_reintegro_ajustes.codigo_compania
         and pr_reintegro_ajustes_rubro.vigencia = pr_reintegro_ajustes.vigencia )
         and pr_reintegro_ajustes_rubro.codigo_compania = :codigo_compania
         and pr_reintegro_ajustes_rubro.codigo_unidad_ejecutora = :codigo_unidad_ejecutora
         and pr_reintegro_ajustes_rubro.vigencia = :vigencia
         and pr_reintegro_ajustes_rubro.rubro_interno = :rubro_interno
         and to_char(
         pr_reintegro_ajustes.fecha_registro,
         'mm'
      ) <= :p_mes
         and pr_reintegro_ajustes.tipo_movimiento = 'REINTEGRO';

    -- Valor de Giros Acumulados

      mi_valor_op_acumulado := nvl(
         mi_valor_op,
         0
      ) - nvl(
         mi_valor_op_anulado,
         0
      ) + nvl(
         mi_valor_ajustes,
         0
      ) + nvl(
         mi_valor_reintegro,
         0
      );

      return nvl(
         mi_valor_op_acumulado,
         0
      );
   end;