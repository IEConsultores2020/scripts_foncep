--Validaciones del paquetes
select 
  :MES MES,
  ogt_pk_predis.Ogt_Fn_aportesemp_Mes(
    una_vigencia         => 2026,
    una_entidad          => 206,
    una_unidad_ejecutora => '01',
    un_mes               => :MES,
    un_rubro_interno     => 1804) APO_EMP_MES,
  ogt_pk_predis.Ogt_Fn_aportespagemp_Mes(
    una_vigencia         => 2026,
    una_entidad          => 206,
    una_unidad_ejecutora => '01',
    un_mes               => :MES,
    un_rubro_interno     => 1804) APOPAG_EMP_MES,
  ogt_pk_predis.Ogt_Fn_Valor_Mes(
    una_vigencia         => 2026,
    una_entidad          => 206,
    una_unidad_ejecutora => '01',
    un_mes               => :MES,
    un_rubro_interno     => 1804) PAG_MES,
  ogt_pk_predis.OGT_FN_VALOR_ACUM(
    una_vigencia          => 2026,
    una_entidad          => 206,
    una_unidad_ejecutora => '01',
    un_mes               => :MES,
    un_rubro_interno     => 1804) PAG_ACUM
from dual   
;


select *
from pr_v_rubros
where  vigencia=2026 and descripcion 
    --like '%eldo%sico%'  ---Sueldo básico 1804
    like '%Apor%alud%'    --Aportes a la seguridad social en salud pública  1833
                          --Aportes a la seguridad social en salud privada  1834
;


/*Esta es la consulta que debe traer los aportes del empleado pagados del mes
  Como en OGT los aportes del empleados se pagan en la nómina MM, 
  Teniendo los pagos de aportes del empleador que se hacen en el MM+n donde generalmente n es 1, pero no necesariamente.
  Se debe buscar la nómina que corresponde al mismo MM del mes de aportes y extraer los valores del pagados por el empleado
  */
cursor cur_val_aportes_empleado_mes is
      select distinct extract(month from rra.dfecha_inicial_periodo) mes_aportes
      select *
      from rh_lm_ra rra,
        (
          /* CRA
          Aquí se cargan las RA del mes que coinciden con dfecha_inicial_periodo y dfecha_final_periodo

          */

        ) op
      where rra.scompania=206
      and rra.vigencia=op.vigencia
      and rra.scompania= op.codigo_compania
      and op.codigo_unidad_ejecutora = '01'
      and rra.vigencia=op.vigencia
      --and rra.nro_ra=2
      --Falta aclarar por que este filtro..
      and instr(op.objeto,'[RA = '||rra.nro_ra||']',1) > 1 -- --ej:  '[RA = 2]'
      and rra.tipo_ra=2
      and rra.ntipo_nomina=0   ---no se tienen en cuenta nominas adicionales, es decir con valor 1
      ;


--CRA
select cc.*
from ogt_relacion_autorizacion ra
join ogt_centro_costos cc on
ra.CONSECUTIVO = cc.CONSECUTIVO
AND ra.ENTIDAD = cc.ENTIDAD
AND ra.TIPO_DOCUMENTO = cc.TIPO_DOCUMENTO
AND ra.UNIDAD_EJECUTORA = cc.UNIDAD_EJECUTORA 
AND ra.VIGENCIA = cc.VIGENCIA
AND ra.TIPO_RA = cc.TIPO_RA
AND ra.MES = cc.MES
AND ra.FECHA_DESDE = cc.FECHA_DESDE
where  ra.vigencia = :vigencia
--and ra.tipo_ra = un_tipo_ra
--and ra.mes = un_mes
--and ra.estado = ''
and ra.tipo_documento='RA'
and ra.unidad_ejecutora = :una_unidad_ejecutora
and ra.entidad = :una_entidad
and ra.ind_aprobado = 1

