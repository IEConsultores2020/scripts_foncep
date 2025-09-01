select pr_apropiacion.vigencia vigencia,
       pr_apropiacion.rubro_interno,
       pr_apropiacion.codigo_compania,
       pr_apropiacion.codigo_unidad_ejecutora,
       pr_apropiacion.valor apropiacion_inicial,
       ( pr_nivel1.codigo||'-'|| pr_nivel2.codigo||'-'|| pr_nivel3.codigo|| '-'
         || pr_nivel4.codigo||'-'|| pr_nivel5.codigo||'-'|| pr_nivel6.codigo|| '-'
         || pr_nivel7.codigo||'-'| pr_nivel8.codigo ) cadena_nivel8,
       pr_rubro.descripcion descripcion_rubro
  from pr_apropiacion,  pr_rubro, pr_nivel8, pr_nivel7, pr_nivel6, pr_nivel5,
       pr_nivel4,       pr_nivel3,pr_nivel2, pr_nivel1
 where pr_apropiacion.vigencia = :p_vigencia
   and pr_apropiacion.codigo_compania like :p_compania || '%'
   and pr_apropiacion.codigo_unidad_ejecutora like :p_unidad || '%'
   and pr_apropiacion.rubro_interno = nvl(:p_rubro_interno, pr_apropiacion.rubro_interno )
   and pr_apropiacion.rubro_interno = pr_rubro.interno
   and pr_apropiacion.vigencia = pr_rubro.vigencia
   and pr_apropiacion.vigencia = pr_nivel8.vigencia
   and pr_rubro.interno_nivel8 = pr_nivel8.interno
   and pr_nivel8.vigencia = pr_nivel7.vigencia
   and pr_rubro.interno_nivel7 = pr_nivel7.interno
   and pr_nivel7.vigencia = pr_nivel6.vigencia
   and pr_rubro.interno_nivel6 = pr_nivel6.interno
   and pr_nivel6.vigencia = pr_nivel5.vigencia
   and pr_rubro.interno_nivel5 = pr_nivel5.interno
   and pr_nivel5.vigencia = pr_nivel4.vigencia
   and pr_rubro.interno_nivel4 = pr_nivel4.interno
   and pr_nivel4.vigencia = pr_nivel3.vigencia
   and pr_rubro.interno_nivel3 = pr_nivel3.interno
   and pr_nivel3.vigencia = pr_nivel2.vigencia
   and pr_rubro.interno_nivel2 = pr_nivel2.interno
   and pr_nivel2.vigencia = pr_nivel1.vigencia
   and pr_rubro.interno_nivel1 = pr_nivel1.interno
 order by pr_apropiacion.vigencia,
          pr_apropiacion.codigo_compania,
          pr_apropiacion.codigo_unidad_ejecutora,
          pr_apropiacion.rubro_interno,
          pr_nivel1.codigo, pr_nivel2.codigo,  pr_nivel3.codigo,
          pr_nivel4.codigo, pr_nivel5.codigo,  pr_nivel6.codigo,
          pr_nivel7.codigo, pr_nivel8.codigo;
--rubo 1491. Ap. Inicial 14013000
/*          2. Modificaciones   0
            3. Apropiacion vigente = Apropiacion Inicial + Modificaciones = 14013000
            3. Suspensiones     0
            4. apropiacion_disponibe=Ap. Inicial-suspensiones = 14013000 - 0
            5. Disponibilidad = +935000-935000
                    mi_valor_disponib_total := 
                        (NVL(mi_valor_disponibilidades,0)                   11972019
                        +NVL(mi_valor_cdp_suspension,0))                    0
                        -NVL(mi_valor_cdp_anulados,0)                       0
                        -NVL(mi_valor_cdp_parciales,0)                      935000
                        -NVL(mi_valor_cdp_autorizados,0)                    0
                        +NVL(mi_valor_ajustes,0)                            0
                        +NVL(mi_valor_reintegro,0)                          935000
                        -NVL(mi_anulacion_cdp_sus_no_apl,0);                0

            6. Saldo Apropiación: Apropiacion Disponible - Disponibilidad
                                    14013000 - 11972019 = 2040981
            7. Compromisos
                mi_valor_comprom_total := NVL(mi_valor_registro,0)          11972019
                                        -  NVL(mi_valor_rp_anulados,0)      0
                                        -  NVL(mi_valor_rp_parciales,0)    -935000
                                        + NVL(mi_valor_ajustes,0);          935000

            9-. Cf_POR_COMPROMETER = NVL(:CF_DISPONIBILIDAD,0)-NVL(:CF_COMPROMISOS,0);
                                    = 11972019 - 11972019
            10. CF GIROS
      
                mi_valor_op_total := NVL(mi_valor_op,0)             5515000
                                    - NVL(mi_valor_op_anulado,0) 
                                    + NVL(mi_valor_ajustes,0);       935000
                                                                    6450000

            11. CF SIN AUTORIZACION = mi_vlr_sin_autorizar:=NVL(:CF_COMPROMISOS,0)-NVL(:CF_GIROS,0);

*/
 

