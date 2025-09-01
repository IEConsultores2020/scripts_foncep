SELECT * FROM
(
select /*a.funcionario,*/ b.primer_apellido||' '||b.segundo_apellido||' '||b.nombres nombre,
   sum(
    case 
        when a.tipo_aporte  = 'CAJA' then
            a.aporte_entidad
        else 0
    end) "CAJA" ,
    sum(
    case 
        when a.tipo_aporte  = 'ICBF' then
            a.aporte_entidad
        else 0
    end) "ICBF",
    sum(
    case 
        when a.tipo_aporte  = 'SENA' then
            a.aporte_entidad
        else 0
    end) "SENA"
from rh_aportes a, rh_personas b
where a.funcionario = b.interno_persona AND
 a.funcionario = 219 and
 a.ano=2025 and 
 a.mes = 7 and a.tipo_aporte in   ('CAJA','ICBF','SENA')
group by /*a.funcionario,*/ b.primer_apellido ,b.segundo_apellido,b.nombres,a.tipo_aporte
)
where "CAJA" <>0
 order by 1 asc;

 select *
 from rh_personas
 where numero_identificacion =  80039413;

 select *
 from 
 --update 
 RH_T_LM_VALORES 
--set valor = 183200
 where NFUNCIONARIO = 219
 and periodo = to_date('2025-07-31','YYYY-MM-DD')
 AND sconcepto = 'CAJA'
 and valor = 172400
 ;


 select *
 from 
 update 
 RH_T_LM_VALORES 
 set valor = 129300+8100
 where NFUNCIONARIO = 219
 and periodo = to_date('2025-07-31','YYYY-MM-DD')
 AND sconcepto IN ('ICBF')
 and valor = 129300
 ;

  select *
 from 
 update 
 RH_T_LM_VALORES 
set valor = 86200+5400
 where NFUNCIONARIO = 219
 and periodo = to_date('2025-07-31','YYYY-MM-DD')
 AND sconcepto IN ('SENA')
 and valor = 86200
 ;

COMMIT;