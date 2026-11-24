/*  INT     CC
    509     24182848
    */
select -- /*
     CASE ESTADO 
     WHEN '1' THEN 'NUEVO'
     WHEN '2' THEN 'ACTIVO'
     WHEN '3' THEN 'CANCELADO'
     WHEN '4' THEN 'SUSPENDIDO'
     WHEN '5' THEN 'TERMINADO'
     ELSE 'OTRO'
     END AS ESTADONOM   --*/
     , RH_DESCUENTOS_F.BENEFICIARIO,
        RH_DESCUENTOS_F.TIPO,
        RH_DESCUENTOS_F.NUMERO_DESCUENTO,
        RH_DESCUENTOS_F.FECHA_INICIO,
        RH_DESCUENTOS_F.PERIODICIDAD,
        RH_DESCUENTOS_F.FECHA_INICIAL_CORTE,
        RH_DESCUENTOS_F.CLASE,
        RH_DESCUENTOS_F.MONTO,
        RH_DESCUENTOS_F.IDENTIFICACION_DESCUENTO
from RH_DESCUENTOS_F
where funcionario = 509
and tipo = 'LIBRANZA'
AND fecha_inicio = '07/feb/2025'
;

select *
from RH_DETALLE_PAGOS_F
where --funcionario = 509
and DESCUENTOS_TIPO = 'LIBRANZA'
and descuentos_numero in (4,5);

select tipo, nit, nombre, sum(monto)
from (
    select case
            when dp.descuentos_tipo like 'APORTEAFP%' then 'APORTEAFP'
            when dp.descuentos_tipo like 'APORTEAFC%' then 'APORTEAFC'
            when dp.descuentos_tipo like 'APORTES%' then 'APORTES'
            when dp.descuentos_tipo like 'CREDITOVIVIENDA%' then 'CREDITOVIVIENDA'
            when dp.descuentos_tipo like 'FONDOEMPLEADOS%' then 'FONDOEMPLEADOS'
            when dp.descuentos_tipo like 'LIBRANZA%' then 'LIBRANZA'
            when dp.descuentos_tipo like 'PLANCOMPLEMENTARIO%' then 'PLANCOMPLEMENTARIO'
            when dp.descuentos_tipo like 'SINDICATO%' then 'SINDICATO'
            else ''
        end tipo,
        b.numero_identificacion_benefici nit,
        b.beneficiario nombre,
        f.valor_cuota,
        dp.monto monto /*,
        --f.*
        --select b. --*/
    from rh_descuentos_f f, 
        rh_detalle_pagos_f dp,
        rh_beneficiarios b
    where f.funcionario = dp.funcionario
    and f.tipo=dp.descuentos_tipo
    and f.numero_descuento=dp.descuentos_numero
    and f.clase = dp.clase
    and f.beneficiario = b.codigo_beneficiario
    and extract(month from dp.fecha_pago)=8
) t
where t.tipo is not null
group by tipo, nit, nombre
order by tipo

