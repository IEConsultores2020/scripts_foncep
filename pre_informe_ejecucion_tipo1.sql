SELECT LTRIM(RTRIM(pr_rubro.descripcion)) descripcion_rubro, 
 pr_nivel1.codigo codigo_nivel1,
 pr_nivel2.codigo codigo_nivel2,
 pr_nivel3.codigo codigo_nivel3,
 pr_nivel4.codigo codigo_nivel4,
 pr_nivel5.codigo codigo_nivel5,
pr_nivel6.codigo codigo_nivel6, pr_nivel7.codigo codigo_nivel7,
 pr_nivel8.codigo codigo_nivel8,
( pr_nivel1.codigo ||'-'||
 pr_nivel2.codigo ||'-'|| 
 pr_nivel3.codigo ||'-'||
 pr_nivel4.codigo ||'-'||
 pr_nivel5.codigo ||'-'||
pr_nivel6.codigo ||'-'||
pr_nivel7.codigo ||'-'||
 pr_nivel8.codigo )  cadena_rubro,
pr_apropiacion.vigencia vigencia,
pr_apropiacion.rubro_interno,
pr_apropiacion.codigo_compania,
pr_apropiacion.codigo_unidad_ejecutora,
NVL(pr_apropiacion.valor,0) valor,
(  pr_nivel1.codigo||'-'||
 pr_nivel2.codigo||'-'||
 pr_nivel3.codigo||'-'||
 pr_nivel4.codigo||'-'||
 pr_nivel5.codigo||'-'||
 pr_nivel6.codigo||'-'||
 pr_nivel7.codigo||'-'||
 pr_nivel8.codigo) cadena_nivel8,
LTRIM(RTRIM(pr_nivel8.descripcion)) desc_nivel8,
(  pr_nivel1.codigo||'-'||
 pr_nivel2.codigo||'-'||
 pr_nivel3.codigo||'-'||
 pr_nivel4.codigo||'-'||
 pr_nivel5.codigo||'-'||
 pr_nivel6.codigo||'-'||
 pr_nivel7.codigo) cadena_nivel7,
LTRIM(RTRIM(pr_nivel7.descripcion)) desc_nivel7,
(  pr_nivel1.codigo||'-'||
 pr_nivel2.codigo||'-'||
 pr_nivel3.codigo||'-'||
 pr_nivel4.codigo||'-'||
 pr_nivel5.codigo||'-'||
 pr_nivel6.codigo) cadena_nivel6,
LTRIM(RTRIM(pr_nivel6.descripcion)) desc_nivel6,
(  pr_nivel1.codigo||'-'||
 pr_nivel2.codigo||'-'||
 pr_nivel3.codigo||'-'||
 pr_nivel4.codigo||'-'||
 pr_nivel5.codigo) cadena_nivel5,
LTRIM(RTRIM(pr_nivel5.descripcion)) desc_nivel5,
(  pr_nivel1.codigo||'-'||
 pr_nivel2.codigo||'-'||
 pr_nivel3.codigo||'-'||
 pr_nivel4.codigo) cadena_nivel4,
LTRIM(RTRIM(pr_nivel4.descripcion)) desc_nivel4,
(  pr_nivel1.codigo||'-'||
 pr_nivel2.codigo||'-'||
 pr_nivel3.codigo
) cadena_nivel3,
LTRIM(RTRIM(pr_nivel3.descripcion)) desc_nivel3,
(  pr_nivel1.codigo||'-'||
 pr_nivel2.codigo
) cadena_nivel2,
LTRIM(RTRIM(pr_nivel2.descripcion)) desc_nivel2,
(  pr_nivel1.codigo) cadena_nivel1,
LTRIM(RTRIM(pr_nivel1.descripcion)) desc_nivel1
 FROM pr_apropiacion,pr_rubro,pr_nivel8, pr_nivel7, pr_nivel6,
