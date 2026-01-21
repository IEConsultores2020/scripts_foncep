
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
