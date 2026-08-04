--Tercero ID 190597 - ID 
--Desde el aplicativo de terceros 2, se realizó la modificación de cambio de nombre al tercero ID 190597. sin embargo, al traer este tercero en el aplicativo OP, no refleja el cambio de nombr

 SELECT ID,
				ic_fecha_inicial,
				ic_fecha_final,
				ic_banco,
				ic_sucursal,
				ic_tipo_cuenta,
				ic_cuenta,
				ic_tipo_pago,
                pk_sit_infbasica.sit_fn_nombre(ic_banco, sysdate)
      FROM shd_informacion_comercial
      WHERE id = 52298 AND ic_fecha_inicial <= sysdate AND
            (ic_fecha_final >= sysdate OR ic_fecha_final IS NULL)    ;


select * from shd_informacion_basica
where ib_codigo_identificacion in ('800103927')            ;

--pk_sit_infbasica.sit_fn_nombre(ic_banco, sysdate)
SELECT * /*id, shd_informacion_basica.ib_primer_nombre,
               shd_informacion_basica.ib_segundo_nombre,
               shd_informacion_basica.ib_primer_apellido,
               shd_informacion_basica.ib_segundo_apellido*/

        select *
        FROM shd_informacion_basica
        WHERE id in (190597) AND ib_fecha_inicial<=sysdate AND
              (ib_fecha_final>=sysdate OR ib_fecha_final IS NULL);

--LV_RADICACION

SELECT ID_TERCERO_PAGAR,NUMERO_RADICADO,IB_TIPO_IDENTIFICACION,IB_CODIGO_IDENTIFICACION,IB_PRIMER_NOMBRE||' '||IB_SEGUNDO_NOMBRE||' '||IB_PRIMER_APELLIDO||' '||IB_SEGUNDO_APELLIDO BENEFICIARIO
FROM OGT_RADICACION_CUENTA_COBRO,SHD_INFORMACION_BASICA
WHERE NUMERO_RADICADO NOT IN (SELECT NVL(NUM_RADICACION,0)
                              FROM OGT_ORDEN_PAGO
                              WHERE VIGENCIA = 2026
                              AND ENTIDAD = 206
                              AND UNIDAD_EJECUTORA = '02')
AND VIGENCIA = 2026
AND ENTIDAD = 206
AND UNIDAD_EJECUTORA = '02'
AND ID_TERCERO_PAGAR = ID
AND IB_FECHA_INICIAL <= SYSDATE
AND NVL(IB_FECHA_FINAL,SYSDATE) >= SYSDATE
ORDER BY NUMERO_RADICADO;

select TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS') from dual
;

select *
from trc_modificacion

