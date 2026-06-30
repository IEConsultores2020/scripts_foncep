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
pr_apropiacion.vigencia =  :P_VIGENCIA  AND
pr_apropiacion.codigo_compania = :P_COMPANIA  AND
pr_apropiacion.codigo_unidad_ejecutora =  :P_UNIDAD   AND
pr_nivel1.codigo =  LTRIM(RTRIM( :P_NIVEL1))
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
 pr_nivel8.codigo;


 SELECT * --NVL(SUM(NVL(pr_v_orden_pago_regis_predis.valor,0)),0) INTO mi_valor_op
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
         --pr_v_orden_pago_regis_predis.rubro_interno = :rubro_interno AND
         TO_CHAR(pr_v_orden_de_pago_predis.fecha_registro,'YYYY') = :vigencia AND
         TO_NUMBER(TO_CHAR(pr_v_orden_de_pago_predis.fecha_registro,'MM')) = TO_NUMBER(:P_MES) AND
         pr_v_orden_de_pago_predis.ESTADO <> 'ANULADO'