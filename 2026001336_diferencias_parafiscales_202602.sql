select h.nfuncionario, h.nhash, h.ndcampo0, n.ndcampo0
from rh_historico_nomina_hoy h, rh_historico_nomina n
where h.nfuncionario = n.nfuncionario
and h.nhash = n.nhash
and h.dinicioperiodo= n.dinicioperiodo
and h.dfinalperiodo = n.dfinalperiodo
and h.ntipoconcepto = n.ntipoconcepto
and h.dinicioperiodo = 20260301
and h.ndcampo0 <> n.ndcampo0
and h.nesnovedad=n.NESNOVEDAD
and h.dfechanovedad=n.dfechanovedad
--and h.besdefinitivo=n.besdefinitivo
;

select 'hoy' fte, h.*
from rh_historico_nomina_hoy h
where h.dinicioperiodo = 20260301
and h.nhash = 2091789934
and h.nfuncionario=33
union 
select 'hn' fte, n.*
from rh_historico_nomina n
where n.dinicioperiodo = 20260301
and n.nhash = 2091789934
and n.nfuncionario=33
;

--33 51665925
select *
from rh_concepto   
where codigo_hash = 2233812345;

select *
from rh_tipos_acto_nove
where codigo_hash = 2233812345;