---------------------
--1. modificaciones
--------------------
select nvl(sum(nvl(modi.valor_credito,0)), 0) - 
         nvl(sum(nvl(modi.valor_contracredito,0)),0) 
  --INTO mi_valor_modificacion
  from pr_modificacion_presupuestal modi
 where modi.codigo_compania = :codigo_compania
   and modi.codigo_unidad_ejecutora = :codigo_unidad_ejecutora
   and modi.vigencia = :vigencia
   and modi.fecha_registro >= :p_fecha_desde
   and modi.fecha_registro <= :p_fecha_hasta
   and modi.rubro_interno = :rubro_interno;
--0

--Apropiación Vigente: Apropiacion Inicial + modificaciones

---------------------
--3. Suspensiones
---------------------
--a. Valor CDP
select * --nvl(sum(nvl(pr_disponibilidad_rubro.valor,0)), 0)  -- INTO mi_valor_cdp
  from pr_confirmacion_suspension,
       pr_disponibilidad_rubro
 where ( ( pr_confirmacion_suspension.vigencia = pr_disponibilidad_rubro.vigencia )
   and ( pr_confirmacion_suspension.codigo_compania = pr_disponibilidad_rubro.codigo_compania )
   and ( pr_confirmacion_suspension.codigo_unidad_ejecutora = pr_disponibilidad_rubro.codigo_unidad_ejecutora )
   and ( pr_confirmacion_suspension.numero_disponibilidad = pr_disponibilidad_rubro.numero_disponibilidad ) )
   and pr_confirmacion_suspension.vigencia = :vigencia
   and pr_confirmacion_suspension.codigo_compania = :codigo_compania
   and pr_confirmacion_suspension.codigo_unidad_ejecutora = :codigo_unidad_ejecutora
   and pr_disponibilidad_rubro.rubro_interno = :rubro_interno
   and pr_confirmacion_suspension.fecha_registro >= :p_fecha_desde
   and pr_confirmacion_suspension.fecha_registro <= :p_fecha_hasta; 
        --0

--b. Calcula el valor de suspensiones levantadas a la fecha
select nvl(sum(nvl(modi.valor_rezago, 0 )), 0) 
  --INTO mi_valor_suspension
  from pr_modificaciones_rezago modi
 where modi.codigo_compania = :codigo_compania
   and modi.codigo_unidad_ejecutora = :codigo_unidad_ejecutora
   and modi.vigencia = :vigencia
   and modi.fecha_registro >= :p_fecha_desde
   and modi.fecha_registro <= :p_fecha_hasta
   and modi.rubro_interno = :rubro_interno;
   --0

  -- c. Calcula el valor de suspensiones utilizadas en reducciones
select nvl(sum(nvl(modi.valor_credito,0)),0) 
      - nvl(sum(nvl(modi.valor_contracredito,0 )), 0)
 -- into mi_valor_modi_reduccion
  from pr_modificacion_presupuestal modi
 where modi.codigo_compania = :codigo_compania
   and modi.codigo_unidad_ejecutora = :codigo_unidad_ejecutora
   and modi.vigencia = :vigencia
   and modi.fecha_registro >= :p_fecha_desde
   and modi.fecha_registro <= :p_fecha_hasta
   and modi.rubro_interno = :rubro_interno
   and modi.tipo_movimiento = 'REDUCCION_SUSPENSION';
 --  0


