select *
from rh_personas p, rh_actos_administrativos a
 where a.tipo_Acto = 171
and a.fecha_acto between '01/DEC/2025' and '31/DEC/2025'
and p.interno_persona = a.funcionario
order by funcionario;

select *
from rh_tipos_acto_nove
where codigo_hash = 3168394695
nombre like '%PENSION%' in ('VACACIONES','SALUD','PENSION','RIESGO PROFESIONAL');
--171 1994756444

select *
from rh_historico_nomina
where /*nhash = 1994756444 
and  ndcampo0 between -981002 and -981002
and*/ nfuncionario = 45
and dfecharegistro between 20251201 and 20251231.9999
order by dfecharegistro desc
;

