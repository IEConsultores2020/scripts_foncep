select p.numero_identificacion cedula, 
   p.nombres||' '||p.primer_apellido||' '||trim(p.segundo_apellido) nombres, 
   --e.descripcion EPS,
   tan.descripcion tipo_incapacidad, n.numero_novedad numero_radicado,
    n.fecha_novedad,  dn.fecha_efectiva fecha_inicio, 
   dn.dias, dn.prorroga
from  rh_personas p, rh_funcionario f, 
   rh_entidad e, rh_tipos_acto_nove tan,  rh_novedades n, 
   --rh_detalle_novedad dn
 (select dnp.funcionario, dnp.tipo_novedad, dnp.numero_novedad, dnp.fecha_novedad, decode(dnp.prorroga,'CIERTO','S','N') prorroga, dnd.dias, dnf.fecha_efectiva
 from   
 (select funcionario, tipo_novedad, numero_novedad, fecha_novedad, valor prorroga from rh_detalle_novedad where nombre_detalle='PRORROGA') dnp,
 (select funcionario, tipo_novedad, numero_novedad, fecha_novedad, valor dias from rh_detalle_novedad where nombre_detalle='DIAS') dnd,
 (select funcionario, tipo_novedad, numero_novedad, fecha_novedad, valor fecha_efectiva from rh_detalle_novedad where nombre_detalle='FECHANOMINA') dnf
 where 
   dnp.funcionario = dnd.funcionario 
   and dnp.tipo_novedad = dnd.tipo_novedad
   and dnp.numero_novedad = dnd.numero_novedad
   and dnp.fecha_novedad = dnd.fecha_novedad
   and dnp.funcionario = dnf.funcionario 
   and dnp.tipo_novedad = dnf.tipo_novedad
   and dnp.numero_novedad = dnf.numero_novedad
   and dnp.fecha_novedad = dnf.fecha_novedad) dn
where p.interno_persona = n.funcionario 
and p.interno_persona = f.personas_interno
and f.personas_interno = dn.funcionario
and p.interno_persona = dn.funcionario
and f.codigo_eps = e.codigo
and f.tipo_eps = e.tipo
and tan.nombre like '%INCAP%'
and tan.codigo_tipo = n.tipo_novedad
and n.funcionario = dn.funcionario
and n.tipo_novedad = dn.tipo_novedad
and n.numero_novedad = dn.numero_novedad
and n.fecha_novedad = dn.fecha_novedad
and n.fecha_novedad >= '01-JAN-2025'
--and p.numero_identificacion = 39789074
ORDER BY 2,6 desc
;

