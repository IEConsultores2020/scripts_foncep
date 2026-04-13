                                            Dependencia CargoNivel  Cargo   CargoGrado
/*
Subdirector Administrativo y Financiero     200         PROFESIONAL 068     2
Asesor Responsable del area de TH           260
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

select *
from rh_tipos_acto_nove
where nombre like '%RENUNCIA%'

/*
Interno IDCargo     Cargo
649     611         Asesor Talento Humano
635     618         Subdirección Administrativa y Financiera

"INTERNO_PERSONA","NUMERO_IDENTIFICACION"
45,"40030681"
619,"1026566862"
620,"79304477"
638,"52951267"
643,"45499003"
649,"1030575813"
*/

select interno_persona, numero_identificacion
from rh_personas
where interno_persona in (45,620,638,649,619,643)
;



select p.numero_identificacion, p.nombres||' '||p.primer_apellido||' '||p.segundo_apellido nombre, hc.cargo, hc.fecha_inicio, hc.fecha_final
from rh_personas p
join 
     ( select ti.funcionario, 
                decode(ti.id_cargo,611,'ASESOR/AREA DE TALENTOHUMANO',
                                618,'SUBDIRECTOR/SUBDIRECCION FINANCIERA Y ADMINISTRATIVA','') cargo,
            ti.fecha_inicio, tf.fecha_final
        from
        (select da.funcionario, da.valor id_cargo, aa.fecha_efectividad fecha_inicio
            from rh_detalle_acto da
                join rh_actos_administrativos aa
                on aa.secuencia=da.secuencia
                and da.nombre_detalle='POSICION' and da.valor in (618,611) and da.tipo_acto='010'
            order by da.valor, da.fecha_acto asc    ) ti
        left outer join    
        (select da.funcionario, da.valor id_cargo, aa.fecha_efectividad-1 fecha_final
            from rh_detalle_acto da
                join rh_actos_administrativos aa
                on aa.secuencia=da.secuencia 
                and da.nombre_detalle='POSICION' and da.valor in (618,611) and da.tipo_acto='100'
            order by da.valor, da.fecha_acto asc    ) tf 
        on ti.funcionario=tf.funcionario 
        and ti.id_cargo = tf.id_cargo     
        union
        select da.funcionario,         
                decode(da.valor,611,'ASESOR/AREA DE TALENTOHUMANO',
                                618,'SUBDIRECTOR/SUBDIRECCION FINANCIERA Y ADMINISTRATIVA','') cargo, 
            aa.fecha_efectividad fecha_inicio, aa.fecha_final
            from rh_detalle_acto da, rh_actos_administrativos aa
            where da.nombre_detalle='POSICION'
            and da.valor in (618,611)
            and aa.secuencia=da.secuencia
            and da.tipo_acto='040'
        order by 2,3
        ) hc
on p.interno_persona = hc.funcionario        
order by cargo, fecha_inicio