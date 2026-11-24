select argumento, resultado
   from   bintablas
   where  grupo = 'SISLA'
   and    nombre = 'CENTROS_COSTO_CP'
   and resultado like /*'%FERROC%'; --*/ '%MINISTERIO DE TECNOLOGIAS%';  --899999053

/*
"ARGUMENTO"	"RESULTADO"
"1045"	"FONDO DE PASIVO SOCIAL - FERROCARRILES NACIONALES DE COLOMBIA - MINISTERIO DE AGRICULTURA - INCORA EN LIQUIDACION"
"1118"	"FONDO DE PASIVO SOCIAL DE FERROCARRILES NACIONALES DE COLOMBIA"
"1122"	"FONDO DE PASIVO SOCIAL DE FERROCARRILES NACIONALES DE COLOMBIA-PROSOCIAL"
*/

 --Total de registros
    --OPEN p_cursor FOR
       select count(*) total_cta, sum(sel.saldo_capital) saldo_capital,
              sum(sel.saldo_intereses) saldo_intereses, sum(valor_k_pagar) total_pagar_k,
              sum(sel.saldo_total) total_pagar_k_i
       from  (
            select cct.id_cuenta_cobro,
                     com.nit, com.nombre,
                     cct.fecha_inicial,
                     cct.fecha_final,
                     cct.saldo_cuenta_cobro saldo_capital,
                     cct.valor_i_pagar saldo_intereses,
                     cct.valor_k_pagar,
                    (cct.valor_k_pagar + cct.valor_i_pagar) saldo_total
              from   sl_pcp_tmp_centro_costo cct, sl_compania com
              where  --cct.id_usuario = p_usuario and    
              cct.centro_costo = :p_centro_costo
              and    cct.codigo_entidad = com.codigo_compania
       --) sel

       --106	3104664690	602335151	3104664692	3706999843