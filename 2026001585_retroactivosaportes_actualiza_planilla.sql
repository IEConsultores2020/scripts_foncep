--drop table rh_tmp_planillaretro2026

create table rh_tmp_planillaretro2026 (
    periodo varchar2(8),
    documento varchar2(15),
    nombre varchar2(300),
    ibc_ps number(10),
    penpub number(10),
    penpriv number(10),
    salud number(10),
    arl number(10),
    caja number(10),
    sena number(10),
    icbf number(10)
)
;


select periodo, sum(penpub) penpub, sum(penpriv) penpriv, sum(salud) salud, sum(caja) caja, 
    sum(arl) arl, sum(icbf) icbf, sum(sena) sena
    --select *
from rh_tmp_planillaretro2026
--where documento = 1030612429
group by periodo
;


select t.sconcepto, sum(t.valor)
from 
--delete 
rh_t_lm_valores t
where t.periodo = to_date('28/2/2026','DD/MM/YYYY')
and t.ntipo_nomina =1
and t.stipofuncionario='PLANTA'
and extract(year from t.periodo) = 2026
and t.nro_ra=9
--and t.nfuncionario =45 --510
--and t.sconcepto = 'PENSIONES-PUB' --in ('PENSIONES-PUB','SALUD','SENA','ICBF','CAJA')
group by t.sconcepto
--order by nfuncionario
;

--commit
--rollback


--Preparo vista para comparar con lo cargado en la planilla
create or replace  view rh_ra_t_vw_planilla as
select tt.nfuncionario, tt.periodo, tt.ntipo_nomina, tt.stipofuncionario, tt.nro_ra,
        sum(tt.penpriv_ra) penpri_ra, SUM(tt.penpub_ra) penpub_ra,
        sum(tt.salud_ra) salud_ra, SUM(tt.sena_ra) sena_ra, sum(tt.arl_ra) arl_ra,
        sum(tt.icbf_ra) icbf_ra, sum(tt.caja_ra) caja_ra
from (        
select nfuncionario, t.periodo, t.ntipo_nomina, t.stipofuncionario, t.nro_ra,
        case t.sconcepto
        when  'PENSIONES' then
        sum(t.valor) 
        else 0
        end PENPRIV_RA,
        case t.sconcepto
        when  'PENSIONES-PUB' then
        sum(t.valor)  
        else 0
        end PENPUB_RA,
        case t.sconcepto
        when  'SALUD' then
        sum(t.valor)  
        else 0
        end SALUD_RA ,     
        case t.sconcepto
        when  'SENA' then
        sum(t.valor) 
        else 0
        end SENA_RA,    
        case t.sconcepto
        when  'ARP' then
        sum(t.valor) 
        else 0
        end ARL_RA,  
        case t.sconcepto
        when  'ICBF' then
        sum(t.valor)  
        else 0
        end ICBF_RA,              
        case t.sconcepto
        when  'CAJA' then
        sum(t.valor)  
        else 0
        end CAJA_RA                                                           
from rh_t_lm_valores t
where t.periodo in (to_date('31/1/2026','DD/MM/YYYY'),to_date('28/2/2026','DD/MM/YYYY'))
and t.ntipo_nomina =1
and t.stipofuncionario='PLANTA'
and extract(year from t.periodo) = 2026
and t.nro_ra in (8,9)     
--and t.nfuncionario =510
and t.sconcepto in ('PENSIONES','PENSIONES-PUB','SALUD','SENA','ARP','ICBF','CAJA') 
group by t.nfuncionario, t.sconcepto, t.periodo, t.ntipo_nomina, t.stipofuncionario, t.nro_ra) tt
group by tt.nfuncionario,  tt.periodo, tt.ntipo_nomina, tt.stipofuncionario, tt.nro_ra
;

select * from rh_ra_t_vw_planilla
;



