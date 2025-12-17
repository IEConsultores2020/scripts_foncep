select *
from  rh_valores_retencion
where ano = 2026;

insert into rh_valores_retencion 
select 2026,procedimiento, salario_inicial, salario_final, porcentaje, valor
from rh_valores_retencion
where ano = 2025;


commit;