
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

--Consulto los rubros que están en el 2025 y 2026 y que no se usan en la apropiación del 2026.
select v2.interno_rubro, v2.vigencia||'-'||v2.descripcion||'-'|| v2.tipo_plan||'-'|| v2.codigo_nivel1||'-'|| v2.codigo_nivel2||'-'|| v2.codigo_nivel3||'-'||
  v2.codigo_nivel4||'-'|| v2.codigo_nivel5 ||'-'||v2.codigo_nivel6 ||'-'||v2.codigo_nivel7||'-'|| v2.codigo_nivel8||'-'|| v2.codigo_tipo||'-'|| 
  v2.codigo_componente||'-'|| v2.codigo_objeto||'-'|| v2.codigo_fuente||'-'|| v2.codigo_det_fuente  
from pr_v_rubros v2
where v2.vigencia||'-'||v2.descripcion||'-'|| v2.tipo_plan||'-'|| v2.codigo_nivel1||'-'|| v2.codigo_nivel2||'-'|| v2.codigo_nivel3||'-'||
  v2.codigo_nivel4||'-'|| v2.codigo_nivel5 ||'-'||v2.codigo_nivel6 ||'-'||v2.codigo_nivel7||'-'|| v2.codigo_nivel8||'-'|| v2.codigo_tipo||'-'|| 
  v2.codigo_componente||'-'|| v2.codigo_objeto||'-'|| v2.codigo_fuente||'-'|| v2.codigo_det_fuente   in
 (
  select vr.interno_rubro ,vr.vigencia||'-'||vr.descripcion||'-'|| vr.tipo_plan||'-'|| vr.codigo_nivel1||'-'|| vr.codigo_nivel2||'-'|| vr.codigo_nivel3||'-'||
  vr.codigo_nivel4||'-'|| vr.codigo_nivel5 ||'-'||vr.codigo_nivel6 ||'-'||vr.codigo_nivel7||'-'|| vr.codigo_nivel8||'-'|| vr.codigo_tipo||'-'|| 
  vr.codigo_componente||'-'|| vr.codigo_objeto||'-'|| vr.codigo_fuente||'-'|| vr.codigo_det_fuente 
/*select vr.vigencia, vr.descripcion, vr.tipo_plan, vr.codigo_nivel1, vr.codigo_nivel2, vr.codigo_nivel3,
  vr.codigo_nivel4, vr.codigo_nivel5 ,vr.codigo_nivel6 ,vr.codigo_nivel7, vr.codigo_nivel8, vr.codigo_tipo, 
  vr.codigo_componente, vr.codigo_objeto, vr.codigo_fuente, vr.codigo_det_fuente */
from pr_rubro r, pr_v_rubros vr
where r.vigencia = 2026
and r.interno = vr.interno_rubro
and r.interno in
  (--Excluyo los rubros que no los programe en la apropiación 2026
  select rubro_interno
  from pr_apropiacion
  where vigencia = 2026
  and rubro_interno not in
                  --Busco los rubros que están en 2025 y 2026
                  (
                   /* select interno from pr_rubro where vigencia=2025
                    minus*/
                    select interno from pr_rubro where vigencia=2026
                  )  order by 1
    -- and rubro_interno between 1380 and 1399
   -- and valor > 0 ORDER BY 1
 ) order by 2
 )
order by 2
;

select *
from pr_v_rubros vr
where vigencia =2026 and descripcion like 'Partes y piezas de muebles'  --1800, 1845
;

--interno_rubro=1735
vr.vigencia||'-'||vr.descripcion||'-'|| vr.tipo_plan||'-'|| vr.codigo_nivel1||'-'|| vr.codigo_nivel2||'-'|| vr.codigo_nivel3||'-'||
  vr.codigo_nivel4||'-'|| vr.codigo_nivel5 ||'-'||vr.codigo_nivel6 ||'-'||vr.codigo_nivel7||'-'|| vr.codigo_nivel8||'-'|| vr.codigo_tipo||'-'|| 
  vr.codigo_componente||'-'|| vr.codigo_objeto||'-'|| vr.codigo_fuente||'-'|| vr.codigo_det_fuente like
