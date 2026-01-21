SELECT ' '||pk_sit_infbasica.sit_fn_nombre( ing.cuba_sucu_ter_id,SYSDATE) receptor, 
' '|| pk_sit_infbasica.SIT_FN_NUM_IDENTIFICACION (ing.ter_id,SYSDATE)     ide_tercero_origen, 
' '|| pk_sit_infbasica.sit_fn_nombre( ing.ter_id,SYSDATE)                 tercero_origen,
' '|| ing.cuba_numero                                                     cuenta,
' '||pk_sit_infbasica.sit_fn_nombre( ing.ter_id_destino,SYSDATE)          tercero_destino,
ing.valor                                                                 valor ,
to_number(ing.num_doc_legalizacion)                                       numero_acta,
ing.doc_numero numero_soporte,ing.doc_tipo                                tipo_soporte,
ing.cote_id                                                               codigo_concepto,
doc.fecha_compra_titulo                                                   fecha_consigna,
ing.fecha_consignacion                                                    fecha_acta,
ing.ter_id_destino                                                        id_destino,
' '||pk_sit_infbasica.sit_fn_nombre( det.ter_id_recaudador,SYSDATE)       tercero_recaudador,
det.fecha_recaudo                                                         fecha_recaudo,
det.centro_costo,
det.NUMERO_SISLA, 
det.ESTADO_SISLA
FROM       ogt_ingreso ing,ogt_documento doc,ogt_detalle_documento det
WHERE    doc.tipo=ing.doc_tipo
       AND   doc.numero=ing.doc_numero
      AND    det.doc_tipo=ing.doc_tipo
       AND   det.doc_numero=ing.doc_numero
       AND   det.ter_id_destino=ing.ter_id_destino
       AND   det.cote_id=ing.cote_id
      --ini condicion
        AND    ing.cote_id like '%' 
        AND  ing.fecha_consignacion>=to_date('20-01-2026','DD-MM-YYYY') 
        AND    ing.fecha_consignacion<=to_date('21-01-2026 ','DD-MM-YYYY')
        and extract(year from fecha_consignacion)=2026
        --and to_number(ing.num_doc_legalizacion) = 55546
      --fin condicion
      AND     doc.tipo_legal='ALE'
      AND    ing.tipo_doc_legalizacion='ALE' 
      AND    ing.unte_codigo='FINANCIERO' 
      ;


    -- 