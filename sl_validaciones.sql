--valor total adeudado capital

--valor a pagar en capital

--Valor total a pagar = valor a pagar en capital + valor total adeudado en intereses


select count(*) total_cta,
       sum(sel.saldo_capital) saldo_capital,
       sum(sel.saldo_intereses) saldo_intereses,
       sum(valor_k_pagar) total_pagar_k,
       sum(sel.saldo_total) total_pagar_k_i
  from (select cct.id_cuenta_cobro,
                com.nit,
                com.nombre,
                cct.fecha_inicial,
                cct.fecha_final,
                cct.saldo_cuenta_cobro saldo_capital,
                cct.valor_i_pagar saldo_intereses,
                cct.valor_k_pagar,
                (cct.valor_k_pagar + cct.valor_i_pagar) saldo_total
           from sl_pcp_tmp_centro_costo cct, sl_compania com
          where -- cct.id_usuario = p_usuario and   
          cct.centro_costo = 162 --GOBERNACION DE NORTE DE SANTANDER - FONDO TERRITORIAL DE PENSIONES --p_centro_costo
       and cct.codigo_entidad = com.codigo_compania) sel
       ;

select distinct p_usuario,
                    p_centro_costo,
                    ctas.entidad_factura,
                    sald.id_cuenta_cobro,
                    peri.fecha_ini_factura,
                    peri.fecha_fin_factura,
                    sald.saldo saldo_capital,
                    sald.saldo saldo_capital, --valor_k_pagar  
                    0 valor_i_pagar,
                    sysdate,
                    1
         from  (select fac.id_cuenta_cobro,
                min(fac.fecha_ini_factura) fecha_ini_factura, max(fac.fecha_fin_factura)fecha_fin_factura
                from   sl_factura_cp_2017 fac
                where id_cuenta_cobro = 2019001475
                group by fac.id_cuenta_cobro
               ) peri,
               (select fac.*, com.nit, com.nombre
                from   sl_cuenta_cobro_cp_2017 cta,
                       sl_factura_cp_2017 fac,
                       sl_relacion_tac tac,
                       sl_compania com
                where  to_number(tac.id_sisla) = :p_centro_costo
                and    cta.entidad_cuenta_cobro = tac.codigo_compa
                and    cta.entidad_cuenta_cobro = com.codigo_compania
                and    cta.id_cuenta_cobro = fac.id_cuenta_cobro
                and    fac.fecha_ini_factura >= decode(:p_fecha_inicial,null,fac.fecha_ini_factura,:p_fecha_inicial)
                and    fac.fecha_ini_factura <= decode(:p_fecha_final,null,fac.fecha_ini_factura,:p_fecha_final)
                and    nvl(fac.factura_anulada,'N') = 'N'
                and    nvl(fac.estado_coactivo,1) <> 3   --cis comentario ccoactivo  DE 11 A 50
               ) ctas,
               (select nov.id_cuenta_cobro,
                  ------    round(sum(nvl(nov.valor_debito,0)))  saldo, -- cis no estaba as 13052026
                  --    round(sum(nvl(nov.valor_debito,0)) - sum(nvl(nov.valor_credito,0)))  saldo -- saldo_k
                        sum(nvl(nov.valor_debito,0)) - sum(nvl(nov.valor_credito,0)) saldo -- cis no estaba as 13052026
                from   sl_novedad_x_cc_cp nov
                where nov.ID_NOVEDAD in (SELECT ncl.ID_NOVEDAD FROM SL_NOVEDAD_CP ncl WHERE ncl.clase_novedad='K' AND ncl.TIPO_CUOTA='1')  --anadio cis
                group by nov.id_cuenta_cobro
                having  (sum(nvl(nov.valor_debito,0)) - sum(nvl(nov.valor_credito,0))) > 0  
               -- having  round(sum(nvl(nov.valor_debito,0)) - sum(nvl(nov.valor_credito,0))) > 0  --cis original
               ) sald
            ;


select sum(saldo)
from (
select nov.id_cuenta_cobro,
       sum(nvl(nov.valor_debito, 0)) - sum(nvl(nov.valor_credito, 0)) saldo 
  from (SELECT * FROM sl_novedad_x_cc_cp WHERE cod_entidad=139  /* and  id_cuenta_cobro=2019001475 /*2016000049*/)  nov
 /*where nov.ID_NOVEDAD in (SELECT ncl.ID_NOVEDAD
                            FROM SL_NOVEDAD_CP ncl
                           WHERE ncl.clase_novedad = 'K'
                             AND ncl.TIPO_CUOTA = '1' ) */
 group by nov.id_cuenta_cobro
having(sum(nvl(nov.valor_debito, 0)) - sum(nvl(nov.valor_credito, 0))) > 0  
order by 1
)
;

