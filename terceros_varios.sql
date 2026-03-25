select id_limay
        from sl_relacion_tac
       where codigo_compa = 107766;  --400293

select nit from sl_compania com where com.codigo_compania = 107766       
    

select *
  from shd_informacion_basica where id = 6112
 where shd_informacion_basica.ib_tipo_identificacion = nvl(
      :un_tipo_identificacion,
      shd_informacion_basica.ib_tipo_identificacion
   )
   and shd_informacion_basica.ib_codigo_identificacion = :una_identificacion
   and shd_informacion_basica.ib_fecha_inicial <= :una_fecha
   and ( shd_informacion_basica.ib_fecha_final >= :una_fecha
    or shd_informacion_basica.ib_fecha_final is null );
            --nit 890399011 31514
            ;

pk_sit_infentidades.sit_fn_infentidades(:ogt_detalle_documento.ter_id_entidad_origen,SYSDATE);
SELECT  shd_informacion_entidades.id,
            shd_informacion_entidades.ie_fecha_inicial,
            shd_informacion_entidades.ie_fecha_final,
            shd_informacion_entidades.ie_tipo,
            shd_informacion_entidades.ie_procedencia,
            shd_informacion_entidades.ie_sector,
            shd_informacion_entidades.ie_regimen_tributario,
            shd_informacion_entidades.ie_gran_contribuyente,
            shd_informacion_entidades.ie_autorretenedor,
            shd_informacion_entidades.ie_matricula_mercantil,
            shd_informacion_entidades.ie_fecha_matricula,
            shd_informacion_entidades.ie_filial_colombia,
            shd_informacion_entidades.ie_fecha_constitucion,
            shd_informacion_entidades.ie_sigla,
            shd_informacion_entidades.ie_codigo_superbancaria,
            shd_informacion_entidades.ie_otra_codificacion,
            shd_informacion_entidades.ie_representante_legal,
            shd_informacion_entidades.ie_identificacion_rl,
            shd_informacion_entidades.ie_procedencia_rl,
            shd_informacion_entidades.ie_delegado,
            shd_informacion_entidades.ie_identificacion_dl,
            shd_informacion_entidades.ie_procedencia_dl,
            shd_informacion_entidades.ie_ep_clase,
            shd_informacion_entidades.ie_ep_nivel,
            shd_informacion_entidades.ie_ep_sector,
            shd_informacion_entidades.ie_ep_tipo,
            shd_informacion_entidades.ie_otra_clasificacion,
            shd_informacion_entidades.ie_contaduria_gral
      FROM shd_informacion_entidades
      WHERE id = :un_id AND ie_fecha_inicial <= :una_fecha AND
      (ie_fecha_final >= :una_fecha OR ie_fecha_final IS NULL)            

      select * from sit_terceros
      ;


--Consulta terceros funcionarios
select en.tipo,
       en.codigo
  from rh.rh_entidad en
 where en.tipo_servicio = 'BANCOS'
   and en.descripcion = '5816';

--Mirando desde funcinario
--select *  from 
   --update 
   rh_funcionario
   --set   codigo_banco = 1014
 where codigo_banco = 1014 /*and/*personas_interno in (
   select interno_persona
     from rh_personas
    where numero_identificacion = 46364040
)*/
   ;


        commit;

--Mirando desde personas
select numero_identificacion
  from rh_personas
 where interno_persona in (
   select personas_interno
     from rh_funcionario
    where forma_pago = 'C' --codigo_banco in ( 1014 )
);

        TRC_PG_SVCIO_INFCOMERCIAL.fn_infcomercial(un_id, TRUNC(SYSDATE));
select * /* id, ic_banco, ic_tipo_cuenta, ic_cuenta, null, ic_fecha_inicial, null,
               ic_sucursal, ic_tipo_pago, null, null, null, null, 0, null*/
  from shd_informacion_comercial
 where id = :un_id
   and ic_fecha_inicial <= :una_fecha
   and ( ic_fecha_final >= :una_fecha
    or ic_fecha_final is null );

select en.tipo,
       en.codigo,
       en.descripcion
          -- INTO mi_tipo_banco, mi_codigo_banco
  from rh.rh_entidad en
 where en.tipo_servicio = 'BANCOS'
   and en.descripcion = 'BANCO DE BOGOTA'; --:rh_funcionario.banco;   	

 select id_tercero --INTO mi_tercero
  from rh_terceros
 where esquema = 'RH'
   and rh_terceros.entidad_tipo = 'BANCO' --:rh_funcionario.tipo_banco
   and rh_terceros.entidad_codigo = 1014 --:rh_funcionario.codigo_banco
   ;

select *
from rh_terceros          
where codigo in (47125,16791);


select *
from rh_funcionario;

select *
from trc.trc_terceros
where codigo_identificacion in ('41341647','51843547');

select b.primer
from trc.trc_informacion_basica B
where id in (select id
from trc.trc_terceros
where codigo_identificacion in ('41341647','51843547'));

select ib.ib_primer_nombre nombre1, ib.ib_segundo_nombre nombre2, ib.ib_primer_apellido apellido1, ib.ib_segundo_apellido apellido2,
      ib.ib_regimen_tributario regiment_tibutario, ib.ib_gran_contribuyente gran_contribuyente, ib.ib_autorretenedor autoretenedor, ib_pais, ib_depto, ib_ciudad,
      ic.ic_banco codigo_banco, ic.ic_tipo_cuenta tipo_cuenta, ic.ic_cuenta numero_cuenta, ic.ic_sucursal sucursal
     -- select distinct t.codigo_identificacion, ib.ib_primer_nombre nombre1, ib.ib_segundo_nombre nombre2
from trc.trc_informacion_basica ib
full outer join trc.trc_terceros t on t.id = ib.id
full outer join trc.trc_informacion_comercial ic on ic.id = ib.id
where t.codigo_identificacion in ('860002503','800126785',
'901104588','860041163','860066942','860514823','80182608',
'900116609','830084033','901652098','860078828','860002964','830070784')
 ;

 select ic.ic_banco codigo_banco, ic.ic_tipo_cuenta tipo_cuenta, ic.ic_cuenta numero_cuenta, ic.ic_sucursal sucursal
 from trc.trc_informacion_comercial ic;

 create or replace view vw_terceros_foncep as
 select ib.ib_primer_nombre nombre1, ib.ib_segundo_nombre nombre2, ib.ib_primer_apellido apellido1, ib.ib_segundo_apellido apellido2,
      ib.ib_regimen_tributario regiment_tibutario, ib.ib_gran_contribuyente gran_contribuyente, ib.ib_autorretenedor autoretenedor, ib_pais, ib_depto, ib_ciudad,
      ic.ic_banco codigo_banco, ic.ic_tipo_cuenta tipo_cuenta, ic.ic_cuenta numero_cuenta, ic.ic_sucursal sucursal
     -- select t.*
from trc.trc_informacion_basica ib
full outer join trc.trc_terceros t on t.id = ib.id
full outer join trc.trc_informacion_comercial ic on ic.id = ib.id
 ;



select *
from shd_terceros
where codigo_identificacion in ('41341647','51843547');

select *
from shd_informacion_basica
where ib_codigo_identificacion in ('41341647','51843547');