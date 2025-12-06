CREATE OR REPLACE PROCEDURE pr_legalizar_financiero (
  p_nro_referencia_pago sl_pcp_pago.nro_referencia_pago%type,
  p_resp                out varchar2,
  p_procesado           out boolean
) IS

  id_transaccion PLS_INTEGER :=0;
  mi_numero_acta ogt_documento.numero%TYPE;
  mi_msg Varchar2(500);
  mi_tipo_acta ogt_documento.tipo%TYPE := 'ALE';
  mi_usuario VARCHAR2(30);

  CURSOR c_ingreso IS 
    select id, ing_id from   
    ogt_ingreso --where num_doc_legalizacion = 55502
    where doc_numero ||'-' || doc_tipo in (  
      select distinct doc_numero|| '-'|| doc_tipo
        from ogt_detalle_documento 
        where doc_numero||'-'|| doc_tipo in (
          select  numero||'-'|| tipo
            from ogt_documento
          where numero_legal = mi_numero_acta
            and tipo = 'XYZ'
      )
          and doc_tipo = 'XYZ'
          and estado = 'RE'
    );
     
begin
  p_resp := p_resp || chr(10)||' Inicio proceso legalización financiero, para ref.pago: ' || p_nro_referencia_pago || '.';
  p_procesado := TRUE;
  mi_usuario := user;
  begin
    --Obtengo el número de acta
    select numero
    into mi_numero_acta
    from ogt_documento
    where tipo = mi_tipo_acta  --'ALE'
      and estado = 'RE'
      and unte_codigo = 'FINANCIERO'
      and numero_externo = p_nro_referencia_pago;
  exception
    when no_data_found then
      p_resp := p_resp || chr(10) || 'No existe el acta para legalizar de la referencia de pago: ' || p_nro_referencia_pago || '.';
      p_procesado := FALSE;
    when too_many_rows then
      p_resp := p_resp || chr(10) || 'Hay más de un acta para la referencia de pago' || p_nro_referencia_pago || '.';
      p_procesado := FALSE;  
  end;    
    
  if p_procesado = TRUE then
  
    -- Legalizar los ingresos seleccionados
    for mi_ingreso IN c_ingreso  loop
      id_transaccion := ogt_pk_ingreso.ogt_fn_Legalizar(mi_ingreso.id);
      if id_transaccion = 0 then
          rollback;
          p_resp := p_resp  || chr(10) ||'No se legalizó. Verifique ingreso '||mi_ingreso.id||', legalización abortada.';
          p_procesado := FALSE;
          exit;
      else
          p_resp := p_resp  || chr(10) ||' Se legalizó ingreso : '||mi_ingreso.id||'. ';
      end if;            
    end loop;
    if p_procesado = TRUE THEN
      For r_sis in (select dd.numero_sisla, d1.fecha_soporte, d1.fecha, dd.valor --Numero_sisla, FECHA_SOPORTE, FECHA, VALOR
                    from ogt_detalle_documento dd, ogt_documento d1
                    where dd.DOC_NUMERO = d1.NUMERO
                    and dd.DOC_TIPO = d1.TIPO
                    and numero_legal = mi_numero_acta
                      and tipo = 'XYZ'
                    and numero_sisla is not null
                    and TER_ID_ORIGEN is not null) Loop 
        PK_SL_INTERFAZ_OPGET_CP.pr_actualiza_interfaz_opget_cp(
          r_sis.Numero_Sisla,   --Número de la cuenta de cobro           
          r_sis.VALOR,          --Valor del pago      
          r_sis.FECHA_SOPORTE,  --Fecha de consignación   
          r_sis.FECHA,          --Fecha de legalización
          mi_numero_acta,       -- Número Acta legalización
          7,                    -- Correspondiente a la fase RECAUDO
          USER,                 -- Usuario quien realizo la transacción
          mi_msg);
          if mi_msg <> 'Proceso termino satisfactoriamente' Then
            p_resp := p_resp || chr(10) || 'No se actualizo la interfaz: ' ||p_nro_referencia_pago||'. '||mi_msg; 
            p_procesado := FALSE;
            exit;
          end if;
      end Loop;
    end if;
    update ogt_documento
      set estado='AP',usuario_reviso=mi_usuario
    where numero=mi_numero_acta
      and tipo=mi_tipo_acta;
    COMMIT;
  end if; --if p_procesado = TRUE THEN
    
exception
  when OTHERS then
    rollback;
    p_resp := p_resp || chr(10) || '. Proceso detenido, informar: '||sqlerrm;
    p_procesado := FALSE;
end pr_legalizar_financiero 
 ;  

