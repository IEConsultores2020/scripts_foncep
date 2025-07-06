PROCEDURE PR_LLENAR_TABLA_ANEXOS(una_compania         VARCHAR2,
                                 una_vigencia         NUMBER,
                                 una_unidad_ejecutora VARCHAR2,
                                 un_nro_ra            NUMBER,
                                 un_tipo_ra           VARCHAR2,
                                 un_grupo_ra          VARCHAR2,
                                 un_tipo_nomina       NUMBER,
                                 una_fecha_inicial    DATE,
                                 una_fecha_final      DATE,
                                 un_mes               NUMBER,
                                 mi_Tbl_AN_Ogt        OUT pk_ogt_bd_crear_ra.antab,
                                 mi_Tbl_AE_Ogt        OUT pk_ogt_bd_crear_ra.aetab,
                                 mi_Tbl_AP_Ogt        OUT pk_ogt_bd_crear_ra.aptab,
                                 mi_err               OUT NUMBER) IS

  CURSOR cur_anexos IS
    SELECT a.codigo,
           a.descripcion,
           a.tabla_detalle,
           c.tipo_ra_ogt,
           c.codigo_opget
      FROM rh_lm_centros_costo a, rh_lm_ra_cc b, rh_lm_ra_cc_ogt c
     WHERE a.codigo = b.cc
       AND b.ra = c.ra
       AND b.transaccion = c.transaccion
       AND b.cc = c.cc
       AND b.ra = un_tipo_ra
       AND c.grupo_ra = un_grupo_ra;

  CURSOR cur_nxp(un_nro_ra NUMBER) IS
    SELECT nfuncionario, SUM(valor) valor
      FROM rh_t_lm_valores a, rh_lm_cuenta b
     WHERE b.stipo_funcionario = a.stipofuncionario
       AND b.sconcepto = a.sconcepto
       AND a.periodo = una_fecha_final
       AND a.ntipo_nomina = un_tipo_nomina
       AND a.sdevengado IN (0, 1)
       AND a.nro_ra = un_nro_ra
       AND b.scompania = una_compania
       AND b.tipo_ra = un_tipo_ra
       AND b.grupo_ra IN (un_grupo_ra)
       AND b.ncierre = 1
          -- RQ2523-2005   05/12/2005
       AND b.dfecha_inicio_vig <= una_fecha_final
       AND (b.dfecha_final_vig >= una_fecha_final OR
           b.dfecha_final_vig IS NULL)
    -- Fin RQ2523
     Having Sum(valor) <> 0
     GROUP BY nfuncionario;

  CURSOR cur_embargos(un_cc NUMBER, un_nro_ra NUMBER) IS
    SELECT a.stercero, a.nfuncionario, a.sdescuento, SUM(valor) valor
      FROM rh_t_lm_valores a, rh_lm_cuenta b, rh_lm_centros_costo c
     WHERE b.stipo_funcionario = a.stipofuncionario
       AND b.sconcepto = a.sconcepto
       AND b.cc = c.codigo
       AND a.periodo = una_fecha_final
       AND a.ntipo_nomina = un_tipo_nomina
       AND a.sdevengado IN (0, 1)
       AND a.nro_ra = un_nro_ra
       AND b.scompania = una_compania
       AND b.tipo_ra = un_tipo_ra
       AND b.grupo_ra IN (un_grupo_ra)
       AND b.ncierre = 1
          -- RQ2523-2005   05/12/2005
       AND b.dfecha_inicio_vig <= una_fecha_final
       AND (b.dfecha_final_vig >= una_fecha_final OR
           b.dfecha_final_vig IS NULL)
          -- Fin RQ2523  
       AND b.cc = un_cc
     GROUP BY stercero, a.nfuncionario, a.sdescuento;

  mi_id_Tbl_AN_Ogt          BINARY_INTEGER := 0;
  mi_id_Tbl_AE_Ogt          BINARY_INTEGER := 0;
  mi_id_Tbl_AP_Ogt          BINARY_INTEGER := 0;
  mi_cc                     rh_lm_centros_costo.codigo%TYPE := NULL;
  mi_cc_opget               rh_lm_ra_cc_ogt.codigo_opget%TYPE := NULL;
  mi_descripcion_cc         VARCHAR2(100);
  mi_tabla_detalle          VARCHAR2(100);
  mi_tabla                  VARCHAR2(100);
  mi_funcionario            rh_t_lm_valores.nfuncionario%TYPE;
  mi_valor                  rh_t_lm_valores.valor%TYPE := 0;
  mi_funcionario_type       pk_detalle_anexos_ra.funcionario_type;
  mi_embargo_type           pk_detalle_anexos_ra.embargo_type;
  mi_demandante_type        pk_detalle_anexos_ra.demandante_type;
  mi_persona_type           pk_detalle_anexos_ra.personas_type;
  mi_entidad_type           pk_detalle_anexos_ra.entidad_type;
  mi_beneficiario_type      pk_detalle_anexos_ra.beneficiarios_type;
  mi_tercero                rh_t_lm_valores.stercero%TYPE;
  mi_id_tercero             NUMBER;
  mi_sdescuento             rh_t_lm_valores.sdescuento%TYPE;
  mi_cursor                 EXEC_SQL.CURSTYPE;
  nIgn                      PLS_INTEGER; --Variable para manejar el cursor dinámico
  mi_consulta               VARCHAR2(2000) := NULL;
  mi_concepto               rh_t_lm_valores.sconcepto%TYPE;
  mi_valor_saldo            rh_t_lm_valores.valor_saldo%TYPE;
  mi_incapacidad            rh_t_lm_valores.valor%TYPE;
  mi_saldo                  rh_t_lm_valores.valor%TYPE;
  mi_concepto_inc           rh_t_lm_valores.sconcepto%TYPE;
  mi_concepto_entidad_benef rh_t_lm_valores.sconcepto%TYPE;
  mi_concepto_saldos        rh_t_lm_valores.sconcepto%TYPE;
  mi_id_ogt                 NUMBER := 0;
  mi_tipo_cuenta_emb        VARCHAR2(30);
  mi_numero_cuenta_emb      VARCHAR2(30);
  mi_banco_emb              VARCHAR2(30);
  mi_forma_pago_emb         VARCHAR2(30);
  mi_autoliq                BOOLEAN := TRUE;
  mi_tipo_ra_ogt            VARCHAR2(30);
  mi_err_prov_ogt           VARCHAR2(300);
  mi_id_error               text_io.file_type;
  mi_nombre_archivo_err     VARCHAR2(500);
  mi_directorio_carga       VARCHAR2(500);
  mi_pagina_carga           VARCHAR2(500);
  mi_sqlcode                NUMBER;
  mi_terceros_neg           NUMBER := 0;

  -- RQ1718-2006         24/10/2006
  mi_tipo_entidad VARCHAR2(150);
  -- Fin RQ1718-2006  