--  '2026-Servicios de gestión de desarrollo empresarial%'
'2026-Servicios de gestión de desarrollo empresarial-PLAN_ADMONCENTRAL-2-3-02-02-02-008-0000-0083117-0-0-0-01-12'
;
--1759 1948 2026-Servicios de gestión de desarrollo empresarial-PLAN_ADMONCENTRAL-2-3-02-02-02-008-0000-0083117-0-0-0-01-12

select rv.descripcion, dr.*
from pr_disponibilidad_rubro dr, pr_v_rubros rv
where dr.vigencia=2026 and dr.codigo_compania=206 and dr.codigo_unidad_ejecutora='01'
and numero_disponibilidad=39
and dr.vigencia=rv.vigencia
and dr.rubro_interno=rv.interno_rubro
and dr.rubro_interno in (1800, 1845);

select * from 
--

delete 
pr_rubro where vigencia=2026 and interno = 1800;

commit

rollback

select *
from pr_disponibilidad_rubro dr
where dr.vigencia=2026 and dr.codigo_compania=206 
and dr.codigo_unidad_ejecutora='01'
--and rubro_interno in (1837,1543)
--and rubro_interno in (1759,1948)    --Servicios de gestión de desarrollo empresarial 2-3-02-02
and rubro_interno in (1804,1547)     --Servicios de gestion de desarrollo empresarial 2-1-02-02%
and dr.numero_disponibilidad in (200,192,214,200,157,159,160)
order by dr.numero_disponibilidad;

select *
from pr_apropiacion
where vigencia=2026 and codigo_compania=206 
and codigo_unidad_ejecutora='01'
and rubro_interno in (1800, 1845)    
;

select *
from pr_registro_disponibilidad
where vigencia=2026 and codigo_compania=206 
and codigo_unidad_ejecutora='01'
--and rubro_interno in (1804, 1547)
--and rubro_interno in (1759,1948)     --Servicios de gestión de desarrollo empresarial  2-3-02-02
and rubro_interno in (1801,1917)       --Servicios de gestión de desarrollo empresarial  2-1-02-02% Quitar 1801
;


/*
Duplicados, se borra segundo  otras
1837, 1543                          Aportes de cesantías a fondos privados
1804, 1547                    1227  Sueldo básico
1759,1948                           Servicios de gestión de desarrollo empresarial  2-3-02-02
1801,1917                           Servicios de gestión de desarrollo empresarial  2-1-02-02%. Eliminado duplicado 1801
*/

select *
from rh_lm_cuenta
update dfecha_inicio
where stipo_funcionario = 'PLANTA' and 
sconcepto LIKE 'INFOCESANTIAS_FAV%';


--Caso M1. Fólders
select *
from pr_v_rubros rv
where rv.vigencia = 2026 and rv.descripcion = 'Servicios de gestión de desarrollo empresarial' --rv.interno_rubro in (1804,1547)
;
--1849 1423 fólderes
--2026-Servicios de gestión de desarrollo empresarial-PLAN_ADMONCENTRAL-2-3-02-02-02-008-0000-0083117-0-0-0-01-12

--ingresos
select * from pr_rubros_no2026 where interno in (1551,1734,1566,1561,1563,1564,1724,1557,1559,1722,1727,1599,1728)
order by descripcion
;


