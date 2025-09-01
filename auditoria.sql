select distinct ( operacion )
  from auditoria
 where tabla = 'OGT_REGISTRO_PRESUPUESTAL'
   and fecha >= to_date('11/08/2025','dd/mm/yyyy')
   and columna = 'VALOR_REGISTRO'
   and ( valor_ant is not null
    or valor_nuevo is not null )
--and operacion not in ('INSERTAR','ELIMINAR')
 group by operacion
 order by fecha desc;


--200250811 8PM  52141 registros
--20250812 11AM  52145 crea table 2025012
--202508121658   52145 creat table 2025121658
-- ogt_registro_presupuestal prod 52145  pru 52125
-- Traida de backup en produccion 52125
-- 20250812 1103pm Se actualiza y queda con 52145

select count(1)
  from ogt_registro_presupuestal;

select count(1),
       valor_registro
  from ogt_registro_presupuestal
  --WHERE VALOR_REGISTRO = 487350435
 group by valor_registro
having count(1) = 44784;

create table ogt_registro_presupuestal_2025011
   as
      select *
        from ogt_registro_presupuestal;

create table ogt_registro_presupuestal_20250121658
   as
      select *
        from ogt_registro_presupuestal;

create table ogt_registro_presupuestal_ori202508101948
   as
      select *
        from ogt_registro_presupuestal;        


select count(1) from ogt_registro_presupuestal_2025011
;

select count(1)
  from ogt_registro_presupuestal_20250121658;


select *
  from ogt_registro_presupuestal_20250121658 rbk,
       ogt_registro_presupuestal rp
 where rbk.vigencia = rp.vigencia
   and rbk.entidad = rp.entidad
   and rbk.unidad_ejecutora = rp.unidad_ejecutora
   and rbk.tipo_documento = rp.tipo_documento
   and rbk.consecutivo = rp.consecutivo
   and rbk.rubro_interno = rp.rubro_interno
   and rbk.disponibilidad = rp.disponibilidad
   and rbk.registro = rp.registro
   and rbk.vigencia_presupuesto = rp.vigencia_presupuesto
   and rbk.valor_registro <> rp.valor_registro;


--Validar valores diferentes de los registros originales

--Ingresar registros que no existen
insertxx into ogt_registro_presupuestal (
        RUBRO_INTERNO,        UNIDAD_EJECUTORA_PRESUPUESTO,   DISPONIBILIDAD,
        VIGENCIA_PRESUPUESTO, TIPO_DOCUMENTO,                 UNIDAD_EJECUTORA,
        ENTIDAD,              VIGENCIA,                       CONSECUTIVO,
        ENTIDAD_PRESUPUESTO,  REGISTRO,                       VALOR_REGISTRO,
        ID_LIMAY_GIRO_PRESUPUESTAL,FECHA_GIRO_PRESUPUESTAL,   USUARIO_GIRO_PRESUPUESTAL,
        ID_LIMAY_PAGO,        FECHA_PAGO,                     USUARIO_PAGO,
        ID_LIMAY_ANULACION_GIRO,FECHA_ANULACION_GIRO,         USUARIO_ANULACION_GIRO,
        ID_LIMAY_ANULACION_PAGO,FECHA_ANULACION_PAGO,         USUARIO_ANULACION_PAGO
      )

    (SELECT RUBRO_INTERNO,        UNIDAD_EJECUTORA_PRESUPUESTO,   DISPONIBILIDAD,
            VIGENCIA_PRESUPUESTO, TIPO_DOCUMENTO,                 UNIDAD_EJECUTORA,
            ENTIDAD,              VIGENCIA,                       CONSECUTIVO,
            ENTIDAD_PRESUPUESTO,  REGISTRO,                       VALOR_REGISTRO,
            ID_LIMAY_GIRO_PRESUPUESTAL,FECHA_GIRO_PRESUPUESTAL,   USUARIO_GIRO_PRESUPUESTAL,
            ID_LIMAY_PAGO,        FECHA_PAGO,                     USUARIO_PAGO,
            ID_LIMAY_ANULACION_GIRO,FECHA_ANULACION_GIRO,         USUARIO_ANULACION_GIRO,
            ID_LIMAY_ANULACION_PAGO,FECHA_ANULACION_PAGO,         USUARIO_ANULACION_PAGO
    FROM ogt_registro_presupuestal_20250121658 bkorp
    WHERE NOT EXISTS
          (select 1
           FROM ogt_registro_presupuestal rp
           where bkorp.vigencia = rp.vigencia
            and bkorp.entidad = rp.entidad
            and bkorp.unidad_ejecutora = rp.unidad_ejecutora
            and bkorp.tipo_documento = rp.tipo_documento
            and bkorp.consecutivo = rp.consecutivo
            and bkorp.rubro_interno = rp.rubro_interno
            and bkorp.disponibilidad = rp.disponibilidad
            and bkorp.registro = rp.registro
            and bkorp.vigencia_presupuesto = rp.vigencia_presupuesto
          )
    );

  commit;  

