SELECT RUBRO_INTERNO
               ,UNIDAD_EJECUTORA_PRESUPUESTO
               ,DISPONIBILIDAD
               ,VIGENCIA_PRESUPUESTO
               ,TIPO_DOCUMENTO
               ,UNIDAD_EJECUTORA
               ,ENTIDAD
               ,VIGENCIA
               ,CONSECUTIVO
               ,ENTIDAD_PRESUPUESTO
               ,REGISTRO
               ,VALOR_REGISTRO
               ,ID_LIMAY_GIRO_PRESUPUESTAL
               ,FECHA_GIRO_PRESUPUESTAL
               ,USUARIO_GIRO_PRESUPUESTAL
               ,ID_LIMAY_PAGO
               ,FECHA_PAGO
               ,USUARIO_PAGO
               ,ID_LIMAY_ANULACION_GIRO
               ,FECHA_ANULACION_GIRO
               ,USUARIO_ANULACION_GIRO
               ,ID_LIMAY_ANULACION_PAGO
               ,FECHA_ANULACION_PAGO
               ,USUARIO_ANULACION_PAGO
           FROM OGT_REGISTRO_PRESUPUESTAL
          WHERE REGISTRO >= 0 --MI_VALOR_CERO
            --AND TIPO_DOCUMENTO = 'RA' --UN_TIPO_DOCUMENTO
            AND DISPONIBILIDAD >= 0 --MI_VALOR_CERO
            AND CONSECUTIVO = 12 --UN_CONSECUTIVO  12 529956361
            AND ENTIDAD = 206 --UNA_ENTIDAD
            AND UNIDAD_EJECUTORA = '01' --UNA_UNIDAD_EJECUTORA
            AND VIGENCIA = 2025 --UNA_VIGENCIA;
            ;

select * --VALOR_REGISTRO 
   /*-
    (select SUM (APORTE_EMPLEADO)
      from ogt_anexo_nomina
      where vigencia = 2025
        and consecutivo = 12
        and CODIGO_CENTRO_COSTOS IN ( 5, 1285, 1267)) resta*/
from --update 
  OGT_REGISTRO_PRESUPUESTAL
/* SET VALOR_REGISTRO =  --529956361
                        VALOR_REGISTRO -  (select SUM (APORTE_EMPLEADO)
                                          from ogt_anexo_nomina
                                          where vigencia = 2025
                                          and consecutivo = 12
                                          AND CODIGO_CENTRO_COSTOS IN ( 5, 1285, 1267)) --*/
where REGISTRO >= 0                     --MI_VALOR_CERO
            AND TIPO_DOCUMENTO = 'RA'   --UN_TIPO_DOCUMENTO
            AND DISPONIBILIDAD >= 0     --MI_VALOR_CERO
            AND CONSECUTIVO = 14        --UN_CONSECUTIVO  12 529956361
            AND ENTIDAD = 206           --UNA_ENTIDAD
            AND UNIDAD_EJECUTORA = '01' --UNA_UNIDAD_EJECUTORA
            AND VIGENCIA = 2025
            AND registro = 326
            AND rubro_interno = 1547
;
            --529956361
            --ogt.OGT_TRG_ACTUALIZA_RP

            rollback
            commit

ogt_lb_pagos.PK_EGR_ORDEN_PAGO.FN_OGT_BD_CREAR_PRESUPUESTO
  CALL INSERT INTO OGT_REGISTRO_PRESUPUESTAL            ;


  --MAYO 2025
  select sum(aporte_empleado)
  from ogt_anexo_nomina
 where vigencia = 2025
   and consecutivo = 12
   and codigo_centro_costos in ( 5,
                                 1285,
                                 1267 );


-------------------2025 JULIO                                 

 --JULIO 2025
  select sum(aporte_empleado)             -- 68246693 CONFIRMAR
  from ogt_anexo_nomina
 where vigencia = 2025
   and consecutivo = 16                  -- NRO RA JULIO
   and codigo_centro_costos in ( 5,
                                 1285,
                                 1267 );  
