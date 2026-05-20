
--drop view rh_vw_g1585_ra2
create or replace view rh_vw_g1585_ra2 as
select  nfuncionario, nro_ra, sum(PENSION_PUBLICA) PENSION_PUBLICA, sum(PENSION_PRIVADA) PENSION_PRIVADA, 
        sum(SALUD) SALUD, sum(ICBF) ICBF, sum(CCF) CCF, sum(ARL) ARL, sum(SENA) SENA
from
(SELECT  nfuncionario,
        periodo,
        case interno_rubro
          when 1839 then
            sum(decode(regimen, '1', a.valor,'2',a.valor,'3',0)) + sum(decode(regimen, '3', a.valor,'1',0,'2',0)) 
          else 0 end as ICBF,
        case interno_rubro
          when 1836 then
            sum(decode(regimen, '1', a.valor,'2',a.valor,'3',0)) + sum(decode(regimen, '3', a.valor,'1',0,'2',0)) 
          else 0 end as CCF,
        case interno_rubro
          when 1838 then
            sum(decode(regimen, '1', a.valor,'2',a.valor,'3',0)) + sum(decode(regimen, '3', a.valor,'1',0,'2',0)) 
          else 0 end as ARL,
        case interno_rubro
          when 1840 then
            sum(decode(regimen, '1', a.valor,'2',a.valor,'3',0)) + sum(decode(regimen, '3', a.valor,'1',0,'2',0)) 
          else 0 end as sena,
        case interno_rubro
          when 1831 then
            sum(decode(regimen, '1', a.valor,'2',a.valor,'3',0)) + sum(decode(regimen, '3', a.valor,'1',0,'2',0)) 
          else 0 end as PENSION_PUBLICA,      
        case interno_rubro
          when 1832 then
            sum(decode(regimen, '1', a.valor,'2',a.valor,'3',0)) + sum(decode(regimen, '3', a.valor,'1',0,'2',0)) 
          else 0 end as PENSION_PRIVADA,            
        case interno_rubro
          when 1834 then
            sum(decode(regimen, '1', a.valor,'2',a.valor,'3',0)) + sum(decode(regimen, '3', a.valor,'1',0,'2',0)) 
          else 0 end as SALUD, 
        nro_ra 
      --sum(decode(regimen, '1', a.valor,'2',a.valor,'3',0)) + sum(decode(regimen, '3', a.valor,'1',0,'2',0))  total
  --select *
  FROM   rh_t_lm_valores a, rh_lm_cuenta b, pr_v_rubros c
  WHERE  tipo_ra                   = 2      --:P_TIPO_RA
  AND        grupo_ra              = '5'     --:P_GRUPO_RA
  AND        scompania             = 206    --:P_COMPANIA
  AND        stipo_funcionario     = stipofuncionario
  AND        a.sconcepto           = b.sconcepto
  AND        ncierre               = 1
  AND        c.interno_rubro       = b.codigo_presupuesto
  AND        c.vigencia            = 2026   --:P_VIGENCIA
  AND        a.ntipo_nomina        = 1      --:P_TIPONOMINA
  AND        dfecha_inicio_vig <= TO_DATE(20260131,'YYYYMMDD')
  AND       (dfecha_final_vig  >= TO_DATE(20260131,'YYYYMMDD') /*:P_FECHA_FINAL*/ OR dfecha_final_vig IS NULL)
  AND        b.codigo_presupuesto IS NOT NULL
  AND        periodo           = TO_DATE(20260131,'YYYYMMDD') --:P_FECHA_FINAL  20260101 20260228
  AND        nro_ra            = 8 --:P_NRORA                                           --8         
  --AND       nfuncionario in (61,591) --(11,15,20,22,29,39,52,634)
  AND       interno_rubro  --=1836
                          in  (1839, --'Aportes al ICBF'
                              1836, --'Compensar'
                              1838, --'Aportes generales al sistema de riesgos laborales públicos
                              1840, --'Aportes al SENA'
                              1831, --'Aportes a la seguridad social en pensiones públicas'
                              1832, --'Aportes a la seguridad social en pensiones privadas'
                              1834 --'Aportes a la seguridad social en salud privada'
                              )  
  group by nfuncionario,
      periodo, nro_ra, /*codigo_nivel2,
      codigo_nivel3,
      codigo_nivel4,
      codigo_nivel5 || '-' || codigo_nivel6 || '-' || codigo_nivel7 || '-' || codigo_nivel8,
      descripcion,*/
      interno_rubro
  --order by nresto      */                
  order by nfuncionario
 ) t
 group by nfuncionario, nro_ra;
    select h.nfuncionario, p.numero_identificacion, count(1)
    from rh_historico_nomina_hoy h
    join rh_personas p on h.nfuncionario = p.interno_persona
    where h.nhash=854032720 and h.dinicioperiodo>=20260101 and h.dfinalperiodo<=20260131
    group by nfuncionario, p.numero_identificacion
    having count(1)>2
    order by 1
    ;

--Verificación de que totales coincida con  los valores en la RA
select  sum(pension_publica) pension_publica, sum(pension_privada) pension_privada, sum(salud) salud, 
    sum(CCF) CCF, sum(ARL) ARL, sum(ICBF) ICBF,  sum(SENA) SENA
from rh_vw_g1585_ra2 ra2
order by 1; --81

--Consulta para exportar y generar el plano
select  '202601' periodo, p.numero_identificacion, p.nombres||' '||p.primer_apellido||' '||p.segundo_apellido nombres, 
    ra2.pension_privada, ra2.pension_publica, ra2.salud, ra2.icbf, ra2.ccf, ra2.arl, ra2.sena
from rh_vw_g1585_ra2 ra2, rh_personas p
where p.interno_persona=nfuncionario
order by 2 desc; --81


/* Se ajusta el valor de la ra de PENSION, SALUD, ARL
  int   CC        NUEVO   ANTERIOR
  61    51753989    84927 79280
  591    7316992   31752  29723


*/
select *
from rh_t_lm_valores
where periodo = to_date('31/1/2026','DD/MM/YYYY')
and ntipo_nomina =1
and stipofuncionario='PLANTA'
and extract(year from periodo) = 2026
and nfuncionario in (61,591)
and nro_ra=8       
and sconcepto in ('PENSIONES-PUB','SALUD','SENA','ICBF','CAJA')
order by nfuncionario, sconcepto
;


select sum(valor)
from rh_t_lm_valores
where periodo = to_date('31/1/2026','DD/MM/YYYY')
and ntipo_nomina =1
and stipofuncionario='PLANTA'
and extract(year from periodo) = 2026
and nro_ra=8       
;
--prod 1746915
--pru 20721697