/*------------------------
5. Disponibilidad 
------------------------*/
  --5.a Calcula el Valor Total de Disponibilidades

SELECT NVL(SUM(NVL(PR_DISPONIBILIDAD_RUBRO.VALOR,0)),0) --INTO mi_valor_disponibilidades
FROM PR_DISPONIBILIDAD_RUBRO, PR_DISPONIBILIDADES
WHERE (PR_DISPONIBILIDAD_RUBRO.NUMERO_DISPONIBILIDAD=PR_DISPONIBILIDADES.NUMERO_DISPONIBILIDAD
 AND PR_DISPONIBILIDAD_RUBRO.CODIGO_UNIDAD_EJECUTORA=PR_DISPONIBILIDADES.CODIGO_UNIDAD_EJECUTORA
 AND PR_DISPONIBILIDAD_RUBRO.CODIGO_COMPANIA=PR_DISPONIBILIDADES.CODIGO_COMPANIA
 AND PR_DISPONIBILIDAD_RUBRO.VIGENCIA=PR_DISPONIBILIDADES.VIGENCIA
 AND PR_DISPONIBILIDAD_RUBRO.CODIGO_UNIDAD_EJECUTORA=:CODIGO_UNIDAD_EJECUTORA
 AND PR_DISPONIBILIDAD_RUBRO.CODIGO_COMPANIA=:CODIGO_COMPANIA
 AND PR_DISPONIBILIDAD_RUBRO.VIGENCIA=:VIGENCIA 
 AND PR_DISPONIBILIDAD_RUBRO.RUBRO_INTERNO=:RUBRO_INTERNO
 AND PR_DISPONIBILIDADES.PARA_SUSPENSION = 0
 AND pr_disponibilidades.fecha_registro >= :P_FECHA_DESDE
 AND pr_disponibilidades.fecha_registro <= :P_FECHA_HASTA);
 -- 11972019

-- Inicio Se inlcuye a julio 2001

--5.b Calcula el Valor Total de Disponibilidades del Mes DE SUSPENSION QUE NO SE HAN APLICADO

SELECT NVL(SUM(NVL(PR_DISPONIBILIDAD_RUBRO.VALOR,0)),0) --INTO mi_valor_cdp_suspension
FROM PR_DISPONIBILIDAD_RUBRO, PR_DISPONIBILIDADES
WHERE (PR_DISPONIBILIDAD_RUBRO.NUMERO_DISPONIBILIDAD=PR_DISPONIBILIDADES.NUMERO_DISPONIBILIDAD
 AND PR_DISPONIBILIDAD_RUBRO.CODIGO_UNIDAD_EJECUTORA=PR_DISPONIBILIDADES.CODIGO_UNIDAD_EJECUTORA
 AND PR_DISPONIBILIDAD_RUBRO.CODIGO_COMPANIA=PR_DISPONIBILIDADES.CODIGO_COMPANIA
 AND PR_DISPONIBILIDAD_RUBRO.VIGENCIA=PR_DISPONIBILIDADES.VIGENCIA
 AND PR_DISPONIBILIDAD_RUBRO.CODIGO_UNIDAD_EJECUTORA=:CODIGO_UNIDAD_EJECUTORA
 AND PR_DISPONIBILIDAD_RUBRO.CODIGO_COMPANIA=:CODIGO_COMPANIA
 AND PR_DISPONIBILIDAD_RUBRO.VIGENCIA=:VIGENCIA
 AND PR_DISPONIBILIDAD_RUBRO.RUBRO_INTERNO=:RUBRO_INTERNO
 AND PR_DISPONIBILIDADES.PARA_SUSPENSION = 1
 AND pr_disponibilidades.fecha_registro >= :P_FECHA_DESDE
 AND pr_disponibilidades.fecha_registro <= :P_FECHA_HASTA)
 AND NOT PR_DISPONIBILIDAD_RUBRO.NUMERO_DISPONIBILIDAD IN
 (SELECT numero_disponibilidad 
 FROM pr_confirmacion_suspension
 WHERE  pr_confirmacion_suspension.vigencia = :vigencia AND 
        pr_confirmacion_suspension.codigo_compania = :codigo_compania AND 
        pr_confirmacion_suspension.codigo_unidad_ejecutora = :codigo_unidad_ejecutora AND 
        pr_disponibilidad_rubro.rubro_interno = :rubro_interno  AND 
        pr_confirmacion_suspension.fecha_registro <= :P_FECHA_HASTA);