--VERIF
SELECT *
FROM OGT_REGISTRO_PRESUPUESTAL
WHERE REGISTRO >= 0 --MI_VALOR_CERO
            AND TIPO_DOCUMENTO = 'RA'   --UN_TIPO_DOCUMENTO
            AND DISPONIBILIDAD >= 0     --MI_VALOR_CERO
            AND CONSECUTIVO = 16        --** RA DE OPGET DEL MES
            AND ENTIDAD = 206           --UNA_ENTIDAD
            AND UNIDAD_EJECUTORA = '01' --UNA_UNIDAD_EJECUTORA
            AND VIGENCIA = 2025
            AND registro = 377          --CONFIRMAR
            AND rubro_interno = 1547    --RUBRO VIGENCIA
            ;

--ORA-20805: No puede actualizar el valor del registro para RAs aprobadas. 
--Se debe deshabilitar trigger OGT_TRG_ACTUALIZA_RP       
--  BEFORE INSERT OR UPDATE OR DELETE ON OGT_REGISTRO_PRESUPUESTAL
/*    IF :NEW.TIPO_DOCUMENTO = 'RA' THEN
      IF SUBSTR(MI_ESTADO_RA, 4, 1) = '1' AND
         :OLD.VALOR_REGISTRO <> :NEW.VALOR_REGISTRO THEN
        RAISE_APPLICATION_ERROR('-20805',
                                'No puede actualizar el valor del registro para RAs aprobadas.    

    ');    
*/   


--JULIO 2025 ACTUALIZAR
SELECT SUM(VALOR_REGISTRO) FROM                                 
--UPDATE 
  OGT_REGISTRO_PRESUPUESTAL
/* 
  SET VALOR_REGISTRO = 487350435  /*VALOR_REGISTRO + (select sum(aporte_empleado)  --806185563
                                        from ogt_anexo_nomina
                                      where vigencia = 2025
                                        and consecutivo = 16  --NRO RA JUNIO
                                        and codigo_centro_costos in ( 5,
                                                                      1285,
                                                                      1267 )) --*/
where REGISTRO >= 0                         --MI_VALOR_CERO
  AND TIPO_DOCUMENTO =    'RA'    --UN_TIPO_DOCUMENTO
  AND DISPONIBILIDAD >=   0       --MI_VALOR_CERO
  AND CONSECUTIVO   =     16      --UN_CONSECUTIVO NUMERO RA DE JULIO
  AND ENTIDAD = 206               --UNA_ENTIDAD
  AND UNIDAD_EJECUTORA = '01'     --UNA_UNIDAD_EJECUTORA
  AND VIGENCIA = 2025             --UNA VIGENCIA
  AND registro = 377              --CONFIRMADO CONSULTA ANTERIOR
  AND rubro_interno = 1547        --RUBRO VIGENCIA 2025
;


ALTER TRIGGER OGT.OGT_TRG_ACTUALIZA_RP DISABLE;
ALTER TRIGGER OGT.OGT_TRG_ACTUALIZA_RP ENABLE;

commit;

rollback