pr_nivel5, pr_nivel4,
pr_nivel3, pr_nivel2, pr_nivel1
WHERE 
pr_apropiacion.vigencia = pr_rubro.vigencia AND
pr_apropiacion.rubro_interno = pr_rubro.interno AND
pr_rubro.vigencia = pr_nivel1.vigencia AND
pr_rubro.interno_nivel1 = pr_nivel1.interno AND
pr_rubro.tipo_plan = pr_nivel1.tipo_plan AND
pr_rubro.vigencia = pr_nivel2.vigencia AND
pr_rubro.interno_nivel2 = pr_nivel2.interno AND
pr_rubro.tipo_plan = pr_nivel2.tipo_plan AND
pr_rubro.vigencia = pr_nivel3.vigencia AND
pr_rubro.interno_nivel3 = pr_nivel3.interno AND
pr_rubro.tipo_plan = pr_nivel3.tipo_plan AND
pr_rubro.vigencia = pr_nivel4.vigencia AND
pr_rubro.interno_nivel4 = pr_nivel4.interno AND
pr_rubro.tipo_plan = pr_nivel4.tipo_plan AND
pr_rubro.vigencia = pr_nivel5.vigencia AND
pr_rubro.interno_nivel5 = pr_nivel5.interno AND
pr_rubro.tipo_plan = pr_nivel5.tipo_plan AND
pr_rubro.vigencia = pr_nivel6.vigencia AND
pr_rubro.interno_nivel6 = pr_nivel6.interno AND
pr_rubro.tipo_plan = pr_nivel6.tipo_plan AND
pr_rubro.vigencia = pr_nivel7.vigencia AND
pr_rubro.interno_nivel7 = pr_nivel7.interno AND
pr_rubro.tipo_plan = pr_nivel7.tipo_plan AND
pr_rubro.vigencia = pr_nivel8.vigencia AND
pr_rubro.interno_nivel8 = pr_nivel8.interno AND
pr_rubro.tipo_plan = pr_nivel8.tipo_plan AND
pr_apropiacion.vigencia =  2025 /*:P_VIGENCIA*/  AND
pr_apropiacion.codigo_compania = 206 /*:P_COMPANIA*/  AND
pr_apropiacion.codigo_unidad_ejecutora = '01'  /*:P_UNIDAD */  AND
--pr_nivel1.codigo =  LTRIM(RTRIM( 2 /*:P_NIVEL1*/))
pr_rubro.descripcion like '%seguridad%social%' --AND
--and pr_apropiacion.DOCUMENTOS_FECHA = TO_DATE('01/01/2025', 'DD/MM/YYYY')
ORDER BY
pr_apropiacion.vigencia,
pr_apropiacion.codigo_compania,
pr_apropiacion.codigo_unidad_ejecutora,
 pr_nivel1.codigo, 
 pr_nivel2.codigo, 
 pr_nivel3.codigo, 
 pr_nivel4.codigo, 
 pr_nivel5.codigo, 
 pr_nivel6.codigo, 
 pr_nivel7.codigo, 
 pr_nivel8.codigo
 ;


--/////////////////////////////////////////////////////////////
--/////////////////////////////////////////////////////////////
function CF_GirosMesFormula return Number is
  mi_valor_op NUMBER(16,2);
  mi_valor_op_anulado NUMBER(16,2);
  mi_valor_op_mes NUMBER(16,2);
  mi_valor_ajustes NUMBER(16,2);
  mi_valor_reintegro NUMBER(16,2);

  mi_valor_op_ogt NUMBER(16,2);
  mi_valor_op_anulado_ogt NUMBER(16,2);
  mi_valor_op_mes_ogt NUMBER(16,2);
  mi_valor_ajustes_ogt NUMBER(16,2);
  mi_valor_reintegro_ogt NUMBER(16,2);
  mi_valor_total NUMBER(16,2);
begin

  mi_valor_op := NULL;
  mi_valor_op_anulado := NULL;
  mi_valor_op_mes := NULL;
  mi_valor_ajustes := NULL;
  mi_valor_reintegro := NULL;

  mi_valor_op_ogt := NULL;
  mi_valor_op_anulado_ogt := NULL;
  mi_valor_op_mes_ogt := NULL;
  mi_valor_ajustes_ogt := NULL;
  mi_valor_reintegro_ogt := NULL;

  mi_valor_total  := NULL;
  -- Valor Total de OP registradas en el mes

  BEGIN
  SELECT NVL(SUM(NVL(pr_v_orden_pago_regis_predis.valor,0)),0) INTO mi_valor_op
  FROM   pr_v_orden_pago_regis_predis,pr_v_orden_de_pago_predis
  WHERE  pr_v_orden_pago_regis_predis.vigencia=pr_v_orden_de_pago_predis.vigencia AND
         pr_v_orden_pago_regis_predis.codigo_compania=pr_v_orden_de_pago_predis.codigo_compania AND
         pr_v_orden_pago_regis_predis.codigo_unidad_ejecutora=pr_v_orden_de_pago_predis.codigo_unidad_ejecutora AND
         pr_v_orden_pago_regis_predis.numero_registro=pr_v_orden_de_pago_predis.numero_registro AND
         pr_v_orden_pago_regis_predis.numero_disponibilidad=pr_v_orden_de_pago_predis.numero_disponibilidad AND
         pr_v_orden_pago_regis_predis.numero_orden=pr_v_orden_de_pago_predis.numero_orden AND
         pr_v_orden_pago_regis_predis.consecutivo_orden=pr_v_orden_de_pago_predis.consecutivo_orden AND
         pr_v_orden_pago_regis_predis.vigencia = :vigencia AND
         pr_v_orden_pago_regis_predis.codigo_compania = :codigo_compania AND
         pr_v_orden_pago_regis_predis.codigo_unidad_ejecutora = :codigo_unidad_ejecutora AND
         pr_v_orden_pago_regis_predis.rubro_interno = :rubro_interno AND
         TO_CHAR(pr_v_orden_de_pago_predis.fecha_registro,'YYYY') = :vigencia AND
         TO_NUMBER(TO_CHAR(pr_v_orden_de_pago_predis.fecha_registro,'MM')) = TO_NUMBER(:P_MES) AND
         pr_v_orden_de_pago_predis.ESTADO <> 'ANULADO';
  EXCEPTION
  	WHEN OTHERS THEN
  	  mi_valor_op := 0;
  END;

  -- Valor Total de OP registradas en el mes por el sistema OPGET
  
