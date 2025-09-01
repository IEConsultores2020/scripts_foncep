/*PK_SL_INTERFAZ_OPGET_CP.*/
CREATE OR REPLACE PACKAGE BODY PK_OGT_IMPUTACION AS


--Registro de cuentas de cobro
TYPE type_rec_cuenta_cobro IS RECORD (
    id                  SL_PCP_CUENTA_COBRO.ID%TYPE,
    id_encabezado       SL_PCP_CUENTA_COBRO.ID_ENCABEZADO%TYPE,
    codigo_entidad      SL_PCP_CUENTA_COBRO.CODIGO_ENTIDAD%TYPE,
    id_cuenta_cobro     SL_PCP_CUENTA_COBRO.ID_CUENTA_COBRO%TYPE,
    saldo_cuenta_cobro  SL_PCP_CUENTA_COBRO.SALDO_CUENTA_COBRO%TYPE,
    valor_capital       SL_PCP_CUENTA_COBRO.VALOR_CAPITAL%TYPE,
    valor_intereses     SL_PCP_CUENTA_COBRO.VALOR_INTERESES%TYPE,
    fecha_sistema       SL_PCP_CUENTA_COBRO.FECHA_SISTEMA%TYPE
);

TYPE type_tab_cuenta_cobro IS TABLE OF type_rec_cuenta_cobro;

TYPE type_rec_pago IS RECORD (
    ID                   SL_PCP_PAGO.ID%TYPE,
    NRO_REFERENCIA_PAGO  SL_PCP_PAGO.NRO_REFERENCIA_PAGO%TYPE,
    ID_BANCO             SL_PCP_PAGO.ID_BANCO%TYPE,
    COD_AUTORIZACION     SL_PCP_PAGO.COD_AUTORIZACION%TYPE,
    FECHA_AUTORIZACION   SL_PCP_PAGO.FECHA_AUTORIZACION%TYPE,
    METODO_RECAUDO       SL_PCP_PAGO.METODO_RECAUDO%TYPE,
    CANAL                SL_PCP_PAGO.CANAL%TYPE,
    JORNADA              SL_PCP_PAGO.JORNADA%TYPE,
    CODIGO_OFICINA       SL_PCP_PAGO.CODIGO_OFICINA%TYPE
);

TYPE type_tab_pago IS TABLE OF type_rec_pago;

TYPE type_rec_liquidacionc IS RECORD (
    id                  SL_PCP_LIQUIDACIONES.ID%TYPE,
    id_det_cuenta_cobro SL_PCP_LIQUIDACIONES.ID_DET_CUENTA_COBRO%TYPE,
    id_factura          SL_PCP_LIQUIDACIONES.ID_FACTURA%TYPE,
    interno_persona     SL_PCP_LIQUIDACIONES.INTERNO_PERSONA%TYPE,
    fecha_periodo_ini   SL_PCP_LIQUIDACIONES.FECHA_PERIODO_INI%TYPE,
    fecha_periodo_fin   SL_PCP_LIQUIDACIONES.FECHA_PERIODO_FIN%TYPE,
    saldo_factura       SL_PCP_LIQUIDACIONES.SALDO_FACTURA%TYPE,
    valor_capital       SL_PCP_LIQUIDACIONES.VALOR_CAPITAL%TYPE,
    valor_interes       SL_PCP_LIQUIDACIONES.VALOR_INTERES%TYPE,
    fecha_sistema       SL_PCP_LIQUIDACIONES.FECHA_SISTEMA%TYPE
);

TYPE type_tab_liquidacion_tab IS TABLE OF type_rec_liquidacion;

