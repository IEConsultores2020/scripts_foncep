select --sconcepto, sum(valor)
        --* 
      sum(valor)
from
    --update 

    rh_t_lm_valores
where
    extract(year from periodo) = 2026
    and periodo = '28/feb/2026' 
    and stipofuncionario = 'PLANTA' 
    and nro_ra = 4
    and sconcepto not in ('PROV_CESANTIAS','PROV_CESANTIAS_ANT','PASAPORTEFONDOGARANTIA','PASAPORTESALUD','CCOMFAVIDI2')
--group by sconcepto --periodo 
order by  1
;

 
--Cursor c_dat (var_inimes Number, var_finmes Number, var_fpago Number) Is
select nfuncionario, -- tipo_documento, numero_identificacion, nombres, primer_apellido, segundo_apellido,
    dfechaefectiva, dfechafinal, dfechanovedad, ndcampo0 ibc_sal, ndcampo1 ibc_pen,
    ndcampo2 dias_sal, ndcampo3 dias_pen, ndcampo4 porc_sal, ndcampo5 aporte_sal, ndcampo6 total_sal,
    ndcampo7 porc_pen, ndcampo8 aporte_pen, ndcampo9 total_pen,
        ndcampo11 total_ibc, ndcampo12 inc_sln, lpad(pk_rh_autoliq_2388.to_base(ndcampo10, 2), 12, '0') novedad,
         trunc(dfecharegistro/100) dfecharegistro
---valores liquidados        
--select sum(ndcampo5) aporte_sal, sum(ndcampo6) total_sal, sum(ndcampo8) aporte_pen, sum(ndcampo9) total_pen    
create table rh_hn_hoy_202602 as
select *     
  from rh_historico_nomina_hoy
	where nhash = 1415990624 -- info_planilla_fun
	and dfechaefectiva between 20260201 and 20260228 --var_inimes and var_finmes
	and trunc(dfecharegistro/100) = 202603 --var_fpago -- la fecha de pago debe corresponder a la fecha del proceso (planillas de ajustes)
    and brechazado = 0
    ;


--APORTES EMPLEADOR
select --p.numero_identificacion, sconcepto, valor, valor_saldo
        -- sum(valor)
        sconcepto, sum(valor)
from rh_t_lm_valores v --,  rh_personas p
where v.periodo = '28/FEB/2026'  --to_date('28/02/2026','dd/mm/yyyy') 
and v.ntipo_nomina=0
and v.stipofuncionario='PLANTA'
and v.sconcepto in ('PENSIONES','PENSIONES-PUB','SALUD','CFAVIDI','CAJA','ARP','ICBF','SENA')
--and v.nfuncionario = p.interno_persona*/
group by sconcepto
order by 2; ---1,2;

--an.nombre, sum(hn.ndcampo0) hn.*  

select an.nombre, sum(hn.ndcampo1) 
from rh_historico_nomina hn, rh_tipos_acto_nove an
where hn.brechazado=0
and hn.besdefinitivo=1
and hn.dinicioperiodo = 20260201
and hn.dfinalperiodo = 20260228
and hn.sproceso = 'NEWNOVELTIES'
and hn.nhash = an.codigo_hash
--and an.nombre in ('APORTEAFC','APORTEAFP','APORTES','APORTEAFC')
group by an.nombre
;

select *
from rh_tipos_acto_nove an
where nombre in ('APORTEAFC','APORTEAFP','APORTES','APORTEAFC')
;

select p.numero_identificacion, c.nombre_corto, hn.*  --c.nombre_corto, sum(hn.ndcampo0)
from rh_historico_nomina hn, rh_concepto c , rh_personas p
where hn.brechazado=0
and hn.besdefinitivo=1
and hn.dinicioperiodo = 20260201
and hn.dfinalperiodo = 20260228
and hn.sproceso = 'NOMINA_DE_EMPLEADOS_PLANTA'
and hn.nhash=c.codigo_hash
and c.nombre_corto in ('APORTESALUD','APORTEPENSION','CSENA')
and hn.nfuncionario=p.interno_persona
order by numero_identificacion asc;


group by c.nombre_corto;