--Internos duplicados
create table select * from select * from pr_rubros_no2026 as
select *
from 
--delete 
pr_rubro where vigencia=2026 and interno in 1759
    (--select vr2.interno_rubro
    --/*
      select vr2.interno_rubro, vr2.vigencia||'-'||vr2.descripcion||'-'|| vr2.tipo_plan||'-'|| vr2.codigo_nivel1||'-'|| vr2.codigo_nivel2||'-'|| vr2.codigo_nivel3||'-'||
      vr2.codigo_nivel4||'-'|| vr2.codigo_nivel5 ||'-'||vr2.codigo_nivel6 ||'-'||vr2.codigo_nivel7||'-'|| vr2.codigo_nivel8||'-'|| vr2.codigo_tipo||'-'|| 
      vr2.codigo_componente||'-'|| vr2.codigo_objeto||'-'|| vr2.codigo_fuente||'-'|| vr2.codigo_det_fuente rubro_Cadena 
    -- */
    from pr_v_rubros vr2
    where vigencia = 2026 and vr2.vigencia||'-'||vr2.descripcion||'-'|| vr2.tipo_plan||'-'|| vr2.codigo_nivel1||'-'|| vr2.codigo_nivel2||'-'|| vr2.codigo_nivel3||'-'||
      vr2.codigo_nivel4||'-'|| vr2.codigo_nivel5 ||'-'||vr2.codigo_nivel6 ||'-'||vr2.codigo_nivel7||'-'|| vr2.codigo_nivel8||'-'|| vr2.codigo_tipo||'-'|| 
      vr2.codigo_componente||'-'|| vr2.codigo_objeto||'-'|| vr2.codigo_fuente||'-'|| vr2.codigo_det_fuente 
      in (
    --Rubros duplicados, no se incluye el interno_rubro que es único    
    select  vr.vigencia||'-'||vr.descripcion||'-'|| vr.tipo_plan||'-'|| vr.codigo_nivel1||'-'|| vr.codigo_nivel2||'-'|| vr.codigo_nivel3||'-'||
      vr.codigo_nivel4||'-'|| vr.codigo_nivel5 ||'-'||vr.codigo_nivel6 ||'-'||vr.codigo_nivel7||'-'|| vr.codigo_nivel8||'-'|| vr.codigo_tipo||'-'|| 
      vr.codigo_componente||'-'|| vr.codigo_objeto||'-'|| vr.codigo_fuente||'-'|| vr.codigo_det_fuente
    from pr_v_rubros vr
    where vr.vigencia = 2026 
    group by vr.vigencia||'-'||vr.descripcion||'-'|| vr.tipo_plan||'-'|| vr.codigo_nivel1||'-'|| vr.codigo_nivel2||'-'|| vr.codigo_nivel3||'-'||
      vr.codigo_nivel4||'-'|| vr.codigo_nivel5 ||'-'||vr.codigo_nivel6 ||'-'||vr.codigo_nivel7||'-'|| vr.codigo_nivel8||'-'|| vr.codigo_tipo||'-'|| 
      vr.codigo_componente||'-'|| vr.codigo_objeto||'-'|| vr.codigo_fuente||'-'|| vr.codigo_det_fuente  
    having count(1)>1
      )
    and   vr2.interno_rubro<=1799
    --and vr2.interno_rubro not in (1759)
    )
order by 1 ;
--commit;
--Analicemos solo folderes.

--Caso M1. Fólders
  select *
  from pr_v_rubros rv
  where rv.vigencia = 2026 --and rv.interno_rubro = 156 --rv.descripcion = 'Fólderes' 
  --rv.interno_rubro in (1804,1547)    --Fólderes
  and rv.interno_rubro in (1759) --,1948)  --Baterías de pilas
;
--1849 1423
select *
from pr_apropiacion
where vigencia =2026
--and rubro_interno <= 1799 -- in (1849,1423);
and rubro_interno in (1759,1948) --Servicios de gestión de desarrollo empresarial
;

select *
from pr_disponibilidad_rubro
where vigencia =2026
--and rubro_interno <= 1799 
--and rubro_interno in (1849,1423) --fólderes
--and rubro_interno in (1715,1893)  --Baterías de pilas
and rubro_interno in (1759,1948)    --Servicios de gestión de desarrollo empresarial
--and numero_disponibilidad in (200,192,214,200,157,159,160)
;


select *
from pr_disponibilidades
where numero_disponibilidad=234
and vigencia=2026
and codigo_compania=206
and codigo_unidad_ejecutora='01'
;

select *
from pr_documentos
where tipo_movimiento = 'TRASLADO'
and vigencia = 2026
and numero = '000014'
and tipo_documento = '02' ---RESOLUCION
;

select *
from pr_modificacion_presupuestal
where vigencia = 2026
and codigo_compania=206
and codigo_unidad_ejecutora = '01'
and rubro_interno in (1800, 1845)   --Servicios de gestión de desarrollo empresarial
;


select *
from pr_compromisos
where vigencia=2026
and codigo_compania=206
and codigo_unidad_ejecutora='01'
and numero_compromiso in (1800, 1845)  
;

select *
from pr_registro_disponibilidad
where vigencia = 2026
and codigo_compania = 206
and codigo_unidad_ejecutora ='01'
--and numero_disponibilidad in  (200,214,200,159,157,160,192)
--and numero_registro in (126,150,173)
and rubro_interno in (1759,1948)
;

