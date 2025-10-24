--  CURSOR cur_embargos(un_cc NUMBER, un_nro_ra NUMBER) IS
  --mi_tercero, mi_funcionario, mi_sdescuento,mi_nbeneficiario,mi_codbeneficiario,  mi_fpagobeneficiario, mi_valor;
select a.stercero,
       a.nfuncionario,
       a.sdescuento,
       bb.beneficiario,
       d.cod_benef_pago,
       d.forma_pago,
       d.proceso,
       sum(valor) valor,
       d.concepto
  from rh_t_lm_valores a,
       rh_lm_cuenta b,
       rh_lm_centros_costo c,
       rh_beneficiarios bb,
       rh_descuentos_f d
 where b.stipo_funcionario = a.stipofuncionario
   and b.sconcepto = a.sconcepto
   and b.cc = c.codigo
   and a.periodo = '31-OCT-2025' --una_fecha_final
   and a.ntipo_nomina = 0 --un_tipo_nomina
   and d.funcionario = a.nfuncionario
   and d.beneficiario = a.stercero
   and d.tipo = substr(
   a.sconcepto,
   2
)
   and a.sdevengado in ( 0,
                         1 )
   and a.sdescuento = d.numero_descuento
   and d.estado in ( 1,
                     2,
                     4 )
   and a.nro_ra = 14 --un_nro_ra
   and b.scompania = 206 --una_compania
   and b.tipo_ra = 1 --un_tipo_ra
   and bb.codigo_beneficiario = a.stercero
   and b.grupo_ra in ( 5 /*un_grupo_ra*/ )
   and b.ncierre = 1
   and d.forma_pago = 'B'
   and b.dfecha_inicio_vig <= '31-OCT-2025' --una_fecha_final
   and ( b.dfecha_final_vig >= '31-OCT-2025' /*una_fecha_final*/
    or b.dfecha_final_vig is null )
   and b.cc = 6
    /*--PRUEBAS 2022
      and       a.nfuncionario IN (4966,4946) --*/
 group by stercero,
          a.nfuncionario,
          bb.beneficiario,
          d.forma_pago,
          a.sdescuento,
          d.cod_benef_pago,
          d.proceso,
          d.concepto;

---CURSOR cur_embargosnba(un_cc NUMBER, un_nro_ra NUMBER) IS

select a.stercero,
       a.nfuncionario,
       a.sdescuento,
       bb.beneficiario,
       d.forma_pago,
       d.cod_benef_pago,
       d.banco,
       d.tipo_cuenta,
       d.numero_cuenta,
       d.proceso,
       sum(valor) valor
  from rh_t_lm_valores a,
       rh_lm_cuenta b,
       rh_lm_centros_costo c,
       rh_beneficiarios bb,
       rh_descuentos_f d
 where b.stipo_funcionario = a.stipofuncionario
   and b.sconcepto = a.sconcepto
   and b.cc = c.codigo
   and a.periodo = '31-OCT-2025' --una_fecha_final
   and a.ntipo_nomina = 0 --un_tipo_nomina
   and d.funcionario = a.nfuncionario
   and d.beneficiario = a.stercero
   and d.tipo = substr(
   a.sconcepto,
   2
)
   and a.sdevengado in ( 0,
                         1 )
   and a.sdescuento = d.numero_descuento
   and d.estado in ( 1,
                     2,
                     4 )
   and a.nro_ra = 22 --un_nro_ra
   and b.scompania = 206 --una_compania
   and b.tipo_ra = 1 --un_tipo_ra
   and bb.codigo_beneficiario = a.stercero
   and b.grupo_ra in ( 5 /*un_grupo_ra*/ )
   and b.ncierre = 1
   and d.forma_pago != 'B'
   and b.dfecha_inicio_vig <= '31-OCT-2025' -- una_fecha_final
   and ( b.dfecha_final_vig >= '31-OCT-2025' /*una_fecha_final*/
    or b.dfecha_final_vig is null )
   and b.cc = 6
    /*--PRUEBAS 2022
      and       a.nfuncionario IN (4966,4946) --*/
 group by a.stercero,
          a.nfuncionario,
          a.sdescuento,
          bb.beneficiario,
          d.forma_pago,
          d.cod_benef_pago,
          d.banco,
          d.tipo_cuenta,
          d.numero_cuenta,
          d.proceso;