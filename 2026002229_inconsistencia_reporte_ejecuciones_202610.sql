
SELECT  
        pr_1.vigencia,
        codigo_compania,
       codigo_unidad_ejecutora,       
        pr_1.interno,
        vCmprmso,
        vSaldoRP,
--PK_PR_CONSOLIDADOS_RESERVAS.fn_pre_GirosMes(pr_1.vigencia ,codigo_compania ,codigo_unidad_ejecutora , :p_mes ,pr_1.interno ) total_giros_mes,
--PK_PR_CONSOLIDADOS_RESERVAS.fn_pre_GirosAcumulados(pr_1.vigencia ,codigo_compania ,codigo_unidad_ejecutora , :p_mes ,vSaldoRP ,pr_1.interno) total_giros_acum,
0 total_giros_mes,
0 total_giros_acum,
        (PR_NIVEL1.codigo||'-'||
        PR_NIVEL2.codigo||'-'||
        PR_NIVEL3.codigo||'-'||
        PR_NIVEL4.codigo||'-'||
        PR_NIVEL5.codigo||'-'||
        PR_NIVEL6.codigo||'-'||
        PR_NIVEL7.codigo||'-'||
        PR_NIVEL8.codigo) cadena,
        PR_NIVEL1.codigo cadena_nivel1,
        (PR_NIVEL1.codigo||'-'||PR_NIVEL2.codigo) cadena_nivel2,
        (PR_NIVEL1.codigo||'-'||PR_NIVEL2.codigo||'-'||PR_NIVEL3.codigo) cadena_nivel3,
        (PR_NIVEL1.codigo||'-'||PR_NIVEL2.codigo||'-'||PR_NIVEL3.codigo||'-'||PR_NIVEL4.codigo) cadena_nivel4,
        (PR_NIVEL1.codigo||'-'||PR_NIVEL2.codigo||'-'||PR_NIVEL3.codigo||'-'||PR_NIVEL4.codigo||'-'||PR_NIVEL5.codigo) cadena_nivel5,
        (PR_NIVEL1.codigo||'-'||PR_NIVEL2.codigo||'-'||PR_NIVEL3.codigo||'-'||PR_NIVEL4.codigo||'-'||PR_NIVEL5.codigo||'-'||PR_NIVEL6.codigo) cadena_nivel6,
(PR_NIVEL1.codigo||'-'||PR_NIVEL2.codigo||'-'||PR_NIVEL3.codigo||'-'||PR_NIVEL4.codigo||'-'||PR_NIVEL5.codigo||'-'||PR_NIVEL6.codigo||'-'||PR_NIVEL7.codigo) cadena_nivel7,
(PR_NIVEL1.codigo||'-'||PR_NIVEL2.codigo||'-'||PR_NIVEL3.codigo||'-'||PR_NIVEL4.codigo||'-'||PR_NIVEL5.codigo||'-'||PR_NIVEL6.codigo||'-'||PR_NIVEL7.codigo||'-'||PR_NIVEL8.codigo) cadena_nivel8,
       PR_NIVEL1.descripcion descripcion_nivel1,
       PR_NIVEL2.descripcion descripcion_nivel2,
       PR_NIVEL3.descripcion descripcion_nivel3,
       PR_NIVEL4.descripcion descripcion_nivel4,
       PR_NIVEL5.descripcion descripcion_nivel5,
       PR_NIVEL6.descripcion descripcion_nivel6,
       PR_NIVEL7.descripcion descripcion_nivel7,
       PR_NIVEL8.descripcion descripcion_nivel8,
        PR_RUBRO.descripcion,
PR_NIVEL1.codigo codigo_nivel1,
PR_NIVEL2.codigo codigo_nivel2,
PR_NIVEL3.codigo codigo_nivel3,
PR_NIVEL4.codigo codigo_nivel4,
PR_NIVEL5.codigo codigo_nivel5,
PR_NIVEL6.codigo codigo_nivel6,
PR_NIVEL7.codigo codigo_nivel7,
PR_NIVEL8.codigo codigo_nivel8 

