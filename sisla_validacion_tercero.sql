--interno   NIT         NOMBRE
--944       890201222   ALCALDIA DE BUCARAMANGA
--          899999357   MUNICIPIO DE CHOCONTA
--CCHICO

select * from sl_compania
where codigo_compania=944;

select * from shd_terceros
where id = 944;

select * from shd_informacion_basica
where --id = 944;
--ib_primer_nombre like '%ALCAL%BUCAR%' --'%CHOCONTA%'  350061
ib_codigo_identificacion in ('899999357','890201222')

select * from trc_informacion_basica
where id in (32053,350061);

select * from trc_terceros
where id in (32053,350061);


--Forma generación Masiva
sl_generac_factura_cp_masiva
Proceso: 

select *  from sl_tmp_factura_cp_2017;

select * from sl_log_procesos
order by fecha desc