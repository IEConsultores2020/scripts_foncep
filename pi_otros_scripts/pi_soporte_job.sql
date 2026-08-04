

Begin
  Dbms_Scheduler.Drop_Job (Job_Name => 'OGT.OGT_JOB_IMPUTACION');    ---20260612 Este debe existir
END;
/


BEGIN
    -- Keep logs from the last 30 days, purging all older entries
    DBMS_SCHEDULER.PURGE_LOG(
        log_history => 0,
        which_log   => 'OGT.OGT_JOB_IMPUTACION'
    );
END;
/
COMMIT; 


SELECT * FROM all_scheduler_jobs;



--Ejecutar solo para verificar
SELECT job_name, status, actual_start_date, run_duration, error#, additional_info
FROM dba_scheduler_job_run_details
WHERE job_name = 'OGT_JOB_IMPUTACION' -- Replace with your job's name
ORDER BY actual_start_date DESC
FETCH FIRST 1 ROWS ONLY;

--Ejecutar solo para verificar
SELECT * --job_name, status, actual_start_date, run_duration, error#, additional_info
FROM dba_scheduler_job_run_details
WHERE JOB_NAME <> 'OGT_JOB_IMPUTACION'
AND JOB_NAME NOT LIKE '%APEX%'
ORDER BY LOG_ID DESC
WHERE job_action like 'PK_SL%'
WHERE job_name = 'JOB_LIQUIDAR_INTERESES_MASIVO' -- Replace with your job's name
ORDER BY actual_start_date DESC
FETCH FIRST 1 ROWS ONLY;


Begin
  Dbms_Scheduler.Drop_Job (Job_Name => 'JOB_LIQUIDAR_INTERESES_MASIVO');    ---20260612 Este debe existir
END;
/