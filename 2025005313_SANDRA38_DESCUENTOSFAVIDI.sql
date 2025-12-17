/*  INT     CC
    509     24182848
    */
select --  /*
     CASE ESTADO 
     WHEN '1' THEN 'NUEVO'
     WHEN '2' THEN 'ACTIVO'
     WHEN '3' THEN 'CANCELADO'
     WHEN '4' THEN 'SUSPENDIDO'
     WHEN '5' THEN 'TERMINADO'
     ELSE 'OTRO'
     END AS ESTADONOM   
     , RH_DESCUENTOS_F.BENEFICIARIO,
        RH_DESCUENTOS_F.TIPO,
        RH_DESCUENTOS_F.NUMERO_DESCUENTO,
        RH_DESCUENTOS_F.FECHA_INICIO,
        RH_DESCUENTOS_F.PERIODICIDAD,
        RH_DESCUENTOS_F.FECHA_INICIAL_CORTE,
        RH_DESCUENTOS_F.CLASE,
        RH_DESCUENTOS_F.MONTO,
        RH_DESCUENTOS_F.IDENTIFICACION_DESCUENTO,
        RH_DESCUENTOS_F.BENEFICIARIO --*/
from RH_DESCUENTOS_F
where funcionario = 38
and tipo IN ('LIBRANZA','FONDOEMPLEADOS1','FONDOEMPLEADOS2','FONDOEMPLEADOS3')
and beneficiario =2510
--AND fecha_inicio BETWEEN '01/JAN/2021' AND '31/DEC/2023'
;

select descuentos_tipo, descuentos_numero, numero_pago, fecha_pago, monto
from RH_DETALLE_PAGOS_F
where funcionario = 38
and DESCUENTOS_TIPO IN ('LIBRANZA','FONDOEMPLEADOS1','FONDOEMPLEADOS2','FONDOEMPLEADOS3')
    and descuentos_numero in 
        (
            select         RH_DESCUENTOS_F.NUMERO_DESCUENTO
            from RH_DESCUENTOS_F
            where funcionario = 38
            and tipo IN ('LIBRANZA','FONDOEMPLEADOS1','FONDOEMPLEADOS2','FONDOEMPLEADOS3')
            and beneficiario = 2510
        )
and fecha_pago between '01/JAN/2021' AND '31/DEC/2023'
order by descuentos_numero, numero_pago, fecha_pago
;