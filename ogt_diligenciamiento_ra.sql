PROCEDURE PR_VALIDA_RA(UN_ESTADO VARCHAR2) IS
  -- RECIBE UN PARAMETRO Y DEACUERDO A EL HACE LA VALIDACION CORRESPONDIENTE
  -- LOS PARAMETROS PUEDEN SER
  -- PAC     VALIDA PAC
  -- PREDIS  VALIDA PREDIS
  -- CC       VALIDA CENTRO DE COSTOS
  -- AN      VALIDA ANEXO DE NOMINA
  -- AE      VALIDA ANEXO DE EMBARGOS
  -- AA      VALIDA ANEXO DE APORTES
  -- TODO    VALIDA TODO
  MI_RESULTADO           NUMBER;
  MI_RETORNO             VARCHAR2(1000);
  MI_SALDO               NUMBER;
  MI_APORTE              NUMBER;
  MI_ERROR               VARCHAR2(100);
  MI_ESTADO              OGT_RELACION_AUTORIZACION.ESTADO%TYPE;
  MI_TAB_PAGE            VARCHAR2(50);
  MI_MENSAJE             VARCHAR2(4000);
  MI_MENSAJE_SIDIF       VARCHAR2(3000);
  MI_MENSAJE_INCAPACIDAD VARCHAR2(100);
  MI_DATO_PREDIS         VARCHAR2(1000);

  MI_VALIDA_PREDIS            VARCHAR2(1);
  MI_VALIDA_PAC               VARCHAR2(1);
  MI_VALIDA_CONTAB            VARCHAR2(1);
  W_TEMPO                     NUMBER;
  W_SIN_PAC                   NUMBER := 0;
  w_valida_pres               NUMBER := 0;
  W_ENTIDAD_TEMP              VARCHAR2(3);
  mi_opcion                   number;
  MI_MARCA                    NUMBER;
  MI_CUR_REGISTRO             PK_OGT_OP.CUR_RP;
  MI_REG_REGISTRO             PK_OGT_OP.RP_TYPE;
  MI_VALOR_PAC_TOTAL          NUMBER;
  MI_VALOR_PAC_COMPROMETIDO   NUMBER;
  MI_VALOR_PAC_EJECUTADO      NUMBER;
  MI_VALOR_PAC_POR_PAGAR      NUMBER;
  MI_VALIDA_PAC_COMPROMETIDO  VARCHAR2(500);
  MI_INDICATIVO_VALIDA_PREDIS VARCHAR2(250);
  MI_INDICATIVO_VALIDA_PAC    VARCHAR2(250);
  MI_DATO_PAC                 VARCHAR2(500);
  MI_VALOR_BRUTO_RP           NUMBER(20, 2);
  MI_TOTAL_RP                 NUMBER(20, 2);
  MI_TIPO_VIGENCIA            VARCHAR2(1);

  dbmserrcode NUMBER;
  dbmserrtext VARCHAR2(200);
