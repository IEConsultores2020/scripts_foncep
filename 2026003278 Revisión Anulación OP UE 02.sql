/*
      Se realizo la anulación de la orden de pago nro. 424 y ya en su estado aparece "anulada", sin embargo, al intentar realizar la anulación en PREDIS de los CRPS que fueron afectados en esta orden de pago no permite hacerlo. Es como si los CRPS estuvieran aun atados en esta orden de pago.
*/

SELECT  op.numero_orden,  op.numero_registro, 
op.numero_disponibilidad,
op.tipo_pago,op.consecutivo_orden,
SUM(opr.valor) valor  
FROM  pr_v_orden_de_pago_predis op,  pr_v_orden_pago_regis_predis opr
WHERE ( opr.consecutivo_orden= op.consecutivo_orden
 AND  opr.numero_orden= op.numero_orden
 AND  opr.codigo_unidad_ejecutora= op.codigo_unidad_ejecutora
 AND  opr.codigo_compania= op.codigo_compania
 AND  opr.vigencia= op.vigencia) AND op.estado <> 'ANULADO'
AND  op.vigencia = :b_pre_anulaciones.vigencia AND
 op.codigo_compania = :b_pre_anulaciones.codigo_compania AND
 op.codigo_unidad_ejecutora = :b_pre_anulaciones.codigo_unidad_ejecutora
group by
op.vigencia, op.codigo_compania,
op.codigo_unidad_ejecutora,
 op.numero_orden,  op.numero_registro, 
       op.numero_disponibilidad,
op.tipo_pago,op.consecutivo_orden
;


select *
from pr_v_orden_pago_regis_predis
where vigencia=2026 and codigo_unidad_ejecutora = '02'
;


SELECT pr_registro_presupuestal.numero_registro,
 pr_compromisos.registro_sipd,
       pr_registro_presupuestal.tipo_compromiso, 
 pr_registro_presupuestal.numero_compromiso,
pr_registro_presupuestal.numero_disponibilidad
FROM   pr_registro_presupuestal,    pr_compromisos
WHERE (pr_registro_presupuestal.tipo_compromiso=   pr_compromisos.tipo_compromiso
 AND   pr_registro_presupuestal.numero_compromiso=   pr_compromisos.numero_compromiso
 AND   pr_registro_presupuestal.numero_registro=   pr_compromisos.numero_registro
 AND   pr_registro_presupuestal.codigo_unidad_ejecutora=   pr_compromisos.codigo_unidad_ejecutora
 AND   pr_registro_presupuestal.codigo_compania=   pr_compromisos.codigo_compania
 AND   pr_registro_presupuestal.vigencia=  pr_compromisos.vigencia) and
pr_registro_presupuestal.vigencia = 2026 and --:b_pre_rp_anulados.vigencia and
pr_registro_presupuestal.codigo_compania = 206 --and--:b_pre_rp_anulados.codigo_compania and
--pr_registro_presupuestal.codigo_unidad_ejecutora = '02' --:b_pre_rp_anulados.codigo_unidad_ejecutora and
--(pr_registro_presupuestal.estado = 'VIGENTE-AGOTADO' or pr_registro_presupuestal.estado = 'VIGENTE')
and pr_registro_presupuestal.numero_registro in (439,440)
ORDER BY pr_registro_presupuestal.numero_registro
;

--frm.boton ogt_anula_op_ar.Anular/Enviar
     /*    IF MI_VALOR_MENSAJE = 88 THEN
            PR_PRESUPUESTO;
         ELSIF MI_VALOR_MENSAJE = 89 THEN
            :OGT_ORDEN_PAGO.ESTADO := '111100000';
         ELSIF MI_VALOR_MENSAJE = 90 THEN
         	  RETURN;
         END IF;   */
select *
from ogt_orden_pago
where vigencia=2026 and entidad=206 and unidad_ejecutora='02'
and consecutivo=424
;
-- estado = 111100101
       

       

select *
from pr_v_orden_de_pago_predis
 --       SET estado = 'ANULADO'
        WHERE vigencia = 2026 AND
            codigo_compania = 206 AND
            codigo_unidad_ejecutora = '02' AND
            --numero_orden = una_orden AND
            consecutivo_orden = 434;       




