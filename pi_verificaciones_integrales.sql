--CUENTAS DE COBRO EN SISLA
select e.nro_referencia_pago,
       --e.estado eest,
       e.valor_referencia evalor,
       e.centro_costo centro_costo,
       --cc.id ctac_id,
       cc.id_cuenta_cobro,
       cc.codigo_entidad centi,
       --cc.id_encabezado,
       cc.estado cest,
       --cc.valor_capital cvcapital,
       --cc.valor_intereses cvinteres,
      -- e.*,
       --l.id li_id,
      -- l.estado li_est,
       l.interno_persona id_persona, 
       l.valor_capital capital, l.valor_interes interes /*,
       l.*, p.**/
  from sl_pcp_encabezado e,
       sl_pcp_cuenta_cobro cc,
       sl_pcp_liquidaciones l,
       sl_pcp_pago p
 where e.id = cc.id_encabezado
   and cc.id = l.id_det_cuenta_cobro
   and e.nro_referencia_pago = p.nro_referencia_pago
   and e.nro_referencia_pago in ('2025000105'); 


select sum(l.valor_capital)+SUM(l.valor_interes) as total_liquidado
from sl_pcp_encabezado e
inner join  sl_pcp_cuenta_cobro cc on e.id = cc.id_encabezado
inner join sl_pcp_liquidaciones l on cc.id = l.id_det_cuenta_cobro 
--inner join sl_pcp_pago p on e.nro_referencia_pago = p.nro_referencia_pago
and e.nro_referencia_pago in ('2025000105'); 


select *
from sl_pcp_encabezado e
where e.nro_referencia_pago = '2025000105'; 

select *
from sl_pcp_pago p 
order by id desc
where p.nro_referencia_pago = '2025000107';

select sum(cc.valor_capital)+sum(cc.valor_intereses) total_cuentas
from sl_pcp_encabezado e
inner join sl_pcp_cuenta_cobro cc on e.id = cc.id_encabezado
and e.nro_referencia_pago in ('2025000105');


select * --sum(l.valor_capital)+SUM(l.valor_interes) as total_liquidado
from sl_pcp_encabezado e
inner join  sl_pcp_cuenta_cobro cc on e.id = cc.id_encabezado
inner join sl_pcp_liquidaciones l on cc.id = l.id_det_cuenta_cobro 
--inner join sl_pcp_pago p on e.nro_referencia_pago = p.nro_referencia_pago
and e.nro_referencia_pago in ('2025000105'); 

select * --sum(l.valor_capital)+SUM(l.valor_interes) as total_liquidado
from sl_pcp_encabezado e
inner join sl_pcp_pago p on e.nro_referencia_pago = p.nro_referencia_pago
and e.nro_referencia_pago in ('2025000105'); 

select fecha_autorizacion, fecha_autorizacion+
from sl_pcp_pago 
where nro_referencia_pago in ('2025000105'); 

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
      and numero_externo in ( '2025000105')
)
and tipo = 'XYZ'   


  select numero
        from ogt_documento
       where tipo = 'ALE'
        -- and estado = un_estado
         and unte_codigo = 'FINANCIERO'
         and numero_externo = '2025000103';

select * from tab_lch_segui   
where mensaje like 'OGT%'      

OPGET: Fallo al procesar la referencia de pago: 2025000105. 
 Resp: Error al obtener información del pago: 2025000105.ORA-04091: table SL.SL_PCP_PAGO is mutating, trigger/function may not see it
 No encuentro registros de pago para la referencia de pago 2025000105


GRANT CREATE JOB TO SL; 
GRANT MANAGE SCHEDULER TO SL;
SELECT * FROM user_sys_privs WHERE privilege LIKE '%JOB%';