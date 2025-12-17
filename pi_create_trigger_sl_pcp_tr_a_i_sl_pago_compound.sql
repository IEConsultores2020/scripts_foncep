CREATE OR REPLACE TRIGGER sl_pcp_tr_a_i_sl_pago
FOR INSERT ON sl_pcp_pago
COMPOUND TRIGGER

    -- 1. Declaramos una colección para guardar las referencias insertadas
    TYPE t_refs IS TABLE OF sl_pcp_pago.nro_referencia_pago%TYPE;
    v_refs t_refs := t_refs();

    -- Sección que se ejecuta por cada fila (AQUÍ NO LLAMAMOS AL PROCESO)
    AFTER EACH ROW IS
    BEGIN
        v_refs.EXTEND;
        v_refs(v_refs.LAST) := :new.nro_referencia_pago;
    END AFTER EACH ROW;

    -- Sección que se ejecuta al final de toda la operación (AQUÍ LA TABLA YA NO MUTA)
    AFTER STATEMENT IS
        mi_resp     VARCHAR2(1000);
        mi_procesado BOOLEAN;
    BEGIN
        FOR i IN 1 .. v_refs.COUNT LOOP
            BEGIN
                pk_ogt_imputacion.pr_procesar_imputacion(
                    p_nro_referencia_pago => v_refs(i),
                    p_usuario             => USER,
                    p_resp                => mi_resp,
                    p_procesado           => mi_procesado
                );

                IF mi_procesado THEN
                    --DBMS_OUTPUT.PUT_LINE('Referencia procesada: ' || v_refs(i) || ' - ' || mi_resp);
                    seguimiento('OPGET: Exito: ' || v_refs(i) || ' - ' || mi_resp);
                ELSE
                    --DBMS_OUTPUT.PUT_LINE('Fallo en referencia: ' || v_refs(i) || '. Resp: ' || mi_resp);
                    seguimiento('OPGET: Fallo: ' || v_refs(i) || '. Resp: ' || mi_resp)
                END IF;

            EXCEPTION
                WHEN OTHERS THEN
                    --DBMS_OUTPUT.PUT_LINE('Error procesando ref ' || v_refs(i) || ': ' || SQLERRM);
                    seguimiento('Error procesando ref '  || v_refs(i) || ': ' || SQLERRM);
            END;
        END LOOP;
    END AFTER STATEMENT;

END sl_pcp_tr_a_i_sl_pago;
/