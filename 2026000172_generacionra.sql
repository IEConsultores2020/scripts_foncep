--CURSOR c_conceptos_dtos IS
      SELECT * --stipo_funcionario
        FROM rh_lm_det_grp_funcionario
       WHERE scompania = 206 --una_compania
         AND sGrupo    = 'SALUD'
         AND sGtipo    = 'DESCUENTO'
         AND una_fecha_final BETWEEN dfecha_inicio_vig AND dfecha_final_vig
         AND ncierre   = 1;

update rh_lm_det_grp_funcionario
 set dfecha_final_vig = '31/DEC/2035'
 where scompania = 206 AND sGrupo    = 'SALUD' 
    AND sGtipo    = 'DESCUENTO' AND dfecha_final_vig = '31/DEC/2025' AND ncierre   = 1;         

update rh_lm_det_grp_funcionario
 set dfecha_final_vig = '31/DEC/2035'
 where scompania = 206 AND sGrupo    = 'PENSION'
   AND sGtipo    = 'DESCUENTO' AND dfecha_final_vig = '31/DEC/2025' AND ncierre   = 1;         


update rh_lm_det_grp_funcionario
set dfecha_final_vig = '31/DEC/2035'
 where scompania = 206 AND sGrupo    = 'CESANTIAS'
   AND sGtipo    = 'DESCUENTO' AND dfecha_final_vig = '31/DEC/2025' AND ncierre   = 1;         

update rh_lm_det_grp_funcionario
set dfecha_final_vig = '31/DEC/2035'
 where scompania = 206 AND sGrupo    = 'RETEFUENTE'
   AND sGtipo    = 'DESCUENTO' AND dfecha_final_vig = '31/DEC/2025' AND ncierre   = 1;            

commit ;

--Se aplica para todos los casos y evitar posibles inconsistentias en otros procesos.

select * --stipo_funcionario
  from 
 --update 
 rh_lm_det_grp_funcionario
-- set dfecha_final_vig = '31/DEC/2035'
 where scompania = 206 
   and dfecha_final_vig = '31/DEC/2025'
   and ncierre = 1;

commit;
/*
105 rows updated.

Commit complete.
*/

select *
from RH_PERSONAS
where interno_persona=52;


SELECT * --sgrupo --INTO mi_funcionarioh.mi_tipofuncionario
    FROM rh_lm_det_grp_funcionario
  WHERE scompania         = 206 --una_compania
    AND sgtipo            ='FUNCIONARIO'
    AND stipo_funcionario = 5 --mi_tipofuncionariof
    AND sysdate   BETWEEN dfecha_inicio_vig AND dfecha_final_vig
    AND ncierre           = 1;

update rh_lm_det_grp_funcionario
set ncierre=1    
  WHERE scompania         = 206 --una_compania
    AND sgtipo            ='FUNCIONARIO'
    AND stipo_funcionario = 5 --mi_tipofuncionariof
    AND sysdate   BETWEEN dfecha_inicio_vig AND dfecha_final_vig
    AND ncierre           = 0;

commit;    


select *
from 
update rh_lm_cuenta
set DFECHA_FINAL_VIG='31/DEC/2035'
where DFECHA_FINAL_VIG='31/DEC/2025'
  and scompania=206;

commit;

select *
from bintablas
where grupo='OPGET'

---Para generar el reporte de la ra
SELECT * FROM --rh_lm_cuenta
pr_v_rubros
where vigencia = 2025
minus
SELECT * FROM --rh_lm_cuenta
pr_v_rubros
where vigencia = 2026;


  SELECT c.codigo_nivel1 n1,
                 c.codigo_nivel2 n2,
	 c.codigo_nivel3 n3,
	 c.codigo_nivel4 n4,
                 codigo_nivel5 || '-' || codigo_nivel6 || '-' || codigo_nivel7 || '-' || codigo_nivel8 nresto,
	 c.descripcion,
                 c.interno_rubro,
	 sum(decode(regimen, '1', a.valor,'2',a.valor,'3',0)) valora,
	 sum(decode(regimen, '3', a.valor,'1',0,'2',0)) valorn
  -- select *
  FROM     rh_t_lm_valores a, rh_lm_cuenta b, pr_v_rubros c
  WHERE  tipo_ra                   = :P_TIPO_RA
  AND        grupo_ra                = :P_GRUPO_RA
  AND        scompania             = :P_COMPANIA
  AND        stipo_funcionario   = stipofuncionario
  AND        a.sconcepto          = b.sconcepto
  AND        ncierre                   = 1
  AND        c.interno_rubro      = b.codigo_presupuesto
  AND        c.vigencia             = :P_VIGENCIA
  AND        a.ntipo_nomina     = :P_TIPONOMINA
  AND        dfecha_inicio_vig <= :P_FECHA_FINAL
  AND       (dfecha_final_vig  >= :P_FECHA_FINAL OR dfecha_final_vig IS NULL) 
  AND        b.codigo_presupuesto IS NOT NULL
  AND        periodo           = :P_FECHA_FINAL
  AND        nro_ra            = :P_NRORA
  GROUP BY codigo_nivel1,
                      codigo_nivel2,
                      codigo_nivel3,
                      codigo_nivel4,
                      codigo_nivel5 || '-' || codigo_nivel6 || '-' || codigo_nivel7 || '-' || codigo_nivel8,
                      descripcion,
                      interno_rubro
;


