--Consulta del report rhlm_ra_nomina
select --/*
      b.sconcepto, b.codigo_presupuesto,
       c.codigo_nivel1 n1,  c.codigo_nivel2 n2,   c.codigo_nivel3 n3,
       c.codigo_nivel4 n4,      
       codigo_nivel5|| '-' ||codigo_nivel6|| '-'|| codigo_nivel7|| '-'|| codigo_nivel8 nresto,
       c.descripcion,           c.interno_rubro,
       sum(decode(regimen,'1',a.valor,'2',a.valor,'3',0)) valora,
       sum(decode(regimen,'3',a.valor,'1',0,'2',0)) valorn
       --*/
  from rh_t_lm_valores a, rh_lm_cuenta b, pr_v_rubros c
 where tipo_ra              = :p_tipo_ra          --4 Cesantias
   and grupo_ra             = :p_grupo_ra   /*5*/    and scompania            = :p_compania
   and stipo_funcionario    = stipofuncionario  and a.sconcepto          = b.sconcepto
   and ncierre              = 1                 and c.interno_rubro      = b.codigo_presupuesto
   and c.vigencia           = :p_vigencia       and a.ntipo_nomina       = :p_tiponomina         --0
   and dfecha_inicio_vig    <= :p_fecha_final   
   and ( dfecha_final_vig   >= :p_fecha_final or dfecha_final_vig is null )
   and b.codigo_presupuesto is not null         and to_char(periodo,'dd/mm/yyyy')  = '31/12/2025' --:p_fecha_final 
  -- and nro_ra               = :p_nrora
  --order by nfuncionario
 group by  b.sconcepto, b.codigo_presupuesto,
          codigo_nivel1,codigo_nivel2,codigo_nivel3,codigo_nivel4,
          codigo_nivel5||'-'|| codigo_nivel6|| '-'|| codigo_nivel7|| '-'|| codigo_nivel8,
          descripcion, interno_rubro
          ;


create table rh_t_lm_valores_to_del as
  (select a.rowid trowid, rownum trownum, nfuncionario, count(1) over (partition by nfuncionario) tcount
    from rh_t_lm_valores a, rh_lm_cuenta b, pr_v_rubros c
  where tipo_ra              = 4 --CESANTIAS
    and grupo_ra             = '5'  and scompania            = 206 
    and stipo_funcionario    = stipofuncionario   and a.sconcepto          = b.sconcepto
    and ncierre              = 1                  and c.interno_rubro      = b.codigo_presupuesto
    and c.vigencia           = 2025               and a.ntipo_nomina       = 0 
    and dfecha_inicio_vig    <= '31/DEC/2025' 
    and ( dfecha_final_vig   >= '31/DEC/2025'     or dfecha_final_vig is null )
    and b.codigo_presupuesto is not null         and to_char(periodo,'dd/mm/yyyy')  = '31/12/2025' 
    and nro_ra               = 30
 -- order by nfuncionario
  )
          ;

select * from rh_t_lm_valores_to_del;

delete rh_t_lm_valores 
where rowid in 
  (select trowid 
    from rh_t_lm_valores_to_del
   where trownum>80 )         ;


commit;

select * from
--update
 rh_t_lm_valores
-- set valor=0
 where  ntipo_nomina = 1 and periodo='31/dec/2025' --and nro_ra =30
 and sconcepto='INFOCESANTIAS_FONDOS'
 and regimen in (1,2);

select distinct from
--update
 rh_t_lm_valores
-- set valor=0
 where  ntipo_nomina = 0 
 and sconcepto like '%CESANTI%'

--commit;

--Se debe corregir la prima de vacaciones de Mónica Yohana Jiménez de 345815  a 6310609 y eliminar la prima fila de la misma funcionaria
--1049606827 interno 607
select * from
--update
 rh_t_lm_valores
-- set valor=0
 where  ntipo_nomina = 1 and periodo='31/dec/2025' --and nro_ra =30
 and sconcepto='INFOCESANTIAS_FONDOS'
 and regimen in (1,2);

 select interno_persona, numero_identificacion, nombres, primer_apellido, segundo_apellido
 from rh_personas
where numero_identificacion=1049606827
;

select *
from rh_t_lm_valores
 where  ntipo_nomina = 1 and periodo='31/dec/2025' and nro_ra =30
 and sconcepto like 'INFOCESANTIAS_FONDOS%'
 ;

 select *
 from rh_historico_nomina