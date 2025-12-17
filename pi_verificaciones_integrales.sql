select sum(l.valor_capital)+SUM(l.valor_interes) as total_liquidado
from sl_pcp_encabezado e
inner join  sl_pcp_cuenta_cobro cc on e.id = cc.id_encabezado
inner join sl_pcp_liquidaciones l on cc.id = l.id_det_cuenta_cobro 
--inner join sl_pcp_pago p on e.nro_referencia_pago = p.nro_referencia_pago
and e.nro_referencia_pago in ('2025000103'); 


select *
from sl_pcp_encabezado e
where e.nro_referencia_pago = '2025000313'; 

select sum(cc.valor_capital)+sum(cc.valor_intereses) total_cuentas
from sl_pcp_encabezado e
inner join sl_pcp_cuenta_cobro cc on e.id = cc.id_encabezado
and e.nro_referencia_pago in ('2025000103');


select * --sum(l.valor_capital)+SUM(l.valor_interes) as total_liquidado
from sl_pcp_encabezado e
inner join  sl_pcp_cuenta_cobro cc on e.id = cc.id_encabezado
inner join sl_pcp_liquidaciones l on cc.id = l.id_det_cuenta_cobro 
inner join sl_pcp_pago p on e.nro_referencia_pago = p.nro_referencia_pago
and e.nro_referencia_pago in ('2025000103'); 

select * --sum(l.valor_capital)+SUM(l.valor_interes) as total_liquidado
from sl_pcp_encabezado e
inner join sl_pcp_pago p on e.nro_referencia_pago = p.nro_referencia_pago
and e.nro_referencia_pago in ('2025000103'); 

select *
from sl_pcp_pago 
where nro_referencia_pago in ('2025000103'); 

----Cunsultar el acta del radicado
select * from 
 ogt_documento
 where tipo = 'ALE'
   and estado = 'RE'
   and unte_codigo = 'FINANCIERO'
   and numero_externo in ( '2025000103') 
   and extract(year from fecha) in ( 2025 );

---Consultar los documentos asociados al acta
select * from 
 ogt_documento
 where numero_legal in (
   select numero
     from ogt_documento
    where tipo = 'ALE'
      --and estado='RE'
      and unte_codigo = 'FINANCIERO'
      and numero_externo in ( '2025000103')
)
and tipo = 'XYZ'   


  select numero
        from ogt_documento
       where tipo = 'ALE'
        -- and estado = un_estado
         and unte_codigo = 'FINANCIERO'
         and numero_externo = '2025000103';