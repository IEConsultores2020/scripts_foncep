declare 
mi_valor_op_ogt number ;
begin
    select OGT_PK_PREDIS.ogt_fn_valor_mes(:vigencia,
                                                        :codigo_compania,
                                                        :codigo_unidad_ejecutora,
                                                        TO_NUMBER(:p_mes),
                                                        :rubro_interno)
    
    from dual;

 dbms_output.put_line('mes '||:p_mes||' - valor: '||mi_valor_op_ogt);

    select OGT_PK_PREDIS.Ogt_Fn_Valor_aportes_Mes(:vigencia,
                                                    :codigo_compania,
                                                    :codigo_unidad_ejecutora,
                                                    TO_NUMBER(:p_mes),
                                                    :rubro_interno)
    --into mi_valor_op_ogt
    from dual;
                                                    
 dbms_output.put_line('valor_aportes_mes '||mi_valor_op_ogt);                                  
end;
