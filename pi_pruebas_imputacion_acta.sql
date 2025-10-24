/*
select *  from sl_pcp_encabezado
 where nro_referencia_pago in ( select nro_referencia_pago from sl_pcp_pago);

select * from SL_PCP_CUENTA_COBRO where id_encabezado in ('2')
*/

/*--Para probar abrir ventana sql y ejecutar las siguientes 4 lineas
   SET ECHO OFF;
   SET SERVEROUTPUT ON  SIZE UNLIMITED;
   spool imputacion.log; 
   Ejecute el código a continuación
   spool off --*/

--Guardo estado previo del encabezado
declare
   mi_estado              sl_pcp_encabezado.estado%type;
   mi_nuevo_estado        sl_pcp_encabezado.estado%type;
   mi_nro_referencia_pago sl_pcp_encabezado.nro_referencia_pago%type := '2025000001';
   num_registros          number;
   mi_mensaje             varchar2(2000);
   mi_procesado           boolean;
begin
   dbms_output.put_line('>>>>>>> Iniciando prueba imputación acta '
                        || current_timestamp
                        || ' >>>>>');
   select estado
     into mi_estado
     from sl_pcp_encabezado
    where nro_referencia_pago = mi_nro_referencia_pago;

   if sql%notfound then
      mi_mensaje := 'No existe en el encabezado la referencia de pago: ' || mi_nro_referencia_pago;
      raise no_data_found;
   end if;

   dbms_output.put_line('llamando pr_proceso_imputacion');
   --/*
   pk_ogt_imputacion.pr_procesar_imputacion(
      p_nro_referencia_pago => '2025000001', --mi_nro_referencia_pago,
      p_usuario             => 'IUSER',
      p_resp                => mi_mensaje,
      p_procesado           => mi_procesado
   );
   --*/
   if mi_procesado = true then
      dbms_output.put_line('Fin normal del proceso de imputación: ' || mi_mensaje);
   else
      dbms_output.put_line('Algo no salió bien en el proceso de imputacion: ' || mi_mensaje);
   end if;

    --Consulta el encabezado de la referncia de pago
   dbms_output.put_line('Consultando el encabezado de pago');
   select estado
     into mi_nuevo_estado
     from sl_pcp_encabezado
    where nro_referencia_pago = mi_nro_referencia_pago;
   --commit;
   dbms_output.put_line('Estado previo: '
                        || mi_estado
                        || ' - Estado nuevo: '
                        || mi_nuevo_estado);
   dbms_output.put_line('Se restaura al estado previo el encabezado');
    --Reversando registros 
   update sl_pcp_encabezado
      set
      estado = mi_estado
    where nro_referencia_pago = mi_nro_referencia_pago;

   commit;
   dbms_output.put_line('<<<<< Fin prueba Imputación '
                        || current_timestamp
                        || ' <<<<<<< ');
                        --*/
   --spool off                        
exception
   when others then
      dbms_output.put_line('Error prueba: ' || sqlerrm);
      --spool off
end;
/
--spool off