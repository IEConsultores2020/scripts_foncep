--inf ejecucion presupuestal
--CF_compromisos_mes

function CF_Compromisos_MesFormula return Number is
 mi_valor_registro        NUMBER(16,2);
 mi_valor_rp_anulados     NUMBER(16,2);
 mi_valor_rp_parciales    NUMBER(16,2);
 mi_valor_compromisos_mes NUMBER(16,2);
 mi_valor_ajustes         NUMBER(16,2);
 mi_valor_reintegro         NUMBER(16,2);
begin

  mi_valor_registro := NULL;        -- Valor Total Registros del Mes
  mi_valor_rp_anulados := NULL;     -- Valor Total RP Anulados del Mes
  mi_valor_rp_parciales:= NULL;     -- Valor Liberaciones Parciales de RP del Mes
  mi_valor_compromisos_mes := NULL; -- Compromisos del Mes
  mi_valor_ajustes := NULL;
  mi_valor_reintegro := NULL;

  -- Calcula el Valor Total de Registros del Mes

  SELECT NVL(SUM(NVL(pr_registro_disponibilidad.valor,0)),0) --INTO mi_valor_registro 0
  FROM  pr_registro_disponibilidad, pr_registro_presupuestal
  WHERE (pr_registro_disponibilidad.numero_disponibilidad=pr_registro_presupuestal.numero_disponibilidad AND
         pr_registro_disponibilidad.numero_registro=pr_registro_presupuestal.numero_registro AND
         pr_registro_disponibilidad.codigo_unidad_ejecutora=pr_registro_presupuestal.codigo_unidad_ejecutora AND
         pr_registro_disponibilidad.codigo_compania=pr_registro_presupuestal.codigo_compania AND
         pr_registro_disponibilidad.vigencia=pr_registro_presupuestal.vigencia) AND
         pr_registro_disponibilidad.codigo_compania = :codigo_compania AND
         pr_registro_disponibilidad.codigo_unidad_ejecutora = :codigo_unidad_ejecutora AND
         pr_registro_disponibilidad.vigencia = :vigencia AND
         pr_registro_disponibilidad.rubro_interno = :rubro_interno AND
         TO_CHAR(pr_registro_presupuestal.fecha_registro,'MM') = :P_MES ;

   -- Anulaciones de RP del mes efectuadas en el mismo mes
/*
  SELECT NVL(SUM(NVL(pr_registro_disponibilidad.valor,0)),0) INTO mi_valor_rp_anulados
  FROM  pr_registro_disponibilidad, pr_registro_presupuestal
  WHERE (pr_registro_disponibilidad.numero_disponibilidad=pr_registro_presupuestal.numero_disponibilidad AND
         pr_registro_disponibilidad.numero_registro=pr_registro_presupuestal.numero_registro AND
         pr_registro_disponibilidad.codigo_unidad_ejecutora=pr_registro_presupuestal.codigo_unidad_ejecutora AND
         pr_registro_disponibilidad.codigo_compania=pr_registro_presupuestal.codigo_compania AND
         pr_registro_disponibilidad.vigencia=pr_registro_presupuestal.vigencia) AND
         pr_registro_disponibilidad.codigo_compania = :codigo_compania AND
         pr_registro_disponibilidad.codigo_unidad_ejecutora = :codigo_unidad_ejecutora AND
         pr_registro_disponibilidad.vigencia = :vigencia AND
         pr_registro_disponibilidad.rubro_interno = :rubro_interno AND
         TO_CHAR(pr_registro_presupuestal.fecha_registro,'MM') = :P_MES AND
         pr_registro_presupuestal.numero_registro IN (SELECT numero_documento_anulado
                                                      FROM pr_anulaciones
                                                      WHERE vigencia = :vigencia AND
                                                            codigo_compania = :codigo_compania AND
                                                            codigo_unidad_ejecutora = :codigo_unidad_ejecutora AND
                                                            documento_anulado = 'REGISTRO' and 
                                                            TO_CHAR(fecha_registro,'MM') = :P_MES);
*/
  SELECT NVL(SUM(NVL(pr_registro_disponibilidad.valor,0)),0) --INTO mi_valor_rp_anulados 0
  FROM  pr_registro_disponibilidad, pr_registro_presupuestal
  WHERE (pr_registro_disponibilidad.numero_disponibilidad=pr_registro_presupuestal.numero_disponibilidad AND
         pr_registro_disponibilidad.numero_registro=pr_registro_presupuestal.numero_registro AND
         pr_registro_disponibilidad.codigo_unidad_ejecutora=pr_registro_presupuestal.codigo_unidad_ejecutora AND
         pr_registro_disponibilidad.codigo_compania=pr_registro_presupuestal.codigo_compania AND
         pr_registro_disponibilidad.vigencia=pr_registro_presupuestal.vigencia) AND
         pr_registro_disponibilidad.codigo_compania = :codigo_compania AND
         pr_registro_disponibilidad.codigo_unidad_ejecutora = :codigo_unidad_ejecutora AND
         pr_registro_disponibilidad.vigencia = :vigencia AND
         pr_registro_disponibilidad.rubro_interno = :rubro_interno AND
           pr_registro_presupuestal.numero_registro IN (SELECT numero_documento_anulado
                                                      FROM pr_anulaciones
                                                      WHERE vigencia = :vigencia AND
                                                            codigo_compania = :codigo_compania AND
                                                            codigo_unidad_ejecutora = :codigo_unidad_ejecutora AND
                                                            documento_anulado = 'REGISTRO' and 
                                                            TO_CHAR(fecha_registro,'MM') = :P_MES);


  -- Liberaciones Parciales del Mes