BEGIN
  If Not Form_Success Then
    dbmserrcode := DBMS_ERROR_CODE;
    dbmserrtext := DBMS_ERROR_TEXT;
  End If;
  DEFAULT_VALUE('BIEN', 'GLOBAL.VALIDA_INCAPACIDAD');
  MI_MENSAJE  := NULL;
  MI_TAB_PAGE := GET_CANVAS_PROPERTY('C_CARPETAS', TOPMOST_TAB_PAGE);
  GO_BLOCK('OGT_CENTRO_COSTOS');
  PR_POBLAR_VALOR_CARGADO_CC;
  MI_ESTADO := :OGT_RELACION_AUTORIZACION.ESTADO;

  IF :OGT_DOCUMENTO_PAGO.CONSECUTIVO IS NOT NULL THEN
    -- NO DEBE PERMITIR VALIDA SI NO HACE NINGUN PAGO
    IF :TOTALES.VALOR_REGISTRO_POSITIVO <= 0 And
       Nvl(:OGT_RELACION_AUTORIZACION.NUMERO_COMPROMISO, -1) <> 0 THEN
      -- Fargel RQ-2010546
      MI_MENSAJE           := MI_MENSAJE || ' ' ||
                              'No se puede diligenciar una RA que no genere pago';
      :GLOBAL.ANEXO_VALIDO := 1;
    ELSE
      :GLOBAL.ANEXO_VALIDO := 0;
    END IF;
  
    -- COMIENZA LAS VALIDACIONES
    IF UN_ESTADO IN ('PAC', 'TODO') THEN
      -- FMD 4-11-2003
      -- NO VALIDA PAC NI PREDIS LAS RA SSF
      IF :OGT_RELACION_AUTORIZACION.SITUACION_FONDOS = 1
        -- fargel: 20100317 RQ2010-546, Para las RA de Pensionados se usará Numero de compromiso
        -- cero (0) y no requerirá información de imputación presupuestal.
         And :OGT_RELACION_AUTORIZACION.NUMERO_COMPROMISO <> 0 THEN
        -- CON SITUACION DE FONDOS        
        OGT_PK_RA.PR_VALIDAR_PAC(:OGT_DOCUMENTO_PAGO.ENTIDAD,
                                 :OGT_DOCUMENTO_PAGO.UNIDAD,
                                 :OGT_DOCUMENTO_PAGO.VIGENCIA,
                                 :OGT_DOCUMENTO_PAGO.CONSECUTIVO,
                                 :OGT_RELACION_AUTORIZACION.TIPO_RA,
                                 :OGT_RELACION_AUTORIZACION.MES,
                                 :OGT_RELACION_AUTORIZACION.FECHA_DESDE,
                                 MI_RETORNO);
      ELSE
        MI_RETORNO := 'Si Es una RA sin situacion de fondos'; -- ASUME QUE SIEMPRE TIENE PAC
      END IF;
    
      IF SUBSTR(MI_RETORNO, 1, 2) = 'No' THEN
        :GLOBAL.PAC_VALIDO := 1;
        MI_MENSAJE         := MI_MENSAJE || ' ' || 'No tiene PAC';
      ELSE
        :GLOBAL.PAC_VALIDO := 0;
      END IF;
    
      IF UN_ESTADO = 'PAC' THEN
        PR_DESPLIEGA_MENSAJE('AL_STOP_1', MI_RETORNO);
      END IF;
    
      -- ACTUALIZO EL ESTADO EN LA RA
      :GLOBAL.PAC_VALIDO := 0;
      PR_CAMBIA_POSICION_ESTADO_ITEM(2, :GLOBAL.PAC_VALIDO, MI_ESTADO);
    END IF;
  
    -- fargel: 20100317 RQ2010-546, Para las RA de Pensionados se usará Numero de compromiso
    -- cero (0) y no requerirá información de imputación presupuestal.
    IF UN_ESTADO IN ('PREDIS', 'TODO') And
       :OGT_RELACION_AUTORIZACION.NUMERO_COMPROMISO <> 0 THEN
      -- FMD 4-11-2003
      -- NO VALIDA PAC NI PREDIS LAS RA SSF
    
      /* SERGIO, AQUI SE VALIDA PREDIS */
    
      MI_INDICATIVO_VALIDA_PREDIS := PK_OGT_OP.FN_OGT_VALOR_BINTABLAS('OPGET',
                                                                      'VALIDA_PREDIS',
                                                                      'INDICATIVO_VALIDA_PREDIS',
                                                                      SYSDATE);
       --return SI

      MI_INDICATIVO_VALIDA_PAC    := PK_OGT_OP.FN_OGT_VALOR_BINTABLAS('OPGET',
                                                                      'VALIDA_PAC',
                                                                      'INDICATIVO_VALIDA_PAC',
                                                                      SYSDATE);
      MI_CUR_REGISTRO             := PK_OGT_OP.FN_OGT_RP_PAGO(:OGT_RELACION_AUTORIZACION.VIGENCIA,
                                                              :OGT_DOCUMENTO_PAGO.ENTIDAD,
                                                              :OGT_RELACION_AUTORIZACION.UNIDAD_EJECUTORA,
                                                              'RA',
                                                              :OGT_RELACION_AUTORIZACION.CONSECUTIVO);
                                        --return OGT_REGISTRO_PRESUPUESTAL
      LOOP
        FETCH MI_CUR_REGISTRO
          INTO MI_REG_REGISTRO;
        EXIT WHEN MI_CUR_REGISTRO%NOTFOUND;
        IF MI_INDICATIVO_VALIDA_PAC = 'SI' THEN
          MI_TIPO_VIGENCIA := PK_OGT_OP.FN_OGT_TIPO_VIGENCIA(TO_NUMBER(:OGT_RELACION_AUTORIZACION.VIGENCIA),
                                                             TO_NUMBER(TO_CHAR(:OGT_RELACION_AUTORIZACION.FECHA_DESDE,
                                                                               'YYYY')),
                                                             TO_NUMBER(TO_CHAR(:OGT_RELACION_AUTORIZACION.FECHA_RADICACION,
                                                                               'YYYY')));
                                --Return 'V'                                                                               
          MI_DATO_PAC      := PK_OGT_OP.FN_OGT_DATOS_PAC_COMP(MI_TIPO_VIGENCIA,
                                                              :OGT_RELACION_AUTORIZACION.VIGENCIA,
                                                              MI_REG_REGISTRO.MI_ENTIDAD_PRESUPUESTO,
                                                              :OGT_DOCUMENTO_PAGO.ENTIDAD,
                                                              :OGT_RELACION_AUTORIZACION.UNIDAD_EJECUTORA,
                                                              :OGT_RELACION_AUTORIZACION.TIPO_DOCUMENTO,
                                                              :OGT_RELACION_AUTORIZACION.CONSECUTIVO,
                                                              :OGT_REGISTRO_PRESUPUESTAL.ANO_PAC,
                                                              :OGT_REGISTRO_PRESUPUESTAL.MES_PAC,
                                                              MI_REG_REGISTRO.MI_RUBRO_INTERNO,
                                                              MI_REG_REGISTRO.MI_REGISTRO,
                                                              MI_REG_REGISTRO.MI_DISPONIBILIDAD);
                            --Return 0 si hay pac
          IF MI_DATO_PAC = '0' THEN
            MI_VALIDA_PAC := '1';
          ELSE
            MI_VALIDA_PAC := '0';
            --            PR_DESPLIEGA_MENSAJE('AL_STOP_1',MI_DATO_PAC);
            :GLOBAL.PAC_VALIDO := 1;
            MI_MENSAJE         := MI_MENSAJE || MI_DATO_PAC;
          END IF;
        ELSE
          MI_VALIDA_PAC := '1';
        END IF;
        IF MI_INDICATIVO_VALIDA_PREDIS = 'SI' THEN
          MI_VALOR_BRUTO_RP := PK_OGT_OP.FN_OGT_BRUTO_RP(:OGT_RELACION_AUTORIZACION.VIGENCIA,
                                                         :OGT_DOCUMENTO_PAGO.ENTIDAD,
                                                         :OGT_RELACION_AUTORIZACION.UNIDAD_EJECUTORA,
                                                         'RA',
                                                         :OGT_RELACION_AUTORIZACION.CONSECUTIVO,
                                                         MI_REG_REGISTRO.MI_RUBRO_INTERNO,
                                                         MI_REG_REGISTRO.MI_DISPONIBILIDAD,
                                                         MI_REG_REGISTRO.MI_REGISTRO);
                                -- RETURN NVL(MI_VALOR_BRUTO_OP,0) + NVL(MI_VALOR_BRUTO_RA,0);
          MI_TOTAL_RP       := PK_EGR_ORDEN_PAGO.CALCULA_TOTAL_RP_TEMP(TO_NUMBER(:OGT_RELACION_AUTORIZACION.VIGENCIA),
                                                                       :OGT_DOCUMENTO_PAGO.ENTIDAD,
                                                                       :OGT_RELACION_AUTORIZACION.UNIDAD_EJECUTORA,
                                                                       MI_REG_REGISTRO.MI_REGISTRO,
                                                                       MI_REG_REGISTRO.MI_DISPONIBILIDAD,
                                                                       MI_REG_REGISTRO.MI_RUBRO_INTERNO);
          IF (NVL(MI_TOTAL_RP, 0) - NVL(MI_VALOR_BRUTO_RP, 0)) < 0 THEN
            --            PR_DESPLIEGA_MENSAJE('AL_STOP_1','Atención : En el documento '||:OGT_RELACION_AUTORIZACION.VIGENCIA||'-'||:OGT_DOCUMENTO_PAGO.ENTIDAD||'-'||:OGT_RELACION_AUTORIZACION.UNIDAD_EJECUTORA||'-'||:OGT_RELACION_AUTORIZACION.CONSECUTIVO||' Registro presupuestal agotado para la Disponibilidad '||MI_REG_REGISTRO.MI_DISPONIBILIDAD||' Registro '||MI_REG_REGISTRO.MI_REGISTRO||'. Total Registro '||MI_TOTAL_RP||'. Total Gastado '||MI_VALOR_BRUTO_RP||'.');
            MI_DATO_PREDIS        := ' RP agotado para el CDP ' ||
                                     MI_REG_REGISTRO.MI_DISPONIBILIDAD ||
                                     ' RP ' || MI_REG_REGISTRO.MI_REGISTRO ||
                                     '. Total RP ' || MI_TOTAL_RP ||
                                     '. Gastado ' || MI_VALOR_BRUTO_RP;
            MI_VALIDA_PREDIS      := '0';
            :GLOBAL.PREDIS_VALIDO := 1;
            MI_MENSAJE            := MI_MENSAJE || MI_DATO_PREDIS;
          ELSE
            MI_VALIDA_PREDIS := '1';
          END IF;
        ELSE
          MI_VALIDA_PREDIS := '1';
        END IF;
      END LOOP;
      CLOSE MI_CUR_REGISTRO;
    
      /* HASTA AQUI VAN LAS VALIDACIONES */
    
      IF :OGT_RELACION_AUTORIZACION.SITUACION_FONDOS = 1 -- CON SITUACION DE FONDOS
        -- fargel: 20100317 RQ2010-546, Para las RA de Pensionados se usará Numero de compromiso
        -- cero (0) y no requerirá información de imputación presupuestal.
         And :OGT_RELACION_AUTORIZACION.NUMERO_COMPROMISO <> 0 Then
        OGT_PK_RA.PR_VALIDAR_PREDIS(:OGT_DOCUMENTO_PAGO.ENTIDAD,
                                    :OGT_DOCUMENTO_PAGO.UNIDAD,
                                    :OGT_DOCUMENTO_PAGO.VIGENCIA,
                                    :OGT_DOCUMENTO_PAGO.CONSECUTIVO,
                                    MI_RETORNO);
      ELSE
        MI_RETORNO := 'Si Es una RA sin situacion de fondos'; -- ASUME QUE SIEMPRE TIENE PAC
      END IF;
    
      IF SUBSTR(MI_RETORNO, 1, 2) = 'No' THEN
        :GLOBAL.PREDIS_VALIDO := 1;
        MI_MENSAJE            := MI_MENSAJE || ' ' || 'No tiene PREDIS';
      ELSE
        :GLOBAL.PREDIS_VALIDO := 0;
      END IF;
    
      IF UN_ESTADO = 'PREDIS' THEN
        PR_DESPLIEGA_MENSAJE('AL_STOP_1', MI_RETORNO);
      END IF;
    
      -- ACTUALIZO EL ESTADO EN LA RA
      :GLOBAL.PREDIS_VALIDO := 0;
    Else
      :GLOBAL.PREDIS_VALIDO := 0;
    END IF;
    PR_CAMBIA_POSICION_ESTADO_ITEM(1, :GLOBAL.PREDIS_VALIDO, MI_ESTADO);
  
    -- VALIDA CENTRO DE COSTOS
    IF UN_ESTADO IN ('CC', 'TODO') THEN
      IF ((:OGT_RELACION_AUTORIZACION.SITUACION_FONDOS = 1 -- CON SITUACION DE FONDOS
         -- fargel: 20100317 RQ2010-546, Para las RA de Pensionados se usará Numero de compromiso
         -- cero (0) y no requerirá información de imputación presupuestal.
         And :OGT_RELACION_AUTORIZACION.NUMERO_COMPROMISO <> 0) AND
         NVL(:TOTALES.VALOR_CARGADO, 0) = NVL(:TOTALES.VALOR_REGISTRO, 0) AND
         NVL(:TOTALES.VALOR_CARGADO, 0) <> 0 AND
         NVL(:TOTALES.VALOR_REGISTRO, 0) <> 0) OR
         (:OGT_RELACION_AUTORIZACION.SITUACION_FONDOS = 0 -- SIN SITUACION DE FONDOS
         AND NVL(:TOTALES.VALOR_CC, 0) = NVL(:TOTALES.VALOR_REGISTRO, 0) AND
         NVL(:TOTALES.VALOR_CC, 0) <> 0 AND
         NVL(:TOTALES.VALOR_REGISTRO, 0) <> 0)
        -- fargel: 20100317 RQ2010-546, Para las RA de Pensionados se usará Numero de compromiso
        -- cero (0) y no requerirá información de imputación presupuestal.
         Or :OGT_RELACION_AUTORIZACION.NUMERO_COMPROMISO = 0 THEN
        :GLOBAL.CC_VALIDO := 0;
      ELSE
        :GLOBAL.CC_VALIDO := 1;
        MI_MENSAJE        := MI_MENSAJE || ' ' ||
                             'Los valores incluidos en el total cargado del Centro de Costos no coinciden con el valor de la Imputacion Presupuestal de la RA';
      END IF;
    
      IF UN_ESTADO = 'CC' AND :GLOBAL.CC_VALIDO = 1 THEN
        IF :OGT_RELACION_AUTORIZACION.SITUACION_FONDOS = 1 -- CON SITUACION DE FONDOS
          -- fargel: 20100317 RQ2010-546, Para las RA de Pensionados se usará Numero de compromiso
          -- cero (0) y no requerirá información de imputación presupuestal.
           And :OGT_RELACION_AUTORIZACION.NUMERO_COMPROMISO <> 0 THEN
          PR_DESPLIEGA_MENSAJE('AL_STOP_1',
                               'Los valores incluidos en el total cargado del Centro de Costos no coinciden con el valor de la Imputacion Presupuestal de la RA');
        ELSIF :OGT_RELACION_AUTORIZACION.SITUACION_FONDOS = 0 -- SIN SITUACION DE FONDOS                                                                                        
             -- fargel: 20100317 RQ2010-546, Para las RA de Pensionados se usará Numero de compromiso
             -- cero (0) y no requerirá información de imputación presupuestal.
              Or :OGT_RELACION_AUTORIZACION.NUMERO_COMPROMISO = 0 Then
          PR_DESPLIEGA_MENSAJE('AL_STOP_1',
                               'Los valores incluidos en el valor total del Centro de Costos no coinciden con el valor de la Imputacion Presupuestal de la RA');
        END IF;
      ELSIF UN_ESTADO = 'CC' AND :GLOBAL.CC_VALIDO = 0 THEN
        PR_DESPLIEGA_MENSAJE('AL_STOP_1',
                             'Los valores incluidos en el Centro de Costos si coinciden con el total de la RA');
      END IF;
    
      -- VALIDACION DE QUE POR ANEXO SEA IGUAL EL REGISTRADO Y EL CARGADO
      IF :TOTALES.VALOR_DIFERENCIA = 0 THEN
        :GLOBAL.CC_VALIDO_ANEXO := 0;
      ELSE
        :GLOBAL.CC_VALIDO_ANEXO := 1;
        MI_MENSAJE              := MI_MENSAJE || ' ' ||
                                   'Los valores incluidos en algun anexo del Centro de Costos no coinciden el cargado con el diligenciado';
      END IF;
    
      IF UN_ESTADO = 'CC' AND :GLOBAL.CC_VALIDO_ANEXO = 1 THEN
        PR_DESPLIEGA_MENSAJE('AL_STOP_1',
                             'Los valores incluidos en algun anexo del Centro de Costos no coinciden el cargado con el diligenciado');
      ELSIF UN_ESTADO = 'CC' AND :GLOBAL.CC_VALIDO_ANEXO = 0 THEN
        PR_DESPLIEGA_MENSAJE('AL_STOP_1',
                             'Los valores incluidos en loa anexos del Centro de Costos son iguales');
      END IF;
    
      -- ACTUALIZO EL ESTADO EN LA RA
      PR_CAMBIA_POSICION_ESTADO_ITEM(10, :GLOBAL.CC_VALIDO, MI_ESTADO);
    
      -- ACTUALIZO EL ESTADO EN LA RA
      -- NO CAMBIO EL ESTADO DEL CC A VALIDO SI ESTA INVALIDO
      IF :GLOBAL.CC_VALIDO = 0 THEN
        PR_CAMBIA_POSICION_ESTADO_ITEM(10,
                                       :GLOBAL.CC_VALIDO_ANEXO,
                                       MI_ESTADO);
      END IF;
    
    END IF;
  
    -- VALIDA ANEXO EMBARGOS
    IF UN_ESTADO IN ('AE') AND :OGT_RELACION_AUTORIZACION.TIPO_RA = 1 THEN
    
      IF NOT ((:OGT_RELACION_AUTORIZACION.SITUACION_FONDOS = 1 -- CON SITUACION DE FONDOS
          AND NVL(:OGT_CENTRO_COSTOS.TOTAL_CARGADO, 0) =
          NVL(:TOTALES.VALOR_ANEXO_EMBARGO, 0) AND
          NVL(:OGT_CENTRO_COSTOS.TOTAL_CARGADO, 0) <> 0 AND
          NVL(:TOTALES.VALOR_ANEXO_EMBARGO, 0) <> 0) OR
          (:OGT_RELACION_AUTORIZACION.SITUACION_FONDOS = 0 -- SIN SITUACION DE FONDOS
          AND NVL(:OGT_CENTRO_COSTOS.VALOR, 0) =
          NVL(:TOTALES.VALOR_ANEXO_EMBARGO, 0) AND
          NVL(:OGT_CENTRO_COSTOS.VALOR, 0) <> 0 AND
          NVL(:TOTALES.VALOR_ANEXO_EMBARGO, 0) <> 0)) THEN
        :GLOBAL.ANEXO_VALIDO := 1;
      END IF;
    
      IF UN_ESTADO = 'AE' AND :GLOBAL.ANEXO_VALIDO = 1 THEN
        IF :OGT_RELACION_AUTORIZACION.SITUACION_FONDOS = 1 THEN
          -- CON SITUACION DE FONDOS                  
          PR_DESPLIEGA_MENSAJE('AL_STOP_1',
                               'El valor de la relacion de Anexo de Aportes Embargos ' ||
                               'no corresponde al valor cargado en el total del concepto en la Relacion ' ||
                               'de Centro de Costos');
        ELSIF :OGT_RELACION_AUTORIZACION.SITUACION_FONDOS = 0 THEN
          -- SIN SITUACION DE FONDOS                                                     
          PR_DESPLIEGA_MENSAJE('AL_STOP_1',
                               'El valor de la relacion de Anexo de Aportes Embargos ' ||
                               'no corresponde al valor diligenciado en el total del concepto en la Relacion ' ||
                               'de Centro de Costos');
        END IF;
      ELSIF UN_ESTADO = 'AE' AND :GLOBAL.ANEXO_VALIDO = 0 THEN
        PR_DESPLIEGA_MENSAJE('AL_STOP_1',
                             'El valor de la relacion de Anexo de Aportes Embargos ' ||
                             'si corresponde al valor diligenciado en el total del concepto en la Relacion ' ||
                             'de Centro de Costos');
      END IF;
    END IF;
  
    -- VALIDA ANEXO NOMINA
    IF UN_ESTADO IN ('AN') AND :OGT_RELACION_AUTORIZACION.TIPO_RA = 1 THEN
      IF NOT ((:OGT_RELACION_AUTORIZACION.SITUACION_FONDOS = 1 -- CON SITUACION DE FONDOS
          AND NVL(:OGT_CENTRO_COSTOS.TOTAL_CARGADO, 0) =
          NVL(:TOTALES.VALOR_ANEXO_NOMINA, 0) AND
          NVL(:OGT_CENTRO_COSTOS.TOTAL_CARGADO, 0) <> 0 AND
          NVL(:TOTALES.VALOR_ANEXO_NOMINA, 0) <> 0) OR
          (:OGT_RELACION_AUTORIZACION.SITUACION_FONDOS = 0 -- SIN SITUACION DE FONDOS
          AND NVL(:OGT_CENTRO_COSTOS.VALOR, 0) =
          NVL(:TOTALES.VALOR_ANEXO_NOMINA, 0) AND
          NVL(:OGT_CENTRO_COSTOS.VALOR, 0) <> 0 AND
          NVL(:TOTALES.VALOR_ANEXO_NOMINA, 0) <> 0)) THEN
        :GLOBAL.ANEXO_VALIDO := 1;
      END IF;
      IF UN_ESTADO = 'AN' AND :GLOBAL.ANEXO_VALIDO = 1 THEN
      
        IF :OGT_RELACION_AUTORIZACION.SITUACION_FONDOS = 1 THEN
          -- CON SITUACION DE FONDOS          
          PR_DESPLIEGA_MENSAJE('AL_STOP_1',
                               'El valor de la relacion de Anexo de Nomina ' ||
                               'no corresponde al valor cargado en el total del concepto ' ||
                               'en la Relacion de Centro de Costos');
        ELSIF :OGT_RELACION_AUTORIZACION.SITUACION_FONDOS = 0 THEN
          -- SIN SITUACION DE FONDOS                                                     
          PR_DESPLIEGA_MENSAJE('AL_STOP_1',
                               'El valor de la relacion de Anexo de Nomina ' ||
                               'no corresponde al valor diligenciado en el total del concepto ' ||
                               'en la Relacion de Centro de Costos');
        END IF;
      ELSIF UN_ESTADO = 'AN' AND :GLOBAL.ANEXO_VALIDO = 0 THEN
        PR_DESPLIEGA_MENSAJE('AL_STOP_1',
                             'El valor de la relacion de Anexo de Nomina ' ||
                             'si corresponde al valor diligenciado en el total del concepto ' ||
                             'en la Relacion de Centro de Costos');
      END IF;
    END IF;
  
    -- VALIDAR ANEXO NOMINA Y EMBARGOS
    IF UN_ESTADO IN ('TODO') AND :OGT_RELACION_AUTORIZACION.TIPO_RA = 1 THEN
      IF (OGT_PK_RA.OGT_FN_TOTAL_ANEXOS_NOMINA(:OGT_DOCUMENTO_PAGO.VIGENCIA,
                                               :OGT_DOCUMENTO_PAGO.ENTIDAD,
                                               :OGT_DOCUMENTO_PAGO.UNIDAD,
                                               'RA',
                                               :OGT_RELACION_AUTORIZACION.CONSECUTIVO,
                                               :OGT_RELACION_AUTORIZACION.TIPO_RA,
                                               :OGT_RELACION_AUTORIZACION.MES,
                                               :OGT_RELACION_AUTORIZACION.FECHA_DESDE) <>
         NVL(:TOTALES.VALOR_CARGADO, 0) AND
         NVL(:TOTALES.VALOR_REGISTRO, 0) <> NVL(:TOTALES.VALOR_CARGADO, 0) AND
         (:OGT_RELACION_AUTORIZACION.SITUACION_FONDOS = '1' -- CON SITUACION DE FONDOS
         -- fargel: 20100317 RQ2010-546, Para las RA de Pensionados se usará Numero de compromiso
         -- cero (0) y no requerirá información de imputación presupuestal.
         And :OGT_RELACION_AUTORIZACION.NUMERO_COMPROMISO <> 0)) OR
         (OGT_PK_RA.OGT_FN_TOTAL_ANEXOS_NOMINA(:OGT_DOCUMENTO_PAGO.VIGENCIA,
                                               :OGT_DOCUMENTO_PAGO.ENTIDAD,
                                               :OGT_DOCUMENTO_PAGO.UNIDAD,
                                               'RA',
                                               :OGT_RELACION_AUTORIZACION.CONSECUTIVO,
                                               :OGT_RELACION_AUTORIZACION.TIPO_RA,
                                               :OGT_RELACION_AUTORIZACION.MES,
                                               :OGT_RELACION_AUTORIZACION.FECHA_DESDE) <>
         NVL(:TOTALES.VALOR_CC, 0) AND
         NVL(:TOTALES.VALOR_REGISTRO, 0) <> NVL(:TOTALES.VALOR_CC, 0) AND
         (:OGT_RELACION_AUTORIZACION.SITUACION_FONDOS = '0' -- SIN SITUACION DE FONDOS
         -- fargel: 20100317 RQ2010-546, Para las RA de Pensionados se usará Numero de compromiso
         -- cero (0) y no requerirá información de imputación presupuestal.
         Or :OGT_RELACION_AUTORIZACION.NUMERO_COMPROMISO = 0)) THEN
        :GLOBAL.ANEXO_VALIDO := 1;
      END IF;
    
      IF UN_ESTADO = 'TODO' AND :GLOBAL.ANEXO_VALIDO = 1 THEN
        IF :OGT_RELACION_AUTORIZACION.SITUACION_FONDOS = 1 THEN
          -- CON SITUACION DE FONDOS          
          MI_MENSAJE := MI_MENSAJE || ' ' ||
                        'Los valores de los Anexos de Nomina y Embargos ' ||
                        'no corresponden al valor cargado en el total de la ' ||
                        'Relacion de Centro de Costos';
        ELSIF :OGT_RELACION_AUTORIZACION.SITUACION_FONDOS = 0 THEN
          -- SIN SITUACION DE FONDOS                                                     
          MI_MENSAJE := MI_MENSAJE || ' ' ||
                        'Los valores de los Anexos de Nomina y Embargos ' ||
                        'no corresponden al valor diligenciado en el total de la ' ||
                        'Relacion de Centro de Costos';
        END IF;
      END IF;
    END IF;
  
    -- VALIDAR ANEXO PATRONAL
    IF UN_ESTADO IN ('AA', 'TODO') AND
       :OGT_RELACION_AUTORIZACION.TIPO_RA = 2 THEN
      IF (OGT_PK_RA.OGT_FN_TOTAL_UN_ANEXO_PATRONAL(:OGT_DOCUMENTO_PAGO.VIGENCIA,
                                                   :OGT_DOCUMENTO_PAGO.ENTIDAD,
                                                   :OGT_DOCUMENTO_PAGO.UNIDAD,
                                                   'RA',
                                                   :OGT_RELACION_AUTORIZACION.CONSECUTIVO,
                                                   :OGT_RELACION_AUTORIZACION.TIPO_RA,
                                                   :OGT_RELACION_AUTORIZACION.MES,
                                                   :OGT_RELACION_AUTORIZACION.FECHA_DESDE,
                                                   :OGT_CENTRO_COSTOS.CODIGO_CENTRO_COSTOS) <>
         NVL(:OGT_CENTRO_COSTOS.TOTAL_CARGADO, 0) AND
         :OGT_RELACION_AUTORIZACION.SITUACION_FONDOS = 1) -- CON SITUACION DE FONDOS
         OR (OGT_PK_RA.OGT_FN_TOTAL_UN_ANEXO_PATRONAL(:OGT_DOCUMENTO_PAGO.VIGENCIA,
                                                      :OGT_DOCUMENTO_PAGO.ENTIDAD,
                                                      :OGT_DOCUMENTO_PAGO.UNIDAD,
                                                      'RA',
                                                      :OGT_RELACION_AUTORIZACION.CONSECUTIVO,
                                                      :OGT_RELACION_AUTORIZACION.TIPO_RA,
                                                      :OGT_RELACION_AUTORIZACION.MES,
                                                      :OGT_RELACION_AUTORIZACION.FECHA_DESDE,
                                                      :OGT_CENTRO_COSTOS.CODIGO_CENTRO_COSTOS) <>
         NVL(:OGT_CENTRO_COSTOS.VALOR, 0) AND
         :OGT_RELACION_AUTORIZACION.SITUACION_FONDOS = 1) -- CON SITUACION DE FONDOS                
       THEN
        :GLOBAL.ANEXO_VALIDO := 1;
      END IF;
      OGT_PK_RA.OGT_PR_VALIDA_INCAPACIDAD(:OGT_RELACION_AUTORIZACION.VIGENCIA,
                                          :OGT_RELACION_AUTORIZACION.ENTIDAD_RA,
                                          :OGT_RELACION_AUTORIZACION.UNIDAD_EJECUTORA,
                                          :OGT_RELACION_AUTORIZACION.TIPO_DOCUMENTO,
                                          :OGT_RELACION_AUTORIZACION.CONSECUTIVO,
                                          :OGT_RELACION_AUTORIZACION.TIPO_RA,
                                          :OGT_RELACION_AUTORIZACION.MES,
                                          :OGT_RELACION_AUTORIZACION.FECHA_DESDE,
                                          MI_MENSAJE_INCAPACIDAD);
    
      IF MI_MENSAJE_INCAPACIDAD = 'MAL' THEN
        MI_MENSAJE           := MI_MENSAJE || ' ' ||
                                'La sumatoria de las incapacidades y el saldo ' ||
                                'superan la sumatoria del aporte patronal y el empleado';
        :GLOBAL.ANEXO_VALIDO := 1;
      END IF;
    
      IF UN_ESTADO = 'AA' AND :GLOBAL.ANEXO_VALIDO = 1 THEN
        IF :OGT_RELACION_AUTORIZACION.SITUACION_FONDOS = 1 THEN
          -- CON SITUACION DE FONDOS          
          PR_DESPLIEGA_MENSAJE('AL_STOP_1',
                               'El valor de la relacion de Anexo de Aportes ' ||
                               'no corresponde al valor cargado en el total del concepto ' ||
                               'en la Relacion de Centro de Costos');
        ELSIF :OGT_RELACION_AUTORIZACION.SITUACION_FONDOS = 0 THEN
          -- SIN SITUACION DE FONDOS                                                     
          PR_DESPLIEGA_MENSAJE('AL_STOP_1',
                               'El valor de la relacion de Anexo de Aportes ' ||
                               'no corresponde al valor diligenciado en el total del concepto ' ||
                               'en la Relacion de Centro de Costos');
        END IF;
      ELSIF UN_ESTADO = 'AA' AND :GLOBAL.ANEXO_VALIDO = 0 THEN
        PR_DESPLIEGA_MENSAJE('AL_STOP_1',
                             'El valor de la relacion de Anexo Patronal ' ||
                             'si corresponde al valor diligenciado en la Relacion ' ||
                             'de Centro de Costos');
      END IF;
    
      IF UN_ESTADO = 'TODO' AND :GLOBAL.ANEXO_VALIDO = 1 THEN
        IF :OGT_RELACION_AUTORIZACION.SITUACION_FONDOS = 1 THEN
          -- CON SITUACION DE FONDOS          
          MI_MENSAJE := MI_MENSAJE || ' ' ||
                        'El valor de la relacion de Anexo de Aportes ' ||
                        'no corresponde al valor cargado en el total del concepto ' ||
                        'en la Relacion de Centro de Costos';
        ELSIF :OGT_RELACION_AUTORIZACION.SITUACION_FONDOS = 0 THEN
          -- SIN SITUACION DE FONDOS                                                     
          MI_MENSAJE := MI_MENSAJE || ' ' ||
                        'El valor de la relacion de Anexo de Aportes ' ||
                        'no corresponde al valor diligenciado en el total del concepto ' ||
                        'en la Relacion de Centro de Costos';
        END IF;
      END IF;
    END IF;
  
    -- VALIDA QUE NO EXISTAN TERCEROS REPETIDOS EN UNA RA
    -- RETORNA 0 SI NO EXISTEN TERCEROS DUPLICADOS Y 1 SI HAY DUPLICADOS
    IF UN_ESTADO = 'TODO' AND
       OGT_PK_RA.FN_VALIDA_TERCERO_RA(:OGT_DOCUMENTO_PAGO.ENTIDAD,
                                      :OGT_DOCUMENTO_PAGO.UNIDAD,
                                      :OGT_DOCUMENTO_PAGO.VIGENCIA,
                                      :OGT_DOCUMENTO_PAGO.CONSECUTIVO,
                                      :OGT_RELACION_AUTORIZACION.TIPO_RA) <> 0 THEN
      MI_MENSAJE           := MI_MENSAJE || ' ' ||
                              'Existe un tercero duplicado en varios centros de ' ||
                              'costos';
      :GLOBAL.ANEXO_VALIDO := 1;
    END IF;
  
    IF UN_ESTADO IN ('AA', 'AE', 'AN', 'TODO') THEN
      -- ACTUALIZO EL ESTADO EN LA RA
      PR_CAMBIA_POSICION_ESTADO_ITEM(11, :GLOBAL.ANEXO_VALIDO, MI_ESTADO);
    END IF;
  
    -- LINEAS TEMPORALES PARA VALIDACION CONTABLE
    IF UN_ESTADO = ('TODO') THEN
      -- ACTUALIZO EL ESTADO EN LA RA
      PR_CAMBIA_POSICION_ESTADO_ITEM(3, 0, MI_ESTADO);
    END IF;
  
    -- SE DEJA EL ESTADO DEVULETO CON EL DEFAULT EN CERO
    IF UN_ESTADO = ('TODO') THEN
      -- ACTUALIZO EL ESTADO EN LA RA
      PR_CAMBIA_POSICION_ESTADO_ITEM(7, 0, MI_ESTADO);
    END IF;
  
  ELSE
    PR_DESPLIEGA_MENSAJE('AL_STOP_1',
                         'La Relacion de Autorizacion no ha sido salvada y no posee consecutivo');
  END IF;

  -- VERIFICA QUE SE HAYA PUESTO EL CONSECUTIVO PARA PARALELOS CON SIDIF
  PR_VALIDA_CODIGO_SIDIF(MI_MENSAJE_SIDIF);

  IF MI_MENSAJE_SIDIF IS NOT NULL THEN
    -- DEJA LA RA INVALIDA POR ANEXOS
    PR_CAMBIA_POSICION_ESTADO_ITEM(11, 1, MI_ESTADO);
    :GLOBAL.ANEXO_VALIDO := 1;
    MI_MENSAJE           := MI_MENSAJE || MI_MENSAJE_SIDIF;
  END IF;

  -- EVLUA SI DEBE MOSTRAR EL MENSAJE
  IF :GLOBAL.PAC_VALIDO = 1 OR :GLOBAL.PREDIS_VALIDO = 1 OR
     :GLOBAL.CC_VALIDO = 1 OR :GLOBAL.CC_VALIDO_ANEXO = 1 OR
     :GLOBAL.ANEXO_VALIDO = 1 THEN
    PR_DESPLIEGA_MENSAJE('AL_STOP_1', MI_MENSAJE);
  END IF;

  -- MODIFICA EL ESTADO
  --  IF MI_ESTADO <> :OGT_RELACION_AUTORIZACION.ESTADO THEN
  :OGT_RELACION_AUTORIZACION.ESTADO := MI_ESTADO;
  -- ACTUALIZA EL ESTADO DESPLEGADO
  PR_ESTADO;
  :GLOBAL.VALIDA_INCAPACIDAD := 'BIEN';

  --  END IF;    
  -- RETORNA AL CANVAS DESDE EL QUE SALVO
  SET_CANVAS_PROPERTY('C_CARPETAS', TOPMOST_TAB_PAGE, MI_TAB_PAGE);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    NULL;
END;
