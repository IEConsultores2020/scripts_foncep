select p.numero_identificacion, p.nombres||' '||p.primer_apellido||' '||p.segundo_apellido, 
    ta.nombre nombre, to_char(a.fecha_acto,'DD/MM/YYYY') fecha_acto, 
    a.numero_acto, to_char(a.fecha_efectividad,'DD/MM/YYYY') fecha_efectividad 
from rh_personas p, rh_funcionario f, rh_actos_administrativos a, 
    rh_tipos_acto_nove ta --, rh_detalle_acto da
where p.interno_persona = f.personas_interno
and p.interno_persona = a.funcionario 
and f.personas_interno = a.funcionario
--and f.estado_funcionario = 1
and a.tipo_acto = ta.codigo_tipo
and ta.nombre like '%PRIMA%TEC%' /*
and da.funcionario = a.funcionario
and da.funcionario = p.interno_persona
and da.funcionario = f.personas_interno*/
order by 2, 3
;

select * --codigo_tipo, codigo_hash
from RH_TIPOS_ACTO_NOVE
where nombre like '%PRIMA%TEC%';

select *
from rh_detalle_acto