/*
2026003842 Liquidaciones realizadas a personas retiradas del nivel directivo y asesor desde el 2024 hasta noviembre 2026
*/

select p.numero_identificacion, p.nombres, p.primer_apellido, p.segundo_apellido, 
    t1.fecha_acto, t1.fecha_efectividad, ps.cargo, ps.cargo_grado, ps.cargo_nivel, 
    d.descripcion dependencia
from rh_personas p,
    (select da.funcionario, da.valor id_cargo, da.fecha_acto, aa.fecha_efectividad
    from rh_actos_administrativos aa
    join rh_detalle_acto da on aa.secuencia=da.secuencia
        and da.nombre_detalle='POSICION' --and da.valor in ('0','1')
        and da.tipo_acto ='100'
        and aa.fecha_efectividad >= '01-JAN-24'
    order by da.valor, da.fecha_acto asc) t1
    join rh_posiciones ps on ps.secuencia=t1.id_cargo
    join rh_dependencias d on d.codigo_dependencia = ps.codigo_dependencia
where p.interno_persona = t1.funcionario  
and ps.cargo_nivel in  (0,1)
order by 1
;


select 1 from dual