VERIFICAR CUANTO CAMBIA OGT_REGISTRO_PRESUPUESTAL
VERIF EN FORMA OGT_FIRMA_RA
BOTON APROBAR
ANTES DE LA LINEA
  -- ACTUALIZO EL ESTADO EN LA RA
  INCLUIR FUNCION DE ACTUALIZAR ANEXOS DE LA NOMINA
  

 SELECT PR_REGISTRO_PRESUPUESTAL.numero_disponibilidad,PR_REGISTRO_PRESUPUESTAL.numero_registro,
      PR_REGISTRO_DISPONIBILIDAD.rubro_interno,PR_REGISTRO_DISPONIBILIDAD.valor valor_inicial,
      Pk_Pr_Compromisos.fn_pre_traer_anulacion(PR_REGISTRO_PRESUPUESTAL.vigencia ,
                                      PR_REGISTRO_PRESUPUESTAL.codigo_compania,
                                      PR_REGISTRO_PRESUPUESTAL.codigo_unidad_ejecutora ,
                                      PR_REGISTRO_PRESUPUESTAL.numero_registro ,
                                      PR_REGISTRO_DISPONIBILIDAD.rubro_interno,
                                      sysdate),
                                      PR_REGISTRO_PRESUPUESTAL.tipo_compromiso,
                                      PR_REGISTRO_PRESUPUESTAL.numero_compromiso*/
      FROM PR_REGISTRO_PRESUPUESTAL,PR_REGISTRO_DISPONIBILIDAD
      WHERE PR_REGISTRO_PRESUPUESTAL.vigencia = PR_REGISTRO_DISPONIBILIDAD.vigencia AND
      PR_REGISTRO_PRESUPUESTAL.codigo_compania = PR_REGISTRO_DISPONIBILIDAD.codigo_compania AND
      PR_REGISTRO_PRESUPUESTAL.codigo_unidad_ejecutora = PR_REGISTRO_DISPONIBILIDAD.codigo_unidad_ejecutora AND
      PR_REGISTRO_PRESUPUESTAL.numero_disponibilidad = PR_REGISTRO_DISPONIBILIDAD.numero_disponibilidad AND
      PR_REGISTRO_PRESUPUESTAL.numero_registro = PR_REGISTRO_DISPONIBILIDAD.numero_registro AND
      PR_REGISTRO_PRESUPUESTAL.vigencia = 2025 AND
      PR_REGISTRO_PRESUPUESTAL.codigo_compania = 206 AND
      PR_REGISTRO_PRESUPUESTAL.codigo_unidad_ejecutora = '01' AND
      --PR_REGISTRO_DISPONIBILIDAD.valor =66963035
      PR_REGISTRO_PRESUPUESTAL.tipo_compromiso = '01' AND
      PR_REGISTRO_PRESUPUESTAL.numero_compromiso = 14; 

select *
from OGT_REGISTRO_PRESUPUESTAL
where vigencia=2025
and entidad=206
and unidad_ejecutora ='01'
and disponibilidad=12
and registro=326
and tipo_documento ='RA'
and rubro_interno=1547
;

select *
from PR_REGISTRO_PRESUPUESTAL
where rubro=1547
and vigencia=2025
;


select * --sum(aporte_empleado), sum(aporte_patronal)  --806185563
  from ogt_anexo_patronal
  where vigencia = 2025
    and consecutivo = 15  --NRO RA JUNIO
    and entidad=206
    and unidad_ejecutora='01'

;

select *
from OGT_REGISTRO_PRESUPUESTAL
where vigencia_presupuesto=2025
and consecutivo = 15
;

select * --interno
from pr_rubro
where vigencia=2025
and descripcion = 'Sueldo básico'
and tipo_plan = 'PLAN_ADMONCENTRAL'
;

select *
from rh_t_lm_valores
select *
from rh_lm_ra_presupuesto
where compania=206
and vigencia=2025
and vigencia=2025



--Si es tipo ra nomina=1 resta x -1
--Si es tipo ra prestaciones=2 suma 1
--Otro tipo no afecta
select sum(aporte_empleado)*DECODE(TIPO_RA,1,-1,2,1,0)  --806185563
  from ogt_anexo_patronal
  where exists ( select 1
    from OGT_REGISTRO_PRESUPUESTAL
    where OGT_REGISTRO_PRESUPUESTAL.rubro_interno
    and OGT_REGISTRO_PRESUPUESTAL.UNIDAD_EJECUTORA=ogt_anexo_nomina.
    and OGT_REGISTRO_PRESUPUESTAL.TIPO_DOCUMENTO=ogt_anexo_nomina.TIPO_DOCUMENTO
    and ogt_registro_presupuestal.tipo_documento='RA'
    AND OGT_REGISTRO_PRESUPUESTAL.DISPONIBILIDAD
    AND OGT_REGISTRO_PRESUPUESTAL.VIGENCIA_PRESUPUESTO
    AND OGT_REGISTRO_PRESUPUESTAL.ENTIDAD
    AND OGT_REGISTRO_PRESUPUESTAL.VIGENCIA
    AND OGT_REGISTRO_PRESUPUESTAL.CONSECUTIVO = OGT_ANEXO_PATRONAL.CONSECUTIVO
    AND OGT_REGISTRO_PRESUPUESTAL.
    AND OGT_TIPO_RA = 
    
  );
  and vigencia >= 2025
  and consecutivo = 15  --NRO RA JUNIO