BEGIN
  mi_err := 0;
  --Validar que los conceptos de saldos a favor o en contra o incapacidades en la autoliquidación
  --no tengan marcado centro de costo
  mi_autoliq := pk_detalle_anexos_ra.fn_validar_cc_salud_arp(una_compania,
                                                             una_fecha_final,
                                                             mi_err);
  IF mi_err = 1 THEN
    RETURN;
  END IF;
  IF mi_autoliq THEN
    pr_despliega_mensaje('AL_STOP_1',
                         'Existen conceptos de autoliquidación para incapacidades o saldos a favor o en contra asociados a un centro de costo.');
    mi_err := 1;
    RETURN;
  END IF;
  mi_directorio_carga := p_bintablas.tbuscar('DIRECTORIO_PAGINA_CARGA',
                                             'NOMINA',
                                             'PATH',
                                             TO_CHAR(SYSDATE, 'dd/mm/yyyy'));
  IF mi_directorio_carga IS NULL THEN
    pr_despliega_mensaje('AL_STOP_1',
                         'No se encuentra definido el parámetro DIRECTORIO_PAGINA_CARGA.  Por favor revise.');
    RETURN;
  END IF;
  mi_pagina_carga := p_bintablas.tbuscar('WWW_PAGINA_CARGA',
                                         'NOMINA',
                                         'PATH',
                                         TO_CHAR(SYSDATE, 'dd/mm/yyyy'));
  IF mi_pagina_carga IS NULL THEN
    pr_despliega_mensaje('AL_STOP_1',
                         'No se encuentra definido el parámetro WWW_PAGINA_CARGA.  Por favor revise.');
    RETURN;
  END IF;
  --Para abrir el archivo que genera listado de terceros con pagos negativos
  mi_nombre_archivo_err := 'TERCEROS_NEGATIVOS.TXT';
  BEGIN
    IF GET_APPLICATION_PROPERTY(USER_INTERFACE) = 'WEB' THEN
      If GET_APPLICATION_PROPERTY(OPERATING_SYSTEM) like '%WIN%' THEN
        mi_id_error := text_io.fopen(mi_directorio_carga || '\' ||
                                     mi_nombre_archivo_err,
                                     'w');
      Else
        mi_id_error := text_io.fopen(mi_directorio_carga || '/' ||
                                     mi_nombre_archivo_err,
                                     'w');
      End If;
    ELSE
      mi_id_error := text_io.fopen('C:\' || mi_nombre_archivo_err, 'w');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      mi_sqlcode := SQLCODE;
      IF mi_sqlcode = -302000 then
        LOOP
          EXIT WHEN TOOL_ERR.NERRORS = 0;
          message(TO_CHAR(TOOL_ERR.CODE) || ': ' || TOOL_ERR.MESSAGE);
          TOOL_ERR.POP;
        END LOOP;
      END IF;
      pr_despliega_mensaje('AL_STOP_1',
                           'Ocurrió un error ' || SQLERRM() || ' ' ||
                           SQLCODE());
      mi_err := 1;
      RETURN;
  END;
  text_io.put_line(mi_id_error, 'Terceros con pagos negativos');
  OPEN cur_anexos;
  LOOP
    FETCH cur_anexos
      INTO mi_cc,
           mi_descripcion_cc,
           mi_tabla_detalle,
           mi_tipo_ra_ogt,
           mi_cc_opget;
    EXIT WHEN cur_anexos%NOTFOUND;
    IF UPPER(mi_descripcion_cc) LIKE '%NOMINA%' THEN
      OPEN cur_nxp(un_nro_ra);
      LOOP
        FETCH cur_nxp
          INTO mi_funcionario, mi_valor;
        EXIT WHEN cur_nxp%NOTFOUND;
        mi_persona_type := pk_detalle_anexos_ra.fn_detalle_personas(mi_funcionario,
                                                                    mi_err);
        IF mi_err = 1 THEN
          pr_despliega_mensaje('AL_STOP_1',
                               'Ocurrió un error al recuperar información de personas: ' ||
                               mi_funcionario);
          RETURN;
        END IF;
        mi_funcionario_type := pk_detalle_anexos_ra.fn_detalle_funcionario(mi_funcionario,
                                                                           mi_err);
        IF mi_err = 1 THEN
          pr_despliega_mensaje('AL_STOP_1',
                               'Ocurrió un error al recuperar información de funcionarios :' ||
                               mi_funcionario);
          RETURN;
        END IF;
        IF mi_funcionario_type.mi_forma_pago IS NULL THEN
          pr_despliega_mensaje('AL_STOP_1',
                               'No se ha registrado la forma de pago para el funcionario ' ||
                               mi_funcionario);
          mi_err := 1;
          RETURN;
        END IF;
        mi_id_tercero := fn_asociar_tercero_ra(mi_tabla_detalle,
                                               NULL,
                                               mi_funcionario,
                                               mi_err);
        IF mi_err <> 0 THEN
          pr_despliega_mensaje('AL_STOP_1',
                               'Ocurrió un error al asociar el tercero para ' ||
                               mi_tabla_detalle || ' y ' || mi_funcionario);
          RETURN;
        END IF;
        --Verifica si el tercero existe en OPGET
        mi_id_ogt := pk_ogt_bd_crear_ra.fn_existe_proveedor(mi_id_tercero);
        -- Inicio famanjarres: Se modifica provisionalmente por interfaz con PREDIS
        mi_id_ogt := pk_ogt_bd_crear_ra.fn_existe_proveedor(mi_id_tercero,
                                                            SYSDATE);
        --Si no existe lo crea en OPGET
        IF mi_id_ogt = 0 THEN
          mi_err_prov_ogt := pk_ogt_bd_crear_ra.fn_crea_proveedor(mi_id_tercero,
                                                                  mi_persona_type.mi_tipo_doc,
                                                                  mi_persona_type.mi_nro_doc,
                                                                  mi_persona_type.mi_nombre,
                                                                  NULL, --segundo nombre
                                                                  mi_persona_type.mi_primer_apellido,
                                                                  mi_persona_type.mi_segundo_apellido,
                                                                  mi_funcionario_type.mi_forma_pago,
                                                                  mi_funcionario_type.mi_banco,
                                                                  mi_funcionario_type.mi_tipo_cuenta,
                                                                  mi_funcionario_type.mi_numero_cuenta);
          IF mi_err_prov_ogt <> '0' THEN
            pr_despliega_mensaje('AL_STOP_1',
                                 'Error al crear en OPGET el tercero ' ||
                                 mi_id_tercero || ' ' || mi_err_prov_ogt);
            mi_err := 1;
            RETURN;
          END IF;
        ELSIF mi_id_ogt <> mi_id_tercero THEN
          pr_actualiza_rh_terceros(mi_id_tercero, mi_id_ogt, mi_err);
          IF mi_err = 1 THEN
            pr_despliega_mensaje('AL_STOP_1',
                                 'Ocurrió un error al actualizar el id de Tercero para ' ||
                                 mi_id_tercero);
            RETURN;
          END IF;
          mi_id_tercero := mi_id_ogt;
        END IF;
        IF un_tipo_ra = '1' THEN
          mi_id_Tbl_AN_Ogt := mi_id_Tbl_AN_Ogt + 1;
          mi_Tbl_AN_Ogt(mi_id_Tbl_AN_Ogt).mi_tipo_pagar_a := mi_persona_type.mi_tipo_doc;
          mi_Tbl_AN_Ogt(mi_id_Tbl_AN_Ogt).mi_nro_pagar_a := mi_persona_type.mi_nro_doc;
          mi_Tbl_AN_Ogt(mi_id_Tbl_AN_Ogt).mi_numero_cuenta := mi_funcionario_type.mi_numero_cuenta;
          mi_Tbl_AN_Ogt(mi_id_Tbl_AN_Ogt).mi_sucursal := NULL;
          mi_Tbl_AN_Ogt(mi_id_Tbl_AN_Ogt).mi_banco := mi_funcionario_type.mi_banco;
          mi_Tbl_AN_Ogt(mi_id_Tbl_AN_Ogt).mi_tipo_cuenta := mi_funcionario_type.mi_tipo_cuenta;
          mi_Tbl_AN_Ogt(mi_id_Tbl_AN_Ogt).mi_aporte_empleado := mi_valor;
          mi_Tbl_AN_Ogt(mi_id_Tbl_AN_Ogt).mi_forma_pago := mi_funcionario_type.mi_forma_pago;
          mi_Tbl_AN_Ogt(mi_id_Tbl_AN_Ogt).mi_codigo_centro_costos := mi_cc_opget;
          --Cesantias pagadas en la nómina
        ELSE
          mi_id_Tbl_AP_Ogt := mi_id_Tbl_AP_Ogt + 1;
          mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_tipo_pagar_a := mi_persona_type.mi_tipo_doc;
          mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_nro_pagar_a := mi_persona_type.mi_nro_doc;
          mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_tipo_id := mi_persona_type.mi_tipo_doc;
          mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_nro_id := mi_persona_type.mi_nro_doc;
          mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_aporte_patronal := mi_valor;
          mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_aporte_empleado := 0;
          mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_forma_pago := mi_funcionario_type.mi_forma_pago;
          mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_saldo := 0;
          mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_incapacidad := 0;
          mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_numero_cuenta := mi_funcionario_type.mi_numero_cuenta;
          mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_sucursal := NULL;
          mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_banco := mi_funcionario_type.mi_banco;
          mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_tipo_cuenta := mi_funcionario_type.mi_tipo_cuenta;
          mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_codigo_centro_costos := mi_cc_opget;
        END IF;
        IF mi_valor < 0 THEN
          text_io.put_line(mi_id_error,
                           'Funcionario con pago negativo.  Cédula: ' ||
                           mi_persona_type.mi_nro_doc || '. Valor: ' ||
                           mi_valor);
          text_io.put_line(mi_id_error,
                           'en la Relación de autorización ' || un_nro_ra);
          mi_terceros_neg := mi_terceros_neg + 1;
        END IF;
      END LOOP;
      CLOSE cur_nxp;
      -- Ini RQ2010-129-51
    ELSIF UPPER(mi_descripcion_cc) LIKE '%CESANTIAS%' AND un_tipo_ra = 3 THEN
      -- Se establece la conexión
      mi_cursor := EXEC_SQL.Open_Cursor(EXEC_SQL.DEFAULT_CONNECTION);
      -- Se construye la sentencia de la consulta
      mi_consulta := 'SELECT a.nfuncionario, SUM(valor) valor
                          FROM rh_t_lm_valores a, rh_lm_cuenta b, rh_lm_centros_costo c
                         WHERE b.stipo_funcionario =  a.stipofuncionario
                           AND b.sconcepto         =  a.sconcepto
                           AND b.cc                =  c.codigo
                           AND TRUNC(a.periodo)    =  TO_DATE(''' ||
                     TO_CHAR(una_fecha_final, 'DD-MM-YYYY') ||
                     ''',''DD-MM-YYYY'')' || '
                           AND a.ntipo_nomina      =  ' ||
                     un_tipo_nomina || '
                           AND a.nro_ra            =  ' ||
                     un_nro_ra || '
                           AND b.scompania         =  ' ||
                     CHR(39) || una_compania || CHR(39) || '
                           AND b.tipo_ra           =  ' ||
                     CHR(39) || un_tipo_ra || CHR(39) || '
                           AND b.grupo_ra          IN (' ||
                     CHR(39) || un_grupo_ra || CHR(39) || ')
                           AND b.ncierre           =  1 
                           AND valor <> 0
                           AND b.dfecha_inicio_vig <= TO_DATE(''' ||
                     TO_CHAR(una_fecha_final, 'DD-MM-YYYY') ||
                     ''',''DD-MM-YYYY'') 
                           AND (b.dfecha_final_vig >= TO_DATE(''' ||
                     TO_CHAR(una_fecha_final, 'DD-MM-YYYY') ||
                     ''',''DD-MM-YYYY'') OR b.dfecha_final_vig IS NULL) 
                           AND b.cc                =  ' ||
                     mi_cc || '
                          GROUP BY a.nfuncionario';
    
      -- Se construye dinámicamente el cursor
      EXEC_SQL.PARSE(EXEC_SQL.DEFAULT_CONNECTION,
                     mi_cursor,
                     mi_consulta,
                     exec_sql.V7);
      -- Se definen las columnas en donde se almacenaran los resultados
      EXEC_SQL.DEFINE_COLUMN(EXEC_SQL.DEFAULT_CONNECTION,
                             mi_cursor,
                             1,
                             mi_funcionario);
      EXEC_SQL.DEFINE_COLUMN(EXEC_SQL.DEFAULT_CONNECTION,
                             mi_cursor,
                             2,
                             mi_valor);
      -- Se ejecuta el cursor
      nIgn := EXEC_SQL.EXECUTE(EXEC_SQL.DEFAULT_CONNECTION, mi_cursor);
      WHILE EXEC_SQL.FETCH_ROWS(EXEC_SQL.DEFAULT_CONNECTION, mi_cursor) > 0 LOOP
        EXEC_SQL.COLUMN_VALUE(EXEC_SQL.DEFAULT_CONNECTION,
                              mi_cursor,
                              1,
                              mi_funcionario);
        EXEC_SQL.COLUMN_VALUE(EXEC_SQL.DEFAULT_CONNECTION,
                              mi_cursor,
                              2,
                              mi_valor);
        mi_persona_type := pk_detalle_anexos_ra.fn_detalle_personas(mi_funcionario,
                                                                    mi_err);
        IF mi_err = 1 THEN
          pr_despliega_mensaje('AL_STOP_1',
                               'Ocurrió un error al recuperar información de personas: ' ||
                               mi_funcionario);
          RETURN;
        END IF;
        mi_funcionario_type := pk_detalle_anexos_ra.fn_detalle_funcionario(mi_funcionario,
                                                                           mi_err);
        IF mi_err = 1 THEN
          pr_despliega_mensaje('AL_STOP_1',
                               'Ocurrió un error al recuperar información de funcionarios :' ||
                               mi_funcionario);
          RETURN;
        END IF;
        IF mi_funcionario_type.mi_forma_pago IS NULL THEN
          pr_despliega_mensaje('AL_STOP_1',
                               'No se ha registrado la forma de pago para el funcionario ' ||
                               mi_funcionario);
          mi_err := 1;
          RETURN;
        END IF;
        mi_id_tercero := fn_asociar_tercero_ra(mi_tabla_detalle,
                                               NULL,
                                               mi_funcionario,
                                               mi_err);
        IF mi_err <> 0 THEN
          pr_despliega_mensaje('AL_STOP_1',
                               'Ocurrió un error al asociar el tercero para ' ||
                               mi_tabla_detalle || ' y ' || mi_funcionario);
          RETURN;
        END IF;
        --Verifica si el tercero existe en OPGET
        -- Inicio famanjarres: Se modifica provisionalmente por interfaz con PREDIS
        mi_id_ogt := pk_ogt_bd_crear_ra.fn_existe_proveedor(mi_id_tercero,
                                                            SYSDATE);
      
        --Si no existe lo crea en OPGET
        IF mi_id_ogt = 0 THEN
          mi_err_prov_ogt := pk_ogt_bd_crear_ra.fn_crea_proveedor(mi_id_tercero,
                                                                  mi_persona_type.mi_tipo_doc,
                                                                  mi_persona_type.mi_nro_doc,
                                                                  mi_persona_type.mi_nombre,
                                                                  NULL, --segundo nombre
                                                                  mi_persona_type.mi_primer_apellido,
                                                                  mi_persona_type.mi_segundo_apellido,
                                                                  mi_funcionario_type.mi_forma_pago,
                                                                  mi_funcionario_type.mi_banco,
                                                                  mi_funcionario_type.mi_tipo_cuenta,
                                                                  mi_funcionario_type.mi_numero_cuenta);
          IF mi_err_prov_ogt <> '0' THEN
            pr_despliega_mensaje('AL_STOP_1',
                                 'Error al crear en OPGET el tercero ' ||
                                 mi_id_tercero || ' ' || mi_err_prov_ogt);
            mi_err := 1;
            RETURN;
          END IF;
        ELSIF mi_id_ogt <> mi_id_tercero THEN
          pr_actualiza_rh_terceros(mi_id_tercero, mi_id_ogt, mi_err);
          IF mi_err = 1 THEN
            pr_despliega_mensaje('AL_STOP_1',
                                 'Ocurrió un error al actualizar el id de Tercero para ' ||
                                 mi_id_tercero);
            RETURN;
          END IF;
          mi_id_tercero := mi_id_ogt;
        END IF;
        mi_id_Tbl_AP_Ogt := mi_id_Tbl_AP_Ogt + 1;
        mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_tipo_pagar_a := mi_persona_type.mi_tipo_doc;
        mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_nro_pagar_a := mi_persona_type.mi_nro_doc;
        mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_tipo_id := mi_persona_type.mi_tipo_doc;
        mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_nro_id := mi_persona_type.mi_nro_doc;
        mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_aporte_patronal := mi_valor;
        mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_aporte_empleado := 0;
        mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_forma_pago := mi_funcionario_type.mi_forma_pago;
        mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_saldo := 0;
        mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_incapacidad := 0;
        mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_numero_cuenta := mi_funcionario_type.mi_numero_cuenta;
        mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_sucursal := NULL;
        mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_banco := mi_funcionario_type.mi_banco;
        mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_tipo_cuenta := mi_funcionario_type.mi_tipo_cuenta;
        mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_codigo_centro_costos := mi_cc_opget;
        IF mi_valor < 0 THEN
          text_io.put_line(mi_id_error,
                           'Funcionario con pago negativo.  Cédula: ' ||
                           mi_persona_type.mi_nro_doc || '. Valor: ' ||
                           mi_valor);
          text_io.put_line(mi_id_error,
                           'en la Relación de autorización ' || un_nro_ra);
          mi_terceros_neg := mi_terceros_neg + 1;
        END IF;
      END LOOP;
    ELSIF UPPER(mi_descripcion_cc) LIKE '%EMBARGO%' THEN
      OPEN cur_embargos(mi_cc, un_nro_ra);
      LOOP
        FETCH cur_embargos
          INTO mi_tercero, mi_funcionario, mi_sdescuento, mi_valor;
        EXIT WHEN cur_embargos%NOTFOUND;
        mi_embargo_type := pk_detalle_anexos_ra.fn_detalle_embargos(mi_tercero,
                                                                    mi_funcionario,
                                                                    mi_sdescuento,
                                                                    mi_err);
        IF mi_err = 1 THEN
          pr_despliega_mensaje('AL_STOP_1',
                               'Ocurrió un error al recuperar información de embargos del funcionario ' ||
                               mi_funcionario);
          RETURN;
        END IF;
        IF mi_embargo_type.mi_tipo_doc_benef_pago IS NULL OR
           mi_embargo_type.mi_nro_doc_benef_pago IS NULL THEN
          pr_despliega_mensaje('AL_STOP_1',
                               'No se encuentra registrado el beneficiario del pago para el embargo del funcionario ' ||
                               mi_funcionario);
          mi_err := 1;
          RETURN;
        END IF;
        IF mi_embargo_type.mi_forma_pago IS NULL THEN
          pr_despliega_mensaje('AL_STOP_1',
                               'No se encuentra registrada la forma de pago para el embargo del funcionario ' ||
                               mi_funcionario);
          mi_err := 1;
          RETURN;
        END IF;
        mi_demandante_type := pk_detalle_anexos_ra.fn_detalle_demandante(mi_tercero,
                                                                         mi_funcionario,
                                                                         mi_sdescuento,
                                                                         mi_err);
        IF mi_err = 1 THEN
          pr_despliega_mensaje('AL_STOP_1',
                               'Ocurrió un error al recuperar información de embargos del funcionario ' ||
                               mi_funcionario);
          RETURN;
        END IF;
        IF mi_demandante_type.mi_nombre_ddte IS NULL THEN
          pr_despliega_mensaje('AL_STOP_1',
                               'No se encuentra registrado el nombre del demandante para el embargo del funcionario ' ||
                               mi_funcionario);
          mi_err := 1;
          RETURN;
        END IF;
        mi_persona_type := pk_detalle_anexos_ra.fn_detalle_personas(mi_funcionario,
                                                                    mi_err);
        IF mi_err = 1 THEN
          pr_despliega_mensaje('AL_STOP_1',
                               'Ocurrió un error al recuperar información de personas: ' ||
                               mi_funcionario);
          RETURN;
        END IF;
        mi_beneficiario_type := pk_detalle_anexos_ra.fn_detalle_beneficiarios(TO_NUMBER(mi_tercero),
                                                                              mi_err);
        IF mi_err = 1 THEN
          pr_despliega_mensaje('AL_STOP_1',
                               'Ocurrió un error al recuperar información de beneficiarios ' ||
                               mi_tercero);
          RETURN;
        END IF;
        mi_valor := mi_valor * (-1);
        mi_id_Tbl_AE_Ogt := mi_id_Tbl_AE_Ogt + 1;
        mi_Tbl_AE_Ogt(mi_id_Tbl_AE_Ogt).mi_tipo_pagar_a := mi_embargo_type.mi_tipo_doc_benef_pago;
        mi_Tbl_AE_Ogt(mi_id_Tbl_AE_Ogt).mi_nro_pagar_a := mi_embargo_type.mi_nro_doc_benef_pago;
      
        mi_Tbl_AE_Ogt(mi_id_Tbl_AE_Ogt).mi_tipo_juzgado := mi_beneficiario_type.mi_tipo_doc; -- Quien imparte la orden de Embargo
        mi_Tbl_AE_Ogt(mi_id_Tbl_AE_Ogt).mi_nro_juzgado := mi_beneficiario_type.mi_nro_doc; -- Quien imparte la orden de Embargo
      
        * / mi_Tbl_AE_Ogt(mi_id_Tbl_AE_Ogt).mi_tipo_id_embargado := mi_demandante_type.mi_tipo_doc_ddte;
        mi_Tbl_AE_Ogt(mi_id_Tbl_AE_Ogt).mi_nro_id_embargado := mi_demandante_type.mi_nro_doc_ddte;
        mi_Tbl_AE_Ogt(mi_id_Tbl_AE_Ogt).mi_tipo_id := mi_persona_type.mi_tipo_doc;
        mi_Tbl_AE_Ogt(mi_id_Tbl_AE_Ogt).mi_nro_id := mi_persona_type.mi_nro_doc;
        -- Fin RQ1556-2006               
        -- RQ371-2008    09-01-2009
        -- mi_Tbl_AE_Ogt(mi_id_Tbl_AE_Ogt).mi_numero_oficio:=mi_embargo_type.mi_nro_oficio;
        mi_Tbl_AE_Ogt(mi_id_Tbl_AE_Ogt).mi_numero_oficio := mi_embargo_type.mi_nro_proceso;
        -- Fin RQ371-2008    09-01-2009
        mi_Tbl_AE_Ogt(mi_id_Tbl_AE_Ogt).mi_oficina_origen := NULL;
        mi_Tbl_AE_Ogt(mi_id_Tbl_AE_Ogt).mi_oficina_destino := NULL;
        mi_Tbl_AE_Ogt(mi_id_Tbl_AE_Ogt).mi_aporte_embargo := mi_valor;
        mi_Tbl_AE_Ogt(mi_id_Tbl_AE_Ogt).mi_forma_pago := mi_embargo_type.mi_forma_pago;
        mi_Tbl_AE_Ogt(mi_id_Tbl_AE_Ogt).mi_fuera_ciudad := NULL;
        mi_Tbl_AE_Ogt(mi_id_Tbl_AE_Ogt).mi_numero_cuenta := mi_embargo_type.mi_numero_cuenta;
        mi_Tbl_AE_Ogt(mi_id_Tbl_AE_Ogt).mi_sucursal := NULL;
        mi_Tbl_AE_Ogt(mi_id_Tbl_AE_Ogt).mi_banco := mi_embargo_type.mi_banco;
        mi_Tbl_AE_Ogt(mi_id_Tbl_AE_Ogt).mi_tipo_cuenta := mi_embargo_type.mi_tipo_cuenta;
        mi_Tbl_AE_Ogt(mi_id_Tbl_AE_Ogt).mi_concepto := mi_embargo_type.mi_concepto;
        mi_Tbl_AE_Ogt(mi_id_Tbl_AE_Ogt).mi_nombre_embargante := mi_demandante_type.mi_nombre_ddte;
        mi_Tbl_AE_Ogt(mi_id_Tbl_AE_Ogt).mi_codigo_centro_costos := mi_cc_opget;
        --Busca el id del Tercero beneficiario del pago
        mi_id_tercero := fn_asociar_tercero_ra('DESCUENTOS',
                                               NULL,
                                               mi_embargo_type.mi_cod_benef_pago,
                                               mi_err);
        IF mi_err <> 0 THEN
          pr_despliega_mensaje('AL_STOP_1',
                               'Ocurrió un error al asociar el tercero para EMBARGOS del funcionario ' ||
                               mi_funcionario);
          RETURN;
        END IF;
        --Verifica si el tercero existe en OPGET
      
        -- Inicio famanjarres: Se modifica provisionalmente por interfaz con PREDIS
        mi_id_ogt := pk_ogt_bd_crear_ra.fn_existe_proveedor(mi_id_tercero,
                                                            SYSDATE);
      
        --             mi_id_ogt:=pk_ogt_bd_crear_ra.fn_existe_proveedor(mi_id_tercero);
        -- FIN famanjarres
        -- Fin RQ1650-2008   SIS-MJ-2009-161
        -- Fin RQ266-2009
      
        IF mi_id_ogt = 0 THEN
          --Si no existe lo crea en OPGET
          IF mi_embargo_type.mi_forma_pago = 'B' THEN
            --Crea el juzgado con forma de pago Cheque
            mi_forma_pago_emb    := 'C';
            mi_banco_emb         := NULL;
            mi_tipo_cuenta_emb   := NULL;
            mi_numero_cuenta_emb := NULL;
          ELSE
            --El beneficiario del pago es el demandante    
            mi_forma_pago_emb    := mi_embargo_type.mi_forma_pago;
            mi_banco_emb         := mi_embargo_type.mi_banco;
            mi_tipo_cuenta_emb   := mi_embargo_type.mi_tipo_cuenta;
            mi_numero_cuenta_emb := mi_embargo_type.mi_numero_cuenta;
          END IF;
          mi_err_prov_ogt := pk_ogt_bd_crear_ra.fn_crea_proveedor(mi_id_tercero,
                                                                  mi_embargo_type.mi_tipo_doc_benef_pago,
                                                                  mi_embargo_type.mi_nro_doc_benef_pago,
                                                                  mi_embargo_type.mi_nombre,
                                                                  NULL, --segundo nombre
                                                                  NULL, --primer apellido
                                                                  NULL, --segundo apellido
                                                                  mi_forma_pago_emb,
                                                                  mi_banco_emb,
                                                                  mi_tipo_cuenta_emb,
                                                                  mi_numero_cuenta_emb);
          IF mi_err_prov_ogt <> '0' THEN
            pr_despliega_mensaje('AL_STOP_1',
                                 'Error al crear en OPGET el tercero EMBARGOS ' ||
                                 mi_id_tercero || ' ' || mi_err_prov_ogt);
            mi_err := 1;
            RETURN;
          END IF;
        ELSIF mi_id_ogt <> mi_id_tercero THEN
          pr_actualiza_rh_terceros(mi_id_tercero, mi_id_ogt, mi_err);
          IF mi_err = 1 THEN
            pr_despliega_mensaje('AL_STOP_1',
                                 'Ocurrió un error al actualizar el id de Tercero para ' ||
                                 mi_id_tercero);
            RETURN;
          END IF;
          mi_id_tercero := mi_id_ogt;
        END IF;
        --Asocia el id del funcionario (embargado)
        mi_id_tercero := fn_asociar_tercero_ra('PERSONAS',
                                               NULL,
                                               mi_funcionario,
                                               mi_err);
        IF mi_err <> 0 THEN
          pr_despliega_mensaje('AL_STOP_1',
                               'Ocurrió un error al asociar el tercero para el funcionario ' ||
                               mi_funcionario);
          mi_err := 1;
          RETURN;
        END IF;
        --Busca el id del Demandate
        mi_id_tercero := fn_asociar_tercero_ra('DESCUENTOS',
                                               NULL,
                                               mi_demandante_type.mi_cod_ddte,
                                               mi_err);
        IF mi_err <> 0 THEN
          pr_despliega_mensaje('AL_STOP_1',
                               'Ocurrió un error al asociar el tercero del demandante para EMBARGOS del funcionario ' ||
                               mi_funcionario);
          RETURN;
        END IF;
        --Verifica si el tercero existe en OPGET
        -- Inicio famanjarres: Se modifica provisionalmente por interfaz con PREDIS
        /*
                     mi_id_ogt:=pk_ogt_bd_crear_ra.fn_existe_proveedor(mi_id_tercero,SYSDATE);
        */
        mi_id_ogt := pk_ogt_bd_crear_ra.fn_existe_proveedor(mi_id_tercero);
        -- FIN famnjarres
        -- Fin RQ1650-2008   SIS-MJ-2009-161
        -- Fin RQ266-2009
      
        --Si no existe lo crea en OPGET
        IF mi_id_ogt = 0 THEN
          mi_err_prov_ogt := pk_ogt_bd_crear_ra.fn_crea_proveedor(mi_id_tercero,
                                                                  mi_demandante_type.mi_tipo_doc_ddte,
                                                                  mi_demandante_type.mi_nro_doc_ddte,
                                                                  mi_demandante_type.mi_nombre_ddte,
                                                                  NULL, --segundo nombre
                                                                  NULL, --primer apellido
                                                                  NULL, --segundo apellido
                                                                  mi_embargo_type.mi_forma_pago,
                                                                  mi_embargo_type.mi_banco,
                                                                  mi_embargo_type.mi_tipo_cuenta,
                                                                  mi_embargo_type.mi_numero_cuenta);
          IF mi_err_prov_ogt <> '0' THEN
            pr_despliega_mensaje('AL_STOP_1',
                                 'Error al crear en OPGET el tercero EMBARGOS ' ||
                                 mi_id_tercero || ' ' || mi_err_prov_ogt);
            mi_err := 1;
            RETURN;
          END IF;
        ELSIF mi_id_ogt <> mi_id_tercero THEN
          pr_actualiza_rh_terceros(mi_id_tercero, mi_id_ogt, mi_err);
          IF mi_err = 1 THEN
            pr_despliega_mensaje('AL_STOP_1',
                                 'Ocurrió un error al actualizar el id de Tercero para ' ||
                                 mi_id_tercero);
            RETURN;
          END IF;
          mi_id_tercero := mi_id_ogt;
        END IF;
      END LOOP;
      CLOSE cur_embargos;
    ELSE
      -- Se establece la conexión
      mi_cursor := EXEC_SQL.Open_Cursor(EXEC_SQL.DEFAULT_CONNECTION);
      -- Se construye la sentencia de la consulta
      mi_consulta := 'SELECT  ';
      IF mi_tabla_detalle LIKE '%NOMBRE%' OR
         mi_tabla_detalle = 'ENTIDAD_BENEFICIARIOS' THEN
        mi_consulta := mi_consulta || 'a.sconcepto, ';
      END IF;
      mi_consulta := mi_consulta ||
                     ' a.stercero, SUM(valor) valor, SUM(valor_saldo) valor_saldo
                      FROM     rh_t_lm_valores a, rh_lm_cuenta b, rh_lm_centros_costo c
                      WHERE    b.stipo_funcionario =  a.stipofuncionario
                      AND      b.sconcepto         =  a.sconcepto
                      AND      b.cc                =  c.codigo
                      AND      (valor <> 0
                      OR       valor_saldo <> 0)
                      AND      trunc(a.periodo)    =  TO_DATE(''' ||
                     TO_CHAR(una_fecha_final, 'DD-MM-YYYY') ||
                     ''',''DD-MM-YYYY'')' || '
                      AND      a.ntipo_nomina      =  ' ||
                     un_tipo_nomina || '
                      AND      a.sdevengado    ';
      IF un_tipo_ra = '1' THEN
        mi_consulta := mi_consulta || 'IN (0,1) ';
      ELSE
        mi_consulta := mi_consulta || 'NOT IN (0,1) ';
      END IF;
      mi_consulta := mi_consulta ||
                     '               
                      AND   a.nro_ra            = ' ||
                     un_nro_ra || '
                      AND   b.scompania         =  ' ||
                     CHR(39) || una_compania || CHR(39) || '
                      AND   b.tipo_ra           =  ' ||
                     CHR(39) || un_tipo_ra || CHR(39) || '
                      AND   b.grupo_ra          IN (' ||
                     CHR(39) || un_grupo_ra || CHR(39) || ')
                      AND   b.ncierre           =  1
                      -- RQ2523-2005   05/12/2005
                      AND   b.dfecha_inicio_vig <= TO_DATE(''' ||
                     TO_CHAR(una_fecha_final, 'DD-MM-YYYY') ||
                     ''',''DD-MM-YYYY'') 
                      AND  (b.dfecha_final_vig  >= TO_DATE(''' ||
                     TO_CHAR(una_fecha_final, 'DD-MM-YYYY') ||
                     ''',''DD-MM-YYYY'') OR b.dfecha_final_vig IS NULL) 
                      -- Fin RQ2523
                      AND      b.cc                =  ' ||
                     mi_cc;
        IF mi_tabla_detalle LIKE '%NOMBRE%' OR
            mi_tabla_detalle = 'ENTIDAD_BENEFICIARIOS' THEN
            mi_consulta := mi_consulta || ' GROUP BY a.sconcepto, a.stercero';
        ELSE
            mi_consulta := mi_consulta || ' GROUP BY a.stercero';
        END IF;
      -- Se construye dinámicamente el cursor
      EXEC_SQL.PARSE(EXEC_SQL.DEFAULT_CONNECTION,
                     mi_cursor,
                     mi_consulta,
                     exec_sql.V7);
      -- Se definen las columnas en donde se almacenaran los resultados
      IF mi_tabla_detalle LIKE '%NOMBRE%' OR
         mi_tabla_detalle = 'ENTIDAD_BENEFICIARIOS' THEN
        EXEC_SQL.DEFINE_COLUMN(EXEC_SQL.DEFAULT_CONNECTION,
                               mi_cursor,
                               1,
                               mi_concepto,
                               30);
        EXEC_SQL.DEFINE_COLUMN(EXEC_SQL.DEFAULT_CONNECTION,
                               mi_cursor,
                               2,
                               mi_tercero,
                               30);
        EXEC_SQL.DEFINE_COLUMN(EXEC_SQL.DEFAULT_CONNECTION,
                               mi_cursor,
                               3,
                               mi_valor);
        EXEC_SQL.DEFINE_COLUMN(EXEC_SQL.DEFAULT_CONNECTION,
                               mi_cursor,
                               4,
                               mi_valor_saldo);
      ELSE
        EXEC_SQL.DEFINE_COLUMN(EXEC_SQL.DEFAULT_CONNECTION,
                               mi_cursor,
                               1,
                               mi_tercero,
                               30);
        EXEC_SQL.DEFINE_COLUMN(EXEC_SQL.DEFAULT_CONNECTION,
                               mi_cursor,
                               2,
                               mi_valor);
        EXEC_SQL.DEFINE_COLUMN(EXEC_SQL.DEFAULT_CONNECTION,
                               mi_cursor,
                               3,
                               mi_valor_saldo);
      END IF;
      -- Se ejecuta el cursor
      nIgn := EXEC_SQL.EXECUTE(EXEC_SQL.DEFAULT_CONNECTION, mi_cursor);
      WHILE EXEC_SQL.FETCH_ROWS(EXEC_SQL.DEFAULT_CONNECTION, mi_cursor) > 0 LOOP
        IF mi_tabla_detalle LIKE '%NOMBRE%' OR
           mi_tabla_detalle = 'ENTIDAD_BENEFICIARIOS' THEN
          EXEC_SQL.COLUMN_VALUE(EXEC_SQL.DEFAULT_CONNECTION,
                                mi_cursor,
                                1,
                                mi_concepto);
          EXEC_SQL.COLUMN_VALUE(EXEC_SQL.DEFAULT_CONNECTION,
                                mi_cursor,
                                2,
                                mi_tercero);
          EXEC_SQL.COLUMN_VALUE(EXEC_SQL.DEFAULT_CONNECTION,
                                mi_cursor,
                                3,
                                mi_valor);
          EXEC_SQL.COLUMN_VALUE(EXEC_SQL.DEFAULT_CONNECTION,
                                mi_cursor,
                                4,
                                mi_valor_saldo);
        ELSE
          EXEC_SQL.COLUMN_VALUE(EXEC_SQL.DEFAULT_CONNECTION,
                                mi_cursor,
                                1,
                                mi_tercero);
          EXEC_SQL.COLUMN_VALUE(EXEC_SQL.DEFAULT_CONNECTION,
                                mi_cursor,
                                2,
                                mi_valor);
          EXEC_SQL.COLUMN_VALUE(EXEC_SQL.DEFAULT_CONNECTION,
                                mi_cursor,
                                3,
                                mi_valor_saldo);
        END IF;
        IF mi_tabla_detalle = 'ENTIDAD_BENEFICIARIOS' THEN
          --Pregunta si el concepto es descuento en la nómina por salud o fondo de garantia para tomar la información de 
          --rh_entidad o sino toma la información de rh_beneficiarios
          mi_concepto_entidad_benef := NULL;
          BEGIN
            SELECT stipo_funcionario
              INTO mi_concepto_entidad_benef
              FROM rh_lm_det_grp_funcionario
             WHERE scompania = una_compania
               AND sgtipo = 'DESCUENTO'
               AND stipo_funcionario = mi_concepto
               AND una_fecha_final BETWEEN dfecha_inicio_vig AND
                   dfecha_final_vig
               AND ncierre = 1;
          EXCEPTION
            WHEN no_data_found THEN
              mi_concepto_entidad_benef := NULL;
            WHEN OTHERS THEN
              pr_despliega_mensaje('AL_STOP_1',
                                   'Ocurrió un error al validar si el concepto ' ||
                                   mi_concepto ||
                                   ' se asocia a rh_entidad. ' ||
                                   SUBSTR(SQLERRM, 1, 120));
              mi_err := 1;
              RETURN;
          END;
          IF mi_concepto_entidad_benef IS NULL THEN
            mi_tabla := 'BENEFICIARIOS';
          ELSE
            mi_tabla := 'ENTIDAD';
          END IF;
          IF mi_tabla = 'ENTIDAD' THEN
            mi_tipo_entidad := p_bintablas.TBuscar(mi_descripcion_cc,
                                                   'NOMINA',
                                                   'CCOSTO_ENTIDAD',
                                                   TO_CHAR(SYSDATE,
                                                           'DD-MM-YYYY'));
            IF mi_tipo_entidad IS NULL THEN
              pr_despliega_mensaje('AL_STOP_1',
                                   'No encontró tipo entidad para el c. costo ' ||
                                   mi_descripcion_cc ||
                                   ' verifique CCOSTO_ENTIDAD en bintablas');
              RAISE Form_Trigger_Failure;
            END IF;
          
            mi_id_tercero := fn_asociar_tercero_ra(mi_tabla_detalle,
                                                   mi_tipo_entidad,
                                                   mi_tercero,
                                                   mi_err);
            IF mi_err <> 0 THEN
              pr_despliega_mensaje('AL_STOP_1',
                                   'Ocurrió un error al asociar el tercero para ' ||
                                   mi_descripcion_cc || ': ' || mi_tercero);
              mi_err := 1;
              RETURN;
            END IF;
          
            mi_entidad_type := pk_detalle_anexos_ra.fn_detalle_entidad(mi_tipo_entidad,
                                                                       mi_tercero,
                                                                       mi_err);
            IF mi_err = 1 THEN
              pr_despliega_mensaje('AL_STOP_1',
                                   'Ocurrió un error al recuperar información de entidades ' ||
                                   mi_tipo_entidad || ' ' || mi_tercero);
              RAISE Form_Trigger_Failure;
            END IF;
          
            IF mi_entidad_type.mi_forma_pago IS NULL THEN
              pr_despliega_mensaje('AL_STOP_1',
                                   'No se ha registrado la forma de pago para la entidad ' ||
                                   mi_tipo_entidad || ' ' ||
                                   mi_entidad_type.mi_nro_doc);
              RAISE Form_Trigger_Failure;
            END IF;
          
            --Verifica si el tercero existe en OPGET
          
            mi_id_ogt := pk_ogt_bd_crear_ra.fn_existe_proveedor(mi_id_tercero,
                                                                SYSDATE);
          
            --Si no existe lo crea en OPGET
            IF mi_id_ogt = 0 THEN
              mi_err_prov_ogt := pk_ogt_bd_crear_ra.fn_crea_proveedor(mi_id_tercero,
                                                                      mi_entidad_type.mi_tipo_doc,
                                                                      mi_entidad_type.mi_nro_doc,
                                                                      mi_entidad_type.mi_nombre,
                                                                      NULL, --segundo nombre
                                                                      NULL, --primer apellido
                                                                      NULL, --segundo apellido
                                                                      mi_entidad_type.mi_forma_pago,
                                                                      mi_entidad_type.mi_banco,
                                                                      mi_entidad_type.mi_tipo_cuenta,
                                                                      mi_entidad_type.mi_numero_cuenta);
              IF mi_err_prov_ogt <> '0' THEN
                pr_despliega_mensaje('AL_STOP_1',
                                     'Error al crear en OPGET el tercero ENTIDADES ' ||
                                     mi_id_tercero || ' ' ||
                                     mi_err_prov_ogt);
                mi_err := 1;
                RETURN;
              END IF;
            ELSIF mi_id_ogt <> mi_id_tercero THEN
              pr_actualiza_rh_terceros(mi_id_tercero, mi_id_ogt, mi_err);
              IF mi_err = 1 THEN
                pr_despliega_mensaje('AL_STOP_1',
                                     'Ocurrió un error al actualizar el id de Tercero para ' ||
                                     mi_id_tercero);
                RETURN;
              END IF;
              mi_id_tercero := mi_id_ogt;
            END IF;
            IF un_tipo_ra = '1' AND mi_valor < 0 THEN
              mi_valor := mi_valor * (-1);
            END IF;
            IF un_tipo_ra = '1' THEN
              mi_id_Tbl_AN_Ogt := mi_id_Tbl_AN_Ogt + 1;
              mi_Tbl_AN_Ogt(mi_id_Tbl_AN_Ogt).mi_tipo_pagar_a := mi_entidad_type.mi_tipo_doc;
              mi_Tbl_AN_Ogt(mi_id_Tbl_AN_Ogt).mi_nro_pagar_a := mi_entidad_type.mi_nro_doc;
              mi_Tbl_AN_Ogt(mi_id_Tbl_AN_Ogt).mi_numero_cuenta := mi_entidad_type.mi_numero_cuenta;
              mi_Tbl_AN_Ogt(mi_id_Tbl_AN_Ogt).mi_sucursal := NULL;
              mi_Tbl_AN_Ogt(mi_id_Tbl_AN_Ogt).mi_banco := mi_entidad_type.mi_banco;
              mi_Tbl_AN_Ogt(mi_id_Tbl_AN_Ogt).mi_tipo_cuenta := mi_entidad_type.mi_tipo_cuenta;
              mi_Tbl_AN_Ogt(mi_id_Tbl_AN_Ogt).mi_aporte_empleado := mi_valor;
              mi_Tbl_AN_Ogt(mi_id_Tbl_AN_Ogt).mi_forma_pago := mi_entidad_type.mi_forma_pago;
              mi_Tbl_AN_Ogt(mi_id_Tbl_AN_Ogt).mi_codigo_centro_costos := mi_cc_opget;
            ELSE
              mi_incapacidad := 0;
              mi_saldo       := 0;
              IF UPPER(mi_descripcion_cc) LIKE '%SALUD%' OR
                 UPPER(mi_descripcion_cc) LIKE '%ARP%' THEN
                IF UPPER(mi_descripcion_cc) LIKE '%SALUD%' THEN
                  -- RQ521-2009  13/05/2009
                  -- mi_concepto_inc   := 'INCAPACIDADES_AUTOL_SALUD';
                  mi_concepto_inc := 'INCAPACIDADES_SALUD';
                  -- Fin RQ521-2009  
                  mi_concepto_saldos := 'SALDOS_SALUD';
                ELSE
                  -- RQ521-2009  13/05/2009
                  -- mi_concepto_inc   :='INCAPACIDADES_AUTOL_ARP';
                  mi_concepto_inc := 'INCAPACIDADES_ARP';
                  -- Fin RQ521-2009  
                  mi_concepto_saldos := 'SALDOS_ARP';
                END IF;
                mi_incapacidad := pk_detalle_anexos_ra.fn_detalle_incapacidades(una_compania,
                                                                                mi_concepto_inc,
                                                                                un_tipo_nomina,
                                                                                mi_tercero,
                                                                                una_fecha_final,
                                                                                un_nro_ra,
                                                                                un_grupo_ra,
                                                                                mi_err);
                IF mi_err = 1 THEN
                  pr_despliega_mensaje('AL_STOP_1',
                                       'Ocurrió un error al recuperar información de incapacidades EPS ' ||
                                       mi_tercero);
                  RETURN;
                END IF;
                IF mi_incapacidad <> 0 THEN
                  --mi_valor:=mi_valor - mi_incapacidad;
                  mi_incapacidad := mi_incapacidad * (-1);
                END IF;
                mi_saldo := pk_detalle_anexos_ra.fn_detalle_saldos(una_compania,
                                                                   mi_concepto_saldos,
                                                                   un_tipo_nomina,
                                                                   mi_tercero,
                                                                   una_fecha_final,
                                                                   un_nro_ra,
                                                                   un_grupo_ra,
                                                                   mi_err);
                IF mi_err = 1 THEN
                  pr_despliega_mensaje('AL_STOP_1',
                                       'Ocurrió un error al recuperar información de saldos a favor o en contra de la EPS ' ||
                                       mi_tercero);
                  RETURN;
                END IF;
                IF mi_saldo <> 0 THEN
                  --mi_valor:=mi_valor - mi_saldo;
                  mi_saldo := mi_saldo * (-1);
                END IF;
              END IF;
              mi_id_Tbl_AP_Ogt := mi_id_Tbl_AP_Ogt + 1;
              mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_tipo_pagar_a := mi_entidad_type.mi_tipo_doc;
              mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_nro_pagar_a := mi_entidad_type.mi_nro_doc;
              mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_tipo_id := mi_entidad_type.mi_tipo_doc;
              mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_nro_id := mi_entidad_type.mi_nro_doc;
              mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_aporte_patronal := mi_valor;
              mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_aporte_empleado := NVL(mi_valor_saldo,
                                                                        0);
              mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_forma_pago := mi_entidad_type.mi_forma_pago;
              mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_saldo := mi_saldo;
              mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_incapacidad := mi_incapacidad;
              mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_numero_cuenta := mi_entidad_type.mi_numero_cuenta;
              mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_sucursal := NULL;
              mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_banco := mi_entidad_type.mi_banco;
              mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_tipo_cuenta := mi_entidad_type.mi_tipo_cuenta;
              mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_codigo_centro_costos := mi_cc_opget;
              --Puede ocurrir si la incapacidad es menor que el aporte por EPS                
              IF mi_valor < 0 THEN
                text_io.put_line(mi_id_error,
                                 'Entidad con pago negativo :' ||
                                 mi_entidad_type.mi_nro_doc || '. Valor:' ||
                                 mi_valor);
                text_io.put_line(mi_id_error,
                                 'en la Relación de autorización ' ||
                                 un_nro_ra);
                mi_terceros_neg := mi_terceros_neg + 1;
              END IF;
            END IF; --Si no es tipo 1
          ELSE
            --Si el concepto debe buscarse en beneficiarios
            mi_beneficiario_type := pk_detalle_anexos_ra.fn_detalle_beneficiarios(TO_NUMBER(mi_tercero),
                                                                                  mi_err);
            IF mi_err = 1 THEN
              pr_despliega_mensaje('AL_STOP_1',
                                   'Ocurrió un error al recuperar información de beneficiarios ' ||
                                   mi_tercero);
              RETURN;
            END IF;
            IF mi_beneficiario_type.mi_forma_pago IS NULL THEN
              pr_despliega_mensaje('AL_STOP_1',
                                   'No se ha registrado la forma de pago para el beneficiario ' ||
                                   mi_beneficiario_type.mi_nro_doc);
              mi_err := 1;
              RETURN;
            END IF;
            mi_id_tercero := fn_asociar_tercero_ra(mi_tabla,
                                                   NULL,
                                                   mi_tercero,
                                                   mi_err);
            IF mi_err <> 0 THEN
              pr_despliega_mensaje('AL_STOP_1',
                                   'Ocurrió un error al asociar el tercero para ' ||
                                   mi_descripcion_cc || ': ' || mi_tercero);
              mi_err := 1;
              RETURN;
            END IF;
            IF mi_valor < 0 THEN
              mi_valor := mi_valor * (-1);
            END IF;
            --Verifica si el tercero existe en OPGET
            mi_id_ogt := pk_ogt_bd_crear_ra.fn_existe_proveedor(mi_id_tercero,
                                                                SYSDATE);
          
            IF mi_id_ogt = 0 THEN
              mi_err_prov_ogt := pk_ogt_bd_crear_ra.fn_crea_proveedor(mi_id_tercero,
                                                                      mi_beneficiario_type.mi_tipo_doc,
                                                                      mi_beneficiario_type.mi_nro_doc,
                                                                      mi_beneficiario_type.mi_nombre,
                                                                      NULL, --segundo nombre
                                                                      NULL, --primer apellido
                                                                      NULL, --segundo apellido
                                                                      mi_beneficiario_type.mi_forma_pago,
                                                                      mi_beneficiario_type.mi_banco,
                                                                      mi_beneficiario_type.mi_tipo_cuenta,
                                                                      mi_beneficiario_type.mi_numero_cuenta);
              IF mi_err_prov_ogt <> '0' THEN
                pr_despliega_mensaje('AL_STOP_1',
                                     'Error al crear en OPGET el tercero BENEFICIARIOS ' ||
                                     mi_id_tercero || ' ' ||
                                     mi_err_prov_ogt);
                mi_err := 1;
                RETURN;
              END IF;
            ELSIF mi_id_ogt <> mi_id_tercero THEN
              pr_actualiza_rh_terceros(mi_id_tercero, mi_id_ogt, mi_err);
              IF mi_err = 1 THEN
                pr_despliega_mensaje('AL_STOP_1',
                                     'Ocurrió un error al actualizar el id de Tercero para ' ||
                                     mi_id_tercero);
                RETURN;
              END IF;
              mi_id_tercero := mi_id_ogt;
            END IF;
            IF un_tipo_ra = '1' THEN
              mi_id_Tbl_AN_Ogt := mi_id_Tbl_AN_Ogt + 1;
              mi_Tbl_AN_Ogt(mi_id_Tbl_AN_Ogt).mi_tipo_pagar_a := mi_beneficiario_type.mi_tipo_doc;
              mi_Tbl_AN_Ogt(mi_id_Tbl_AN_Ogt).mi_nro_pagar_a := mi_beneficiario_type.mi_nro_doc;
              mi_Tbl_AN_Ogt(mi_id_Tbl_AN_Ogt).mi_numero_cuenta := mi_beneficiario_type.mi_numero_cuenta;
              mi_Tbl_AN_Ogt(mi_id_Tbl_AN_Ogt).mi_sucursal := NULL;
              mi_Tbl_AN_Ogt(mi_id_Tbl_AN_Ogt).mi_banco := mi_beneficiario_type.mi_banco;
              mi_Tbl_AN_Ogt(mi_id_Tbl_AN_Ogt).mi_tipo_cuenta := mi_beneficiario_type.mi_tipo_cuenta;
              mi_Tbl_AN_Ogt(mi_id_Tbl_AN_Ogt).mi_aporte_empleado := mi_valor;
              mi_Tbl_AN_Ogt(mi_id_Tbl_AN_Ogt).mi_forma_pago := mi_beneficiario_type.mi_forma_pago;
              mi_Tbl_AN_Ogt(mi_id_Tbl_AN_Ogt).mi_codigo_centro_costos := mi_cc_opget;
            ELSE
              mi_id_Tbl_AP_Ogt := mi_id_Tbl_AP_Ogt + 1;
              mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_tipo_pagar_a := mi_beneficiario_type.mi_tipo_doc;
              mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_nro_pagar_a := mi_beneficiario_type.mi_nro_doc;
              mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_tipo_id := mi_beneficiario_type.mi_tipo_doc;
              mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_nro_id := mi_beneficiario_type.mi_nro_doc;
              mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_aporte_patronal := mi_valor;
              mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_aporte_empleado := NVL(mi_valor_saldo,
                                                                        0);
              mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_forma_pago := mi_beneficiario_type.mi_forma_pago;
              mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_saldo := '0';
              mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_incapacidad := '0';
              mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_numero_cuenta := mi_beneficiario_type.mi_numero_cuenta;
              mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_sucursal := NULL;
              mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_banco := mi_beneficiario_type.mi_banco;
              mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_tipo_cuenta := mi_beneficiario_type.mi_tipo_cuenta;
              mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_codigo_centro_costos := mi_cc_opget;
            END IF;
          END IF;
        ELSIF mi_tabla_detalle = 'ENTIDAD' THEN
        
          mi_tipo_entidad := p_bintablas.TBuscar(mi_descripcion_cc,
                                                 'NOMINA',
                                                 'CCOSTO_ENTIDAD',
                                                 TO_CHAR(SYSDATE,
                                                         'DD-MM-YYYY'));
          IF mi_tipo_entidad IS NULL THEN
            pr_despliega_mensaje('AL_STOP_1',
                                 'No encontró tipo entidad para el c. costo ' ||
                                 mi_descripcion_cc ||
                                 ' verifique CCOSTO_ENTIDAD en bintablas');
            RAISE Form_Trigger_Failure;
          END IF;
        
          -- RQ1650-2008  SIS-MJ-2009-192  23/04/2008
          mi_id_tercero := fn_asociar_tercero_ra(mi_tabla_detalle,
                                                 mi_tipo_entidad,
                                                 mi_tercero,
                                                 mi_err);
          IF mi_err <> 0 THEN
            pr_despliega_mensaje('AL_STOP_1',
                                 'Ocurrió un error al asociar el tercero para ' ||
                                 mi_descripcion_cc || ': ' || mi_tercero);
            mi_err := 1;
            RETURN;
          END IF;
          -- Fin RQ16501-2009               
        
          mi_entidad_type := pk_detalle_anexos_ra.fn_detalle_entidad(mi_tipo_entidad,
                                                                     mi_tercero,
                                                                     mi_err);
          IF mi_err = 1 THEN
            pr_despliega_mensaje('AL_STOP_1',
                                 'Ocurrió un error al recuperar información de entidades ' ||
                                 mi_tipo_entidad || ' ' || mi_tercero);
            RAISE Form_Trigger_Failure;
          END IF;
          -- FIN RQ1718-2006
          IF mi_entidad_type.mi_forma_pago IS NULL THEN
            pr_despliega_mensaje('AL_STOP_1',
                                 'No se ha registrado la forma de pago para la entidad ' ||
                                 mi_tipo_entidad || ' ' ||
                                 mi_entidad_type.mi_nro_doc);
            RAISE Form_Trigger_Failure;
          END IF;
        
          --Verifica si el tercero existe en OPGET
          -- RQ266-2009  27/03/2009
          -- RQ1650-2008   SIS-MJ-2009-161  03/04/2009
          --mi_id_ogt:=pk_ogt_bd_crear_ra.fn_existe_proveedor(mi_id_tercero);
          --mi_id_ogt:=pk_ogt_bd_crear_ra.fn_existe_proveedor(mi_id_tercero,una_fecha_final);
          -- Inicio famanjarres: Se modifica provisionalmente por interfaz con PREDIS
        
          mi_id_ogt := pk_ogt_bd_crear_ra.fn_existe_proveedor(mi_id_tercero,
                                                              SYSDATE);
        
          --              mi_id_ogt:=pk_ogt_bd_crear_ra.fn_existe_proveedor(mi_id_tercero);
          -- FIN famanjarres
          -- Fin RQ1650-2008   SIS-MJ-2009-161  
          -- Fin RQ266-2009
        
          --Si no existe lo crea en OPGET
          IF mi_id_ogt = 0 THEN
            mi_err_prov_ogt := pk_ogt_bd_crear_ra.fn_crea_proveedor(mi_id_tercero,
                                                                    mi_entidad_type.mi_tipo_doc,
                                                                    mi_entidad_type.mi_nro_doc,
                                                                    mi_entidad_type.mi_nombre,
                                                                    NULL, --segundo nombre
                                                                    NULL, --primer apellido
                                                                    NULL, --segundo apellido
                                                                    mi_entidad_type.mi_forma_pago,
                                                                    mi_entidad_type.mi_banco,
                                                                    mi_entidad_type.mi_tipo_cuenta,
                                                                    mi_entidad_type.mi_numero_cuenta);
            IF mi_err_prov_ogt <> '0' THEN
              pr_despliega_mensaje('AL_STOP_1',
                                   'Error al crear en OPGET el tercero ENTIDADES ' ||
                                   mi_id_tercero || ' ' || mi_err_prov_ogt);
              mi_err := 1;
              RETURN;
            END IF;
          ELSIF mi_id_ogt <> mi_id_tercero THEN
            pr_actualiza_rh_terceros(mi_id_tercero, mi_id_ogt, mi_err);
            IF mi_err = 1 THEN
              pr_despliega_mensaje('AL_STOP_1',
                                   'Ocurrió un error al actualizar el id de Tercero para ' ||
                                   mi_id_tercero);
              RETURN;
            END IF;
            mi_id_tercero := mi_id_ogt;
          END IF;
          IF un_tipo_ra = '1' AND mi_valor < 0 THEN
            mi_valor := mi_valor * (-1);
          END IF;
          IF un_tipo_ra = '1' THEN
            mi_id_Tbl_AN_Ogt := mi_id_Tbl_AN_Ogt + 1;
            mi_Tbl_AN_Ogt(mi_id_Tbl_AN_Ogt).mi_tipo_pagar_a := mi_entidad_type.mi_tipo_doc;
            mi_Tbl_AN_Ogt(mi_id_Tbl_AN_Ogt).mi_nro_pagar_a := mi_entidad_type.mi_nro_doc;
            mi_Tbl_AN_Ogt(mi_id_Tbl_AN_Ogt).mi_numero_cuenta := mi_entidad_type.mi_numero_cuenta;
            mi_Tbl_AN_Ogt(mi_id_Tbl_AN_Ogt).mi_sucursal := NULL;
            mi_Tbl_AN_Ogt(mi_id_Tbl_AN_Ogt).mi_banco := mi_entidad_type.mi_banco;
            mi_Tbl_AN_Ogt(mi_id_Tbl_AN_Ogt).mi_tipo_cuenta := mi_entidad_type.mi_tipo_cuenta;
            mi_Tbl_AN_Ogt(mi_id_Tbl_AN_Ogt).mi_aporte_empleado := mi_valor;
            mi_Tbl_AN_Ogt(mi_id_Tbl_AN_Ogt).mi_forma_pago := mi_entidad_type.mi_forma_pago;
            mi_Tbl_AN_Ogt(mi_id_Tbl_AN_Ogt).mi_codigo_centro_costos := mi_cc_opget;
          ELSE
            mi_incapacidad := 0;
            mi_saldo       := 0;
            IF UPPER(mi_descripcion_cc) LIKE '%SALUD%' OR
               UPPER(mi_descripcion_cc) LIKE '%ARP%' THEN
              IF UPPER(mi_descripcion_cc) LIKE '%SALUD%' THEN
                -- RQ521-2009  13/05/2009
                -- mi_concepto_inc   := 'INCAPACIDADES_AUTOL_SALUD';
                mi_concepto_inc := 'INCAPACIDADES_SALUD';
                -- Fin RQ521-2009
                mi_concepto_saldos := 'SALDOS_SALUD';
              ELSE
                -- RQ521-2009  13/05/2009
                -- mi_concepto_inc   :='INCAPACIDADES_AUTOL_ARP';
                mi_concepto_inc := 'INCAPACIDADES_ARP';
                -- Fin RQ521-2009
                mi_concepto_saldos := 'SALDOS_ARP';
              END IF;
              mi_incapacidad := pk_detalle_anexos_ra.fn_detalle_incapacidades(una_compania,
                                                                              mi_concepto_inc,
                                                                              un_tipo_nomina,
                                                                              mi_tercero,
                                                                              una_fecha_final,
                                                                              un_nro_ra,
                                                                              un_grupo_ra,
                                                                              mi_err);
              IF mi_err = 1 THEN
                pr_despliega_mensaje('AL_STOP_1',
                                     'Ocurrió un error al recuperar información de incapacidades EPS ' ||
                                     mi_tercero);
                RETURN;
              END IF;
              IF mi_incapacidad <> 0 THEN
                --mi_valor:=mi_valor - mi_incapacidad;
                mi_incapacidad := mi_incapacidad * (-1);
              END IF;
              mi_saldo := pk_detalle_anexos_ra.fn_detalle_saldos(una_compania,
                                                                 mi_concepto_saldos,
                                                                 un_tipo_nomina,
                                                                 mi_tercero,
                                                                 una_fecha_final,
                                                                 un_nro_ra,
                                                                 un_grupo_ra,
                                                                 mi_err);
              IF mi_err = 1 THEN
                pr_despliega_mensaje('AL_STOP_1',
                                     'Ocurrió un error al recuperar información de saldos a favor o en contra de la EPS ' ||
                                     mi_tercero);
                RETURN;
              END IF;
              IF mi_saldo <> 0 THEN
                --mi_valor:=mi_valor - mi_saldo;
                mi_saldo := mi_saldo * (-1);
              END IF;
            END IF;
            mi_id_Tbl_AP_Ogt := mi_id_Tbl_AP_Ogt + 1;
            mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_tipo_pagar_a := mi_entidad_type.mi_tipo_doc;
            mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_nro_pagar_a := mi_entidad_type.mi_nro_doc;
            mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_tipo_id := mi_entidad_type.mi_tipo_doc;
            mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_nro_id := mi_entidad_type.mi_nro_doc;
            mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_aporte_patronal := mi_valor;
            mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_aporte_empleado := NVL(mi_valor_saldo,
                                                                      0);
            mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_forma_pago := mi_entidad_type.mi_forma_pago;
            mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_saldo := mi_saldo;
            mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_incapacidad := mi_incapacidad;
            mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_numero_cuenta := mi_entidad_type.mi_numero_cuenta;
            mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_sucursal := NULL;
            mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_banco := mi_entidad_type.mi_banco;
            mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_tipo_cuenta := mi_entidad_type.mi_tipo_cuenta;
            mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_codigo_centro_costos := mi_cc_opget;
            --Puede ocurrir si la incapacidad es menor que el aporte por EPS                
            IF mi_valor < 0 THEN
              text_io.put_line(mi_id_error,
                               'Entidad con pago negativo :' ||
                               mi_entidad_type.mi_nro_doc || '. Valor:' ||
                               mi_valor);
              text_io.put_line(mi_id_error,
                               'en la Relación de autorización ' ||
                               un_nro_ra);
              mi_terceros_neg := mi_terceros_neg + 1;
            END IF;
          END IF; --Si no es tipo 1
        ELSIF mi_tabla_detalle LIKE '%BENEFICIARIOS%' THEN
          IF mi_tabla_detalle LIKE '%NOMBRE%' THEN
            mi_beneficiario_type := pk_detalle_anexos_ra.fn_detalle_beneficiarios(mi_concepto,
                                                                                  mi_err);
            IF mi_err = 1 THEN
              pr_despliega_mensaje('AL_STOP_1',
                                   'Ocurrió un error al recuperar información de beneficiarios');
              RETURN;
            END IF;
            mi_id_tercero := fn_asociar_tercero_ra('BENEFICIARIOS',
                                                   NULL,
                                                   mi_beneficiario_type.mi_codigo,
                                                   mi_err);
            IF mi_err <> 0 THEN
              pr_despliega_mensaje('AL_STOP_1',
                                   'Ocurrió un error al asociar el tercero para ' ||
                                   mi_descripcion_cc || ': ' || mi_tercero);
              mi_err := 1;
              RETURN;
            END IF;
          ELSE
            mi_beneficiario_type := pk_detalle_anexos_ra.fn_detalle_beneficiarios(TO_NUMBER(mi_tercero),
                                                                                  mi_err);
            IF mi_err = 1 THEN
              pr_despliega_mensaje('AL_STOP_1',
                                   'Ocurrió un error al recuperar información de beneficiarios ' ||
                                   mi_tercero);
              RETURN;
            END IF;
            mi_id_tercero := fn_asociar_tercero_ra('BENEFICIARIOS',
                                                   NULL,
                                                   mi_tercero,
                                                   mi_err);
            IF mi_err <> 0 THEN
              pr_despliega_mensaje('AL_STOP_1',
                                   'Ocurrió un error al asociar el tercero para ' ||
                                   mi_descripcion_cc || ': ' || mi_tercero);
              mi_err := 1;
              RETURN;
            END IF;
          END IF;
          IF mi_beneficiario_type.mi_forma_pago IS NULL THEN
            pr_despliega_mensaje('AL_STOP_1',
                                 'No se ha registrado la forma de pago para el beneficiario ' ||
                                 mi_beneficiario_type.mi_nro_doc);
            mi_err := 1;
            RETURN;
          END IF;
          IF mi_valor < 0 THEN
            mi_valor := mi_valor * (-1);
          END IF;
          --Verifica si el tercero existe en OPGET
          -- RQ266-2009  27/03/2009
          -- RQ1650-2008   SIS-MJ-2009-161  03/04/2009
          --mi_id_ogt:=pk_ogt_bd_crear_ra.fn_existe_proveedor(mi_id_tercero);
          --mi_id_ogt:=pk_ogt_bd_crear_ra.fn_existe_proveedor(mi_id_tercero,una_fecha_final);
          -- Inicio famanjarres: Se modifica provisionalmente por interfaz con PREDIS
        
          mi_id_ogt := pk_ogt_bd_crear_ra.fn_existe_proveedor(mi_id_tercero,
                                                              SYSDATE);
        
          --              mi_id_ogt:=pk_ogt_bd_crear_ra.fn_existe_proveedor(mi_id_tercero);
          -- FIN famanjarres
          -- Fin RQ1650-2008   SIS-MJ-2009-161  
          -- Fin RQ266-2009
          --Si no existe lo crea en OPGET
          IF mi_id_ogt = 0 THEN
            mi_err_prov_ogt := pk_ogt_bd_crear_ra.fn_crea_proveedor(mi_id_tercero,
                                                                    mi_beneficiario_type.mi_tipo_doc,
                                                                    mi_beneficiario_type.mi_nro_doc,
                                                                    mi_beneficiario_type.mi_nombre,
                                                                    NULL, --segundo nombre
                                                                    NULL, --primer apellido
                                                                    NULL, --segundo apellido
                                                                    mi_beneficiario_type.mi_forma_pago,
                                                                    mi_beneficiario_type.mi_banco,
                                                                    mi_beneficiario_type.mi_tipo_cuenta,
                                                                    mi_beneficiario_type.mi_numero_cuenta);
            IF mi_err_prov_ogt <> '0' THEN
              pr_despliega_mensaje('AL_STOP_1',
                                   'Error al crear en OPGET el tercero BENEFICIARIOS ' ||
                                   mi_id_tercero || ' ' || mi_err_prov_ogt);
              mi_err := 1;
              RETURN;
            END IF;
          ELSIF mi_id_ogt <> mi_id_tercero THEN
            pr_actualiza_rh_terceros(mi_id_tercero, mi_id_ogt, mi_err);
            IF mi_err = 1 THEN
              pr_despliega_mensaje('AL_STOP_1',
                                   'Ocurrió un error al actualizar el id de Tercero para ' ||
                                   mi_id_tercero);
              RETURN;
            END IF;
            mi_id_tercero := mi_id_ogt;
          END IF;
          IF un_tipo_ra = '1' THEN
            mi_id_Tbl_AN_Ogt := mi_id_Tbl_AN_Ogt + 1;
            mi_Tbl_AN_Ogt(mi_id_Tbl_AN_Ogt).mi_tipo_pagar_a := mi_beneficiario_type.mi_tipo_doc;
            mi_Tbl_AN_Ogt(mi_id_Tbl_AN_Ogt).mi_nro_pagar_a := mi_beneficiario_type.mi_nro_doc;
            mi_Tbl_AN_Ogt(mi_id_Tbl_AN_Ogt).mi_numero_cuenta := mi_beneficiario_type.mi_numero_cuenta;
            mi_Tbl_AN_Ogt(mi_id_Tbl_AN_Ogt).mi_sucursal := NULL;
            mi_Tbl_AN_Ogt(mi_id_Tbl_AN_Ogt).mi_banco := mi_beneficiario_type.mi_banco;
            mi_Tbl_AN_Ogt(mi_id_Tbl_AN_Ogt).mi_tipo_cuenta := mi_beneficiario_type.mi_tipo_cuenta;
            mi_Tbl_AN_Ogt(mi_id_Tbl_AN_Ogt).mi_aporte_empleado := mi_valor;
            mi_Tbl_AN_Ogt(mi_id_Tbl_AN_Ogt).mi_forma_pago := mi_beneficiario_type.mi_forma_pago;
            mi_Tbl_AN_Ogt(mi_id_Tbl_AN_Ogt).mi_codigo_centro_costos := mi_cc_opget;
          ELSE
            mi_id_Tbl_AP_Ogt := mi_id_Tbl_AP_Ogt + 1;
            mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_tipo_pagar_a := mi_beneficiario_type.mi_tipo_doc;
            mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_nro_pagar_a := mi_beneficiario_type.mi_nro_doc;
            mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_tipo_id := mi_beneficiario_type.mi_tipo_doc;
            mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_nro_id := mi_beneficiario_type.mi_nro_doc;
            mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_aporte_patronal := mi_valor;
            mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_aporte_empleado := NVL(mi_valor_saldo,
                                                                      0);
            mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_forma_pago := mi_beneficiario_type.mi_forma_pago;
            mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_saldo := '0';
            mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_incapacidad := '0';
            mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_numero_cuenta := mi_beneficiario_type.mi_numero_cuenta;
            mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_sucursal := NULL;
            mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_banco := mi_beneficiario_type.mi_banco;
            mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_tipo_cuenta := mi_beneficiario_type.mi_tipo_cuenta;
            mi_Tbl_AP_Ogt(mi_id_Tbl_AP_Ogt).mi_codigo_centro_costos := mi_cc_opget;
          END IF;
        END IF;
      END LOOP; --Anexos de aportes patronales
    END IF; --Nomina, embargos o aportes patronales
  END LOOP; --Termina de recorrer los centros de costo para el tipo de nómina
  CLOSE cur_anexos;
  IF mi_cc IS NULL THEN
    pr_despliega_mensaje('AL_STOP_1',
                         'No se han definido centros de costo para el tipo de RA.');
    mi_err := 1;
  END IF;
  IF mi_terceros_neg > 0 THEN
    text_io.fclose(mi_id_error);
    pr_despliega_mensaje('AL_STOP_1',
                         'Existen terceros con pagos negativos.  Será rechazada la RA en OPGET.');
    mi_err := 1;
    IF GET_APPLICATION_PROPERTY(USER_INTERFACE) = 'WEB' THEN
      web.show_document(mi_pagina_carga || '/' || mi_nombre_archivo_err,
                        '_BLANK');
    ELSE
      HOST('NOTEPAD.EXE ' || 'C:\' || mi_nombre_archivo_err);
    END IF;
  END IF;
  IF text_io.is_open(mi_id_error) THEN
    text_io.fclose(mi_id_error);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    mi_err := 1;
    pr_despliega_mensaje('AL_STOP_1',
                         'Ocurrió el error : ' || SUBSTR(SQLERRM, 1, 120) ||
                         ' al poblar las tablas de Anexos.');
END;
