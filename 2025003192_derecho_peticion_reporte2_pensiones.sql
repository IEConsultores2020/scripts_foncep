--EXCEL PENSIONES
select /*a.funcionario*/ a.ano, a.mes, b.numero_identificacion cedula ,
    b.nombres||' '||b.primer_apellido||' '||b.segundo_apellido as nombres_y_apellidos,
    sum(a.ibc) ibl_pension,
    sum(a.aporte_entidad)+sum(a.aporte_funcionario) as aporte_pension
from rh_aportes a, rh_personas b
where a.funcionario = b.interno_persona AND
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
