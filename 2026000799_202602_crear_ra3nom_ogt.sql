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