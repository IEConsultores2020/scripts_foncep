Select interno_persona, NUMERO_IDENTIFICACION, NOMBRES || ' ' || PRIMER_APELLIDO || ' ' || SEGUNDO_APELLIDO Nombre, sconcepto,valor
/*Replace(SCONCEPTO, 'PROV_', '') Concept*/
From rh_personas, rh_t_lm_valores
Where nfuncionario = interno_persona
and nfuncionario=591
and PERIODO = '30/APR/2026'
 AND SDEVENGADO = 5
Order By to_number(NUMERO_IDENTIFICACION);

select distinct periodo
from rh_t_lm_valores
where extract(year from periodo)=2026;

