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
 where /*id_cuenta_cobro= 2016000139 and nro_liquidacion=2016049725*/ --id_novedad is null

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

---20260812


select          distinct
                    --:p_usuario,
                    --:p_centro_costo,
                    ctas.entidad_factura,
                    ctas.id_cuenta_cobro,
                    ctas.id_factura,
                    ctas.interno_persona,
                    ctas.fecha_ini_factura,
                    ctas.fecha_fin_factura,
                    sald.saldo saldo_liquidacion,
                    sald.saldo valor_k_pagar,
                    0 saldo_intereses,
                    0 valor_i_pagar,
                    sysdate,
                    1
         from  (select fac.*, com.nit, com.nombre
                from   sl_cuenta_cobro_cp_2017 cta,
                       sl_factura_cp_2017 fac,
                       sl_relacion_tac tac,
                       sl_compania com
                where  to_number(tac.id_sisla) = nvl(:p_centro_costo,to_number(tac.id_sisla))
                and    cta.entidad_cuenta_cobro = tac.codigo_compa
                and    cta.entidad_cuenta_cobro = com.codigo_compania
                and    cta.id_cuenta_cobro = fac.id_cuenta_cobro
                --and    cta.ide_cuenta_cobro = 1128 --(1128,1047,1125,1323)   
                --and    fac.fecha_ini_factura >= decode(:p_fecha_inicial,null,fac.fecha_ini_factura,:p_fecha_inicial)
                --and    fac.fecha_ini_factura <= decode(:p_fecha_final,null,fac.fecha_ini_factura,:p_fecha_final)
                and    nvl(fac.factura_anulada,'N') = 'N'
                and    nvl(fac.estado_coactivo,1) <> 3   --cis comentario coactivo
                --and  cta.id_cuenta_cobro=2025001353  1118
               ) ctas,
              (select nov.nro_liquidacion,
                    -- (sum(nvl(nov.valor_debito,0)))  saldo -- cis no estaba as 13052026
                      sum(nvl(nov.valor_debito,0)) - sum(nvl(nov.valor_credito,0)) saldo -- cis no estaba as
                   --   round(sum(nvl(nov.valor_debito,0)) - sum(nvl(nov.valor_credito,0))) saldo     ---cis si estaba asi
                from sl_novedad_x_cc_cp nov, 
              where nov.ID_NOVEDAD in (SELECT ncl.ID_NOVEDAD FROM SL_NOVEDAD_CP ncl WHERE ncl.clase_novedad='K' AND ncl.TIPO_CUOTA='1')  --anadio cis
               and nov.nro_liquidacion in (select fc.id_factura from sl_factura_cp_2017 fc where nvl(fc.estado_coactivo,1) <> 3 and fc.id_cuenta_cobro = nov.id_cuenta_cobro) --02062026grupo portal
               group by nov.nro_liquidacion
                having  sum(nvl(nov.valor_debito,0)) - sum(nvl(nov.valor_credito,0)) > 0 -- le quito esto: round(
               ) sald

;

select --fac.*,  com.nit, com.nombre
       * --cta.entidad_cuenta_cobro
                from   sl_cuenta_cobro_cp_2017 cta,
                       --sl_factura_cp_2017 fac,
                       sl_relacion_tac tac,
                       sl_compania com
                where  to_number(tac.id_sisla) = nvl(:p_centro_costo,to_number(tac.id_sisla)) --1118
                and  cta.id_cuenta_cobro=2025001353 
                and    cta.entidad_cuenta_cobro = tac.codigo_compa
                and    cta.entidad_cuenta_cobro = com.codigo_compania
                --and    cta.id_cuenta_cobro = fac.id_cuenta_cobro
                --and    fac.fecha_ini_factura >= decode(:p_fecha_inicial,null,fac.fecha_ini_factura,:p_fecha_inicial)
                --and    fac.fecha_ini_factura <= decode(:p_fecha_final,null,fac.fecha_ini_factura,:p_fecha_final)
                --and    nvl(fac.factura_anulada,'N') = 'N'
                --and    nvl(fac.estado_coactivo,1) <> 3   --cis comentario coactivo
                
                ;


select  * from sl_cuenta_cobro_cp_2017 cta where cta.id_cuenta_cobro=2025001353 ;

select * from sl_relacion_tac tac where tac.codigo_compa=111324


select * from sl_relacion_tac tac where  nit = 800112806

select count(1), nit, id_sisla
from sl_relacion_tac
group by nit, id_sisla
having count(1) >1
;

select *
from sl_relacion_tac
where nit='899999053'
400339
;

select *
from sl_novedades
where cod_entidad = 1118;

select *
from all_tables
where owner='SL'
and table_name like 'SL%NOVEDAD%';


select *
from user_tab_columns
where table_name like 'SL%NOVEDAD%'
and column_name like 'ID_CUENTA_COBRO';

/*
select cod_entidad, interno_persona, id_cuenta_cobro, nro_liquidacion,
       sum(valor_debito)  debito, 
       sum(valor_credito)  credito, 
       abs(sum(trunc(valor_debito))- sum(trunc(valor_credito))) dif_trunc,
       abs(sum(round(valor_debito))- sum(round(valor_credito))) dif_round  */
select *       
from SL_NOVEDAD_X_CC_CP
where id_cuenta_cobro = 2021000357 and nro_liquidacion=2021005918
;

---Validaciones para el proceso de redondeo
select res.* from
(
select cod_entidad, interno_persona, id_cuenta_cobro, nro_liquidacion,
       sum(valor_debito)  debito, 
       sum(valor_credito)  credito,
       abs(sum(trunc(valor_debito))- sum(trunc(valor_credito))) dif_trunc,
       abs(sum(round(valor_debito))- sum(round(valor_credito))) dif_round,
       sum(valor_saldo) saldo
--select cod_entidad, interno_persona, id_cuenta_cobro, nro_liquidacion   
from SL_NOVEDAD_X_CC_CP  
where id_cuenta_cobro = 20190001488 --and nro_liquidacion=2019023513
group by cod_entidad, interno_persona, id_cuenta_cobro, nro_liquidacion
) res
where ((res.dif_trunc between 1 and 10) or (res.dif_round between 1 and 10)) --and saldo =0
order by cod_entidad, interno_persona, id_cuenta_cobro, nro_liquidacion, debito asc, credito asc
;



--Validando el tercero tac
select count(1), nit, id_sisla
from sl_relacion_tac
group by nit, id_sisla
having count(1) >1
;

---terceros en sisla sin nit
select * from sl_relacion_tac
where nit in
(select nit
from sl_relacion_tac where id_sisla is null)
--and id_sisla is not null
;

--Cuenta de cobro que no aparecen en el portal
select distinct com.nit, com.nombre
    /*, fac.id_cuenta_cobro, fac.id_factura, fac.interno_persona, fac.id_resol_cp, 
       fac.fecha_ini_factura, fac.fecha_fin_factura, fac.vlr_total_factura*/
from   sl_cuenta_cobro_cp_2017 cta,
       sl_factura_cp_2017 fac,
       sl_relacion_tac tac,
       sl_compania com
where  to_number(tac.id_sisla) not in 
       (
       select argumento from bintablas
       where  grupo = 'SISLA'
       and nombre = 'CENTROS_COSTO_CP'
       ) 
       and    cta.entidad_cuenta_cobro = tac.codigo_compa
       and    cta.entidad_cuenta_cobro = com.codigo_compania
       and    cta.id_cuenta_cobro = fac.id_cuenta_cobro
       --and    fac.fecha_ini_factura >= decode(:p_fecha_inicial,null,fac.fecha_ini_factura,:p_fecha_inicial)
       --and    fac.fecha_ini_factura <= decode(:p_fecha_final,null,fac.fecha_ini_factura,:p_fecha_final)
       and    nvl(fac.factura_anulada,'N') = 'N'
       and    nvl(fac.estado_coactivo,1) <> 3  ;


---
select tac.* --tac.nombres, tac.id_sisla, b.resultado
from sl_relacion_tac tac,  bintablas b
where  b.grupo = 'SISLA'
and b.nombre = 'CENTROS_COSTO_CP'
and tac.id_sisla = b.argumento
and tac.id_sisla in (1128,1047,1125,1323)   
       /*duplicados 
          id_sisla   compa       nombres
          1125       921,100862  GOBERNACION DE BOYACA%
          1128       936,111860  GOBERNACION DE CUNDINAMARCA - FONDO DE PENSIONES PUBLICAS
       */
and sysdate between b.vig_inicial and nvl(b.vig_final,sysdate)
order by 1
;

--Terceros_tac que no se encuentran en bintablas centros de costo
select *
from sl_relacion_tac tac
where tac.id_sisla not in 
       (select argumento
       from bintablas
       where  grupo = 'SISLA'
       and nombre = 'CENTROS_COSTO_CP')       
and nit in (
       899999001, --	MINISTERIO DE EDUCACION NACIONAL
       899999059, --	UNIDAD ADMINISTRATIVA ESPECIAL DE AERONAUTICA CIVIL - AEROCIVIL
       860063875, --	ENEL COLOMBIA SA ESP
       891800857, --	HOSPITAL BAUDILIO ACERO E.S.E DE TURMEQUE
       800231235, --	HOSPITAL UNIVERSITARIO SAN JORGE E.S.E. - PEREIRA
       899999090, --	MINISTERIO DE HACIENDA Y CREDITO PUBLICO
       892280033  --	HOSPITAL UNIVERSITARIO DE SINCELEJO
)
;


--20260825_1 Relación tac que están en centros de costo y no tienen ID Sisla
select *
from sl_relacion_tac tac
where tac.id_sisla --= 1045 
       not in 
       (select argumento
       from bintablas
       where  grupo = 'SISLA'
       and nombre = 'CENTROS_COSTO_CP')       
--and id_sisla is null
;

--Cuentas de cobro con caso anterior 20260825_1
select distinct tac.codigo_compa, tac.nit, tac.nombres, tac.id_sisla
from sl_cuenta_cobro_cp_2017 cta, sl_relacion_tac tac
where  cta.entidad_cuenta_cobro = tac.codigo_compa
and    tac.id_sisla --= 1045 
       not in 
       (select argumento
       from bintablas
       where  grupo = 'SISLA'
       and nombre = 'CENTROS_COSTO_CP')  
;

select * from sl_cuenta_cobro_cp_2017
where id_cuenta_cobro = 2026001201
;

select argumento, resultado
    from   bintablas
    where  grupo = 'SISLA'
    and    nombre = 'CENTROS_COSTO_CP'
    and argumento in (1128,1047,1125,1323)
      -- =1045 --FONDO DE PASIVO SOCIAL - FERROCARRILES NACIONALES DE COLOMBIA - MINISTERIO DE AGRICULTURA - INCORA EN LIQUIDACION
    ;


-- traer_resumen_cuentas
select count(*) total_cta, sum(sel.saldo_capital) saldo_capital,
              sum(sel.saldo_intereses) saldo_intereses, sum(valor_k_pagar) total_pagar_k,
              sum(sel.saldo_total) total_pagar_k_i
              --select count(1), centro_costo
       from  (select cct.id_cuenta_cobro,
                     com.nit, com.nombre,
                     cct.fecha_inicial,
                     cct.fecha_final,
                     cct.saldo_cuenta_cobro saldo_capital,
                     cct.valor_i_pagar saldo_intereses,
                     cct.valor_k_pagar,
                    (cct.valor_k_pagar + cct.valor_i_pagar) saldo_total
                    ,cct.centro_costo
              from   sl_pcp_tmp_centro_costo cct, sl_compania com
              where  cct.id_usuario = nvl(:p_usuario,cct.id_usuario)
              and    cct.centro_costo = nvl(:p_centro_costo,cct.centro_costo)
              and    cct.codigo_entidad = com.codigo_compania
             ) sel  --(1128,1047,1125,1323)
             where centro_costo in (1128,1047,1125,1323)
             group by centro_costo
             order by 1 desc;

--Traer paginación cuentas
select cct.id_cuenta_cobro,
                   com.nit, com.nombre,
                   cct.fecha_inicial,
                   cct.fecha_final,
                   cct.saldo_cuenta_cobro saldo_capital,
                   cct.valor_k_pagar,
                   cct.valor_i_pagar saldo_intereses,
                  (cct.valor_k_pagar + cct.valor_i_pagar) saldo_total,
                   cct.seleccion
           -- select  count(1), max(fecha_inicial), cct.centro_costo
            from   sl_pcp_tmp_centro_costo cct, sl_compania com
            where  /* cct.id_usuario = p_usuario
            and    cct.centro_costo in -- nvl(:p_centro_costo,cct.centro_costo)
            (1128,1047,1125,1323)
            and  */  cct.codigo_entidad = com.codigo_compania
            and cct.id_cuenta_cobro = 2026001201
          --  group by cct.centro_costo
   ;

select *
from sl_pcp_cuenta_cobro
where valor_capital between 0 and 1;

select *
from sl_pcp_encabezado
where id in (886,887)
;