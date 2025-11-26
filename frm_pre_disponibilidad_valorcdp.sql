-- Actualiza variable de total de cdp

-- Si ya se ha seleccionado el rubro valida la apropiacion
IF  :b_pre_disponibilidad_rubro.rubro_interno IS NOT NULL THEN
    -- Valida la existencia de la apropiacion para el rubro
    pk_disponibilidad.pr_valida_apropiacion;
END IF;


:b_pre_disponibilidades.valor_total_cdp := NVL(:b_pre_disponibilidades.valor_total_cdp,0) + NVL(:b_pre_disponibilidad_rubro.valor,0) - NVL(pk_disponibilidad.gl_mi_valor_anterior,0);

PROCEDURE pr_valida_apropiacion IS

   -- Define variables 

      mi_valor_apropiacion      pr_disponibilidad_rubro.valor%TYPE;
      mi_valor_cdp              pr_disponibilidad_rubro.valor%TYPE;
      mi_valor_disponible       pr_disponibilidad_rubro.valor%TYPE;
      mi_valor_registros_p      pr_disponibilidad_rubro.valor%TYPE;
      mi_valor_ajuste_reintegro pr_disponibilidad_rubro.valor%TYPE;
      mi_valor_reintegro        pr_disponibilidad_rubro.valor%TYPE;
      mi_registro               NUMBER;
      mi_bloque_actual          VARCHAR2(30);
     
   BEGIN

      mi_valor_apropiacion := NULL;
      mi_valor_cdp := NULL;
      mi_valor_disponible := NULL;
      mi_valor_registros_p := NULL;
      mi_valor_ajuste_reintegro := NULL;
      mi_valor_reintegro := NULL;
      

      -- Asigna valor a variables: Valor de apropiacion para un rubro

      mi_valor_apropiacion := pk_disponibilidad.fn_traer_valor_decreto(:b_pre_disponibilidad_rubro.rubro_interno,
      :b_pre_disponibilidades.vigencia, :b_pre_unidad_ejecutora.codigo_compania,
      :b_pre_unidad_ejecutora.codigo);
        SELECT (NVL(valor,0) - NVL(valor_rezago,0) + NVL(valor_modificaciones,0)) 
        FROM pr_apropiacion
        WHERE vigencia = 2025 AND                      
        rubro_interno = :un_interno AND 
        codigo_compania = 206 AND 
        codigo_unidad_ejecutora = '01';  --mi_valor_apropiacion 10.522.019


	  ---->>>>>>>>>>
      -- Asigna valor a variables: Totaliza Valor del rubro en CDP
      mi_valor_cdp := pk_disponibilidad.fn_traer_total_cdp (:b_pre_disponibilidad_rubro.rubro_interno,
      :b_pre_disponibilidades.vigencia, :b_pre_unidad_ejecutora.codigo_compania,
      :b_pre_unidad_ejecutora.codigo);
            mi_total :=  NVL(mi_total_cdp,0) - 
                        NVL(mi_total_anulacion_total,0) -  
                        NVL(mi_total_anulados,0) - 
                        NVL(mi_total_anulados_autorizados,0);    

            --disponibilidad
            --CURSOR c_disponibilidades IS
            SELECT NVL(SUM(NVL(PR_DISPONIBILIDAD_RUBRO.VALOR,0)),0) 
                    FROM PR_DISPONIBILIDAD_RUBRO, PR_DISPONIBILIDADES
                    WHERE (PR_DISPONIBILIDAD_RUBRO.NUMERO_DISPONIBILIDAD=PR_DISPONIBILIDADES.NUMERO_DISPONIBILIDAD
                    AND PR_DISPONIBILIDAD_RUBRO.CODIGO_UNIDAD_EJECUTORA=PR_DISPONIBILIDADES.CODIGO_UNIDAD_EJECUTORA
                    AND PR_DISPONIBILIDAD_RUBRO.CODIGO_COMPANIA=PR_DISPONIBILIDADES.CODIGO_COMPANIA
                    AND PR_DISPONIBILIDAD_RUBRO.VIGENCIA=PR_DISPONIBILIDADES.VIGENCIA
                    AND PR_DISPONIBILIDAD_RUBRO.CODIGO_UNIDAD_EJECUTORA= '01' --un_codigo_unidad
                    AND PR_DISPONIBILIDAD_RUBRO.CODIGO_COMPANIA= '206' --un_codigo_compania
                    AND PR_DISPONIBILIDAD_RUBRO.VIGENCIA= '2025' --una_vigencia
                    AND PR_DISPONIBILIDAD_RUBRO.RUBRO_INTERNO = 1491 ); --un_interno);
           mi_total_cdp 15463000

            
            --Anulaciones del mes efectuadas en el  mismo mes.
            --CURSOR c_anulacion_total is
            SELECT NVL(SUM(NVL(PR_DISPONIBILIDAD_RUBRO.VALOR,0)),0) 
            FROM PR_DISPONIBILIDAD_RUBRO, PR_DISPONIBILIDADES
            WHERE PR_DISPONIBILIDAD_RUBRO.NUMERO_DISPONIBILIDAD=PR_DISPONIBILIDADES.NUMERO_DISPONIBILIDAD
            AND PR_DISPONIBILIDAD_RUBRO.CODIGO_UNIDAD_EJECUTORA=PR_DISPONIBILIDADES.CODIGO_UNIDAD_EJECUTORA
            AND PR_DISPONIBILIDAD_RUBRO.CODIGO_COMPANIA=PR_DISPONIBILIDADES.CODIGO_COMPANIA
            AND PR_DISPONIBILIDAD_RUBRO.VIGENCIA=PR_DISPONIBILIDADES.VIGENCIA
            AND PR_DISPONIBILIDAD_RUBRO.CODIGO_UNIDAD_EJECUTORA='01' --un_codigo_unidad
            AND PR_DISPONIBILIDAD_RUBRO.CODIGO_COMPANIA=206 -- un_codigo_compania
            AND PR_DISPONIBILIDAD_RUBRO.VIGENCIA=2025 --una_vigencia
            AND PR_DISPONIBILIDAD_RUBRO.RUBRO_INTERNO=1491 --un_interno
            AND PR_DISPONIBILIDADES.NUMERO_DISPONIBILIDAD IN (SELECT numero_documento_anulado
                                                                FROM pr_anulaciones
                                                                WHERE vigencia = 2025 /*una_vigencia*/ AND
                                                                    codigo_compania = 206 /*un_codigo_compania*/ AND
                                                                    codigo_unidad_ejecutora = '01' /*un_codigo_unidad*/ AND
                                                                    documento_anulado = 'CDP');
            mi_total_anulacion_total 3490981

            
                                                            
            --CURSOR c_cdp_anulados IS
            SELECT NVL(sum(nvl(valor_anulado,0)),0) valor_anulado
            FROM pr_cdp_anulados
            WHERE vigencia = 2025 /*una_vigencia*/ and 
                codigo_compania = 206 /*un_codigo_compania*/ AND
                codigo_unidad_ejecutora = '01' /*un_codigo_unidad*/ AND
                rubro_interno = 1491; --un_interno;
            mi_total_anulados 5522019

                                                                        
            --CURSOR c_cdp_anulados_autorizados IS
            SELECT NVL(sum(nvl(valor_anulado,0)),0) valor_anulado
            FROM pr_cdp_anulados_autorizados
            WHERE vigencia = 2025 /*una_vigencia*/ and 
                codigo_compania = 202 /*un_codigo_compania*/ AND
                codigo_unidad_ejecutora = '01' /*un_codigo_unidad*/ AND
                rubro_interno = 1491;
            mi_total_anulados_autorizados 0
        ----<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

			
      -- Asigna valor a variables: Totaliza los ajustes
      
      mi_valor_ajuste_reintegro := pk_disponibilidad.fn_traer_ajuste_cdp(:b_pre_disponibilidad_rubro.rubro_interno,
      :b_pre_disponibilidades.vigencia, :b_pre_unidad_ejecutora.codigo_compania,
      :b_pre_unidad_ejecutora.codigo)  ;
        SELECT NVL(SUM(NVL(pr_reintegro_ajustes_rubro.valor,0)),0)
        FROM pr_reintegro_ajustes, pr_reintegro_ajustes_rubro
        WHERE (pr_reintegro_ajustes_rubro.consecutivo_ajuste=pr_reintegro_ajustes.consecutivo_ajuste AND 
               pr_reintegro_ajustes_rubro.numero_registro=pr_reintegro_ajustes.numero_registro AND 
               pr_reintegro_ajustes_rubro.numero_disponibilidad=pr_reintegro_ajustes.numero_disponibilidad AND
               pr_reintegro_ajustes_rubro.consecutivo_orden=pr_reintegro_ajustes.consecutivo_orden AND 
               pr_reintegro_ajustes_rubro.numero_orden=pr_reintegro_ajustes.numero_orden AND 
               pr_reintegro_ajustes_rubro.codigo_unidad_ejecutora=pr_reintegro_ajustes.codigo_unidad_ejecutora AND 
               pr_reintegro_ajustes_rubro.codigo_compania=pr_reintegro_ajustes.codigo_compania AND 
               pr_reintegro_ajustes_rubro.vigencia=pr_reintegro_ajustes.vigencia) AND
               pr_reintegro_ajustes_rubro.vigencia = 2025 /*una_vigencia*/ AND 
               pr_reintegro_ajustes_rubro.codigo_compania = 206 /*un_codigo_compania*/ AND 
               pr_reintegro_ajustes_rubro.codigo_unidad_ejecutora = '01'  and
               pr_reintegro_ajustes_rubro.rubro_interno = 1491 /*un_interno*/ AND
               pr_reintegro_ajustes.tipo_movimiento = 'AJUSTE';
      
      




     -- Asigna valor a variables: Totaliza los Reintegros
      
      mi_valor_reintegro := pk_disponibilidad.fn_traer_reintegro_cdp(:b_pre_disponibilidad_rubro.rubro_interno,
      :b_pre_disponibilidades.vigencia, :b_pre_unidad_ejecutora.codigo_compania,
      :b_pre_unidad_ejecutora.codigo)  ;
      SELECT NVL(SUM(NVL(pr_reintegro_ajustes_rubro.valor,0)),0)
        FROM pr_reintegro_ajustes, pr_reintegro_ajustes_rubro
        WHERE (pr_reintegro_ajustes_rubro.consecutivo_ajuste=pr_reintegro_ajustes.consecutivo_ajuste AND 
               pr_reintegro_ajustes_rubro.numero_registro=pr_reintegro_ajustes.numero_registro AND 
               pr_reintegro_ajustes_rubro.numero_disponibilidad=pr_reintegro_ajustes.numero_disponibilidad AND
               pr_reintegro_ajustes_rubro.consecutivo_orden=pr_reintegro_ajustes.consecutivo_orden AND 
               pr_reintegro_ajustes_rubro.numero_orden=pr_reintegro_ajustes.numero_orden AND 
               pr_reintegro_ajustes_rubro.codigo_unidad_ejecutora=pr_reintegro_ajustes.codigo_unidad_ejecutora AND 
               pr_reintegro_ajustes_rubro.codigo_compania=pr_reintegro_ajustes.codigo_compania AND 
               pr_reintegro_ajustes_rubro.vigencia=pr_reintegro_ajustes.vigencia) AND
               pr_reintegro_ajustes_rubro.vigencia = 2025 /*una_vigencia*/ AND 
               pr_reintegro_ajustes_rubro.codigo_compania = 206 /*un_codigo_compania*/ AND 
               pr_reintegro_ajustes_rubro.codigo_unidad_ejecutora = '01' /*un_codigo_unidad*/ and
               pr_reintegro_ajustes_rubro.rubro_interno = 1491 /*un_interno*/ AND
               pr_reintegro_ajustes.tipo_movimiento = 'REINTEGRO';


     -- mi_valor_disponible := NVL(mi_valor_apropiacion,0) - NVL(mi_valor_cdp,0);

      --mi_valor_disponible := NVL(mi_valor_apropiacion,0) - NVL(mi_valor_cdp,0) + NVL(mi_valor_ajuste_reintegro,0) + NVL(mi_valor_reintegro,0);
      
      mi_valor_disponible := NVL(mi_valor_apropiacion,0) - 
            (NVL(mi_valor_cdp,0) + NVL(mi_valor_ajuste_reintegro,0) + NVL(mi_valor_reintegro,0));

		  	  
      -- Asigna valor afectado de ese rubro a partir de Registros Presupuestales

      mi_valor_registros_p := pk_disponibilidad.fn_traer_total_registro(:b_pre_disponibilidad_rubro.rubro_interno,
      :b_pre_disponibilidades.vigencia, :b_pre_unidad_ejecutora.codigo_compania,
      :b_pre_unidad_ejecutora.codigo);
      SELECT NVL(sum(NVL(pr_registro_disponibilidad.valor,0)),0)
        FROM pr_registro_disponibilidad
        WHERE pr_registro_disponibilidad.vigencia = :una_vigencia and
           pr_registro_disponibilidad.codigo_compania = :un_codigo_compania AND
           pr_registro_disponibilidad.codigo_unidad_ejecutora = :un_codigo_unidad and
           pr_registro_disponibilidad.rubro_interno = :un_interno;

      -- Asigna valor a variable global
      pk_disponibilidad.gl_mi_saldo_apropiacion_rubro := NVL(mi_valor_apropiacion,0) +  NVL(mi_valor_ajuste_reintegro,0) + NVL(mi_valor_reintegro,0);
      pk_disponibilidad.gl_mi_total_cdp_rubro := NVL(mi_valor_cdp,0);
