select e.id, e.nro_referencia_pago, e.estado
from sl_pcp_encabezado e
where e.nro_referencia_pago in ('2026000524','2026000525')
;

update sl_pcp_encabezado e
set e.estado='REG'
where e.nro_referencia_pago in ('2026000524','2026000525','2026000526')
;

--commit;

select *
from SL_PCP_PAGO


--CUENTAS DE COBRO EN SISLA
select e.nro_referencia_pago,
       e.estado eest,
       e.valor_referencia evalor,
       e.centro_costo centro_costo,
       --cc.id ctac_id,
       cc.id_cuenta_cobro,
       cc.codigo_entidad centi,
       cc.id_encabezado,
       cc.estado cest,
       --cc.valor_capital cvcapital,
       --cc.valor_intereses cvinteres,
      -- e.*,
       l.id li_id,
      -- l.estado li_est,
       l.interno_persona id_persona, 
       l.valor_capital capital, l.valor_interes interes,
       p.id_banco --, l.*
      -- select l.*
  from sl_pcp_encabezado e,
      sl_pcp_cuenta_cobro cc,
       sl_pcp_liquidaciones l,
       sl_pcp_pago p
 where e.id = cc.id_encabezado
   and cc.id = l.id_det_cuenta_cobro
   and e.nro_referencia_pago = p.nro_referencia_pago
  -- and e.estado not in 'IMP'
  and e.nro_referencia_pago IN ('2026000524','2026000525','2026000526')
  -- order by e.nro_referencia_pago desc
;

select *
from sl_pcp_liquidaciones l
order by id_factura, id_det_cuenta_cobro, interno_persona
;

   select * from  sl_pcp_cuenta_cobro cc
;

   select id_sisla, id_tercero
   from SL_RELACION_TERCEROS
   where id_sisla in (16791,47125)

   update sl_pcp_pago
   set id_banco = 49
   where id_banco = 51;

   commit;

select sum(l.valor_capital)+SUM(l.valor_interes) as total_liquidado
from sl_pcp_encabezado e
inner join  sl_pcp_cuenta_cobro cc on e.id = cc.id_encabezado
inner join sl_pcp_liquidaciones l on cc.id = l.id_det_cuenta_cobro 
--inner join sl_pcp_pago p on e.nro_referencia_pago = p.nro_referencia_pago
and e.nro_referencia_pago in ('2026000211'); 


select *
from sl_pcp_encabezado e
where e.nro_referencia_pago = '2026000211'; 

select *
from sl_pcp_pago p 
where p.nro_referencia_pago = '2026000211';

select sum(cc.valor_capital)+sum(cc.valor_intereses) total_cuentas
from sl_pcp_encabezado e
inner join sl_pcp_cuenta_cobro cc on e.id = cc.id_encabezado
and e.nro_referencia_pago in ('2026000211');


select * --sum(l.valor_capital)+SUM(l.valor_interes) as total_liquidado
from sl_pcp_encabezado e
inner join  sl_pcp_cuenta_cobro cc on e.id = cc.id_encabezado
inner join sl_pcp_liquidaciones l on cc.id = l.id_det_cuenta_cobro 
--inner join sl_pcp_pago p on e.nro_referencia_pago = p.nro_referencia_pago
and e.nro_referencia_pago in ('2026000211'); 

select * --sum(l.valor_capital)+SUM(l.valor_interes) as total_liquidado
from sl_pcp_encabezado e
inner join sl_pcp_pago p on e.nro_referencia_pago = p.nro_referencia_pago
and e.nro_referencia_pago in ('2026000211'); 

select fecha_autorizacion, fecha_autorizacion
from sl_pcp_pago 
where nro_referencia_pago in ('2026000211'); 

----Cunsultar el acta del radicado
select numero_externo from 
 ogt_documento
 where tipo = 'ALE'
   and estado = 'RE'
   and unte_codigo = 'FINANCIERO'
   --and*/ numero_externo like '2026000427%' --in ( '2026000211') 
   and extract(year from fecha) in ( 2026 );

---Consultar el acta asociados a una referencia de pago
select numero, tipo, estado, fecha,numero_legal from 
 ogt_documento
 where numero_legal in (
   select numero
     from ogt_documento
    where tipo = 'ALE'
      --and estado='RE'
      and unte_codigo = 'FINANCIERO'
      and numero_externo in ( '2026000524','2026000525')
)
and tipo = 'XYZ'   
;

