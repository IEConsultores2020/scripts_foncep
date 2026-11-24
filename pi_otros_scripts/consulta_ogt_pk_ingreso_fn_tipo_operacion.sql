--De función tipo operación

--CURSOR cur_tipo_ingreso IS
   SELECT NVL(ing.cuba_tipo,'0')            mi_tipo_cuenta_bancaria,
          NVL(ing.cote_id,'0')              mi_concepto_ingreso,
          NVL(ing.unte_codigo,'0')          mi_unidad_ingreso,
          NVL(ing.ter_id,0)                   mi_tercero,
          NVL(ing.tipo_titulo,'0')            mi_tipo_titulo,
          ing.valor                           mi_valor,
          NVL(doc.bin_tipo_emisor_titulo,'0') mi_tipo_emisor,
          DECODE('LEGALIZACION PORTALP' /*mi_tipo_transaccion_contable*/,'NO_AJUSTE',ing.doc_numero,ing.num_doc_legalizacion)
                                              mi_doc_numero,
          DECODE('LEGALIZACION PORTALP' /*mi_tipo_transaccion_contable*/,'NO_AJUSTE',ing.doc_tipo,ing.tipo_doc_legalizacion)
                                              mi_doc_tipo,
          ing.ter_id_destino                  mi_tercero_destino,
          ing.vigencia                        mi_vigencia_ingreso,
          ing.fecha_consignacion              mi_fecha_consignacion,
          ing.ing_id                          mi_ingreso_id,
          NVL(ing.cuba_numero,'0')            mi_numero_cuenta,
          NVL(ing.cuba_sucu_ter_id,0)         mi_entidad_financiera,
          --RQ1885-2006 07-11-2006 campos para reintegros-reembolsos
          doc.tipo_soporte                    mi_tipo_acta,
          doc.numero_soporte                  mi_consecutivo_acta,
          doc.fecha_soporte                   mi_fecha_acta
     FROM ogt_ingreso ing,
          ogt_documento doc
    WHERE DECODE('LEGALIZACION PORTALP' /*mi_tipo_transaccion_contable*/,'NO_AJUSTE',ing.doc_numero,ing.num_doc_legalizacion) = doc.numero
      AND DECODE('LEGALIZACION PORTALP' /*mi_tipo_transaccion_contable*/,'NO_AJUSTE',ing.doc_tipo,ing.tipo_doc_legalizacion) = doc.tipo
      AND ing.id in 
      (
        --= un_ingreso;

--Cursor ingresos 
 /*cursor cursor_ingresos (
         pc_nro_referencia_pago varchar2
      ) is*/      
      select id   --ogt_ingreso.*
        from ogt_ingreso
      --where id = 608377
       where doc_numero||'-'|| doc_tipo in 
        (
         select distinct doc_numero||'-'|| doc_tipo
           from ogt_detalle_documento 
               --where doc_numero in ('55502','54861') --'55503'
          where doc_numero|| '-'||doc_tipo in 
            (select numero|| '-'|| tipo
              from ogt_documento
             where numero_legal in 
                (
                select numero
                    from ogt_documento
                    where tipo = 'ALE'
                    --and estado='RE'
                    and unte_codigo = 'FINANCIERO'
                    --and numero in ( 55502, 55503,  54861 )
                    and numero_externo = '2026000525'  --628360
                )  
                and tipo = 'XYZ'
            )  
            and doc_tipo = 'XYZ'
                           --and estado = 'RE'
      ) --order by id desc
      
      );