--select *
FROM (
SELECT 
               pr.vigencia    ,
              pr.codigo_compania,
              codigo_unidad_ejecutora    ,
               pr.interno     ,
               SUM(vCmprmso) vCmprmso   ,
               (SUM(vSaldo))   vSaldoRP
 FROM
    (
  SELECT
        de.vigencia                     vigencia    ,
        de.codigo_compania              codigo_compania,
        de.codigo_unidad_ejecutora      codigo_unidad_ejecutora    ,
        de.rubro_interno                interno     ,
        'COM'                           tipo        ,
        2                               orden       ,
        ma.fecha_registro               fecha       ,
        TO_CHAR( ma.numero_registro )
                                        nDoc        ,
        NVL(ma.tipo_compromiso || '-'|| TO_CHAR( ma.numero_compromiso )|| '-' || co.objeto,'TEMPO')    detalle,
       0    consecutivo_orden,
        de.valor                        vCmprmso    ,
       /*pk_pr_compromisos.fn_pre_saldo_rp_fc (:P_VIGENCIA-1,:p_compania, :p_unidad, ma.numero_registro, ma.numero_disponibilidad, de.rubro_interno, TO_DATE(TO_CHAR('31-12-'||(:P_VIGENCIA-1)),'DD-MM-YYYY'))
        */  
     0 Vsaldo
      FROM
        PR_COMPROMISOS                  co,
        PR_REGISTRO_PRESUPUESTAL        ma          ,
        PR_REGISTRO_DISPONIBILIDAD      de
      WHERE
         co.vigencia = ma.vigencia                    
        AND co.codigo_compania = ma.codigo_compania              
        AND co.codigo_unidad_ejecutora = ma.codigo_unidad_ejecutora   
        AND co.numero_registro    = ma.numero_registro  
        AND co.numero_compromiso = ma.numero_compromiso  
        AND co.tipo_compromiso = ma.tipo_compromiso  
        and ma.vigencia = de.vigencia                
        AND ma.codigo_compania = de.codigo_compania            
        AND ma.codigo_unidad_ejecutora = de.codigo_unidad_ejecutora   
        AND ma.numero_registro = de.numero_registro       
        AND ma.numero_disponibilidad = de.numero_disponibilidad    
        AND co.vigencia                = ( :P_VIGENCIA-1)
        AND co.codigo_compania         =  :P_COMPANIA
        AND co.codigo_unidad_ejecutora =  :P_UNIDAD
    )   pr	
  WHERE
    pr.VIGENCIA            =   ( :P_VIGENCIA-1)  AND
    pr.CODIGO_COMPANIA     =  :P_COMPANIA  AND
    pr.CODIGO_UNIDAD_EJECUTORA = :P_UNIDAD  
   GROUP BY     pr.vigencia    ,
              pr.codigo_compania,
              pr.codigo_unidad_ejecutora    ,
              pr.interno
   )  pr_1, PR_RUBRO,PR_NIVEL1, PR_NIVEL2, PR_NIVEL3
   ,PR_NIVEL4, PR_NIVEL5,PR_NIVEL6 , PR_NIVEL7, PR_NIVEL8
