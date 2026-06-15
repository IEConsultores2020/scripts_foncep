--CUENTAS DE COBRO EN SISLA
select e.nro_referencia_pago,
       e.estado eest,
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
       l.valor_capital capital, l.valor_interes interes,
       p.id_banco, l.*
      -- select p.*
  from sl_pcp_encabezado e,
       sl_pcp_cuenta_cobro cc,
       sl_pcp_liquidaciones l,
       sl_pcp_pago p
 where e.id = cc.id_encabezado
   and cc.id = l.id_det_cuenta_cobro
   and e.nro_referencia_pago = p.nro_referencia_pago
   --and e.estado = 'PAG'
   and e.nro_referencia_pago in ('2026000201'); --,'2025000003');

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
and e.nro_referencia_pago in ('2025000105'); 


select *
from sl_pcp_encabezado e
where e.nro_referencia_pago = '2026000202'; 

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

select fecha_autorizacion, fecha_autorizacion
from sl_pcp_pago 
where nro_referencia_pago in ('2025000105'); 

----Cunsultar el acta del radicado
select * from 
 ogt_documento
 where tipo = 'ALE'
   --and estado = 'RE'
   and unte_codigo = 'FINANCIERO'
   and numero_externo in ( '2026000002') 
   and extract(year from fecha) in ( 2026 );

---Consultar los documentos asociados al acta
select * from 
 ogt_documento
 where numero_legal in (
   select numero
     from ogt_documento
    where tipo = 'ALE'
      --and estado='RE'
      and unte_codigo = 'FINANCIERO'
      and numero_externo in ( '2026000002')
)
and tipo = 'XYZ'   
;


select * --distinct mensaje 
from tab_lch_segui   
where fecha >= '12/JUN/2026'
--order by consec DESC
and consec = (select max(consec) from tab_lch_segui 
              where /*mensaje like '%55585%'*/
                mensaje like '%2026000206%') -- 'OGT->LEG>%FALLID%') --'OGT->LEG>Legalización EXITOSA ingreso: 608727%')
--and mensaje like 'OGT->LEG>Recaudo FALLIDO en SISLA para referencia:%'
order by consec DESC
; --55585  2026000187

--truncate table tab_lch_segui;

commit

declare
  p_resp varchar2(4000);
  p_procesado boolean;
begin
  pk_ogt_imputacion.pr_procesar_imputacion(    
      p_nro_referencia_pago => '2026000204',
      p_usuario             => 'user',
      p_resp                => p_resp,
      p_procesado           => p_procesado
   ) ;
   dbms_output.put_line('Respuesta: ' || p_resp);
   dbms_output.put_line('Procesado: ' || case when p_procesado then 'Sí' else 'No' end);
end;   


begin
  pk_ogt_imputacion.pr_procesar_imputacion (    

      p_usuario     => user
   ) ;
end;   

update --select * from
   sl_pcp_encabezado 
   set estado='PAG'
  where nro_referencia_pago =   '2026000002'

--rollback;

--commit;


  SELECT * 
  FROM ogt_info_ing
  WHERE VALOR= '31132';


  ogt_fn_dinamica_actualiza (
      mi_clase_info    => 'CONCEPTO_TESORERIA',
      mi_tipo_info     => 'DESCRIPCION',
      p_tipo_info => ' WHERE  id         =  ''00-02-37-19-00-00-00'' '
   ) ;

   SELECT NUMERO_LEGAL
   FROM DOCUMENTO
----
--ID no  corresponde


SELECT * FROM ogt_DOCUMENTO  WHERE numero = '55540'   AND tipo   = 'XYZ'

SELECT * --numero, tipo, fecha_compra_titulo, numero_legal, tipo_legal 
FROM ogt_DOCUMENTO  WHERE /*numero=98232 and*/ numero_legal = '55540'   AND tipo   = 'XYZ'

select doc_numero from ogt_ingreso where doc_numero=98232 and doc_tipo='XYZ';