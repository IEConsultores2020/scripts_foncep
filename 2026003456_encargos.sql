/*
Atentamente solicitamos un listado de encargos desde el año 20146 a la fecha, con datos fecha inicio y fecha fin.
*/
select *
from rh_tipos_acto_nove where descripcion like '%ENCAR%COMI%'
where codigo_tipo in ('040');

select --aa.funcionario, 
    p.numero_identificacion,
    p.nombres || ' ' || p.primer_apellido || ' ' || p.segundo_apellido nombre_completo,
    aa.fecha_efectividad, aa.fecha_final, dad.valor dias, dac.valor cargo, dag.valor grado, dan.valor nivel, 
        dap.valor cod_dependencia, d.DESCRIPCION
from rh_actos_administrativos aa
left join rh_detalle_acto dad on aa.tipo_acto=dad.tipo_acto and aa.secuencia=dad.secuencia and dad.nombre_detalle='DIAS'
join rh_detalle_acto dac on aa.tipo_acto=dac.tipo_acto and aa.secuencia=dac.secuencia and dac.nombre_detalle='CARGO'
join rh_detalle_acto dag on aa.tipo_acto=dag.tipo_acto and aa.secuencia=dag.secuencia and dag.nombre_detalle='GRADO'
join rh_detalle_acto dan on aa.tipo_acto=dan.tipo_acto and aa.secuencia=dan.secuencia and dan.nombre_detalle='NIVEL'
join rh_detalle_acto dap on aa.tipo_acto=dap.tipo_acto and aa.secuencia=dap.secuencia and dap.nombre_detalle='DEPENDENCIA'
join rh_dependencias d on dap.valor=d.codigo_dependencia
join rh_personas p on aa.funcionario=p.interno_persona
where aa.tipo_acto in ('040') and aa.fecha_efectividad   >= '01-JAN-2016'
order by aa.numero_identificacion, aa.fecha_efectividad asc;