--Inconsistencia 1. Valor total
SELECT nov.id_cuenta_cobro,
               ROUND(SUM(NVL(nov.valor_debito,0)) - SUM(NVL(nov.valor_credito,0))) AS saldo
        FROM (SELECT * FROM sl_novedad_x_cc_cp )  nov
        GROUP BY nov.id_cuenta_cobro
        HAVING ROUND(SUM(NVL(nov.valor_debito,0)) - SUM(NVL(nov.valor_credito,0))) > 0
        ;


select  sum(vlr_total_nov) valor_saldo_capital from SL_FACTURA_CP_2017 
where id_cuenta_cobro =  2019024509   --2016000049  -2019001482 -- 2016000088
AND SL_FACTURA_CP_2017.ENTIDAD_FACTURA = 139
;
--Verificación Inconsistencia 1. No hay dato en novedad
 select *
 from sl_novedad_x_cc_cp
 where  id_novedad is null 
 ;

 --Solución 1. Excluye todos los que valor_debito, valor_credito, valor_saldo también son nulo
 select *
 from sl_novedad_x_cc_cp
 where  id_novedad is null and valor_debito is null and valor_credito is null and valor_saldo is null
 ;

 select *
 from sl_novedad_x_cc_cp
 where id_novedad is null  and (valor_debito is not null or valor_credito is not null or valor_saldo is not null)
  ;

--Verificación Inconsistencia 1. No hay dato en novedad
 select cod_entidad, id_cuenta_cobro, nro_liquidacion, id_novedad, valor_debito, valor_credito, valor_saldo,
        observaciones, usuario, fecha_novedad, fecha_creacion
 from sl_novedad_x_cc_cp
 where id_cuenta_cobro= 2016000139 and nro_liquidacion=2016049725 --id_novedad is null
 order by fecha_novedad, fecha_creacion
 --order by valor_debito+ valor_credito+ valor_saldo --cod_entidad, id_cuenta_cobro, nro_liquidacion, fecha_novedad, fecha_creacion
 ;

 select *
 from sl_novedad_x_cc_cp
 where id_cuenta_cobro =  2016000139 --2019001475 --nro_liquidacion in (2019024509, 2019024510)
 and id_novedad is null
 order by interno_persona
 ;

select *
from sl_novedad_x_cc_cp
where id_cuenta_cobro in ( 
 select count(1) count, nro_liquidacion
 from sl_novedad_x_cc_cp
 where nro_liquidacion in (2016049725) --2019024509, 2019024510)
 group by  /*cod_entidad, interno_persona, */ nro_liquidacion 
 having count(1) =2
 )
 --where nro_liquidacion=2019024509
 ;

select  sum(vlr_total_nov) valor_saldo_capital from SL_FACTURA_CP_2017 
where id_cuenta_cobro =  2019024509   --2016000049  -2019001482 -- 2016000088
AND SL_FACTURA_CP_2017.ENTIDAD_FACTURA = 139


--Inconsistencia 2. Actualizando saldo, función actualiza_tmp_liq
/* 
GOBERNACION DE NORTE DE SANTANDER - FONDO TERRITORIAL DE PENSIONES
SALDO CAPITAL 505.865.087
VALOR A PAGAR EN CAPITAL 473.449.655
Total registros: 67
*/

 select *
 from sl_novedad_x_cc_cp
 where id_cuenta_cobro =  2016000088 
 and nro_liquidacion in (2016042427, --coactivo, 
                        2016042480  --sin
                        )
 and nov.nro_liquidacion in  
 (
        select fc.id_factura
       from sl_factura_cp_2017 fc
       where nvl(fc.estado_coactivo,1) <> 3
       and fc.id_cuenta_cobro = nov.id_cuenta_cobro
 )            
 and id_novedad is not null  --excluyo el caso 1
 order by interno_persona
 ;

 select *
 from sl_factura_cp_2017
 where id_factura in (2016042427, --coactivo, 
                        2016042480--sin
                        )
                        ;

-- Continua Diferencia 1 peso
--Verificar cuenta de cobro 20190001482

 select *
 from sl_novedad_x_cc_cp
 where id_cuenta_cobro =  20190001482 
 ;

--Inconsistencia 3. Chulea y deschulea falla.
2017001026
2018000689                       