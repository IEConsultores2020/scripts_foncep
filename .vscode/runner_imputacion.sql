-- runner for SL.PK_OGT_IMPUTACION
   SET SERVEROUTPUT ON
VARIABLE P_RESP VARCHAR2
VARIABLE P_PROCESADO VARCHAR2

declare
   p_nro_referencia_pago varchar2(15);
   p_usuario             varchar2(200);
   p_resp                varchar2(200);
   p_procesado           boolean;
begin
   p_nro_referencia_pago := null;
   p_usuario := null;
   sl.pk_ogt_imputacion.pr_procesar_imputacion(
      p_nro_referencia_pago => p_nro_referencia_pago,
      p_usuario             => p_usuario,
      p_resp                => p_resp,
      p_procesado           => p_procesado
   );
   dbms_output.put_line('P_RESP = ' || p_resp);
   :p_resp := p_resp;
  -- IF (P_PROCESADO) THEN 
    -- DBMS_OUTPUT.PUT_LINE('P_PROCESADO = ' || 'TRUE');
    -- :P_PROCESADO := 'TRUE';
  -- ELSE
    -- DBMS_OUTPUT.PUT_LINE('P_PROCESADO = ' || 'FALSE');
    -- :P_PROCESADO := 'FALSE';
  -- END IF;
  -- Rollback;
end;