/*
*/
pr_leer_aportes_patron(mi_compania,mi_fecha_final,mi_anho,mi_mes,:b_nom_parafiscales.ntipo_nomina,mi_tipos_func,mi_err);
pr_leer_incapacidades(mi_compania,mi_fecha_final,mi_anho,mi_mes,:b_nom_parafiscales.ntipo_nomina,mi_tipos_func,mi_err);
pk_rhlm_ra.pr_atomizar_cuenta(mi_compania,4,:b_nom_parafiscales.ntipo_nomina,mi_fecha_final,:GLOBAL.mi_adm_ope,mi_tipos_func,mi_err);
pr_leer_saldos(mi_compania, mi_fecha_final,mi_anho,mi_mes,:b_nom_parafiscales.ntipo_nomina,mi_tipos_func,mi_err);
--Planilla corrección
RH_R2388_DETALLE
RH_R2388_ENCABEZADO
*/

select *
from rh_r2388_detalle n
where n.anho='2026' 
and n.mes=1
and n.funcionario=52
and n.tipo_planilla = 'N'
;

drop view rh_vw_g1585_r2388

create or replace view rh_vw_g1585_r2388 as
select n.funcionario, n.mes, 
      n.total_ccf - e.total_ccf ccf,
      n.total_arl - e.total_arl arl,
      n.total_sena - e.total_sena sena,
      n.total_icbf - e.total_icbf icbf
from rh_r2388_detalle n, rh_r2388_detalle e
where n.anho='2026' 
and n.mes in (1,2)
--and n.funcionario=52 --635
and n.tipo_planilla = 'N'
and n.anho=e.anho
and n.mes=e.mes
and n.funcionario=e.funcionario
and n.tipo_planilla = 'N'
and e.tipo_planilla = 'E'
and n.fecha_novedad = e.fecha_novedad
;

    CURSOR c_paraf IS
      SELECT *  --argumento
        FROM bintablas
       WHERE grupo = 'NOMINA'
         AND nombre = 'GRUPOS_PARAF'
         AND vig_inicial <= sysdate
         AND (vig_final >= sysdate OR vig_final IS NULL);
         --1 BASE  ICBF, SENA, CAJAS, INSTITUTOS_TECNICOS

--pk_generar_parafiscales.pr_generar_paraf
--pk_detalle_anexos_ra.fn_detalle_beneficiarios(mi_concepto_paraf,mi_err)
--pk_rhlm_ra.pr_inserta_tmp

create or replace view rh_vw_g1585_ra2 as
select nfuncionario, nro_ra, sum(ICBF) ICBF, sum(CCF) CCF, sum(ARL) ARL, sum(SENA) SENA
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
  AND        dfecha_inicio_vig <= TO_DATE(20260228,'YYYYMMDD')
  AND       (dfecha_final_vig  >= TO_DATE(20260228,'YYYYMMDD') /*:P_FECHA_FINAL*/ OR dfecha_final_vig IS NULL)
  AND        b.codigo_presupuesto IS NOT NULL
  AND        periodo           = TO_DATE(20260228,'YYYYMMDD') --:P_FECHA_FINAL  20260101 20260228
  AND        nro_ra            = 9 --:P_NRORA                                           --8         
  --AND       nfuncionario in (11,15,20,22,29,39,52,634)
  AND       interno_rubro  --=1836
                          in  (1839, --'Aportes al ICBF'
                              1836, --'Compensar'
                              1838, --'Aportes generales al sistema de riesgos laborales públicos
                              1840 --'Aportes al SENA'
                              )  --*/
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

   select *
    from rh_tipos_acto_nove
    where nombre = 'INFO_PLANILLA_ENTIDAD' --854032720
    --'INFOAPORTEPARAF' --543977345


      select *
    from rh_historico_nomina_hoy
    where nhash=854032720 and dinicioperiodo>=20260101 and dfinalperiodo<=20260131
    and nfuncionario=52
    order by dfecharegistro desc
    ;

     select *
    from rh_historico_nomina_hoy
    where nhash=854032720 and dinicioperiodo>=20260101 and dfinalperiodo<=20260131
    and dfechanovedad >= 20260301 and dfechanovedad <= 20260331
    and nfuncionario=52
    order by dfecharegistro desc;

    select numero_identificacion, interno_persona
    from RH_PERSONAS
    where numero_identificacion = 1014179264
    1014179264	    635
    1010211471      656
    52025918        52
    ;


    select h.nfuncionario, p.numero_identificacion, count(1)
    from rh_historico_nomina_hoy h
    join rh_personas p on h.nfuncionario = p.interno_persona
    where h.nhash=854032720 and h.dinicioperiodo>=20260101 and h.dfinalperiodo<=20260131
    group by nfuncionario, p.numero_identificacion
    having count(1)>2
    order by 1
    ;

    select *
    from rh_t_lm_valores a
    where a.ntipo_nomina        = 1      --:P_TIPONOMINA
    and extract(year from periodo) = 2026
    --and extract(month from periodo) = 4
    and /*periodo           = '01-MAR-2026'
    and*/ nro_ra            = 8
    order by periodo desc
;

select  count(1) --sum(ICBF) ICBF, sum(CCF) CCF, sum(ARL) ARL, sum(SENA) SENA
from rh_vw_g1585_ra1;  --79

select  count(1) --sum(ICBF) ICBF, sum(CCF) CCF, sum(ARL) ARL, sum(SENA) SENA
from rh_vw_g1585_ra2; --81

select count(distinct funcionario), mes  --, sum(ccf) ccf, sum(arl) arl, sum(sena) sena, sum(icbf) icbf 
from rh_vw_g1585_r2388
group by mes
;--1 80, 2 81


select funcionario, p.ccf ccfp, r.ccf ccfr, p.arl arlp, r.arl arlr, p.sena senap, r.sena senar, p.icbf icbfp, r.icbf icbfr
from (select funcionario, mes, sum(ccf) ccf, sum(arl) arl, sum(sena) sena, sum(icbf) icbf 
      from rh_vw_g1585_r2388
      group by funcionario, mes) p, rh_vw_g1585_ra1 r
where p.mes = 1
and p.funcionario = r.nfuncionario
and (p.ccf - r.ccf != 0 or p.arl - r.arl != 0 or p.sena - r.sena != 0 or p.icbf - r.icbf != 0) 
union
select funcionario, sum(ccf) ccf, 0, sum(arl) arl, 0, sum(sena) sena, 0,sum(icbf) icbf,0 
  from rh_vw_g1585_r2388
  where funcionario not in (select distinct nfuncionario from rh_vw_g1585_ra1)
  and mes = 1
group by funcionario
;


select funcionario, p.ccf ccfp, r.ccf ccfr, p.arl arlp, r.arl arlr, p.sena senap, r.sena senar, p.icbf icbfp, r.icbf icbfr
from (select funcionario, mes, sum(ccf) ccf, sum(arl) arl, sum(sena) sena, sum(icbf) icbf 
      from rh_vw_g1585_r2388
      group by funcionario, mes) p, rh_vw_g1585_ra2 r
where p.mes = 2
and p.funcionario = r.nfuncionario
and (p.ccf - r.ccf != 0 or p.arl - r.arl != 0 or p.sena - r.sena != 0 or p.icbf - r.icbf != 0) ;

