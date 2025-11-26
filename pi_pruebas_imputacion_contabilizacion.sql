
update --select * from
   sl_pcp_encabezado 
  set estado='PAG'
  where nro_referencia_pago =   '2025000001'
  ;

--commit;

--Guardo estado previo del encabezado
declare
   mi_estado              sl_pcp_encabezado.estado%type;
   mi_nuevo_estado        sl_pcp_encabezado.estado%type;
   mi_nro_referencia_pago sl_pcp_encabezado.nro_referencia_pago%type := '2025000001';
   num_registros          number;
   mi_mensaje             varchar2(2000);
   mi_procesado           boolean;
begin
   dbms_output.put_line('>>>>>>> Iniciando prueba imputación contabilizacion '|| current_timestamp|| ' >>>>>');

   select estado
     into mi_estado
     from sl_pcp_encabezado
    where nro_referencia_pago = mi_nro_referencia_pago;

   dbms_output.put_line('llamando pr_contabilizar_imputacion');
   --/*

   pk_ogt_imputacion.pr_contabilizar_imputacion(
      p_nro_referencia_pago => '2025000001', --mi_nro_referencia_pago,
      p_usuario             => 'IUSER',
      p_resp                => mi_mensaje,
      p_procesado           => mi_procesado
   );
   --*/
   if mi_procesado = true then
      dbms_output.put_line('Fin normal del proceso de imputación contabilizacion: ' || mi_mensaje);
   else
      dbms_output.put_line('Revise mensaje' || mi_mensaje);
   end if;

    --Consulta el encabezado de la referncia de pago
   dbms_output.put_line('Consultando el encabezado de pago');
   select estado
     into mi_nuevo_estado
     from sl_pcp_encabezado
    where nro_referencia_pago = mi_nro_referencia_pago;
   --commit;
   dbms_output.put_line('Estado previo: '|| mi_estado || ' - Estado nuevo: '|| mi_nuevo_estado);
   

   commit;
   dbms_output.put_line('<<<<< Fin prueba Imputación contabilizacion '|| current_timestamp  || ' <<<<<<< ');
                        --
   --spool off                        
exception
   when others then
      dbms_output.put_line('Error prueba: ' || sqlerrm);
end;
/
--spool off