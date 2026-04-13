 select TRUNC(dinicioperiodo/100) FECHAMES,
        nombre,
        decode(devengado,'S',valor_deducido,0) "DEVENGADO",
        decode(devengado,'N',valor_deducido,0) "DEDUCIDO"
  from v_consulta_nomina 
 where  func_deducido=547
   and (dinicioperiodo >= 20180101 --between 20220701 and 20221231
   and dfinalperiodo <= 20251231) --between 20220701 and 20221231)
  -- and decode(devengado,'S',valor_deducido,0) > 0
 order by 1,3,4
   ;
3
   select *
   from rh_personas
   where numero_identificacion =51852403