---Comparo la RA con la planilla, usando la vista creada rh_ra_t_vw_planilla
select p.numero_identificacion, 
        p.primer_apellido, p.segundo_apellido, p.nombres, 
        t.penpub_ra, nvl(ll.penpub,0) penpub, t.penpub_ra - nvl(ll.penpub,0) dif_penpub,
        t.penpri_ra, nvl(ll.penpriv,0) penpriv, t.penpri_ra - nvl(ll.penpriv,0) dif_penpriv,
        t.salud_ra, nvl(ll.salud,0) salud, t.salud_ra - nvl(ll.salud,0) dif_salud,
        t.sena_ra, nvl(ll.sena,0) sena, t.sena_ra - nvl(ll.sena,0) dif_sena,
        t.arl_ra, nvl(ll.arl,0) arl, t.arl_ra - nvl(ll.arl,0) dif_arl,
        t.caja_ra, nvl(ll.caja,0) caja, t.caja_ra - nvl(ll.caja,0) dif_caja,
        t.icbf_ra, nvl(ll.icbf,0) icbf, t.icbf_ra - nvl(ll.icbf,0) dif_icbf
from rh_ra_t_vw_planilla t,
    rh_personas p,
    (
        select periodo, documento, sum(penpub) penpub, sum(penpriv) penpriv, 
                sum(salud) salud, sum(caja) caja, 
                sum(arl) arl, sum(icbf) icbf, sum(sena) sena
        from rh_tmp_planillaretro2026
        group by periodo, documento
    ) ll
where t.periodo = to_date('28/2/2026','DD/MM/YYYY')
and ll.periodo = '20260228'
and t.ntipo_nomina = 1
and t.stipofuncionario='PLANTA'
and extract(year from t.periodo) = 2026
and t.nro_ra=9
and ll.documento = p.numero_identificacion 
and p.interno_persona = t.nfuncionario
--and numero_identificacion = 1030612429
--and t.nfuncionario =45
order by p.primer_apellido, p.segundo_apellido, p.nombres
;


--Consulta antes del proceso de actualización de la RA.
select t.nfuncionario, t.valor , --sum(t.valor), 
        (select sum(penpub) 
        from rh_tmp_planillaretro2026 ll, rh_personas p
        where ll.documento = p.numero_identificacion
        and p.interno_persona = t.nfuncionario
        and periodo = 20260228
        group by documento) valor_planilla
from rh_t_lm_valores t 
where t.periodo = to_date('20260228','YYYYMMDD')
and t.ntipo_nomina =1
and t.stipofuncionario='PLANTA'
--and t.nfuncionario = 510
and extract(year from t.periodo) = 2026
and t.nro_ra=9       
and t.sconcepto = 'PENSIONES-PUB' --in ('PENSIONES-PUB','SALUD','SENA','ICBF','CAJA')
;

------------------------------------------------------------------------------------------
---ACTUALIZACIONES DE LA RA
------------------------------------------------------------------------------------------

--Actualización
--PENSIONES-PUB
update rh_t_lm_valores t
  set valor = 
        (select sum(penpub) 
        from rh_tmp_planillaretro2026 ll, rh_personas p
        where ll.documento = p.numero_identificacion
        and p.interno_persona = t.nfuncionario
        and periodo = 20260228
        group by documento) 
where t.periodo = to_date('20260228','YYYYMMDD')
and t.ntipo_nomina =1
and t.stipofuncionario='PLANTA'
and extract(year from t.periodo) = 2026
and t.nro_ra=9
and t.sconcepto = 'PENSIONES-PUB' --in ('PENSIONES','PENSIONES-PUB','SALUD','SENA','ARP','ICBF','CAJA') 
;

---UPDATE PENSIONES PRIVADAS
update rh_t_lm_valores t
  set valor = 
        (select sum(penpriv) 
        from rh_tmp_planillaretro2026 ll, rh_personas p
        where ll.documento = p.numero_identificacion
        and p.interno_persona = t.nfuncionario
        and periodo = 20260228
        group by documento) 
