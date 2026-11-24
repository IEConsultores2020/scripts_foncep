
--codigo_identificacion in ('830053630');

select b.*
from trc.trc_informacion_basica b
where b.id in (
  select id from trc_terceros where codigo_identificacion in ('901526741')
  ) or
  b.ib_primer_nombre like '%RAP%';

select ib.id, ib.ib_primer_nombre nombre1, ib.ib_segundo_nombre nombre2, ib.ib_primer_apellido apellido1, ib.ib_segundo_apellido apellido2,
      ib.ib_regimen_tributario regiment_tibutario, ib.ib_gran_contribuyente gran_contribuyente, ib.ib_autorretenedor autoretenedor, ib_pais, ib_depto, ib_ciudad,
      ic.ic_banco codigo_banco, ic.ic_tipo_cuenta tipo_cuenta, ic.ic_cuenta numero_cuenta, ic.ic_sucursal sucursal
     -- select*
from trc.trc_informacion_basica ib
full outer join trc.trc_terceros t on t.id = ib.id
full outer join trc.trc_informacion_comercial ic on ic.id = ib.id
where t.codigo_identificacion in ('830053630')
 ;

 select * --ic.ic_banco codigo_banco, ic.ic_tipo_cuenta tipo_cuenta, ic.ic_cuenta numero_cuenta, ic.ic_sucursal sucursal
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
from trc_informacion_comercial
where id in (352874, 49693)

select *
from shd_informacion_comercial
where id in (190597);

select *
from shd_informacion_basica
where id in (190597);

select *
from trc_informacion_basica
--where ib_primer_nombre like '%Patrim%Auto%Socid%Fid%Desa%'
where id --<= 352878 
        in (352874, 352754)
order by id desc
and ib_fecha_final is null;

SELECT 0 ID_BANCO, 'A' NOMBRE, 'B' CUENTA, 'C' TIPO FROM DUAL

  select rowid,ID,IC_FECHA_INICIAL,
  IC_FECHA_FINAL,
  IC_BANCO,
  IC_SUCURSAL,
  IC_TIPO_CUENTA,
  IC_CUENTA,
  IC_TIPO_PAGO     
	FROM SHD_INFORMACION_COMERCIAL
	WHERE ID in in (352874, 352754)
	AND IC_FECHA_FINAL IS NULL;


  select ib.id, max(ib.ib_fecha_final)
	      from trc_terceros t, trc_informacion_basica ib
	     where ib.id = t.id 
	       and t.tipo_identificacion   = 'NIT'
         and t.codigo_identificacion = '830053630'
	     group by ib.id;

  select  *  --ib.id, ib.ib_fecha_final
	      from trc_terceros t, trc_informacion_basica ib
	     where ib.id = t.id  and t.id in (352874, 352754, 49693)
;

	    select * ---c1.observacion
	      --into mi_observacion
	      from trc_soporte_cambio c1
	     where c1.id = 352874
	       and c1.consecutivo = (select max(c2.consecutivo)
	                               from trc_soporte_cambio c2
	                              where c2.id = 352874);       

----
--Se obtiene el interno del tercero 413659
--Se verifica el campo codigo_identificacion en tabla terceros 1
select *
from shd_informacion_basica
where id=413659 ;

---Se procede a actualizar
update shd_terceros
set codigo_identificacion=127165
where id=413659
and codigo_identificacion = 'C1C2716C5';
--Solo debe actualizarse 1 registro de esta tabla

--Se verifica el campo codigo_identificacion en tabla terceros 2
select *
from trc_terceros
where id=413659 ;

--Se procede a actualizar
update trc_terceros
set codigo_identificacion=127165
where id=413659
and codigo_identificacion = 'C1C2716C5';
----Solo debe actualizarse 1 registro de esta tabla

--Se graban los datos modificados.
--commit;
pk_trc_tupes
TRC_Identificacion_TYPE
  MiId                    NUMBER(20),
  MiCompuesto              VARCHAR2(1),
  MiTipoIdentificacion    VARCHAR2(30),
  MiCodigoIdentificacion  VARCHAR2(20),
  MiCodigoEntidad          VARCHAR2(20),
  MiCodigoSuperbancaria    VARCHAR2(20),
  MiTipoSuperbancaria      VARCHAR2(20),
  MiCodigoContaduria      NUMBER(30),
  MiTipoTercero            VARCHAR2(1),
  MiFechaCreacion          DATE,
  MiSistema                VARCHAR2(30),
  MiUsuario                VARCHAR2(30)

  select distinct (tipo_identificacion)
  from trc_terceros

