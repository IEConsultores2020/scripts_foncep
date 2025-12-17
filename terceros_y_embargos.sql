--pk_secuencial.fn_traer_consecutivo('RH','ACTOS_ADVOS','0000','0')

SELECT *
   -- SECUENCIAL
FROM
    BINCONSECUTIVO
WHERE
    GRUPO = 'RH'
    AND NOMBRE = 'ACTOS_ADVOS'
    AND VIGENCIA = '0000'
    AND CODIGO_COMPANIA = '000'
    AND CODIGO_UNIDAD_EJECUTORA = '00'
    ;

/*
 AC202510023762

1092851847

código de identificación: el numero que asignó el banco agrario al juzgado.

el tipo de documento no es valido para personas juridicas

RH_EMBARGOS_BENEFICIARIO

ABONO EN BANCO AGRARIO
y el número de cuenta es la cuenta judicial

*/

SELECT *
FROM BINTABLAS
WHERE /*GRUPO='TERCEROS' 
AND NOMBRE='IDENTIFICACION_P_JURIDICA'
AND ARGUMENTO   = 'IDENTIFICACION_P_JURIDICA';
AND */RESULTADO LIKE '%JUZGADO%'


--FROM RH_EMBARGOS_BENEFICIARIO

SELECT *
  FROM TRC_ERRORES_APLICACION E
 --WHERE E.EA_MENSAJE LIKE '%violado%'
 order by e.ea_mensaje
 ;

select tt.codigo_identificacion
   from trc_terceros tt
 where tt.CODIGO_IDENTIFICACION = 213622 -- 110012041067
;

En PK_TRC_UTIL buscar
IF Una_naturaleza = 'J' THEN
  IF RTRIM(LTRIM(Un_Tipo_Identificacion)) NOT IN ('NIT','ESP','TAC') THEN
    RAISE_APPLICATION_ERROR(-20970,'');
  END IF;
END IF;


SELECT *
FROM BINTABLAS
WHERE GRUPO='NOMINA' 
AND NOMBRE='IDENTIFICACION';

SET SERVEROUTPUT ON;
DECLARE
  mi_resultado pk_trc_types.trc_InfEmbargos_type;
BEGIN
  mi_resultado := trc_pg_svcio_infEntidad.Fn_EntidadEmbargo('110012041022', TRUNC(SYSDATE));
  dbms_output.put_line('my id'||mi_resultado.miId);
  dbms_output.put_line('MiCodigoEmbargo'||mi_resultado.MiCodigoEmbargo);
END;
/
SET SERVEROUTPUT OFF;



  SELECT vista.id, vista.tipo_identificacion, vista.codigo_identificacion, vista.ib_primer_nombre,
           vista.codigo_entidad, vista.ib_codigo_embargo, vista.ib_codigo_ban_agrario, vista.nombre,
           vista.depto
      FROM (
      select te.id, te.tipo_identificacion, te.codigo_identificacion, ib.ib_primer_nombre,te.codigo_entidad,
                   ib.ib_codigo_embargo, ib.ib_codigo_ban_agrario, ba.nombre ,
                   --pk_trc_util.TBuscar(ba.cod_depto, 'TERCEROS','DEPTO', To_char(sysdate, 'DD-MM-YYYY')) depto,
                   Row_Number() Over(Partition By Ib.Id Order By Ib_Fecha_Inicial Desc) Orden01
            from   trc_terceros te, trc_informacion_basica ib, trc_oficinas_banco_agrario ba
            where  ib.id = te.id
            and    ba.codigo_oficina    = ib.ib_codigo_ban_agrario
            --and    ib.ib_codigo_embargo IN  (110012041722,110014003066) --:UnCodEmbargo
            and    ib.ib_fecha_inicial  < sysdate+1
            and    (ib.ib_Fecha_Final  >= sysdate+1 /*Una_Fecha*/ Or ib.ib_Fecha_Final Is Null)
            ) Vista
            ;
            

select IB.ID, IB.IB_PRIMER_NOMBRE, ib.IB_CODIGO_EMBARGO, ib.IB_CODIGO_BAN_AGRARIO
from TRC_INFORMACION_BASICA ib
where id IN (53,31115);
where ib.IB_PRIMER_NOMBRE like '%JUZGADO%SESENTA%SEIS%'  --48816  110014003066
or ib.IB_PRIMER_NOMBRE like '%JUZGADO%VEINTI%DOS%MUNIC%' --277019 110012041722
;


select * --T.ID, T.TIPO_IDENTIFICACION, T.CODIGO_IDENTIFICACION, T.CODIGO_ENTIDAD
from trc_terceros T
where id IN (53,31115);

--ib.IB_CODIGO_EMBARGO= 110014003066

select *
from trc_oficinas_banco_agrario ba
;

select * from TRC_TERCEROS, TRC_INFORMACION_BASICA
WHERE TRC_TERCEROS.ID = TRC_INFORMACION_BASICA.ID
AND CODIGO_IDENTIFICACION='800093816';

select max(id)
from trc_terceros;

ALTER SEQUENCE tr_sq_id.nextval 
   MAXVALUE 1500;

   ALTER SEQUENCE tr_sq_id START WITH 413000
   ;

SELECT * FROM SHD_TERCEROS   
ORDER BY ID DESC
;

SELECT * FROM BINCONSECUTIVO
WHERE NOMBRE LIKE '%TERCEROS%';

select *
from rh_beneficiarios
order by CODIGO_BENEFICIARIO desc;

select sysdate from dual
;


 pk_sit_infbasica.sit_fn_id_identificacion(un_tipo_identificacion, una_identificacion, una_fecha);

  SELECT shd_informacion_basica.id,shd_terceros.tro_compuesto,
             RTRIM(RTRIM(ib_primer_nombre) || ' ' || RTRIM(ib_segundo_nombre) || ' ' ||
             RTRIM(ib_primer_apellido) || ' ' || RTRIM(ib_segundo_apellido)) AS nombre,
             shd_informacion_basica.ib_codigo_identificacion, 
             shd_informacion_basica.ib_fecha_inicial,
             shd_informacion_basica.ib_fecha_final
                   FROM shd_informacion_basica, shd_terceros
      WHERE shd_informacion_basica.ib_tipo_identificacion   = 'NIT'  and --un_tipo_identificacion AND
            shd_informacion_basica.ib_codigo_identificacion = '830053700' and -- una_identificacion AND
		        shd_informacion_basica.id = shd_terceros.id AND
		        shd_informacion_basica.ib_fecha_inicial<=sysdate AND
           (shd_informacion_basica.ib_fecha_final>=sysdate OR shd_informacion_basica.ib_fecha_final IS Null);

             
