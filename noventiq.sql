select ib.id,
       ib.ib_primer_nombre,
       ib.ib_codigo_embargo,
       ib.ib_codigo_ban_agrario
  from trc_informacion_basica ib
 where ib.ib_primer_nombre like '%CONSORCIO%NOV%'  --413113 CONSORCIO NOVENTIQ SM
 ;


select t.id,
       t.tipo_identificacion,
       t.codigo_identificacion,
       t.codigo_entidad
  from trc_terceros t
 where id in ( 413113 ); --NIT 900389156


select *
  from trc_oficinas_banco_agrario ba;

select *
  from trc_terceros,
       trc_informacion_basica
 where trc_terceros.id = trc_informacion_basica.id
   and codigo_identificacion = '901953305';

select max(id)
  from trc_terceros;

alter sequence tr_sq_id.nextval maxvalue 1500;

alter sequence tr_sq_id start with 413000;

select *
  from shd_terceros
 order by id desc;

select *
  from binconsecutivo
 where nombre like '%TERCEROS%';

select *
  from rh_beneficiarios
 order by codigo_beneficiario desc;

select sysdate
  from dual;


pk_sit_infbasica.sit_fn_id_identificacion(
   un_tipo_identificacion,
   una_identificacion,
   una_fecha
);

select shd_informacion_basica.id,
       shd_terceros.tro_compuesto,
       rtrim(rtrim(ib_primer_nombre)
             || ' '
             || rtrim(ib_segundo_nombre)
             || ' '
             || rtrim(ib_primer_apellido)
             || ' '
             || rtrim(ib_segundo_apellido)) as nombre,
       shd_informacion_basica.ib_codigo_identificacion,
       shd_informacion_basica.ib_fecha_inicial,
       shd_informacion_basica.ib_fecha_final
  from shd_informacion_basica,
       shd_terceros
 where shd_informacion_basica.ib_tipo_identificacion = 'NIT'
   and --un_tipo_identificacion AND
    shd_informacion_basica.ib_codigo_identificacion = '830053700'
   and -- una_identificacion AND
    shd_informacion_basica.id = shd_terceros.id
   and shd_informacion_basica.ib_fecha_inicial <= sysdate
   and ( shd_informacion_basica.ib_fecha_final >= sysdate
    or shd_informacion_basica.ib_fecha_final is null );