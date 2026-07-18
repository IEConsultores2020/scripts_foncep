/*Buen día, debido al nuevo festivo es necesario modificar la fecha de terminación de vacaciones del Dr. Camilo Ojeda Amaya c.c. 1098748360, segun el registro incial finaliza el 13 de julio es necesario que finalice el 14 de julio, además de deben interrumpir el día de hoy.
*/ 

select *
from rh_personas
where numero_identificacion =1098748360  --644
;

select *
from rh_tipos_acto_nove
where nombre like '%VACACIONES%'; --VACACIONES 171  CODIGO_HASH 1994756444
;

select *
from rh_actos_administrativos 
where funcionario = 644
and tipo_acto=171
;  ---1 cambiar fecha acto de 13 a 14

select *
from rh_detalle_acto
where secuencia=5803
and funcionario=644
and tipo_acto=171
;

select *
from rh_historico_nomina
where nfuncionario=644
and nhash = 1994756444
; --2 Cambiar DFECHAFINAL a 20260714


select *
from rh_vacaciones
where funcionario=644;

select *
from rh_vacaciones_proy
where funcionario = 644
;

select *
from rh_detalle_vacaciones
where funcionario=644
;
--3. Cambiar fecha fin vacaciones


select *
from
--update
 rh_movimientos_planta
 --set fecha_final = '14-JUL-26'
where funcionario = 644
and tipo_acto =171
--4. Cambiar fecha_final tipo_acto 171
;


COMMIT