--0

 --5.c Anulaciones de CDP del mes efectuadas

SELECT * --NVL(SUM(NVL(PR_DISPONIBILIDAD_RUBRO.VALOR,0)),0) --INTO mi_valor_cdp_anulados
FROM PR_DISPONIBILIDAD_RUBRO, PR_DISPONIBILIDADES
WHERE PR_DISPONIBILIDAD_RUBRO.NUMERO_DISPONIBILIDAD=PR_DISPONIBILIDADES.NUMERO_DISPONIBILIDAD
 AND PR_DISPONIBILIDAD_RUBRO.CODIGO_UNIDAD_EJECUTORA=PR_DISPONIBILIDADES.CODIGO_UNIDAD_EJECUTORA
 AND PR_DISPONIBILIDAD_RUBRO.CODIGO_COMPANIA=PR_DISPONIBILIDADES.CODIGO_COMPANIA
 AND PR_DISPONIBILIDAD_RUBRO.VIGENCIA=PR_DISPONIBILIDADES.VIGENCIA
 AND PR_DISPONIBILIDAD_RUBRO.CODIGO_UNIDAD_EJECUTORA=:CODIGO_UNIDAD_EJECUTORA
 AND PR_DISPONIBILIDAD_RUBRO.CODIGO_COMPANIA=:CODIGO_COMPANIA
 AND PR_DISPONIBILIDAD_RUBRO.VIGENCIA=:VIGENCIA
 AND PR_DISPONIBILIDAD_RUBRO.RUBRO_INTERNO=:RUBRO_INTERNO
 AND pr_disponibilidades.fecha_registro >= :P_FECHA_DESDE
 AND pr_disponibilidades.fecha_registro <= :P_FECHA_HASTA
 AND PR_DISPONIBILIDADES.PARA_SUSPENSION = 0
 AND PR_DISPONIBILIDADES.NUMERO_DISPONIBILIDAD IN (SELECT numero_documento_anulado
                                                      FROM pr_anulaciones
                                                      WHERE vigencia = :vigencia AND
                                                            codigo_compania = :codigo_compania AND
                                                            codigo_unidad_ejecutora = :codigo_unidad_ejecutora AND
                                                            documento_anulado = 'CDP' and 
                                                            fecha_registro >= :P_FECHA_DESDE AND
                                                            fecha_registro <= :P_FECHA_HASTA);
--0

  --5.d Liberaciones Parciales
  SELECT NVL(SUM(NVL(pr_cdp_anulados.valor_anulado,0)),0) --INTO mi_valor_cdp_parciales
  FROM   pr_cdp_anulados
  WHERE  vigencia = :vigencia AND
         codigo_compania = :codigo_compania AND
         codigo_unidad_ejecutora = :codigo_unidad_ejecutora AND
         rubro_interno = :rubro_interno AND
         fecha_anulacion >= :P_FECHA_DESDE AND 
         fecha_anulacion <= :P_FECHA_HASTA AND 
         numero_disponibilidad IN (SELECT numero_disponibilidad 
                             FROM pr_disponibilidades
                             WHERE vigencia = :vigencia AND
                                   codigo_compania = :codigo_compania AND
                                   codigo_unidad_ejecutora = :codigo_unidad_ejecutora AND
                                   para_suspension = 0 AND
                                   fecha_registro >= :P_FECHA_DESDE AND
                                   fecha_registro <= :P_FECHA_HASTA);
--935000
commit;

--5.e cdps autorizados
  SELECT * --NVL(SUM(NVL(pr_cdp_anulados_autorizados.valor_anulado,0)),0) --INTO mi_valor_cdp_autorizados
  FROM   pr_cdp_anulados_autorizados
  WHERE  vigencia = :vigencia AND
         codigo_compania = :codigo_compania AND
         codigo_unidad_ejecutora = :codigo_unidad_ejecutora AND
         rubro_interno = :rubro_interno AND
         fecha_anulacion >= :P_FECHA_DESDE AND
         fecha_anulacion <= :P_FECHA_HASTA AND
         numero_disponibilidad IN (SELECT numero_disponibilidad 
                             FROM pr_disponibilidades
                             WHERE vigencia = :vigencia AND
                                   codigo_compania = :codigo_compania AND
                                   codigo_unidad_ejecutora = :codigo_unidad_ejecutora AND
                                   para_suspension = 0 AND
                                   fecha_registro >= :P_FECHA_DESDE AND
                                   fecha_registro <= :P_FECHA_HASTA);
