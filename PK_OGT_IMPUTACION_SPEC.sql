/*PK_SL_INTERFAZ_OPGET_CP.*/
CREATE OR REPLACE PACKAGE BODY PK_OGT_IMPUTACION AS

TYPE ref_cursor IS REF CURSOR;

--Retorna las cuentas de cobro de un encabezado con p_id_encabezado
PROCEDURE get_cuenta_cobro_ref_cursor(
  p_id_encabezado SL_PCP_ENCABEZADO.ID%type, 
  p_resp OUT VARCHAR2, 
  p_ref_cursor OUT SYS_REFCURSOR
);

--Retorna las liquidaciones de una cuenta de cobro con id p_id_det_cuenta_cobro
PROCEDURE get_liquidaciones_ref_cursor(
  p_id_det_cuenta_cobro SL_PCP_CUENTA_COBRO.id%type, 
  p_resp OUT VARCHAR2, 
  p_ref_cursor OUT SYS_REFCURSOR
);

PROCEDURE PR_IMPUTACION(
    p_nro_referencia_pago VARCHAR2, p_id_usuario NUMBER, p_resp OUT VARCHAR2);


PROCEDURE PR_OGT_IMPUTAR(/*parametros*/)

select * from dual
/


