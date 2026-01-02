
 --Consulta de reporte de cesantias
 select --/*
     -- b.sconcepto, b.codigo_presupuesto,
      --/*
      -- c.codigo_nivel1 n1,  c.codigo_nivel2 n2,   c.codigo_nivel3 n3,
      -- c.codigo_nivel4 n4,      
       codigo_nivel5|| '-' ||codigo_nivel6|| '-'|| codigo_nivel7|| '-'|| codigo_nivel8 nresto,
      c.descripcion,         --  c.interno_rubro,
    --   sum(decode(regimen,'1',a.valor,'2',a.valor,'3',0)) valora,
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

--PARA CONSULTAR ENTIDADES DE CESANTIAS QUE SON PUBLICAS INFOCESANTIAS_FONDOS_PUB O PRIVADAS INFOCESANTIAS_FONDOS
SELECT  --ss.funcionario,
        --distinct 
        e.tipo_entidad,
        decode(e.tipo_entidad,1,'INFOCESANTIAS_FONDOS_PUB',null,'INFOCESANTIAS_FONDOS','OTRO') sconceptos, 
       decode(e.tipo_entidad,1,'02-003-0001-0000000',2,'02-003-0002-0000000','OTRO') codigo_presupuesto,
        ss.entidad,e.tipo, e.descripcion 
     FROM rh_seguridad_social ss, rh_entidad e
    WHERE ss.tipo_entidad = 'FONDO_CESANTIAS'
      AND ss.tipo_entidad = e.tipo
      AND ss.entidad = e.codigo
      AND ss.fecha_afiliacion <= sysdate
      AND (ss.fecha_retiro >= sysdate OR ss.fecha_retiro IS NULL)
      AND codigo=ss.entidad   
      order by ss.funcionario
      ;


select *
from rh_entidad
where tipo_servicio ='CESANTIAS'
;

--Actualización CONCEPTO fondo penSiones en la ra.
--update
 rh_t_lm_valores
set SCONCEPTO= --'INFOCESANTIAS_FONDOS_PUB'  --cuando  TIPO_ENTIDAD = 1
              'INFOCESANTIAS_FONDOS'      --cuando  TIPO_ENTIDAD =  NULL
 where  ntipo_nomina = 0 
   and periodo='31/dec/2025' and nro_ra =30
   and nfuncionario = 
        (SELECT f.personas_interno
          FROM rh_funcionario f, rh_seguridad_social ss, rh_entidad e
          WHERE ss.tipo_entidad = 'FONDO_CESANTIAS'
            AND ss.tipo_entidad = e.tipo
            AND ss.entidad = e.codigo
            AND ss.fecha_afiliacion <= sysdate
            AND (ss.fecha_retiro >= sysdate OR ss.fecha_retiro IS NULL)
            AND codigo=ss.entidad   
            and e.tipo_entidad  IS NULL        --DE ESTO DEPENDE para actualizar el SCONCEPTO
            and ss.funcionario=f.personas_interno
            and f.estado_funcionario = 1 --ACTIVO
            and rh_t_lm_valores.nfuncionario=ss.funcionario
        )
 ;


select * from
--update
 rh_t_lm_valores
--set valor=0
 where  ntipo_nomina = 0 and periodo='31/dec/2025' and nro_ra =30
 and sconcepto like 'INFOCESANTIAS_FONDOS%'
 and regimen in (1,2);

commit;

---Consulta RH_T_LM_VALORES
select *
from rh_t_lm_valores
 where ntipo_nomina = 0 and periodo='31/dec/2025' 
 and nro_ra =30
 and 595
 --and sconcepto like 'INFOCESANTIAS_FONDOS%'
 order by nfuncionario
 ;

 --Consulta funcionario en RH_T_LM_VALORES ver cesantias
 select v.nfuncionario, v.sconcepto, p.numero_identificacion
from rh_t_lm_valores v, rh_personas p
 where v.ntipo_nomina = 0 and v.periodo='31/dec/2025' 
 and v.nro_ra =30
 and v.nfuncionario = p.interno_persona
 --and sconcepto like 'INFOCESANTIAS_FONDOS%'
 order by v.nfuncionario
 ;

 --Borro datos de la RA borrado desde pantalla.. donde nro_ra is null
 delete
 rh_t_lm_valores
 where  ntipo_nomina = 0 and periodo='31/dec/2025' 
 --and nro_ra =30
 and sconcepto like 'INFOCESANTIAS_FONDOS%'
 ;

 commit;