create or replace package pk_ogt_imputacion as
   procedure pr_procesar_imputacion (
      p_nro_referencia_pago sl_pcp_pago.nro_referencia_pago%type,
      p_usuario             varchar2,
      p_resp                out varchar2,
      p_procesado           out boolean
   );

   procedure pr_actualiza_encabezado (
      p_nro_referencia_pago sl_pcp_encabezado.nro_referencia_pago%type,
      p_resp                out varchar2,
      p_procesado           in out boolean
   );
end pk_ogt_imputacion;
/

create or replace package body pk_ogt_imputacion as

   procedure pr_procesar_imputacion (
      p_nro_referencia_pago sl_pcp_pago.nro_referencia_pago%type,
      p_usuario             varchar2,
      p_resp                out varchar2,
      p_procesado           out boolean
   ) as
   begin
      p_procesado := true;
      select sysdate || 'En construcción desde 09/01/2025'
        into p_resp
        from dual;
      pr_actualiza_encabezado(
         p_nro_referencia_pago => p_nro_referencia_pago,
         p_resp                => p_resp,
         p_procesado           => p_procesado
      );
   exception
      when others then
         p_procesado := false;
         p_resp := dbms_utility.format_error_stack;
   end pr_procesar_imputacion;

   procedure pr_actualiza_encabezado (
      p_nro_referencia_pago sl_pcp_encabezado.nro_referencia_pago%type,
      p_resp                out varchar2,
      p_procesado           in out boolean
   ) as
   begin
      --PIM (Parcialmente IMputado): Faltaron cuentas de cobro o liquidaciones por registrar (R)
      if not nvl(
         p_procesado,
         false
      ) then
         update sl_pcp_encabezado
            set
            estado = 'PIM'
          where nro_referencia_pago = p_nro_referencia_pago;
      else
      --IMP (IMputado): Todas las cuentas de cobro y liquidaciones fueron completamente registradas (R)
         update sl_pcp_encabezado
            set
            estado = 'IMP'
          where nro_referencia_pago = p_nro_referencia_pago;
      end if;
      --commit;
      p_procesado := true;
   exception
      when others then
         p_procesado := false;
         p_resp := dbms_utility.format_error_stack;
   end;

end pk_ogt_imputacion;
/

--CREATE PUBLIC SYNONYM pk_ogt_imputacion FOR portalp.object_name[@dblink];