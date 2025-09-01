--EXCEL PENSIONES
select sa.descripcion ent_salud, pe.descripcion ent_pension,
    psc.dependencia, psc.centro_costo, cargo cod_cargo, nom_cargo, grado, 
    p.numero_identificacion cedula,
    p.nombres||' '||p.primer_apellido||' '||p.segundo_apellido as nombres_y_apellidos
from rh_personas p, rh_funcionario f, 
    (select distinct psc.FUNCIONARIO, d.descripcion dependencia, c.descripcion nom_cargo, 
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
    and sysdate between psc.fecha_inicial and nvl(psc.fecha_final,sysdate)) psc,
    (select * from rh_entidad where tipo_servicio LIKE 'PENSIONES') pe,
    (select * from rh_entidad where tipo_servicio = 'SALUD') sa
where p.interno_persona = f.personas_interno
and f.CODIGO_FONDO_PENSIONES = pe.codigo
and f.codigo_eps = sa.codigo
and p.interno_persona = psc.funcionario
order by 1
;


select *
from bintablas
where grupo='NOMINA'
and nombre='CENTRO_COSTO'
;

 AND
 (a.ano between 2018 and  2025) and
 (a.mes between 1 and 12) and 
 a.tipo_aporte = 'PENSIONES' AND
 b.numero_identificacion in ( 23495638, 
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
group by a.ano, a.mes, b.numero_identificacion, b.primer_apellido, b.segundo_apellido, b.nombres, a.tipo_aporte
order by b.nombres, b.primer_apellido, b.segundo_apellido, a.ano, a.mes
;

select CODIGO_HASH, NOMBRE
from rh_concepto
--WHERE NOMBRE LIKE '%LIBRAN%'
where nombre_CORTO IN ('APORTESALUD'/*APO.SALUD PATRONO*/,'APORTEPENSION'/*AP.PENSION PATRONO*/,'AUXILIOALIMENTACION',
                        'BONIFICACIONRECREACION','BONIFICACIONSERVICIOS','BONIFICACIONRECREACION',
                        'RECONOCIMIENTOPROD','CESANTIAS','DIAS_INCAPACIDAD','DIFERENCIA_SALARIAL','GASTOSREPRESENTACION',
                        'HORASEXTRAS','HORAS_EXTRAS_DIURNAS','HORAS_EXTRAS_HORDIUFEST','HORAS_EXTRAS_NOCTURNAS',
                        'HORAS EXTRAS NOCTURNAS', 'HORAS_EXTRAS_HORNOCT_FEST','HORAS_EXTRAS_100','INCAPACIDADMATERNIDAD',
                        'INCAPACIDADNOPROFESIONAL','INCAPACIDADPROFESIONAL','INTERESESCESANTIAS','PRIMAANTIGUEDAD',
                        'PRIMANAVIDAD','PRIMASECRETARIAL','PRIMASEMESTRAL','PRIMASEMESTRAL_JULIO','PRIMATECNICA',
                        'PRIMAVACACIONES','PRIMAVACACIONESPROP','REANUDACION_VACACIONES','RECONOCIMIENTOPERMANENCIA', 
                        'SUBSIDIOTRANSPORTE','SUELDOBASICO',
                        'SUELDO_DIAS_NO_TRABAJADOS', /*DEBERIA ESTAR EN DIAS_NO_TRABAJAD*/
                        'SUELDOVACACIONES_JULIO','SUELDOVACACIONES',  /* SUELDO VACACIONES*/
                        'VACACIONESDINERO','CFONDOEMPLEADOS2' /*ADMON FONDO EMPLEADOS FAVIDI*/,
                        'CFONDOEMPLEADOS1' /* APORTE FONDO EMPLEADOS FAVIDI*/, 
                        'APORTESALUD'/*APO.SALUD EMP*/,'APORTEPENSION'/*APO.PENSION EMP*/,
                        ---
                        'DIAS_SUSPENSION','DIAS_LICENCIA','VALOR_DIAS_NO_TRABAJADOS', /*DIAS_NO_TRABAJAD en uno solo*/
                        ---
                        'CEMBARGOFINANCIERO','CEMBARGOCIVIL','CEMBARGO', /*EMBARGOS SEPARADOS*/
                        ---
                        'CFONDOEMPLEADOS3' /*LIBRANZA FONDO EMPLEADOS FAVIDI*/,
                        'CLIBRANZA' /*PAGO DE LIBRANZA*/,
                        'CAPORTEAFC','CAPORTEAFP',  /*APORTES_OTRAS_CO?*/
                        'CEMBARGOFAMILIA','CLIBRANZA','CFONDOEMPLEADOS3', /*LIBRANZA FONDO EMPLEADOS FAVIDI*/
                        'CPLANCOMPLEMENTARIO','APORTEREGIMENSOLIDARIDAD' /*FONDO_SOLIDARIDAD*/,
                        'RETENCIONFUENTE','CSINDICATO')

/*    
dias no trabajado en uno solo.
embargos separados
aportes salud y pensión patrono no está en hn.
aporte salud y pensión del funcionario
*/