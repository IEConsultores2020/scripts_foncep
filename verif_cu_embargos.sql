--  CURSOR cur_embargos(un_cc NUMBER, un_nro_ra NUMBER) IS
  --mi_tercero, mi_funcionario, mi_sdescuento,mi_nbeneficiario,mi_codbeneficiario,  mi_fpagobeneficiario, mi_valor;
    SELECT a.stercero,
           a.nfuncionario,
           a.sdescuento,
           bb.beneficiario,
           d.cod_benef_pago,
           d.forma_pago,
           d.proceso,
           SUM(valor) valor,
           d.concepto
      FROM rh_t_lm_valores     a,
           rh_lm_cuenta        b,
           rh_lm_centros_costo c,
           rh_beneficiarios    bb,
           rh_descuentos_f     d
     WHERE b.stipo_funcionario = a.stipofuncionario
       AND b.sconcepto = a.sconcepto
       AND b.cc = c.codigo
       AND a.periodo = '30-JUN-2025' --una_fecha_final
       AND a.ntipo_nomina = 0 --un_tipo_nomina
       and d.funcionario = a.nfuncionario
       and d.beneficiario = a.stercero
       and d.tipo = substr(a.sconcepto, 2)
       AND a.sdevengado IN (0, 1)
       and a.sdescuento = d.numero_descuento
       and d.estado in (1, 2, 4)
       AND a.nro_ra = 14 --un_nro_ra
       AND b.scompania = 206 --una_compania
       AND b.tipo_ra = 1 --un_tipo_ra
       and bb.codigo_beneficiario = a.stercero
       AND b.grupo_ra IN (5 /*un_grupo_ra*/ )
       AND b.ncierre = 1
       and d.forma_pago = 'B'
       AND b.dfecha_inicio_vig <= '30-JUN-2025' --una_fecha_final
       AND (b.dfecha_final_vig >= '30-JUN-2025' /*una_fecha_final*/ OR
           b.dfecha_final_vig IS NULL)
       AND b.cc = 6
    /*--PRUEBAS 2022
      and       a.nfuncionario IN (4966,4946) --*/
     GROUP BY stercero,
              a.nfuncionario,
              bb.beneficiario,
              d.forma_pago,
              a.sdescuento,
              d.cod_benef_pago,
              d.proceso,
              d.concepto;
  