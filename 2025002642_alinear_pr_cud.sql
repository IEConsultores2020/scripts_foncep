 select sum(aporte_empleado)        
  from ogt_anexo_nomina
 where vigencia = 2025
   and consecutivo = :nro_ra            
   and codigo_centro_costos in ( 5,1285, 1267 );  

--Inicio actualizar
--1de4 Disable 'OGT.OGT_TRG_ACTUALIZA_RP'
ALTER TRIGGER OGT.OGT_TRG_ACTUALIZA_RP DISABLE;

--2de4 update
update OGT_REGISTRO_PRESUPUESTAL
    SET VALOR_REGISTRO =  VALOR_REGISTRO +  (select SUM (APORTE_EMPLEADO)
                                                from ogt_anexo_nomina
                                                where vigencia = 2025
                                                and consecutivo = :nro_ra
                                                AND CODIGO_CENTRO_COSTOS IN ( 5, 1285, 1267))
where REGISTRO >= 0                      --MI_VALOR_CERO
            AND TIPO_DOCUMENTO = 'RA'   --UN_TIPO_DOCUMENTO
            AND DISPONIBILIDAD >= 0     --MI_VALOR_CERO
            AND CONSECUTIVO = :nro_ra    --UN_CONSECUTIVO  12 529956361
            AND ENTIDAD = 206           --UNA_ENTIDAD
            AND UNIDAD_EJECUTORA = '01' --UNA_UNIDAD_EJECUTORA
            AND VIGENCIA = 2025
            AND registro = :nro_rp
            AND rubro_interno = 1547
;

--3de4 guardar
COMMIT;

--4de4 Enable 'OGT.OGT_TRG_ACTUALIZA_RP'
ALTER TRIGGER OGT.OGT_TRG_ACTUALIZA_RP ENABLE;


--Fin Actualizar

--Verificar
select valor_registro
from ogt_registro_presupuestal
where REGISTRO >= 0                     --MI_VALOR_CERO
            AND TIPO_DOCUMENTO = 'RA'   --UN_TIPO_DOCUMENTO
            AND DISPONIBILIDAD >= 0     --MI_VALOR_CERO
            AND CONSECUTIVO = :nro_ra   --UN_CONSECUTIVO  12 529956361
            AND ENTIDAD = 206           --UNA_ENTIDAD
            AND UNIDAD_EJECUTORA = '01' --UNA_UNIDAD_EJECUTORA
            AND VIGENCIA = 2025
            AND registro = :nro_rp
            AND rubro_interno = 1547
;