WHERE pr_1.VIGENCIA=PR_RUBRO.VIGENCIA AND
pr_1.INTERNO=PR_RUBRO.INTERNO AND
PR_RUBRO.vigencia = PR_NIVEL1.vigencia AND
PR_RUBRO.interno_nivel1 = PR_NIVEL1.interno AND
PR_RUBRO.tipo_plan = PR_NIVEL1.tipo_plan AND
PR_RUBRO.vigencia = PR_NIVEL2.vigencia AND
PR_RUBRO.interno_nivel2 = PR_NIVEL2.interno AND
PR_RUBRO.tipo_plan = PR_NIVEL2.tipo_plan AND
PR_RUBRO.vigencia = PR_NIVEL3.vigencia AND
PR_RUBRO.interno_nivel3 = PR_NIVEL3.interno AND
PR_RUBRO.tipo_plan = PR_NIVEL3.tipo_plan AND
PR_RUBRO.vigencia = PR_NIVEL4.vigencia AND
PR_RUBRO.interno_nivel4 = PR_NIVEL4.interno AND
PR_RUBRO.tipo_plan = PR_NIVEL4.tipo_plan AND
PR_RUBRO.vigencia = PR_NIVEL5.vigencia AND
PR_RUBRO.interno_nivel5 = PR_NIVEL5.interno AND
PR_RUBRO.tipo_plan = PR_NIVEL5.tipo_plan AND
PR_RUBRO.vigencia = PR_NIVEL6.vigencia AND
PR_RUBRO.interno_nivel6 = PR_NIVEL6.interno AND
PR_RUBRO.tipo_plan = PR_NIVEL6.tipo_plan AND
PR_RUBRO.vigencia = PR_NIVEL7.vigencia AND
PR_RUBRO.interno_nivel7 = PR_NIVEL7.interno AND
PR_RUBRO.tipo_plan = PR_NIVEL7.tipo_plan AND
PR_RUBRO.vigencia = PR_NIVEL8.vigencia AND
PR_RUBRO.interno_nivel8 = PR_NIVEL8.interno AND
PR_RUBRO.tipo_plan = PR_NIVEL8.tipo_plan AND
pr_1.vigencia = :P_VIGENCIA-1 AND
pr_1.CODIGO_COMPANIA     =  :P_COMPANIA  AND
pr_1.CODIGO_UNIDAD_EJECUTORA = :P_UNIDAD AND  
--pr_1.vSaldoRP <> 0  AND
PR_NIVEL1.codigo = :P_NIVEL1
;
/*-------
-------------*/

SELECT  
        pr_1.vigencia,
        codigo_compania,
       codigo_unidad_ejecutora,       
        pr_1.interno,
        vCmprmso,
        vSaldoRP,
--PK_PR_CONSOLIDADOS_RESERVAS.fn_pre_GirosMes(pr_1.vigencia ,codigo_compania ,codigo_unidad_ejecutora , :p_mes ,pr_1.interno ) total_giros_mes,
--PK_PR_CONSOLIDADOS_RESERVAS.fn_pre_GirosAcumulados(pr_1.vigencia ,codigo_compania ,codigo_unidad_ejecutora , :p_mes ,vSaldoRP ,pr_1.interno) total_giros_acum,
0 total_giros_mes,
0 total_giros_acum,
        (PR_NIVEL1.codigo||'-'||
        PR_NIVEL2.codigo||'-'||
        PR_NIVEL3.codigo||'-'||
        PR_NIVEL4.codigo||'-'||
        PR_NIVEL5.codigo||'-'||
        PR_NIVEL6.codigo||'-'||
        PR_NIVEL7.codigo||'-'||
        PR_NIVEL8.codigo) cadena,
        PR_NIVEL1.codigo cadena_nivel1,
        (PR_NIVEL1.codigo||'-'||PR_NIVEL2.codigo) cadena_nivel2,
        (PR_NIVEL1.codigo||'-'||PR_NIVEL2.codigo||'-'||PR_NIVEL3.codigo) cadena_nivel3,
        (PR_NIVEL1.codigo||'-'||PR_NIVEL2.codigo||'-'||PR_NIVEL3.codigo||'-'||PR_NIVEL4.codigo) cadena_nivel4,
        (PR_NIVEL1.codigo||'-'||PR_NIVEL2.codigo||'-'||PR_NIVEL3.codigo||'-'||PR_NIVEL4.codigo||'-'||PR_NIVEL5.codigo) cadena_nivel5,
        (PR_NIVEL1.codigo||'-'||PR_NIVEL2.codigo||'-'||PR_NIVEL3.codigo||'-'||PR_NIVEL4.codigo||'-'||PR_NIVEL5.codigo||'-'||PR_NIVEL6.codigo) cadena_nivel6,
