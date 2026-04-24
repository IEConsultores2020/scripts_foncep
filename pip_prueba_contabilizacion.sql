declare
   mi_resp                varchar2(3000) := 'NN';
   mi_procesado           boolean := true;
   mi_nro_referencia_pago sl_pcp_pago.nro_referencia_pago%type := '2025000001';
begin
   pk_ogt_imputacion.pr_contabilizar_imputacion(
      p_nro_referencia_pago => mi_nro_referencia_pago,
      p_usuario             => 'PRUEBA',
      p_resp                => mi_resp,
      p_procesado           => mi_procesado
   );
   if mi_procesado = true then
      dbms_output.put_line('Procesado OK.' || mi_resp);
   else
      dbms_output.put_line('Pago:'
                           || mi_nro_referencia_pago
                           || ' .No procesado ' || mi_resp);
   end if;
end;