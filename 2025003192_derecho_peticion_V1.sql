--EXCEL CONCEPTOS DEVENGADOS Y DEDUCIDOS
select sa.descripcion ent_salud, pe.descripcion ent_pension,
    psc.dependencia, psc.centro_costo, cargo cod_cargo, nom_cargo, grado, 
    p.numero_identificacion cedula,
    p.nombres||' '||p.primer_apellido||' '||p.segundo_apellido as nombres_y_apellidos,
    ss.*,
    hn.*
from rh_personas p, rh_funcionario f, 
    (
        SELECT hn.nfuncionario, hn.dinicioperiodo,
            ABS(SUM(CASE WHEN C.nombre_corto = 'AUXILIOALIMENTACION' THEN hn.ndcampo0 ELSE 0 END)) AS AUXILIOALIMENTACION,
            ABS(SUM(CASE WHEN C.nombre_corto = 'BONIFICACIONRECREACION' THEN hn.ndcampo0 ELSE 0 END)) AS BONIFICACIONRECREACION,
            ABS(SUM(CASE WHEN C.nombre_corto = 'BONIFICACIONSERVICIOS' THEN hn.ndcampo0 ELSE 0 END)) AS BONIFICACIONSERVICIOS,
            ABS(SUM(CASE WHEN C.nombre_corto = 'RECONOCIMIENTOPROD' THEN hn.ndcampo0 ELSE 0 END)) AS RECONOCIMIENTOPROD,
            ABS(SUM(CASE WHEN C.nombre_corto = 'CESANTIAS' THEN hn.ndcampo0 ELSE 0 END)) AS CESANTIAS,
            ABS(SUM(CASE WHEN C.nombre_corto = 'DIAS_INCAPACIDAD' THEN hn.ndcampo0 ELSE 0 END)) AS DIAS_INCAPACIDAD,
            ABS(SUM(CASE WHEN C.nombre_corto = 'DIFERENCIA_SALARIAL' THEN hn.ndcampo0 ELSE 0 END)) AS DIFERENCIA_SALARIAL,
            ABS(SUM(CASE WHEN C.nombre_corto = 'GASTOSREPRESENTACION' THEN hn.ndcampo0 ELSE 0 END)) AS GASTOSREPRESENTACION,
            ABS(SUM(CASE WHEN C.nombre_corto = 'HORASEXTRAS' THEN hn.ndcampo0 ELSE 0 END)) AS HORAS_EXTRAS,
            ABS(SUM(CASE WHEN C.nombre_corto = 'HORAS_EXTRAS_DIURNAS' THEN hn.ndcampo0 ELSE 0 END)) AS HORAS_EXTRAS_DIURNAS,
            ABS(SUM(CASE WHEN C.nombre_corto = 'HORAS_EXTRAS_HORDIUFEST' THEN hn.ndcampo0 ELSE 0 END)) AS HORAS_EXTRAS_HORDIUFEST,
            ABS(SUM(CASE WHEN C.nombre_corto = 'HORAS_EXTRAS_NOCTURNAS' THEN hn.ndcampo0 ELSE 0 END)) AS HORAS_EXTRAS_NOCTURNAS,
            ABS(SUM(CASE WHEN C.nombre_corto = 'HORAS_EXTRAS_HORNOCT_FEST' THEN hn.ndcampo0 ELSE 0 END)) AS HORAS_EXTRAS_HORNOCT_FEST,
            ABS(SUM(CASE WHEN C.nombre_corto = 'HORAS_EXTRAS_100' THEN hn.ndcampo0 ELSE 0 END)) AS HORAS_EXTRAS_100,
            ABS(SUM(CASE WHEN C.nombre_corto = 'INCAPACIDADMATERNIDAD' THEN hn.ndcampo0 ELSE 0 END)) AS INCAPACIDADMATERNIDAD,
            ABS(SUM(CASE WHEN C.nombre_corto = 'INCAPACIDADNOPROFESIONAL' THEN hn.ndcampo0 ELSE 0 END)) AS INCAPACIDADNOPROFESIONAL,
            ABS(SUM(CASE WHEN C.nombre_corto = 'INCAPACIDADPROFESIONAL' THEN hn.ndcampo0 ELSE 0 END)) AS INCAPACIDADPROFESIONAL,
            ABS(SUM(CASE WHEN C.nombre_corto = 'INTERESESCESANTIAS' THEN hn.ndcampo0 ELSE 0 END)) AS INTERESESCESANTIAS,
            ABS(SUM(CASE WHEN C.nombre_corto = 'PRIMAANTIGUEDAD' THEN hn.ndcampo0 ELSE 0 END)) AS PRIMAANTIGUEDAD,
            ABS(SUM(CASE WHEN C.nombre_corto = 'PRIMANAVIDAD' THEN hn.ndcampo0 ELSE 0 END)) AS PRIMANAVIDAD,
            ABS(SUM(CASE WHEN C.nombre_corto = 'PRIMASECRETARIAL' THEN hn.ndcampo0 ELSE 0 END)) AS PRIMASECRETARIAL,
            ABS(SUM(CASE WHEN C.nombre_corto = 'PRIMASEMESTRAL' THEN hn.ndcampo0 ELSE 0 END)) AS PRIMASEMESTRAL,
            ABS(SUM(CASE WHEN C.nombre_corto = 'PRIMASEMESTRAL_JULIO' THEN hn.ndcampo0 ELSE 0 END)) AS PRIMASEMESTRAL_JULIO,
            ABS(SUM(CASE WHEN C.nombre_corto = 'PRIMATECNICA' THEN hn.ndcampo0 ELSE 0 END)) AS PRIMATECNICA,
            ABS(SUM(CASE WHEN C.nombre_corto = 'PRIMAVACACIONES' THEN hn.ndcampo0 ELSE 0 END)) AS PRIMAVACACIONES,
            ABS(SUM(CASE WHEN C.nombre_corto = 'PRIMAVACACIONESPROP' THEN hn.ndcampo0 ELSE 0 END)) AS PRIMAVACACIONESPROP,
            ABS(SUM(CASE WHEN C.nombre_corto = 'REANUDACION_VACACIONES' THEN hn.ndcampo0 ELSE 0 END)) AS REANUDACION_VACACIONES,
            ABS(SUM(CASE WHEN C.nombre_corto = 'RECONOCIMIENTOPERMANENCIA' THEN hn.ndcampo0 ELSE 0 END)) AS RECONOCIMIENTOPERMANENCIA,
            ABS(SUM(CASE WHEN C.nombre_corto = 'SUBSIDIOTRANSPORTE' THEN hn.ndcampo0 ELSE 0 END)) AS SUBSIDIOTRANSPORTE,
            ABS(SUM(CASE WHEN C.nombre_corto = 'SUELDOBASICO' THEN hn.ndcampo0 ELSE 0 END)) AS SUELDOBASICO,
            ABS(SUM(CASE WHEN C.nombre_corto = 'SUELDO_DIAS_NO_TRABAJADOS' THEN hn.ndcampo0 ELSE 0 END)) AS SUELDO_DIAS_NO_TRABAJADOS,
            ABS(SUM(CASE WHEN C.nombre_corto = 'SUELDOVACACIONES_JULIO' THEN hn.ndcampo0 ELSE 0 END)) AS SUELDOVACACIONES_JULIO,
            ABS(SUM(CASE WHEN C.nombre_corto = 'SUELDOVACACIONES' THEN hn.ndcampo0 ELSE 0 END)) AS SUELDOVACACIONES,
            ABS(SUM(CASE WHEN C.nombre_corto = 'VACACIONESDINERO' THEN hn.ndcampo0 ELSE 0 END)) AS VACACIONESDINERO,
            ABS(SUM(CASE WHEN C.nombre_corto = 'CFONDOEMPLEADOS2' THEN hn.ndcampo0 ELSE 0 END)) AS CFONDOEMPLEADOS2,
            ABS(SUM(CASE WHEN C.nombre_corto = 'CFONDOEMPLEADOS1' THEN hn.ndcampo0 ELSE 0 END)) AS CFONDOEMPLEADOS1,
            ABS(SUM(CASE WHEN C.nombre_corto IN ('DIAS_SUSPENSION','DIAS_LICENCIA','VALOR_DIAS_NO_TRABAJADOS') THEN hn.ndcampo0 ELSE 0 END)) AS DIAS_NO_TRABAJADOS,
            ABS(SUM(CASE WHEN C.nombre_corto = 'CEMBARGOFINANCIERO' THEN hn.ndcampo0 ELSE 0 END)) AS CEMBARGOFINANCIERO,
            ABS(SUM(CASE WHEN C.nombre_corto = 'CEMBARGOCIVIL' THEN hn.ndcampo0 ELSE 0 END)) AS CEMBARGOCIVIL,
            ABS(SUM(CASE WHEN C.nombre_corto = 'CEMBARGO' THEN hn.ndcampo0 ELSE 0 END)) AS CEMBARGO,
            ABS(SUM(CASE WHEN C.nombre_corto = 'CFONDOEMPLEADOS3' THEN hn.ndcampo0 ELSE 0 END)) AS CFONDOEMPLEADOS3,
            ABS(SUM(CASE WHEN C.nombre_corto = 'CLIBRANZA' THEN hn.ndcampo0 ELSE 0 END)) AS CLIBRANZA,
            ABS(SUM(CASE WHEN C.nombre_corto = 'CAPORTEAFC' THEN hn.ndcampo0 ELSE 0 END)) AS CAPORTEAFC,
            ABS(SUM(CASE WHEN C.nombre_corto = 'CAPORTEAFP' THEN hn.ndcampo0 ELSE 0 END)) AS CAPORTEAFP,
            ABS(SUM(CASE WHEN C.nombre_corto = 'CEMBARGOFAMILIA' THEN hn.ndcampo0 ELSE 0 END)) AS CEMBARGOFAMILIA,
            ABS(SUM(CASE WHEN C.nombre_corto = 'CPLANCOMPLEMENTARIO' THEN hn.ndcampo0 ELSE 0 END)) AS CPLANCOMPLEMENTARIO,
            ABS(SUM(CASE WHEN C.nombre_corto = 'APORTEREGIMENSOLIDARIDAD' THEN hn.ndcampo0 ELSE 0 END)) AS APORTEREGIMENSOLIDARIDAD,
            ABS(SUM(CASE WHEN C.nombre_corto = 'RETENCIONFUENTE' THEN hn.ndcampo0 ELSE 0 END)) AS RETENCIONFUENTE,
            ABS(SUM(CASE WHEN C.nombre_corto = 'CSINDICATO' THEN hn.ndcampo0 ELSE 0 END)) AS CSINDICATO
        FROM
            rh_historico_nomina hn
        JOIN
            rh_concepto C ON c.codigo_hash = hn.nhash
        WHERE
            hn.dinicioperiodo >= 20180101
            AND hn.dfinalperiodo <= 20250731
            AND C.nombre_corto IN (
                'APORTESALUD', 'APORTEPENSION', 'AUXILIOALIMENTACION', 'BONIFICACIONRECREACION', 'BONIFICACIONSERVICIOS',
                'RECONOCIMIENTOPROD', 'CESANTIAS', 'DIAS_INCAPACIDAD', 'DIFERENCIA_SALARIAL', 'GASTOSREPRESENTACION',
                'HORASEXTRAS', 'HORAS_EXTRAS_DIURNAS', 'HORAS_EXTRAS_HORDIUFEST', 'HORAS_EXTRAS_NOCTURNAS',
                'HORAS EXTRAS NOCTURNAS', 'HORAS_EXTRAS_HORNOCT_FEST', 'HORAS_EXTRAS_100', 'INCAPACIDADMATERNIDAD',
                'INCAPACIDADNOPROFESIONAL', 'INCAPACIDADPROFESIONAL', 'INTERESESCESANTIAS', 'PRIMAANTIGUEDAD',
                'PRIMANAVIDAD', 'PRIMASECRETARIAL', 'PRIMASEMESTRAL', 'PRIMASEMESTRAL_JULIO', 'PRIMATECNICA',
                'PRIMAVACACIONES', 'PRIMAVACACIONESPROP', 'REANUDACION_VACACIONES', 'RECONOCIMIENTOPERMANENCIA',
                'SUBSIDIOTRANSPORTE', 'SUELDOBASICO', 'SUELDO_DIAS_NO_TRABAJADOS', 'SUELDOVACACIONES_JULIO',
                'SUELDOVACACIONES', 'VACACIONESDINERO', 'CFONDOEMPLEADOS2', 'CFONDOEMPLEADOS1',
                'DIAS_SUSPENSION', 'DIAS_LICENCIA', 'VALOR_DIAS_NO_TRABAJADOS', 'CEMBARGOFINANCIERO',
                'CEMBARGOCIVIL', 'CEMBARGO', 'CFONDOEMPLEADOS3', 'CLIBRANZA', 'CAPORTEAFC', 'CAPORTEAFP',
                'CEMBARGOFAMILIA', 'CPLANCOMPLEMENTARIO', 'APORTEREGIMENSOLIDARIDAD', 'RETENCIONFUENTE', 'CSINDICATO'
            )
            AND hn.brechazado = 0
            AND besdefinitivo = 1
        GROUP BY
            hn.nfuncionario,
            hn.dinicioperiodo
    ) hn,
    (
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
    ) psc,
    (select * from rh_entidad where tipo_servicio LIKE 'PENSIONES') pe,
    (select * from rh_entidad where tipo_servicio = 'SALUD') sa,
    (
    select a.funcionario, --a.ano, a.mes,
        to_number(to_char(a.ano)||lpad(to_char(a.mes),2,'0')||'01') periodo,
        SUM(CASE WHEN a.tipo_aporte = 'PENSIONES' THEN a.aporte_entidad ELSE 0 END) AS APORTEPENSIONPATRONO,
        SUM(CASE WHEN  a.tipo_aporte = 'PENSIONES' THEN a.aporte_funcionario ELSE 0 END) AS APORTEPESIONEMPLEADO, 
        SUM(CASE WHEN a.tipo_aporte = 'SALUD' THEN a.aporte_entidad ELSE 0 END) AS APORTESALUDPATRONO,
        SUM(CASE WHEN  a.tipo_aporte = 'SALUD' THEN a.aporte_funcionario ELSE 0 END) AS APORTESALUDEMPLEADO
    from rh_aportes a
    where (a.ano between 2018 and  2025) and 
    (a.mes between 1 and 12) and 
    a.tipo_aporte IN ('PENSIONES','SALUD') 
    group by a.funcionario, a.ano, a.mes,  a.tipo_aporte
    ) ss
