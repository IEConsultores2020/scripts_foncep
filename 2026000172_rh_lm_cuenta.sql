select *
from RH_LM_CENTROS_COSTO, RH_LM_RA_CC
where RH_LM_CENTROS_COSTO.CODIGO = RH_LM_RA_CC.CC

--Cuentas activas con código de presupuesto
select *
from rh_lm_cuenta c
where c.stipo_funcionario= 'PLANTA'
and c.scompania=206
and sysdate between c.dfecha_inicio_vig and nvl(c.dfecha_final_vig,sysdate)
and c.codigo_presupuesto is not null
order by sconcepto desc
;

--Cuentas activas para tipos funcionarios de planta vigentes 2025
select c.codigo_presupuesto, r.descripcion, c.*
from rh_lm_cuenta c, pr_rubro r
where c.stipo_funcionario= 'PLANTA'
and c.scompania=206
and sysdate between c.dfecha_inicio_vig and nvl(c.dfecha_final_vig,sysdate)
and c.codigo_presupuesto is not null
and r.interno = c.codigo_presupuesto
and r.vigencia = 2025
order by descripcion
;


--Miremos las que no tienen interno presupuesto
select *
from rh_lm_cuenta c
where c.stipo_funcionario= 'PLANTA'
and c.scompania=206
and sysdate between c.dfecha_inicio_vig and nvl(c.dfecha_final_vig,sysdate)
and c.codigo_presupuesto is not null
and c.codigo_presupuesto not in (select r.interno from pr_rubro r where r.vigencia <= 2026)


--rubros 2025 vs. 2026
select r26.interno, r.interno
from pr_rubro r26, pr_rubro r
where r26.vigencia = 2026
and r.vigencia = 2025
and r26.tipo_plan = r.tipo_plan
and r.tipo_plan = 'PLAN_ADMONCENTRAL'
and r26.interno_nivel1||'-'||r26.interno_nivel2||'-'||r26.interno_nivel3||'-'||r26.interno_nivel4||'-'||r26.interno_nivel5||'-'||
    r26.interno_nivel6||'-'||r26.interno_nivel7||'-'||r26.interno_nivel8||'-'||r26.codigo_tipo||'-'||r26.codigo_componente||'-'||
    r26.codigo_objeto||'-'||r26.codigo_fuente||'-'||r26.codigo_det_fuente =
    r.interno_nivel1||'-'||r.interno_nivel2||'-'||r.interno_nivel3||'-'||r.interno_nivel4||'-'||r.interno_nivel5||'-'||
    r.interno_nivel6||'-'||r.interno_nivel7||'-'||r.interno_nivel8||'-'||r.codigo_tipo||'-'||r.codigo_componente||'-'||
    r.codigo_objeto||'-'||r.codigo_fuente||'-'||r.codigo_det_fuente
and r26.interno <> r.interno    
;

--rubros 2025 vs. 2026 basado en las disponibilidades 2026
select r26.interno rinterno2026, r.interno rinterno2025, r26.descripcion desc26, r.descripcion desc2025
from pr_rubro r26, pr_rubro r
where r26.vigencia = 2026
and r.vigencia = 2025
and r26.tipo_plan = r.tipo_plan
and r.tipo_plan = 'PLAN_ADMONCENTRAL'
and r26.interno_nivel1||'-'||r26.interno_nivel2||'-'||r26.interno_nivel3||'-'||r26.interno_nivel4||'-'||r26.interno_nivel5||'-'||
    r26.interno_nivel6||'-'||r26.interno_nivel7||'-'||r26.interno_nivel8||'-'||r26.codigo_tipo||'-'||r26.codigo_componente||'-'||
    r26.codigo_objeto||'-'||r26.codigo_fuente||'-'||r26.codigo_det_fuente =
    r.interno_nivel1||'-'||r.interno_nivel2||'-'||r.interno_nivel3||'-'||r.interno_nivel4||'-'||r.interno_nivel5||'-'||
    r.interno_nivel6||'-'||r.interno_nivel7||'-'||r.interno_nivel8||'-'||r.codigo_tipo||'-'||r.codigo_componente||'-'||
    r.codigo_objeto||'-'||r.codigo_fuente||'-'||r.codigo_det_fuente
and r26.interno in  (select distinct rubro_interno
                        from pr_disponibilidad_rubro
                        where vigencia = 2026
                        and codigo_compania=206
                        and codigo_unidad_ejecutora = '01')   
and r26.interno <> r.interno                        
;

select *
from pr_rubro
where vigencia = 2025
and interno in (1622,1539,1653,1540)

--1. Se borran los rubros que no se van a usar en el 2026 por que ya tienen otro id.
--commit ok. Ver 202600172_creacionrubros_pr.sql

