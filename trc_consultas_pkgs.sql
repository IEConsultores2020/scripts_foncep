declare
    miident PK_TRC_TYPES.TRC_Identificacion_TYPE;
begin    

	miident := pk_trc_consulta.Fn_InfTerc(
			    UnTipoIdentificacion    => 'NIT'	,
			    UnCodigoIdentificacion  => '890903938',
                UnaFecha                => SYSDATE
	) ;
    
   dbms_output.put_line(' id:'|| miident.miid);

end;        

grant execute on trc.pk_trc_types to siteto;
grant execute on trc.pk_trc_consulta to siteto;