select *
from pr_cdp_anulados
where vigencia = 2026
and codigo_compania = 206
and codigo_unidad_ejecutora ='01'
and numero_disponibilidad=160
and rubro_interno in (1759,1948)
;

select *
from pr_registro_presupuestal
where vigencia=2026 and codigo_compania=206
and numero_disponibilidad in (200,214,200,159,157,160,192)
and numero_registro in (126,150,173)
;

--Anulaciones parciales rp
select *
from pr_rp_anulados
where vigencia=2026
and codigo_compania=206
and codigo_unidad_ejecutora='01'
and rubro_interno in (1800, 1845)     --Servicios de gestión de desarrollo empresarial
;

--Anulaciones totales
select *
from pr_anulaciones
where vigencia = 2026
and codigo_compania = 206
and codigo_unidad_ejecutora='01'
and documento_anulado='CDP'
and  numero_documento_anulado=214
;


---Rubros por centros de costos en PERNO
select distinct descripcion, interno_rubro
from pr_v_rubros 
where interno_rubro in (
select * --codigo_presupuesto
from rh_lm_cuenta
where scompania=206 and stipo_funcionario='PLANTA' and sysdate between dfecha_inicio_vig and dfecha_final_vig
and codigo_presupuesto is not null
minus
select interno_rubro
from pr_v_rubros rv
where rv.vigencia = 2026)
;

/*
Vacaciones en dinero	927               Indemnización por vacaciones
Fortalecimiento Institucional	982
Otros Gastos de Personal	1054
*/

select vigencia, descripcion, interno_rubro
from pr_v_rubros
where --interno_rubro in (1825,1837) --(927,982,1054)
(descripcion like '%Prima de servicio%'  or descripcion like '%Aportes de cesant%priv%')
and vigencia=2026
order by vigencia desc
--descripcion like '%tros%astos%' and vigencia=2025
;


select distinct c.codigo_presupuesto , rv.descripcion
from rh_lm_cuenta c, pr_v_rubros rv
where scompania=206 and stipo_funcionario='PLANTA' and sysdate between dfecha_inicio_vig and dfecha_final_vig
and codigo_presupuesto = interno_rubro
and rv.vigencia=2026
order by c.codigo_presupuesto asc
;

select *
from rh_lm_conta_nom;

--Que borrar.
select rv.interno_rubro, rv.descripcion, dr.*
from pr_disponibilidad_rubro dr, pr_v_rubros rv
where dr.vigencia=2026 and dr.codigo_compania=206 
and dr.codigo_unidad_ejecutora='01'
and rubro_interno in (1759,1948)
and dr.numero_disponibilidad=234
and dr.vigencia=rv.vigencia
and dr.rubro_interno =rv.interno_rubro
order by 2
;

---Duplicados por apropiacion. No hay
select count(1), dr.tipo_documento, dr.documentos_numero, 
  rv.vigencia||'-'||rv.descripcion||'-'|| rv.tipo_plan||'-'|| rv.codigo_nivel1||'-'|| rv.codigo_nivel2||'-'|| rv.codigo_nivel3||'-'||
  rv.codigo_nivel4||'-'|| rv.codigo_nivel5 ||'-'||rv.codigo_nivel6 ||'-'||rv.codigo_nivel7||'-'|| rv.codigo_nivel8||'-'|| rv.codigo_tipo||'-'|| 
  rv.codigo_componente||'-'|| rv.codigo_objeto||'-'|| rv.codigo_fuente||'-'|| rv.codigo_det_fuente rubro_Cadena
from pr_apropiacion dr, pr_v_rubros rv
where dr.vigencia=2026 and dr.codigo_compania=206 
and dr.codigo_unidad_ejecutora='01'
--and rubro_interno in (1715,1893)
--and dr.numero_disponibilidad=234
and dr.vigencia=rv.vigencia
and dr.rubro_interno = rv.interno_rubro
group by   dr.tipo_documento, dr.documentos_numero, 
   rv.vigencia||'-'||rv.descripcion||'-'|| rv.tipo_plan||'-'|| rv.codigo_nivel1||'-'|| rv.codigo_nivel2||'-'|| rv.codigo_nivel3||'-'||
  rv.codigo_nivel4||'-'|| rv.codigo_nivel5 ||'-'||rv.codigo_nivel6 ||'-'||rv.codigo_nivel7||'-'|| rv.codigo_nivel8||'-'|| rv.codigo_tipo||'-'|| 
  rv.codigo_componente||'-'|| rv.codigo_objeto||'-'|| rv.codigo_fuente||'-'|| rv.codigo_det_fuente
