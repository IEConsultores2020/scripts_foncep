--connectado como OGT
grant ogt_admin to sl;

grant ogt_admin to sl with admin option;

grant select,insert,update,delete on ogt_documento to sl with grant option;
grant select,insert,update,delete on ogt_detalle_documento to sl with grant option;
grant select,insert,update,delete on ogt_detalle_pensionado to sl with grant option;

grant select on ogt_concepto_tesoreria to sl with grant option;
grant select on ogt_tercero_cc to sl with grant option;
grant select on ogt_ingreso to sl with grant option;

--revoke select,insert,update,delete on ogt.ogt_documento from sl;

grant execute,debug on ogt.ogt_pk_ingreso to sl with grant option;

grant insert on ogt.ogt_documento to portalp;

grant update, insert on ogt_ingreso to sl;

grant execute on fn_actualiza_ejecutora to sl;

create or replace public synonym pk_ogt_imputacion FOR ogt.pk_ogt_imputacion;
--create public synonym seguimiento FOR sl.seguimiento;


--connectado como shd
grant execute,debug on shd.pk_sit_infentidades to sl with grant option;
grant execute,debug on shd.pk_sit_infbasica to sl with grant option;
grant execute,debug on shd.pk_secuencial to sl with grant option;
grant execute,debug on sl.seguimiento to ogt with grant option;
grant execute,debug on sl.seguimiento to lm2 with grant option;

--jobs with system
GRANT CREATE JOB TO SL;
GRANT EXECUTE ON DBMS_SCHEDULER TO SL;
-- Optional, but useful for full management capabilities
GRANT MANAGE SCHEDULER TO SL; 


--Conectado como SYS
grant select,update on sl.sl_relacion_terceros to ogt with grant option;
grant execute on sl.pk_sl_interfaz_opget_cp to ogt with grant option;
grant select, update on sl.sl_pcp_encabezado to ogt with grant option;
grant select, update on sl.sl_pcp_cuenta_cobro to ogt with grant option;
grant select, update on sl.sl_pcp_liquidaciones to ogt with grant option;
grant select, update on sl.sl_pcp_pago to ogt with grant option;
grant select, update on sl.sl_relacion_tac to ogt with grant option;



