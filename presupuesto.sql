select * from pr_nivel1
order by vigencia desc;

insert into pr_nivel1 (vigencia,interno,codigo,descripcion,tipo_plan)
values (2026,4,2,'GASTOS','PLAN_ADMONCENTRAL')

insert into pr_nivel1 (vigencia,interno,codigo,descripcion,tipo_plan)
values (2026,3,1,'INGRESOS','PLAN_ADMONCENTRAL')

commit

select *
from pr_rubro;

select *
from pr_disponibilidades
where vigencia=2025 and numero_disponibilidad=395;