--0                                   


--5f Ajustes/Reintegros Acumulados  

    SELECT NVL(SUM(NVL(pr_reintegro_ajustes_rubro.valor,0)),0) --INTO mi_valor_ajustes
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
           pr_reintegro_ajustes.cerrado = '0' AND
           pr_reintegro_ajustes.tipo_movimiento = 'AJUSTE' AND
           pr_reintegro_ajustes.fecha_registro >= :P_FECHA_DESDE AND
           pr_reintegro_ajustes.fecha_registro <= :P_FECHA_HASTA ;
--0
--5g Reintegros
 SELECT * --NVL(SUM(NVL(pr_reintegro_ajustes_rubro.valor,0)),0) --INTO mi_valor_reintegro
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
           pr_reintegro_ajustes.fecha_registro >= :P_FECHA_DESDE AND
           pr_reintegro_ajustes.fecha_registro <= :P_FECHA_HASTA AND
           pr_reintegro_ajustes.tipo_movimiento = 'REINTEGRO';
--935000           
---Ver modificacion_presupuesto_reintegro.sql

--5h Se agrego enero 10 de 2002 - Se presenta un cdp de suspension que no se aplico y fue anulado directamente

SELECT NVL(SUM(NVL(PR_DISPONIBILIDAD_RUBRO.VALOR,0)),0)  --into mi_anulacion_cdp_sus_no_apl
FROM PR_DISPONIBILIDAD_RUBRO, PR_DISPONIBILIDADES
WHERE PR_DISPONIBILIDAD_RUBRO.NUMERO_DISPONIBILIDAD=PR_DISPONIBILIDADES.NUMERO_DISPONIBILIDAD
 AND PR_DISPONIBILIDAD_RUBRO.CODIGO_UNIDAD_EJECUTORA=PR_DISPONIBILIDADES.CODIGO_UNIDAD_EJECUTORA
 AND PR_DISPONIBILIDAD_RUBRO.CODIGO_COMPANIA=PR_DISPONIBILIDADES.CODIGO_COMPANIA
 AND PR_DISPONIBILIDAD_RUBRO.VIGENCIA=PR_DISPONIBILIDADES.VIGENCIA
 AND PR_DISPONIBILIDAD_RUBRO.CODIGO_UNIDAD_EJECUTORA=:CODIGO_UNIDAD_EJECUTORA
 AND PR_DISPONIBILIDAD_RUBRO.CODIGO_COMPANIA=:CODIGO_COMPANIA
 AND PR_DISPONIBILIDAD_RUBRO.VIGENCIA=:VIGENCIA
 AND PR_DISPONIBILIDAD_RUBRO.RUBRO_INTERNO=:RUBRO_INTERNO
 AND pr_disponibilidades.fecha_registro >= :P_FECHA_DESDE
 AND pr_disponibilidades.fecha_registro <= :P_FECHA_HASTA
 AND PR_DISPONIBILIDADES.PARA_SUSPENSION = 1
 AND PR_DISPONIBILIDADES.NUMERO_DISPONIBILIDAD IN (SELECT numero_documento_anulado
                                                      FROM pr_anulaciones
                                                      WHERE vigencia = :vigencia AND
                                                            codigo_compania = :codigo_compania AND
                                                            codigo_unidad_ejecutora = :codigo_unidad_ejecutora AND
                                                            documento_anulado = 'CDP' and 
                                                            fecha_registro >= :P_FECHA_DESDE AND
                                                            fecha_registro <= :P_FECHA_HASTA) 