-- Define a record type for OGT.OGT_DOCUMENTO
TYPE type_rec_documento IS RECORD (
    NUMERO                         VARCHAR2(30),
    TIPO                           VARCHAR2(10),
    ESTADO                         VARCHAR2(10),
    FECHA                          DATE,
    TER_ID_RECEPTOR                NUMBER(20),
    UNTE_CODIGO                    VARCHAR2(10),
    BIN_TIPO_CUENTA                VARCHAR2(10),
    BIN_TIPO_TITULO                VARCHAR2(10),
    CUBA_NUMERO                    VARCHAR2(30),
    NUMERO_TIMBRE                  VARCHAR2(100),
    OBSERVACIONES                  VARCHAR2(4000),
    USUARIO_ELABORO                VARCHAR2(30),
    USUARIO_REVISO                 VARCHAR2(30),
    CON_ID                         NUMBER(10),
    BIN_TIPO_EMISOR_TITULO         VARCHAR2(10),
    FECHA_COMPRA_TITULO            DATE,
    FECHA_EMISION_TITULO           DATE,
    FECHA_VENCIMIENTO_TITULO       DATE,
    TASA_CAMBIO_TITULO             NUMBER,
    VALOR_ACTUAL_TITULO            NUMBER,
    VALOR_INTERESES_TITULO         NUMBER,
    VALOR_INGRESO_TITULO           NUMBER,
    VALOR_ESPERADO_TITULO          NUMBER,
    VALOR_COMPRA_TITULO            NUMBER,
    NUMERO_LEGAL                   VARCHAR2(30),
    TIPO_LEGAL                     VARCHAR2(10),
    VALOR_REINVERSION_TITULO       NUMBER,
    NUMERO_SOPORTE                 VARCHAR2(30),
    TIPO_SOPORTE                   VARCHAR2(10),
    FECHA_SOPORTE                  DATE,
    TER_ID_EMISOR                  NUMBER(20),
    TER_ID_COMPRADOR               NUMBER(20),
    BIN_CIUDAD                     VARCHAR2(30),
    FECHA_VENTA_TITULO             DATE,
    FECHA_PACTO_TITULO             DATE,
    FORMA_PAGO                     VARCHAR2(30),
    SITUACION_FONDOS               VARCHAR2(1),
    DESTINACION_ESPECIFICA         VARCHAR2(1),
    DESCRIPCION                    VARCHAR2(4000),
    ENTIDAD                        VARCHAR2(6),
    UNIDAD_EJECUTORA               VARCHAR2(6),
    NUMERO_EXTERNO                 VARCHAR2(30)
);

TYPE type_tab_documento IS TABLE OF type_rec_documento;

--Retorna las cuentas de cobro de un encabezado con p_id_encabezado
PROCEDURE pr_trae_cuentas_cobro(
  p_id_encabezado SL_PCP_ENCABEZADO.ID%type, 
  p_resp OUT VARCHAR2, 
  p_ref_cursor OUT SYS_REFCURSOR
) AS
BEGIN
  OPEN p_ref_cursor FOR
    SELECT
      ID,
      ID_ENCABEZADO,
      CODIGO_ENTIDAD,
      ID_CUENTA_COBRO,
      SALDO_CUENTA_COBRO,
      VALOR_CAPITAL,
      VALOR_INTERESES,
      FECHA_SISTEMA
    FROM SL.SL_PCP_CUENTA_COBRO
    WHERE ID_ENCABEZADO = p_id_encabezado;
exception
  when no_data_found then
    p_resp := 'No se encontraron cuentas de cobro para el encabezado: ' || p_id_encabezado;p_resp
    p_ref_cursor := NULL;
  when others then
    p_ref_cursor := NULL;
    p_resp := 'Error al obtener las cuentas de cobro: ' || sqlerrm);
END pr_trae_cuentas_cobro;

--Retorna las liquidaciones de una cuenta de cobro con id p_id_det_cuenta_cobro
PROCEDURE pr_trae_liquidaciones(
  p_id_det_cuenta_cobro SL_PCP_CUENTA_COBRO.id%type, 
  p_resp OUT VARCHAR2, 
  p_ref_cursor OUT SYS_REFCURSOR
) AS
BEGIN
  OPEN p_ref_cursor FOR
    SELECT
      ID,
      ID_DET_CUENTA_COBRO,
      ID_FACTURA,
      INTERNO_PERSONA,
      FECHA_PERIODO_INI,
      FECHA_PERIODO_FIN,
      SALDO_FACTURA,
      VALOR_CAPITAL,
      VALOR_INTERES,
      FECHA_SISTEMA
    FROM SL.SL_PCP_LIQUIDACIONES
    WHERE ID_DET_CUENTA_COBRO = p_id_det_cuenta_cobro;
exception
  when no_data_found then
    p_resp := 'No se encontraron liquidaciones para la cuenta de cobro: ' || p_id_det_cuenta_cobro;
    p_ref_cursor := NULL;
  when others then
    p_ref_cursor := NULL;
    p_resp := 'Error al obtener las liquidaciones: ' || sqlerrm;
END pr_trae_liquidaciones;

