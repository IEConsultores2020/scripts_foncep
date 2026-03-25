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
and numero_disponibilidad=160
--and rubro_interno=1917
;

   
--Rubros disponibles, que coinciden con el cambio solicitado
select *
from pr_v_rubros 
where vigencia= 2026
and (interno_rubro=1917
or descripcion = 'Servicios de gestión de desarrollo empresarial')
and codigo_nivel1=2 and codigo_nivel2 in (1,3)
;
--Actual rubro 1917 cambiar a 1948
--nuevo rubro_interno que debe quedar 1948 o 1759. Se recomienda usar el de mayor valor que son los nuevos creados

PR.FK_PR_REGIS_REF_5094_PR_DISPO

--reviso compromisos
select *
from pr_compromisos
where vigencia=2026
and codigo_compania=206
and codigo_unidad_ejecutora='01'
and numero_registro=150
--and numero_compromiso=130
--and tipo_compromiso=145
;

------Registros presupuestales
select * 
from pr_registro_presupuestal 
where vigencia=2026
and codigo_compania=206
and codigo_unidad_ejecutora='01'
and numero_disponibilidad=160
and numero_registro=150
--and numero_compromiso=130
--and tipo_compromiso=145
;

select *
from pr_registro_disponibilidad 
where vigencia=2026
and codigo_compania=206
and codigo_unidad_ejecutora='01'
and numero_disponibilidad=160
and numero_registro=150
;
--and numero_compromiso=130
--and tipo_compromiso=145

-----Inicio cambio
------------Inicio cambio
----------------Inicio cambio
--1. deshabilita llave foránea
alter table pr.pr_registro_disponibilidad disable constraint FK_PR_REGIS_REF_5094_PR_DISPO;

--2. cambia rubro 1917 a 1948 manual
select pr_disponibilidad_rubro.*, rowid
from pr_disponibilidad_rubro 
where vigencia=2026
and codigo_compania=206
and codigo_unidad_ejecutora='01'
and numero_disponibilidad=160
;

--3. cambia rubro 1917 a 1948 manual
select pr_registro_disponibilidad.*, rowid
from pr_registro_disponibilidad 
where vigencia=2026
and codigo_compania=206
and codigo_unidad_ejecutora='01'
and numero_disponibilidad=160
and numero_registro=150
;

--4. Habilita trigger
alter table pr.pr_registro_disponibilidad enable constraint FK_PR_REGIS_REF_5094_PR_DISPO;

----------------fin cambio
------------fin cambio
-----fin cambio