/*  SELECT NVL(SUM(NVL(pr_rp_anulados.valor_anulado,0)),0) INTO mi_valor_rp_parciales
  FROM   pr_rp_anulados
  WHERE  vigencia = :vigencia AND
         codigo_compania = :codigo_compania AND
         codigo_unidad_ejecutora = :codigo_unidad_ejecutora AND
         rubro_interno = :rubro_interno AND
         TO_CHAR(fecha_anulacion,'MM') = :P_MES AND
         numero_registro IN (SELECT numero_registro 
                             FROM pr_registro_presupuestal
                             WHERE vigencia = :vigencia AND
                                   codigo_compania = :codigo_compania AND
                                   codigo_unidad_ejecutora = :codigo_unidad_ejecutora AND
                                   TO_CHAR(fecha_registro,'MM') = :P_MES);
*/

  SELECT * --NVL(SUM(NVL(pr_rp_anulados.valor_anulado,0)),0) --INTO mi_valor_rp_parciales  3677019
  FROM   pr_rp_anulados
  WHERE  vigencia = :vigencia AND
         codigo_compania = :codigo_compania AND
         codigo_unidad_ejecutora = :codigo_unidad_ejecutora AND
         rubro_interno = :rubro_interno AND
         TO_CHAR(fecha_anulacion,'MM') = :P_MES AND
         numero_registro IN (SELECT numero_registro 
                             FROM pr_registro_presupuestal
                             WHERE vigencia = :vigencia AND
                                   codigo_compania = :codigo_compania AND
                                   codigo_unidad_ejecutora = :codigo_unidad_ejecutora AND
                                   TO_CHAR(fecha_registro,'MM') <= :P_MES);

    -- Ajustes/Reintegros Acumulados

