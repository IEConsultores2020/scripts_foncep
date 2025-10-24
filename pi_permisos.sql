--connectado como OGT
grant ogt_admin to sl;

grant ogt_admin to sl with admin option;

grant select,insert,update,delete on ogt_documento to sl with grant option;
grant select,insert,update,delete on ogt_detalle_documento to sl with grant option;
grant select,insert,update,delete on ogt_detalle_pensionado to sl with grant option;
grant select on ogt_concepto_tesoreria to sl with grant option;
grant select on ogt_tercero_cc to sl with grant option;

--revoke select,insert,update,delete on ogt.ogt_documento from sl;

grant execute,debug on ogt.ogt_pk_ingreso to sl with grant option;

grant insert on ogt.ogt_documento to portalp;

--connectado como shd
grant execute,debug on shd.pk_sit_infentidades to sl with grant option;