CREATE OR REPLACE TRIGGER sl_pcp_tr_a_i_sl_pago
AFTER INSERT ON sl_pcp_pago
FOR EACH ROW
DECLARE
   v_job_name VARCHAR2(100);
   v_plsql_block VARCHAR2(4000);
BEGIN
   -- 1. Definimos un nombre único para el Job
   v_job_name := 'JOB_PAGO_' || :new.nro_referencia_pago || '_' || TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS');

   -- 2. Definimos el bloque de código que ejecutará el Job
   -- Nota: Como el Job es asíncrono, los parámetros de salida (OUT) 
   -- deben ser manejados internamente por el procedimiento o guardados en una tabla de log.
   v_plsql_block := 'DECLARE 
                        v_resp VARCHAR2(1000); 
                        v_proc BOOLEAN; 
                     BEGIN 
                        pk_ogt_imputacion.pr_procesar_imputacion(
                           p_nro_referencia_pago => ''' || :new.nro_referencia_pago || ''',
                           p_usuario             => ''' || USER || ''',
                           p_resp                => v_resp,
                           p_procesado           => v_proc
                        );
                        -- Aquí podrías insertar el resultado en una tabla de auditoría si lo necesitas
                     END;';

   -- 3. Creamos y lanzamos el Job
   DBMS_SCHEDULER.CREATE_JOB (
      job_name        => v_job_name,
      job_type        => 'PLSQL_BLOCK',
      job_action      => v_plsql_block,
      start_date      => SYSTIMESTAMP,
      enabled         => TRUE,
      auto_drop       => TRUE -- El Job se borra solo al terminar
   );

EXCEPTION
   WHEN OTHERS THEN
      seguimiento('Error al lanzar el Job para ref ' || :new.nro_referencia_pago || ': ' || SQLERRM);
END;