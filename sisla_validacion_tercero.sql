--interno   NIT         NOMBRE
--944       890201222   ALCALDIA DE BUCARAMANGA
--          899999357   MUNICIPIO DE CHOCONTA
--CCHICO

select * from sl_compania
where codigo_compania=944;

select * from shd_terceros
where id = 413469;

select ib_fecha_final
from 
update shd_informacion_basica
set ib_fecha_final = sysdate
where id = 413469;
--ib_primer_nombre like '%ALCAL%BUCAR%' --'%CHOCONTA%'  350061
ib_codigo_identificacion in ('900189642');

select *
from shd_informacion_comercial
where id=153938;

--SHD--SHD--SHD--SHD--SHD--SHD--SHD--SHD--SHD--SHD--SHD--SHD--SHD
select ib.id, ib.ib_fecha_inicial, ib.ib_primer_nombre, 
    ib.ib_codigo_identificacion, ic.ic_cuenta, ic.ic_fecha_inicial, ic.ic_fecha_final
    --select ic.*
from shd_informacion_basica ib, shd_informacion_comercial ic
where ib.id = ic.id
and ib.ib_codigo_identificacion in ('900189642')
and ic_tipo_pago <> 'ND';
/* glp 2026002834
   id   ib_primer_nombre        ib_codigo_identificacion
153938  APERTU COLOMBIA SA      900189642
*/

--TRC--TRC--TRC--TRC--TRC--TRC--TRC--TRC--TRC--TRC--TRC--TRC--TRC
select ib.id, ib.ib_fecha_inicial, ib.ib_primer_nombre, 
    ic.ic_cuenta, ic.ic_feccreacion
    --select ic.*
from trc_informacion_basica ib, trc_informacion_comercial ic
where ib.id = ic.id
and ib_primer_nombre='APERTU COLOMBIA SA'
and ib.id = 153938
--and ib.ib_codigo_identificacion in ('900189642')
and ic.ic_estado='A'
and ic_tipo_pago <> 'ND';

select * from trc_informacion_basica
where id in (32053,350061);

select * from trc_terceros
where id in (32053,350061);


--Forma generación Masiva
sl_generac_factura_cp_masiva
Proceso: 

select *  from sl_tmp_factura_cp_2017;

select * from sl_log_procesos
order by fecha desc;

---Validando tercero TAC
select * from shd_informacion_basica
where ib_tipo_identificacion = 'TAC';


select *
from trc_informacion_comercial
where id=153938;


select *
from sl_relacion_tac
where nombres like '%FERROC%'
;

--20260826_2 Centro de costo que no se encuentran en relacion TAC
select distinct argumento, resultado
       from bintablas
       where  grupo = 'SISLA'
       and nombre = 'CENTROS_COSTO_CP'
       and sysdate between vig_inicial and nvl(sysdate,vig_final)
       and argumento not in 
       (
              select id_sisla
              from sl_relacion_tac tac, sl_cuenta_cobro_cp_2017 cta
              where tac.id_sisla is not null and cta.entidad_cuenta_cobro = tac.codigo_compa
       )
order by argumento --resultado       
;

select *
from sl_relacion_tac tac
where tac.id_sisla in (1128,1047,1125,1323)
;

select *
from sl_cuenta_cobro_cp_2017