where t.periodo = to_date('20260228','YYYYMMDD')
and t.ntipo_nomina =1
and t.stipofuncionario='PLANTA'
--and t.nfuncionario = 510
and extract(year from t.periodo) = 2026
and t.nro_ra=9
and t.sconcepto = 'PENSIONES' --in ('PENSIONES','PENSIONES-PUB','SALUD','SENA','ARP','ICBF','CAJA') 
;

---UPDATE SALUD
update rh_t_lm_valores t
  set valor = 
        (select sum(SALUD) 
        from rh_tmp_planillaretro2026 ll, rh_personas p
        where ll.documento = p.numero_identificacion
        and p.interno_persona = t.nfuncionario
        and periodo = 20260228
        group by documento) 
where t.periodo = to_date('20260228','YYYYMMDD')
and t.ntipo_nomina =1
and t.stipofuncionario='PLANTA'
--and t.nfuncionario = 510
and extract(year from t.periodo) = 2026
and t.nro_ra=9
and t.sconcepto = 'SALUD' --in ('PENSIONES','PENSIONES-PUB','SALUD','SENA','ARP','ICBF','CAJA') 
;

---UPDATE SENA
update rh_t_lm_valores t
  set valor = 
        (select sum(SENA) 
        from rh_tmp_planillaretro2026 ll, rh_personas p
        where ll.documento = p.numero_identificacion
        and p.interno_persona = t.nfuncionario
        and periodo = 20260228
        group by documento) 
where t.periodo = to_date('20260228','YYYYMMDD')
and t.ntipo_nomina =1
and t.stipofuncionario='PLANTA'
--and t.nfuncionario = 510
and extract(year from t.periodo) = 2026
and t.nro_ra=9
and t.sconcepto = 'SENA' --in ('PENSIONES','PENSIONES-PUB','SALUD','SENA','ARP','ICBF','CAJA') 
;

---UPDATE ARL
update rh_t_lm_valores t
  set valor = 
        (select sum(ARL) 
        from rh_tmp_planillaretro2026 ll, rh_personas p
        where ll.documento = p.numero_identificacion
        and p.interno_persona = t.nfuncionario
        and periodo = 20260228
        group by documento) 
where t.periodo = to_date('20260228','YYYYMMDD')
and t.ntipo_nomina =1
and t.stipofuncionario='PLANTA'
--and t.nfuncionario = 510
and extract(year from t.periodo) = 2026
and t.nro_ra=9
and t.sconcepto = 'ARP' --in ('PENSIONES','PENSIONES-PUB','SALUD','SENA','ARP','ICBF','CAJA') 
;

---UPDATE ARL
update rh_t_lm_valores t
  set valor = 
        (select sum(ICBF) 
        from rh_tmp_planillaretro2026 ll, rh_personas p
        where ll.documento = p.numero_identificacion
        and p.interno_persona = t.nfuncionario
        and periodo = 20260228
        group by documento) 
where t.periodo = to_date('20260228','YYYYMMDD')
and t.ntipo_nomina =1
and t.stipofuncionario='PLANTA'
--and t.nfuncionario = 510
and extract(year from t.periodo) = 2026
and t.nro_ra=9
and t.sconcepto = 'ICBF' --in ('PENSIONES','PENSIONES-PUB','SALUD','SENA','ARP','ICBF','CAJA') 
;


---UPDATE CAJA
update rh_t_lm_valores t
  set valor = 
        (select sum(CAJA) 
        from rh_tmp_planillaretro2026 ll, rh_personas p
        where ll.documento = p.numero_identificacion
        and p.interno_persona = t.nfuncionario
        and periodo = 20260228
        group by documento) 
where t.periodo = to_date('20260228','YYYYMMDD')
and t.ntipo_nomina =1
and t.stipofuncionario='PLANTA'
--and t.nfuncionario = 510
and extract(year from t.periodo) = 2026
and t.nro_ra=9
and t.sconcepto = 'CAJA' --in ('PENSIONES','PENSIONES-PUB','SALUD','SENA','ARP','ICBF','CAJA') 
;

--commit;

select *
from rh_personas --510
where numero_identificacion = 1030612429;