/***************************************************************************************
      Forma: ogt_anula_op_ar
            Libreria: lib_pre_anulacion_total
   Descripcion   : Anula una orden de pago y actualiza el estado del RP para cualquier orden, 
                  y el estado del compromiso y de la disponibilidad si es de Giro Directo
   Parámetros    : La vigencia, compañia, unidad ejecutora, número de orden, número de registro 
                   y número de disponibilidad
  *****************************************************************************************/

  PROCEDURE pr_pre_anular_orden(una_vigencia pr_v_orden_de_pago_predis.vigencia%TYPE, 
                              una_compania pr_v_orden_de_pago_predis.codigo_compania%TYPE, 
                              una_unidad pr_v_orden_de_pago_predis.codigo_unidad_ejecutora%TYPE,
                              una_orden pr_v_orden_de_pago_predis.numero_orden%TYPE, 
                              un_registro pr_v_orden_de_pago_predis.numero_registro%TYPE, 
                              una_disponibilidad pr_v_orden_de_pago_predis.numero_disponibilidad%TYPE,
                              un_consecutivo pr_v_orden_de_pago_predis.consecutivo_orden%TYPE) IS

     mi_modalidad_giro pr_disponibilidades.modalidad_giro%TYPE;
     mi_alerta NUMBER;
     mi_valor_total NUMBER;
     mi_valor_pagado NUMBER;
     mi_total_orden NUMBER;
     mi_saldo NUMBER;

  BEGIN

    -- Si la disponibilidad es de Giro No Directo entonces procede a cambiar el estado del RP.

       mi_valor_total := 0;
       mi_valor_pagado := 0;
       global_error_anulacion := 0;

    -- Obtiene el Total del Registro Presupuestal para la vigencia 
    -- entidad y unidad ejecutora que se esta consultando.


       mi_valor_total := 
       select pk_pre_anulacion_total.fn_pre_total_rp (una_vigencia, una_compania,
                                 una_unidad, un_registro,una_disponibilidad);
      -- CRP CDP mi_valor_total  
      -- 439 26  34823278
      -- 440 35  22392576                                        
   

       IF mi_valor_total IS NULL THEN
          SET_ALERT_PROPERTY('AL_STOP_1',ALERT_MESSAGE_TEXT,'No fue posible establecer el Valor Total del Registro presupuestal');
          mi_alerta := SHOW_ALERT('AL_STOP_1');
       END IF;

    -- Obtiene el Total del Registro Presupuestal incluido en Ordenes de Pago para la vigencia 
    -- entidad y unidad ejecutora que se esta consultando.


       mi_valor_pagado := pk_pre_anulacion_total.fn_pre_total_op_rp(una_vigencia, una_compania,
                                 una_unidad, un_registro,una_disponibilidad);
      -- CRP CDP mi_valor_pagado  
      -- 439 26  34823278
      -- 440 35  22392576                                        
                                    
                          


    -- Obtiene el Valor Total de la Orden que se esta anulando


       mi_total_orden := pk_pre_anulacion_total.fn_pre_total_orden(una_vigencia, una_compania,
                                 una_unidad, un_registro,una_disponibilidad, una_orden, un_consecutivo);
      -- CRP CDP mi_total_orden  
      -- 439 26  0
      -- 440 35  0                                             


    -- Calcula el saldo del RP, descontanso el valor total de la orden que se esta anulando

       mi_saldo := NVL(mi_valor_total,0) - NVL(mi_valor_pagado,0) + NVL(mi_total_orden,0) ;

    -- Se anula la orden de pago
      BEGIN
        UPDATE pr_v_orden_de_pago_predis
        SET estado = 'ANULADO'
        WHERE vigencia = una_vigencia AND
            codigo_compania = una_compania AND
            codigo_unidad_ejecutora = una_unidad AND
            numero_orden = una_orden AND
            consecutivo_orden = un_consecutivo;
      EXCEPTION
      	  WHEN OTHERS THEN
      	     null;
      END;

       IF mi_saldo = mi_valor_total THEN

          -- Si al anular la OP el saldo es igual al valor total del RP, entonces el estado es VIGENTE

            UPDATE pr_registro_presupuestal SET estado = 'VIGENTE' WHERE vigencia = una_vigencia AND codigo_compania = una_compania AND 
                         codigo_unidad_ejecutora = una_unidad AND 
                         numero_disponibilidad = una_disponibilidad AND 
                         numero_registro = un_registro ;
       ELSE

           -- Si al anular la OP el saldo es diferente al valor total del RP, entonces el estado es VIGENTE AGOTADO,
           -- esto quiere decir que existen otras ordenes de pago que utilizan el RP (Ordenes de Pago no Anuladas)

         UPDATE pr_registro_presupuestal SET estado = 'VIGENTE-AGOTADO' WHERE vigencia = una_vigencia AND codigo_compania = una_compania AND 
                         codigo_unidad_ejecutora = una_unidad AND 
                         numero_disponibilidad = una_disponibilidad AND 
                         numero_registro = un_registro ;

       END IF;
       EXCEPTION
       	 WHEN OTHERS THEN
       	    global_error_anulacion := -1;
       	
  END pr_pre_anular_orden;
            

 /*****************************************************************************************************************
    Descripción : Obtiene el valor total de un Registro Presupuestal desde la tabla de Registro Disponibilidad, descontando
               el valor de anulaciones parciales que tenga el registro.
    Párametros  : la vigencia, el codigo de la compañia, el codigo de la Unidad Ejecutora y el numero del registro.
    Retorna     : El valor total del RP.
   *****************************************************************************************************************/

   FUNCTION fn_pre_total_rp (una_vigencia pr_v_orden_pago_regis_predis.vigencia%TYPE, 
                          una_compania pr_v_orden_pago_regis_predis.codigo_compania%TYPE,
                          una_unidad pr_v_orden_pago_regis_predis.codigo_unidad_ejecutora%TYPE, 
                          un_registro pr_v_orden_pago_regis_predis.numero_registro%TYPE,
                          una_disponibilidad pr_v_orden_pago_regis_predis.numero_disponibilidad%TYPE) RETURN NUMBER IS

     mi_total NUMBER;
     mi_anulado_parcial NUMBER;
     mi_anulado_parcial_reservas NUMBER;

  BEGIN

     -- Inicializa como cero el total del Registro Presupuestal (RP)

     mi_total := 0;

     -- Obtiene el valor del RP de la tabla de Registros Disponibilidad

     SELECT NVL(SUM(NVL(rd.valor,0)),0) --INTO mi_total 
     FROM pr_registro_disponibilidad rd WHERE rd.vigencia = :una_vigencia AND 
           rd.codigo_compania = :una_compania AND rd.codigo_unidad_ejecutora = :una_unidad AND 
          rd.numero_registro = :un_registro AND rd.numero_disponibilidad = :una_disponibilidad 
          GROUP BY rd.vigencia, rd.codigo_compania,  rd.numero_disponibilidad;
     -- CRP CDP mi_total  
     -- 439 26  34823278
     -- 440 35  22392576

     -- Obtiene el valor del RP Anulado Parcialmente de la tabla de Rp Anulados Parcialmnte (pr_rp_anulados)

     SELECT NVL(SUM(NVL(rpa.valor_anulado,0)),0) --INTO mi_anulado_parcial 
     FROM pr_rp_anulados rpa WHERE rpa.vigencia = :una_vigencia AND 
          rpa.codigo_compania = :una_compania AND rpa.codigo_unidad_ejecutora = :una_unidad AND 
          rpa.numero_registro = :un_registro AND rpa.numero_disponibilidad = :una_disponibilidad 
          GROUP BY rpa.vigencia, rpa.codigo_compania, 
          rpa.codigo_unidad_ejecutora, rpa.numero_registro, rpa.numero_disponibilidad;
      -- CRP CDP mi_anulado_parcial  
      -- 439 26  0
      -- 440 35  0

     -- Obtiene el valor del RP Anulado Parcialmente de la tabla de Rp Anulados Parcialmnte (pr_rp_anulados_reservas)

     SELECT NVL(SUM(NVL(rpa.valor_anulado,0)),0) --INTO mi_anulado_parcial_reservas 
     FROM pr_rp_anulados_reservas rpa WHERE rpa.vigencia = :una_vigencia AND 
          rpa.codigo_compania = :una_compania AND rpa.codigo_unidad_ejecutora = :una_unidad AND 
          rpa.numero_registro = :un_registro AND rpa.numero_disponibilidad = :una_disponibilidad 
          GROUP BY rpa.vigencia, rpa.codigo_compania, 
          rpa.codigo_unidad_ejecutora, rpa.numero_registro, rpa.numero_disponibilidad;
      -- CRP CDP mi_anulado_parcial_reservas  
      -- 439 26    0
      -- 440 35    0

     mi_total := NVL(mi_total,0) - NVL(mi_anulado_parcial,0) - NVL(mi_anulado_parcial_reservas,0);

     RETURN mi_total;

     EXCEPTION

        WHEN NO_DATA_FOUND THEN 

      mi_total := NVL(mi_total,0) - NVL(mi_anulado_parcial,0) - NVL(mi_anulado_parcial_reservas,0);

      RETURN mi_total;


  END fn_pre_total_rp;


 /*****************************************************************************************************************
   Descripción : Obtiene el valor total incluido en una Orden de Pago (suma el valor de todos los rubros de la OP). 
   Párametros  : la vigencia, el codigo de la compañia, el codigo de la Unidad Ejecutora, registro, la disponibilidad 
               y el numero de la orden.
   Retorna     : El valor total de una orden de pago.
  *****************************************************************************************************************/

     FUNCTION fn_pre_total_orden (una_vigencia pr_v_orden_pago_regis_predis.vigencia%TYPE, 
                          una_compania pr_v_orden_pago_regis_predis.codigo_compania%TYPE,
                          una_unidad pr_v_orden_pago_regis_predis.codigo_unidad_ejecutora%TYPE, 
                          un_registro pr_v_orden_pago_regis_predis.numero_registro%TYPE,
                          una_disponibilidad pr_v_orden_pago_regis_predis.numero_disponibilidad%TYPE, 
                          una_orden pr_v_orden_de_pago_predis.numero_orden%TYPE,
                          un_consecutivo pr_v_orden_de_pago_predis.consecutivo_orden%TYPE) RETURN NUMBER IS
     mi_total_orden NUMBER;

   BEGIN

     -- Inicializa como cero el valor total del RP incluido en Ordenes de Pago

     mi_total_orden := 0;

     -- Obtiene el valor de lo pagado a partir de la tabla orden_de_pago

     SELECT NVL(SUM(NVL(opr.valor,0)),0) --INTO mi_total_orden 
     FROM pr_orden_de_pago_registro opr 
     WHERE opr.vigencia = :una_vigencia AND 
           opr.codigo_compania = :una_compania AND 
           opr.codigo_unidad_ejecutora = :una_unidad AND 
           opr.numero_registro = :un_registro AND 
           opr.numero_disponibilidad = :una_disponibilidad /*AND 
           opr.numero_orden = :una_orden AND 
           opr.consecutivo_orden = :un_consecutivo */
          GROUP BY opr.vigencia, opr.codigo_compania, 
          opr.codigo_unidad_ejecutora, opr.numero_registro, 
          opr.numero_disponibilidad, opr.numero_orden;
      -- CRP CDP mi_anulado_mi_total_ordenparcial_reservas  
      -- 439 26    0
      -- 440 35    0

     RETURN NVL(mi_total_orden,0);

     EXCEPTION

        WHEN NO_DATA_FOUND THEN 
           mi_total_orden := 0;

           RETURN mi_total_orden;

   END fn_pre_total_orden;

   select *
   from pr_registro_presupuestal
   where vigencia=2026
   and codigo_compania=206
   and codigo_unidad_ejecutora='02'
   and numero_registro||'-'||numero_disponibilidad in ('439-26','440-35');

   update pr_registro_presupuestal
   set estado = 'VIGENTE'
   where vigencia=2026
   and codigo_compania=206
   and codigo_unidad_ejecutora='02'
   and numero_registro||'-'||numero_disponibilidad in ('439-26','440-35');

   commit;