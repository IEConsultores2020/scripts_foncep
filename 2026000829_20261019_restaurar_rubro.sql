select vigencia, interno, descripcion
from pr_rubro 
where (descripcion like 'Servicios de asesoramiento y representación jurídica relativos a otros%campos del derecho%')
  and vigencia=2026
order by descripcion;
--1606 no existen registros
--1595 (termina con "(CPC, Division 85)") y 1914 (tiene un espacio adicional "otros__campos")


select vigencia, rubro_interno, codigo_unidad_ejecutora, count(1) numregistros, sum(valor)
from pr_disponibilidad_rubro
where vigencia=2026
and rubro_interno in (1914,1606,1595)
group by  vigencia, rubro_interno, codigo_unidad_ejecutora
;

select vigencia, rubro_interno, count(1), sum(valor)
from pr_disponibilidad_rubro
where vigencia=2026
and rubro_interno in  (1914,1606,1595)
group by vigencia, rubro_interno
;



select *
from pr_apropiacion
where vigencia = 2026
and codigo_compania = 206
and codigo_unidad_ejecutora='01'
and rubro_interno in  (1914,1606,1595)
;

select *
from PR_MODIFICACION_PRESUPUESTAL
where vigencia=2026
and rubro_interno in 
(1914,1606,1595)
; --pasar a 1606

commit;



--commit;


