/*
Reporte
Buen día, comedidamente solicitamos de carácter urgente la generación de un reporte en excel, 
de quienes han ocupado los cargos de conductor desde enero de 2018 a marzo de 2026, con los siguientes campos.
N° identificación
Nombres y apellidos
Asignación básica
Prima de antigüedad (si corresponde)
Bonificación por servicios
Prima de servicios
Prima de navidad
Horas extras ( Diurnas, nocturnas, festivos diurnos, festivos nocturnos dominicales diurnos y dominicales nocturnos)
Gracias por su atención y diligencia.
*/


select *  --count(1) 
from rh_dependencias
;

select *
from rh_concepto 
where (nombre like '%EXTRAS%' and nombre not like 'REINTEGRO HORASEXTRAS')
or nombre in ('SUELDO BASICO', 'PRIMA ANTIGUEDAD','BONIFICACION SERVICIOS',
            'PRIMA SERVICIOS','PRIMA SERVICIOS JULIO','PRIMA NAVIDAD')         
order by nombre  
;

select *
from rh_tipos_acto_nove
where codigo_tipo in ('010','100','115')

select secuencia
from rh_posiciones
where cargo||'-'||cargo_grado in ('480-2','480-16','480-17')
;

/*
504
605
8
425
573
13
555
645
*/

select hc2.numero_identificacion, hc2.nombre, TRUNC(VN.DINICIOPERIODO/100) FECHAMES, VN.NOMBRE CONCEPTO, VALOR_DEDUCIDO+AJUSTE_DEDUCIDO VALOR
from v_consulta_nomina vn,
    (
    select p.interno_persona, p.numero_identificacion, 
        p.nombres||' '||p.primer_apellido||' '||p.segundo_apellido nombre,
        min(hc.fecha_inicio) as fecha_minima, max(nvl(hc.fecha_final,sysdate)) fecha_maxima
    from rh_personas p
    join 
        ( select ti.funcionario, 
                ti.fecha_inicio, tf.fecha_final
            from
            (select da.funcionario, da.valor id_cargo, aa.fecha_efectividad fecha_inicio
                from rh_detalle_acto da
                    join rh_actos_administrativos aa
                    on aa.secuencia=da.secuencia
                    and da.nombre_detalle='POSICION' 
                    --and da.funcionario=13
                    and da.valor in (select secuencia
                                    from rh_posiciones
                                    where cargo||'-'||cargo_grado in ('480-2','480-16','480-17')
                                ) and da.tipo_acto='010'
                order by da.valor, da.fecha_acto asc    ) ti
            left outer join    
            (select da.funcionario, da.valor id_cargo, aa.fecha_efectividad-1 fecha_final
                from rh_detalle_acto da
                    join rh_actos_administrativos aa
                    on aa.secuencia=da.secuencia 
                    and da.nombre_detalle='POSICION' 
                    --and da.funcionario=13
                    and da.valor in (select secuencia
                                    from rh_posiciones
                                    where (cargo||'-'||cargo_grado in ('480-2','480-16','480-17')
                                    ) and da.tipo_acto ='100')
                order by da.valor, da.fecha_acto asc    
            ) tf 
            on ti.funcionario=tf.funcionario 
            and ti.id_cargo = tf.id_cargo     
            ) hc
    on p.interno_persona = hc.funcionario      
    group by p.interno_persona, p.numero_identificacion, 
        p.nombres,p.primer_apellido,p.segundo_apellido 
        ) hc2

where vn.dinicioperiodo >= 20180101
and  vn.func_deducido = hc2.interno_persona
---and interno_persona=425
and vn.nombre in (
        select nombre
        from rh_concepto 
        where (nombre like '%EXTRAS%' and nombre not like 'REINTEGRO HORASEXTRAS')
        or nombre in ('SUELDO BASICO', 'PRIMA ANTIGUEDAD','BONIFICACION SERVICIOS',
            'PRIMA SERVICIOS','PRIMA SERVICIOS JULIO','PRIMA NAVIDAD') 
        )
order by numero_identificacion asc, fechames asc, concepto