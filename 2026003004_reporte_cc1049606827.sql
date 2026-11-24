
/*
un reporte donde figuren el concepto y valor de todo lo pagado y deducido a la servidora pública Mónica Johana Jimenez cc 1049606827 durante la vigencia 2025.
*/

 select TRUNC(v.dinicioperiodo/100) FECHAMES,
        v.nombre,
        decode(v.devengado,'S',v.valor_deducido,0) "DEVENGADO",
        decode(v.devengado,'N',v.valor_deducido,0) "DEDUCIDO"
  from v_consulta_nomina v, rh_personas p
  where v.func_deducido = p.interno_persona 
   and p.numero_identificacion =1049606827 
   and v.dinicioperiodo >= 20250101 --between 20220701 and 20221231
   and v.dfinalperiodo <= 20251231 --between 20220701 and 20221231)
  -- and decode(devengado,'S',valor_deducido,0) > 0
 order by 1,3,4
   ;

