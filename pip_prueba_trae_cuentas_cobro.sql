--Guardo estado previo del encabezado
/*--Para probar abrir ventana sql y ejecutar las siguientes 4 lineas
   SET ECHO OFF;
   SET SERVEROUTPUT ON  SIZE UNLIMITED;
   spool imputacion.log; 
   Ejecute el código a continuación
   spool off 
   --*/
declare
   mi_nro_referencia_pago  sl_pcp_encabezado.nro_referencia_pago%type := '2025000001';
   v_type_rec_cuenta_cobro pk_ogt_imputacion.type_rec_cuenta_cobro;
   ref_cur_cuentas_cobro   sys_refcursor;
   num_registros           number;
   mi_mensaje              varchar2(2000);
   mi_procesado            boolean;
begin
   dbms_output.put_line('>>>>>>> Iniciando prueba carga cuentas cobro '
                        || current_timestamp
                        || ' >>>>>');
    --/*
   pk_ogt_imputacion.pr_trae_cuentas_cobro(
      p_nro_referencia_pago => mi_nro_referencia_pago,
      p_resp                => mi_mensaje,
      p_ref_cursor          => ref_cur_cuentas_cobro
   );
   dbms_output.put_line('Resultado tarea cuentas cobro para referencia de pago = '
                        || mi_nro_referencia_pago
                        || '. Mensaje:'
                        || mi_mensaje);
   loop
      fetch ref_cur_cuentas_cobro into v_type_rec_cuenta_cobro;
      exit when ref_cur_cuentas_cobro%notfound;
      dbms_output.put_line('ID Cuenta cobro= ' || v_type_rec_cuenta_cobro.id);
   end loop;
   dbms_output.put_line('<<<<< Fin prueba de carga de cuentas de cobro '
                        || current_timestamp
                        || ' <<<<<<< ');
                        --*/
exception
   when others then
      dbms_output.put_line('Error prueba cuentas cobro: ' || sqlerrm);
      --spool off
end;
/
--spool off