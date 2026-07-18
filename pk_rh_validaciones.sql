create or replace PACKAGE PK_RH_VALIDACIONES AS
--by FTORRESV
TYPE RDetallePagos IS RECORD (
        Funcionario                   rh_detalle_pagos_F.funcionario%TYPE, 
        Descuentos_Numero             rh_detalle_pagos_F.descuentos_numero%TYPE,
        Descuentos_Tipo               rh_detalle_pagos_F.descuentos_tipo%TYPE,
        Numero_Pago                   rh_detalle_pagos_F.numero_pago%TYPE,
        Fecha_Pago                    rh_detalle_pagos_F.fecha_pago%TYPE,
        Monto_Descuento               rh_detalle_pagos_F.monto%TYPE,
        Clase                         rh_detalle_pagos_F.clase%TYPE,
        Comision											rh_detalle_pagos_F.comision%TYPE,
        Iva														rh_detalle_pagos_F.iva%TYPE);

   /* Selecciona número de siguiente pago de la tabla rh_detalle_pagos_F. */
   PROCEDURE PR_RH_Numero_Pago (un_funcionario IN NUMBER, 
                                un_numero_descuento IN VARCHAR2,
                                un_tipo_descuento IN VARCHAR2, 
                                un_numero_pago OUT NUMBER );

PROCEDURE PR_RH_Clase_Descuento (un_funcionario IN NUMBER, 
                                    un_numero_descuento IN VARCHAR2,
                                    un_tipo_descuento IN VARCHAR2, 
                                    una_clase_descuento OUT VARCHAR2 ) ;

PROCEDURE PR_RH_Valida_Detalle_Pago (un_detalle_pago IN RDetallePagos, 
                                        un_total_registros OUT NUMBER );


PROCEDURE Pr_RH_Validar_Detalle_Pagos(un_proceso IN
                                     rh_historico_nomina.sproceso%TYPE,
                                     una_corrida IN
                                     rh_historico_nomina.ncorrida%TYPE,
                                     un_inicioperiodo IN
                                     rh_historico_nomina.dinicioperiodo%TYPE,
                                     un_finalperiodo IN
                                     rh_historico_nomina.dfinalperiodo%TYPE);

end PK_RH_VALIDACIONES;
