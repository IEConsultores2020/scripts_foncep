--2026002460 Buen día, comedidamente solicito elaborar reporte en excel de Perno de los servidores activos con la fecha de naciemiento y edad de cada uno

select p.numero_identificacion, p.numero_identificacion, p.nombres||' '||p.primer_apellido||' '||p.segundo_apellido as nombre_completo, p.fecha_nacimiento, trunc(months_between(sysdate, p.fecha_nacimiento)/12) as "edad_años"
--select p.*
from rh_funcionario f, rh_personas p
where f.personas_interno = p.interno_persona
and f.estado_funcionario =1
order by 2
;