select *
from rh_concepto c 
where c.nombre_corto in ('APORTESALUD','APORTEPENSION','CSENA')
;

 CURSOR c_bruto_ra   IS
	SELECT b.sconcepto , b.codigo_presupuesto, SUM(a.valor)
    --select  a.nfuncionario, a.sconcepto, a.valor, a.variable_valor, b.cc, b.codigo_presupuesto
    FROM   rh_t_lm_valores a, rh_lm_cuenta b
    WHERE  b.stipo_funcionario = a.stipofuncionario
    AND    b.sconcepto         = a.sconcepto
    AND    a.periodo           = '28/FEB/2026' -- una_fecha_final
    AND    a.ntipo_nomina      = '0'  --un_tipo_nomina
    AND    a.nro_ra            = '3'  --un_nro_ra
    AND    b.scompania         = 206  --una_compania
    AND    b.tipo_ra           = 1    --un_tipo_ra
    AND    b.grupo_ra          = '5'  --un_grupo_ra
    AND    b.ncierre           = 1
    AND    b.codigo_presupuesto IS NOT NULL
    -- RQ2523-2005   05/12/2005
    AND   b.dfecha_inicio_vig <= '28/FEB/2026' --una_fecha_final
    AND  (b.dfecha_final_vig  >= '28/FEB/2026' /*una_fecha_final*/ OR b.dfecha_final_vig IS NULL)
    AND     a.nfuncionario= 509
     -- */
    -- Fin RQ2523
    GROUP BY b.sconcepto, b.codigo_presupuesto
    order by 2
    ;

    select * from rh_lm_cuenta
    where scompania=206
    and stipo_funcionario='PLANTA'
    and sysdate between dfecha_inicio_vig and dfecha_final_vig
    and scuenta IN ('NDD-APORTEREGIMENSOLIDARIDAD','NDD-APORTESALUD')
    order by sconcepto
    ;

	SELECT sconcepto, valor
    FROM   rh_t_lm_valores a
    WHERE a.periodo           = '28/FEB/2026' -- una_fecha_final
    AND    a.ntipo_nomina      = '0'  --un_tipo_nomina
    AND    a.nro_ra            = '4'  --un_nro_ra
    order by valor asc
    and valor <= 11900
;
    and a.nfuncionario=509

    -- Fin RQ2523
    GROUP BY b.sconcepto, b.codigo_presupuesto
    order by 2
    ;    

    select *
    from rh_personas
    where numero_identificacion = 24182848
    ;

select  sum(pension_empleador) pension_empleador, sum(pension_emple_ado) pension_emple_ado  , 
        sum(pension_empleador)+ sum(pension_emple_ado) suma_pension, sum(total_aporte_pension) total_pension ,
        sum(salud_empleador) salud_empleador, sum(salud_empleado) salud_empleado, 
        sum(salud_empleador) + sum(salud_empleado) sumsalud,
        sum(total_aportesalud) total_salud
from  rh_tmp_resumen_planilla       
;

--Problema 1. Los parafiscales están diferenes a la RA firmada, deben actualizarse.
--Solucion. Se tomará los datos de la  planilla generada y enviada para actualizar.
--P1.1. Se hace tabla de rh_t_lm_valores de la RA Nro. 4 aportes de febrero 2026. rh_t_lm_valora_RA_202602
/*P1.2  Se compara con la tabla RH_TMP_RESUMEN_PLANILLA de aportes 202602 generada que se cargo a la BD denominada
   Compara con Compensar, Riesgos Laborales, ICBF, Sena*/
--P1.3. Para generar la RA de OPGET se suman a solo dos funcionarios las diferencias para que se igual al CDP.
--P1.4. Se modifica nuevamente la RA para que coincidan con los valores de la planial.
--P.1.1   
create table rh_t_lm_valores_RA4_202602 as
select *
from rh_t_lm_valores
where
    extract(year from periodo) = 2026
    and periodo = '28/feb/2026' 
    and stipofuncionario = 'PLANTA' 
    and nro_ra = 4;

--P1.2
select 
from rh_t_lm_valores
where extract(year from periodo) = 2026
    and periodo = '28/feb/2026' 
    and stipofuncionario = 'PLANTA' 
    and nro_ra = 4
    and sconcepto='SENA';

create view vw_rh_t_lm_valores as
select p.numero_identificacion, v.*
from rh_t_lm_valores v, rh_personas p
where
    v.nfuncionario = p.interno_persona
    /*extract(year from periodo) = 2026
    and periodo = '28/feb/2026' 
    and stipofuncionario = 'PLANTA' 
    and nro_ra = 4*/

--P1.3 Para generar la RA de OPGT. Se concluye con el archivo 2026000956_analisis.exe en cuadr H14 A J23 se identifican los valores modificados.
select *
from vw_rh_t_lm_valores   
where periodo = '28/feb/2026' 
    and stipofuncionario = 'PLANTA' 
    and nro_ra = 4
    and sconcepto in ('PENSIONES','PENSIONES-PUB','SALUD','CFAVIDI','CAJA','ARP','ICBF','SENA')
    and nfuncionario IN (510) --20
    ;

--v.sconcepto in ('PENSIONES','PENSIONES-PUB','SALUD','CFAVIDI','CAJA','ARP','ICBF','SENA')

/*
MELBA CC 35325745 INT 20.
SANITAS +926709, 
COLPENSIONES +1518573
COMPENSAR +23900, 
POSITIVA 3300, 
ICB +17900, 
SENA +11900

ANGIE CC 1030612429 INT 510
COMPENSAR SALUD, PORVENIR PENSIONES SA  +209522
*/




--P1.4
select numero_identificacion,
       decode(sconcepto,'PENSIONES',valor,'PENSIONES-PUB',valor,0) PENSIONES,
       decode(sconcepto,'SALUD',valor,0) SALUD,
       decode(sconcepto,'CAJA',valor,0) COMPENSAR,
       decode(sconcepto,'ICBF',valor,0) ICBF,
       decode(sconcepto,'ARP',valor,0) ARP,
       decode(sconcepto,'SENA',valor,0) SENA
