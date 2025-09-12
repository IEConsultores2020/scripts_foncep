--EXCEL CONCEPTOS DEVENGADOS Y DEDUCIDOS
select sa.descripcion ent_salud,
       pe.descripcion ent_pension,
    /*psc.dependencia, psc.centro_costo, psc.cargo cod_cargo, psc.nom_cargo, psc.grado, */
       p.numero_identificacion cedula,
       p.nombres
       || ' '
       || p.primer_apellido
       || ' '
       || p.segundo_apellido as nombres_y_apellidos,
       hn.*
  from rh_personas p,
       rh_funcionario f,
       (
          select hn.nfuncionario,
                 hn.dinicioperiodo,
                 abs(sum(
                    case
                       when c.nombre_corto = 'AUXILIOALIMENTACION' then
                          hn.ndcampo0
                       else 0
                    end
                 )) as auxilioalimentacion,
                 abs(sum(
                    case
                       when c.nombre_corto = 'BONIFICACIONRECREACION' then
                          hn.ndcampo0
                       else 0
                    end
                 )) as bonificacionrecreacion,
                 abs(sum(
                    case
                       when c.nombre_corto = 'BONIFICACIONSERVICIOS' then
                          hn.ndcampo0
                       else 0
                    end
                 )) as bonificacionservicios,
                 abs(sum(
                    case
                       when c.nombre_corto = 'RECONOCIMIENTOPROD' then
                          hn.ndcampo0
                       else 0
                    end
                 )) as reconocimientoprod,
                 abs(sum(
                    case
                       when c.nombre_corto = 'CESANTIAS' then
                          hn.ndcampo0
                       else 0
                    end
                 )) as cesantias,
                 abs(sum(
                    case
                       when c.nombre_corto = 'DIAS_INCAPACIDAD' then
                          hn.ndcampo0
                       else 0
                    end
                 )) as dias_incapacidad,
                 abs(sum(
                    case
                       when c.nombre_corto = 'DIFERENCIA_SALARIAL' then
                          hn.ndcampo0
                       else 0
                    end
                 )) as diferencia_salarial,
                 abs(sum(
                    case
                       when c.nombre_corto = 'GASTOSREPRESENTACION' then
                          hn.ndcampo0
                       else 0
                    end
                 )) as gastosrepresentacion,
                 abs(sum(
                    case
                       when c.nombre_corto = 'HORASEXTRAS' then
                          hn.ndcampo0
                       else 0
                    end
                 )) as horas_extras,
                 abs(sum(
                    case
                       when c.nombre_corto = 'HORAS_EXTRAS_DIURNAS' then
                          hn.ndcampo0
                       else 0
                    end
                 )) as horas_extras_diurnas,
                 abs(sum(
                    case
                       when c.nombre_corto = 'HORAS_EXTRAS_HORDIUFEST' then
                          hn.ndcampo0
                       else 0
                    end
                 )) as horas_extras_hordiufest,
                 abs(sum(
                    case
                       when c.nombre_corto = 'HORAS_EXTRAS_NOCTURNAS' then
                          hn.ndcampo0
                       else 0
                    end
                 )) as horas_extras_nocturnas,
                 abs(sum(
                    case
                       when c.nombre_corto = 'HORAS_EXTRAS_HORNOCT_FEST' then
                          hn.ndcampo0
                       else 0
                    end
                 )) as horas_extras_hornoct_fest,
                 abs(sum(
                    case
                       when c.nombre_corto = 'HORAS_EXTRAS_100' then
                          hn.ndcampo0
                       else 0
                    end
                 )) as horas_extras_100,
                 abs(sum(
                    case
                       when c.nombre_corto = 'INCAPACIDADMATERNIDAD' then
                          hn.ndcampo0
                       else 0
                    end
                 )) as incapacidadmaternidad,
                 abs(sum(
                    case
                       when c.nombre_corto = 'INCAPACIDADNOPROFESIONAL' then
                          hn.ndcampo0
                       else 0
                    end
                 )) as incapacidadnoprofesional,
                 abs(sum(
                    case
                       when c.nombre_corto = 'INCAPACIDADPROFESIONAL' then
                          hn.ndcampo0
                       else 0
                    end
                 )) as incapacidadprofesional,
                 abs(sum(
                    case
                       when c.nombre_corto = 'INTERESESCESANTIAS' then
                          hn.ndcampo0
                       else 0
                    end
                 )) as interesescesantias,
                 abs(sum(
                    case
                       when c.nombre_corto = 'PRIMAANTIGUEDAD' then
                          hn.ndcampo0
                       else 0
                    end
                 )) as primaantiguedad,
                 abs(sum(
                    case
                       when c.nombre_corto = 'PRIMANAVIDAD' then
                          hn.ndcampo0
                       else 0
                    end
                 )) as primanavidad,
                 abs(sum(
                    case
                       when c.nombre_corto = 'PRIMASECRETARIAL' then
                          hn.ndcampo0
                       else 0
                    end
                 )) as primasecretarial,
                 abs(sum(
                    case
                       when c.nombre_corto = 'PRIMASEMESTRAL' then
                          hn.ndcampo0
                       else 0
                    end
                 )) as primasemestral,
                 abs(sum(
                    case
                       when c.nombre_corto = 'PRIMASEMESTRAL_JULIO' then
                          hn.ndcampo0
                       else 0
                    end
                 )) as primasemestral_julio,
                 abs(sum(
                    case
                       when c.nombre_corto = 'PRIMATECNICA' then
                          hn.ndcampo0
                       else 0
                    end
                 )) as primatecnica,
                 abs(sum(
                    case
                       when c.nombre_corto = 'PRIMAVACACIONES' then
                          hn.ndcampo0
                       else 0
                    end
                 )) as primavacaciones,
                 abs(sum(
                    case
                       when c.nombre_corto = 'PRIMAVACACIONESPROP' then
                          hn.ndcampo0
                       else 0
                    end
                 )) as primavacacionesprop,
                 abs(sum(
                    case
                       when c.nombre_corto = 'REANUDACION_VACACIONES' then
                          hn.ndcampo0
                       else 0
                    end
                 )) as reanudacion_vacaciones,
                 abs(sum(
                    case
                       when c.nombre_corto = 'RECONOCIMIENTOPERMANENCIA' then
                          hn.ndcampo0
                       else 0
                    end
                 )) as reconocimientopermanencia,
                 abs(sum(
                    case
                       when c.nombre_corto = 'SUBSIDIOTRANSPORTE' then
                          hn.ndcampo0
                       else 0
                    end
                 )) as subsidiotransporte,
                 abs(sum(
                    case
                       when c.nombre_corto = 'SUELDOBASICO' then
                          hn.ndcampo0
                       else 0
                    end
                 )) as sueldobasico,
                 abs(sum(
                    case
                       when c.nombre_corto = 'SUELDO_DIAS_NO_TRABAJADOS' then
                          hn.ndcampo0
                       else 0
                    end
                 )) as sueldo_dias_no_trabajados,
                 abs(sum(
                    case
                       when c.nombre_corto = 'SUELDOVACACIONES_JULIO' then
                          hn.ndcampo0
                       else 0
                    end
                 )) as sueldovacaciones_julio,
                 abs(sum(
                    case
                       when c.nombre_corto = 'SUELDOVACACIONES' then
                          hn.ndcampo0
                       else 0
                    end
                 )) as sueldovacaciones,
                 abs(sum(
                    case
                       when c.nombre_corto = 'VACACIONESDINERO' then
                          hn.ndcampo0
                       else 0
                    end
                 )) as vacacionesdinero,
                 abs(sum(
                    case
                       when c.nombre_corto = 'CFONDOEMPLEADOS2' then
                          hn.ndcampo0
                       else 0
                    end
                 )) as cfondoempleados2,
                 abs(sum(
                    case
                       when c.nombre_corto = 'CFONDOEMPLEADOS1' then
                          hn.ndcampo0
                       else 0
                    end
                 )) as cfondoempleados1,
                 abs(sum(
                    case
                       when c.nombre_corto in('DIAS_SUSPENSION',
                                              'DIAS_LICENCIA',
                                              'VALOR_DIAS_NO_TRABAJADOS') then
                          hn.ndcampo0
                       else 0
                    end
                 )) as dias_no_trabajados,
                 abs(sum(
                    case
                       when c.nombre_corto = 'CEMBARGOFINANCIERO' then
                          hn.ndcampo0
                       else 0
                    end
                 )) as cembargofinanciero,
                 abs(sum(
                    case
                       when c.nombre_corto = 'CEMBARGOCIVIL' then
                          hn.ndcampo0
                       else 0
                    end
                 )) as cembargocivil,
                 abs(sum(
                    case
                       when c.nombre_corto = 'CEMBARGO' then
                          hn.ndcampo0
                       else 0
                    end
                 )) as cembargo,
                 abs(sum(
                    case
                       when c.nombre_corto = 'CFONDOEMPLEADOS3' then
                          hn.ndcampo0
                       else 0
                    end
                 )) as cfondoempleados3,
                 abs(sum(
                    case
                       when c.nombre_corto = 'CLIBRANZA' then
                          hn.ndcampo0
                       else 0
                    end
                 )) as clibranza,
                 abs(sum(
                    case
                       when c.nombre_corto = 'CAPORTEAFC' then
                          hn.ndcampo0
                       else 0
                    end
                 )) as caporteafc,
                 abs(sum(
                    case
                       when c.nombre_corto = 'CAPORTEAFP' then
                          hn.ndcampo0
                       else 0
                    end
                 )) as caporteafp,
                 abs(sum(
                    case
                       when c.nombre_corto = 'CEMBARGOFAMILIA' then
                          hn.ndcampo0
                       else 0
                    end
                 )) as cembargofamilia,
                 abs(sum(
                    case
                       when c.nombre_corto = 'CPLANCOMPLEMENTARIO' then
                          hn.ndcampo0
                       else 0
                    end
                 )) as cplancomplementario,
                 abs(sum(
                    case
                       when c.nombre_corto = 'APORTEREGIMENSOLIDARIDAD' then
                          hn.ndcampo0
                       else 0
                    end
                 )) as aporteregimensolidaridad,
                 abs(sum(
                    case
                       when c.nombre_corto = 'RETENCIONFUENTE' then
                          hn.ndcampo0
                       else 0
                    end
                 )) as retencionfuente,
                 abs(sum(
                    case
                       when c.nombre_corto = 'CSINDICATO' then
                          hn.ndcampo0
                       else 0
                    end
                 )) as csindicato
            from rh_historico_nomina hn
            join rh_concepto c
          on c.codigo_hash = hn.nhash
           where hn.dinicioperiodo >= 20180101
             and hn.dfinalperiodo <= 20250731
             and c.nombre_corto in ( 'APORTESALUD',
                                     'APORTEPENSION',
                                     'AUXILIOALIMENTACION',
                                     'BONIFICACIONRECREACION',
                                     'BONIFICACIONSERVICIOS',
                                     'RECONOCIMIENTOPROD',
                                     'CESANTIAS',
                                     'DIAS_INCAPACIDAD',
                                     'DIFERENCIA_SALARIAL',
                                     'GASTOSREPRESENTACION',
                                     'HORASEXTRAS',
                                     'HORAS_EXTRAS_DIURNAS',
                                     'HORAS_EXTRAS_HORDIUFEST',
                                     'HORAS_EXTRAS_NOCTURNAS',
                                     'HORAS EXTRAS NOCTURNAS',
                                     'HORAS_EXTRAS_HORNOCT_FEST',
                                     'HORAS_EXTRAS_100',
                                     'INCAPACIDADMATERNIDAD',
                                     'INCAPACIDADNOPROFESIONAL',
                                     'INCAPACIDADPROFESIONAL',
                                     'INTERESESCESANTIAS',
                                     'PRIMAANTIGUEDAD',
                                     'PRIMANAVIDAD',
                                     'PRIMASECRETARIAL',
                                     'PRIMASEMESTRAL',
                                     'PRIMASEMESTRAL_JULIO',
                                     'PRIMATECNICA',
                                     'PRIMAVACACIONES',
                                     'PRIMAVACACIONESPROP',
                                     'REANUDACION_VACACIONES',
                                     'RECONOCIMIENTOPERMANENCIA',
                                     'SUBSIDIOTRANSPORTE',
                                     'SUELDOBASICO',
                                     'SUELDO_DIAS_NO_TRABAJADOS',
                                     'SUELDOVACACIONES_JULIO',
                                     'SUELDOVACACIONES',
                                     'VACACIONESDINERO',
                                     'CFONDOEMPLEADOS2',
                                     'CFONDOEMPLEADOS1',
                                     'DIAS_SUSPENSION',
                                     'DIAS_LICENCIA',
                                     'VALOR_DIAS_NO_TRABAJADOS',
                                     'CEMBARGOFINANCIERO',
                                     'CEMBARGOCIVIL',
                                     'CEMBARGO',
                                     'CFONDOEMPLEADOS3',
                                     'CLIBRANZA',
                                     'CAPORTEAFC',
                                     'CAPORTEAFP',
                                     'CEMBARGOFAMILIA',
                                     'CPLANCOMPLEMENTARIO',
                                     'APORTEREGIMENSOLIDARIDAD',
                                     'RETENCIONFUENTE',
                                     'CSINDICATO' )
             and hn.brechazado = 0
             and besdefinitivo = 1
           group by hn.nfuncionario,
                    hn.dinicioperiodo
       ) hn,
  /*  (
        select distinct psc.FUNCIONARIO, d.descripcion dependencia, c.descripcion nom_cargo, 
            cargo, cargo_grado grado, cargo_nivel nivel, cc.resultado centro_costo  
        from rh_posiciones psc, rh_dependencias d, rh_cargo c, 
                (select argumento, resultado from bintablas where grupo='NOMINA'
                and nombre='CENTRO_COSTO'
                and sysdate between vig_inicial and nvl(vig_final,sysdate)) cc
        where psc.codigo_dependencia = d.codigo_dependencia
        and psc.cargo = c.codigo_cargo
        and psc.cargo_grado = c.grado
        and psc.cargo_nivel = c.nivel
        and d.centro_costo = cc.argumento
        and funcionario is not null
        and sysdate between psc.fecha_inicial and nvl(psc.fecha_final,sysdate)
    ) psc,*/
       (
          select a.funcionario,
                 to_number(to_char(a.ano)
                           || lpad(
                    to_char(a.mes),
                    2,
                    '0'
                 )
                           || '01') periodo,
                 sum(
                    case
                       when a.tipo_aporte = 'PENSIONES' then
                          a.aporte_entidad
                       else
                          0
                    end
                 ) as aportepensionpatrono,
                 sum(
                    case
                       when a.tipo_aporte = 'PENSIONES' then
                          a.aporte_funcionario
                       else
                          0
                    end
                 ) as aportepesionempleado,
                 sum(
                    case
                       when a.tipo_aporte = 'SALUD' then
                          a.aporte_entidad
                       else
                          0
                    end
                 ) as aportesaludpatrono,
                 sum(
                    case
                       when a.tipo_aporte = 'SALUD' then
                          a.aporte_funcionario
                       else
                          0
                    end
                 ) as aportesaludempleado
            from rh_aportes a
           where ( a.ano between 2018 and 2025 )
             and a.tipo_aporte in ( 'PENSIONES',
                                    'SALUD' ) 
        --and a.funcionario = 34
           group by a.funcionario,
                    a.ano,
                    a.mes
       ) ss,
       (
          select *
            from rh_entidad
           where tipo_servicio like 'PENSIONES'
       ) pe,
       (
          select *
            from rh_entidad
           where tipo_servicio = 'SALUD'
       ) sa
 where p.interno_persona = f.personas_interno
   and p.interno_persona = hn.nfuncionario
   and f.personas_interno = hn.nfuncionario
   and f.codigo_fondo_pensiones = pe.codigo
   and f.codigo_eps = sa.codigo
--and p.interno_persona = psc.funcionario
--and f.personas_interno = psc.funcionario
--and hn.nfuncionario = psc.funcionario
   and p.interno_persona = ss.funcionario
   and f.personas_interno = ss.funcionario
   and hn.nfuncionario = ss.funcionario
--and psc.funcionario = ss.funcionario
   and hn.dinicioperiodo = ss.periodo
   and p.numero_identificacion in ( 51605363 ) /* 23495638, 45454959,79355621, 37891855, 
                                79329628, 51753989, 79315507, 35325745, 
                                51978047, 24022412, 39789074, 79489819, 
                                51665925, 51605363, 52116283, 51841009, 
                                6762048, 51653368, 51564303, 40030681, 
                                80039413, 79536419, 30401728, 52750014, 
                                53116209, 74369918, 37726651, 1049606827, 
                                29328794, 79737305, 20730522, 1015404700, 
                                51852403, 53141042, 79455999, 52227361,
                                52866026 )*/
--and p.numero_identificacion = 6762048 and dinicioperiodo = 20180101                                
--order by DINICIOPERIODO
   ;