AND NOT PR_DISPONIBILIDAD_RUBRO.NUMERO_DISPONIBILIDAD IN
 (SELECT numero_disponibilidad 
 FROM pr_confirmacion_suspension
 WHERE  pr_confirmacion_suspension.vigencia = :vigencia AND 
        pr_confirmacion_suspension.codigo_compania = :codigo_compania AND 
        pr_confirmacion_suspension.codigo_unidad_ejecutora = :codigo_unidad_ejecutora AND 
        pr_disponibilidad_rubro.rubro_interno = :rubro_interno  AND 
        pr_confirmacion_suspension.fecha_registro <= :P_FECHA_HASTA);
--0



mi_valor_disponib_total := (NVL(mi_valor_disponibilidades,0)+NVL(mi_valor_cdp_suspension,0))
                            -NVL(mi_valor_cdp_anulados,0)-NVL(mi_valor_cdp_parciales,0)
                            -NVL(mi_valor_cdp_autorizados,0)+NVL(mi_valor_ajustes,0)
                            +NVL(mi_valor_reintegro,0)
                            -NVL(mi_anulacion_cdp_sus_no_apl,0);
11972019+935000-9350000


---------------------------
--6. COMPRomISOS
---------------------------

  --6.1 Calcula el Valor Total de Registros

  SELECT NVL(SUM(NVL(pr_registro_disponibilidad.valor,0)),0) 
  --INTO mi_valor_registro
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
         pr_registro_presupuestal.fecha_registro >= :P_FECHA_DESDE AND
         pr_registro_presupuestal.fecha_registro <= :P_FECHA_HASTA;
--11972019         

   -- Anulaciones de RP

  SELECT NVL(SUM(NVL(pr_registro_disponibilidad.valor,0)),0) --INTO mi_valor_rp_anulados
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
         pr_registro_presupuestal.fecha_registro >= :P_FECHA_DESDE AND
         pr_registro_presupuestal.fecha_registro <= :P_FECHA_HASTA AND
         pr_registro_presupuestal.numero_registro IN (SELECT numero_documento_anulado
                                                      FROM pr_anulaciones
                                                      WHERE vigencia = :vigencia AND
                                                            codigo_compania = :codigo_compania AND
                                                            codigo_unidad_ejecutora = :codigo_unidad_ejecutora AND
                                                            documento_anulado = 'REGISTRO' and 
                                                            fecha_registro >= :P_FECHA_DESDE and
                                                            fecha_registro <= :P_FECHA_HASTA);
    0

  -- Liberaciones Parciales

  SELECT NVL(SUM(NVL(pr_rp_anulados.valor_anulado,0)),0) --INTO mi_valor_rp_parciales
  FROM   pr_rp_anulados
  WHERE  vigencia = :vigencia AND
         codigo_compania = :codigo_compania AND
         codigo_unidad_ejecutora = :codigo_unidad_ejecutora AND
         rubro_interno = :rubro_interno AND
         fecha_anulacion >= :P_FECHA_DESDE AND
         fecha_anulacion <= :P_FECHA_HASTA AND
         numero_registro IN (SELECT numero_registro 
                             FROM pr_registro_presupuestal
                             WHERE vigencia = :vigencia AND
                                   codigo_compania = :codigo_compania AND
                                   codigo_unidad_ejecutora = :codigo_unidad_ejecutora AND
                                   fecha_registro >= :P_FECHA_DESDE AND
                                   fecha_registro <= :P_FECHA_HASTA);
    935000

   -- Ajustes/Reintegros Acumulados

    SELECT NVL(SUM(NVL(pr_reintegro_ajustes_rubro.valor,0)),0) --INTO mi_valor_ajustes
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
           pr_reintegro_ajustes.fecha_registro >= :P_FECHA_DESDE AND
           pr_reintegro_ajustes.fecha_registro <= :P_FECHA_HASTA;
    935000

  mi_valor_comprom_total := NVL(mi_valor_registro,0) 
            -  NVL(mi_valor_rp_anulados,0) 
            -  NVL(mi_valor_rp_parciales,0) 
            + NVL(mi_valor_ajustes,0);