----Consultar al actas de un día mes.
select * --numero acta, numero_externo factura, estado, fecha
from ogt_documento
 where tipo = 'ALE'
   --and estado = 'RE'
   and unte_codigo = 'FINANCIERO'
   and numero_externo = nvl(:factura,numero_externo) --'2026000358' 
   and extract(year from fecha) in nvl(:agno,extract(year from fecha))
   and extract(month from fecha) in nvl(:mes,extract(month from fecha))
   and extract(day from fecha) in nvl(:dd,extract(day from fecha))
   ;


--Consultar el acta con su factura, cuenta de cobro 
select d.numero acta, d.numero_externo factura, tsl.id_cuenta_cobro cta_cobro,
    d.estado Eacta, tsl.estado Efctra,
    d.fecha fecha_acta, tsl.fecha_sistema fecha_factura, 
     tsl.codigo_entidad entdd, valor_capital "$K", valor_intereses "$i"
-- select  * 
from ogt_documento d
join
  (
    select e.nro_referencia_pago, e.estado, e.fecha_vencimiento, cc.codigo_entidad, cc.id_cuenta_cobro,
      l.interno_persona, e.fecha_sistema, cc.valor_capital, cc.valor_intereses
    -- select l.*
    from sl_pcp_encabezado e
    join sl_pcp_cuenta_cobro cc on e.id = cc.id_encabezado
    join sl_pcp_liquidaciones l on cc.id = l.id_det_cuenta_cobro
    join sl_pcp_pago p on e.nro_referencia_pago = p.nro_referencia_pago
    where  e.nro_referencia_pago = nvl(:factura,e.nro_referencia_pago) --'2026000358' 
    and cc.id_cuenta_cobro = nvl(:cuenta_cobro,cc.id_cuenta_cobro)
    and extract(year from e.fecha_sistema) = nvl(:agno,extract(year from e.fecha_sistema))
    and extract(month from e.fecha_sistema) = nvl(:mes,extract(month from e.fecha_sistema))
    and extract(day from e.fecha_sistema) = nvl(:dd,extract(day from e.fecha_sistema))
    ) tsl on tsl.fecha_sistema <= d.fecha and d.numero_externo = tsl.nro_referencia_pago
 where d.tipo = 'ALE'
   and d.unte_codigo = 'FINANCIERO'
   and d.estado = nvl(:estado_acta_RE_AP,d.estado)
 order by 1,2,3 
   ;

--Consultar el acta con su factura, cuenta de cobro, liquidación y pensionado
select d.numero acta, d.numero_externo factura, tsl.id_cuenta_cobro,
    d.estado Eacta, tsl.estado Efctra,
    d.fecha fecha_acta, tsl.fecha_sistema fecha_factura, 
     tsl.codigo_entidad entdd, valor_capital "$K", valor_intereses "$i", 
    interno_persona Prsona, --fini_pens,
     k_pens "$k_pens", i_pens "$i_pens"
-- select  * 
from ogt_documento d
join
  (
    select e.nro_referencia_pago, e.estado, e.fecha_vencimiento, cc.codigo_entidad, cc.id_cuenta_cobro,
      l.interno_persona, e.fecha_sistema, cc.valor_capital, cc.valor_intereses, 
       l.fecha_periodo_ini fini_pens, l.valor_capital k_pens, l.valor_interes i_pens
    -- select l.*
    from sl_pcp_encabezado e
    join sl_pcp_cuenta_cobro cc on e.id = cc.id_encabezado
    join sl_pcp_liquidaciones l on cc.id = l.id_det_cuenta_cobro
    join sl_pcp_pago p on e.nro_referencia_pago = p.nro_referencia_pago
    where  e.nro_referencia_pago = nvl(:factura,e.nro_referencia_pago) --'2026000358' 
    and cc.id_cuenta_cobro = nvl(:cuenta_cobro,cc.id_cuenta_cobro)
    and extract(year from e.fecha_sistema) = nvl(:agno,extract(year from e.fecha_sistema))
    and extract(month from e.fecha_sistema) = nvl(:mes,extract(month from e.fecha_sistema))
    and extract(day from e.fecha_sistema) = nvl(:dd,extract(day from e.fecha_sistema))
    ) tsl on tsl.fecha_sistema <= d.fecha and d.numero_externo = tsl.nro_referencia_pago
 where d.tipo = 'ALE'
   and d.unte_codigo = 'FINANCIERO'
   and d.estado = nvl(:estado_acta_RE_AP,d.estado)
 order by 1,2,3 
   ;   

--Consultar actas que no se imputaron
select d.numero acta, 
    d.estado estado_acta, d.fecha fecha_acta, 
     tsl.codigo_entidad, tm.mensaje,
      d.tipo 
   ,d.unte_codigo 
   , d.estado
     --select distinct d.estado
