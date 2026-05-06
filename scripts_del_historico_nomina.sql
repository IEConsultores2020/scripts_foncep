--Para eliminar un acto de vacaciones
delete 
rh_historico_nomina hn
where hn.nfuncionario=633
and nhash like '1994%';

--Para verificar
select hn.*
from rh_historico_nomina hn
where hn.nfuncionario=633
and nhash like '1994%'
and hn.dinicioperiodo = 20260401