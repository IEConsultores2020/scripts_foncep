select rubro_interno,
       sum(valor)
  from ogt_detalle_actas
 where vigencia = 2025
   and rubro_interno = 1941
 group by rubro_interno;

select *
  from ogt_detalle_actas
 where vigencia = 2025
   and consecutivo in (1,2,4,5,6)
   and rubro_interno = 1491;

select *
  from ogt_actas
 where consecutivo in ( 1,2,4,5,6 )
   and vigencia = 2025
   and tipo_documento = 'AR';

select *
  from ogt_documento_pago
 where consecutivo in ( 1,2,4,5,6 )
   and vigencia = 2025
   and tipo_documento = 'AR';

select trigger_name,
       trigger_type,   -- e.g., BEFORE STATEMENT, AFTER EACH ROW
       triggering_event, -- e.g., INSERT, UPDATE, DELETE
       status
  from all_triggers
 where table_name like 'OGT_DOCUMENTO_PAGO' -- Enter the name of the table in UPPERCASE
   and owner = 'OGT';

select owner,
       view_name,
       text -- Displays the full SQL definition of the view
  from all_views
 where
    -- 1. Search for the table name in the view definition text
  upper(text) like '%OGT%'
    
    -- 2. Optional: Restrict to a specific schema (owner)
   and owner = 'VIEW_OWNER_SCHLEMA' 
    
    -- 3. Optional: Filter out views owned by system users
   and owner not in ( 'SYS',
                      'SYSTEM',
                      'APEX_040200' );