--2. Finalizo a 31/12/2025 los rubros que ya no estén en el 2026
select *
from 
--update 
rh_lm_cuenta c
set dfecha_final_vig = to_date('31/12/2025','dd/mm/yyyy')
where  c.scompania=206
and sysdate between c.dfecha_inicio_vig and nvl(c.dfecha_final_vig,sysdate)
and c.codigo_presupuesto is not null
and c.stipo_funcionario= 'PLANTA'
and c.codigo_presupuesto not in (select r.interno from pr_rubro r where r.vigencia = 2026)
; --83 update. Ver plano rh_lm_cuenta_PLANTA_hasta_2025.csc sin ultima linea
  --65 update última linea. Ult. aplicado
  --prod 65 ok

--Creo nuevos registros en rh_lm_cuenta a partir del 1/1/2026 con los nuevos rubros que estén en 2026 y no estén en 2025.
insert into rh_lm_cuenta (scompania, stipo_funcionario, sconcepto, dfecha_inicio_vig, dfecha_final_vig, 
                  scuenta, ncierre, codigo_presupuesto, cc, grupo_ra, tipo_ra, codigo_ppto_reserva)

select scompania, stipo_funcionario, sconcepto, to_date('1/1/2026','dd/mm/yyyy'), to_date('31/12/2045','dd/mm/yyyy'), 
                  scuenta, ncierre, r26.interno, cc, grupo_ra, tipo_ra, codigo_ppto_reserva
from rh_lm_cuenta c, pr_rubro r26, pr_rubro r
where  c.scompania=206
and c.dfecha_final_vig = to_date('31/12/2025','dd/mm/yyyy')
and c.codigo_presupuesto is not null
and r.vigencia = 2025
and c.stipo_funcionario= 'PLANTA'
and r26.tipo_plan = r.tipo_plan
and r26.vigencia = 2026
and r.tipo_plan = 'PLAN_ADMONCENTRAL'
and c.codigo_presupuesto = r.interno
and r26.interno_nivel1||'-'||r26.interno_nivel2||'-'||r26.interno_nivel3||'-'||r26.interno_nivel4||'-'||r26.interno_nivel5||'-'||
    r26.interno_nivel6||'-'||r26.interno_nivel7||'-'||r26.interno_nivel8||'-'||r26.codigo_tipo||'-'||r26.codigo_componente||'-'||
    r26.codigo_objeto||'-'||r26.codigo_fuente||'-'||r26.codigo_det_fuente =
    r.interno_nivel1||'-'||r.interno_nivel2||'-'||r.interno_nivel3||'-'||r.interno_nivel4||'-'||r.interno_nivel5||'-'||
    r.interno_nivel6||'-'||r.interno_nivel7||'-'||r.interno_nivel8||'-'||r.codigo_tipo||'-'||r.codigo_componente||'-'||
    r.codigo_objeto||'-'||r.codigo_fuente||'-'||r.codigo_det_fuente
--and r26.interno <> r.interno    
; --59 (con  83 update)  no permite por RH.RH_PK_LMCU
  --39 (con 65 update) ok
  --prod 39 ok

--Si se proceden a insertar los restantes.
--Para este caso 39-65 = 26 registros a insertar.
insert into rh_lm_cuenta (scompania, stipo_funcionario, sconcepto, dfecha_inicio_vig, dfecha_final_vig, 
                  scuenta, ncierre, codigo_presupuesto, cc, grupo_ra, tipo_ra, codigo_ppto_reserva)
select scompania, stipo_funcionario, sconcepto, to_date('1/1/2026','dd/mm/yyyy'), to_date('31/12/2045','dd/mm/yyyy'), 
                  scuenta, ncierre, codigo_presupuesto, cc, grupo_ra, tipo_ra, codigo_ppto_reserva
from rh_lm_cuenta c
where  c.scompania=206
and c.dfecha_final_vig = to_date('31/12/2025','dd/mm/yyyy')
and c.codigo_presupuesto is not null
and c.stipo_funcionario= 'PLANTA'
and c.codigo_presupuesto not in 
    (   select r.interno 
        from pr_rubro r 
        where r.vigencia = 2025
        and r.tipo_plan = 'PLAN_ADMONCENTRAL')
;
--prueba 26
--prod 26 ok

--se verifica que no existan conceptos repetidos
select sconcepto, count(1)
from rh_lm_cuenta c
where c.stipo_funcionario= 'PLANTA'
and c.scompania=206
and sysdate between c.dfecha_inicio_vig and nvl(c.dfecha_final_vig,sysdate)
and c.codigo_presupuesto is not null
group by sconcepto
having count(1)>1

--commit;
--rollback


--RH.RH_PK_LMCU
select *
from dba_constraints
where constraint_name = 'RH_PK_LMCU'
;

select *
from rh_lm_cuenta
where scompania = 206
and stipo_funcionario='PLANTA'
and sconcepto like 'SUELDOBASICO'