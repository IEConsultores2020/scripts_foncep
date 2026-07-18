create or replace PACKAGE body PK_RH_VALIDACIONES AS



   /* Selecciona número de siguiente pago de la tabla rh_detalle_pagos_F. */
   PROCEDURE PR_RH_Numero_Pago (un_funcionario IN NUMBER, 
                                un_numero_descuento IN VARCHAR2,
                                un_tipo_descuento IN VARCHAR2, 
                                un_numero_pago OUT NUMBER ) IS
      -- Define cursor: Obtiene el número de pago de un descuento específico
      CURSOR cur_numero_pago IS
      SELECT NVL(MAX(numero_pago),0) + 1
        FROM rh_detalle_pagos_F
       WHERE funcionario       = un_funcionario AND
             descuentos_numero = un_numero_descuento AND
             descuentos_tipo   = un_tipo_descuento;
   BEGIN
      IF un_funcionario IS NULL OR un_numero_descuento IS NULL OR
         un_tipo_descuento IS NULL THEN
         RETURN;
      END IF;
       OPEN cur_numero_pago; 
      FETCH cur_numero_pago INTO un_numero_pago;
      IF cur_numero_pago%NOTFOUND THEN
         dbms_output.put_line('PR_RH_Numero_Pago: No existen datos en la tabla rh_detalle_pagos_F del funcionario : '||un_funcionario||'.');
      END IF;
     CLOSE cur_numero_pago;
   END PR_RH_Numero_Pago;


  PROCEDURE PR_RH_Clase_Descuento (un_funcionario IN NUMBER, 
                                    un_numero_descuento IN VARCHAR2,
                                    un_tipo_descuento IN VARCHAR2, 
                                    una_clase_descuento OUT VARCHAR2 ) IS
      -- Define cursor: Obtiene CLASE de un descuento específico
      CURSOR cur_clase_descuento IS
      SELECT clase
        FROM rh_descuentos_F
       WHERE funcionario      = un_funcionario AND
             numero_descuento = un_numero_descuento AND
             tipo             = un_tipo_descuento;
    BEGIN
       IF un_funcionario IS NULL OR un_numero_descuento IS NULL OR
          un_tipo_descuento IS NULL THEN
          RETURN;
       END IF;
       OPEN cur_clase_descuento; 
       FETCH cur_clase_descuento INTO una_clase_descuento;
       IF cur_clase_descuento%NOTFOUND THEN
           dbms_output.put_line('PR_RH_Clase_Descuento: No existen datos en la tabla rh_descuentos_F del funcionario : '||un_funcionario||'.');
       END IF;
       CLOSE cur_clase_descuento;
   END PR_RH_Clase_Descuento;

   /* Valida que no exista registro en la tabla rh_detalle_pagos_F. */
  PROCEDURE PR_RH_Valida_Detalle_Pago (un_detalle_pago IN RDetallePagos, 
                                        un_total_registros OUT NUMBER ) IS
      -- Define cursor: Obtiene total de registros de un descuento específico
      CURSOR cur_total_detalle IS
      SELECT COUNT(*)
        FROM rh_detalle_pagos_F
       WHERE funcionario       = un_detalle_pago.Funcionario AND
             descuentos_numero = un_detalle_pago.Descuentos_Numero AND
             descuentos_tipo   = UPPER(un_detalle_pago.Descuentos_Tipo) AND
             fecha_pago        = un_detalle_pago.Fecha_Pago AND
             clase             = un_detalle_pago.Clase;		            
   BEGIN
       OPEN cur_total_detalle; 
      FETCH cur_total_detalle INTO un_total_registros;
      IF cur_total_detalle%NOTFOUND THEN
         un_total_registros := 0;
      END IF;
     CLOSE cur_total_detalle;
   END PR_RH_Valida_Detalle_Pago;