/*CONSULTA OGT_ORDEN_PAGO
    where  AND TO_CHAR(B.FECHA_APROBACION, 'YYYY') = TO_CHAR(una_vigencia)
    AND ESTADO= 1
*/
 SELECT OGT_PK_PREDIS.ogt_fn_valor_mes(2025, --:vigencia,
  															206,  --:codigo_compania,
  															'01', --:codigo_unidad_ejecutora,
  															6,    --TO_NUMBER(:p_mes),
  															1387) --										:rubro_interno);
FROM dual                                
                                        
    
  -- Valor de Ordenes del mes anuladas en el mismos mes

  BEGIN
  SELECT * --NVL(SUM(NVL(pr_v_orden_pago_regis_predis.valor,0)),0) --INTO mi_valor_op_anulado
  FROM   pr_v_orden_pago_regis_predis,pr_v_orden_de_pago_predis
  WHERE  pr_v_orden_pago_regis_predis.vigencia=pr_v_orden_de_pago_predis.vigencia AND
         pr_v_orden_pago_regis_predis.codigo_compania=pr_v_orden_de_pago_predis.codigo_compania AND
         pr_v_orden_pago_regis_predis.codigo_unidad_ejecutora=pr_v_orden_de_pago_predis.codigo_unidad_ejecutora AND
         pr_v_orden_pago_regis_predis.numero_registro=pr_v_orden_de_pago_predis.numero_registro AND
         pr_v_orden_pago_regis_predis.numero_disponibilidad=pr_v_orden_de_pago_predis.numero_disponibilidad AND                
         pr_v_orden_pago_regis_predis.numero_orden=pr_v_orden_de_pago_predis.numero_orden  AND
         pr_v_orden_pago_regis_predis.consecutivo_orden=pr_v_orden_de_pago_predis.consecutivo_orden  AND
         pr_v_orden_pago_regis_predis.vigencia = 2025 AND --:vigencia AND
         pr_v_orden_pago_regis_predis.codigo_compania = 206 AND --:codigo_compania AND
         pr_v_orden_pago_regis_predis.codigo_unidad_ejecutora = '01' AND  --:codigo_unidad_ejecutora AND
         pr_v_orden_pago_regis_predis.rubro_interno in (1387,1388,1389,1390) AND -- :rubro_interno AND
         TO_CHAR(pr_v_orden_de_pago_predis.fecha_registro,'YYYY') = '2025' AND --:vigencia AND
         EXISTS (SELECT numero_documento_anulado, numero_registro, consecutivo_orden
                 FROM pr_v_anulaciones_predis
                 WHERE vigencia = pr_v_orden_pago_regis_predis.vigencia AND
                       codigo_compania = pr_v_orden_pago_regis_predis.codigo_compania AND
                       codigo_unidad_ejecutora = pr_v_orden_pago_regis_predis.codigo_unidad_ejecutora AND
                       documento_anulado = 'ORDEN' and 
                       numero_documento_anulado = pr_v_orden_pago_regis_predis.numero_orden AND
                       numero_registro = pr_v_orden_pago_regis_predis.numero_registro AND
                       consecutivo_orden = pr_v_orden_pago_regis_predis.consecutivo_orden AND
                       TO_NUMBER(TO_CHAR(fecha_registro,'MM')) = TO_NUMBER(:P_MES));
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
    SELECT NVL(SUM(NVL(pr_v_reint_ajust_rubro_predis.valor,0)),0) INTO mi_valor_ajustes
    FROM PR_V_REINT_AJUST_RUBRO_PREDIS,pr_v_reintegro_ajustes_predis
    WHERE  pr_v_reint_ajust_rubro_predis.vigencia=pr_v_reintegro_ajustes_predis.vigencia AND
           pr_v_reint_ajust_rubro_predis.codigo_compania=pr_v_reintegro_ajustes_predis.codigo_compania AND
           pr_v_reint_ajust_rubro_predis.codigo_unidad_ejecutora=pr_v_reintegro_ajustes_predis.codigo_unidad_ejecutora AND           
           pr_v_reint_ajust_rubro_predis.numero_disponibilidad=pr_v_reintegro_ajustes_predis.numero_disponibilidad AND
           pr_v_reint_ajust_rubro_predis.numero_registro=pr_v_reintegro_ajustes_predis.numero_registro AND
           pr_v_reint_ajust_rubro_predis.numero_orden=pr_v_reintegro_ajustes_predis.numero_orden AND
           pr_v_reint_ajust_rubro_predis.consecutivo_orden=pr_v_reintegro_ajustes_predis.consecutivo_orden AND
           pr_v_reint_ajust_rubro_predis.consecutivo_ajuste=pr_v_reintegro_ajustes_predis.consecutivo_ajuste AND
           pr_v_reint_ajust_rubro_predis.vigencia = :vigencia AND
           pr_v_reint_ajust_rubro_predis.codigo_compania = :codigo_compania AND
           pr_v_reint_ajust_rubro_predis.codigo_unidad_ejecutora = :codigo_unidad_ejecutora AND
           pr_v_reint_ajust_rubro_predis.rubro_interno = :rubro_interno AND
           TO_NUMBER(to_char(pr_v_reintegro_ajustes_predis.fecha_registro,'mm')) = TO_NUMBER(:p_mes) AND
           pr_v_reintegro_ajustes_predis.tipo_movimiento = 'AJUSTE';
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
    SELECT NVL(SUM(NVL(pr_v_reint_ajust_rubro_predis.valor,0)),0) INTO mi_valor_reintegro
    FROM pr_v_reint_ajust_rubro_predis,pr_v_reintegro_ajustes_predis
    WHERE  pr_v_reint_ajust_rubro_predis.vigencia=pr_v_reintegro_ajustes_predis.vigencia AND
           pr_v_reint_ajust_rubro_predis.codigo_compania=pr_v_reintegro_ajustes_predis.codigo_compania AND
           pr_v_reint_ajust_rubro_predis.codigo_unidad_ejecutora=pr_v_reintegro_ajustes_predis.codigo_unidad_ejecutora AND           
           pr_v_reint_ajust_rubro_predis.numero_disponibilidad=pr_v_reintegro_ajustes_predis.numero_disponibilidad AND
           pr_v_reint_ajust_rubro_predis.numero_registro=pr_v_reintegro_ajustes_predis.numero_registro AND
           pr_v_reint_ajust_rubro_predis.numero_orden=pr_v_reintegro_ajustes_predis.numero_orden AND
           pr_v_reint_ajust_rubro_predis.consecutivo_orden=pr_v_reintegro_ajustes_predis.consecutivo_orden AND
           pr_v_reint_ajust_rubro_predis.consecutivo_ajuste=pr_v_reintegro_ajustes_predis.consecutivo_ajuste AND
           pr_v_reint_ajust_rubro_predis.vigencia = :vigencia AND
           pr_v_reint_ajust_rubro_predis.codigo_compania = :codigo_compania AND
           pr_v_reint_ajust_rubro_predis.codigo_unidad_ejecutora = :codigo_unidad_ejecutora AND
           pr_v_reint_ajust_rubro_predis.rubro_interno = :rubro_interno AND
           TO_NUMBER(to_char(pr_v_reintegro_ajustes_predis.fecha_registro,'mm')) = TO_NUMBER(:p_mes) AND
           pr_v_reintegro_ajustes_predis.tipo_movimiento = 'REINTEGRO';
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
    mi_valor_op_mes := NVL(mi_valor_op,0) - NVL(mi_valor_op_anulado,0) + NVL(mi_valor_ajustes,0) + NVL(mi_valor_reintegro,0);

    mi_valor_op_mes_ogt := NVL(mi_valor_op_ogt,0) - NVL(mi_valor_op_anulado_ogt,0) - NVL(mi_valor_ajustes_ogt,0) - NVL(mi_valor_reintegro_ogt,0);
   
    mi_valor_total := mi_valor_op_mes + mi_valor_op_mes_ogt;
   
    RETURN NVL(mi_valor_total,0);

EXCEPTION
	WHEN OTHERS THEN
	   RETURN 0;
END CF_GirosMesFormula;                       