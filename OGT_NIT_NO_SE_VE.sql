P_BINTABLAS.REGISTRARITEM('OGT_DETALLE_GIROS.TIPO_IDENT', 'GENERAL', 'IDENTIFICACION', TO_CHAR(SYSDATE,'DD/MM/YYYY'), 1);

pk_ogt_terceros.fn_id_identificacion(:ogt_detalle_giros.tipo_ident,
		 	                                                            :OGT_DETALLE_GIROS.dcto,
		 	                                                            SYSDATE,
		 	                                                            un_error);


  

  FUNCTION FN_ID_IDENTIFICACION (un_tipo_identificacion VARCHAR2
                            ,una_identificacion     VARCHAR2
                                ,una_fecha DATE DEFAULT SYSDATE
                              ,un_error  OUT VARCHAR2) RETURN pk_ogt_terceros.cur_terceros IS

    mi_trc_cur_terceros         pk_sit_infbasica.cur_terceros;
    mi_tabla_pl                 pk_ogt_terceros.cur_terceros;
    mi_cur_terceros_type        pk_ogt_terceros.cur_terceros_type;

  BEGIN
    mi_contador:=1;
    un_error:='0';
    mi_trc_cur_terceros:= pk_sit_infbasica.sit_fn_id_identificacion(un_tipo_identificacion, una_identificacion, una_fecha);



pk_sit_infbasica.sit_fn_id_identificacion(un_tipo_identificacion, una_identificacion, una_fecha);
  FUNCTION SIT_FN_ID_IDENTIFICACION (un_tipo_identificacion VARCHAR2, una_identificacion VARCHAR2, una_fecha DATE) RETURN cur_terceros IS

  mi_cursor_terceros    cur_terceros;

  BEGIN
    OPEN mi_cursor_terceros FOR
      SELECT shd_informacion_basica.id,shd_terceros.tro_compuesto,
             RTRIM(RTRIM(ib_primer_nombre) || ' ' || RTRIM(ib_segundo_nombre) || ' ' ||
             RTRIM(ib_primer_apellido) || ' ' || RTRIM(ib_segundo_apellido)) AS nombre, shd_informacion_basica.ib_fecha_final,shd_informacion_basica.ib_fecha_final
      FROM shd_informacion_basica, shd_terceros
      WHERE shd_informacion_basica.ib_tipo_identificacion   = 'NIT' /*un_tipo_identificacion*/ AND
            shd_informacion_basica.ib_codigo_identificacion = '830053700' /*una_identificacion*/ AND
		        shd_informacion_basica.id = shd_terceros.id AND
		        shd_informacion_basica.ib_fecha_inicial<=SYSDATE /*una_fecha*/ AND
           (shd_informacion_basica.ib_fecha_final>=SYSDATE /*una_fecha*/ OR shd_informacion_basica.ib_fecha_final IS Null);
    RETURN mi_cursor_terceros;
  END SIT_FN_ID_IDENTIFICACION;