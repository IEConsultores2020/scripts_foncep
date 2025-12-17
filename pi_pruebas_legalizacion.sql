select * from 
 ogt_documento
 where tipo = 'ALE'
   and estado = 'RE'
   and unte_codigo = 'FINANCIERO'
   and numero_externo in ( '20250000477') 
   and extract(year from fecha) in ( 2025 );

select estado
from sl_pcp_encabezado 
where nro_referencia_pago =   '2025000001'
;

--Guardo estado previo del encabezado
declare
   mi_estado              sl_pcp_encabezado.estado%type;
   mi_nuevo_estado        sl_pcp_encabezado.estado%type;
   mi_nro_referencia_pago sl_pcp_encabezado.nro_referencia_pago%type := '2025000001';
   num_registros          number;
   mi_mensaje             varchar2(2000);
   mi_procesado           boolean;
begin
   dbms_output.put_line('>>>>>>> Iniciando prueba de legalizacion '|| current_timestamp|| ' >>>>>');

   select estado
     into mi_estado
     from sl_pcp_encabezado
    where nro_referencia_pago = mi_nro_referencia_pago;

   dbms_output.put_line('llamando pr_proceso_imputacion');
   --/*
   pr_legalizar_financiero(
      p_nro_referencia_pago => '2025000001', --mi_nro_referencia_pago,
      p_resp                => mi_mensaje,
      p_procesado           => mi_procesado
   );
   --*/
   if mi_procesado = true then
      dbms_output.put_line('Fin normal del proceso de legalizacion: ' || mi_mensaje);
   else
      dbms_output.put_line('Revise mensaje' || mi_mensaje);
   end if;


   commit;
   dbms_output.put_line('<<<<< Fin prueba legalizacion '|| current_timestamp  || ' <<<<<<< ');
                        --
   --spool off                        
exception
   when others then
      dbms_output.put_line('Error prueba legalizacion: ' || sqlerrm);
end;
/
--spool off