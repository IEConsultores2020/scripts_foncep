select *
from lm_centro_contable

update lm_centro_contable
set cncn_dfnal=to_date('28/02/2026','dd/mm/yyyy')

commit;


select * from tab_lch_segui   
where consec > (select max(consec) from tab_lch_segui where mensaje like '%2026000070%')
order by consec desc   
;