/*    SELECT NVL(SUM(NVL(pr_reintegro_ajustes_rubro.valor,0)),0) INTO mi_valor_ajustes
    FROM pr_reintegro_ajustes, pr_reintegro_ajustes_rubro
    WHERE (pr_reintegro_ajustes_rubro.consecutivo_ajuste=pr_reintegro_ajustes.consecutivo_ajuste AND
           pr_reintegro_ajustes_rubro.numero_registro=pr_reintegro_ajustes.numero_registro AND
           pr_reintegro_ajustes_rubro.numero_disponibilidad=pr_reintegro_ajustes.numero_disponibilidad AND
           pr_reintegro_ajustes_rubro.consecutivo_orden=pr_reintegro_ajustes.consecutivo_orden AND
           pr_reintegro_ajustes_rubro.numero_orden=pr_reintegro_ajustes.numero_orden AND
           pr_reintegro_ajustes_rubro.codigo_unidad_ejecutora=pr_reintegro_ajustes.codigo_unidad_ejecutora AND
           pr_reintegro_ajustes_rubro.codigo_compania=pr_reintegro_ajustes.codigo_compania AND
           pr_reintegro_ajustes_rubro.vigencia=pr_reintegro_ajustes.vigencia) AND
           pr_reintegro_ajustes_rubro.codigo_compania = :codigo_compania AND
           pr_reintegro_ajustes_rubro.codigo_unidad_ejecutora = :codigo_unidad_ejecutora AND
           pr_reintegro_ajustes_rubro.vigencia = :vigencia AND
           pr_reintegro_ajustes_rubro.rubro_interno = :rubro_interno AND
           to_char(pr_reintegro_ajustes.fecha_registro,'mm') = :p_mes ;
*/

    -- Ajustes
    
    SELECT NVL(SUM(NVL(pr_reintegro_ajustes_rubro.valor,0)),0) --INTO mi_valor_ajustes 0
    FROM pr_reintegro_ajustes, pr_reintegro_ajustes_rubro
    WHERE (pr_reintegro_ajustes_rubro.consecutivo_ajuste=pr_reintegro_ajustes.consecutivo_ajuste AND
           pr_reintegro_ajustes_rubro.numero_registro=pr_reintegro_ajustes.numero_registro AND
           pr_reintegro_ajustes_rubro.numero_disponibilidad=pr_reintegro_ajustes.numero_disponibilidad AND
           pr_reintegro_ajustes_rubro.consecutivo_orden=pr_reintegro_ajustes.consecutivo_orden AND
           pr_reintegro_ajustes_rubro.numero_orden=pr_reintegro_ajustes.numero_orden AND
           pr_reintegro_ajustes_rubro.codigo_unidad_ejecutora=pr_reintegro_ajustes.codigo_unidad_ejecutora AND
           pr_reintegro_ajustes_rubro.codigo_compania=pr_reintegro_ajustes.codigo_compania AND
           pr_reintegro_ajustes_rubro.vigencia=pr_reintegro_ajustes.vigencia) AND
           pr_reintegro_ajustes_rubro.codigo_compania = :codigo_compania AND
           pr_reintegro_ajustes_rubro.codigo_unidad_ejecutora = :codigo_unidad_ejecutora AND
           pr_reintegro_ajustes_rubro.vigencia = :vigencia AND
           pr_reintegro_ajustes_rubro.rubro_interno = :rubro_interno AND
           to_char(pr_reintegro_ajustes.fecha_registro,'mm') = :p_mes AND
           pr_reintegro_ajustes.tipo_movimiento = 'AJUSTE';

    -- Reintegros
    SELECT NVL(SUM(NVL(pr_reintegro_ajustes_rubro.valor,0)),0) --INTO mi_valor_reintegro 395
    FROM pr_reintegro_ajustes, pr_reintegro_ajustes_rubro
    WHERE (pr_reintegro_ajustes_rubro.consecutivo_ajuste=pr_reintegro_ajustes.consecutivo_ajuste AND
           pr_reintegro_ajustes_rubro.numero_registro=pr_reintegro_ajustes.numero_registro AND
           pr_reintegro_ajustes_rubro.numero_disponibilidad=pr_reintegro_ajustes.numero_disponibilidad AND
           pr_reintegro_ajustes_rubro.consecutivo_orden=pr_reintegro_ajustes.consecutivo_orden AND
           pr_reintegro_ajustes_rubro.numero_orden=pr_reintegro_ajustes.numero_orden AND
           pr_reintegro_ajustes_rubro.codigo_unidad_ejecutora=pr_reintegro_ajustes.codigo_unidad_ejecutora AND
           pr_reintegro_ajustes_rubro.codigo_compania=pr_reintegro_ajustes.codigo_compania AND
           pr_reintegro_ajustes_rubro.vigencia=pr_reintegro_ajustes.vigencia) AND
           pr_reintegro_ajustes_rubro.codigo_compania = :codigo_compania AND
           pr_reintegro_ajustes_rubro.codigo_unidad_ejecutora = :codigo_unidad_ejecutora AND
           pr_reintegro_ajustes_rubro.vigencia = :vigencia AND
           pr_reintegro_ajustes_rubro.rubro_interno = :rubro_interno AND
           to_char(pr_reintegro_ajustes.fecha_registro,'mm') = :p_mes AND
           pr_reintegro_ajustes.tipo_movimiento = 'REINTEGRO';

  mi_valor_compromisos_mes := NVL(mi_valor_registro,0) -  NVL(mi_valor_rp_anulados,0) -  NVL(mi_valor_rp_parciales,0) + NVL(mi_valor_ajustes,0) + NVL(mi_valor_reintegro,0);

  RETURN NVL(mi_valor_compromisos_mes,0);
  
  
end;