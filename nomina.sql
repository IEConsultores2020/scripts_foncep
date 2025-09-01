select nfuncionario, nesnovedad, nhash, dfecharegistro, sproceso, ndcampo0, dfechaefectiva
from 
    update rh_historico_nomina_hoy
    set ndcampo0 = 13596967
where nfuncionario in (select interno_persona
                       from rh_personas
                       where numero_identificacion in (1015404700))
and dfechaefectiva = 20250601                      
and ndcampo0= 13589294
;

commit;

and nhash = 2504578959
;1748960496

select *
from rh_concepto
where --nombre like 'PRIMA%TEC%'
codigo_hash in (854032720,1415990624,2411991376)
;

select *
from rh_tipos_acto_nove
where --nombre like 'PRIMA%'
codigo_hash in  (854032720,1415990624,2411991376)
;

(547529232,4290415819,854032720,1415990560,1415990624,2411991376)
;