from ogt_documento d
join
  (
    select e.nro_referencia_pago, e.estado, e.fecha_vencimiento, cc.codigo_entidad, cc.id_cuenta_cobro,
      l.interno_persona, e.fecha_sistema
    -- select *
    from sl_pcp_encabezado e
    join sl_pcp_cuenta_cobro cc on e.id = cc.id_encabezado
    join sl_pcp_liquidaciones l on cc.id = l.id_det_cuenta_cobro
    join sl_pcp_pago p on e.nro_referencia_pago = p.nro_referencia_pago
    where  e.nro_referencia_pago = nvl(:factura,e.nro_referencia_pago) --'2026000358' 
    and cc.id_cuenta_cobro = nvl(:cuenta_cobro,cc.id_cuenta_cobro)
    and extract(year from e.fecha_sistema) = nvl(:agno,extract(year from e.fecha_sistema))
    and extract(month from e.fecha_sistema) = nvl(:mes,extract(month from e.fecha_sistema))
    and extract(day from e.fecha_sistema) = nvl(:dd,extract(day from e.fecha_sistema))
    ) tsl on tsl.fecha_sistema <= d.fecha and d.numero_externo = tsl.nro_referencia_pago
    left join 
      (select distinct mensaje from tab_lch_segui
        where extract(year from fecha) = nvl(:agno,extract(year from fecha))
        and extract(month from fecha) >= nvl(:mes,extract(month from fecha))
        and extract(day from fecha) >= nvl(:dd,extract(day from fecha))) tm 
      on tm.mensaje like  'OGT->LEG>%FALLID%'||tsl.nro_referencia_pago||'%'||tsl.id_cuenta_cobro||'%' 
 where d.tipo = 'ALE'
   and d.unte_codigo = 'FINANCIERO'
   --and d.numero in (60082,60085)
   and d.estado = 'RE'
 order by 1,2,3 
   ;



commit;

select *
from sl.tab_lch_segui
where extract(year from fecha) = nvl(:agno,extract(year from fecha))
and extract(month from fecha) >= nvl(:mes,extract(month from fecha))
and extract(day from fecha) >= nvl(:dd,extract(day from fecha))
and mensaje like  'OGT->LEG>%FALLID%'||:factura||'%'||:cuenta_cobro||'%'   --2026000427  2026000357
;


--truncate table ;
--create table tab_lch_segui20261013 as
select consec, mensaje
from tab_lch_segui   
order by consec desc
;  --3982435  3982453


--delete  tab_lch_segui   
--commit;


select distinct mensaje --max(consec) 
  from tab_lch_segui 
  where mensaje like  'OGT->LEG>%FALLID%2026000524%'
  and fecha >= '13-OCT-2026'
  order by 1;

60086 OGT->LEG>Recaudo FALLIDO en SISLA para referencia: 2026000562. Saldo cuenta de cobro: 2025000952 es menor a valor pago capital: 18634
60082 OGT->LEG>Recaudo FALLIDO en SISLA para referencia: 2026000555. Saldo cuenta de cobro: 2021000100 es menor a valor pago capital: 1122678
60085 OGT->LEG>Recaudo FALLIDO en SISLA para referencia: 2026000559. Saldo cuenta de cobro: 2025000629 es menor a valor pago capital: 9317

select *
from tab_lch_segui
order by 2 desc
/*
where consec > (
select max(consec) from tab_lch_segui   where mensaje like  '%2026000524%'
)*/;

-- delete tab_lch_segui;
-- commit

declare
  p_resp varchar2(4000);
  p_procesado boolean;
begin
  pk_ogt_imputacion.pr_procesar_imputacion(    
      p_nro_referencia_pago => '2026000525',
      p_usuario             => 'user',
      p_resp                => p_resp,
      p_procesado           => p_procesado
   ) ;
   dbms_output.put_line('Respuesta: ' || p_resp);
   dbms_output.put_line('Procesado: ' || case when p_procesado then 'Sí' else 'No' end);
end;   


--commit

select *
from binconsecutivo
where grupo='OPGET'
and nombre='DOC_NUM'
and vigencia=2002
and codigo_compania='000'

set echo on
declare
  mi_sec number;
begin
  mi_sec :=  pk_secuencial.fn_traer_consecutivo('OPGET', 'DOC_NUM', '2002', '000' );
  dbms_output.put_line('mi_sec:'||mi_sec);
end;
commit
rollback;


select *
from ogt_detalle_pensionado;

