select e.nro_referencia_pago,
       e.estado eest,
       e.valor_referencia evalor,
       cc.id ctac_id,
       cc.codigo_entidad centi,
       cc.estado cest,
       cc.valor_capital cvcapital,
       cc.valor_intereses cvinteres,
       cc.*,
       l.id li_id,
       l.estado li_est,
       l.interno_persona li_ipers,
       p.*
  from sl_pcp_encabezado e,
       sl_pcp_cuenta_cobro cc,
       sl_pcp_liquidaciones l,
       sl_pcp_pago p
 where e.id = cc.id_encabezado
   and cc.id = l.id_det_cuenta_cobro
   and e.nro_referencia_pago = p.nro_referencia_pago
   and e.nro_referencia_pago = '2025000001';


   select cod_centro_costo
        from ogt_tercero_cc
       where id_tercero = 400293 

       select id_limay
        from sl_relacion_tac
        where codigo_compa = 107766