(PR_NIVEL1.codigo||'-'||PR_NIVEL2.codigo||'-'||PR_NIVEL3.codigo||'-'||PR_NIVEL4.codigo||'-'||PR_NIVEL5.codigo||'-'||PR_NIVEL6.codigo||'-'||PR_NIVEL7.codigo) cadena_nivel7,
(PR_NIVEL1.codigo||'-'||PR_NIVEL2.codigo||'-'||PR_NIVEL3.codigo||'-'||PR_NIVEL4.codigo||'-'||PR_NIVEL5.codigo||'-'||PR_NIVEL6.codigo||'-'||PR_NIVEL7.codigo||'-'||PR_NIVEL8.codigo) cadena_nivel8,
       PR_NIVEL1.descripcion descripcion_nivel1,
       PR_NIVEL2.descripcion descripcion_nivel2,
       PR_NIVEL3.descripcion descripcion_nivel3,
       PR_NIVEL4.descripcion descripcion_nivel4,
       PR_NIVEL5.descripcion descripcion_nivel5,
       PR_NIVEL6.descripcion descripcion_nivel6,
       PR_NIVEL7.descripcion descripcion_nivel7,
       PR_NIVEL8.descripcion descripcion_nivel8,
        PR_RUBRO.descripcion,
PR_NIVEL1.codigo codigo_nivel1,
PR_NIVEL2.codigo codigo_nivel2,
PR_NIVEL3.codigo codigo_nivel3,
PR_NIVEL4.codigo codigo_nivel4,
PR_NIVEL5.codigo codigo_nivel5,
PR_NIVEL6.codigo codigo_nivel6,
PR_NIVEL7.codigo codigo_nivel7,
PR_NIVEL8.codigo codigo_nivel8
FROM (
SELECT 
               pr.vigencia    ,
              pr.codigo_compania,
              codigo_unidad_ejecutora    ,
               pr.interno     ,
               SUM(vCmprmso) vCmprmso   ,
               (SUM(vSaldo))   vSaldoRP
 FROM
    (
  SELECT
        de.vigencia                     vigencia    ,
        de.codigo_compania              codigo_compania,
        de.codigo_unidad_ejecutora      codigo_unidad_ejecutora    ,
        de.rubro_interno                interno     ,
        'COM'                           tipo        ,
        2                               orden       ,
        ma.fecha_registro               fecha       ,
        TO_CHAR( ma.numero_registro )
                                        nDoc        ,
        NVL(ma.tipo_compromiso || '-'|| TO_CHAR( ma.numero_compromiso )|| '-' || co.objeto,'TEMPO')    detalle,
       0    consecutivo_orden,
        de.valor                        vCmprmso    ,
       /*pk_pr_compromisos.fn_pre_saldo_rp_fc (:P_VIGENCIA-1,
                          :p_compania,
                          :p_unidad,
                          ma.numero_registro,
                          ma.numero_disponibilidad,
                          de.rubro_interno,                                               TO_DATE(TO_CHAR('31-12-'||(:P_VIGENCIA-1)),'DD-MM-YYYY'))
*/  
     0 Vsaldo
      FROM
        PR_COMPROMISOS                  co,
        PR_REGISTRO_PRESUPUESTAL        ma          ,
        PR_REGISTRO_DISPONIBILIDAD      de
      WHERE
         co.vigencia = ma.vigencia                    
        AND co.codigo_compania = ma.codigo_compania              
        AND co.codigo_unidad_ejecutora = ma.codigo_unidad_ejecutora   
        AND co.numero_registro    = ma.numero_registro  
        AND co.numero_compromiso = ma.numero_compromiso  
        AND co.tipo_compromiso = ma.tipo_compromiso  
        and ma.vigencia = de.vigencia                
        AND ma.codigo_compania = de.codigo_compania            
        AND ma.codigo_unidad_ejecutora = de.codigo_unidad_ejecutora   
        AND ma.numero_registro = de.numero_registro       
        AND ma.numero_disponibilidad = de.numero_disponibilidad    
        AND co.vigencia                = ( :P_VIGENCIA-1)
        AND co.codigo_compania         =  :P_COMPANIA
        AND co.codigo_unidad_ejecutora =  :P_UNIDAD
    )   pr	
  WHERE
    pr.VIGENCIA            =   ( :P_VIGENCIA-1)  AND
    pr.CODIGO_COMPANIA     =  :P_COMPANIA  AND
    pr.CODIGO_UNIDAD_EJECUTORA = :P_UNIDAD  
   GROUP BY     pr.vigencia    ,
              pr.codigo_compania,
              pr.codigo_unidad_ejecutora    ,
              pr.interno
   )  pr_1, PR_RUBRO,PR_NIVEL1, PR_NIVEL2, PR_NIVEL3,