-- Procedure to return a SYS_REFCURSOR for SL.SL_PCP_PAGO
PROCEDURE pr_trae_pagos(
  p_nro_referencia_pago SL_PCP_ENCABEZADO.NRO_REFERENCIA_PAGO%type, 
  p_resp OUT VARCHAR2, 
  p_ref_cursor OUT SYS_REFCURSOR
) AS
BEGIN
  OPEN p_ref_cursor FOR
    SELECT
      ID,
      NRO_REFERENCIA_PAGO,
      ID_BANCO,
      COD_AUTORIZACION,
      FECHA_AUTORIZACION,
      METODO_RECAUDO,
      CANAL,
      JORNADA,
      CODIGO_OFICINA
    FROM SL.SL_PCP_PAGO
    WHERE NRO_REFERENCIA_PAGO = p_nro_referencia_pago ;
exception
  when no_data_found then
    p_resp := 'No se encontraron para la referencia de pago: ' || p_nro_referencia_pago;
    p_ref_cursor := NULL;
  when others then
    p_ref_cursor := NULL;
    p_resp := 'Error al obtener pagos: ' || sqlerrm;    
END pr_trae_pagos;

PROCEDURE PR_PROCESAR_IMPUTACION (p_nro_referencia_pago SL_PCP_ENCABEZADO.NRO_REFERENCIA_PAGO%type, 
                                  p_usuario VARCHAR2(30) 
                                  p_resp OUT VARCHAR2 DEFAULT 'PORTALP',
                                  p_bandera OUT BOOLEAN ) AS
DECLARE
    ref_cur_cuentas_cobro SYS_REFCURSOR;

    v_type_rec_cuenta_cobro type_rec_cuenta_cobro;

    p_resp VARCHAR2(4000) := NULL; -- Retorna mensaje de error
BEGIN
    IF p_nro_referencia_pago IS NOT NULL THEN
        P_RESP := '1 - OGT. Referencia de pago no puede ser nula';
        RETURN;
    END IF;
    --ref_cuentas_cobro := pk_sl_interfaz_opget_cp.pr_trae_cuentas_cobro(p_nro_referencia_pago,);
    --p_resp en caso de error o no encontrar datos
    --ref_cuentas_cobro retorna las cuentas de cobro asociadas a p_nro_referencia_pago o nulo si no existen
    pr_trae_cuentas_cobro(    
        p_id_encabezado => p_nro_referencia_pago, 
        p_resp => p_resp, 
        p_ref_cursor => ref_cur_cuentas_cobro
    );
    IF p_resp IS NOT NULL THEN
        EXIT;
    END IF;
    LOOP ref_cur_cuentas_cobro
     FETCH ref_cur_cuentas_cobro INTO v_type_rec_cuenta_cobro;
        EXIT WHEN ref_cur_cuentas_cobro%not_found;
        /*
        PR_SL_PROCESAR (
            p_cuenta_cobro_rec => v_cuenta_cobro,
            p_usuario => p_usuario,
            p_resp => p_resp,
            p_bandera => p_bandera
        );
        IF p_bandera = FALSE THEN
          RETURN;
        END;
        */
        PR_OGT_CREA_ACTA (p_nro_referencia_pago => p_nro_referencia_pago,
                              p_type_rec_cuenta_cobro_rec => v_type_rec_cuenta_cobro,
                              p_usuario => p_usuario,
                              p_resp => p_resp,
                              p_bandera => p_bandera); 
        IF p_bandera = FALSE THEN
          RETURN;
        END IF;
    END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    IF p_resp IS NULL THEN
        P_RESP := '99 - OGT. Error no identificado';
    END IF;
END PR_IMPUTACION;

PROCEDURE PR_OGT_CREA_ACTA(
                        p_nro_referencia_pago SL_PCP_ENCABEZADO.NRO_REFERENCIA_PAGO%type,
                        p_cuenta_cobro_rec    cuenta_cobro_rec, 
                        p_usuario             VARCHAR2,
                        p_resp                OUT VARCHAR2
                        p_bandera             OUT BOOLEAN) AS
  v_acta_numero NUMBER;
  v_tipo_acta  VARCHAR2(20) := 'XYZ';

  ref_liquidaciones SYS_REFCURSOR;
  v_rec_liquidacion type_rec_liquidacion;

  v_rec_documento   type_rec_documento;
  v_rec_acta        type_rec_documento;

  p_ref_pago      SYS_REFCURSOR;
  v_rec_pago      type_rec_pago;

  v_rec_enbezado_fijo_factura SYS_REFCURSOR;

