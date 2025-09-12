-- Myriam silva Obando -- 51653368 INT 41

select *
  from rh_personas
 where numero_identificacion = '51653368'; --41


/*
DESCUENTO 
  NUM   754          3241       2188
  TIPO  LIBRANZA     LIBRANZA   LIBRANZA
  MONTO 1442686      487387     193167
*/


select *
  from rh_descuentos_f
 where funcionario = 41
   and identificacion_descuento in ( 754,
                                     3241,
                                     2188 )
   and estado = 2;

select *
  from rh_detalle_pagos_f
 where funcionario = 41
   and descuentos_tipo = 'LIBRANZA'
   and descuentos_numero in ( 85,
                              94,
                              100 )
 order by descuentos_numero,
          fecha_pago desc;

select h.*
  from rh_historico_nomina h,
       rh_concepto c
 where h.nfuncionario = 41
   and h.dinicioperiodo = 20250601
   and h.nhash = c.codigo_hash
   and c.nombre_corto = 'CLIBRANZA'
   and h.sactoadmi in ( 85,
                        94,
                        100 )
   and brechazado = 0
 order by dfechaefectiva desc,
          h.sactoadmi;