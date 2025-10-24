

select  from dual;

select *
from rh_personas
where  nombres like 'MARGARITA%' --numero_identificacion= 79693028
;


    select substr(DESCRIPCION,1,20)
    from ogt_concepto_tesoreria
    where id = :concepto;

    --Consulta del acta
    select *
    from ogt_documento
    where numero in (15617,54948)
      and tipo_legal = 'ALE' 
      and unte_codigo = 'FINANCIERO'
        ;

    --Consulta documento
    select * -- numero, numero_legal, numero_soporte   --54861 56715
    from ogt_documento
    where numero /*is not null --*/ not  in (56896, 56898, 56900, 56901, 56903, 56904 ,56905)
    and extract(year from fecha) = 2025
    ;
    /*
    '56896' in (numero_soporte,numero_legal) 
      or '54948' in (numero_soporte,numero_legal)
      and tipo_legal = 'ALE' 
        ;        */
        --or '54948'=numero_legal;

    select *
    from ogt_detalle_documento
    where 54948 = doc_numero ;

    select *
    from ogt_ingreso
    where doc_numero = '54948'
    and doc_tipo ='XYZ';

    select *
    from 
    where numero_identificacion in (1030592799,79693028,20730522);

    SELECT NVL(ing.cuba_tipo,'0'),
          NVL(ing.cote_id,'0'),
          NVL(ing.unte_codigo,'0'),
          NVL(ing.ter_id,0),
          NVL(ing.tipo_titulo,'0'),
          ing.valor,
          NVL(doc.bin_tipo_emisor_titulo,'0'), 
          DECODE('INGRESO' /*mi_tipo_transaccion_contable*/,'NO_AJUSTE',ing.doc_numero,ing.num_doc_legalizacion),
          DECODE('INGRESO' /*mi_tipo_transaccion_contable*/,'NO_AJUSTE',ing.doc_tipo,ing.tipo_doc_legalizacion),
          ing.ter_id_destino, 
          ing.vigencia,
          ing.fecha_consignacion,
          ing.ing_id,
          NVL(ing.cuba_numero,'0'),
          NVL(ing.cuba_sucu_ter_id,0),
          --RQ1885-2006 07-11-2006 campos para reintegros-reembolsos
          doc.tipo_soporte,
          doc.numero_soporte,
          doc.fecha_soporte
     FROM ogt_ingreso ing,
          ogt_documento doc
    WHERE DECODE('INGRESO' /*mi_tipo_transaccion_contable*/,'NO_AJUSTE',ing.doc_numero,ing.num_doc_legalizacion) = doc.numero
      AND DECODE('INGRESO' /*mi_tipo_transaccion_contable*/,'NO_AJUSTE',ing.doc_tipo,ing.tipo_doc_legalizacion) = doc.tipo
      AND ing.id = 507179; -- un_ingreso;    


    select *
    from ogt_detalle_pensionado;

select id
from ogt_concepto_tesoreria;


  select cod_centro_costo
        from ogt_tercero_cc;