having count(1)>1
;

---Duplicados por disponibilidad. Solucionar
select count(1), dr.numero_disponibilidad, rv.vigencia||'-'||rv.descripcion||'-'|| rv.tipo_plan||'-'|| rv.codigo_nivel1||'-'|| rv.codigo_nivel2||'-'|| rv.codigo_nivel3||'-'||
  rv.codigo_nivel4||'-'|| rv.codigo_nivel5 ||'-'||rv.codigo_nivel6 ||'-'||rv.codigo_nivel7||'-'|| rv.codigo_nivel8||'-'|| rv.codigo_tipo||'-'|| 
  rv.codigo_componente||'-'|| rv.codigo_objeto||'-'|| rv.codigo_fuente||'-'|| rv.codigo_det_fuente rubro_Cadena
from pr_disponibilidad_rubro dr, pr_v_rubros rv
where dr.vigencia=2026 and dr.codigo_compania=206 
and dr.codigo_unidad_ejecutora='01'
--and rubro_interno in (1715,1893)
--and dr.numero_disponibilidad=234
and dr.vigencia=rv.vigencia
and dr.rubro_interno = rv.interno_rubro
group by dr.numero_disponibilidad, rv.vigencia||'-'||rv.descripcion||'-'|| rv.tipo_plan||'-'|| rv.codigo_nivel1||'-'|| rv.codigo_nivel2||'-'|| rv.codigo_nivel3||'-'||
  rv.codigo_nivel4||'-'|| rv.codigo_nivel5 ||'-'||rv.codigo_nivel6 ||'-'||rv.codigo_nivel7||'-'|| rv.codigo_nivel8||'-'|| rv.codigo_tipo||'-'|| 
  rv.codigo_componente||'-'|| rv.codigo_objeto||'-'|| rv.codigo_fuente||'-'|| rv.codigo_det_fuente
having count(1)>1
;

--duplicados por movimiento
---Duplicados por disponibilidad. no hay
select count(1), dr.tipo_documento, dr.documentos_numero, dr.tipo_documento, rv.vigencia||'-'||rv.descripcion||'-'|| rv.tipo_plan||'-'|| rv.codigo_nivel1||'-'|| rv.codigo_nivel2||'-'|| rv.codigo_nivel3||'-'||
  rv.codigo_nivel4||'-'|| rv.codigo_nivel5 ||'-'||rv.codigo_nivel6 ||'-'||rv.codigo_nivel7||'-'|| rv.codigo_nivel8||'-'|| rv.codigo_tipo||'-'|| 
  rv.codigo_componente||'-'|| rv.codigo_objeto||'-'|| rv.codigo_fuente||'-'|| rv.codigo_det_fuente rubro_Cadena
from pr_modificacion_presupuestal dr, pr_v_rubros rv
where dr.codigo_compania = 2026 and codigo_unidad_ejecutora='01'and dr.vigencia=2026 
--and rubro_interno in (1715,1893)
--and dr.numero_disponibilidad=234
and dr.vigencia=rv.vigencia
and dr.rubro_interno = rv.interno_rubro
group by dr.tipo_documento, dr.documentos_numero, rv.vigencia||'-'||rv.descripcion||'-'|| rv.tipo_plan||'-'|| rv.codigo_nivel1||'-'|| rv.codigo_nivel2||'-'|| rv.codigo_nivel3||'-'||
  rv.codigo_nivel4||'-'|| rv.codigo_nivel5 ||'-'||rv.codigo_nivel6 ||'-'||rv.codigo_nivel7||'-'|| rv.codigo_nivel8||'-'|| rv.codigo_tipo||'-'|| 
  rv.codigo_componente||'-'|| rv.codigo_objeto||'-'|| rv.codigo_fuente||'-'|| rv.codigo_det_fuente
having count(1)>1

where tipo_movimiento = 'TRASLADO'
and vigencia = 2026
and numero = '000014'
and tipo_documento = '02' ---RESOLUCION

