--Q1
SELECT       doc.numero   numero_soporte,
                     doc.tipo         tipo_soporte,
                     doc.fecha_compra_titulo      fecha_recaudo,
                     doc.fecha_emision_titulo      mes_recaudo,
                     doc.ter_id_receptor  id_receptor,
                     doc.cuba_numero numero_cuenta
    FROM      ogt_documento doc,ogt_ingreso ing
 WHERE      ing.doc_numero=doc.numero
       AND      ing.doc_tipo=doc.tipo
       AND      ing.tipo_doc_legalizacion = :tipo_acta 
       AND      ing.num_doc_legalizacion =:numero_acta
       AND      ing.unte_codigo=:CF_UNIDAD
GROUP BY  doc.ter_id_receptor ,doc.cuba_numero,doc.numero, doc.tipo,
               doc.fecha_compra_titulo,doc.fecha_emision_titulo 


select sysdate from dual
--Q2
SELECT      doc.numero  numero_acta,
                    doc.tipo    tipo_acta,
                    doc.fecha fecha_acta,
                    doc.observaciones                   
   FROM       ogt_documento doc
WHERE      doc.numero= :p_numero
       AND     doc.tipo=:p_tipo
       AND     unte_codigo= :CF_UNIDAD


--Q3
        SELECT   ing.cote_id codigo_concepto,sum(ing.valor)  total_concepto
           FROM   ogt_ingreso   ing
        WHERE   ing.num_doc_legalizacion = :numero_acta
              AND   ing.tipo_doc_legalizacion= :tipo_acta
              AND   ing.unte_codigo=:CF_UNIDAD
GROUP BY    ing.cote_id
