--Actualizar estado del acta
select * from 
--update 
--delete
ogt_documento
--set estado='RE'
 where tipo = 'ALE'
   --and estado = 'AP'
   and unte_codigo = 'FINANCIERO'
   and numero_externo in ( '2025000112') 
   and extract(year from fecha) in ( 2025 );

select id,
      nro_referencia_pago,
      estado,
      centro_costo
from sl_pcp_encabezado
where estado in ('PAG','REG')
and nro_referencia_pago = '2025000114'
;

select estado
from sl_pcp_encabezado 
where nro_referencia_pago =   '2025000114'
;

update --select * from
   sl_pcp_encabezado 
   set estado='PAG'
  where nro_referencia_pago =   '2025000113'
  ;

commit;

--Consulta acta
select * from 
 ogt_documento
 where tipo = 'ALE'
  -- and estado = 'AP'
   and unte_codigo = 'FINANCIERO'
   and numero_externo in ( '2025000112') 
   and extract(year from fecha) in ( 2025 );

update  ogt_documento
set estado = 'RE'
 where tipo = 'ALE'
   and estado = 'AP'
   and unte_codigo = 'FINANCIERO'
   and numero_externo in ( '2025000112') 
   and extract(year from fecha) in ( 2025 );  

COMMIT;

declare
   mi_estado              sl_pcp_encabezado.estado%type;
   mi_nuevo_estado        sl_pcp_encabezado.estado%type;
   mi_nro_referencia_pago sl_pcp_encabezado.nro_referencia_pago%type := '2025000114';
   num_registros          number;
   mi_mensaje             varchar2(2000);
   mi_procesado           boolean;
begin
   dbms_output.put_line('>>>>>>> Iniciando prueba imputación acta '|| current_timestamp|| ' >>>>>');

   select estado
     into mi_estado
     from sl_pcp_encabezado
    where nro_referencia_pago = mi_nro_referencia_pago;

   dbms_output.put_line('llamando pr_proceso_imputacion');
   --/*
   pk_ogt_imputacion.pr_procesar_imputacion(
      p_nro_referencia_pago => mi_nro_referencia_pago,
      p_usuario             => 'IUSER',
      p_resp                => mi_mensaje,
      p_procesado           => mi_procesado
   );
   --*/
   if mi_procesado = true then
      dbms_output.put_line('Fin normal del proceso de imputación: ' || mi_mensaje);
   else
      dbms_output.put_line('Revise mensaje ' || mi_mensaje);
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
   dbms_output.put_line('<<<<< Fin prueba Imputación '|| current_timestamp  || ' <<<<<<< ');
                        --
   --spool off                        
exception
   when others then
      dbms_output.put_line('Error prueba: ' || sqlerrm);
end;
/

select * from tab_lch_segui   
where fecha >= '24/dec/2025'
order by consec desc   
;


select * from   
 ogt_ingreso 
 where doc_numero|| '-'||doc_tipo 
  in (  select distinct doc_numero ||'-'|| doc_tipo
        from ogt_detalle_documento
        where doc_numero in (54758,55525,55526))
        ;