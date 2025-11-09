--Borra info cuenta
delete --select *  from 
 ogt_info_cuenta
 where dein_cuco_codigo
       || ''
       || dein_ing_id
       || ''
       || dein_id in (
   select cuco_codigo
          || ''
          || ing_id
          || ''
          || id
     from ogt_detalle_ing
    where ing_id in (
      select id
        from ogt_ingreso
       where doc_numero
             || '-'
             || doc_tipo in (
         select numero_legal
                || '-'
                || tipo
           from ogt_documento
          where numero_legal in (
            select numero
              from ogt_documento
             where tipo = 'ALE'
                            --and estado='RE'
               and unte_codigo = 'FINANCIERO'
               and numero in ( 55502,
                               55503/*,
                               54861 */ )
                    --and numero_externo in ('2025000001','2025000003','2025000012')
         )
            and tipo = 'XYZ'
                        --and estado = 'RE'
      )
   )
);

--Borra Detalle ingreso
delete --select * from 
 ogt_detalle_ing
 where ing_id in (
   select id
     from ogt_ingreso
    where doc_numero
          || '-'
          || doc_tipo in (
      select numero_legal
             || '-'
             || tipo
        from ogt_documento
       where numero_legal in (
         select numero
           from ogt_documento
          where tipo = 'ALE'
                    --and estado='RE'
            and unte_codigo = 'FINANCIERO'
            and numero in ( 55502,
                            55503/*
                            54861*/ )
            --and numero_externo in ('2025000001','2025000003','2025000012')
      )
         and tipo = 'XYZ'
                --and estado = 'RE'
   )
);

--Borra ingreso
delete --select * from   
 ogt_ingreso
 where doc_numero
       || '-'
       || doc_tipo in (
   select numero_legal
          || '-'
          || tipo
     from ogt_documento
    where numero_legal in (
      select numero
        from ogt_documento
       where tipo = 'ALE'
                --and estado='RE'
         and unte_codigo = 'FINANCIERO'
         and numero in ( 55502,
                         55503/*,
                         54861 */ )
                --and numero_externo in ('2025000001','2025000003','2025000012')
   )
      and tipo = 'XYZ'
            --and estado = 'RE'
);


--Borra detalle documentos
delete --select * from
 ogt_detalle_documento 
--where doc_numero in ('55502','54861') --'55503'
 where doc_numero
       || '-'
       || doc_tipo in (
   select numero
          || '-'
          || tipo
     from ogt_documento
    where numero_legal in (
      select numero
        from ogt_documento
       where tipo = 'ALE'
            --and estado='RE'
         and unte_codigo = 'FINANCIERO'
         and numero in ( 55502,
                         55503,
                         54861 )
            --and numero_externo in ('2025000001','2025000003','2025000012')
   )
      and tipo = 'XYZ'
        --and estado = 'RE'
);

--Borra documentos
delete --select * from 
 ogt_documento
 where numero_legal in (
   select numero
     from ogt_documento
    where tipo = 'ALE'
      --and estado='RE'
      and unte_codigo = 'FINANCIERO'
      and numero in ( 55502/*,
                      55503,
                      54861 */ )
      --and numero_externo in ('2025000001','2025000003','2025000012')
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
   --and numero in (55502,55503,54861)
   and numero_externo in ( '2025000001',
                           '2025000003',
                           '2025000012' )
   and extract(year from fecha) in ( 2025 );

commit;