--pr_v_rubros
--create or replace view pr.pr_v_rubros as
select pr_rubro.descripcion, pr_rubro.vigencia, pr_rubro.interno interno_rubro,
          pr_rubro.tipo_plan tipo_plan, pr_nivel1.codigo codigo_nivel1, pr_nivel2.codigo codigo_nivel2,
          pr_nivel3.codigo codigo_nivel3, pr_nivel4.codigo codigo_nivel4, pr_nivel5.codigo codigo_nivel5,
          pr_nivel6.codigo codigo_nivel6, pr_nivel7.codigo codigo_nivel7, pr_nivel8.codigo codigo_nivel8,
          pr_rubro.interno_nivel1, pr_rubro.interno_nivel2, pr_rubro.interno_nivel3, pr_rubro.interno_nivel4,
          pr_rubro.interno_nivel5, pr_rubro.interno_nivel6, pr_rubro.interno_nivel7, pr_rubro.interno_nivel8,
          pr_rubro.codigo_tipo, pr_rubro.codigo_componente, pr_rubro.codigo_objeto, pr_rubro.codigo_fuente,
          pr_rubro.codigo_det_fuente
     from pr_rubro, pr_nivel8, pr_nivel7, pr_nivel6, pr_nivel5, pr_nivel4, pr_nivel3, pr_nivel2, pr_nivel1
    where pr_rubro.vigencia = pr_nivel8.vigencia
      and pr_rubro.interno_nivel8 = pr_nivel8.interno
      and pr_nivel8.vigencia = pr_nivel7.vigencia
      and pr_nivel8.interno_nivel7 = pr_nivel7.interno
      and pr_nivel8.tipo_plan = pr_nivel7.tipo_plan
      and pr_nivel7.vigencia = pr_nivel6.vigencia
      and pr_nivel7.interno_nivel6 = pr_nivel6.interno
      and pr_nivel7.tipo_plan = pr_nivel6.tipo_plan
      and pr_nivel6.vigencia = pr_nivel5.vigencia
      and pr_nivel6.interno_nivel5 = pr_nivel5.interno
      and pr_nivel6.tipo_plan = pr_nivel5.tipo_plan
      and pr_nivel5.vigencia = pr_nivel4.vigencia
      and pr_nivel5.interno_nivel4 = pr_nivel4.interno
      and pr_nivel5.tipo_plan = pr_nivel4.tipo_plan
      and pr_nivel4.vigencia = pr_nivel3.vigencia
      and pr_nivel4.interno_nivel3 = pr_nivel3.interno
      and pr_nivel4.tipo_plan = pr_nivel3.tipo_plan
      and pr_nivel3.vigencia = pr_nivel2.vigencia
      and pr_nivel3.interno_nivel2 = pr_nivel2.interno
      and pr_nivel3.tipo_plan = pr_nivel2.tipo_plan
      and pr_nivel2.vigencia = pr_nivel1.vigencia
      and pr_nivel2.interno_nivel1 = pr_nivel1.interno
      and pr_nivel2.tipo_plan = pr_nivel1.tipo_plan;



 SELECT /*c.codigo_nivel1 n1,
                 c.codigo_nivel2 n2,
	 c.codigo_nivel3 n3,
	 c.codigo_nivel4 n4,
                 codigo_nivel5 || '-' || codigo_nivel6 || '-' || codigo_nivel7 || '-' || codigo_nivel8 nresto,*/
   c.*,
	 c.descripcion,
                 c.interno_rubro,
	 sum(decode(regimen, '1', a.valor,'2',a.valor,'3',0)) valora,
	 sum(decode(regimen, '3', a.valor,'1',0,'2',0)) valorn
   select c.*
  FROM     rh_t_lm_valores a, rh_lm_cuenta b, pr_rubro c
  WHERE  tipo_ra                   = :P_TIPO_RA
  AND        grupo_ra                = :P_GRUPO_RA
  AND        scompania             = :P_COMPANIA
  AND        stipo_funcionario   = stipofuncionario
  AND        a.sconcepto          = b.sconcepto
  AND        ncierre                   = 1
  AND        c.interno /*_rubro*/      = b.codigo_presupuesto
  AND        c.vigencia             = :P_VIGENCIA
  AND        a.ntipo_nomina     = :P_TIPONOMINA
  AND        dfecha_inicio_vig <= :P_FECHA_FINAL
  AND       (dfecha_final_vig  >= :P_FECHA_FINAL OR dfecha_final_vig IS NULL) 
  AND        b.codigo_presupuesto IS NOT NULL
  AND        periodo           = :P_FECHA_FINAL
  AND        nro_ra            = :P_NRORA
  GROUP BY codigo_nivel1,
                      codigo_nivel2,
                      codigo_nivel3,
                      codigo_nivel4,
                      codigo_nivel5 || '-' || codigo_nivel6 || '-' || codigo_nivel7 || '-' || codigo_nivel8,
                      descripcion,
                      interno_rubro
;      

select *
from pr_rubro
where vigencia=2026;

select interno||'-'||interno_nivel1||'-'||interno_nivel2||'-'||interno_nivel3||'-'||interno_nivel4||'-'||
       interno_nivel5||'-'||interno_nivel6||'-'||interno_nivel7||'-'||interno_nivel8||'-'||descripcion||'-'||tipo_plan
    from pr_rubro
    where vigencia=2025
    minus
    select interno||'-'||interno_nivel1||'-'||interno_nivel2||'-'||interno_nivel3||'-'||interno_nivel4||'-'||
          interno_nivel5||'-'||interno_nivel6||'-'||interno_nivel7||'-'||interno_nivel8||'-'||descripcion||'-'||tipo_plan
    from pr_rubro
    where vigencia=2026
    ;

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
