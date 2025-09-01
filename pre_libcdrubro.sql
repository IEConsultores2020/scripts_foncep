-- Identifica si CDP fue anulado

 CURSOR cur_cdp_anulado IS
  SELECT nvl(SUM(NVL(valor,0)),0) 
  FROM pr_v_anulaciones_predis
  WHERE vigencia = :vigencia AND
      codigo_compania = :codigo_compania AND
      codigo_unidad_ejecutora = :codigo_unidad_ejecutora AND
      numero_documento_anulado = :numero_disponibilidad AND
      documento_anulado = 'CDP' AND
      fecha_registro <= :P_FECHA_CORTE;
  0

   -- Total de anulaciones parciales del cdp

    CURSOR cur_cdp_anulacion_parcial IS
      SELECT NVL(SUM(NVL(pr_cdp_anulados.valor_anulado,0)),0) 
      FROM   pr_cdp_anulados
      WHERE  vigencia = :vigencia AND
             codigo_compania = :codigo_compania AND
             codigo_unidad_ejecutora = :codigo_unidad_ejecutora AND
             numero_disponibilidad = :numero_disponibilidad AND
             rubro_interno = :rubro_interno AND
             fecha_anulacion <= :P_FECHA_CORTE;
935000
   -- Total de anulaciones parciales del cdp autorizadas

    CURSOR cur_cdp_anulacion_parcial_au IS
      SELECT NVL(sum(NVL(valor_anulado,0)),0) 
      FROM pr_cdp_anulados_autorizados
      WHERE vigencia = :vigencia and 
            codigo_compania = :codigo_compania AND
            codigo_unidad_ejecutora = :codigo_unidad_ejecutora AND
            numero_disponibilidad = :numero_disponibilidad AND
            rubro_interno = :rubro_interno AND
            fecha_anulacion <= :P_FECHA_CORTE;
            0


  mi_total_anulado := NVL(mi_valor_cdp_autorizado,0) + NVL(mi_valor_cdp_parciales,0) + NVL(mi_valor_anulado_rubro,0);
            