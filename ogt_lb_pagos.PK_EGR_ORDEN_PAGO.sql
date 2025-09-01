PACKAGE BODY PK_EGR_ORDEN_PAGO IS

  -- Metodo que crea una orden de pago.

  FUNCTION FN_OGT_BD_CREAR_ORDEN_PAGO(UN_TYPE_T_ORDEN_PAGO T_ORDEN_PAGO)
    RETURN VARCHAR2 IS
    MI_NUMERO_FILAS   NUMBER;
    MI_EXISTE_TERCERO BOOLEAN;
    MI_TRC_ERROR      VARCHAR2(200);
  BEGIN
  
    MI_NUMERO_FILAS := UN_TYPE_T_ORDEN_PAGO.COUNT;
  
    IF MI_NUMERO_FILAS = 0 THEN
      --PR_DESPLIEGA_MENSAJE('AL_STOP_1','Atencion : No existen registros para crea la orden de pago.');
      RETURN('Atencion : No existen registros para crea la orden de pago.');
    END IF;
  
    -- Validar que el tercero exista.
  
    MI_EXISTE_TERCERO := PK_OGT_TERCEROS.FN_EXISTE_ID(UN_TYPE_T_ORDEN_PAGO(1)
                                                      .MI_TER_ID,
                                                      MI_TRC_ERROR);
  
    IF NOT MI_EXISTE_TERCERO THEN
      --PR_DESPLIEGA_MENSAJE('AL_STOP_1','Atencion :  Tercero no existe, debe crearlo antes de continuar.');
      RETURN('Atencion :  Tercero no existe, debe crearlo antes de continuar.');
    END IF;
  
    -- Validar que la forma de pago sea A (Abono en Cuenta) o C (Cheque).
  
    IF UN_TYPE_T_ORDEN_PAGO(1).MI_FORMA_PAGO NOT IN ('A', 'C') THEN
      --PR_DESPLIEGA_MENSAJE('AL_STOP_1','Atencion :  Forma de pago invalida. Digite A (Abono en cuenta), C (Cheque).');
      RETURN('Atencion :  Forma de pago invalida. Digite A (Abono en cuenta), C (Cheque).');
    END IF;
  
    -- Si la forma de pago es 'A', verificar que venga el banco, el numero de cuenta y la
    -- clase de la cuenta.
  
    IF UN_TYPE_T_ORDEN_PAGO(1).MI_FORMA_PAGO = 'A' THEN
      IF UN_TYPE_T_ORDEN_PAGO(1).MI_BANCO IS NULL THEN
        --PR_DESPLIEGA_MENSAJE('AL_STOP_1','Atencion :  No se especifico banco para abono en cuenta.');
        RETURN('Atencion :  No se especifico banco para abono en cuenta.');
      ELSE
        MI_EXISTE_TERCERO := PK_OGT_TERCEROS.FN_EXISTE_ID(UN_TYPE_T_ORDEN_PAGO(1)
                                                          .MI_BANCO,
                                                          MI_TRC_ERROR);
        IF NOT MI_EXISTE_TERCERO THEN
          --PR_DESPLIEGA_MENSAJE('AL_STOP_1','Atencion :  Banco no existe, debe crearlo antes de continuar.');
          RETURN('Atencion :  Banco no existe, debe crearlo antes de continuar.');
        END IF;
      END IF;
      IF UN_TYPE_T_ORDEN_PAGO(1).MI_NUMERO_CUENTA IS NULL THEN
        --PR_DESPLIEGA_MENSAJE('AL_STOP_1','Atencion :  Numero de cuenta no especificado.');
        RETURN('Atencion :  Numero de cuenta no especificado.');
      END IF;
      IF UN_TYPE_T_ORDEN_PAGO(1).MI_CLASE IS NULL THEN
        --PR_DESPLIEGA_MENSAJE('AL_STOP_1','Atencion :  Clase de cuenta no especificado.');
        RETURN('Atencion :  Clase de cuenta no especificado.');
      END IF;
    END IF;
  
    -- Verificar que la vigencia sea 'V' Vigencia Actual, 'R' Reserva, 'C' Cuenta por Pagar
  
    --IF UN_TYPE_T_ORDEN_PAGO(1).MI_TIPO_VIGENCIA NOT IN ('V','R','C','RC') THEN
    IF UN_TYPE_T_ORDEN_PAGO(1).MI_TIPO_VIGENCIA NOT IN ('V', 'R', 'C') THEN
      --PR_DESPLIEGA_MENSAJE('AL_STOP_1','Atencion :  Tipo de vigencia invalido. Digite V (Vigencia Actual), R (Reserva), C (Cuenta por Pagar).');
      RETURN('Atencion :  Tipo de vigencia invalido. Digite V (Vigencia Actual), R (Reserva), C (Cuenta por Pagar).');
    END IF;
  
    -- Verificar que el indicativo de ejecutado sea 'P' Parcial o 'T' Total.
  
    IF UN_TYPE_T_ORDEN_PAGO(1).MI_DESCRIPCION_EJECUTADO NOT IN ('P', 'T') THEN
      --PR_DESPLIEGA_MENSAJE('AL_STOP_1','Atencion :  La ejecucion de la orden debe ser T (Total) o P (Parcial).');
      RETURN('Atencion :  La ejecucion de la orden debe ser T (Total) o P (Parcial).');
    END IF;
  
    -- Verificar que venga el indicativo de si la orden de pago es con situacion de fondos.
  
    IF UN_TYPE_T_ORDEN_PAGO(1).MI_SITUACION_FONDOS NOT IN ('S', 'N') THEN
      --PR_DESPLIEGA_MENSAJE('AL_STOP_1','Atencion :  Falta indicativo de situacion de fondos. Digite (S) o (N).');
      RETURN('Atencion :  Falta indicativo de situacion de fondos. Digite (S) o (N).');
    END IF;
  
    -- Verificar que el compromiso realmente exista.
  
    DECLARE
      TOTAL_ROWS          NUMBER := 0;
      MI_CURSOR_CONTRATOS PK_PRE_TESORERIA.CUR_CONTRATOS_BENEFICIARIO;
      MI_REG_CONTRATOS    PK_PRE_TESORERIA.TYPREC_CONTRATOS_BENEFICIARIO;
      TYPE R_COMPROMISOS IS RECORD(
        MI_TIPO_COMPROMISO   VARCHAR2(30),
        MI_NUMERO_COMPROMISO NUMBER(6));
      TYPE T_COMPROMISOS IS TABLE OF R_COMPROMISOS INDEX BY BINARY_INTEGER;
      TYPE_T_COMPROMISOS T_COMPROMISOS;
      MI_ENCONTRO        NUMBER;
    BEGIN
      NULL;
    END;
  
    -- Crear el documento de pago en la tabla ogt_documento_pago.
  
    IF MI_NUMERO_FILAS = 1 THEN
    
      -- Crear tercero, si ya existe no hay problema
    
      BEGIN
        INSERT INTO OGT_TERCERO VALUES (UN_TYPE_T_ORDEN_PAGO(1).MI_TER_ID);
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          NULL;
        WHEN OTHERS THEN
          RETURN('Atención : Error creando tercero.');
      END;
    
      BEGIN
        INSERT INTO OGT_DOCUMENTO_PAGO
          (VIGENCIA,
           ENTIDAD,
           UNIDAD_EJECUTORA,
           TIPO_DOCUMENTO,
           CONSECUTIVO,
           FECHA_DILIGENCIAMIENTO)
        VALUES
          (UN_TYPE_T_ORDEN_PAGO(1).MI_VIGENCIA,
           UN_TYPE_T_ORDEN_PAGO(1).MI_ENTIDAD,
           UN_TYPE_T_ORDEN_PAGO(1).MI_UNIDAD_EJECUTORA,
           'OP',
           UN_TYPE_T_ORDEN_PAGO(1).MI_CONSECUTIVO,
           TO_DATE(TO_CHAR(SYSDATE, 'DDMMYYHH24MISS'), 'DDMMYYHH24MISS'));
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          --PR_DESPLIEGA_MENSAJE('AL_STOP_1','Atencion :  Documento ya existe.');
          RETURN('Atencion :  Documento ya existe.');
        WHEN OTHERS THEN
          --PR_DESPLIEGA_MENSAJE('AL_STOP_1','Atencion : No se pudo crear documento de pago debido a que sucedio el siguiente error. '||SQLERRM);
          RETURN('Atencion : No se pudo crear documento de pago debido a que sucedio el siguiente error. ' ||
                 SQLERRM);
      END;
    
      -- Crear la orden de pago en la tabla ogt_orden_pago.
    
      --pr_despliega_mensaje('al_stop_1','sqlcode antes de insert de orden de pago....'||sqlcode);         
    
      -- 02-05-2003. Sergio.
      -- Actualizar el campo ENTIDAD_PRESUPUESTO.
    
      --IF SQLCODE = 0 THEN
      BEGIN
        INSERT INTO OGT_ORDEN_PAGO
          (VIGENCIA,
           ENTIDAD,
           UNIDAD_EJECUTORA,
           TIPO_DOCUMENTO,
           CONSECUTIVO,
           TIPO_OP,
           TER_ID,
           CODIGO_COMPROMISO,
           NUMERO_DE_COMPROMISO,
           TIPO_VIGENCIA,
           ESTADO,
           SITUACION_FONDOS,
           DETALLE,
           ORIGEN_FDL,
           DESCRIPCION_EJECUTADO,
           ACTA_DE_RECIBO,
           NOMBRE_INTERVENTOR,
           CODIGO_CONTABLE_NETO,
           CODIGO_CONTABLE_BRUTO,
           FORMA_PAGO,
           NUMERO_CUENTA,
           BANCO,
           CLASE,
           REGIMEN,
           OBSERVACIONES,
           ENTIDAD_PRESUPUESTO)
        VALUES
          (UN_TYPE_T_ORDEN_PAGO(1).MI_VIGENCIA,
           UN_TYPE_T_ORDEN_PAGO(1).MI_ENTIDAD,
           UN_TYPE_T_ORDEN_PAGO(1).MI_UNIDAD_EJECUTORA,
           'OP',
           UN_TYPE_T_ORDEN_PAGO(1).MI_CONSECUTIVO,
           1,
           UN_TYPE_T_ORDEN_PAGO(1).MI_TER_ID,
           UN_TYPE_T_ORDEN_PAGO(1).MI_CODIGO_COMPROMISO,
           UN_TYPE_T_ORDEN_PAGO(1).MI_NUMERO_DE_COMPROMISO,
           UN_TYPE_T_ORDEN_PAGO(1).MI_TIPO_VIGENCIA,
           '101000000',
           UN_TYPE_T_ORDEN_PAGO(1).MI_SITUACION_FONDOS,
           UN_TYPE_T_ORDEN_PAGO(1).MI_DETALLE,
           UN_TYPE_T_ORDEN_PAGO(1).MI_ORIGEN_FDL,
           UN_TYPE_T_ORDEN_PAGO(1).MI_DESCRIPCION_EJECUTADO,
           UN_TYPE_T_ORDEN_PAGO(1).MI_ACTA_DE_RECIBO,
           UN_TYPE_T_ORDEN_PAGO(1).MI_NOMBRE_INTERVENTOR,
           UN_TYPE_T_ORDEN_PAGO(1).MI_CODIGO_CONTABLE_NETO,
           UN_TYPE_T_ORDEN_PAGO(1).MI_CODIGO_CONTABLE_BRUTO,
           UN_TYPE_T_ORDEN_PAGO(1).MI_FORMA_PAGO,
           UN_TYPE_T_ORDEN_PAGO(1).MI_NUMERO_CUENTA,
           UN_TYPE_T_ORDEN_PAGO(1).MI_BANCO,
           UPPER(UN_TYPE_T_ORDEN_PAGO(1).MI_CLASE),
           UN_TYPE_T_ORDEN_PAGO(1).MI_REGIMEN,
           UN_TYPE_T_ORDEN_PAGO(1).MI_OBSERVACIONES,
           UN_TYPE_T_ORDEN_PAGO(1).MI_ENTIDAD);
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          --PR_DESPLIEGA_MENSAJE('AL_STOP_1','Atencion :  Orden de pago ya existe.');
          RETURN('Atencion :  Orden de pago ya existe.');
        WHEN OTHERS THEN
          --PR_DESPLIEGA_MENSAJE('AL_STOP_1','Atencion : No se pudo crear la orden de pago debido a que sucedio el siguiente error. '||SQLERRM);
          RETURN('Atencion : No se pudo crear la orden de pago debido a que sucedio el siguiente error. ' ||
                 SQLERRM);
      END;
      --END IF;
      RETURN('0');
    ELSIF MI_NUMERO_FILAS > 1 THEN
      --PR_DESPLIEGA_MENSAJE('AL_STOP_1','Atencion : No puede crear mas de una orden de pago al tiempo.');
      RETURN('Atencion : No puede crear mas de una orden de pago al tiempo.');
    ELSIF MI_NUMERO_FILAS < 1 THEN
      --PR_DESPLIEGA_MENSAJE('AL_STOP_1','Atencion : No existe orden de pago para crear.');
      RETURN('Atencion : No existe orden de pago para crear.');
    END IF;
  END FN_OGT_BD_CREAR_ORDEN_PAGO;

  -- Funcion usada para crear la imputacion presupuestal de la orden de pago.

  FUNCTION FN_OGT_BD_CREAR_PRESUPUESTO(UN_TYPE_T_PRESUPUESTO T_PRESUPUESTO)
    RETURN VARCHAR2 IS
    MI_NUMERO_FILAS NUMBER;
  BEGIN
    MI_NUMERO_FILAS := UN_TYPE_T_PRESUPUESTO.COUNT;
  
    IF MI_NUMERO_FILAS = 0 THEN
      --PR_DESPLIEGA_MENSAJE('AL_STOP_1','Atencion : No existen registros para crea la imputacion presupuestal.');
      RETURN('Atencion : No existen registros para crear la imputacion presupuestal.');
    END IF;
  
    -- Verificar que la informacion de PREDIS sea correcta.
  
    DECLARE
      TOTAL_ROWS    NUMBER := 0;
      CUR_REGISTROS PK_PRE_TESORERIA.cur_trae_rubros_rp_disponible;
      REG_REGISTROS PK_PRE_TESORERIA.TYPREC_RUBROS_RP_DISPONIBLE;
      TYPE R_REGISTROS_PREDIS IS RECORD(
        MI_NUMERO_REGISTRO       OGT_REGISTRO_PRESUPUESTAL.REGISTRO%TYPE,
        MI_NUMERO_DISPONIBILIDAD OGT_REGISTRO_PRESUPUESTAL.DISPONIBILIDAD%TYPE,
        MI_NUMERO_RUBRO_INTERNO  OGT_REGISTRO_PRESUPUESTAL.RUBRO_INTERNO%TYPE);
      TYPE T_REGISTROS_PREDIS IS TABLE OF R_REGISTROS_PREDIS INDEX BY BINARY_INTEGER;
      TYPE_T_REGISTROS_PREDIS T_REGISTROS_PREDIS;
      MI_ENCONTRO             NUMBER;
      MI_TOTAL_RP             NUMBER(20, 2) := 0;
      MI_TOTAL_PAGADO         NUMBER(20, 2) := 0;
      MI_TOTAL_DISPONIBLE     NUMBER(20, 2) := 0;
    BEGIN
      TYPE_T_REGISTROS_PREDIS.DELETE;
      TOTAL_ROWS := 0;
    
      CUR_REGISTROS := PK_PRE_TESORERIA.FN_PRE_TRAE_RUBROS_RP(TO_NUMBER(UN_TYPE_T_PRESUPUESTO(1)
                                                                        .MI_VIGENCIA),
                                                              UN_TYPE_T_PRESUPUESTO(1)
                                                              .MI_ENTIDAD,
                                                              UN_TYPE_T_PRESUPUESTO(1)
                                                              .MI_UNIDAD_EJECUTORA,
                                                              --REPLACE(RPAD(TO_CHAR(UN_TYPE_T_PRESUPUESTO(1).MI_CODIGO_COMPROMISO,'000'),30),' '),
                                                              TO_CHAR(UN_TYPE_T_PRESUPUESTO(1)
                                                                      .MI_CODIGO_COMPROMISO),
                                                              UN_TYPE_T_PRESUPUESTO(1)
                                                              .MI_NUMERO_DE_COMPROMISO);
      LOOP
        FETCH CUR_REGISTROS
          INTO REG_REGISTROS;
        EXIT WHEN CUR_REGISTROS%NOTFOUND;
        TOTAL_ROWS := TOTAL_ROWS + 1;
        TYPE_T_REGISTROS_PREDIS(TOTAL_ROWS).MI_NUMERO_REGISTRO := REG_REGISTROS.NUMERO_REGISTRO;
        TYPE_T_REGISTROS_PREDIS(TOTAL_ROWS).MI_NUMERO_DISPONIBILIDAD := REG_REGISTROS.NUMERO_DISPONIBILIDAD;
        TYPE_T_REGISTROS_PREDIS(TOTAL_ROWS).MI_NUMERO_RUBRO_INTERNO := REG_REGISTROS.RUBRO_INTERNO;
      END LOOP;
      IF TYPE_T_REGISTROS_PREDIS.COUNT = 0 THEN
        --PR_DESPLIEGA_MENSAJE('AL_STOP_1','Atencion : No existe informacion de presupuesto para este tercero.');
        RETURN('Atencion : No existe informacion de presupuesto para este tercero.');
      ELSE
        --FOR I IN 1..TYPE_T_REGISTROS_PREDIS.COUNT LOOP
        FOR J IN 1 .. UN_TYPE_T_PRESUPUESTO.COUNT LOOP
          MI_ENCONTRO := 0;
          --FOR J IN 1..UN_TYPE_T_PRESUPUESTO.COUNT LOOP
          FOR I IN 1 .. TYPE_T_REGISTROS_PREDIS.COUNT LOOP
            IF TYPE_T_REGISTROS_PREDIS(I)
             .MI_NUMERO_REGISTRO = UN_TYPE_T_PRESUPUESTO(J).MI_REGISTRO AND TYPE_T_REGISTROS_PREDIS(I)
               .MI_NUMERO_DISPONIBILIDAD = UN_TYPE_T_PRESUPUESTO(J)
               .MI_DISPONIBILIDAD AND TYPE_T_REGISTROS_PREDIS(I)
               .MI_NUMERO_RUBRO_INTERNO = UN_TYPE_T_PRESUPUESTO(J)
               .MI_RUBRO_INTERNO THEN
              -- Si encuentra el registro presupuestal debe averiguar si el saldo que
              -- tiene en PREDIS es suficiente para pagar.
              -- Para esto debe averiguar el total del registro presupuestal y restar
              -- el total pagado de este registro. Si la diferencia es menor o igual 
              -- a cero quiere decir que no puede crear este registro presupuestal en 
              -- la tabla OGT_IMPUTACION y OGT_REGISTRO_PRESUPUESTAL.
              MI_TOTAL_PAGADO := PK_EGR_GENERAL.FN_OGT_BD_SUMA_EGRESOS_COMPROM(UN_TYPE_T_PRESUPUESTO  (J)
                                                                               .MI_VIGENCIA,
                                                                               UN_TYPE_T_PRESUPUESTO  (J)
                                                                               .MI_ENTIDAD,
                                                                               UN_TYPE_T_PRESUPUESTO  (J)
                                                                               .MI_UNIDAD_EJECUTORA,
                                                                               UN_TYPE_T_PRESUPUESTO  (J)
                                                                               .MI_CODIGO_COMPROMISO,
                                                                               UN_TYPE_T_PRESUPUESTO  (J)
                                                                               .MI_NUMERO_DE_COMPROMISO,
                                                                               UN_TYPE_T_PRESUPUESTO  (J)
                                                                               .MI_RUBRO_INTERNO,
                                                                               UN_TYPE_T_PRESUPUESTO  (J)
                                                                               .MI_VIGENCIA_PRESUPUESTO,
                                                                               TYPE_T_REGISTROS_PREDIS(I)
                                                                               .MI_NUMERO_DISPONIBILIDAD,
                                                                               TYPE_T_REGISTROS_PREDIS(I)
                                                                               .MI_NUMERO_REGISTRO);
              MI_TOTAL_RP         := PK_EGR_ORDEN_PAGO.CALCULA_TOTAL_RP_TEMP(TO_NUMBER(UN_TYPE_T_PRESUPUESTO(J)
                                                                                       .MI_VIGENCIA),
                                                                             UN_TYPE_T_PRESUPUESTO(J)
                                                                             .MI_ENTIDAD,
                                                                             UN_TYPE_T_PRESUPUESTO(J)
                                                                             .MI_UNIDAD_EJECUTORA,
                                                                             TYPE_T_REGISTROS_PREDIS(I)
                                                                             .MI_NUMERO_REGISTRO,
                                                                             TYPE_T_REGISTROS_PREDIS(I)
                                                                             .MI_NUMERO_DISPONIBILIDAD,
                                                                             UN_TYPE_T_PRESUPUESTO(J)
                                                                             .MI_RUBRO_INTERNO);
              MI_TOTAL_DISPONIBLE := MI_TOTAL_RP - MI_TOTAL_PAGADO;
              IF MI_TOTAL_DISPONIBLE <= 0 THEN
                --PR_DESPLIEGA_MENSAJE('AL_STOP_1','Atencion : No puede crear imputacion presupuestal para la disponibilidad '||TYPE_T_REGISTROS_PREDIS(I).MI_NUMERO_DISPONIBILIDAD||' registro '||TYPE_T_REGISTROS_PREDIS(I).MI_NUMERO_REGISTRO||' porque no tiene recursos suficientes para efectuar el pago.');
                RETURN('Atencion : No puede crear imputacion presupuestal para la disponibilidad ' || TYPE_T_REGISTROS_PREDIS(I)
                       .MI_NUMERO_DISPONIBILIDAD || ' registro ' || TYPE_T_REGISTROS_PREDIS(I)
                       .MI_NUMERO_REGISTRO ||
                       ' porque no tiene recursos suficientes para efectuar el pago.');
              ELSE
                BEGIN
                  INSERT INTO OGT_IMPUTACION
                    (VIGENCIA,
                     ENTIDAD,
                     UNIDAD_EJECUTORA,
                     TIPO_DOCUMENTO,
                     CONSECUTIVO,
                     RUBRO_INTERNO,
                     DISPONIBILIDAD,
                     VIGENCIA_PRESUPUESTO,
                     ENTIDAD_PRESUPUESTO,
                     UNIDAD_EJECUTORA_PRESUPUESTO,
                     VALOR_BRUTO,
                     ANO_PAC,
                     MES_PAC)
                  VALUES
                    (UN_TYPE_T_PRESUPUESTO(J).MI_VIGENCIA,
                     UN_TYPE_T_PRESUPUESTO(J).MI_ENTIDAD,
                     UN_TYPE_T_PRESUPUESTO(J).MI_UNIDAD_EJECUTORA,
                     UN_TYPE_T_PRESUPUESTO(J).MI_TIPO_DOCUMENTO,
                     UN_TYPE_T_PRESUPUESTO(J).MI_CONSECUTIVO,
                     UN_TYPE_T_PRESUPUESTO(J).MI_RUBRO_INTERNO,
                     UN_TYPE_T_PRESUPUESTO(J).MI_DISPONIBILIDAD,
                     TO_NUMBER(UN_TYPE_T_PRESUPUESTO(J).MI_VIGENCIA),
                     UN_TYPE_T_PRESUPUESTO(J).MI_ENTIDAD,
                     UN_TYPE_T_PRESUPUESTO(J).MI_UNIDAD_EJECUTORA,
                     0,
                     UN_TYPE_T_PRESUPUESTO(J).MI_ANO_PAC,
                     UN_TYPE_T_PRESUPUESTO(J).MI_MES_PAC);
                EXCEPTION
                  WHEN DUP_VAL_ON_INDEX THEN
                    --PR_DESPLIEGA_MENSAJE('AL_STOP_1','Atencion : La disponibilidad '||UN_TYPE_T_PRESUPUESTO(1).MI_DISPONIBILIDAD||' registro '||UN_TYPE_T_PRESUPUESTO(1).MI_REGISTRO||' ya existe en el registro presupuestal.');
                    RETURN('Atencion : La disponibilidad ' || UN_TYPE_T_PRESUPUESTO(1)
                           .MI_DISPONIBILIDAD || ' registro ' || UN_TYPE_T_PRESUPUESTO(1)
                           .MI_REGISTRO ||
                           ' ya existe en el registro presupuestal.');
                  WHEN OTHERS THEN
                    --PR_DESPLIEGA_MENSAJE('AL_STOP_1','Atencion : No se pudo crear la imputacion presupuestal para la disponibilidad '||TYPE_T_REGISTROS_PREDIS(I).MI_NUMERO_DISPONIBILIDAD||' registro '||TYPE_T_REGISTROS_PREDIS(I).MI_NUMERO_REGISTRO||' ya que ocurrio el siguiente error. '||SQLERRM);
                    RETURN('Atencion : No se pudo crear la imputacion presupuestal para la disponibilidad ' || TYPE_T_REGISTROS_PREDIS(I)
                           .MI_NUMERO_DISPONIBILIDAD || ' registro ' || TYPE_T_REGISTROS_PREDIS(I)
                           .MI_NUMERO_REGISTRO ||
                           ' ya que ocurrio el siguiente error. ' ||
                           SQLERRM);
                END;
                BEGIN
                  INSERT INTO OGT_REGISTRO_PRESUPUESTAL
                    (VIGENCIA,
                     ENTIDAD,
                     UNIDAD_EJECUTORA,
                     TIPO_DOCUMENTO,
                     CONSECUTIVO,
                     RUBRO_INTERNO,
                     DISPONIBILIDAD,
                     REGISTRO,
                     VIGENCIA_PRESUPUESTO,
                     ENTIDAD_PRESUPUESTO,
                     UNIDAD_EJECUTORA_PRESUPUESTO,
                     VALOR_REGISTRO)
                  VALUES
                    (UN_TYPE_T_PRESUPUESTO(J).MI_VIGENCIA,
                     UN_TYPE_T_PRESUPUESTO(J).MI_ENTIDAD,
                     UN_TYPE_T_PRESUPUESTO(J).MI_UNIDAD_EJECUTORA,
                     UN_TYPE_T_PRESUPUESTO(J).MI_TIPO_DOCUMENTO,
                     UN_TYPE_T_PRESUPUESTO(J).MI_CONSECUTIVO,
                     UN_TYPE_T_PRESUPUESTO(J).MI_RUBRO_INTERNO,
                     UN_TYPE_T_PRESUPUESTO(J).MI_DISPONIBILIDAD,
                     UN_TYPE_T_PRESUPUESTO(J).MI_REGISTRO,
                     TO_NUMBER(UN_TYPE_T_PRESUPUESTO(J).MI_VIGENCIA),
                     UN_TYPE_T_PRESUPUESTO(J).MI_ENTIDAD,
                     UN_TYPE_T_PRESUPUESTO(J).MI_UNIDAD_EJECUTORA,
                     MI_TOTAL_DISPONIBLE);
                EXCEPTION
                  WHEN DUP_VAL_ON_INDEX THEN
                    --PR_DESPLIEGA_MENSAJE('AL_STOP_1','Atencion : La disponibilidad '||UN_TYPE_T_PRESUPUESTO(1).MI_DISPONIBILIDAD||' registro '||UN_TYPE_T_PRESUPUESTO(1).MI_REGISTRO||' ya existe en el registro presupuestal.');
                    RETURN('Atencion : La disponibilidad ' || UN_TYPE_T_PRESUPUESTO(1)
                           .MI_DISPONIBILIDAD || ' registro ' || UN_TYPE_T_PRESUPUESTO(1)
                           .MI_REGISTRO ||
                           ' ya existe en el registro presupuestal.');
                  WHEN OTHERS THEN
                    --PR_DESPLIEGA_MENSAJE('AL_STOP_1','Atencion : No se pudo crear el registro presupuestal para la disponibilidad '||TYPE_T_REGISTROS_PREDIS(I).MI_NUMERO_DISPONIBILIDAD||' registro '||TYPE_T_REGISTROS_PREDIS(I).MI_NUMERO_REGISTRO||' ya que ocurrio el siguiente error. '||SQLERRM);
                    RETURN('Atencion : No se pudo crear el registro presupuestal para la disponibilidad ' || TYPE_T_REGISTROS_PREDIS(I)
                           .MI_NUMERO_DISPONIBILIDAD || ' registro ' || TYPE_T_REGISTROS_PREDIS(I)
                           .MI_NUMERO_REGISTRO ||
                           ' ya que ocurrio el siguiente error. ' ||
                           SQLERRM);
                END;
              END IF;
              MI_ENCONTRO := 1;
            END IF;
          END LOOP;
          IF MI_ENCONTRO = 0 THEN
            --PR_DESPLIEGA_MENSAJE('AL_STOP_1','Atencion : La disponibilidad '||UN_TYPE_T_PRESUPUESTO(1).MI_DISPONIBILIDAD||' registro '||UN_TYPE_T_PRESUPUESTO(1).MI_REGISTRO||' no existe en presupuesto.');
            RETURN('Atencion : La disponibilidad ' || UN_TYPE_T_PRESUPUESTO(1)
                   .MI_DISPONIBILIDAD || ' registro ' || UN_TYPE_T_PRESUPUESTO(1)
                   .MI_REGISTRO || ' no existe en presupuesto.');
          END IF;
        END LOOP;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        --PR_DESPLIEGA_MENSAJE('AL_STOP_1','Atencion : No se pudo crear la imputacion presupuestal debido a que ocurrio el siguiente error. '||SQLERRM);
        RETURN('Atencion : No se pudo crear la imputacion presupuestal debido a que ocurrio el siguiente error. ' ||
               SQLERRM);
    END;
    RETURN(0);
  END FN_OGT_BD_CREAR_PRESUPUESTO;

  -- Funcion usada para crear la informacion exogena (detalle del pago) de la orden de pago.

  FUNCTION FN_OGT_BD_CREAR_DETALLE_PAGO(UN_TYPE_T_DETALLE_PAGO T_DETALLE_PAGO)
    RETURN VARCHAR2 IS
    MI_TOTAL_BRUTO          NUMBER(20, 2) := 0;
    MI_TOTAL_PAGADO         NUMBER(20, 2) := 0;
    MI_TOTAL_RP             NUMBER(20, 2) := 0;
    MI_TOTAL_DISPONIBLE     NUMBER(20, 2) := 0;
    MI_ACTIVIDAD            OGT_ACTIVIDAD_ECONOMICA.CODIGO_ACTIVIDAD%TYPE;
    MI_CODIGO_COMPROMISO    OGT_ORDEN_PAGO.CODIGO_COMPROMISO%TYPE;
    MI_NUMERO_DE_COMPROMISO OGT_ORDEN_PAGO.NUMERO_DE_COMPROMISO%TYPE;
    MI_EXISTE_TERCERO       BOOLEAN;
    MI_EXISTE_BANCO         BOOLEAN;
    MI_TYPE_T_DETALLE_PAGO  T_DETALLE_PAGO;
    MI_ITEM                 NUMBER;
    MI_TRC_ERROR            VARCHAR2(200);
  BEGIN
    IF UN_TYPE_T_DETALLE_PAGO.COUNT = 0 THEN
      --PR_DESPLIEGA_MENSAJE('AL_STOP_1','Atencion : No existen detalles de pago para crear.');
      RETURN('Atencion : No existen detalles de pago para crear.');
    ELSE
      -- 14-04-2003. Sergio.
      -- Volcar el arreglo que entra y que no se puede modificar a un arreglo local y que
      -- si se puede modificar.
      FOR I IN 1 .. UN_TYPE_T_DETALLE_PAGO.COUNT LOOP
        MI_TYPE_T_DETALLE_PAGO(I).MI_VIGENCIA := UN_TYPE_T_DETALLE_PAGO(I)
                                                 .MI_VIGENCIA;
        MI_TYPE_T_DETALLE_PAGO(I).MI_ENTIDAD := UN_TYPE_T_DETALLE_PAGO(I)
                                                .MI_ENTIDAD;
        MI_TYPE_T_DETALLE_PAGO(I).MI_UNIDAD_EJECUTORA := UN_TYPE_T_DETALLE_PAGO(I)
                                                         .MI_UNIDAD_EJECUTORA;
        MI_TYPE_T_DETALLE_PAGO(I).MI_TIPO_DOCUMENTO := UN_TYPE_T_DETALLE_PAGO(I)
                                                       .MI_TIPO_DOCUMENTO;
        MI_TYPE_T_DETALLE_PAGO(I).MI_RUBRO_INTERNO := UN_TYPE_T_DETALLE_PAGO(I)
                                                      .MI_RUBRO_INTERNO;
        MI_TYPE_T_DETALLE_PAGO(I).MI_VIGENCIA_PRESUPUESTO := UN_TYPE_T_DETALLE_PAGO(I)
                                                             .MI_VIGENCIA_PRESUPUESTO;
        MI_TYPE_T_DETALLE_PAGO(I).MI_NUMERO_REGISTRO := UN_TYPE_T_DETALLE_PAGO(I)
                                                        .MI_NUMERO_REGISTRO;
        MI_TYPE_T_DETALLE_PAGO(I).MI_NUMERO_DISPONIBILIDAD := UN_TYPE_T_DETALLE_PAGO(I)
                                                              .MI_NUMERO_DISPONIBILIDAD;
        MI_TYPE_T_DETALLE_PAGO(I).MI_CONSECUTIVO := UN_TYPE_T_DETALLE_PAGO(I)
                                                    .MI_CONSECUTIVO;
        MI_TYPE_T_DETALLE_PAGO(I).MI_TIPO_DOCUMENTO_IE := UN_TYPE_T_DETALLE_PAGO(I)
                                                          .MI_TIPO_DOCUMENTO_IE;
        MI_TYPE_T_DETALLE_PAGO(I).MI_NUMERO_DOCUMENTO := UN_TYPE_T_DETALLE_PAGO(I)
                                                         .MI_NUMERO_DOCUMENTO;
        MI_TYPE_T_DETALLE_PAGO(I).MI_ITEM := UN_TYPE_T_DETALLE_PAGO(I)
                                             .MI_ITEM;
        MI_TYPE_T_DETALLE_PAGO(I).MI_TER_ID := UN_TYPE_T_DETALLE_PAGO(I)
                                               .MI_TER_ID;
        MI_TYPE_T_DETALLE_PAGO(I).MI_CODIGO_ACTIVIDAD := UN_TYPE_T_DETALLE_PAGO(I)
                                                         .MI_CODIGO_ACTIVIDAD;
        MI_TYPE_T_DETALLE_PAGO(I).MI_FECHA := UN_TYPE_T_DETALLE_PAGO(I)
                                              .MI_FECHA;
        MI_TYPE_T_DETALLE_PAGO(I).MI_VALOR_BRUTO := UN_TYPE_T_DETALLE_PAGO(I)
                                                    .MI_VALOR_BRUTO;
        MI_TYPE_T_DETALLE_PAGO(I).MI_FORMA_PAGO := UN_TYPE_T_DETALLE_PAGO(I)
                                                   .MI_FORMA_PAGO;
        MI_TYPE_T_DETALLE_PAGO(I).MI_NUMERO_CUENTA := UN_TYPE_T_DETALLE_PAGO(I)
                                                      .MI_NUMERO_CUENTA;
        MI_TYPE_T_DETALLE_PAGO(I).MI_BANCO := UN_TYPE_T_DETALLE_PAGO(I)
                                              .MI_BANCO;
        MI_TYPE_T_DETALLE_PAGO(I).MI_CLASE := UN_TYPE_T_DETALLE_PAGO(I)
                                              .MI_CLASE;
        MI_TYPE_T_DETALLE_PAGO(I).MI_SUMADO := 'N';
        MI_TYPE_T_DETALLE_PAGO(I).MI_GENERA_PAGO := UN_TYPE_T_DETALLE_PAGO(I)
                                                    .MI_GENERA_PAGO;
      END LOOP;
      -- Validar que la sumatoria de los valores brutos no excedan el valor maximo 
      -- disponible del registro presupuestal.
      -- 14-04-2003. Sergio.
      -- Se adiciono el siguiente FOR para garantizar que solo se sume y se valide los 
      -- pagos realizados por un rubro interno, CDP y RP.
      -- Se adiciono el campo MI_SUMADO a la estructura para controlar que la fila sumada
      -- no se tenga en cuenta en el loo externo.
      -- Se paso las validaciones de tipo documento ('F','C','R','S','I','AC','CO') al 
      -- segundo LOOP.
      -- Igual para el resto de validaciones.
      FOR I IN 1 .. MI_TYPE_T_DETALLE_PAGO.COUNT LOOP
        IF MI_TYPE_T_DETALLE_PAGO(I).MI_SUMADO != 'S' THEN
          MI_TOTAL_BRUTO := 0;
          FOR J IN 1 .. MI_TYPE_T_DETALLE_PAGO.COUNT LOOP
            IF MI_TYPE_T_DETALLE_PAGO(I)
             .MI_VIGENCIA = MI_TYPE_T_DETALLE_PAGO(J).MI_VIGENCIA AND MI_TYPE_T_DETALLE_PAGO(I)
               .MI_ENTIDAD = MI_TYPE_T_DETALLE_PAGO(J).MI_ENTIDAD AND MI_TYPE_T_DETALLE_PAGO(I)
               .MI_UNIDAD_EJECUTORA = MI_TYPE_T_DETALLE_PAGO(J)
               .MI_UNIDAD_EJECUTORA AND MI_TYPE_T_DETALLE_PAGO(I)
               .MI_VIGENCIA_PRESUPUESTO = MI_TYPE_T_DETALLE_PAGO(J)
               .MI_VIGENCIA_PRESUPUESTO AND MI_TYPE_T_DETALLE_PAGO(I)
               .MI_RUBRO_INTERNO = MI_TYPE_T_DETALLE_PAGO(J)
               .MI_RUBRO_INTERNO AND MI_TYPE_T_DETALLE_PAGO(I)
               .MI_NUMERO_REGISTRO = MI_TYPE_T_DETALLE_PAGO(J)
               .MI_NUMERO_REGISTRO AND MI_TYPE_T_DETALLE_PAGO(I)
               .MI_NUMERO_DISPONIBILIDAD = MI_TYPE_T_DETALLE_PAGO(J)
               .MI_NUMERO_DISPONIBILIDAD AND MI_TYPE_T_DETALLE_PAGO(J)
               .MI_SUMADO != 'S' THEN
              -- Sumar el valor bruto para validar mas adelante contra PREDIS.
              MI_TOTAL_BRUTO := NVL(MI_TOTAL_BRUTO, 0) +
                                NVL(MI_TYPE_T_DETALLE_PAGO(J).MI_VALOR_BRUTO,
                                    0);
              MI_TYPE_T_DETALLE_PAGO(J).MI_SUMADO := 'S';
              -- Validar que el tipo de documento corresponda a Factura (F) o Cuenta de 
              -- Cobro (C).
              -- 11-11-2003. Sergio.
              -- Validar que los tipos de documentos 'S','I','AC','CO'
              IF MI_TYPE_T_DETALLE_PAGO(J)
               .MI_TIPO_DOCUMENTO_IE NOT IN
                  ('F', 'C', 'R', 'S', 'I', 'AC', 'CO') THEN
                RETURN('Atencion : Tipo de documento incorrecto, digite F (Factura), C (Cuenta Cobro).');
              END IF;
              -- 11-11-2003. Sergio.
              -- Validar indicativo de egreso
              IF NVL(MI_TYPE_T_DETALLE_PAGO(J).MI_GENERA_PAGO, 'N') NOT IN
                 ('S', 'N') THEN
                RETURN('Atencion : Indicativo genera pago incorrecto, digite S o N.');
              END IF;
              -- Validar que el tercero exista.
              MI_EXISTE_TERCERO := PK_OGT_TERCEROS.FN_EXISTE_ID(MI_TYPE_T_DETALLE_PAGO(J)
                                                                .MI_TER_ID,
                                                                MI_TRC_ERROR);
              IF NOT MI_EXISTE_TERCERO THEN
                --PR_DESPLIEGA_MENSAJE('AL_STOP_1','Atencion :  Tercero no existe, debe crearlo antes de continuar.');
                RETURN('Atencion :  Tercero no existe, debe crearlo antes de continuar.');
              END IF;
              IF MI_TYPE_T_DETALLE_PAGO(J).MI_FORMA_PAGO IS NOT NULL THEN
                IF MI_TYPE_T_DETALLE_PAGO(J).MI_FORMA_PAGO NOT IN ('A', 'C') THEN
                  --PR_DESPLIEGA_MENSAJE('AL_STOP_1','Atencion :  Forma de Pago Incorrecta, digite A (Abono en cuenta), C (Cheque).');
                  RETURN('Atencion :  Forma de Pago Incorrecta, digite A (Abono en cuenta), C (Cheque).');
                ELSE
                  IF MI_TYPE_T_DETALLE_PAGO(J).MI_BANCO IS NOT NULL THEN
                    MI_EXISTE_BANCO := PK_OGT_TERCEROS.FN_EXISTE_ID(MI_TYPE_T_DETALLE_PAGO(J)
                                                                    .MI_BANCO,
                                                                    MI_TRC_ERROR);
                  
                    -- 13-05-2004. Sergio.
                    -- Adicionar ayuda al mensaje.
                  
                    IF NOT MI_EXISTE_BANCO THEN
                      --PR_DESPLIEGA_MENSAJE('AL_STOP_1','Atencion :  Banco no existe, debe crearlo antes de continuar.');
                      RETURN('Atencion :  Banco no existe, debe crearlo antes de continuar. Número Documento ' || MI_TYPE_T_DETALLE_PAGO(J)
                             .MI_NUMERO_DOCUMENTO || ' Item ' || MI_TYPE_T_DETALLE_PAGO(J)
                             .MI_ITEM);
                    ELSE
                      IF MI_TYPE_T_DETALLE_PAGO(J).MI_NUMERO_CUENTA IS NULL THEN
                        --PR_DESPLIEGA_MENSAJE('AL_STOP_1','Atencion : No se encontro numero de cuenta.');
                        RETURN('Atencion : No se encontro numero de cuenta. Número Documento ' || MI_TYPE_T_DETALLE_PAGO(J)
                               .MI_NUMERO_DOCUMENTO || ' Item ' || MI_TYPE_T_DETALLE_PAGO(J)
                               .MI_ITEM);
                      END IF;
                      IF MI_TYPE_T_DETALLE_PAGO(J).MI_CLASE IS NULL THEN
                        --PR_DESPLIEGA_MENSAJE('AL_STOP_1','Atencion : No se encontro clase de cuenta (AHORROS o CORRIENTE.');
                        RETURN('Atencion : No se encontro clase de cuenta (AHORROS o CORRIENTE. Número Documento ' || MI_TYPE_T_DETALLE_PAGO(J)
                               .MI_NUMERO_DOCUMENTO || ' Item ' || MI_TYPE_T_DETALLE_PAGO(J)
                               .MI_ITEM);
                      ELSE
                        IF UPPER(MI_TYPE_T_DETALLE_PAGO(J).MI_CLASE) NOT IN
                           ('CORRIENTE', 'AHORROS') THEN
                          --UPPER(MI_TYPE_T_DETALLE_PAGO(J).MI_CLASE) NOT IN ('C','A') THEN
                          --PR_DESPLIEGA_MENSAJE('AL_STOP_1','Atencion : Clase de cuenta incorrecta. Debe digitar AHORROS o CORRIENTE.');
                          RETURN('Atencion : Clase de cuenta incorrecta. Debe digitar AHORROS o CORRIENTE. Número Documento ' || MI_TYPE_T_DETALLE_PAGO(J)
                                 .MI_NUMERO_DOCUMENTO || ' Item ' || MI_TYPE_T_DETALLE_PAGO(J)
                                 .MI_ITEM);
                        END IF;
                      END IF;
                    END IF;
                  ELSE
                    --MI_TYPE_T_DETALLE_PAGO(I).MI_NUMERO_CUENTA := NULL;     
                    NULL;
                  END IF;
                END IF;
              END IF;
            
              -- 23-05-2003. Sergio.
              -- Validar si el valor bruto es mayor que cero, sino, error.
            
              IF MI_TYPE_T_DETALLE_PAGO(J).MI_VALOR_BRUTO <= 0 THEN
                RETURN('Atencion : El valor bruto no puede ser menor o igual cero. Número Documento ' || MI_TYPE_T_DETALLE_PAGO(J)
                       .MI_NUMERO_DOCUMENTO || ' Item ' || MI_TYPE_T_DETALLE_PAGO(J)
                       .MI_ITEM);
              END IF;
            
            END IF;
          END LOOP;
          MI_TOTAL_PAGADO := PK_EGR_GENERAL.FN_OGT_BD_SUMA_EGRESOS_COMPROM(MI_TYPE_T_DETALLE_PAGO(I)
                                                                           .MI_VIGENCIA,
                                                                           MI_TYPE_T_DETALLE_PAGO(I)
                                                                           .MI_ENTIDAD,
                                                                           MI_TYPE_T_DETALLE_PAGO(I)
                                                                           .MI_UNIDAD_EJECUTORA,
                                                                           '0',
                                                                           '0',
                                                                           MI_TYPE_T_DETALLE_PAGO(I)
                                                                           .MI_RUBRO_INTERNO,
                                                                           MI_TYPE_T_DETALLE_PAGO(I)
                                                                           .MI_VIGENCIA_PRESUPUESTO,
                                                                           MI_TYPE_T_DETALLE_PAGO(I)
                                                                           .MI_NUMERO_DISPONIBILIDAD,
                                                                           MI_TYPE_T_DETALLE_PAGO(I)
                                                                           .MI_NUMERO_REGISTRO);
          MI_TOTAL_RP         := PK_EGR_ORDEN_PAGO.CALCULA_TOTAL_RP_TEMP(TO_NUMBER(MI_TYPE_T_DETALLE_PAGO(I)
                                                                                   .MI_VIGENCIA),
                                                                         MI_TYPE_T_DETALLE_PAGO(I)
                                                                         .MI_ENTIDAD,
                                                                         MI_TYPE_T_DETALLE_PAGO(I)
                                                                         .MI_UNIDAD_EJECUTORA,
                                                                         MI_TYPE_T_DETALLE_PAGO(I)
                                                                         .MI_NUMERO_REGISTRO,
                                                                         MI_TYPE_T_DETALLE_PAGO(I)
                                                                         .MI_NUMERO_DISPONIBILIDAD,
                                                                         MI_TYPE_T_DETALLE_PAGO(I)
                                                                         .MI_RUBRO_INTERNO);
          MI_TOTAL_DISPONIBLE := MI_TOTAL_RP -
                                 (MI_TOTAL_PAGADO + MI_TOTAL_BRUTO);
          -- 14-04-2003. Sergio.
          -- Se cambio el operador de relación <= por <.
          --IF MI_TOTAL_DISPONIBLE <= 0 THEN
        
          --PR_DESPLIEGA_MENSAJE('AL_STOP_1','EN I .... MI TOTAL DISPONIBLE '||MI_TOTAL_DISPONIBLE);
        
          IF MI_TOTAL_DISPONIBLE < 0 THEN
            --PR_DESPLIEGA_MENSAJE('AL_STOP_1','Atencion : No puede crear detalle pago para la disponibilidad '||MI_TYPE_T_DETALLE_PAGO(1).MI_NUMERO_DISPONIBILIDAD||' registro '||MI_TYPE_T_DETALLE_PAGO(1).MI_NUMERO_REGISTRO||' porque el total pagado ('||MI_TOTAL_PAGADO||') mas el valor bruto de este detalle ('||MI_TOTAL_BRUTO||') supera el valor del registro presupuestal ('||MI_TOTAL_RP||').');
            RETURN('Atencion : No puede crear detalle pago para la disponibilidad ' || MI_TYPE_T_DETALLE_PAGO(I)
                   .MI_NUMERO_DISPONIBILIDAD || ' registro ' || MI_TYPE_T_DETALLE_PAGO(I)
                   .MI_NUMERO_REGISTRO || ' porque el total pagado (' ||
                   MI_TOTAL_PAGADO ||
                   ') mas el valor bruto de este detalle (' ||
                   MI_TOTAL_BRUTO ||
                   ') supera el valor del registro presupuestal (' ||
                   MI_TOTAL_RP || '). Número Documento ' || MI_TYPE_T_DETALLE_PAGO(I)
                   .MI_NUMERO_DOCUMENTO || ' Item ' || MI_TYPE_T_DETALLE_PAGO(I)
                   .MI_ITEM);
          ELSE
            -- 14-03-2003. Sergio.
            -- Después de obtener el valor bruto y hacer todas las validaciones toca 
            -- crear uno por uno los detalles de pago para esta imputación.
            FOR K IN 1 .. MI_TYPE_T_DETALLE_PAGO.COUNT LOOP
              --PR_DESPLIEGA_MENSAJE('AL_STOP_1','EN K .... RUBRO INTERNO '||MI_TYPE_T_DETALLE_PAGO(K).MI_RUBRO_INTERNO||' NUMERO REGISTRO '||MI_TYPE_T_DETALLE_PAGO(K).MI_NUMERO_REGISTRO||' NUMERO DISPONIBILIDAD '||MI_TYPE_T_DETALLE_PAGO(K).MI_NUMERO_DISPONIBILIDAD||' VALOR BRUTO '||MI_TYPE_T_DETALLE_PAGO(K).MI_VALOR_BRUTO||' SUMADO '||MI_TYPE_T_DETALLE_PAGO(K).MI_SUMADO);                    
              IF MI_TYPE_T_DETALLE_PAGO(I)
               .MI_VIGENCIA = MI_TYPE_T_DETALLE_PAGO(K).MI_VIGENCIA AND MI_TYPE_T_DETALLE_PAGO(I)
                 .MI_ENTIDAD = MI_TYPE_T_DETALLE_PAGO(K).MI_ENTIDAD AND MI_TYPE_T_DETALLE_PAGO(I)
                 .MI_UNIDAD_EJECUTORA = MI_TYPE_T_DETALLE_PAGO(K)
                 .MI_UNIDAD_EJECUTORA AND MI_TYPE_T_DETALLE_PAGO(I)
                 .MI_VIGENCIA_PRESUPUESTO = MI_TYPE_T_DETALLE_PAGO(K)
                 .MI_VIGENCIA_PRESUPUESTO AND MI_TYPE_T_DETALLE_PAGO(I)
                 .MI_RUBRO_INTERNO = MI_TYPE_T_DETALLE_PAGO(K)
                 .MI_RUBRO_INTERNO AND MI_TYPE_T_DETALLE_PAGO(I)
                 .MI_NUMERO_REGISTRO = MI_TYPE_T_DETALLE_PAGO(K)
                 .MI_NUMERO_REGISTRO AND MI_TYPE_T_DETALLE_PAGO(I)
                 .MI_NUMERO_DISPONIBILIDAD = MI_TYPE_T_DETALLE_PAGO(K)
                 .MI_NUMERO_DISPONIBILIDAD AND MI_TYPE_T_DETALLE_PAGO(K)
                 .MI_SUMADO = 'S' THEN
                BEGIN
                
                  -- 13-05-2004. Sergio.
                  -- Adicionar id del tercero a OGT_TERCERO.
                
                  BEGIN
                    INSERT INTO OGT_TERCERO
                      (ID)
                    VALUES
                      (MI_TYPE_T_DETALLE_PAGO(K).MI_TER_ID);
                  EXCEPTION
                    WHEN DUP_VAL_ON_INDEX THEN
                      NULL;
                  END;
                
                  INSERT INTO OGT_INFORMACION_EXOGENA
                    (VIGENCIA,
                     ENTIDAD,
                     UNIDAD_EJECUTORA,
                     TIPO_DOCUMENTO,
                     CONSECUTIVO,
                     TIPO_DOCUMENTO_IE,
                     NUMERO_DOCUMENTO,
                     ITEM,
                     RUBRO_INTERNO,
                     VIGENCIA_PRESUPUESTO,
                     REGISTRO,
                     DISPONIBILIDAD,
                     TER_ID,
                     CODIGO_ACTIVIDAD,
                     FECHA,
                     FORMA_PAGO,
                     NUMERO_CUENTA,
                     BANCO,
                     CLASE,
                     VALOR_BRUTO,
                     INDICATIVO_EGRESO)
                  VALUES
                    (MI_TYPE_T_DETALLE_PAGO(K).MI_VIGENCIA,
                     MI_TYPE_T_DETALLE_PAGO(K).MI_ENTIDAD,
                     MI_TYPE_T_DETALLE_PAGO(K).MI_UNIDAD_EJECUTORA,
                     MI_TYPE_T_DETALLE_PAGO(K).MI_TIPO_DOCUMENTO,
                     MI_TYPE_T_DETALLE_PAGO(K).MI_CONSECUTIVO,
                     UPPER(MI_TYPE_T_DETALLE_PAGO(K).MI_TIPO_DOCUMENTO_IE),
                     MI_TYPE_T_DETALLE_PAGO(K).MI_NUMERO_DOCUMENTO,
                     MI_TYPE_T_DETALLE_PAGO(K).MI_ITEM,
                     MI_TYPE_T_DETALLE_PAGO(K).MI_RUBRO_INTERNO,
                     TO_NUMBER(MI_TYPE_T_DETALLE_PAGO(K).MI_VIGENCIA),
                     MI_TYPE_T_DETALLE_PAGO(K).MI_NUMERO_REGISTRO,
                     MI_TYPE_T_DETALLE_PAGO(K).MI_NUMERO_DISPONIBILIDAD,
                     MI_TYPE_T_DETALLE_PAGO(K).MI_TER_ID,
                     MI_TYPE_T_DETALLE_PAGO(K).MI_CODIGO_ACTIVIDAD,
                     --TO_DATE(TO_CHAR(SYSDATE,'DDMMYYHH24MISS'),'DDMMYYHH24MISS'),
                     MI_TYPE_T_DETALLE_PAGO(K).MI_FECHA,
                     MI_TYPE_T_DETALLE_PAGO(K).MI_FORMA_PAGO,
                     MI_TYPE_T_DETALLE_PAGO(K).MI_NUMERO_CUENTA,
                     MI_TYPE_T_DETALLE_PAGO(K).MI_BANCO,
                     UPPER(MI_TYPE_T_DETALLE_PAGO(K).MI_CLASE),
                     MI_TYPE_T_DETALLE_PAGO(K).MI_VALOR_BRUTO,
                     NVL(MI_TYPE_T_DETALLE_PAGO(K).MI_GENERA_PAGO, 'N'));
                EXCEPTION
                  WHEN DUP_VAL_ON_INDEX THEN
                    --PR_DESPLIEGA_MENSAJE('AL_STOP_1','Atención : Detalle de pago ya existe para el documento '||MI_TYPE_T_DETALLE_PAGO(I).MI_NUMERO_DOCUMENTO||' Item '||MI_TYPE_T_DETALLE_PAGO(I).MI_ITEM);
                    RETURN('Atención : Detalle de pago ya existe para el documento ' || MI_TYPE_T_DETALLE_PAGO(K)
                           .MI_NUMERO_DOCUMENTO || ' Item ' || MI_TYPE_T_DETALLE_PAGO(K)
                           .MI_ITEM);
                  WHEN OTHERS THEN
                    --PR_DESPLIEGA_MENSAJE('AL_STOP_1','Atención : No se pudo crear detalle de pago para el documento '||MI_TYPE_T_DETALLE_PAGO(I).MI_NUMERO_DOCUMENTO||' Item '||MI_TYPE_T_DETALLE_PAGO(I).MI_ITEM||' debido a que se presento el siguiente error. '||SQLERRM);
                    RETURN('Atención : No se pudo crear detalle de pago para el documento ' || MI_TYPE_T_DETALLE_PAGO(K)
                           .MI_NUMERO_DOCUMENTO || ' Item ' || MI_TYPE_T_DETALLE_PAGO(K)
                           .MI_ITEM ||
                           ' debido a que se presento el siguiente error. ' ||
                           SQLERRM);
                END;
              END IF;
            END LOOP;
          END IF;
        END IF;
      END LOOP;
    END IF;
    RETURN(0);
  EXCEPTION
    WHEN OTHERS THEN
      --PR_DESPLIEGA_MENSAJE('AL_STOP_1','Atencion : No se pudo crear detalle del pago debido a que ocurrio el siguiente error. '||SQLERRM);
      RETURN('Atencion : No se pudo crear detalle del pago debido a que ocurrio el siguiente error. ' ||
             SQLERRM);
  END FN_OGT_BD_CREAR_DETALLE_PAGO;

  -- Funcion usada para crear el detalle de descuento de la orden de pago.

  FUNCTION FN_OGT_BD_CREAR_DETALLE_DESCUE(UN_TYPE_T_DETALLE_DESCUENTO T_DETALLE_DESCUENTO)
    RETURN VARCHAR2 IS
    MI_BASE_MINIMA                OGT_DESCUENTO.BASE_MINIMA%TYPE;
    MI_PORCENTAJE                 OGT_DESCUENTO.PORCENTAJE%TYPE;
    MI_FECHA_INICIAL              OGT_DESCUENTO.FECHA_INICIAL%TYPE;
    MI_CODIGO_ACTIVIDAD_DESCUENTO OGT_DESCUENTO.CODIGO_ACTIVIDAD%TYPE;
    MI_FECHA_FINAL                OGT_DESCUENTO.FECHA_INICIAL%TYPE;
    --MI_DESCRIPCION_CODIGO    OGT_DESCUENTO.DESCRIPCION_CODIGO%TYPE;
    MI_VALOR_BRUTO              OGT_INFORMACION_EXOGENA.VALOR_BRUTO%TYPE;
    MI_CODIGO_ACTIVIDAD_EXOGENA OGT_INFORMACION_EXOGENA.CODIGO_ACTIVIDAD%TYPE;
    MI_VALOR_CALCULADO          NUMBER(20, 2);
  BEGIN
  
    -- Validar que existan filas en la tabla.
  
    IF UN_TYPE_T_DETALLE_DESCUENTO.COUNT = 0 THEN
      --PR_DESPLIEGA_MENSAJE('AL_STOP_1','Atención : No existen detalles de descuento para procesar.');
      RETURN('Atención : No existen detalles de descuento para procesar.');
    END IF;
  
    -- Validar que el codigo interno que se recibe exista en la tabla OGT_DESCUENTO de 
    -- tesoreria.
  
    FOR I IN 1 .. UN_TYPE_T_DETALLE_DESCUENTO.COUNT LOOP
      BEGIN
        SELECT BASE_MINIMA,
               PORCENTAJE,
               FECHA_INICIAL,
               CODIGO_ACTIVIDAD,
               FECHA_FINAL
          INTO MI_BASE_MINIMA,
               MI_PORCENTAJE,
               MI_FECHA_INICIAL,
               MI_CODIGO_ACTIVIDAD_DESCUENTO,
               MI_FECHA_FINAL
          FROM OGT_DESCUENTO
         WHERE CODIGO_INTERNO = UN_TYPE_T_DETALLE_DESCUENTO(I)
              .MI_CODIGO_INTERNO;
        IF SQL%FOUND THEN
          IF MI_FECHA_FINAL > SYSDATE THEN
            --PR_DESPLIEGA_MENSAJE('AL_STOP_1','Atención : El código interno '||UN_TYPE_T_DETALLE_DESCUENTO(I).MI_CODIGO_INTERNO||' caduco el '||MI_FECHA_FINAL||' debe crear un nuevo código con fecha final indefinida o superior a la actual.');
            RETURN('Atención : El código interno ' || UN_TYPE_T_DETALLE_DESCUENTO(I)
                   .MI_CODIGO_INTERNO || ' caduco el ' || MI_FECHA_FINAL ||
                   ' debe crear un nuevo código con fecha final indefinida o superior a la actual. Número Documento ' || UN_TYPE_T_DETALLE_DESCUENTO(I)
                   .MI_NUMERO_DOCUMENTO || ' Item ' || UN_TYPE_T_DETALLE_DESCUENTO(I)
                   .MI_ITEM);
          END IF;
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          --PR_DESPLIEGA_MENSAJE('AL_STOP_1','Atención : El código interno '||UN_TYPE_T_DETALLE_DESCUENTO(I).MI_CODIGO_INTERNO||' no existe, debe crearlo antes de continuar.');
          RETURN('Atención : El código interno ' || UN_TYPE_T_DETALLE_DESCUENTO(I)
                 .MI_CODIGO_INTERNO ||
                 ' no existe, debe crearlo antes de continuar. Número Documento ' || UN_TYPE_T_DETALLE_DESCUENTO(I)
                 .MI_NUMERO_DOCUMENTO || ' Item ' || UN_TYPE_T_DETALLE_DESCUENTO(I)
                 .MI_ITEM);
        WHEN OTHERS THEN
          --PR_DESPLIEGA_MENSAJE('AL_STOP_1','Atención : Error seleccionando código interno de descuento. '||SQLERRM);
          RETURN('Atención : Error seleccionando código interno de descuento. Número Documento ' || UN_TYPE_T_DETALLE_DESCUENTO(I)
                 .MI_NUMERO_DOCUMENTO || ' Item ' || UN_TYPE_T_DETALLE_DESCUENTO(I)
                 .MI_ITEM || '. ' || SQLERRM);
      END;
    
      -- Validar que la base de retencion no sea inferior a la base minima del descuento.
    
      IF UN_TYPE_T_DETALLE_DESCUENTO(I)
       .MI_VALOR_BASE_RETENCION < MI_BASE_MINIMA THEN
        --PR_DESPLIEGA_MENSAJE('AL_STOP_1','Atención : El valor base de retención ('||TO_CHAR(UN_TYPE_T_DETALLE_DESCUENTO(I).MI_VALOR_BASE_RETENCION,'99,999,999,999.99')||') es menor a la base minima de retencion del descuento ('||TO_CHAR(MI_BASE_MINIMA,'99,999,999,999.99')||').');
        RETURN('Atención : El valor base de retención (' ||
               TO_CHAR(UN_TYPE_T_DETALLE_DESCUENTO(I)
                       .MI_VALOR_BASE_RETENCION,
                       '99,999,999,999.99') ||
               ') es menor a la base minima de retencion del descuento (' ||
               TO_CHAR(MI_BASE_MINIMA, '99,999,999,999.99') ||
               '). Número Documento ' || UN_TYPE_T_DETALLE_DESCUENTO(I)
               .MI_NUMERO_DOCUMENTO || ' Item ' || UN_TYPE_T_DETALLE_DESCUENTO(I)
               .MI_ITEM);
      END IF;
    
      -- Validar que el valor de descuento sea realmente concordante con los valores de
      -- base minima del descuento y valor bruto del detalle descuento.
    
      BEGIN
        SELECT VALOR_BRUTO, CODIGO_ACTIVIDAD
          INTO MI_VALOR_BRUTO, MI_CODIGO_ACTIVIDAD_EXOGENA
          FROM OGT_INFORMACION_EXOGENA
         WHERE VIGENCIA = UN_TYPE_T_DETALLE_DESCUENTO(I).MI_VIGENCIA
           AND ENTIDAD = UN_TYPE_T_DETALLE_DESCUENTO(I).MI_ENTIDAD
           AND UNIDAD_EJECUTORA = UN_TYPE_T_DETALLE_DESCUENTO(I)
              .MI_UNIDAD_EJECUTORA
           AND TIPO_DOCUMENTO = UN_TYPE_T_DETALLE_DESCUENTO(I)
              .MI_TIPO_DOCUMENTO
           AND CONSECUTIVO = UN_TYPE_T_DETALLE_DESCUENTO(I).MI_CONSECUTIVO
           AND RUBRO_INTERNO = UN_TYPE_T_DETALLE_DESCUENTO(I)
              .MI_RUBRO_INTERNO
           AND VIGENCIA_PRESUPUESTO = UN_TYPE_T_DETALLE_DESCUENTO(I)
              .MI_VIGENCIA
           AND REGISTRO = UN_TYPE_T_DETALLE_DESCUENTO(I).MI_REGISTRO
           AND DISPONIBILIDAD = UN_TYPE_T_DETALLE_DESCUENTO(I)
              .MI_DISPONIBILIDAD
           AND NUMERO_DOCUMENTO = UN_TYPE_T_DETALLE_DESCUENTO(I)
              .MI_NUMERO_DOCUMENTO
           AND ITEM = UN_TYPE_T_DETALLE_DESCUENTO(I).MI_ITEM;
      
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          --PR_DESPLIEGA_MENSAJE('AL_STOP_1','Atención : Informacion de valor bruto no se encontro en la tabla de información exogena.');
          RETURN('Atención : Informacion de valor bruto no se encontro en la tabla de información exogena. Número Documento ' || UN_TYPE_T_DETALLE_DESCUENTO(I)
                 .MI_NUMERO_DOCUMENTO || ' Item ' || UN_TYPE_T_DETALLE_DESCUENTO(I)
                 .MI_ITEM);
        WHEN OTHERS THEN
          --PR_DESPLIEGA_MENSAJE('AL_STOP_1','Atención : Ocurrio el siguiente error seleccionando la información exogena.');
          RETURN('Atención : Ocurrio el siguiente error seleccionando la información exogena. Número Documento ' || UN_TYPE_T_DETALLE_DESCUENTO(I)
                 .MI_NUMERO_DOCUMENTO || ' Item ' || UN_TYPE_T_DETALLE_DESCUENTO(I)
                 .MI_ITEM);
      END;

    
      IF UN_TYPE_T_DETALLE_DESCUENTO(I).MI_VALOR_DESCUENTO > MI_VALOR_BRUTO THEN
        --PR_DESPLIEGA_MENSAJE('AL_STOP_1','Atención : Valor de descuento no puede ser mayor a máximo valor bruto.');
        RETURN('Atención : Valor de descuento no puede ser mayor a máximo valor bruto. Valor descuento ' || UN_TYPE_T_DETALLE_DESCUENTO(I)
               .MI_VALOR_DESCUENTO || ' Valor Bruto ' || MI_VALOR_BRUTO ||
               '. Número Documento ' || UN_TYPE_T_DETALLE_DESCUENTO(I)
               .MI_NUMERO_DOCUMENTO || ' Item ' || UN_TYPE_T_DETALLE_DESCUENTO(I)
               .MI_ITEM);
      END IF;
    
      -- 23-05-2003. Sergio.
      -- Validar que el descuento sea mayor que cero.
    
      IF UN_TYPE_T_DETALLE_DESCUENTO(I).MI_VALOR_DESCUENTO <= 0 THEN
        --PR_DESPLIEGA_MENSAJE('AL_STOP_1','Atención : Valor de descuento no puede ser mayor a máximo valor bruto.');
        RETURN('Atención : Valor de descuento no puede ser menor o igual a cero. Número Documento ' || UN_TYPE_T_DETALLE_DESCUENTO(I)
               .MI_NUMERO_DOCUMENTO || ' Item ' || UN_TYPE_T_DETALLE_DESCUENTO(I)
               .MI_ITEM);
      END IF;
    
      -- Crear el detalle de descuento.
    
      BEGIN
      
        INSERT INTO OGT_DETALLE_DESCUENTO
          (VIGENCIA,
           ENTIDAD,
           UNIDAD_EJECUTORA,
           TIPO_DOCUMENTO,
           CONSECUTIVO,
           RUBRO_INTERNO,
           VIGENCIA_PRESUPUESTO,
           DISPONIBILIDAD,
           REGISTRO,
           NUMERO_DOCUMENTO,
           ITEM,
           CODIGO_INTERNO,
           FECHA_GRABACION,
           VALOR_BASE_RETENCION,
           VALOR_DESCUENTO)
        VALUES
          (UN_TYPE_T_DETALLE_DESCUENTO(I).MI_VIGENCIA,
           UN_TYPE_T_DETALLE_DESCUENTO(I).MI_ENTIDAD,
           UN_TYPE_T_DETALLE_DESCUENTO(I).MI_UNIDAD_EJECUTORA,
           UN_TYPE_T_DETALLE_DESCUENTO(I).MI_TIPO_DOCUMENTO,
           UN_TYPE_T_DETALLE_DESCUENTO(I).MI_CONSECUTIVO,
           UN_TYPE_T_DETALLE_DESCUENTO(I).MI_RUBRO_INTERNO,
           TO_NUMBER(UN_TYPE_T_DETALLE_DESCUENTO(I).MI_VIGENCIA),
           UN_TYPE_T_DETALLE_DESCUENTO(I).MI_DISPONIBILIDAD,
           UN_TYPE_T_DETALLE_DESCUENTO(I).MI_REGISTRO,
           UN_TYPE_T_DETALLE_DESCUENTO(I).MI_NUMERO_DOCUMENTO,
           UN_TYPE_T_DETALLE_DESCUENTO(I).MI_ITEM,
           UN_TYPE_T_DETALLE_DESCUENTO(I).MI_CODIGO_INTERNO,
           TO_DATE(TO_CHAR(SYSDATE, 'DDMMYYHH24MISS'), 'DDMMYYHH24MISS'),
           UN_TYPE_T_DETALLE_DESCUENTO(I).MI_VALOR_BASE_RETENCION,
           UN_TYPE_T_DETALLE_DESCUENTO(I).MI_VALOR_DESCUENTO);
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          --PR_DESPLIEGA_MENSAJE('AL_STOP_1','Atención : Detalle de descuento ya existe.');
          RETURN('Atención : Detalle de descuento ya existe. ' || UN_TYPE_T_DETALLE_DESCUENTO(I)
                 .MI_CONSECUTIVO || '-' || UN_TYPE_T_DETALLE_DESCUENTO(I)
                 .MI_RUBRO_INTERNO || '-' || UN_TYPE_T_DETALLE_DESCUENTO(I)
                 .MI_DISPONIBILIDAD || '-' || UN_TYPE_T_DETALLE_DESCUENTO(I)
                 .MI_REGISTRO || '-' || UN_TYPE_T_DETALLE_DESCUENTO(I)
                 .MI_NUMERO_DOCUMENTO || '-' || UN_TYPE_T_DETALLE_DESCUENTO(I)
                 .MI_ITEM || '-' || UN_TYPE_T_DETALLE_DESCUENTO(I)
                 .MI_CODIGO_INTERNO);
        WHEN OTHERS THEN
          --PR_DESPLIEGA_MENSAJE('AL_STOP_1','Atención : No se pudo crear el detalle de descuento porque sucedio el siguiente error.'||SQLERRM);
          RETURN('Atención : No se pudo crear el detalle de descuento porque sucedio el siguiente error. Número Documento ' || UN_TYPE_T_DETALLE_DESCUENTO(I)
                 .MI_NUMERO_DOCUMENTO || ' Item ' || UN_TYPE_T_DETALLE_DESCUENTO(I)
                 .MI_ITEM || '. ' || SQLERRM);
      END;
    END LOOP;
    RETURN(0);
  END FN_OGT_BD_CREAR_DETALLE_DESCUE;

  --Funcion que retorna tabla con los descuentos de egresos.

  FUNCTION FN_OGT_BD_DESCUENTOS RETURN T_DESCUENTOS IS
    CURSOR C_DESCUENTOS IS
      SELECT *
        FROM OGT_DESCUENTO
       WHERE CODIGO_INTERNO > 0
         AND (FECHA_FINAL IS NULL OR FECHA_FINAL > SYSDATE)
       ORDER BY CODIGO_INTERNO;
    I                    NUMBER := 0;
    UN_TYPE_T_DESCUENTOS T_DESCUENTOS;
  BEGIN
    FOR R_DESCUENTOS IN C_DESCUENTOS LOOP
      I := I + 1;
      UN_TYPE_T_DESCUENTOS(I).MI_CODIGO_INTERNO := R_DESCUENTOS.CODIGO_INTERNO;
      UN_TYPE_T_DESCUENTOS(I).MI_CUENTA_CONTABLE := R_DESCUENTOS.CUENTA_CONTABLE;
      UN_TYPE_T_DESCUENTOS(I).MI_PORCENTAJE := R_DESCUENTOS.PORCENTAJE;
      UN_TYPE_T_DESCUENTOS(I).MI_BASE_MINIMA := R_DESCUENTOS.BASE_MINIMA;
      UN_TYPE_T_DESCUENTOS(I).MI_FECHA_INICIAL := R_DESCUENTOS.FECHA_INICIAL;
      UN_TYPE_T_DESCUENTOS(I).MI_CODIGO_ACTIVIDAD := R_DESCUENTOS.CODIGO_ACTIVIDAD;
      UN_TYPE_T_DESCUENTOS(I).MI_FECHA_FINAL := R_DESCUENTOS.FECHA_FINAL;
      UN_TYPE_T_DESCUENTOS(I).MI_DESCRIPCION_CODIGO := R_DESCUENTOS.DESCRIPCION_CODIGO;
    END LOOP;
    --message('UN_TYPE_T_DESCUENTOS '||UN_TYPE_T_DESCUENTOS.count);
    RETURN UN_TYPE_T_DESCUENTOS;
  END FN_OGT_BD_DESCUENTOS;

  -- Función que permite recuperar el id. del descuento.

  FUNCTION FN_OGT_ID_DESCUENTO(UNA_CUENTA_CONTABLE VARCHAR2,
                               UN_PORCENTAJE       NUMBER) RETURN NUMBER IS
    MI_ID_DESCUENTO NUMBER;
  BEGIN
    SELECT CODIGO_INTERNO
      INTO MI_ID_DESCUENTO
      FROM OGT_DESCUENTO
     WHERE CODIGO_INTERNO > 0
       AND CUENTA_CONTABLE = UNA_CUENTA_CONTABLE
       AND PORCENTAJE = UN_PORCENTAJE
       AND FECHA_INICIAL <= SYSDATE
       AND (FECHA_FINAL >= SYSDATE OR FECHA_FINAL IS NULL);
    RETURN MI_ID_DESCUENTO;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END FN_OGT_ID_DESCUENTO;

  --Funcion que retorna tabla con las actividades economicas.

  FUNCTION FN_OGT_BD_ACT_ECONOMICA RETURN T_ACTIVIDADES IS
    CURSOR C_ACTIVIDADES IS
      SELECT *
        FROM OGT_ACTIVIDAD_ECONOMICA
       WHERE CODIGO_ACTIVIDAD > 0
       ORDER BY CODIGO_ACTIVIDAD;
    I                     NUMBER := 0;
    UN_TYPE_T_ACTIVIDADES T_ACTIVIDADES;
  BEGIN
    FOR R_ACTIVIDADES IN C_ACTIVIDADES LOOP
      I := I + 1;
      UN_TYPE_T_ACTIVIDADES(I).MI_CODIGO_ACTIVIDAD := R_ACTIVIDADES.CODIGO_ACTIVIDAD;
      UN_TYPE_T_ACTIVIDADES(I).MI_NOMBRE_ACTIVIDAD := R_ACTIVIDADES.NOMBRE_ACTIVIDAD;
      UN_TYPE_T_ACTIVIDADES(I).MI_PORCENTAJE := R_ACTIVIDADES.PORCENTAJE;
    END LOOP;
    RETURN UN_TYPE_T_ACTIVIDADES;
  END FN_OGT_BD_ACT_ECONOMICA;

  -- Funcion que permite crear un detalle de pago para abono en cuenta o cheque.

  FUNCTION FN_OGT_BD_CREA_DET_PAGO(UN_ID_PAGO                NUMBER,
                                   UN_COMPROBANTE_EGRESO     NUMBER,
                                   UNA_FORMA_PAGO            VARCHAR2,
                                   UN_BANCO_GIRADOR          NUMBER,
                                   UNA_CUENTA_BANCO_GIRADOR  VARCHAR2,
                                   UN_TIPO_CUENTA_GIRADOR    VARCHAR2,
                                   UN_BANCO_RECEPTOR         NUMBER,
                                   UNA_CUENTA_BANCO_RECEPTOR VARCHAR2,
                                   UN_TIPO_CUENTA_RECEPTOR   VARCHAR2,
                                   UN_VALOR                  NUMBER,
                                   UN_TER_ID_RECEPTOR        NUMBER)
    RETURN NUMBER IS
    MI_CONSECUTIVO NUMBER(20);
  BEGIN
    PK_SECUENCIAL.PR_VALIDA_CONSECUTIVO('OPGET',
                                        'COMPROBANTE',
                                        '0000',
                                        '000',
                                        '00');
    MI_CONSECUTIVO := PK_SECUENCIAL.FN_TRAER_CONSECUTIVO('OPGET',
                                                         'COMPROBANTE',
                                                         '0000',
                                                         '000',
                                                         '00') + 1;
    PK_SECUENCIAL.PR_ACTUALIZAR_CONSECUTIVO(MI_CONSECUTIVO);
    INSERT INTO OGT_DETALLE_PAGO
      (ID_PAGO,
       COMPROBANTE_EGRESO,
       FORMA_PAGO,
       BANCO_GIRADOR,
       CUENTA_BANCO_GIRADOR,
       TIPO_CUENTA_GIRADOR,
       BANCO_RECEPTOR,
       CUENTA_BANCO_RECEPTOR,
       TIPO_CUENTA_RECEPTOR,
       ESTADO,
       VALOR,
       TER_ID_RECEPTOR)
    VALUES
      (UN_ID_PAGO,
       MI_CONSECUTIVO,
       UNA_FORMA_PAGO,
       UN_BANCO_GIRADOR,
       UNA_CUENTA_BANCO_GIRADOR,
       UN_TIPO_CUENTA_GIRADOR,
       UN_BANCO_RECEPTOR,
       UNA_CUENTA_BANCO_RECEPTOR,
       UN_TIPO_CUENTA_RECEPTOR,
       'P',
       UN_VALOR,
       UN_TER_ID_RECEPTOR);
    RETURN(0);
  EXCEPTION
    WHEN OTHERS THEN
      --RAISE_APPLICATION_ERROR(-20001,'Atención : Ocurrio el siguiente error creando el detalle de pago. '||SQLERRM);
      PR_DESPLIEGA_MENSAJE('AL_STOP_1',
                           'Atención : Ocurrio el siguiente error creando el detalle de pago. ' ||
                           SQLERRM);
      RETURN(1);
  END FN_OGT_BD_CREA_DET_PAGO;

  -- Función que imprime las ordenes de pago.                             

  FUNCTION FN_OGT_IMPRIME_OP(UNA_VIGENCIA         VARCHAR2,
                             UNA_ENTIDAD          VARCHAR2,
                             UNA_UNIDAD_EJECUTORA VARCHAR2,
                             UN_CONSECUTIVO       VARCHAR2,
                             UN_REPORTE           REPORT_OBJECT)
    RETURN NUMBER IS
    MI_REPORTE         VARCHAR2(200);
    MI_CONDICION_ENVIO VARCHAR2(4500);
    MI_RESULTADO       NUMBER;
  BEGIN
    MI_CONDICION_ENVIO := ' AND (OGT_DOCUMENTO_PAGO.VIGENCIA = ' || CHR(39) ||
                          UNA_VIGENCIA || CHR(39) ||
                          ' AND OGT_DOCUMENTO_PAGO.ENTIDAD = ' || CHR(39) ||
                          UNA_ENTIDAD || CHR(39) ||
                          ' AND OGT_DOCUMENTO_PAGO.UNIDAD_EJECUTORA = ' ||
                          CHR(39) || UNA_UNIDAD_EJECUTORA || CHR(39) ||
                          ' AND OGT_DOCUMENTO_PAGO.TIPO_DOCUMENTO = ' ||
                          CHR(39) || 'OP' || CHR(39) ||
                          ' AND OGT_DOCUMENTO_PAGO.CONSECUTIVO = ' ||
                          CHR(39) || UN_CONSECUTIVO || CHR(39) || ')';
    MI_REPORTE         := 'OGT_REP_OP';
    IF GET_APPLICATION_PROPERTY(USER_INTERFACE) = 'WEB' THEN
      PK_EGR_ORDEN_PAGO.PR_IMPRIMIR_RUN_REPORT_OBJECT(MI_CONDICION_ENVIO,
                                                      MI_RESULTADO);
    ELSE
      PK_EGR_ORDEN_PAGO.PR_IMPRIMIR_RUN_PRODUCT(MI_CONDICION_ENVIO,
                                                MI_RESULTADO,
                                                UN_REPORTE);
    END IF;
    IF MI_RESULTADO = 0 THEN
      RETURN 0;
    ELSE
      RETURN 1;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      PR_DESPLIEGA_MENSAJE('AL_STOP_1',
                           'Atención : Error imprimiendo reporte. ' ||
                           SQLERRM);
      RETURN 1;
  END;

  PROCEDURE PR_IMPRIMIR_RUN_PRODUCT(UNA_CONDICION_ENVIO IN VARCHAR2,
                                    UN_RESULTADO        OUT NUMBER,
                                    UN_REPORTE          REPORT_OBJECT) IS
    -- DECLARA LISTA DE PARÁMETROS
    LISTA_PARAMETROS  PARAMLIST;
    MI_SQLERRM        VARCHAR2(250);
    MI_NOMBRE_REPORTE VARCHAR2(100) := 'OGT_REP_OP';
    MI_CONDICION      VARCHAR2(2000);
  BEGIN
    MI_NOMBRE_REPORTE := REPLACE(UPPER(MI_NOMBRE_REPORTE), '.REP', '');
    LISTA_PARAMETROS  := GET_PARAMETER_LIST('TMPDATA');
    IF NOT ID_NULL(LISTA_PARAMETROS) THEN
      DESTROY_PARAMETER_LIST(LISTA_PARAMETROS);
    END IF;
    LISTA_PARAMETROS := CREATE_PARAMETER_LIST('TMPDATA');
    ADD_PARAMETER(LISTA_PARAMETROS, 'PARAMFORM', TEXT_PARAMETER, 'NO');
    ADD_PARAMETER(LISTA_PARAMETROS,
                  'P_CONDICION',
                  TEXT_PARAMETER,
                  UNA_CONDICION_ENVIO);
    --MI_NOMBRE_REPORTE := GET_REPORT_OBJECT_PROPERTY (MI_REPORTE, REPORT_FILENAME);
    MI_NOMBRE_REPORTE := REPLACE(UPPER(MI_NOMBRE_REPORTE), '.REP', '');
    --MI_REPORTE:=FIND_REPORT_OBJECT(MI_NOMBRE_REPORTE);
    MI_NOMBRE_REPORTE := RUN_REPORT_OBJECT(UN_REPORTE, LISTA_PARAMETROS);
    UN_RESULTADO      := 0;
  EXCEPTION
    WHEN OTHERS THEN
      PR_DESPLIEGA_MENSAJE('AL_STOP_1',
                           'Atención : Error en cliente-servidor. ' ||
                           SQLERRM);
      UN_RESULTADO := 1;
  END;

  /********************************************************************************
  PROCEDIMIENTO: PR_IMPRIMIR_RUN_REPORT_OBJECT
  DESCRIPCION: PROCEDIMIENTO A PARTIR DEL CUAL SE VISUALIZA EL REPORTE CON RUN_REPORT_OBJECT
  *********************************************************************************/

  PROCEDURE PR_IMPRIMIR_RUN_REPORT_OBJECT(UNA_CONDICION_ENVIO IN VARCHAR2,
                                          UN_RESULTADO        OUT NUMBER) IS
    MI_PARAMETRO      VARCHAR2(3000);
    MI_NOMBRE_REPORTE VARCHAR2(100) := 'OGT_REP_OP';
    MI_RUNFORMAT      VARCHAR2(10);
    MI_REPORTE        REPORT_OBJECT;
  BEGIN
    MI_NOMBRE_REPORTE := REPLACE(UPPER(MI_NOMBRE_REPORTE), '.RDF', '');
    MI_RUNFORMAT      := 'PDF';
    MI_PARAMETRO      := 'P_CONDICION=''' || UNA_CONDICION_ENVIO || '''';
    PK_OGT_REPORTES.FN_OGT_RUN_REPORT_OBJECT(MI_NOMBRE_REPORTE,
                                             MI_PARAMETRO,
                                             MI_RUNFORMAT,
                                             'OPGET');
    UN_RESULTADO := 0;
  EXCEPTION
    WHEN OTHERS THEN
      PR_DESPLIEGA_MENSAJE('AL_STOP_1',
                           'Atención : Error en cliente-servidor. ' ||
                           SQLERRM);
      UN_RESULTADO := 1;
  END;

  -- Funcion que evalua los registros presupuestales de una orden de pago y retorna 0 si
  -- todos los RP tienen fondos suficientes para ser pagado, o 1 si al menos un RP no 
  -- tiene fondos suficientes.

  FUNCTION fn_ogt_valida_presupuesto(mi_vigencia         VARCHAR2,
                                     mi_entidad          VARCHAR2,
                                     mi_unidad_ejecutora VARCHAR2,
                                     mi_tipo_documento   VARCHAR2,
                                     mi_consecutivo      VARCHAR2,
                                     mi_tipo_op          NUMBER)
    RETURN NUMBER IS
    w_sin_pres    NUMBER(10) := 0;
    w_total       NUMBER(20, 2) := 0;
    w_mi_entidad  VARCHAR2(3);
    mi_valor_uno  VARCHAR2(1) := '1';
    mi_valor_cero VARCHAR2(1) := '0';
    CURSOR c_exogena IS
    -- 18-08-2003. Sergio.
    -- Adicionar la unidad ejecutora.
      SELECT vigencia_presupuesto,
             entidad_presupuesto MI_ENTIDAD,
             a.unidad_ejecutora,
             rubro_interno,
             disponibilidad,
             registro,
             SUM(NVL(valor_bruto, 0)) valor_bruto
        FROM ogt_orden_pago a, ogt_informacion_exogena b
       WHERE a.unidad_ejecutora = b.unidad_ejecutora
         AND a.entidad = b.entidad
         AND a.consecutivo = b.consecutivo
         AND a.vigencia = b.vigencia
         AND a.tipo_documento = b.tipo_documento
         AND a.unidad_ejecutora = mi_unidad_ejecutora
         AND a.entidad = mi_entidad
         AND a.consecutivo = mi_consecutivo
         AND a.tipo_documento = mi_tipo_documento
         AND a.vigencia = mi_vigencia
         AND SUBSTR(a.estado, 9, 1) != mi_valor_uno -- No esten anuladas
       GROUP BY vigencia_presupuesto,
                entidad_presupuesto,
                a.unidad_ejecutora,
                rubro_interno,
                disponibilidad,
                registro;
  BEGIN
    --w_mi_entidad := mi_entidad;  
  
    --PR_DESPLIEGA_MENSAJE('AL_STOP_1','ENTRO A VALIDAR PRESUPUESTO....');
  
    FOR r_exogena IN c_exogena LOOP
      IF mi_tipo_op != 2 THEN
      

        w_total := PK_EGR_ORDEN_PAGO.CALCULA_TOTAL_RP_TEMP(TO_NUMBER(mi_vigencia),
                                                           R_EXOGENA.MI_ENTIDAD,
                                                           mi_unidad_ejecutora,
                                                           r_exogena.registro,
                                                           r_exogena.disponibilidad,
                                                           r_exogena.rubro_interno);
      
      ELSE

        w_total := PK_EGR_ORDEN_PAGO.CALCULA_TOTAL_CDP_TEMP(TO_NUMBER(mi_vigencia),
                                                            R_EXOGENA.MI_ENTIDAD,
                                                            mi_unidad_ejecutora,
                                                            r_exogena.disponibilidad,
                                                            r_exogena.rubro_interno);
      
      END IF;
      -- Registro presupuestal agotado.
      --pr_despliega_mensaje('al_stop_1','w_total '||w_total||' r_exogena.valor_bruto '||r_exogena.valor_bruto);
      IF (NVL(w_total, 0) - NVL(r_exogena.valor_bruto, 0)) < 0 THEN
        PR_DESPLIEGA_MENSAJE('AL_STOP_1',
                             'Atención : En la orden de pago ' ||
                             MI_VIGENCIA || '-' || R_EXOGENA.MI_ENTIDAD || '-' ||
                             MI_UNIDAD_EJECUTORA || '-' || MI_CONSECUTIVO ||
                             ' Registro presupuestal agotado para la Disponibilidad ' ||
                             r_exogena.disponibilidad || ' Registro ' ||
                             r_exogena.registro || '. Total Registro ' ||
                             w_total || '. Total Gastado ' ||
                             r_exogena.valor_bruto || '.');
        w_sin_pres := w_sin_pres + 1;
      END IF;
    END LOOP;
  
    -- Si encuentra mas de un RP agotado retorna 1, sino retorna 0
  
    IF w_sin_pres > 0 THEN
      RETURN(1);
    ELSE
      RETURN(0);
    END IF;
  END fn_ogt_valida_presupuesto;

  -- Función que contabiliza en PREDIS los RPs de las OPs

  FUNCTION FN_OGT_CONTABILIZA_PREDIS(UNA_VIGENCIA         VARCHAR2,
                                     UNA_ENTIDAD          VARCHAR2,
                                     UNA_UNIDAD_EJECUTORA VARCHAR2,
                                     UN_TIPO_DOCUMENTO    VARCHAR2,
                                     UN_CONSECUTIVO       VARCHAR2,
                                     UN_PROCESO           VARCHAR2)
    RETURN VARCHAR2 IS
    MI_R_OP           PK_OGT_OP.ORDEN_PAGO_TYPE;
    MI_CUR_REGISTRO   PK_OGT_OP.CUR_RP;
    MI_REG_REGISTRO   PK_OGT_OP.RP_TYPE;
    MI_TIPO_VIGENCIA  VARCHAR2(50);
    MI_ID_LIMAY       NUMBER(20);
    MI_CLASE          VARCHAR2(20);
    MI_VALOR_BRUTO_RP NUMBER(20, 2);
  BEGIN
    --       IF UNA_ENTIDAD = :global.g_codEntidad THEN     
    IF UN_TIPO_DOCUMENTO = 'OP' THEN
      MI_R_OP := PK_OGT_OP.FN_OGT_ORDEN_PAGO(UNA_VIGENCIA,
                                             UNA_ENTIDAD,
                                             UNA_UNIDAD_EJECUTORA,
                                             UN_TIPO_DOCUMENTO,
                                             UN_CONSECUTIVO);
    END IF;
    MI_CUR_REGISTRO := PK_OGT_OP.FN_OGT_RP_PAGO(UNA_VIGENCIA,
                                                UNA_ENTIDAD,
                                                UNA_UNIDAD_EJECUTORA,
                                                UN_TIPO_DOCUMENTO,
                                                UN_CONSECUTIVO);
    LOOP
      FETCH MI_CUR_REGISTRO
        INTO MI_REG_REGISTRO;
      EXIT WHEN MI_CUR_REGISTRO%NOTFOUND;
      IF (UN_PROCESO = 'PAGO' AND MI_REG_REGISTRO.MI_ID_LIMAY_PAGO IS NULL) OR
         (UN_PROCESO = 'ANULAR_PAGO' AND
         MI_REG_REGISTRO.ID_LIMAY_ANULACION_PAGO IS NULL) OR
         (UN_PROCESO = 'GIRO_PRESUPUESTAL' AND
         MI_REG_REGISTRO.MI_ID_LIMAY_GIRO_PRESUPUESTAL IS NULL) OR
         (UN_PROCESO = 'ANULAR_GIRO_PRESUPUESTAL' AND
         MI_REG_REGISTRO.ID_LIMAY_ANULACION_GIRO IS NULL) THEN
      
        -- Traer el valor bruto para este RP en el documento
      
        MI_VALOR_BRUTO_RP := PK_OGT_OP.FN_OGT_BRUTO_RP(UNA_VIGENCIA,
                                                       UNA_ENTIDAD,
                                                       UNA_UNIDAD_EJECUTORA,
                                                       UN_TIPO_DOCUMENTO,
                                                       UN_CONSECUTIVO,
                                                       MI_REG_REGISTRO.MI_RUBRO_INTERNO,
                                                       MI_REG_REGISTRO.MI_DISPONIBILIDAD,
                                                       MI_REG_REGISTRO.MI_REGISTRO);
        IF UN_PROCESO = 'GIRO_PRESUPUESTAL' THEN
          MI_CLASE := 'CONSTITUCION';
          IF MI_R_OP.MI_TIPO_VIGENCIA = 'R' THEN
            MI_TIPO_VIGENCIA := 'GP RESERVAS';
          ELSIF MI_R_OP.MI_TIPO_VIGENCIA = 'C' THEN
            MI_TIPO_VIGENCIA := 'CUENTAS POR PAGAR';
          ELSIF MI_R_OP.MI_TIPO_VIGENCIA = 'V' THEN
            MI_TIPO_VIGENCIA := 'GP VIGENCIA';
          END IF;
        ELSIF UN_PROCESO = 'PAGO' THEN
          MI_CLASE := 'PAGOS';
          IF MI_R_OP.MI_TIPO_VIGENCIA = 'R' THEN
            MI_TIPO_VIGENCIA := 'OP RESERVAS';
          ELSIF MI_R_OP.MI_TIPO_VIGENCIA = 'C' THEN
            MI_TIPO_VIGENCIA := 'CUENTAS POR PAGAR';
          ELSIF MI_R_OP.MI_TIPO_VIGENCIA = 'V' THEN
            MI_TIPO_VIGENCIA := 'OP VIGENCIA';
          END IF;
        ELSIF UN_PROCESO = 'ANULAR_GIRO_PRESUPUESTAL' THEN
          MI_CLASE := 'ANULACION';
          IF MI_R_OP.MI_TIPO_VIGENCIA = 'R' THEN
            MI_TIPO_VIGENCIA := 'CONST GP RESERVAS';
          ELSIF MI_R_OP.MI_TIPO_VIGENCIA = 'C' THEN
            MI_TIPO_VIGENCIA := 'CONST CUENTAS POR PAGAR';
          ELSIF MI_R_OP.MI_TIPO_VIGENCIA = 'V' THEN
            MI_TIPO_VIGENCIA := 'CONST GP VIGENCIA';
          END IF;
        ELSIF UN_PROCESO = 'ANULAR_PAGO' THEN
          MI_CLASE := 'ANULACION';
          IF MI_R_OP.MI_TIPO_VIGENCIA = 'R' THEN
            MI_TIPO_VIGENCIA := 'PAGOS OP RESERVAS';
          ELSIF MI_R_OP.MI_TIPO_VIGENCIA = 'C' THEN
            MI_TIPO_VIGENCIA := 'PAGOS CUENTAS POR PAGAR';
          ELSIF MI_R_OP.MI_TIPO_VIGENCIA = 'V' THEN
            MI_TIPO_VIGENCIA := 'PAGOS OP VIGENCIA';
          END IF;
        END IF;
        MI_ID_LIMAY := PK_PRE_TESORERIA.FN_PRE_CONTAB_PAGOS(TO_NUMBER(UNA_VIGENCIA),
                                                            MI_REG_REGISTRO.MI_ENTIDAD_PRESUPUESTO,
                                                            UNA_UNIDAD_EJECUTORA,
                                                            MI_CLASE,
                                                            MI_TIPO_VIGENCIA,
                                                            TO_NUMBER(UN_CONSECUTIVO),
                                                            MI_REG_REGISTRO.MI_REGISTRO,
                                                            MI_REG_REGISTRO.MI_DISPONIBILIDAD,
                                                            'EGRESO',
                                                            SYSDATE,
                                                            MI_REG_REGISTRO.MI_RUBRO_INTERNO,
                                                            MI_VALOR_BRUTO_RP,
                                                            MI_R_OP.MI_TER_ID);
        IF MI_ID_LIMAY > 0 THEN
          -- Actualizar ID_LIMAY_GIRO DE OGT_REGISTRO_PRESUPUESTAL.
          IF UN_PROCESO = 'GIRO_PRESUPUESTAL' THEN
            UPDATE OGT_REGISTRO_PRESUPUESTAL
               SET ID_LIMAY_GIRO_PRESUPUESTAL = NVL(MI_ID_LIMAY, 0),
                   FECHA_GIRO_PRESUPUESTAL    = TO_DATE(TO_CHAR(SYSDATE,
                                                                'DDMMYYHH24MISS'),
                                                        'DDMMYYHH24MISS'),
                   USUARIO_GIRO_PRESUPUESTAL  = USER
             WHERE REGISTRO = MI_REG_REGISTRO.MI_REGISTRO
               AND TIPO_DOCUMENTO = UN_TIPO_DOCUMENTO
               AND DISPONIBILIDAD = MI_REG_REGISTRO.MI_DISPONIBILIDAD
               AND CONSECUTIVO = UN_CONSECUTIVO
               AND ENTIDAD = UNA_ENTIDAD
               AND UNIDAD_EJECUTORA = UNA_UNIDAD_EJECUTORA
               AND VIGENCIA = UNA_VIGENCIA
               AND VIGENCIA_PRESUPUESTO = UNA_VIGENCIA
               AND RUBRO_INTERNO = MI_REG_REGISTRO.MI_RUBRO_INTERNO
               AND ID_LIMAY_GIRO_PRESUPUESTAL IS NULL;
          ELSIF UN_PROCESO = 'PAGO' THEN
            UPDATE OGT_REGISTRO_PRESUPUESTAL
               SET ID_LIMAY_PAGO = NVL(MI_ID_LIMAY, 0),
                   FECHA_PAGO    = TO_DATE(TO_CHAR(SYSDATE, 'DDMMYYHH24MISS'),
                                           'DDMMYYHH24MISS'),
                   USUARIO_PAGO  = USER
             WHERE REGISTRO = MI_REG_REGISTRO.MI_REGISTRO
               AND TIPO_DOCUMENTO = UN_TIPO_DOCUMENTO
               AND DISPONIBILIDAD = MI_REG_REGISTRO.MI_DISPONIBILIDAD
               AND CONSECUTIVO = UN_CONSECUTIVO
               AND ENTIDAD = UNA_ENTIDAD
               AND UNIDAD_EJECUTORA = UNA_UNIDAD_EJECUTORA
               AND VIGENCIA = UNA_VIGENCIA
               AND VIGENCIA_PRESUPUESTO = UNA_VIGENCIA
               AND RUBRO_INTERNO = MI_REG_REGISTRO.MI_RUBRO_INTERNO
               AND ID_LIMAY_PAGO IS NULL;
          ELSIF UN_PROCESO = 'ANULAR_GIRO_PRESUPUESTAL' THEN
            UPDATE OGT_REGISTRO_PRESUPUESTAL
               SET ID_LIMAY_ANULACION_GIRO = NVL(MI_ID_LIMAY, 0),
                   FECHA_ANULACION_GIRO    = TO_DATE(TO_CHAR(SYSDATE,
                                                             'DDMMYYHH24MISS'),
                                                     'DDMMYYHH24MISS'),
                   USUARIO_ANULACION_GIRO  = USER
             WHERE REGISTRO = MI_REG_REGISTRO.MI_REGISTRO
               AND TIPO_DOCUMENTO = UN_TIPO_DOCUMENTO
               AND DISPONIBILIDAD = MI_REG_REGISTRO.MI_DISPONIBILIDAD
               AND CONSECUTIVO = UN_CONSECUTIVO
               AND ENTIDAD = UNA_ENTIDAD
               AND UNIDAD_EJECUTORA = UNA_UNIDAD_EJECUTORA
               AND VIGENCIA = UNA_VIGENCIA
               AND VIGENCIA_PRESUPUESTO = UNA_VIGENCIA
               AND RUBRO_INTERNO = MI_REG_REGISTRO.MI_RUBRO_INTERNO
               AND ID_LIMAY_ANULACION_GIRO IS NULL;
          ELSIF UN_PROCESO = 'ANULAR_PAGO' THEN
            UPDATE OGT_REGISTRO_PRESUPUESTAL
               SET ID_LIMAY_ANULACION_PAGO = NVL(MI_ID_LIMAY, 0),
                   FECHA_ANULACION_PAGO    = TO_DATE(TO_CHAR(SYSDATE,
                                                             'DDMMYYHH24MISS'),
                                                     'DDMMYYHH24MISS'),
                   USUARIO_ANULACION_PAGO  = USER
             WHERE REGISTRO = MI_REG_REGISTRO.MI_REGISTRO
               AND TIPO_DOCUMENTO = UN_TIPO_DOCUMENTO
               AND DISPONIBILIDAD = MI_REG_REGISTRO.MI_DISPONIBILIDAD
               AND CONSECUTIVO = UN_CONSECUTIVO
               AND ENTIDAD = UNA_ENTIDAD
               AND UNIDAD_EJECUTORA = UNA_UNIDAD_EJECUTORA
               AND VIGENCIA = UNA_VIGENCIA
               AND VIGENCIA_PRESUPUESTO = UNA_VIGENCIA
               AND RUBRO_INTERNO = MI_REG_REGISTRO.MI_RUBRO_INTERNO
               AND ID_LIMAY_ANULACION_PAGO IS NULL;
          END IF;
          RETURN '1';
        ELSE
          RETURN '0';
        END IF;
      END IF;
    END LOOP;
    --      END IF;
    RETURN '1';
  EXCEPTION
    WHEN OTHERS THEN
      PR_DESPLIEGA_MENSAJE('AL_STOP_1',
                           'Atención : Error contabilizando PREDIS en el documento ' ||
                           UNA_VIGENCIA || '-' || UNA_ENTIDAD || '-' ||
                           UNA_UNIDAD_EJECUTORA || '-' || UN_CONSECUTIVO || '.');
      RETURN '0';
  END;

  -- Función que actualiza en PREDIS el esta del registro presupuestal.

  FUNCTION FN_OGT_REVERSAR_GIRO_PRES(UNA_VIGENCIA         VARCHAR2,
                                     UNA_ENTIDAD          VARCHAR2,
                                     UNA_UNIDAD_EJECUTORA VARCHAR2,
                                     UN_TIPO_DOCUMENTO    VARCHAR2,
                                     UN_CONSECUTIVO       VARCHAR2)
    RETURN VARCHAR2 IS
    MI_CUR_REGISTRO PK_OGT_OP.CUR_RP;
    MI_REG_REGISTRO PK_OGT_OP.RP_TYPE;
  BEGIN
    -- Recuperar cada uno de los RPs de la OP.
    MI_CUR_REGISTRO := PK_OGT_OP.FN_OGT_RP_PAGO(UNA_VIGENCIA,
                                                UNA_ENTIDAD,
                                                UNA_UNIDAD_EJECUTORA,
                                                UN_TIPO_DOCUMENTO,
                                                UN_CONSECUTIVO);
    LOOP
      --pr_despliega_mensaje('al_stop_1','1...Entro a anular orden de pago '||una_vigencia||'-'||una_entidad||'-'||una_unidad_ejecutora||'-'||un_tipo_documento||'-'||un_consecutivo);        
      FETCH MI_CUR_REGISTRO
        INTO MI_REG_REGISTRO;
      --pr_despliega_mensaje('al_stop_1','2...Entro a anular orden de pago '||una_vigencia||'-'||una_entidad||'-'||una_unidad_ejecutora||'-'||un_tipo_documento||'-'||un_consecutivo);         
      EXIT WHEN MI_CUR_REGISTRO%NOTFOUND;
      --pr_despliega_mensaje('al_stop_1','3...Entro a anular orden de pago '||una_vigencia||'-'||una_entidad||'-'||una_unidad_ejecutora||'-'||un_tipo_documento||'-'||un_consecutivo);         
      PK_PRE_ANULACION_TOTAL.PR_PRE_ANULAR_ORDEN(UNA_VIGENCIA,
                                                 UNA_ENTIDAD,
                                                 UNA_UNIDAD_EJECUTORA,
                                                 UN_CONSECUTIVO,
                                                 MI_REG_REGISTRO.MI_REGISTRO,
                                                 MI_REG_REGISTRO.MI_DISPONIBILIDAD,
                                                 UN_CONSECUTIVO);
    
      --pr_despliega_mensaje('al_stop_1','4...Entro a anular orden de pago '||una_vigencia||'-'||una_entidad||'-'||una_unidad_ejecutora||'-'||un_tipo_documento||'-'||un_consecutivo);
    
      IF PK_PRE_ANULACION_TOTAL.GLOBAL_ERROR_ANULACION = -1 THEN
      
        --pr_despliega_mensaje('al_stop_1','5...Entro a anular orden de pago '||una_vigencia||'-'||una_entidad||'-'||una_unidad_ejecutora||'-'||un_tipo_documento||'-'||un_consecutivo);           
      
        RETURN '0';
      ELSE
      
        --pr_despliega_mensaje('al_stop_1','6...Entro a anular orden de pago '||una_vigencia||'-'||una_entidad||'-'||una_unidad_ejecutora||'-'||un_tipo_documento||'-'||un_consecutivo);           
      
        RETURN '1';
      END IF;
    END LOOP;
  
    --pr_despliega_mensaje('al_stop_1','7...Entro a anular orden de pago '||una_vigencia||'-'||una_entidad||'-'||una_unidad_ejecutora||'-'||un_tipo_documento||'-'||un_consecutivo);      
  
    RETURN '1';
  EXCEPTION
    WHEN OTHERS THEN
      PR_DESPLIEGA_MENSAJE('AL_STOP_1',
                           'Atención : Error reversando giro presupuestal. ' ||
                           SQLERRM);
      RETURN '0';
  END;

  -- Funcion que evalua los registros presupuestales de una orden de pago y retorna 0 si
  -- todos los RP tienen fondos suficientes para ser pagado, o 1 si al menos un RP no 
  -- tiene fondos suficientes.

  FUNCTION fn_ogt_valida_pac(mi_vigencia         VARCHAR2,
                             mi_entidad          VARCHAR2,
                             mi_unidad_ejecutora VARCHAR2,
                             mi_tipo_documento   VARCHAR2,
                             mi_consecutivo      VARCHAR2) RETURN NUMBER IS
  BEGIN
    NULL;
  END fn_ogt_valida_pac;

  -- OJO : FUNCION TEMPORAL, MIENTRAS SE ADICIONA EL PARAMETRO DE RUBRO INTERNO EN
  -- fn_pre_total_rp.

  FUNCTION CALCULA_TOTAL_RP_TEMP(UNA_VIGENCIA         VARCHAR2,
                                 UNA_ENTIDAD          VARCHAR2,
                                 UNA_UNIDAD_EJECUTORA VARCHAR2,
                                 UN_REGISTRO          NUMBER,
                                 UNA_DISPONIBILIDAD   NUMBER,
                                 UN_RUBRO_INTERNO     NUMBER) RETURN NUMBER IS
    W_TOTAL_RP NUMBER(20, 2);
  BEGIN
  
    --PR_DESPLIEGA_MENSAJE('AL_STOP_1','ENTRO A CALCULAR EL TOTAL RP....');  
  
    SELECT SUM(rd.valor) --INTO mi_total 
      INTO W_TOTAL_RP
      FROM pr_registro_disponibilidad rd
     WHERE rd.vigencia = UNA_VIGENCIA
       AND rd.codigo_compania = UNA_ENTIDAD
       AND rd.codigo_unidad_ejecutora = UNA_UNIDAD_EJECUTORA
       AND rd.numero_registro = UN_REGISTRO
       AND rd.numero_disponibilidad = UNA_DISPONIBILIDAD
       AND RD.RUBRO_INTERNO = UN_RUBRO_INTERNO
     GROUP BY rd.vigencia,
              rd.codigo_compania,
              rd.codigo_unidad_ejecutora,
              rd.numero_registro,
              rd.numero_disponibilidad,
              RD.RUBRO_INTERNO;
    RETURN(W_TOTAL_RP);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 0;
  END;

  -- OJO : FUNCION TEMPORAL, MIENTRAS SE ADICIONA EL PARAMETRO DE RUBRO INTERNO EN
  -- fn_pre_total_cdp.

  FUNCTION CALCULA_TOTAL_CDP_TEMP(una_vigencia       NUMBER,
                                  una_compania       VARCHAR2,
                                  una_unidad         VARCHAR2,
                                  una_disponibilidad NUMBER,
                                  UN_RUBRO_INTERNO   NUMBER) RETURN NUMBER IS
    mi_valor_cdp NUMBER(20, 2);
  BEGIN
    SELECT NVL(SUM(VALOR), 0)
      INTO mi_valor_cdp
      FROM pr_disponibilidad_rubro
     WHERE vigencia = una_vigencia
       AND codigo_compania = una_compania
       AND codigo_unidad_ejecutora = una_unidad
       AND numero_disponibilidad = una_disponibilidad
       AND RUBRO_INTERNO = UN_RUBRO_INTERNO;
    RETURN mi_valor_cdp;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 0;
  END;

END;
