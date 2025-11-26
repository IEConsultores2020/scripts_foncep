--Acta
select * from 
 ogt_documento
 where tipo = 'ALE'
   --and estado = 'RE'
   and unte_codigo = 'FINANCIERO'
   and numero in (57097,52679)
;

--Documento
select * from 
 ogt_documento
 where numero_legal in (
   select numero
     from ogt_documento
    where tipo = 'ALE'
      --and estado='RE'
      and unte_codigo = 'FINANCIERO'
      and numero in ( 57097,52679)
)
   and tipo = 'XYZ'
   --and estado = 'RE'
   ;

--Detalle Documento
select * from
 ogt_detalle_documento 
 where doc_numero||'-'||doc_tipo in (
   select numero ||'-'||tipo
     from ogt_documento
    where numero_legal in (
      select numero
        from ogt_documento
       where tipo = 'ALE'
          --and estado='RE'
         and unte_codigo = 'FINANCIERO'
         and numero in ( 57097,52679)
   )
      and tipo = 'XYZ'
)
   and doc_tipo = 'XYZ'
        --and estado = 'RE'
   ;

select *
  from (
   select id,
          descripcion
     from ogt_concepto_tesoreria
    where afecta_ingreso <> 8
      and concepto_hoja = 1
      and fecha_final is null connect by
      prior id = cote_id
   start with id = (
      select id
        from ogt_concepto_tesoreria
       where cote_id is null
         and rownum = 1
   )
) t
 where id in ( '00-01-02-10-03-46-00',
               '00-01-02-10-03-18-00' )
 order by descripcion;

 select id, descripcion, interno_rubro, fecha_inicial, compania
 from ogt_concepto_tesoreria 
  where id in ( '00-01-02-10-03-46-00',
               '00-01-02-10-03-18-00' )
 order by descripcion



