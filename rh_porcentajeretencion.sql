

select * from rh_concepto
where nombre_corto like '%RE%FU%'
--2091789934

 --hn.nfuncionario, 
select  distinct   p.numero_identificacion, 
      hn.dfechanovedad fecha, 
      regexp_substr(hn.informativo,'<([^>]+)>',1,1,null,1) as "% RETENCION" 
from rh_historico_nomina hn
join rh_personas p on hn.nfuncionario = p.interno_persona
where hn.nhash=2091789934
and  hn.dfechanovedad between 20250101 and 20251231
and brechazado=0
and besdefinitivo=1
order by 1