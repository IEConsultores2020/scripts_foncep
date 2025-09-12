--Pruebas.
   SET SERVEROUTPUT ON; 

--Guardo estado previo del encabezado
declare
   mi_estado              sl_pcp_encabezado.estado%type;
   mi_nuevo_estado        sl_pcp_encabezado.estado%type;
   mi_nro_referencia_pago sl_pcp_encabezado.nro_referencia_pago%type := '1234567890123';
   num_registros          number;
begin
   dbms_output.put_line('>>>>>>> Iniciando imputación '
                        || current_timestamp
                        || ' >>>>>');
   --Alistando pruebas
   select count(*)
     into num_registros
     from sl_pcp_pago
    where id = 99999;
   if num_registros > 0 then
      dbms_output.put_line('Borrando el registro deprueba');
      delete sl_pcp_pago
       where id = 99999;
      commit;
   end if;


   begin
      --Guardar el estado del encabezado para reversarlo
      select estado
        into mi_estado
        from sl_pcp_encabezado
       where nro_referencia_pago = mi_nro_referencia_pago;
   exception
      when no_data_found then
         mi_estado := 'PEN';
         dbms_output.put_line('No existe el registro en sl_pcp_encabezado, se asume estado PAG');
         insert into sl_pcp_encabezado (
            id,
            nro_referencia_pago,
            cod_barras_iac,
            cod_barras,
            convenio,
            centro_costo,
            valor_referencia,
            id_usuario,
            fecha_sistema,
            estado,
            fecha_vencimiento
         ) values ( 88888,
                    mi_nro_referencia_pago,
                    1234567890123,  --cod barras iac
                    1234567890123,  --cod barras
                    1,              --convenio
                    1,              --centro de costo
                    444444,         --valor referencia
                    1,              --id usuario
                    sysdate,
                    mi_estado,
                    sysdate + 30 );
         --commit;
   end;
   


    --Insertar un registro en sl_pcp_pagos
   dbms_output.put_line('Insertando un registro en SL_PCP_PAGO');
   insert into sl_pcp_pago (
      id,
      nro_referencia_pago,
      id_banco,
      cod_autorizacion,
      fecha_autorizacion,
      metodo_recaudo,
      canal,
      jornada,
      codigo_oficina
   ) values ( 99999,      --id
              mi_nro_referencia_pago,
              1,
              '1234567890',
              sysdate,
              9,          --metodo recaudo: webservice
              9,          --canal webservice
              1,          --jronada normal,
              99          --oficina
               );

   /*dbms_output.put_line('Esperando que procese...');
   dbms_lock.sleep(5); */
    
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

    --Reversando registros 
   update sl_pcp_encabezado
      set
      estado = mi_estado
    where nro_referencia_pago = mi_nro_referencia_pago;

   delete sl_pcp_pago
    where id = 99999;

   commit;
   

    --Se borran los registros creados
  /* dbms_output.put_line('Borrando el pago de prueba');
   delete sl_pcp_pago
    where id = 99999;
*/
   dbms_output.put_line('<<<<< Imputación Finalizada '
                        || current_timestamp
                        || ' <<<<<<< ');
exception
   when others then
      dbms_output.put_line('Error: ' || sqlerrm);
end;
/

--   SET SERVEROUTPUT OFF; 

--EXIT