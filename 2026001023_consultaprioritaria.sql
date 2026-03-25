select p.numero_identificacion, p.primer_apellido||'-'||p.segundo_apellido||'-'||p.nombres NOMBRE, TRUNC(VN.DINICIOPERIODO/100) FECHAMES, 'DEVENGADO' TIPO, VN.NOMBRE CONCEPTO, VALOR_DEDUCIDO+AJUSTE_DEDUCIDO VALOR
from v_consulta_nomina vn, rh_personas p
 where func_deducido = p.interno_persona
   and devengado = 'S' 
   and (dinicioperiodo >= 20220701 --between 20220701 and 20221231
   and dfinalperiodo <= 20260331) --between 20220701 and 20221231)
UNION
 select p.numero_identificacion, p.primer_apellido||'-'||p.segundo_apellido||'-'||p.nombres NOMBRE, TRUNC(VN.DINICIOPERIODO/100) FECHAMES, 'DEDUCIDO' TIPO, VN.NOMBRE CONCEPTO, VALOR_DEDUCIDO+AJUSTE_DEDUCIDO VALOR
  from v_consulta_nomina vn, rh_personas p
 where func_deducido = p.interno_persona
   and devengado = 'N' 
   and (dinicioperiodo >= 20220107 --between 20220701 and 20221231
   and dfinalperiodo <= 20260331) --between 20220701 and 20221231)  
 order by 1,2,3,4
   ;

   select *
   from rh_personas