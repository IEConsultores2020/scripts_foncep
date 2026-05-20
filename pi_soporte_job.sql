
Begin
  Dbms_Scheduler.Drop_Job (Job_Name => 'OGT_JOB_IMPUTACION');
END;
/

BEGIN
    -- Keep logs from the last 30 days, purging all older entries
    DBMS_SCHEDULER.PURGE_LOG(
        log_history => 0,
        which_log   => 'OGT_JOB_IMPUTACION'
    );
END;
/
COMMIT; 


--Ejecutar solo para verificar
SELECT job_name, status, actual_start_date, run_duration, error#
FROM dba_scheduler_job_run_details
WHERE job_name = 'OGT_JOB_IMPUTACION' -- Replace with your job's name
ORDER BY actual_start_date DESC
FETCH FIRST 1 ROWS ONLY;

