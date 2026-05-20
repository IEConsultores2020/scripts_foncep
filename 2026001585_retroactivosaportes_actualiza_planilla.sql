--drop table rh_tmp_planillaretro2026

create table rh_tmp_planillaretro2026 (
    periodo varchar2(8),
    documento varchar2(15),
    penpub number(10),
    penpriv number(10),
    salud number(10),
    arl number(10),
    caja number(10),
    sena number(10),
    icbf number(10)
)
;


select periodo, documento sum(penpub) penpub, sum(penpriv) penpriv, sum(salud) salud, sum(caja) caja, 
    sum(arl) arl, sum(icbf) icbf, sum(sena) sena
from rh_tmp_planillaretro2026
group by periodo
;


select * --sum(t.valor) penpub_ra
from rh_t_lm_valores t
where t.periodo = to_date('31/1/2026','DD/MM/YYYY')
and t.ntipo_nomina =1
and t.stipofuncionario='PLANTA'
and extract(year from t.periodo) = 2026
and t.nro_ra=8       
and t.nfuncionario =45
and t.sconcepto = 'PENSIONES-PUB' --in ('PENSIONES-PUB','SALUD','SENA','ICBF','CAJA')
order by nfuncionario
;

select p.numero_identificacion, t.valor, ll.penpub, tvalor - ll.penpub --sum(t.valor) penpub_ra, sum(ll.penpub) penpub_pll
from rh_t_lm_valores t, 
    rh_personas p,
    (
        select periodo, documento, sum(penpub) penpub, sum(penpriv) penpriv, 
                sum(salud) salud, sum(caja) caja, 
                sum(arl) arl, sum(icbf) icbf, sum(sena) sena
        from rh_tmp_planillaretro2026
        group by periodo, documento
    ) ll
where t.periodo = to_date('31/1/2026','DD/MM/YYYY')
and ll.periodo = '20260131'
and t.ntipo_nomina = 1
and t.stipofuncionario='PLANTA'
and extract(year from t.periodo) = 2026
and t.nro_ra=8       
and t.sconcepto = 'PENSIONES-PUB' --in ('PENSIONES-PUB','SALUD','SENA','ICBF','CAJA')
and ll.documento = p.numero_identificacion 
and p.interno_persona = t.nfuncionario
--and t.nfuncionario =45
order by nfuncionario
;