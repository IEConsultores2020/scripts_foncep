BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
        job_name        => 'SL_JOB_IMPUTACION',
        job_type        => 'PLSQL_BLOCK',
        job_action      => 'BEGIN 
                                sl.pk_ogt_imputacion.pr_imputaciones(
                                ''' || USER || ''',
                                NULL
                                );
                            END;',
        start_date      => SYSTIMESTAMP,
        repeat_interval => 'FREQ=MINUTELY; INTERVAL=2',
        enabled         => TRUE,              ---ACTIVAR
        auto_drop       => FALSE,          
        comments        => 'Proceso de imputación, cada 2 minutos.'
    );
END;
/

Begin
  Dbms_Scheduler.Drop_Job (Job_Name => 'SL_JOB_IMPUTACION');
END;
/

BEGIN
    -- Keep logs from the last 30 days, purging all older entries
    DBMS_SCHEDULER.PURGE_LOG(
        log_history => 0,
        which_log   => 'SL_JOB_IMPUTACION'
    );
END;
/
COMMIT; 

SELECT job_name, status, actual_start_date, run_duration, error#
FROM dba_scheduler_job_run_details
WHERE job_name = 'SL_JOB_IMPUTACION' -- Replace with your job's name
ORDER BY actual_start_date DESC
FETCH FIRST 1 ROWS ONLY;