--      pk_disponibilidad.gl_mi_valor_dispo_rubro:= NVL(mi_valor_disponible,0);
      pk_disponibilidad.gl_mi_valor_dispo_rubro:= NVL(:b_pre_disponibilidad_rubro.valor,0);
      pk_disponibilidad.gl_mi_total_registros_rubro := NVL(mi_valor_registros_p,0);

--      gl_mi_valor_rubro := :b_pre_disponibilidades_rubro.valor;

      -- Valida que el valor del Certificado de Disponibilidad no sea mayor a
      -- lo apropiado en el Decreto de Liquidación

      IF NVL(mi_valor_disponible,0) < NVL(NAME_IN('b_pre_disponibilidad_rubro.valor'),0) THEN
        mi_registro := NAME_IN('SYSTEM.CuRSOR_RECORD');
        pr_despliega_mensaje ('AL_STOP_1','El valor del Rubro en el Certificado de Disponibilidad no debe superar lo Apropiado para el rubro. '||chr(13)||chr(10)||'El Valor Disponible es: ' || TO_CHAR(mi_valor_disponible,'999,999,999,999,999,999.99'));
        GO_RECORD(mi_registro);
        GO_ITEM('b_pre_disponibilidad_rubro.valor'); 
        RAISE FORM_TRIGGER_FAILURE;
      END IF; 


    END pr_valida_apropiacion;