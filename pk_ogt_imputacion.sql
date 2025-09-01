create or replace package pk_ogt_imputacion as
   procedure pr_procesar_imputacion (
      p_nro_referencia_pago sl_pcp_encabezado.nro_referencia_pago%type,
      p_usuario             varchar2,
      p_resp                out varchar2,
      p_bandera             out boolean
   );
end pk_ogt_imputacion;
/

create or replace package body pk_ogt_imputacion as
   procedure pr_procesar_imputacion (
      p_nro_referencia_pago sl_pcp_encabezado.nro_referencia_pago%type,
      p_usuario             varchar2,
      p_resp                out varchar2,
      p_bandera             out boolean
   ) as
   begin
      select sysdate || '-En construcción desde 09/01/2025'
        into p_resp
        from dual;
      p_bandera := true;
   exception
      when others then
         p_resp := dbms_utility.format_error_stack;
         p_bandera := false;
   end pr_procesar_imputacion;

end pk_ogt_imputacion;
/

CREATE PUBLIC SYNONYM pk_ogt_imputacion FOR portalp.object_name[@dblink];