where p.interno_persona = f.personas_interno
and p.interno_persona = hn.nfuncionario
and f.personas_interno = hn.nfuncionario
and p.interno_persona = ss.funcionario
and f.personas_interno = ss.funcionario
and hn.nfuncionario = ss.funcionario
and f.CODIGO_FONDO_PENSIONES = pe.codigo
and f.codigo_eps = sa.codigo
and p.interno_persona = psc.funcionario
and hn.dinicioperiodo = ss.periodo
and p.numero_identificacion in ( 23495638, 45454959,79355621, 37891855, 
                                79329628, 51753989, 79315507, 35325745, 
                                51978047, 24022412, 39789074, 79489819, 
                                51665925, 51605363, 52116283, 51841009, 
                                6762048, 51653368, 51564303, 40030681, 
                                80039413, 79536419, 30401728, 52750014, 
                                53116209, 74369918, 37726651, 1049606827, 
                                29328794, 79737305, 20730522, 1015404700, 
                                51852403, 53141042, 79455999, 52227361,
                                52866026 )
order by 1
;


/*    
aportes salud y pensión patrono no está en hn.
aporte salud y pensión del funcionario
*/

--EXCEL PENSIONES
select a.funcionario, a.ano, a.mes,
    to_char(a.ano)||lpad(to_char(a.mes),2,'0')||'01' periodo,
    SUM(CASE WHEN a.tipo_aporte = 'PENSIONES' THEN a.aporte_entidad ELSE 0 END) AS APORTEPENSIONPATRONO,
    SUM(CASE WHEN  a.tipo_aporte = 'PENSIONES' THEN a.aporte_funcionario ELSE 0 END) AS APORTEPESIONEMPLEADO, 
    SUM(CASE WHEN a.tipo_aporte = 'SALUD' THEN a.aporte_entidad ELSE 0 END) AS APORTESALUDPATRONO,
    SUM(CASE WHEN  a.tipo_aporte = 'SALUD' THEN a.aporte_funcionario ELSE 0 END) AS APORTESALUDEMPLEADO
from rh_aportes a
where (a.ano between 2018 and  2025) and 
 (a.mes between 1 and 12) and 
 a.tipo_aporte IN ('PENSIONES','SALUD') 
group by a.funcionario, a.ano, a.mes,  a.tipo_aporte