---------------------------------
---Giros
---------------------------------            
 -- Valor Total de OP registradas en el mes

  SELECT NVL(SUM(NVL(pr_orden_de_pago_registro.valor,0)),0) ---INTO mi_valor_op
  FROM   pr_orden_de_pago, pr_orden_de_pago_registro
  WHERE (pr_orden_de_pago_registro.consecutivo_orden=pr_orden_de_pago.consecutivo_orden AND
         pr_orden_de_pago_registro.numero_orden=pr_orden_de_pago.numero_orden AND
    		 pr_orden_de_pago_registro.numero_disponibilidad = pr_orden_de_pago.numero_disponibilidad AND
		     pr_orden_de_pago_registro.numero_registro = pr_orden_de_pago.numero_registro AND
         pr_orden_de_pago_registro.codigo_unidad_ejecutora=pr_orden_de_pago.codigo_unidad_ejecutora AND
         pr_orden_de_pago_registro.codigo_compania=pr_orden_de_pago.codigo_compania AND
         pr_orden_de_pago_registro.vigencia=pr_orden_de_pago.vigencia) AND
         pr_orden_de_pago_registro.codigo_compania = :codigo_compania AND
         pr_orden_de_pago_registro.codigo_unidad_ejecutora = :codigo_unidad_ejecutora AND
         pr_orden_de_pago_registro.vigencia = :vigencia AND
         pr_orden_de_pago_registro.rubro_interno = :rubro_interno AND
         pr_orden_de_pago_registro.valor > 0 AND
         pr_orden_de_pago.fecha_registro >= :P_FECHA_DESDE AND
         pr_orden_de_pago.fecha_registro <= :P_FECHA_HASTA;
   ---mi_valor_op 515000

  -- Valor de Ordenes del mes anuladas en el mismos mes

  SELECT NVL(SUM(NVL(pr_orden_de_pago_registro.valor,0)),0) --INTO mi_valor_op_anulado
  FROM   pr_orden_de_pago, pr_orden_de_pago_registro
  WHERE (pr_orden_de_pago_registro.consecutivo_orden=pr_orden_de_pago.consecutivo_orden  AND
         pr_orden_de_pago_registro.numero_orden=pr_orden_de_pago.numero_orden  AND
    		 pr_orden_de_pago_registro.numero_disponibilidad = pr_orden_de_pago.numero_disponibilidad AND
		     pr_orden_de_pago_registro.numero_registro = pr_orden_de_pago.numero_registro AND
         pr_orden_de_pago_registro.codigo_unidad_ejecutora=pr_orden_de_pago.codigo_unidad_ejecutora AND
         pr_orden_de_pago_registro.codigo_compania=pr_orden_de_pago.codigo_compania AND
         pr_orden_de_pago_registro.vigencia=pr_orden_de_pago.vigencia) AND
         pr_orden_de_pago_registro.codigo_compania = :codigo_compania AND
         pr_orden_de_pago_registro.codigo_unidad_ejecutora = :codigo_unidad_ejecutora AND
         pr_orden_de_pago_registro.vigencia = :vigencia AND
         pr_orden_de_pago_registro.rubro_interno = :rubro_interno AND
         (pr_orden_de_pago_registro.numero_orden,pr_orden_de_pago_registro.numero_registro,pr_orden_de_pago_registro.consecutivo_orden)
         IN (SELECT numero_documento_anulado,numero_registro,consecutivo_orden
             FROM pr_anulaciones
             WHERE vigencia = :vigencia AND
             codigo_compania = :codigo_compania AND
             codigo_unidad_ejecutora = :codigo_unidad_ejecutora AND
             documento_anulado = 'ORDEN' and 
             fecha_registro >= :P_FECHA_DESDE and
             fecha_registro <= :P_FECHA_HASTA); 
    0

    -- Ajustes/Reintegros Acumulados

    SELECT NVL(SUM(NVL(pr_reintegro_ajustes_rubro.valor,0)),0) --INTO mi_valor_ajustes
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
           pr_reintegro_ajustes.fecha_registro >= :P_FECHA_DESDE AND
           pr_reintegro_ajustes.fecha_registro <= :P_FECHA_HASTA AND
           pr_reintegro_ajustes.cerrado <> 9;
    
   -- mi_valor_ajustes 93500

    -- Valor de Giros del Mes
    mi_valor_op_total := NVL(mi_valor_op,0) - NVL(mi_valor_op_anulado,0) + NVL(mi_valor_ajustes,0);

--Compromisos sin autorización de giro