-- PROCEDURE
 PROCEDURE Pr_RH_Validar_Detalle_Pagos(un_proceso IN
                                     rh_historico_nomina.sproceso%TYPE,
                                     una_corrida IN
                                     rh_historico_nomina.ncorrida%TYPE,
                                     un_inicioperiodo IN
                                     rh_historico_nomina.dinicioperiodo%TYPE,
                                     un_finalperiodo IN
                                     rh_historico_nomina.dfinalperiodo%TYPE) IS
--BY FTORRESV 20260002526                                     
 --RETURN BOOLEAN IS



      -- Define cursor: Selecciona conceptos de bintablas, para obtener el hash por el que se debe buscar
       CURSOR cur_bintablas IS  SELECT argumento
          FROM bintablas
         WHERE grupo = 'NOMINA'
           AND nombre = 'T_DESCUENTO';

-- Define cursor: Selecciona registros de rh_historico_nomina que cumplan con parámetros.
CURSOR cur_historico_nomina(un_hash_descuento IN NUMBER) IS
  SELECT nfuncionario,
         nhash,
         RTRIM(sactoadmi, ' ') sactoadmi,
         dfechaefectiva,
         SUM(ndcampo0) valor_descuento,
         -- RQ2013-831-175 17/07/2013
         SUM(ndcampo9) vlr_embg_ini,
         SUM(ndcampo7) vlr_comision,
         SUM(ndcampo8) vlr_iva -- RQ2014-1279-254 11/11/2014 Se cambia SUM(ndcampo6) por SUM(ndcampo9)
  -- Fin RQ2013-831-175  
    FROM rh_historico_nomina
   WHERE rh_historico_nomina.nesnovedad = 0
     AND rh_historico_nomina.besdefinitivo = 1
     AND rh_historico_nomina.brechazado = 0
     AND rh_historico_nomina.nretroactivo = 0
     AND rh_historico_nomina.sproceso = un_proceso
        --         AND rh_historico_nomina.ncorrida       = una_corrida   RQ 2020005053
     AND rh_historico_nomina.nhash = un_hash_descuento
     AND rh_historico_nomina.dinicioperiodo >= un_inicioperiodo
     AND rh_historico_nomina.dfinalperiodo <= un_finalperiodo
   GROUP BY nfuncionario, nhash, sactoadmi, dfechaefectiva;
