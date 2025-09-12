create or replace trigger SL_PCP_TR_A_I_SL_PAGO after
   create of nro_referencia_pago on sl_pcp_encabezado
   for each row
declare
   mi_resp      varchar2(3000);
   mi_procesado boolean;
begin
   if (
      :new.nro_referencia_pago is not null
      and :old.nro_referencia_pago is null
   ) then
      if :new.estado = 'IMP' then
         raise_application_error(
            -20001,
            'Encabezado estaba previamente imputado. ID: '||:OLD.ID || ' No es posible registrar la referencia de pago ' ||:NEW.NRO_REFERENCIA_PAGO ;
         );
      end if;
      pk_ogt_imputacion.pr_procesar_imputacion(
         p_nro_referencia_pago => :new.nro_referencia_pago,
         p_usuario             => user,
         p_resp                => mi_resp,
         p_bandera             => mi_procesado
      );

      if mi_procesado = true then
         :new.estado := 'IMP';
         dbms_output.put_line('Referencia de pago imputada correctamente: ' || mi_resp);
      else
         dbms_output.put_line('Fallo al imputar al encabezado '
                              || :old.id
                              || ' la referencia de pago: '
                              || :new.nro_referencia_pago
                              || '. Resp:'
                              || mi_resp);
      end if;
   else
      raise_application_error(
         -20001,
         'No es posible modificar ó anular la referencia de pago'
      );
   end if;
exception
   when others then
      raise_application_error(
         -20001,
         'No es posible modificar ó anular la referencia de pago'
      );
end;
/