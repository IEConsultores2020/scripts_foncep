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
/*
 SELECT NVL(SUM(VALOR_REGISTRO), 0)
      INTO mi_valor_ra*/
    SELECT *
      FROM OGT_REGISTRO_PRESUPUESTAL A, OGT_RELACION_AUTORIZACION B
     WHERE A.VIGENCIA = B.VIGENCIA
       AND A.ENTIDAD = B.ENTIDAD
       AND A.UNIDAD_EJECUTORA = B.UNIDAD_EJECUTORA
       AND A.TIPO_DOCUMENTO = B.TIPO_DOCUMENTO
       AND A.CONSECUTIVO = B.CONSECUTIVO
       AND A.RUBRO_INTERNO in
            (select interno_rubro
              from pr_v_rubros
              where vigencia= :una_vigencia
              and descripcion in ('Aportes a la seguridad social en pensiones públicas',
              'Aportes a la seguridad social en pensiones privadas',
              'Aportes a la seguridad social en salud pública',
              'Aportes a la seguridad social en salud privada')
            )
       AND B.VIGENCIA = TO_CHAR(:una_vigencia)
       AND B.ENTIDAD = :una_entidad
       AND B.UNIDAD_EJECUTORA = :una_unidad_ejecutora
       AND B.TIPO_DOCUMENTO = :mi_tipo_documento_ra
       AND B.IND_APROBADO = :mi_valor_uno
       AND SUBSTR(B.ESTADO, 4, 1) = :mi_estado_uno
       AND TO_NUMBER(TO_CHAR(B.fecha_aprobacion, 'MM')) = :un_mes
       AND TO_CHAR(B.FECHA_APROBACION, 'YYYY') = TO_CHAR(:una_vigencia)
       AND NVL(A.VALOR_REGISTRO, 0) > :mi_valor_cero;