from vw_rh_t_lm_valores   
where periodo = '28/feb/2026' 
    and stipofuncionario = 'PLANTA' 
    and nro_ra = 4
    and sconcepto in ('PENSIONES','PENSIONES-PUB','SALUD','CFAVIDI','CAJA','ARP','ICBF','SENA');

select p.numero_identifcacion, p.pension_empleador - n.pensiones difp, p.salud_empleador-n.salud difs
from rh_tmp_resumen_planilla p,
    (select numero_identificacion, count(1) lineas,
       sum(decode(sconcepto,'PENSIONES',valor,'PENSIONES-PUB',valor,0)) PENSIONES,
       sum(decode(sconcepto,'SALUD',valor,0)) SALUD
        from vw_rh_t_lm_valores   
        where periodo = '28/feb/2026' 
            and stipofuncionario = 'PLANTA' 
            and nro_ra = 4
            and sconcepto in ('PENSIONES','PENSIONES-PUB','SALUD')
           -- and numero_identificacion=1010211471
        group by numero_identificacion
    ) n
where p.numero_identifcacion = n.numero_identificacion 
and (p.pension_empleador <> n.pensiones  or p.salud_empleador <> n.salud 
    )
;

select p.numero_identifcacion, p.pension_empleador - n.pensiones difp, p.salud_empleador-n.salud difs
from rh_tmp_resumen_planilla p,
    (select numero_identificacion, 
       sum(decode(sconcepto,'PENSIONES',valor)) PENSIONES,
       sum(decode(sconcepto,'PENSIONES-PUB',valor,)) PENSIONES_PUB,
       sum(decode(sconcepto,'SALUD',valor,0)) SALUD
        from vw_rh_t_lm_valores   
        where periodo = '28/feb/2026' 
            and stipofuncionario = 'PLANTA' 
            and nro_ra = 4
            and sconcepto in ('PENSIONES','PENSIONES-PUB','SALUD')
           -- and numero_identificacion=1010211471
        group by numero_identificacion
    ) n
where p.numero_identifcacion = n.numero_identificacion 
and (p.pension_empleador <> n.pensiones  or p.salud_empleador <> n.salud 
    );

---Totales por fondo de pensiones
select --f.codigo_fondo_pensiones, tp.numero_identifcacion, tp.pension_empleador, tp.pension_emple_ado
      f.codigo_fondo_pensiones, t.nit, t.nombre,  sum(tp.pension_empleador), sum(tp.pension_emple_ado)
from rh_tmp_resumen_planilla tp, rh_personas p, rh_funcionario f, 
    (select t.entidad_codigo, tc.id, tc.codigo_identificacion nit, ib.ib_primer_nombre nombre
    from rh_terceros t
    join trc.trc_terceros tc on t.id_tercero = tc.id
    join trc.trc_informacion_basica ib on tc.id = ib.id
    where t.entidad_tipo='FONDO_PENSIONES'
    --and ib.ib_primer_nombre like '%OLD MUTUAL%'
    and nvl(ib.ib_fecha_final,sysdate ) >= sysdate
    ) t
where tp.numero_identifcacion = p.numero_identificacion
and p.interno_persona = f.personas_interno
and f.codigo_fondo_pensiones = t.entidad_codigo
group by f.codigo_fondo_pensiones,  t.nit, t.nombre
--union

---Totales por fondo de salud
select --t.entidad_codigo, f.codigo_eps, tp.numero_identifcacion, tp.salud_empleador, tp.salud_empleado
    f.codigo_eps, t.nit, t.nombre, sum(tp.salud_empleador) total_empleador, sum(tp.salud_empleado) total_empleado
from rh_tmp_resumen_planilla tp, rh_personas p, rh_funcionario f, 
    (select t.entidad_codigo, tc.id, tc.codigo_identificacion nit, ib.ib_primer_nombre nombre
    from rh_terceros t
    join trc.trc_terceros tc on t.id_tercero = tc.id
    join trc.trc_informacion_basica ib on tc.id = ib.id
    where t.entidad_tipo='EPS'
    --and ib.ib_primer_nombre like '%SANITAS%'
    and nvl(ib.ib_fecha_final,sysdate ) >= sysdate
    ) t
where tp.numero_identifcacion = p.numero_identificacion
and p.interno_persona = f.personas_interno
--and f.personas_interno=20
and f.codigo_eps = t.entidad_codigo
group by f.codigo_eps, t.nit, t.nombre
order by 1;

select t.entidad_tipo, t.codigo, tc.id, tc.codigo_identificacion nit, ib.ib_primer_nombre
from rh_terceros t
join trc.trc_terceros tc on t.id_tercero = tc.id
join trc.trc_informacion_basica ib on tc.id = ib.id
where t.entidad_tipo='EPS'
and t.codigo=5
; --'EPS';

select *
from rh_funcionario
where personas_interno = 20 --codigo_eps=5

select *
from rh_terceros
where codigo=16;




select sum(pension_empleador), sum(pension_emple_ado), sum(salud_empleador), sum(salud_empleado)
from rh_tmp_resumen_planilla