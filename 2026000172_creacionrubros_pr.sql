
insert into pr_nivel8 (VIGENCIA,INTERNO,CODIGO,DESCRIPCION,INTERNO_NIVEL7,TIPO_PLAN)
select 2026,INTERNO,CODIGO,DESCRIPCION,INTERNO_NIVEL7,TIPO_PLAN
from pr_nivel8 where vigencia=2025 and interno=1584;

-----Niveles

select interno from pr_nivel8
 where vigencia = 2025
minus
select interno from pr_nivel8
 where vigencia = 2026;
 --0

 select * --interno
  from pr_nivel8
 where vigencia = 2025
 and interno = 1584
minus
select interno
  from pr_nivel8
 where vigencia = 2026;

--pr_detalle_fuentes
insert into pr_detalle_fuentes(VIGENCIA,CLASIFICACION,CODIGO_FUENTES_FINANCIACION,CONSECUTIVO_FUENTE,DESCRIPCION)
select 2026,CLASIFICACION,CODIGO_FUENTES_FINANCIACION,CONSECUTIVO_FUENTE,DESCRIPCION
from pr_detalle_fuentes where vigencia=2025
and codigo_fuentes_financiacion||'-'||consecutivo_fuente in 
  (  select codigo_fuentes_financiacion||'-'||consecutivo_fuente from pr_detalle_fuentes where vigencia=2025
  minus
  select codigo_fuentes_financiacion||'-'||consecutivo_fuente from pr_detalle_fuentes where vigencia=2026)  ;

insert into pr_nivel8 (VIGENCIA,INTERNO,CODIGO,DESCRIPCION,INTERNO_NIVEL7,TIPO_PLAN)
select 2026,INTERNO,CODIGO,DESCRIPCION,INTERNO_NIVEL7,TIPO_PLAN
from pr_nivel8 where vigencia=2025 and interno=1584;

insert into pr_rubro (VIGENCIA,INTERNO,INTERNO_NIVEL1,INTERNO_NIVEL2,INTERNO_NIVEL3,INTERNO_NIVEL4,    
INTERNO_NIVEL5,INTERNO_NIVEL6,INTERNO_NIVEL7,INTERNO_NIVEL8,DESCRIPCION,TIPO_PLAN,ADMINISTRACION,
INVERSION,PROGRAMACION,CODIGO_TIPO,CODIGO_COMPONENTE,CODIGO_OBJETO,CODIGO_FUENTE,CODIGO_DET_FUENTE)
select 2026 vigencia,INTERNO,INTERNO_NIVEL1,INTERNO_NIVEL2,INTERNO_NIVEL3,INTERNO_NIVEL4,    
INTERNO_NIVEL5,INTERNO_NIVEL6,INTERNO_NIVEL7,INTERNO_NIVEL8,DESCRIPCION,TIPO_PLAN,ADMINISTRACION,
INVERSION,PROGRAMACION,CODIGO_TIPO,CODIGO_COMPONENTE,CODIGO_OBJETO,CODIGO_FUENTE,CODIGO_DET_FUENTE
FROM pr_rubro WHERE interno IN 
              (select interno from pr_rubro where vigencia=2025
                minus
                select interno from pr_rubro where vigencia=2026
              )  and vigencia=2025;

--Verifico los rubros que están en 2025 y que están en 2026
select *
from pr_rubro where descripcion in (
  select *
  FROM pr_rubro WHERE interno IN 
                (select interno from pr_rubro where vigencia=2025
                  intersect
                  select interno from pr_rubro where vigencia=2026
                )  and vigencia=2025
  and vigencia=2026)
order by descripcion;

---Ahora se deben eliminar rubros que no se van a usar en 2026 por que ya tienen otro id.
create or replace view v_rubros_nomina as
select interno, descripcion
from 
--delete 
pr_rubro
where vigencia = 2026
and descripcion in (
--Nómina 
'Sueldos y salarios',
'Horas extras, dominicales, festivos y recargos',
'Gastos de representación',
'Subsidio de alimentación',
'Auxilio de transporte',
'Bonificación por servicios prestados',
'Prima de navidad',
'Prima de vacaciones',
'Prima técnica salarial',
'Beneficios a los empleados a corto plazo',
'Aportes de cesantías a fondos públicos',
'Reconocimiento por permanencia en el servicio público - Bogotá D.C.',
'Bonificación especial de recreación',
'Prima secretarial',
--SS
'Aportes a la seguridad social en pensiones públicas',
'Aportes a la seguridad social en salud pública',
'Aportes a la seguridad social en pensiones privadas',
'Aportes a la seguridad social en salud privada',
'Aportes de cesantías a fondos públicos',
'Compensar',
'Aportes generales al sistema de riesgos laborales públicos',
'Aportes al ICBF',
'Aportes al SENA',
'Servicios de administración de fondos de pensiones y cesantías'
)
and interno not in ( select rubro_interno from pr_disponibilidad_rubro where vigencia = 2026 and codigo_compania='206' 
  --in 22,  not in 12
  --prod 12 ok
  )
order by descripcion;

--Validando con la apropiacion 2026




select * from v_rubros_nomina
where interno not in /*(
  select rubro_interno from pr_apropiacion where vigencia = 2026
); ---in 22, not in 12*/
( select rubro_interno from pr_disponibilidad_rubro where vigencia = 2026 and codigo_compania='206' 
  --in 22,  not in 12
  )




--commit;

--Consulto los rubros que están en el 2025 y 2026 y que no se usan en el 2026.
--no es acertada, no se recomienda.
select interno, descripcion
from pr_rubro
where vigencia = 2026
and interno in
  (--Excluyo los rubros que no los programe en la apropiación 2026
  select rubro_interno
  from pr_apropiacion
  where vigencia = 2026
  and rubro_interno not in
                  --Busco los rubros que están en 2025 y 2026
                  (
                    select interno from pr_rubro where vigencia=2025
                    intersect
                    select interno from pr_rubro where vigencia=2026
                   -- order by 1
                  ) 
    -- and rubro_interno between 1380 and 1399
    and valor > 0
  )
order by descripcion;

