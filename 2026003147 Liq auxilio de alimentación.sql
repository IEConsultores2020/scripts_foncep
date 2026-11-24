/*
2026003147 Liq. auxilio de alimentación
Buena tarde, revisada una preliquidación de la nómina del mes de septiembre se evidencia que no esta pagando Auxilio de alimentación a 4 servidores que tiene el derecho
35325745 Melba Cecilia Núñez Rodríguez
24022412 Ana Dilfa Pardo Suárez
79315507 Victor Manuel Jaimes Sanchez
79313081 Carlos Humberto Vergara Acosta
Rta. Sea actualiza formulación
Efectivamente está haciendo el pago a los servidores que corresponde, pero adicionalmente está haciendo el pago a los servidores José Fernando Bedoya y Olga Lucia Galeano quienes no tienen el derecho.
Gracias
Rta. Tienen la misma novedad.. se pasa a rechazar la infonovedad

*/

select *
from RH_TIPOS_ACTO_NOVE
where nombre = 'MANTENER_REGIMEN_FONCEP' --3809335290
;

select *
from rh_personas
where nombres like '%OLGA%' ---3809335290
;
JOSE FERNANDO     79355621    int. 65
OLGA LUCIA GALEANO 52025918   int. 52


select *
from 
update rh_historico_nomina
set brechazado = 1
where nfuncionario in (65,52)
and nhash=3809335290
and brechazado=0;

commit;