;

SELECT TIPO_RA, CONSECUTIVO, UNIDAD_EJECUTORA, FECHA_DESDE, SUM(APORTE_PATRONAL) , SUM(APORTE_EMPLEADO)
FROM OGT_ANEXO_PATRONAL
WHERE VIGENCIA=2025 --AND CONSECUTIVO IN (14,15)
AND ENTIDAD=206
GROUP BY TIPO_RA, CONSECUTIVO,UNIDAD_EJECUTORA, FECHA_DESDE
ORDER BY 1,2,3,4;

SELECT *  -- TIPO_RA, CONSECUTIVO, UNIDAD_EJECUTORA  --, SUM(APORTE_EMPLEADO)
FROM OGT_ANEXO_NOMINA
WHERE VIGENCIA=2025
and entidad=206
and consecutivo in (16)
and codigo_centro_costos in (5,1285,1267)
GROUP BY TIPO_RA, CONSECUTIVO, UNIDAD_EJECUTORA
;


/*Aplica para RAs de PERNO. 
  Retorna negativo aportes empleador si es RA Nomina 
  Retorna positivo aportes empleador si es RA Aportes
  0 para los demás casos */
mi_valor_sincroniza_cud := fn_valor_sincroniza_cud(
                                 una_vigencia number, 
                                 un_codigo_compania number,
                                 un_codigo_unidad varchar(2)
                                 un_tipo_ra,
                                 un_nro_ra,
                                 un_numero_registro,
                                 un_numero_disponibilidad);

function fn_valor_sincroniza_cud  una_vigencia          number,
                                 un_codigo_compania     number,
                                 un_codigo_unidad       varchar(2)
                                 un_tipo_ra             number,
                                 un_consecutivo number) return integer as
  mi_valor number;                                 
begin
  if tipo_ra = 1 then
    select sum(aporte_empleado)           
    into mi_valor
    from ogt_anexo_nomina
    where  entidad = un_codigo_compania
    and unidad_ejecutora = un_codigo_unidad
    and vigencia = una_vigencia
    and consecutivo = un_consecutivo        
    and tipo_ra = 1        
    and tipo_documento = 'RA'
    and codigo_centro_costos in (5,1285,1267);  
   elsif tipo_ra = 2 then
    select SUM(APORTE_EMPLEADO)
    into mi_valor 
    from OGT_ANEXO_PATRONAL
    where entidad = un_codigo_compania
    and unidad_ejecutora = un_codigo_unidad
    and vigencia = una_vigencia
    and consecutivo = un_consecutivo  
    and tipo_ra = 2
    and tipo_documento = 'RA'
    /*and VIGENCIA=2025 --una_vigencia
    AND ENTIDAD=206 --un_codigo_compania
    AND CONSECUTIVO=17 --UN_CONSECUTIVO*/;
  else 
    mi_valor := 0;
  end IF;
  return mi_valor;
exception 
  when others THEN
    return 0;
end;                                                  


select n.nro_ra_opget
  from rh_lm_ra n,
       rh_lm_ra s
 where s.nro_ra_opget = 15
   and s.vigencia = n.vigencia
   and s.grupo_ra = n.grupo_ra
   and s.vigencia_presupuesto = n.vigencia_presupuesto
   and s.unidad_ejecutora = n.unidad_ejecutora
   and s.ntipo_nomina = n.ntipo_nomina
   and s.dfecha_inicial_periodo = n.dfecha_inicial_periodo
   and s.dfecha_final_periodo = n.dfecha_final_periodo
   and n.tipo_ra = 1 --NOMINA
   and n.vigencia = 2025
            