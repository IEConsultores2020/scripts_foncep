/*PK_SL_INTERFAZ_OPGET_CP.*/
CREATE OR REPLACE PACKAGE BODY PK_OGT_IMPUTACION AS

TYPE ref_cursor IS REF CURSOR;

PROCEDURE PR_IMPUTACION(P_NRO_REFERENCIA_PAGO VARCHAR2, P_ID_USUARIO NUMBER, P_RESP OUT VARCHAR2);
BEGIN
    IF p_nro_referencia_pago IS NOT NULL THEN
        P_RESP := '1 - OGT. Referencia de pago no puede ser nula';
    END IF;
    ref_cuentas_cobro := pr_trae_cuentas_cobro(P_NRO_REFERENCIA_PAGO);
    LOOP ref_cuentas_cobro
        EXIT WHEN ref_cuentas_cobro%not_found;
        pr_imputar_opget(/*parametros cuenta_cobro*/ )
    END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    IF p_resp IS NULL THEN
        P_RESP := '99 - OGT. Error no identificado';
    END IF;
END PR_IMPUTACION;

PROCEDURE PR_OGT_IMPUTAR(/*parametros*/)
BEGIN
    insert into opget;  /* Despues de insertar retorna el comprobante y demas información para contabilizar */
    pk_ogt_imputacion.pr_ingresa_acta
    if ok then
        pk_ogt_imputación.pr_ingresa_documento
        if ok then 
            pk_ogt_imputacion.pr_ingresa_detalle_documento
    ref_liquidaciones := pr_trae_liquidaciones(P_NRO_REFERENCIA_PAGO); 
    loop ref_liquidaciones
        exit when ref_liquidaciones%not_found;
        pk_sl_interfaz_opget_cp.pr_valida_recaudo (
                    p_cuenta_cobro        => p_cuenta_cobro
                    p_valor_pago          => p_valor_pago,
                    p_respuesta_proceso   => p_output_respuesta_proceso,
                    p_bandera             =< p_output_bandera
        );
        --Actualmente ingresa novedad 13 recaudo capital
        --Pendiente definir novedad para
                -- Causación intereses
                -- Recaudo intereses
        pk_sl_interfaz_opget_cp.pr_actualizar_interfaz_opget(
            p_cuenta_cobro_volante         NUMBER,
                p_valor_pago             => p_valor_pago,
                p_fecha_pago             => p_fecha_pago,
                p_fecha_legalizacion     => p_fecha_legalizacion,
                p_acta_legalizacion      => p_acta_legalizacion,
                p_fase                   => p_fase,
                p_usuario_transaccion    => p_usuario_transaccion,
                p_respuesta_proceso      => p_output_respuesta_proceso
                    );
                    
        --Contabilización 4 pasos por aclarar, ver código actual en forma en opget */
        pk_lm_transaccion.fn_iniciar(/*tipo_transaccion, */
        pk_lm_transaccion...
    end loop;
END PR_IMPUTAR_OPGET;
/
