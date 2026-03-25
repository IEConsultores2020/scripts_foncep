select *
from rh_personas
where nombres like 'ECCE%' --primer_apellido = 'SOLER'
;
ECCEHOMO 11 78484354


select *
from rh_historico_nomina hn
where nfuncionario=33
and dinicioperiodo=20260301
and dfinalperiodo=20260331
;

select *
from rh_historico_nomina hn, rh_actos_administratrivos a
where nfuncionario=615
and dinicioperiodo=20260301
and dfinalperiodo=20260331
and an.codigo_hash = hn.nhash
and sproceso='NOMINA_DE_EMPLEADOS_PLANTA'
AND 

select *
  from rh_tipos_acto_nove nn
 where nn.nombre like '%ALIM%FAV%'