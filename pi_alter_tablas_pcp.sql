--sl_pcp_encabezado
comment on column sl_pcp_encabezado.estado is
   'Estado de la referencia de pago DIS-Disponible, PAG-Pagado, ANU-Anulado, IMP=Imputado, PIMP=Pendiente imputar(alguna acto o liquidación no está Registrado completamente)'
   ;

--sl_pcp_cuenta_cobro 
alter table sl_pcp_cuenta_cobro add (
   estado char default 'A'
);
comment on column sl_pcp_cuenta_cobro.estado is
   'De acuerdo al registro del acta en opget. A Pendiente crear, R Registrado';

alter table sl_pcp_liquidaciones add (
   estado char(1) default 'C'
);
comment on column sl_pcp_liquidaciones.estado is
   'C pendiente contabilizar, S pendiente actualizar en SISLA, R Registrado ';