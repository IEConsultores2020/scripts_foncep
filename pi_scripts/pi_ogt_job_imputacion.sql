--crea el job
BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
        job_name        => 'OGT.OGT_JOB_IMPUTACION',
        job_type        => 'PLSQL_BLOCK',
        job_action      => 'BEGIN 
                                pk_ogt_imputacion.pr_imputaciones(
                                ''' || USER || ''',
                                NULL
                                );
                            END;',
        start_date      => SYSTIMESTAMP,
        repeat_interval => 'FREQ=MINUTELY; INTERVAL=1',
        enabled         => TRUE,              ---ACTIVAR
        auto_drop       => FALSE,          
        comments        => 'Proceso de imputación, cada 1 minuto.'
    );
END;
/
