---Paquete
-- pk_pr_obligxpagar.fn_pre_obligxpagar_fc

SELECT  de.vigencia vigencia    ,
             de.codigo_compania              codigo_compania,
             de.codigo_unidad_ejecutora      codigo_unidad_ejecutora    ,
             de.rubro_interno                interno     ,
             'COM'                           tipo        ,
             2                               orden       ,
             ma.fecha_registro               fecha       ,
             TO_CHAR( ma.numero_registro )   nDoc        ,
             ma.tipo_compromiso || '-'|| TO_CHAR( ma.numero_compromiso )|| '-' || co.objeto             detalle     ,
             0    consecutivo_orden,
             de.valor                        vCmprmso    ,
             0                               vAtrzcion   ,
             0                               vAnulAutori ,
             0                               vAnulParComp,
             0                               vAnulComp,
             Pk_Pr_Compromisos.fn_pre_pagado_rubro_fc (una_vigencia,
                          un_codigo_compania,
                          un_codigo_unidad_ejecutora,
                          ma.numero_registro,
                          ma.numero_disponibilidad,
                          de.rubro_interno,
          		  una_fecha_corte) Vlor_giros,
             Pk_Pr_Compromisos.fn_pre_saldo_rp_fc (una_vigencia,
                          un_codigo_compania,
                          un_codigo_unidad_ejecutora,
                          ma.numero_registro,
                          ma.numero_disponibilidad,
                          de.rubro_interno,
          		  una_fecha_corte) Vsaldo
      FROM   PR_REGISTRO_PRESUPUESTAL        ma          ,
             PR_REGISTRO_DISPONIBILIDAD      de          ,
             PR_COMPROMISOS                  co
      WHERE  ma.vigencia                = de.vigencia AND
             ma.codigo_compania         = de.codigo_compania AND
             ma.codigo_unidad_ejecutora = de.codigo_unidad_ejecutora AND
             ma.numero_registro         = de.numero_registro AND
             ma.numero_disponibilidad   = de.numero_disponibilidad AND
             ma.vigencia                = co.vigencia AND
             ma.codigo_compania         = co.codigo_compania AND
             ma.codigo_unidad_ejecutora = co.codigo_unidad_ejecutora AND
             ma.numero_registro         = co.numero_registro AND
             ma.numero_compromiso       = co.numero_compromiso AND
             ma.tipo_compromiso         = co.tipo_compromiso AND
             ma.vigencia                = ( una_vigencia) AND
             ma.codigo_compania         =  un_codigo_compania AND
             ma.codigo_unidad_ejecutora =  un_codigo_unidad_ejecutora
;

SELECT 
pr_tmp_obligxpagar_reserva.vigencia, 
pr_tmp_obligxpagar_reserva.codigo_compania, 
pr_tmp_obligxpagar_reserva.codigo_unidad_ejecutora, 
pr_tmp_obligxpagar_reserva.codigo_entidad,
pr_tmp_obligxpagar_reserva.rubro_interno, 
pr_tmp_obligxpagar_reserva.numero_disponibilidad, 
pr_tmp_obligxpagar_reserva.numero_registro, 
pr_tmp_obligxpagar_reserva.numero_compromiso, 
pr_tmp_obligxpagar_reserva.tipo_compromiso, 
pr_tmp_obligxpagar_reserva.fecha_inicial, 
pr_tmp_obligxpagar_reserva.tipo_documento, 
pr_tmp_obligxpagar_reserva.numero_documento, 
pr_tmp_obligxpagar_reserva.id_interno, 
pr_tmp_obligxpagar_reserva.vcmprmso, 
pr_tmp_obligxpagar_reserva.vanulparcomp, 
pr_tmp_obligxpagar_reserva.vanulcomp, 
pr_tmp_obligxpagar_reserva.vlor_cmprmiso, 
pr_tmp_obligxpagar_reserva.vatrzcion, 
pr_tmp_obligxpagar_reserva.vanulautori, 
pr_tmp_obligxpagar_reserva.vlor_giros,
pr_tmp_obligxpagar_reserva.vsaldo,
(pr_nivel1.codigo||'-'||pr_nivel2.codigo||'-'||pr_nivel3.codigo||'-'||pr_nivel4.codigo||'-'||pr_nivel5.codigo||'-'||pr_nivel6.codigo||'-'||pr_nivel7.codigo||'-'||pr_nivel8.codigo) cadena,
pr_rubro.descripcion,
(pr_nivel1.codigo||'-'||pr_nivel2.codigo||'-'||pr_nivel3.codigo) cadena_niv3,
pr_nivel3.descripcion desc_niv3,
(pr_nivel1.codigo||'-'||pr_nivel2.codigo) cadena_niv2,
pr_nivel2.descripcion desc_niv2
--select *
FROM pr_tmp_obligxpagar_reserva, pr_rubro,pr_nivel1,pr_nivel2,pr_nivel3,pr_nivel4,pr_nivel5,
pr_nivel6,pr_nivel7,pr_nivel8
WHERE 
pr_tmp_obligxpagar_reserva.vigencia = pr_rubro.vigencia AND
pr_tmp_obligxpagar_reserva.rubro_interno = pr_rubro.interno AND
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
pr_tmp_obligxpagar_reserva.vigencia = :p_vigencia  AND
pr_tmp_obligxpagar_reserva.codigo_compania = :p_compania AND
pr_tmp_obligxpagar_reserva.codigo_unidad_ejecutora = :p_unidad AND
pr_tmp_obligxpagar_reserva.vsaldo > 0 AND
pr_nivel1.codigo =  LTRIM(RTRIM( :P_NIVEL1)) 
ORDER BY
pr_tmp_obligxpagar_reserva.vigencia,
pr_tmp_obligxpagar_reserva.codigo_compania,
pr_tmp_obligxpagar_reserva.codigo_unidad_ejecutora,
 pr_nivel1.codigo, 
 pr_nivel2.codigo, 
 pr_nivel3.codigo, 
 pr_nivel4.codigo, 
 pr_nivel5.codigo, 
 pr_nivel6.codigo, 
 pr_nivel7.codigo, 
 pr_nivel8.codigo,
pr_tmp_obligxpagar_reserva.numero_registro