-- Define variables
mi_registro_detalle RDetallePagos;
mi_ano VARCHAR2(4);
mi_mes VARCHAR2(3);
mi_dia VARCHAR2(2);
mi_fecha_pago VARCHAR2(10);
mi_bandera BOOLEAN := TRUE;
mi_hash_descuento rh_concepto.codigo_hash%TYPE;
mi_nombre_corto rh_concepto.nombre_corto%TYPE;
mi_contador NUMERIC := 0;
BEGIN
  IF un_proceso IS NULL OR una_corrida IS NULL OR un_inicioperiodo IS NULL OR
     un_finalperiodo IS NULL THEN
    mi_bandera := FALSE;
    dbms_output.put_line('Pr_RH_Validar_Detalle_Pagos: Los datos pasados como parámetro para insertar en la tabla rh_detalle_pagos_F no pueden ser nulos. Por favor verifique');
    --RETURN mi_bandera;
  ELSE
    /* Ciclo para obtener todos los conceptos de descuentos existentes en la tabla
    BINTABLAS. grupo = 'NOMINA' y nombre = 'T_DESCUENTO'  */
    FOR mi_descuento IN cur_bintablas LOOP
      SELECT codigo_hash, nombre_corto
      INTO mi_hash_descuento, mi_nombre_corto
        FROM rh_concepto
       WHERE nombre_corto = 'C' || mi_descuento.argumento
      ;
      FOR mi_historico_nomina IN cur_historico_nomina(mi_hash_descuento) LOOP
        mi_registro_detalle.Funcionario       := mi_historico_nomina.nfuncionario;
        mi_registro_detalle.Descuentos_Numero := mi_historico_nomina.sactoadmi;
        mi_registro_detalle.Descuentos_Tipo   := mi_descuento.argumento;
        PR_RH_Numero_Pago(mi_registro_detalle.Funcionario,
                          mi_registro_detalle.Descuentos_Numero,
                          mi_registro_detalle.Descuentos_Tipo,
                          mi_registro_detalle.Numero_Pago);
        mi_ano := TO_CHAR(TO_DATE(SUBSTR(mi_historico_nomina.dfechaefectiva, 1, 4),'YYYY'), 'YYYY');
        mi_mes := TO_CHAR(TO_DATE(SUBSTR(mi_historico_nomina.dfechaefectiva, 5, 2), 'MM'),'MM');
        mi_dia  := SUBSTR(mi_historico_nomina.dfechaefectiva, 7, 2);
        mi_fecha_pago                  := mi_dia || '-' || mi_mes || '-' || mi_ano;
        mi_registro_detalle.Fecha_Pago := TO_DATE(mi_fecha_pago, 'DD-MM-YYYY');
        -- RQ2013-831-175 17/07/2013
        IF mi_hash_descuento =
           SHD_PG_BINTABLAS.FN_Buscar_rdf(mi_nombre_corto,
                                          'NOMINA',
                                          'CODIGO_EMBG_COMISION',
                                          TO_CHAR(sysdate, 'DD/MM/YYYY')) AND
           mi_historico_nomina.vlr_embg_ini <> 0 THEN
        
          mi_registro_detalle.Monto_Descuento := -mi_historico_nomina.vlr_embg_ini;
          mi_registro_detalle.Comision        := mi_historico_nomina.vlr_comision;
          mi_registro_detalle.Iva             := mi_historico_nomina.vlr_iva;
          -- Fin RQ2013-831-175  
        ELSE
          mi_registro_detalle.Monto_Descuento := -mi_historico_nomina.valor_descuento;
          mi_registro_detalle.Comision        := null;
          mi_registro_detalle.Iva             := null;
        END IF;
      
        PR_RH_Clase_Descuento(mi_registro_detalle.Funcionario,
                              mi_registro_detalle.Descuentos_Numero,
                              mi_registro_detalle.Descuentos_Tipo,
                              mi_registro_detalle.Clase);
        PR_RH_Valida_Detalle_Pago(mi_registro_detalle, mi_contador);
        --IF mi_contador = 0 THEN
          -- Inserta registro en tabla rh_detalle_pagos_F
          dbms_output.put_line('Si mi contador es 0, es válido para insertar registro en detalle_pagos_f  funcionario:'||mi_registro_detalle.Funcionario
          ||' Numero: '||mi_registro_detalle.Descuentos_Numero
          ||' Tipo: '||mi_registro_detalle.Descuentos_Tipo||' Clase:'||mi_registro_detalle.Clase||' mi_contador: '||mi_contador);
          --PR_RH_Inserta_Detalle_Pago(mi_registro_detalle, mi_bandera);
        /*ELSE
          mi_bandera := FALSE;
          RETURN mi_bandera;
        END IF;*/
      END LOOP mi_historico_nomina;
    END LOOP mi_descuento;
    dbms_output.put_line('Finalizó registro de descuentos de nómina en tabla rh_detalle_pagos_F.');
    --RETURN mi_bandera;
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    dbms_output.put_line('No encontro datos para procesar la nomina');
    mi_bandera := FALSE;
  WHEN STORAGE_ERROR or DUP_VAL_ON_INDEX or PROGRAM_ERROR or
       TIMEOUT_ON_RESOURCE THEN
    mi_bandera := FALSE;
    IF cur_historico_nomina%ISOPEN THEN
      CLOSE cur_historico_nomina;
    END IF;
    dbms_output.put_line('Error registrando descuentos en rh_detalle_pagos_F');
    --RETURN mi_bandera;
  WHEN OTHERS THEN
    mi_bandera := FALSE;
    IF cur_historico_nomina%ISOPEN THEN
      CLOSE cur_historico_nomina;
    END IF;
    dbms_output.put_line('Error Inesperado seleccionado Descuentos de Nómina de la tabla rh_historico_nomina. ' ||
            SQLERRM);
END Pr_RH_Validar_Detalle_Pagos;

end PK_RH_VALIDACIONES;