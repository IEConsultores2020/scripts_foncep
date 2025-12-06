--Borra info cuenta
delete --select *  from 
 ogt_info_cuenta
 where dein_cuco_codigo|| ''|| dein_ing_id||''||dein_id in 
 (select cuco_codigo   ||''||       ing_id||''|| id
   from ogt_detalle_ing --where valor in (70000,55000,150000,10000) order by id desc
    where ing_id in (
      select  id
        from ogt_ingreso
        -- where fecha_consignacion >= to_Date('01/10/2025','dd/mm/yyyy'))
        where doc_numero||'-' || doc_tipo in (
          select distinct numero|| '-'|| tipo
            from ogt_documento
          where numero_legal in (
            select numero
              from ogt_documento
              where tipo = 'ALE'
                        --and estado='RE'
                and unte_codigo = 'FINANCIERO'
                --and numero in ( 55503) --,  54861)
                and numero_externo in ('2025000001') --,'2025000003','2025000012')
          )
            -- and tipo = 'XYZ'
                    --and estado = 'RE'
      )
    )
);

delete --select * from 
ogt_detalle_pensionado
where doc_numero||'-'||doc_tipo in
    (
      select numero||'-'|| tipo
        from ogt_documento
        where numero_legal in (
          select numero
            from ogt_documento
          where tipo = 'ALE'
                    --and estado='RE'
            and unte_codigo = 'FINANCIERO'
            --and numero in ( 55503) --,  54861 )
            and numero_externo in ( '2025000001') --/*, '2025000003',    '2025000012' */)
      )
          and tipo = 'XYZ'
    )
;


--Borra Detalle ingreso
delete --select * from 
 ogt_detalle_ing --where valor in (70000,55000,150000,10000) order by id desc
 where ing_id in (
   select id
     from ogt_ingreso
    -- where fecha_consignacion >= to_Date('01/10/2025','dd/mm/yyyy'))
    where doc_numero||'-' || doc_tipo in (
      select distinct numero|| '-'|| tipo
        from ogt_documento
       where numero_legal in (
         select numero
           from ogt_documento
          where tipo = 'ALE'
                    --and estado='RE'
            and unte_codigo = 'FINANCIERO'
            --and numero in ( 55503) --, 54861)
            and numero_externo in ('2025000001') --,'2025000003','2025000012')
      )
        -- and tipo = 'XYZ'
                --and estado = 'RE'
   )
);



--Borra ingreso
delete --select * from   
 ogt_ingreso --where num_doc_legalizacion = 55502
 --order by id desc  borrar los de fecha consignacion con mm/yyyy 11/2025
 --where doc_numero = 98114
 where doc_numero       || '-'       || doc_tipo in (  --'98113-XYZ','98114-XYZ')
   select distinct doc_numero                   || '-'                   || doc_tipo
     from ogt_detalle_documento 
          --where doc_numero in ('55502','54861') --'55503'
    where doc_numero          || '-'          || doc_tipo in (
      select numero             || '-'             || tipo
        from ogt_documento
       where numero_legal in (
         select numero
           from ogt_documento
          where tipo = 'ALE'
                          --and estado='RE'
            and unte_codigo = 'FINANCIERO'
            --and numero in ( 55503)--, 54861 )
            and numero_externo in ( '2025000001'/*,'2025000003',   '2025000012'*/ )
      )
         and tipo = 'XYZ'
   )
      and doc_tipo = 'XYZ'
                      --and estado = 'RE'
);


--Borra detalle documentos
delete --select * from
 ogt_detalle_documento 
--where doc_numero in ('55502','54861') --'55503'
 where doc_numero||'-'||doc_tipo in (
   select numero ||'-'||tipo
     from ogt_documento
    where numero_legal in (
      select numero
        from ogt_documento
       where tipo = 'ALE'
         --and estado='RE'
         and unte_codigo = 'FINANCIERO'
        --and numero in ( 55503) --, 54861 )
         and numero_externo in ( '2025000001'/*, '2025000003', '2025000012'*/ )
   )
      and tipo = 'XYZ'
)
   and doc_tipo = 'XYZ'
  --and estado = 'RE'
   ;


--Borra documentos
delete --select * from 
 ogt_documento
 where numero_legal in (
   select numero
     from ogt_documento
    where tipo = 'ALE'
      --and estado='RE'
      and unte_codigo = 'FINANCIERO'
      --and numero in ( 55503) --, 54861 )
      and numero_externo in ( '2025000001')--,'2025000003','2025000012' )
)
   and tipo = 'XYZ'
   --and estado = 'RE'
   ;

---Borra actas
delete --select * from 
 ogt_documento
 where tipo = 'ALE'
   and estado = 'RE'
   and unte_codigo = 'FINANCIERO'
   --and numero in (55503,55503,54861)
   and numero_externo in ( '2025000001') /*,'2025000003', '2025000012' )*/
   and extract(year from fecha) in ( 2025 );


--rollback;

--commit;
