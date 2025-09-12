--EXCEL CONCEPTOS DEVENGADOS Y DEDUCIDOS
select p.numero_identificacion cedula,
       p.nombres
       || ' '
       || p.primer_apellido
       || ' '
       || p.segundo_apellido as nombres_y_apellidos,
       hn.dinicioperiodo,
       hn.dias_vacaciones
  from rh_personas p,
       rh_funcionario f,
       (
          select hn.nfuncionario,
                 hn.dinicioperiodo,
                 abs(sum(
                    case
                       when c.nombre_corto = 'DIAS_VACACIONES' then
                          hn.ndcampo0
                       else 0
                    end
                 )) as dias_vacaciones
            from rh_historico_nomina hn
            join rh_concepto c
          on c.codigo_hash = hn.nhash
           where hn.dinicioperiodo >= 20180101
             and hn.dfinalperiodo <= 20250731
             and c.nombre_corto in ( 'DIAS_VACACIONES' )
             and hn.brechazado = 0
             and besdefinitivo = 1
           group by hn.nfuncionario,
                    hn.dinicioperiodo
       ) hn
 where p.interno_persona = f.personas_interno
   and p.interno_persona = hn.nfuncionario
   and f.personas_interno = hn.nfuncionario
   and p.numero_identificacion in ( 51605363,
                                    23495638,
                                    45454959,
                                    79355621,
                                    37891855,
                                    79329628,
                                    51753989,
                                    79315507,
                                    35325745,
                                    51978047,
                                    24022412,
                                    39789074,
                                    79489819,
                                    51665925,
                                    51605363,
                                    52116283,
                                    51841009,
                                    6762048,
                                    51653368,
                                    51564303,
                                    40030681,
                                    80039413,
                                    79536419,
                                    30401728,
                                    52750014,
                                    53116209,
                                    74369918,
                                    37726651,
                                    1049606827,
                                    29328794,
                                    79737305,
                                    20730522,
                                    1015404700,
                                    51852403,
                                    53141042,
                                    79455999,
                                    52227361,
                                    52866026 )
--and p.numero_identificacion = 6762048 and dinicioperiodo = 20180101                                
--order by DINICIOPERIODO
                                    ;