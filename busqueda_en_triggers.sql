SELECT owner, name, type, line, text
FROM all_source
WHERE type = 'TRIGGER'
  AND (upper(text) LIKE '%OGT_DOCUMENTO%') 
   AND upper(text) LIKE '%NUMERO_LEGAL%')
ORDER BY owner, name, line;


SELECT owner, 
       name AS package_name, 
       type, 
       line, 
       text
FROM all_source
WHERE type IN ('PACKAGE', 'PACKAGE BODY')
  AND upper(text) LIKE upper('%UPDATE OGT_DOCUMENTO%')
ORDER BY owner, name, line;