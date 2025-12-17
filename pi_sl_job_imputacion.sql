BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
        job_name        => 'SL_JOB_IMPUTACION',
        job_type        => 'PLSQL_BLOCK',
        job_action      => 'DECLARE 
                                v_resp VARCHAR2(1000); 
                                v_proc BOOLEAN; 
                            BEGIN 
                                pk_ogt_imputacion.pr_imputaciones(
                                p_usuario             => ''' || USER || ''',
                                p_resp                => v_resp,
                                p_procesado           => v_proc
                                );
                            END;',
        start_date      => SYSTIMESTAMP,
        repeat_interval => 'FREQ=MINUTELY; INTERVAL=15',
        enabled         => TRUE,
        auto_drop       => FALSE,
        comments        => 'Proceso de imputación, cada 15 minutos.'
    );
END;
/