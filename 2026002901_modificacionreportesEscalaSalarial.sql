/*
2026002901_ModifcacionReeportesEscalaSalarial
Buen día, con el fin de dar cumplimiento al plan de mejoramiento solicitado por la Contraloría de Bogotá, comedidamente solicitamos la creación de un espacio adicional en los reportes de; "Prenómina" y "Archivo Plano Acumulados Periodos", donde se identifique la escala salarial con la cual se le reconoce la asignación básica a cada Servidor Público de la entidad, para determinar la escala salarial se debe tener en cuenta la fecha de ingreso a la entidad así:
Fecha de ingreso anterior al 1 de enero de 2019 y a partir del 31 de marzo de 2023 se debe distinguir con "Acuerdo 1 de 2023"
Fecha de ingreso apartir del 1 de enero de 2019 y hasta el 30 de marzo de 2023, se debe distinguir con "Acuerdo 11 de 2018"
Gracias por su atención y colaboración.
*/

select *
from bintablas
where grupo = 'NOMINA'
and nombre like 'ESCALA SALARIAL%';

select f.personas_interno, resultado --count(es.argumento)
-- select f.personas_interno, f.fecha_ingreso_entidad, es.resultado, es.vig_inicial, es.vig_final
from  rh_funcionario f
    join  bintablas es
        on grupo = 'NOMINA' and nombre like 'ESCALA SALARIAL%' and argumento='ACUERDO' and
        f.fecha_ingreso_entidad between es.vig_inicial and nvl(es.vig_final, sysdate)
where f.personas_interno = 510        
--group by f.personas_interno
--having count(es.argumento) > 1        
order by personas_interno        ;

select * from rh_funcionario f where f.fecha_ingreso_entidad between to_date('01/01/2019','dd/mm/yyyy') 
    and to_date('30/03/2023','dd/mm/yyyy') 0;

select * from bintablas
 where grupo = 'NOMINA' and nombre like 'ESCALA SALARIAL%' and argumento='ACUERDO' and
     :fecha_ingreso_entidad >= vig_inicial and :fecha_ingreso_entidad <= nvl(sysdate, vig_final)
     ;
