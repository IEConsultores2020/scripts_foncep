                                            Dependencia CargoNivel  Cargo   CargoGrado
/*
Subdirectores Todas las dependencias de la entidad         
Asesor todas las dependencias de la entidad         
*/

select *  --count(1) 
from rh_dependencias
;

--Tipo acto 010 de nombramiento
-- 040 encargo
-- 100 retiro
select p.numero_identificacion, t1.*
from rh_personas p,
    (select da.funcionario, da.valor id_cargo,--da.fecha_acto, --da.secuencia, aa.tipo_acto, aa.fecha_efectividad, aa.fecha_final,
            decode(da.tipo_acto,'040',aa.fecha_efectividad, '010',aa.fecha_efectividad,null) fecha_inicio,
            decode(da.tipo_acto,'040',aa.fecha_final,'100',aa.fecha_efectividad,null) fecha_final
    from rh_detalle_acto da, rh_actos_administrativos aa
    where da.nombre_detalle='POSICION'
    and da.valor in (618,611)
    and aa.secuencia=da.secuencia
    order by da.valor, da.fecha_acto asc) t1
where t1.fecha_inicio is not null or t1.fecha_final is not null  and
 p.interno_persona = t1.funcionario  
order by t1.id_cargo, t1.fecha_inicio desc
;

select *
from rh_posiciones 
where cargo='068' and cargo_grado=2
and codigo_dependencia=200
;


---asesor
select p.secuencia, d.descripcion
from rh_posiciones p, rh_dependencias d
where  p.codigo_dependencia=d.codigo_dependencia
and to_number(p.cargo)=105 and to_number(p.cargo_grado) between 1 and 5
and cargo_nivel=1 --asesor
union
--subdirector administrativo y financiero
---asesor
select p.secuencia, d.descripcion
from rh_posiciones p, rh_dependencias d
where  p.codigo_dependencia=d.codigo_dependencia
and to_number(p.cargo)=68 and to_number(p.cargo_grado) in (7,2)
and cargo_nivel=0 --directivo
;

---0 directivo, 1 asesor
select * --p.SECUENCIA
from rh_posiciones p
where to_number(p.cargo)=105 and to_number(p.cargo_grado) between 1 and 5
and p.cargo_nivel=1 
union
--subdirector administrativo y financiero
---asesor
select p.secuencia
from rh_posiciones p
where  to_number(p.cargo)=68 and to_number(p.cargo_grado) in (7,2)
and p.cargo_nivel=0 
;

select *
from rh_tipos_acto_nove
where nombre like '%RENUNCIA%'
;

--Subdirectores
select decode(posic.cargo_nivel,0,'SUBDIRECTOR',1,'ASESOR','OTRO') nivel, d.descripcion, 
    p.numero_identificacion, p.nombres||' '||p.primer_apellido||' '||p.segundo_apellido nombre, 
    hc.id_cargo, hc.fecha_inicio, hc.fecha_final
from rh_personas p
join 
     ( select ti.funcionario, 
            ti.id_cargo,
            ti.fecha_inicio, tf.fecha_final
        from
        (select da.funcionario, da.valor id_cargo, aa.fecha_efectividad fecha_inicio
            from rh_detalle_acto da
                join rh_actos_administrativos aa
                on aa.secuencia=da.secuencia
                and da.nombre_detalle='POSICION' 
                and da.valor in (
                                    select p.SECUENCIA
                                        from rh_posiciones p
                                        where to_number(p.cargo)=105 and to_number(p.cargo_grado) between 1 and 5
                                        and p.cargo_nivel=1 
                                        union
                                        --subdirector administrativo y financiero
                                        ---asesor
                                        select p.secuencia
                                        from rh_posiciones p
                                        where  to_number(p.cargo)=68 and to_number(p.cargo_grado) in (7,2)
                                        and p.cargo_nivel=0 
                                ) 
                and da.tipo_acto='010'
            order by da.valor, da.fecha_acto asc    ) ti
        left outer join    
        (select da.funcionario, da.valor id_cargo, aa.fecha_efectividad-1 fecha_final
            from rh_detalle_acto da
                join rh_actos_administrativos aa
                on aa.secuencia=da.secuencia 
                and da.nombre_detalle='POSICION' 
                and da.valor in (
                                select p.SECUENCIA
                                        from rh_posiciones p
                                        where to_number(p.cargo)=105 and to_number(p.cargo_grado) between 1 and 5
                                        and p.cargo_nivel=1 
                                        union
                                        --subdirector administrativo y financiero
                                        ---asesor
                                        select p.secuencia
                                        from rh_posiciones p
                                        where  to_number(p.cargo)=68 and to_number(p.cargo_grado) in (7,2)
                                        and p.cargo_nivel=0 
                                ) 
                and da.tipo_acto='100'
            order by da.valor, da.fecha_acto asc    ) tf 
        on ti.funcionario=tf.funcionario 
        and ti.id_cargo = tf.id_cargo     
        union
        select da.funcionario,         
               da.valor id_cargo, 
            aa.fecha_efectividad fecha_inicio, aa.fecha_final
            from rh_detalle_acto da, rh_actos_administrativos aa
            where da.nombre_detalle='POSICION'
            and da.valor in (select p.SECUENCIA
                            from rh_posiciones p
                            where to_number(p.cargo)=105 and to_number(p.cargo_grado) between 1 and 5
                            and p.cargo_nivel=1 
                            union
                            --subdirector administrativo y financiero
                            --asesor
                            select p.secuencia
                            from rh_posiciones p
                            where  to_number(p.cargo)=68 and to_number(p.cargo_grado) in (7,2)
                            and p.cargo_nivel=0 )
            and aa.secuencia=da.secuencia
            and da.tipo_acto='040'
        order by 2,3
        ) hc        
on p.interno_persona = hc.funcionario        
join rh_posiciones posic on posic.secuencia=hc.id_cargo
join rh_dependencias d on d.codigo_dependencia=posic.codigo_dependencia
--where numero_identificacion = 24022412
order by 1,2, fecha_inicio desc
;

