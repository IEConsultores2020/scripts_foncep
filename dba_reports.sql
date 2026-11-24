--Check Oracle Profiles & Resource Limits

SELECT p.profile, p.resource_name, p.limit
FROM dba_profiles p, dba_users u
WHERE p.profile = u.profile
  AND u.username = 'PR'
  AND p.resource_name IN ('IDLE_TIME'), 'CONNECT_TIME', 'CPU_PER_CALL');


  ALTER PROFILE DEFAULT LIMIT IDLE_TIME UNLIMITED;

