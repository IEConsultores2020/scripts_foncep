--Consulta el encabezado de la disponibilidad
select *
from pr_disponibilidades
where vigencia      =   2026
and codigo_compania =   206
and codigo_unidad_ejecutora ='01'
and numero_disponibilidad   =39
;

--Consulto los rubros de la disponibilidad para confirmar el total de la misma por pantalla
select sum(valor)
from pr_disponibilidad_rubro
where vigencia      =   2026
and codigo_compania =   206
and codigo_unidad_ejecutora ='01'
and numero_disponibilidad   =39
;

--Consulto los rubros de la disponibilidad con la descripción
select r.interno, r.descripcion
from pr.pr_disponibilidad_rubro pr
join pr_rubro r on r.vigencia = pr.vigencia 
    and pr.rubro_interno      = r.INTERNO
where pr.vigencia               =   2026
and pr.codigo_compania          =   206
and pr.codigo_unidad_ejecutora  =   '01'
and pr.numero_disponibilidad    =   39
;

--Consulta los rubros en nómina, donde se almacena el rubro presupuestal
select * --distinct(lc.codigo_presupuesto)
from rh_lm_cuenta lc
where lc.scompania=206
and lc.stipo_funcionario='PLANTA'
and sysdate between lc.dfecha_inicio_vig and lc.dfecha_final_vig
and codigo_presupuesto is not null
;

--Verifico las
select distinct /*sconcepto,*/ r.interno, r.descripcion
    --r.interno, r.descripcion, lc.*
from rh_lm_cuenta lc
join pr_rubro r on r.vigencia = 2026 and lc.codigo_presupuesto= r.interno
where lc.scompania=206
and lc.stipo_funcionario='PLANTA'
and sysdate between lc.dfecha_inicio_vig and lc.dfecha_final_vig
--and r.descripcion = 'Indemnización por vacaciones'
order by r.interno
;

select max(vigencia), r1.interno, r1.descripcion 
from pr_rubro r1
where  r1.interno in (
select distinct(lc.codigo_presupuesto)
from rh_lm_cuenta lc
where lc.scompania=206
and lc.stipo_funcionario='PLANTA'
and sysdate between lc.dfecha_inicio_vig and lc.dfecha_final_vig
and codigo_presupuesto is not null
minus
select distinct(lc.codigo_presupuesto) --r.interno, r.descripcion, lc.*
from rh_lm_cuenta lc
join pr_rubro r on r.vigencia = 2026 and lc.codigo_presupuesto= r.interno
where lc.scompania=206
and lc.stipo_funcionario='PLANTA'
and sysdate between lc.dfecha_inicio_vig and lc.dfecha_final_vig
)
group by r1.interno, r1.descripcion 
;

---Reviso compromisos
select *
from pr_compromisos 
where vigencia=2026
and codigo_compania=206
and codigo_unidad_ejecutora='01'
and numero_registro=205;

--detalle compromisos
select rd.rubro_interno, r.descripcion
from pr_registro_disponibilidad rd
join pr_rubro r on r.vigencia = 2026 and rd.rubro_interno= r.interno
where rd.vigencia=2026
and rd.codigo_compania=206
and rd.codigo_unidad_ejecutora='01'
and rd.numero_registro=206
and rd.numero_disponibilidad=199 ;
--rubro 1396  indemnizacion vacaciones
--1322 viejo

select *
from pr_rubro
where interno in  (1396,1322)
and vigencia=2026
;

select interno,descripcion
from pr_rubro
where vigencia=2026
and descripcion like '%Indemnización por vacaciones%'
--1396



	SELECT DISPONIBILIDAD, RUBRO_INTERNO, MES_PAC
		      ,ANO_PAC 
	/*	INTO  :OGT_REGISTRO_PRESUPUESTAL.MES_PAC
		     ,:OGT_REGISTRO_PRESUPUESTAL.ANO_PAC*/
		FROM   OGT_IMPUTACION
		WHERE  VIGENCIA         = 2026
		AND    ENTIDAD          = 206   --:OGT_DOCUMENTO_PAGO.ENTIDAD          
		AND    UNIDAD_EJECUTORA = '01'  --:OGT_DOCUMENTO_PAGO.UNIDAD               
		AND    CONSECUTIVO      = 3     --:OGT_DOCUMENTO_PAGO.CONSECUTIVO                    
		AND    TIPO_DOCUMENTO   = 'RA'  --:OGT_DOCUMENTO_PAGO.TIPO_DOCUMENTO              
		AND    DISPONIBILIDAD   = 199    --:OGT_REGISTRO_PRESUPUESTAL.DISPONIBILIDAD
		AND    RUBRO_INTERNO    = 1396  --:OGT_REGISTRO_PRESUPUESTAL.RUBRO_INTERNO   
		;


select  * --a.nfuncionario, a.sconcepto, a.valor, a.variable_valor, b.cc, b.codigo_presupuesto
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
   -- AND    b.codigo_presupuesto IS NOT NULL
    -- RQ2523-2005   05/12/2005
    AND   b.dfecha_inicio_vig <= '28/FEB/2026' --una_fecha_final
    AND  (b.dfecha_final_vig  >= '28/FEB/2026' /*una_fecha_final*/ OR b.dfecha_final_vig IS NULL)
    AND     a.nfuncionario= 20 --509
    order by 2		;

select  a.sconcepto, sum(valor)
    FROM   rh_t_lm_valores a
    WHERE     a.periodo           = '28/FEB/2026' -- una_fecha_final
    AND    a.ntipo_nomina      = '0'  --un_tipo_nomina
    AND    a.nro_ra            = '4'  --un_nro_ra
	--AND sconcepto in ('APORTESALUD') --,'APORTEFONDOGARANTIA')
	--AND     a.nfuncionario= 20 --509
	group by a.sconcepto
    order by 2		;

	select r.descripcion, r.interno, p.compania, p.vigencia, p.unidad_ejecutora, p.valor_rp, p.valor_bruto
	from rh_lm_ra_presupuesto p, pr_rubro r
	where p.vigencia=2025
	and p.unidad_ejecutora=01
	and p.nro_ra=24
	and r.interno = p.interno_rubro
	and p.vigencia=r.vigencia
	order by descripcion
	;

	select *
	from rh_lm_cuenta
	where stipo_funcionario='PLANTA'
	and sconcepto like '%SALUD%'

