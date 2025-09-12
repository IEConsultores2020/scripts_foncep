--EXCEL CONCEPTOS DEVENGADOS Y DEDUCIDOS
select  p.numero_identificacion cedula,
    p.nombres||' '||p.primer_apellido||' '||p.segundo_apellido as nombres_y_apellidos,
    hn.*
from rh_personas p, rh_funcionario f, 
    (
        SELECT hn.nfuncionario, hn.dinicioperiodo,
            ABS(SUM(CASE WHEN C.nombre = 'INFOCESANTIAS' THEN hn.ndcampo0 ELSE 0 END)) AS CESANTIAS
        FROM
            rh_historico_nomina hn
        JOIN
            rh_tipos_acto_nove C ON c.codigo_hash = hn.nhash
        WHERE
            hn.dinicioperiodo >= 20180101
            AND hn.dfinalperiodo <= 20250731
            AND C.nombre IN (
                'INFOCESANTIAS'
            )
            AND hn.brechazado = 0
            AND besdefinitivo = 1        
        GROUP BY
            hn.nfuncionario,
            hn.dinicioperiodo
    ) hn
where p.interno_persona = f.personas_interno
and p.interno_persona = hn.nfuncionario
and f.personas_interno = hn.nfuncionario
and p.numero_identificacion in (51605363) 23495638, 45454959,79355621, 37891855, 
                                79329628, 51753989, 79315507, 35325745, 
                                51978047, 24022412, 39789074, 79489819, 
                                51665925, 51605363, 52116283, 51841009, 
                                6762048, 51653368, 51564303, 40030681, 
                                80039413, 79536419, 30401728, 52750014, 
                                53116209, 74369918, 37726651, 1049606827, 
                                29328794, 79737305, 20730522, 1015404700, 
                                51852403, 53141042, 79455999, 52227361,
                                52866026 )
--and p.numero_identificacion = 6762048 and dinicioperiodo = 20180101                                
order by 1
;


/*    
aportes salud y pensión patrono no está en hn.
aporte salud y pensión del funcionario
*/

--EXCEL PENSIONES
select a.funcionario,
    to_number(to_char(a.ano)||lpad(to_char(a.mes),2,'0')||'01') periodo,
    SUM(CASE WHEN a.tipo_aporte = 'PENSIONES' THEN a.aporte_entidad ELSE 0 END) AS APORTEPENSIONPATRONO,
    SUM(CASE WHEN  a.tipo_aporte = 'PENSIONES' THEN a.aporte_funcionario ELSE 0 END) AS APORTEPESIONEMPLEADO, 
    SUM(CASE WHEN a.tipo_aporte = 'SALUD' THEN a.aporte_entidad ELSE 0 END) AS APORTESALUDPATRONO,
    SUM(CASE WHEN  a.tipo_aporte = 'SALUD' THEN a.aporte_funcionario ELSE 0 END) AS APORTESALUDEMPLEADO
from rh_aportes a
where (a.ano between 2018 and  2025)  and 
 a.tipo_aporte IN ('PENSIONES','SALUD') and
 a.funcionario = 66  and a.ano = 2018 and a.mes = 1
group by a.funcionario, a.ano, a.mes
order by periodo asc