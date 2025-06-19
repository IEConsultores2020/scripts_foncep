select *
from rh_personas
where --NUMERO_IDENTIFICACION = 23495638  --int 218
INTERNO_PERSONA = 45 --CC 40030681
;

select *
from RH_ACTOS_ADMINISTRATIVOS
where FUNCIONARIO = 218
and extract(year from  fecha_FINAL ) = 2025
and tipo_acto = 040
;

