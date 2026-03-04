/*El día 14 de enero, en la unidad ejecutora 01, 
    se registro el CDP Nro. 160 el cual quedo afectado al rubro presupuestal 

    "Servicios de gestión de desarrollo empresarial 2-1-02-02-02-008-0003-0083117", 
    sin embargo solicitamos de su ayuda con el fin de validar 
    si por base de datos es posible cambiar este dato al rubro: 

    "Servicios de gestión de desarrollo empresarial 2-3-02-02-02-008-0003-0083117"
*/ 


--Consulto disponibilidades
select *
from pr_disponibilidades
where vigencia=2026
and codigo_compania=206
and codigo_unidad_ejecutora='01'
and numero_disponibilidad=160;


--Consulta de rubros de las disponibilidad 160
select * 
from pr_disponibilidad_rubro 
where vigencia=2026
and codigo_compania=206
and codigo_unidad_ejecutora='01'
and numero_disponibilidad=160;

   
--Rubros disponibles, que coinciden con el cambio solicitado
select *
from pr_v_rubros 
where vigencia= 2026
and (interno_rubro=1917
or descripcion = 'Servicios de gestión de desarrollo empresarial')
and codigo_nivel1=2 and codigo_nivel2 in (1,3)
;

select * 
from pr_disponibilidad_rubro 