PR_NIVEL4, PR_NIVEL5,
PR_NIVEL6, PR_NIVEL7, PR_NIVEL8
WHERE pr_1.VIGENCIA=PR_RUBRO.VIGENCIA AND
pr_1.INTERNO=PR_RUBRO.INTERNO AND
PR_RUBRO.vigencia = PR_NIVEL1.vigencia AND
PR_RUBRO.interno_nivel1 = PR_NIVEL1.interno AND
PR_RUBRO.tipo_plan = PR_NIVEL1.tipo_plan AND
PR_RUBRO.vigencia = PR_NIVEL2.vigencia AND
PR_RUBRO.interno_nivel2 = PR_NIVEL2.interno AND
PR_RUBRO.tipo_plan = PR_NIVEL2.tipo_plan AND
PR_RUBRO.vigencia = PR_NIVEL3.vigencia AND
PR_RUBRO.interno_nivel3 = PR_NIVEL3.interno AND
PR_RUBRO.tipo_plan = PR_NIVEL3.tipo_plan AND
PR_RUBRO.vigencia = PR_NIVEL4.vigencia AND
PR_RUBRO.interno_nivel4 = PR_NIVEL4.interno AND
PR_RUBRO.tipo_plan = PR_NIVEL4.tipo_plan AND
PR_RUBRO.vigencia = PR_NIVEL5.vigencia AND
PR_RUBRO.interno_nivel5 = PR_NIVEL5.interno AND
PR_RUBRO.tipo_plan = PR_NIVEL5.tipo_plan AND
PR_RUBRO.vigencia = PR_NIVEL6.vigencia AND
PR_RUBRO.interno_nivel6 = PR_NIVEL6.interno AND
PR_RUBRO.tipo_plan = PR_NIVEL6.tipo_plan AND
PR_RUBRO.vigencia = PR_NIVEL7.vigencia AND
PR_RUBRO.interno_nivel7 = PR_NIVEL7.interno AND
PR_RUBRO.tipo_plan = PR_NIVEL7.tipo_plan AND
PR_RUBRO.vigencia = PR_NIVEL8.vigencia AND
PR_RUBRO.interno_nivel8 = PR_NIVEL8.interno AND
PR_RUBRO.tipo_plan = PR_NIVEL8.tipo_plan AND
NOT EXISTS (SELECT BINTABLAS.RESULTADO 
              FROM BINTABLAS 
                 WHERE BINTABLAS.GRUPO = 'PREDIS' AND 
                          BINTABLAS.NOMBRE = 'CODIGOS_NIVEL' AND 
                         (BINTABLAS.ARGUMENTO = 'RESER_PRESUPUESTALES_N3' OR   
                          BINTABLAS.ARGUMENTO = 'RESERVAS_FUNCIONAMIENTO' OR 
                          BINTABLAS.ARGUMENTO = 'RESERVAS_DEUDA' OR
                          BINTABLAS.ARGUMENTO = 'PASIVOS_EXIGIBLES_N3' OR
                          BINTABLAS.ARGUMENTO = 'PASIVOS_EXIGIBLES_FUNCIONA_N3' OR  /*3-1-5*/  -- Inicio modificación - RQ2013-555  -  17/06/2013
                          BINTABLAS.ARGUMENTO = 'PASIVOS_DEUDA'   /*3-2-7*/   -- Fin modificación - RQ2013-555  -  17/06/2013
                                                                                               ) AND 
                         ((:P_VIGENCIA-1 >= TO_NUMBER(TO_CHAR(vig_inicial,'YYYY')) AND vig_final IS NULL) OR 
                          (:P_VIGENCIA-1 BETWEEN TO_NUMBER(TO_CHAR(vig_inicial,'YYYY')) AND TO_NUMBER(TO_CHAR(vig_final,'YYYY')))) 
                          AND RESULTADO = (PR_NIVEL1.CODIGO||'-'||PR_NIVEL2.CODIGO||'-'||PR_NIVEL3.CODIGO)) AND 
 