BEGIN
  resp := NULL;
  p_bandera := TRUE;

  -- Trae los valores por defecto en bintablas del portalpagos.
  pk_sl_interfaz_opget.cp.trae_encabezado_fijo_factura(v_rec_enbezado_fijo_factura);

  -- INICIO REGISTRA ACTA
  v_acta_numero := pk_secuencial.fn_traer_consecutivo('OPGET','ACTA_LEGAL_ID','0000','000')+1;
        
  IF p_resp IS NOT NULL THEN
    RETURN;
    IF p_ref_pago IS NOT NULL THEN  
      FETCH p_ref_pago INTO v_type_rec_pago;
    ELSE
      RETURN;
    END IF;      
  END IF;


  --CREA ACTA
  v_rec_acta.numero       := v_acta_numero;
  v_rec_acta.tipo         := v_tipo_acta;
  v_rec_acta_acta.fecha        := SYSDATE;
  v_rec_acta.estado       := 'RE';
  v_rec_acta.unte_codigo  := 'FINANCIERO';
  v_rec_acta.observacion  := 'PORTAL PAGOS ' || p_nro_referencia_pago,
  v_rec_acta.usuario_elaboro := p_usuario;

  FN_CREAR_DOCUMENTO(p_rec_acta       => v_acta,
                     p_resp           => p_resp,
                     p_bandera        => p_bandera
  );

  pk_secuencial.pr_actualizar_consecutivo(v_acta_numero);  
  ---FIN CREACIO ACTA
    cc
    id                  SL_PCP_CUENTA_COBRO.ID%TYPE,
    id_encabezado       SL_PCP_CUENTA_COBRO.ID_ENCABEZADO%TYPE,
    codigo_entidad      SL_PCP_CUENTA_COBRO.CODIGO_ENTIDAD%TYPE,
    id_cuenta_cobro     SL_PCP_CUENTA_COBRO.ID_CUENTA_COBRO%TYPE,
    saldo_cuenta_cobro  SL_PCP_CUENTA_COBRO.SALDO_CUENTA_COBRO%TYPE,
    valor_capital       SL_PCP_CUENTA_COBRO.VALOR_CAPITAL%TYPE,
    valor_intereses     SL_PCP_CUENTA_COBRO.VALOR_INTERESES%TYPE,
    fecha_sistema       SL_PCP_CUENTA_COBRO.FECHA_SISTEMA%TYPE


    NUMERO                         :=  pk_secuencial.fn_traer_consecutivo('OPGET','DOC_NUM','2002','000')+1;
    TIPO                           := 'XYZ';
    ESTADO                         VARCHAR2(10),
    FECHA                          := SYSDATE;
    TER_ID_RECEPTOR                := pk_sit_infentidades.sit_fn_id_superbancaria(:ogt_documento.id_receptor, SYSDATE);

    IF pk_sit_infbasica.sit_fn_existe_id(mi_id_tercero) = FALSE OR  TER_ID_RECEPTOR<=0 IS NULL THEN
        p_resp := p_resp || 'No se encontró el tercero receptor.';
        p_bandera := FALSE;
    END IF;
    
    UNTE_CODIGO                    VARCHAR2(10),
    v_rec_documento.BIN_TIPO_CUENTA                := v_rec_enbezado_fijo_factura.bin_tipo_cuenta;
    BIN_TIPO_TITULO                VARCHAR2(10),
    v_rec_documentoCUBA_NUMERO                    := v_rec_enbezado_fijo_factura.cuba_numero;
    v_rec_documento.NUMERO_TIMBRE                  TO_CHAR(SYSDATE,'YYYY');
    OBSERVACIONES                  VARCHAR2(4000),
    USUARIO_ELABORO                VARCHAR2(30),
    USUARIO_REVISO                 VARCHAR2(30),
    CON_ID                         NUMBER(10),
    BIN_TIPO_EMISOR_TITULO         VARCHAR2(10),
    v_rec_documento.FECHA_COMPRA_TITULO            p_rec_pago.fecha_autorizacion;
    v_rec_documento.FECHA_EMISION_TITULO           SYSDATE,
    FECHA_VENCIMIENTO_TITULO       DATE,
    TASA_CAMBIO_TITULO             NUMBER,
    VALOR_ACTUAL_TITULO            NUMBER,
    VALOR_INTERESES_TITULO         NUMBER,
    VALOR_INGRESO_TITULO           NUMBER,
    VALOR_ESPERADO_TITULO          NUMBER,
    VALOR_COMPRA_TITULO            NUMBER,
    v_rec_documento.NUMERO_LEGAL                   := v_acta_numero;
    v_rec_documento.TIPO_LEGAL                     := v_tipo_acta;
    VALOR_REINVERSION_TITULO       NUMBER,
    v_rec_documento.NUMERO_SOPORTE                 := v_acta_numero;
    v_rec_documento.TIPO_SOPORTE                   'NCR';           --Nota Credito
    v_rec_documento.FECHA_SOPORTE                  SYSDATE
    TER_ID_EMISOR                  NUMBER(20),
    TER_ID_COMPRADOR               NUMBER(20),
    BIN_CIUDAD                     VARCHAR2(30),
    FECHA_VENTA_TITULO             DATE,
    FECHA_PACTO_TITULO             DATE,
    FORMA_PAGO                     VARCHAR2(30),
    SITUACION_FONDOS               VARCHAR2(1),
    DESTINACION_ESPECIFICA         VARCHAR2(1),
    DESCRIPCION                    VARCHAR2(4000),
    ENTIDAD                        VARCHAR2(6),
    UNIDAD_EJECUTORA               VARCHAR2(6),
    NUMERO_EXTERNO                 VARCHAR2(30)


  --CREA DOCUMENTO
  v_tipo_soporte := p_bintablas.RegistrarItem('ogt_documento.tipo_soporte','general','documento',to_char(SYSDATE,'DD/MM/YYYY'),1);
  PR_OGT_REGISTRA_DOCUMENTO
  PR_OGT_REGISTRA_DETALLE_DOCUMENTO

   /* insert into opget;  /* Despues de insertar retorna el comprobante y demas información para contabilizar * /
      pk_ogt_imputacion.pr_ingresa_acta
    if ok then
        pk_ogt_imputación.pr_ingresa_documento
        if ok then 
            pk_ogt_imputacion.pr_ingresa_detalle_documento
    --pk_sl_interfaz_opget_cp.pr_trae_liquidaciones(id_det_cuenta_cobro); 
    */
    loop ref_liquidaciones
        exit when ref_liquidaciones%not_found;
     
        --Contabilización 4 pasos por aclarar, ver código actual en forma en opget */
        pk_lm_transaccion.fn_iniciar(/*tipo_transaccion, */
        pk_lm_transaccion...
    end loop;
END PR_OGT_REGISTRA_ACTA;


PROCEDURE PR_SL_PROCESAR(
    p_cuenta_cobro_rec cuenta_cobro_rec, 
    p_usuario VARCHAR2, 
    p_resp OUT VARCHAR2,
    p_bandera OUT BOOLEAN
) AS
BEGIN
  ---Hacer llamado para capital y otro para intereses
  pk_sl_interfaz_opget_cp.pr_valida_recaudo (
    p_cuenta_cobro        => p_cuenta_cobro
    p_valor_pago          => p_valor_pago,
    p_valor_intereses     => p_valor_intereses,
    p_respuesta_proceso   => p_resp,
    p_bandera             =< p_bandera
  );
  --Si la validación retorna false, cancela el proceso.
  IF p_bandera = FALSE then
    RETURN;
  END IF;
  --Actualmente ingresa novedad 13 recaudo capital
  --Pendiente definir novedad para
  -- Causación intereses
  -- Recaudo intereses   
  pk_sl_interfaz_opget_cp.pr_actualizar_interfaz_opget(
    p_cuenta_cobro_volante         NUMBER,
    p_valor_pago             => p_valor_pago,
    p_valor_intereses        => p_valor_intereses,
    p_fecha_pago             => p_fecha_pago,
    p_fecha_legalizacion     => p_fecha_legalizacion,
    p_acta_legalizacion      => p_acta_legalizacion,
    p_fase                   => p_fase,
    p_usuario_transaccion    => p_usuario_transaccion,
    p_respuesta_proceso      => p_resp
  );

  IF p_respuesta_proceso IS NOT NULL THEN
    p_bandera := FALSE
    RETURN;
  END IF;
END;

PROCEDURE PR_REGISTRA_OGT () IS
begin

END PK_OGT_IMPUTACION;
/
