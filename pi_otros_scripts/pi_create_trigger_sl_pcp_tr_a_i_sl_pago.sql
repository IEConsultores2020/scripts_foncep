create or replace trigger sl_pcp_tr_a_i_sl_pago after
   insert on sl_pcp_pago
   for each row
declare
   mi_resp      varchar2(1000);
   mi_procesado boolean;
begin
    -- PL/SQL code to be executed after insert
   pk_ogt_imputacion.pr_procesar_imputacion(
      p_nro_referencia_pago => :new.nro_referencia_pago,
      p_usuario             => user,
      p_resp                => mi_resp,
      p_procesado           => mi_procesado
   );
   /*Cuando el proceso se registra completamente en OPGET, LIMAY y SISLA,
      Para el encabezado de la referencia de pago se asigna el estado IMP: Imputado
         Cumpiendo que:
         Todas las cuentas de cobro asociadas al encabezado se encuentran en registradas (Estado=R)
         Todas las liquidaciones asociadas a las cuentas de cobro del encabezado se encuentran registradas (Estado=R)
       */
   if mi_procesado = true then
        /* Cuando el proceso no se registra completamente en OPGET y/o LIMAY y/0 SISLA,
         Su estado es Pendiente de IMputar (estado=PIM).
            Esto sucede por que al menos una cuenta de cobro y/o liquidación, asociado al encabezado tiene su estado diferente a R (Registrado)
       */
     /* pk_ogt_imputacion.pr_actualiza_encabezado(
         p_nro_referencia_pago => :new.nro_referencia_pago,
         p_estado              => 'IMP'
      );*/
      dbms_output.put_line('Referencia de pago procesada correctamente: ' || mi_resp);
   else
      /*Cuando el proceso no termina correctamente,
      Para el encabezado de la referencia de pago se asigna el estado IMP: Imputado
         Y:
         Para las cuentas de cobro asociadas al encabezado. En estado R.
            Se registraron todas las actas  pendientes de registrar. 
               Estado R.
         Para las liquidaciones asociadas a las cuentas de cobro del encabezado. En estado R.
            Se contabilizaron las liquidaciones pendientes de registrar
            Se causaron en contabilidad los intereses pendientes de registrar
            Se actualizó en Sisla los pensionados pendientes de actualizar
       */
    /*  pk_ogt_imputacion.pr_actualiza_encabezado(
         p_nro_referencia_pago => :new.nro_referencia_pago,
         p_estado              => 'PIM'
      );*/
      dbms_output.put_line('Fallo al procesar la referencia de pago: '|| :new.nro_referencia_pago || '. Resp: '|| mi_resp);
   end if;
exception
   when others then -- exception handling (optional)
      dbms_output.put_line('-20001 | Error processing payment reference: ' || sqlerrm);
end;
/