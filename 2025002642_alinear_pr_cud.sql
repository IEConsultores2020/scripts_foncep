CREATE OR REPLACE PACKAGE PK_OGT_SESSION IS
/*Control cambios
  GLP2025002642 20260408 ftorresv Alineación PREDIS vs. PPTO.SHD
*/
    -- Esta variable controlará si los triggers deben ejecutarse o no
    G_IGNORE_TRIGGER BOOLEAN := FALSE;
END PK_OGT_SESSION;CREATE OR REPLACE PACKAGE PK_OGT_SESSION IS
/*Control cambios
  GLP2025002642 20260408 ftorresv Alineación PREDIS vs. PPTO.SHD
*/
    -- Esta variable controlará si los triggers deben ejecutarse o no
    G_IGNORE_TRIGGER BOOLEAN := FALSE;
END PK_OGT_SESSION;--Tomado de varios.sql linea 98

select SUM (APORTE_EMPLEADO)
from ogt_anexo_nomina
where vigencia = 2025
and consecutivo = 26
AND CODIGO_CENTRO_COSTOS IN ( 5, 1285, 1267)
;


select consecutivo, SUM (APORTE_EMPLEADO)
from ogt_anexo_nomina
where vigencia = 2026
and consecutivo =2
AND CODIGO_CENTRO_COSTOS IN ( 5, 1285, 1267)
group by consecutivo
;


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
select p.* --p.consecutivo, p.rubro_interno, r.descripcion
from ogt_registro_presupuestal p, pr_v_rubros r
where REGISTRO >= 0                     --MI_VALOR_CERO
            AND p.TIPO_DOCUMENTO = 'RA'   --UN_TIPO_DOCUMENTO
            AND p.DISPONIBILIDAD >= 0     --MI_VALOR_CERO
            AND p.CONSECUTIVO in (1,2) --:nro_ra   --UN_CONSECUTIVO  12 529956361
            AND p.ENTIDAD = 206           --UNA_ENTIDAD
            AND p.UNIDAD_EJECUTORA = '01' --UNA_UNIDAD_EJECUTORA
            AND p.VIGENCIA = 2026
            and p.vigencia=r.vigencia
            and p.rubro_interno = r.interno_rubro
            order by p.consecutivo
           -- AND registro = :nro_rp
           -- AND rubro_interno = 1804 --2026  es el mismo 1547 antes
;


   	     MI_CUR_REGISTRO := PK_OGT_OP.FN_OGT_RP_PAGO(:OGT_RELACION_AUTORIZACION.VIGENCIA
                                                    ,:OGT_RELACION_AUTORIZACION.ENTIDAD
                                                    ,:OGT_RELACION_AUTORIZACION.UNIDAD_EJECUTORA
                                                    ,'RA'
                                                    ,:OGT_RELACION_AUTORIZACION.CONSECUTIVO);

select * from 
--update 
ogt_relacion_autorizacion  
set estado =  '00000000000'      
where vigencia=2026
and tipo_ra in (1,2)
--and consecutivo=2
and fecha_desde = '01-FEB-2026';

--commit;

select nro_ra
from rh_lm_ra
where scompania = 206 and dfecha_inicial_periodo = '01-FEB-2026'
and tipo_ra=1
and ntipo_nomina=0
;


select *
from bintablas
where grupo='OPGET'
and nombre = 'PATH'
;

create or replace public synonym pk_ogt_session for ogt.pk_ogt_session