pr_1.vigencia = :P_VIGENCIA-1 AND
pr_1.CODIGO_COMPANIA     =  :P_COMPANIA  AND
pr_1.CODIGO_UNIDAD_EJECUTORA = :P_UNIDAD AND  
--pr_1.vSaldoRP <> 0 AND
--PR_NIVEL1.codigo = :P_NIVEL1 
;

select interno, 
 PK_PR_CONSOLIDADOS_RESERVAS.fn_pre_GirosMes(:p_vigencia,
                                             :p_codigo_compania,
                                             :p_codigo_unidad_ejecutora,
                                             :p_mes,
                                             1674) total_giros_mes
from pr_rubro
where vigencia=:p_vigencia -1    
and descripcion like '%Servicios de Seguro Sociales de Riesgos Laborales%'                                           
;

select *
from pr_v_rubros
where descripcion like '%Sueldo%sico%'   --1227 
and vigencia = 2009
;

select vigencia, interno, descripcion
from pr_rubro
where --vigencia in (2008,2009,2025,2026) and 
descripcion like '%Servicios de Seguro Sociales de Riesgos Laborales%'  
;


mi_valor_op_anulado_ogt := OGT_PK_PREDIS.OGT_FN_ANULGIROSMES_RESERVA(una_vigencia + 1,
                                                               un_codigo_compania,
                                                               un_codigo_unidad_ejecutora,
                                                               un_mes,
                                                               un_interno);

SELECT NVL(SUM(VALOR_BRUTO), 0)
      --INTO mi_valor_op
      FROM OGT_INFORMACION_EXOGENA A, OGT_ORDEN_PAGO B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO = B.CONSECUTIVO
       AND A.RUBRO_INTERNO = :un_interno
       AND B.VIGENCIA = TO_CHAR(TO_NUMBER(:una_vigencia) - 1)
          -- AND B.ENTIDAD > '0'
       AND B.UNIDAD_EJECUTORA = :un_codigo_unidad_ejecutora
       AND B.TIPO_DOCUMENTO = 'OP' --:mi_tipo_documento_op
       AND B.ENTIDAD_PRESUPUESTO = :un_codigo_compania
       AND B.TIPO_OP != 2 --:mi_tipo_caja_menor
       AND B.IND_APROBADO = :mi_valor_uno
       AND B.IND_ANULADO = :mi_valor_uno
       AND SUBSTR(B.ESTADO, 9, 1) = :mi_estado_uno
       AND TO_CHAR(B.FECHA_ANULACION, 'MM') = :un_mes
       AND TO_CHAR(B.FECHA_ANULACION, 'YYYY') = TO_CHAR(:una_vigencia);

    SELECT NVL(SUM(VALOR_REGISTRO), 0)
      INTO mi_valor_ra
      FROM OGT_REGISTRO_PRESUPUESTAL A, OGT_RELACION_AUTORIZACION B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO = B.CONSECUTIVO
       AND A.RUBRO_INTERNO = un_interno
       AND B.VIGENCIA = TO_CHAR(TO_NUMBER(una_vigencia) - 1)
       AND B.ENTIDAD = un_codigo_compania
       AND B.UNIDAD_EJECUTORA = un_codigo_unidad_ejecutora
       AND B.TIPO_DOCUMENTO = mi_tipo_documento_ra
       AND B.IND_APROBADO = mi_valor_uno
       AND B.IND_ANULADO = mi_valor_uno
       AND SUBSTR(B.ESTADO, 4, 1) = mi_estado_uno
       AND SUBSTR(B.ESTADO, 9, 1) = mi_estado_uno
       AND TO_CHAR(B.FECHA_ANULACION, 'MM') = un_mes
       AND TO_CHAR(B.FECHA_ANULACION, 'YYYY') = TO_CHAR(una_vigencia)
       AND NVL(A.VALOR_REGISTRO, 0) > mi_valor_cero;
    RETURN(NVL(mi_valor_op, 0) + NVL(mi_valor_ra, 0));