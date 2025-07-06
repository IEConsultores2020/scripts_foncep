CREATE OR REPLACE PACKAGE BODY "PR".Pk_Pr_Detalle_Fuentes IS


/********************************************************
 Funcion: fn_carga_apropia_det_ftes
 Descripcion: Carga los registros de detalle de fuentes de financiacion (de programacion)
              en la tabla pr_detalle_fuentes_apropia
 Entradas: Vigencia
           Rubro
           Compania
           Unidad ejecutora
           Clasificacion (ADMONCENTRAL)
           Cursor que contiene el detalle de las fuentes
 Salidas: 1  Ejecuta la Isercion
          0 no puede realizar la insercion

 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

 *********************************************************/


FUNCTION fn_carga_apropia_det_ftes (una_vigencia   PR_APROPIACION.vigencia%TYPE,
                                    un_rubro       PR_APROPIACION.rubro_interno%TYPE,
                                    una_compania   PR_APROPIACION.codigo_compania%TYPE,
                                    una_unidad     PR_APROPIACION.codigo_unidad_ejecutora%TYPE,
                                    una_clasificacion PR_DETALLE_FUENTES.clasificacion%TYPE,
                                    un_cursor      Pk_Pr_Detalle_Fuentes.cur_c_temporal) RETURN NUMBER IS

mi_registro     Pk_Pr_Detalle_Fuentes.TypRec_fuentes;


BEGIN


   LOOP
   FETCH un_cursor INTO mi_registro;
   EXIT WHEN un_cursor%NOTFOUND;
   INSERT INTO PR_DETALLE_FUENTES_APROPIA ( VIGENCIA,
                                            RUBRO_INTERNO,
                                            CODIGO_COMPANIA,
                                            CODIGO_UNIDAD_EJECUTORA,
                                            CODIGO_FUENTE,
                                            CODIGO_DET_FUENTE_FINANC,
                                            CLASIFICACION,
                                            VALOR)
    VALUES (una_vigencia,
            un_rubro,
            una_compania,
            una_unidad,
            mi_registro.codigo_fuente,
            mi_registro.codigo_det_fuente_financ,
            una_clasificacion,
            mi_registro.valor);


   END LOOP;
   CLOSE un_cursor;
   RETURN (1);

   EXCEPTION
      WHEN INVALID_CURSOR THEN
       -- MESSAGE('AL_STOP_1', ERROR_CODE||'ERRR'||MESSAGE_TEXT);
         RETURN 1000000;


END fn_carga_apropia_det_ftes;


 /********************************************************
 Funcion: fn_pre_ins_apropia
 Descripcion: Inserta los registros correspondientes al detalle de fuentes de financiciacion
 Entradas: Vigencia
           Rubro
		   Compania
           Unidad ejecutora
		   Clasificacion (ADMONCENTRAL)
		   Cursor que contiene el detalle de las fuentes
 Salidas: 1  Ejecuta la Isercion
          0 no puede realizar la insercion
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

 *********************************************************/


FUNCTION fn_pre_ins_apropia (una_vigencia      PR_APROPIACION.vigencia%TYPE,
                             un_rubro          PR_APROPIACION.rubro_interno%TYPE,
                             una_compania      PR_APROPIACION.codigo_compania%TYPE,
                             una_unidad        PR_APROPIACION.codigo_unidad_ejecutora%TYPE,
                             un_codigo_fuente  PR_DETALLE_FUENTES_APROPIA.codigo_fuente%TYPE,
                             un_detalle_fuente PR_DETALLE_FUENTES_APROPIA.codigo_det_fuente_financ%TYPE,
                             una_clasificacion PR_DETALLE_FUENTES.clasificacion%TYPE,
                             un_valor          PR_DETALLE_FUENTES_APROPIA.valor%TYPE)
                             RETURN NUMBER IS


mi_e_integridad  EXCEPTION;
mi_e_privilegios EXCEPTION;
mi_e_llavePk     EXCEPTION;
PRAGMA EXCEPTION_INIT(mi_e_integridad,-2291);
PRAGMA EXCEPTION_INIT(mi_e_integridad,-1402);
PRAGMA EXCEPTION_INIT(mi_e_llavePk,-1);

BEGIN

   INSERT INTO PR_DETALLE_FUENTES_APROPIA ( VIGENCIA,
                                            RUBRO_INTERNO,
                                            CODIGO_COMPANIA,
                                            CODIGO_UNIDAD_EJECUTORA,
                                            CODIGO_FUENTE,
                                            CODIGO_DET_FUENTE_FINANC,
                                            CLASIFICACION,
                                            VALOR)
    VALUES (una_vigencia,
            un_rubro,
            una_compania,
            una_unidad,
            un_codigo_fuente,
            un_detalle_fuente,
            una_clasificacion,
            un_valor);

   RETURN (1);

   EXCEPTION
      WHEN mi_e_integridad THEN
	  --no puede insertar por itegridad refreencial
           RETURN 0;
	  WHEN mi_e_privilegios THEN
	  --no puede insertar porque el usuario no tiene privilegios
           RETURN 0;
	  WHEN mi_e_llavePk THEN
	  --la llave primaria ya esta en la tabla por tanto no deja insertar
	   	   RETURN 0;


END fn_pre_ins_apropia;


/********************************************************
 Funcion: fn_cursor
 Descripcion: Crea el cursor que contiene el detalle de las fuentes de financiacion
 Entradas: Vigencia
           Rubro
           Compania
           Unidad ejecutora

 Salidas:  Cursor que contiene el detalle de las fuentes
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

*********************************************************/

FUNCTION fn_cursor  (una_vigencia      PR_APROPIACION.vigencia%TYPE,
                     un_rubro          PR_APROPIACION.rubro_interno%TYPE,
                     una_compania      PR_APROPIACION.codigo_compania%TYPE,
                     una_unidad        PR_APROPIACION.codigo_unidad_ejecutora%TYPE)
                     RETURN Pk_Pr_Detalle_Fuentes.cur_c_temporal IS

c_cursor1 Pk_Pr_Detalle_Fuentes.cur_c_temporal;
BEGIN

OPEN c_cursor1 FOR SELECT codigo_fuente,
                          codigo_det_fuente_financ,
                          valor
                   FROM PR_TEMPORAL_FUENTES_APROPIA
                   WHERE vigencia=una_vigencia
                   AND   rubro_interno=un_rubro
                   AND   codigo_compania=una_compania
                   AND   codigo_unidad_ejecutora=una_unidad;

RETURN (c_cursor1);

END;

/********************************************************
 Funcion: fn_pre_traer_desc_fuente
 Descripcion: trae la descripcion de una fuente de financiacion
 Entradas: Codigo de la fuente
 Salidas:  Descripcion de la fuente.
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

 *********************************************************/

 FUNCTION fn_pre_traer_desc_fuente (una_fuente VARCHAR) RETURN VARCHAR2 IS
   mi_desc_fuente  PR_FUENTES_FINANCIACION.descripcion%TYPE;

    -- Requiere cursor para determinar datos: Descripcion de Entidades.


     CURSOR c_fuente IS
        SELECT descripcion
        FROM PR_FUENTES_FINANCIACION
        WHERE codigo = una_fuente;
     BEGIN
        OPEN c_fuente;
        FETCH c_fuente INTO mi_desc_fuente;
        CLOSE c_fuente;
        RETURN mi_desc_fuente;

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
          RETURN NULL;
       WHEN INVALID_CURSOR THEN
		  RETURN NULL;
END;

/********************************************************
 Funcion: fn_pre_traer_desc_det_fuente
 Descripcion: trae la descripcion de un detalle de fuente de financiacion
 Entradas: Codigo del detalle de la fuente
           Vigencia
           Codigo Fuente
           Clasificacion
 Salidas:  Descripcion del detalle de la fuente.
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

 *********************************************************/

FUNCTION fn_pre_traer_desc_det_fuente (un_detalle_fuente NUMBER,
                                       una_vigencia NUMBER,
                                       un_codigo_fuente VARCHAR,
                                       una_clasificacion VARCHAR) RETURN VARCHAR IS
   mi_desc_detalle_fuente  PR_DETALLE_FUENTES.descripcion%TYPE;


    CURSOR c_detalle_fuente IS
        SELECT descripcion
        FROM PR_DETALLE_FUENTES
        WHERE consecutivo_fuente = un_detalle_fuente AND
              vigencia=una_vigencia AND
              codigo_fuentes_financiacion=un_codigo_fuente AND
              clasificacion=una_clasificacion;

    BEGIN

      OPEN c_detalle_fuente;
      FETCH c_detalle_fuente INTO mi_desc_detalle_fuente;
      CLOSE c_detalle_fuente;
      RETURN mi_desc_detalle_fuente;

    EXCEPTION
       WHEN NO_DATA_FOUND THEN
          RETURN ('No Encontro Detalle');
	   WHEN INVALID_CURSOR THEN
	      RETURN NULL;

END;

/********************************************************
 Funcion: fn_busca_entidad
 Descripcion: Busca una entidad para determinar si la entidad
              tiene autorizadas las fuuentes de fu?inanciacion
 Entradas: Codigo_entidad
 Salidas: Falso: si no encuentra la entidad
          Verdadero: Si la emtidad esta registrada
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

 *********************************************************/
FUNCTION fn_pre_busca_entidad( un_codigo_compania VARCHAR2,
                               una_vigencia       NUMBER ) RETURN BOOLEAN IS

    mi_entidad  VARCHAR2(3);
    mi_detalle_habilitado VARCHAR2(250);


     CURSOR cur_entidad IS
        SELECT  codigo_compania
        FROM PR_FUENTES_FINANCIA_ENTIDAD
        WHERE codigo_compania = un_codigo_compania
        AND   vigencia=una_vigencia;


    BEGIN

      -- En bintablas se verifica que en la variable DET_FUENTE_HABILITADO,
      -- este registrada la entidad;
      -- Valores: (SI) - Se permite registrar informacion del detalle de la fuente
      --          (NO) - No se permite registrar informacion del detalle de la fuente

      mi_detalle_habilitado := RTRIM(LTRIM(Pk_Pr_Consolidados_Gastos.fn_pre_TBuscar(un_codigo_compania,'PREDIS','DET_FUENTE_HABILITADO','01/01/'||TO_CHAR(una_vigencia))));

      IF mi_detalle_habilitado = 'SI' THEN

         -- Verifica entidad tiene asociadas fuentes
         OPEN cur_entidad;
         FETCH cur_entidad INTO mi_entidad;

         IF cur_entidad%NOTFOUND THEN
            CLOSE cur_entidad;
            RETURN FALSE;
         ELSE
            CLOSE cur_entidad;
            RETURN TRUE;
         END IF;
      ELSE
         RETURN FALSE;
      END IF;

END fn_pre_busca_entidad;

/********************************************************
 Procedimiento: pr_pre_ins_anula_total_detalle
 Descripcion:Insertqa los regostros correspondientes  al detalle de fuentes de financiacion
             cuando se hacen anulaciones totales de CDP's
 Entradas: vigencia, codigo_compania, numero_documento , documento_anulado
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

 *********************************************************/
PROCEDURE pr_pre_ins_anula_total_detalle ( una_vigencia         NUMBER,
                                           un_codigo_compania   VARCHAR2,
                                           una_unidad_ejecutora VARCHAR2,
                                           un_numero_documento  NUMBER,
                                           un_documento_anulado VARCHAR2
                                             ) IS

mi_e_integridad  EXCEPTION;
mi_e_privilegios EXCEPTION;
mi_e_llavePk     EXCEPTION;
PRAGMA EXCEPTION_INIT(mi_e_integridad,-2291);
PRAGMA EXCEPTION_INIT(mi_e_integridad,-1402);
PRAGMA EXCEPTION_INIT(mi_e_llavePk,-1);

 BEGIN

  INSERT INTO PR_ANULACION_TOTAL_DETA_FTES
         (VALOR,
          VIGENCIA,
          RUBRO_INTERNO,
          CODIGO_COMPANIA,
          CODIGO_UNIDAD_EJECUTORA,
          CODIGO_FUENTE,
          CODIGO_DET_FUENTE_FINANC,
          CLASIFICACION,
          NUMERO_DOCUMENTO,
          DOCUMENTO_ANULADO)
 (  SELECT
        VALOR,
        VIGENCIA,
        RUBRO_INTERNO,
        CODIGO_COMPANIA,
        CODIGO_UNIDAD_EJECUTORA,
        CODIGO_FUENTE,
        CODIGO_DET_FUENTE_FINANC,
        CLASIFICACION,
        NUMERO_DISPONIBILIDAD,
        un_documento_anulado
  FROM PR_DETALLE_FUENTES_CDP
  WHERE
  vigencia=una_vigencia AND
  codigo_compania=un_codigo_compania AND
  codigo_unidad_ejecutora=una_unidad_ejecutora AND
  numero_disponibilidad = un_numero_documento);
  COMMIT;

    EXCEPTION
      WHEN mi_e_integridad THEN
	  --no puede insertar por itegridad refreencial
           ROLLBACK;
	  WHEN mi_e_privilegios THEN
	  --no puede insertar porque el usuario no tiene privilegios
           ROLLBACK;
	  WHEN mi_e_llavePk THEN
	  --la llave primaria ya esta en la tabla por tanto no deja insertar
	   	   ROLLBACK;


 END  pr_pre_ins_anula_total_detalle;

/********************************************************
 Procedimiento: pr_pre_ins_anula_total_deta_rp
 Descripcion:Inserta anulacioens totales de los registros correspondientes
             al detalle de fuentes de financiacion
             cuando se hacen anulaciones totales de CDP's
 Entradas: vigencia, codigo_compania, numero_documento , documento_anulado

 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o
 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

 *********************************************************/

PROCEDURE pr_pre_ins_anula_total_deta_rp ( una_vigencia               NUMBER,
                                           un_codigo_compania         VARCHAR2,
                                           una_unidad_ejecutora       VARCHAR2,
                                           un_numero_documento        NUMBER,  --NUMERO DEL RP
                                           un_documento_anulado       VARCHAR2 -- RP
                                           ) IS

mi_e_integridad  EXCEPTION;
mi_e_privilegios EXCEPTION;
mi_e_llavePk     EXCEPTION;
PRAGMA EXCEPTION_INIT(mi_e_integridad,-2291);
PRAGMA EXCEPTION_INIT(mi_e_integridad,-1402);
PRAGMA EXCEPTION_INIT(mi_e_llavePk,-1);

BEGIN


INSERT INTO PR_ANULACION_TOTAL_DETA_FTES
         (VALOR,
          VIGENCIA,
          RUBRO_INTERNO,
          CODIGO_COMPANIA,
          CODIGO_UNIDAD_EJECUTORA,
          CODIGO_FUENTE,
          CODIGO_DET_FUENTE_FINANC,
          CLASIFICACION,
          NUMERO_DOCUMENTO,
          DOCUMENTO_ANULADO,
          NUMERO_DISPONIBILIDAD)
 (  SELECT
        VALOR,
        VIGENCIA,
        RUBRO_INTERNO,
        CODIGO_COMPANIA,
        CODIGO_UNIDAD_EJECUTORA,
        CODIGO_FUENTE,
        CODIGO_DET_FUENTE_FINANC,
        CLASIFICACION,
        NUMERO_REGISTRO,
        un_documento_anulado,
        NUMERO_DISPONIBILIDAD
  FROM PR_DETALLE_FUENTES_RP
  WHERE
  vigencia=una_vigencia AND
  codigo_compania=un_codigo_compania AND
  codigo_unidad_ejecutora=una_unidad_ejecutora AND
  numero_registro = un_numero_documento);
  COMMIT;
      EXCEPTION
      WHEN mi_e_integridad THEN
	  --no puede insertar por itegridad refreencial
           ROLLBACK;
	  WHEN mi_e_privilegios THEN
	  --no puede insertar porque el usuario no tiene privilegios
           ROLLBACK;
	  WHEN mi_e_llavePk THEN
	  --la llave primaria ya esta en la tabla por tanto no deja insertar
	   	   ROLLBACK;


 END  pr_pre_ins_anula_total_deta_rp;

/*********************************************r***********
 Procedimiento: pr_pre_ins_anula_total_deta_op
 Descripcion:Inserta los registros correspondientes al detalle de fuentes de financiacion
             cuando se hacen anulaciones totales de Ordenes de Pago
 Entradas: vigencia, codigo_compania, numero_documento , documento_anulado
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o
 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

 *********************************************************/


PROCEDURE pr_pre_ins_anula_total_deta_op ( una_vigencia               NUMBER,
                                           un_codigo_compania         VARCHAR2,
                                           una_unidad_ejecutora       VARCHAR2,
                                           un_numero_documento        NUMBER,  --NUMERO ORDEN OP
                                           un_documento_anulado       VARCHAR2 -- ORDEN
                                         ) IS
mi_e_integridad  EXCEPTION;
mi_e_privilegios EXCEPTION;
mi_e_llavePk     EXCEPTION;
PRAGMA EXCEPTION_INIT(mi_e_integridad,-2291);
PRAGMA EXCEPTION_INIT(mi_e_integridad,-1402);
PRAGMA EXCEPTION_INIT(mi_e_llavePk,-1);
BEGIN


INSERT INTO PR_ANULACION_TOTAL_DETA_FTES
         (VALOR,
          VIGENCIA,
          RUBRO_INTERNO,
          CODIGO_COMPANIA,
          CODIGO_UNIDAD_EJECUTORA,
          CODIGO_FUENTE,
          CODIGO_DET_FUENTE_FINANC,
          CLASIFICACION,
          NUMERO_DOCUMENTO,
          DOCUMENTO_ANULADO,
          NUMERO_DISPONIBILIDAD,
          NUMERO_REGISTRO,
          CONSECUTIVO_ORDEN)
 (  SELECT
        VALOR,
        VIGENCIA,
        RUBRO_INTERNO,
        CODIGO_COMPANIA,
        CODIGO_UNIDAD_EJECUTORA,
        CODIGO_FUENTE,
        CODIGO_DET_FUENTE_FINANC,
        CLASIFICACION,
        NUMERO_ORDEN,
        un_documento_anulado,
        NUMERO_DISPONIBILIDAD,
        NUMERO_REGISTRO,
        CONSECUTIVO_ORDEN
  FROM PR_DETALLE_FUENTES_OP
  WHERE  vigencia=una_vigencia
  AND codigo_compania=un_codigo_compania
  AND codigo_unidad_ejecutora=una_unidad_ejecutora
  AND numero_orden = un_numero_documento
  );

  COMMIT;

      EXCEPTION
      WHEN mi_e_integridad THEN
	  --no puede insertar por itegridad refreencial
           ROLLBACK;
	  WHEN mi_e_privilegios THEN
	  --no puede insertar porque el usuario no tiene privilegios
           ROLLBACK;
	  WHEN mi_e_llavePk THEN
	  --la llave primaria ya esta en la tabla por tanto no deja insertar
	   	   ROLLBACK;


 END  pr_pre_ins_anula_total_deta_op;


 /********************************************************
 Procedimiento: pr_pre_ins_anul_total_det_reser
 Descripcion:Inserta los regIstros correspondientes al detalle de fuentes de financiacion
             cuando se hacen anulaciones totales de reservas (CDP's)
 Entradas: vigencia, codigo_compania, numero_documento , documento_anulado
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o
 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

 *********************************************************/

PROCEDURE pr_pre_ins_anulTot_det_reser (una_vigencia          NUMBER,
                                        un_codigo_compania    VARCHAR2,
                                        una_unidad_ejecutora  VARCHAR2,
                                        un_numero_documento   NUMBER,
                                        un_documento_anulado  VARCHAR2,
                                        un_numero_registro    NUMBER,
                                        un_consecutivo_orden  NUMBER) IS

mi_e_integridad  EXCEPTION;
mi_e_privilegios EXCEPTION;
mi_e_llavePk     EXCEPTION;
PRAGMA EXCEPTION_INIT(mi_e_integridad,-2291);
PRAGMA EXCEPTION_INIT(mi_e_integridad,-1402);
PRAGMA EXCEPTION_INIT(mi_e_llavePk,-1);

 BEGIN

  INSERT INTO PR_ANULA_RESERVAS_DETALLE
         (VIGENCIA,
          CODIGO_COMPANIA,
          CODIGO_UNIDAD_EJECUTORA,
          DOCUMENTO_ANULADO,
          NUMERO_DOCUMENTO_ANULADO,
          NUMERO_REGISTRO,
          CONSECUTIVO_ORDEN,
          CODIGO_FUENTE,
          CODIGO_DET_FUENTE_FINANC,
          RUBRO_INTERNO,
          VALOR
          )
 (  SELECT
        VIGENCIA,
        CODIGO_COMPANIA,
        CODIGO_UNIDAD_EJECUTORA,
        un_documento_anulado,
        NUMERO_DISPONIBILIDAD,
        un_numero_registro,
        un_consecutivo_orden,
        CODIGO_FUENTE,
        CODIGO_DET_FUENTE_FINANC,
        RUBRO_INTERNO,
        VALOR
  FROM PR_DETALLE_FUENTES_CDP
  WHERE
  vigencia=una_vigencia AND
  codigo_compania=un_codigo_compania AND
  codigo_unidad_ejecutora=una_unidad_ejecutora AND
  numero_disponibilidad = un_numero_documento);

  COMMIT;

  EXCEPTION
      WHEN mi_e_integridad THEN
	  --no puede insertar por itegridad refreencial
           ROLLBACK;
	  WHEN mi_e_privilegios THEN
	  --no puede insertar porque el usuario no tiene privilegios
           ROLLBACK;
	  WHEN mi_e_llavePk THEN
	  --la llave primaria ya esta en la tabla por tanto no deja insertar
	   	   ROLLBACK;


 END  pr_pre_ins_anulTot_det_reser;

/********************************************************
 Procedimiento: pr_pre_insanulTot_det_reseRp
 Descripcion:Inserta los regostros correspondientes al detalle de fuentes de financiacion
             cuando se hacen anulaciones totales de reservas (CDP's)
 Entradas: vigencia, codigo_compania, numero_documento , documento_anulado
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o
 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

 *********************************************************/

PROCEDURE pr_pre_insanulTot_det_reseRp (una_vigencia          NUMBER,
                                        un_codigo_compania    VARCHAR2,
                                        una_unidad_ejecutora  VARCHAR2,
                                        un_numero_documento   NUMBER,
                                        un_documento_anulado  VARCHAR2,
                                        un_numero_registro    NUMBER,
                                        un_consecutivo_orden  NUMBER) IS

mi_e_integridad  EXCEPTION;
mi_e_privilegios EXCEPTION;
mi_e_llavePk     EXCEPTION;
PRAGMA EXCEPTION_INIT(mi_e_integridad,-2291);
PRAGMA EXCEPTION_INIT(mi_e_integridad,-1402);
PRAGMA EXCEPTION_INIT(mi_e_llavePk,-1);

 BEGIN

  INSERT INTO PR_ANULA_RESERVAS_DETALLE
         (VIGENCIA,
          CODIGO_COMPANIA,
          CODIGO_UNIDAD_EJECUTORA,
          DOCUMENTO_ANULADO,
          NUMERO_DOCUMENTO_ANULADO,
          NUMERO_REGISTRO,
          CONSECUTIVO_ORDEN,
          CODIGO_FUENTE,
          CODIGO_DET_FUENTE_FINANC,
          RUBRO_INTERNO,
          VALOR
          )
 (  SELECT
        VIGENCIA,
        CODIGO_COMPANIA,
        CODIGO_UNIDAD_EJECUTORA,
        un_documento_anulado,
        NUMERO_REGISTRO,
        un_numero_registro,
        un_consecutivo_orden,
        CODIGO_FUENTE,
        CODIGO_DET_FUENTE_FINANC,
        RUBRO_INTERNO,
        VALOR
  FROM PR_DETALLE_FUENTES_RP
  WHERE
  vigencia=una_vigencia AND
  codigo_compania=un_codigo_compania AND
  codigo_unidad_ejecutora=una_unidad_ejecutora AND
  numero_registro = un_numero_documento);

  COMMIT;

  EXCEPTION
      WHEN mi_e_integridad THEN
	  --no puede insertar por itegridad refreencial
           ROLLBACK;
	  WHEN mi_e_privilegios THEN
	  --no puede insertar porque el usuario no tiene privilegios
           ROLLBACK;
	  WHEN mi_e_llavePk THEN
	  --la llave primaria ya esta en la tabla por tanto no deja insertar
	   	   ROLLBACK;

 END  pr_pre_insanulTot_det_reseRp;


  /********************************************************
 Procedimiento: pr_pre_insanulTot_det_reseOp
 Descripcion:Inserta los registros correspondientes al detalle de fuentes de financiacion
             cuando se hacen anulaciones totales de reservas (Ordenes de Pago )
 Entradas: vigencia, codigo_compania, numero_documento , documento_anulado
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o
 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

 *********************************************************/

PROCEDURE pr_pre_insanulTot_det_reseOp (una_vigencia          NUMBER,
                                        un_codigo_compania    VARCHAR2,
                                        una_unidad_ejecutora  VARCHAR2,
                                        un_numero_documento   NUMBER,
                                        un_documento_anulado  VARCHAR2,
                                        un_numero_registro    NUMBER,
                                        un_consecutivo_orden  NUMBER) IS

mi_e_integridad  EXCEPTION;
mi_e_privilegios EXCEPTION;
mi_e_llavePk     EXCEPTION;
PRAGMA EXCEPTION_INIT(mi_e_integridad,-2291);
PRAGMA EXCEPTION_INIT(mi_e_integridad,-1402);
PRAGMA EXCEPTION_INIT(mi_e_llavePk,-1);

 BEGIN

  INSERT INTO PR_ANULA_RESERVAS_DETALLE
         (VIGENCIA,
          CODIGO_COMPANIA,
          CODIGO_UNIDAD_EJECUTORA,
          DOCUMENTO_ANULADO,
          NUMERO_DOCUMENTO_ANULADO,
          NUMERO_REGISTRO,
          CONSECUTIVO_ORDEN,
          CODIGO_FUENTE,
          CODIGO_DET_FUENTE_FINANC,
          RUBRO_INTERNO,
          VALOR
          )
 (  SELECT
        VIGENCIA,
        CODIGO_COMPANIA,
        CODIGO_UNIDAD_EJECUTORA,
        un_documento_anulado,
        NUMERO_ORDEN,
        NUMERO_REGISTRO,
        CONSECUTIVO_ORDEN,
        CODIGO_FUENTE,
        CODIGO_DET_FUENTE_FINANC,
        RUBRO_INTERNO,
        VALOR
  FROM PR_DETALLE_FUENTES_OP
  WHERE
  vigencia=una_vigencia
  AND  codigo_compania=un_codigo_compania
  AND  codigo_unidad_ejecutora=una_unidad_ejecutora
  AND  numero_orden = un_numero_documento
  AND  consecutivo_orden=un_consecutivo_orden);

  COMMIT;

  EXCEPTION
      WHEN mi_e_integridad THEN
	  --no puede insertar por itegridad refreencial
           ROLLBACK;
	  WHEN mi_e_privilegios THEN
	  --no puede insertar porque el usuario no tiene privilegios
           ROLLBACK;
	  WHEN mi_e_llavePk THEN
	  --la llave primaria ya esta en la tabla por tanto no deja insertar
	   	   ROLLBACK;


 END  pr_pre_insanulTot_det_reseOp;


/***********************************************************************************************
 Funcion: fn_pre_cuenta_registros_apro
 Descripcion:Trae el total de registros de detalle de apropiaciones
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora
 Salidas : Total de Registros de detalle de apropiaciones.
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

 ***********************************************************************************************/

FUNCTION fn_pre_cuenta_registros_apro(una_vigencia               NUMBER,
                                      un_rubro_interno           NUMBER,
                                      una_compania               VARCHAR2,
                                      una_unidad_ejecutora       VARCHAR2
                                      )RETURN NUMBER IS

mi_num_registros  NUMBER;

CURSOR c_deta_fuente IS
  SELECT COUNT(*)
        FROM   PR_DETALLE_FUENTES_APROPIA
        WHERE  vigencia = una_vigencia
        AND    rubro_interno = un_rubro_interno
        AND    codigo_compania=una_compania
        AND    codigo_unidad_ejecutora=una_unidad_ejecutora;


  BEGIN
        OPEN c_deta_fuente;
        FETCH c_deta_fuente INTO mi_num_registros;
        CLOSE c_deta_fuente;
        RETURN mi_num_registros;

  EXCEPTION
       WHEN NO_DATA_FOUND THEN
          RETURN 0;

END;


/***********************************************************************************************
 Funcion: fn_pre_cuenta_registros
 Descripcion:Trae el total de registros de detalle de disponibilidades para un rubro
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora
 Salidas : Total de Registros de detalle de apropiaciones.
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

 ***********************************************************************************************/
FUNCTION fn_pre_cuenta_registros(una_vigencia              NUMBER,
                                 un_rubro_interno          NUMBER,
                                 una_compania              VARCHAR2,
                                 una_unidad_ejecutora      VARCHAR2,
                                 un_numero_disponibilidad  NUMBER)   RETURN NUMBER IS
mi_num_registros  NUMBER;

CURSOR c_deta_fuente IS
  SELECT COUNT(*)
        FROM PR_DETALLE_FUENTES_CDP
        WHERE vigencia = una_vigencia
        AND   rubro_interno = un_rubro_interno
        AND   codigo_compania=una_compania
        AND   codigo_unidad_ejecutora=una_unidad_ejecutora
        AND   numero_disponibilidad=un_numero_disponibilidad;


  BEGIN
        OPEN c_deta_fuente;
        FETCH c_deta_fuente INTO mi_num_registros;
        CLOSE c_deta_fuente;
        RETURN mi_num_registros;

  EXCEPTION
       WHEN NO_DATA_FOUND THEN
          RETURN 0;

END fn_pre_cuenta_registros;



/***********************************************************************************************
 Funcion: fn_pre_TraeAcum_CDPT
 Descripcion:Trae el acumulado del cdp, de la tabla temporal
 en la tabla temporal de disponibilidades
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora
 Salidas : Total de Registros de detalle de apropiaciones.
 Fecha             Octubre 2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

 ***********************************************************************************************/

FUNCTION fn_pre_TraeAcum_CDPT(una_vigencia              NUMBER,
                              un_rubro_interno          NUMBER,
                              una_compania              VARCHAR2,
                              una_unidad_ejecutora      VARCHAR2,
                              un_usuario                VARCHAR2,
							  un_consec_user            NUMBER)
							  RETURN NUMBER IS


mi_valor_registros  NUMBER;

CURSOR c_deta_fuente IS
  SELECT SUM (valor)
        FROM PR_DETALLE_FUENTES_CDPT
        WHERE vigencia = una_vigencia
        AND   rubro_interno = un_rubro_interno
        AND   codigo_compania=una_compania
        AND   codigo_unidad_ejecutora=una_unidad_ejecutora
		AND   numero_disponibilidad=0
	    AND   usuario=un_usuario
		AND   consec_user=un_consec_user;


  BEGIN
        OPEN c_deta_fuente;
        FETCH c_deta_fuente INTO mi_valor_registros;
        CLOSE c_deta_fuente;
        RETURN mi_valor_registros;

  EXCEPTION
       WHEN NO_DATA_FOUND THEN
          RETURN 0;

END fn_pre_TraeAcum_CDPT;





/***********************************************************************************************
 Funcion: fn_pre_cuenta_registros_rp
 Descripcion:Trae el total de registros de detalle de rp para
             un rubro
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, Numero disponibilidad, Numero Registro
           presupuestal.

 Salidas : Total de Registros de Rp.
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

 ***********************************************************************************************/

FUNCTION fn_pre_cuenta_registros_rp(una_vigencia               NUMBER,
                                    un_rubro_interno           NUMBER,
                                    una_compania               VARCHAR2,
                                    una_unidad_ejecutora       VARCHAR2,
                                    un_numero_disponibilidad   NUMBER,
                                    un_numero_registro         NUMBER )RETURN NUMBER IS


mi_num_registros_rp  NUMBER;

CURSOR c_deta_fuente_rp IS
  SELECT COUNT(*)
  FROM PR_DETALLE_FUENTES_RP
  WHERE vigencia = una_vigencia
  AND   rubro_interno = un_rubro_interno
  AND   codigo_compania=una_compania
  AND   codigo_unidad_ejecutora=una_unidad_ejecutora
  AND   numero_disponibilidad=un_numero_disponibilidad
  AND   numero_registro=un_numero_registro;



  BEGIN
        OPEN c_deta_fuente_rp;
        FETCH c_deta_fuente_rp INTO mi_num_registros_rp;
        CLOSE c_deta_fuente_rp;
        RETURN mi_num_registros_rp;

  EXCEPTION
       WHEN NO_DATA_FOUND THEN
          RETURN 0;

END;



/***********************************************************************************************
 Funcion: fn_pre_cuenta_registros_op
 Descripcion:Trae el total de registros de detalle de rp para
             un rubro
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, Numero disponibilidad, Numero Registro
           presupuestal.

 Salidas : Total de Registros de Ordenes de pago.
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

 ***********************************************************************************************/

FUNCTION fn_pre_cuenta_registros_op (una_vigencia                NUMBER,
                                    un_rubro_interno             NUMBER,
                                    una_compania                 VARCHAR2,
                                    una_unidad_ejecutora         VARCHAR2,
                                    un_numero_disponibilidad     NUMBER,
                                    un_numero_registro           NUMBER,
                                    un_numero_orden              NUMBER,
                                    un_consecutivo_orden         NUMBER ) RETURN NUMBER  IS


mi_num_registros_op  NUMBER;

CURSOR c_deta_fuente_op IS
  SELECT COUNT(*)
  FROM PR_DETALLE_FUENTES_OP
  WHERE vigencia = una_vigencia
  AND   rubro_interno = un_rubro_interno
  AND   codigo_compania=una_compania
  AND   codigo_unidad_ejecutora=una_unidad_ejecutora
  AND   numero_disponibilidad=un_numero_disponibilidad
  AND   numero_registro=un_numero_registro
  AND   numero_orden=un_numero_orden
  AND   consecutivo_orden=un_consecutivo_orden;

  BEGIN
        OPEN c_deta_fuente_op;
        FETCH c_deta_fuente_op INTO mi_num_registros_op;
        CLOSE c_deta_fuente_op;
        RETURN mi_num_registros_op;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 0;

END;


/***********************************************************************************************
 Funcion: fn_pre_cuenta_registros_reint
 Descripcion:Trae el total de registros de detalle de reintgegros.
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, Numero disponibilidad, Numero Registro
           presupuestal, numero_orden, consecutivo_orden, consecutivo_ajuste.

 Salidas : Total de Registros de reintegros (de detalle fuentes) .
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

 ***********************************************************************************************/

FUNCTION fn_pre_cuenta_registros_reint (una_vigencia                 NUMBER,
                                        un_rubro_interno             NUMBER,
                                        una_compania                 VARCHAR2,
                                        una_unidad_ejecutora         VARCHAR2,
                                        un_numero_disponibilidad     NUMBER,
                                        un_numero_registro           NUMBER,
                                        un_numero_orden              NUMBER,
                                        un_consecutivo_orden         NUMBER,
                                        un_consecutivo_ajuste        NUMBER ) RETURN NUMBER  IS


mi_num_registros_reint  NUMBER;

CURSOR c_deta_fuente_reint IS
  SELECT COUNT(*)
  FROM PR_DETALLE_FUENTES_REINT
  WHERE vigencia = una_vigencia
  AND   rubro_interno = un_rubro_interno
  AND   codigo_compania=una_compania
  AND   codigo_unidad_ejecutora=una_unidad_ejecutora
  AND   numero_disponibilidad=un_numero_disponibilidad
  AND   numero_registro=un_numero_registro
  AND   numero_orden=un_numero_orden
  AND   consecutivo_orden=un_consecutivo_orden
  AND   consecutivo_ajuste=un_consecutivo_ajuste;

  BEGIN
   OPEN c_deta_fuente_reint;
   FETCH c_deta_fuente_reint INTO mi_num_registros_reint;
   CLOSE c_deta_fuente_reint;
   RETURN mi_num_registros_reint;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 0;

END;


/***********************************************************************************************
 Funcion: fn_pre_cuenta_registros_ajust
 Descripcion:Trae el total de registros de detalle de los ajustes.
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, Numero disponibilidad, Numero Registro
           presupuestal, numero_orden, consecutivo_orden, consecutivo_ajuste.

 Salidas : Total de Registros de ajustes  (de detalle fuentes) .
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

 ***********************************************************************************************/


FUNCTION fn_pre_cuenta_registros_ajust (una_vigencia                 NUMBER,
                                        un_rubro_interno             NUMBER,
                                        una_compania                 VARCHAR2,
                                        una_unidad_ejecutora         VARCHAR2,
                                        un_numero_disponibilidad     NUMBER,
                                        un_numero_registro           NUMBER,
                                        un_numero_orden              NUMBER,
                                        un_consecutivo_orden         NUMBER,
                                        un_consecutivo_ajuste        NUMBER ) RETURN NUMBER  IS


mi_num_registros_ajust  NUMBER;

CURSOR c_deta_fuente_ajust IS
  SELECT COUNT(*)
  FROM PR_DETALLE_FUENTES_AJUSTES
  WHERE vigencia = una_vigencia
  AND   rubro_interno = un_rubro_interno
  AND   codigo_compania=una_compania
  AND   codigo_unidad_ejecutora=una_unidad_ejecutora
  AND   numero_disponibilidad=un_numero_disponibilidad
  AND   numero_registro=un_numero_registro
  AND   numero_orden=un_numero_orden
  AND   consecutivo_orden=un_consecutivo_orden
  AND   consecutivo_ajuste=un_consecutivo_ajuste;

  BEGIN
        OPEN c_deta_fuente_ajust;
        FETCH c_deta_fuente_ajust INTO mi_num_registros_ajust;
        CLOSE c_deta_fuente_ajust;
        RETURN mi_num_registros_ajust;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 0;

END;

/***********************************************************************************************
 Funcion: fn_pre_cuenta_registros_res
 Descripcion:Trae el total de registros de detalle de anulacion parcial de reservas.
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, Numero disponibilidad, Numero Registro
           presupuestal,consecutivo_anulacion.

 Salidas : Total de Registros de anulacion parcial de reservas .
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_cuenta_registros_res(una_vigencia                NUMBER,
                                     un_rubro_interno            NUMBER,
                                     una_compania                VARCHAR2,
                                     una_unidad_ejecutora        VARCHAR2,
                                     un_numero_disponibilidad    NUMBER,
                                     un_numero_registro          NUMBER,
                                     un_consecutivo_anulacion    NUMBER )RETURN NUMBER IS


mi_num_registros_rp  NUMBER;

CURSOR c_deta_fuente_rp IS
  SELECT COUNT(*)
  FROM  PR_RP_ANULA_RES_DETA
  WHERE vigencia = una_vigencia
  AND   rubro_interno = un_rubro_interno
  AND   codigo_compania=una_compania
  AND   codigo_unidad_ejecutora=una_unidad_ejecutora
  AND   numero_disponibilidad=un_numero_disponibilidad
  AND   numero_registro=un_numero_registro
  AND   consecutivo_anulacion=un_consecutivo_anulacion;


  BEGIN
   OPEN c_deta_fuente_rp;
   FETCH c_deta_fuente_rp INTO mi_num_registros_rp;
   CLOSE c_deta_fuente_rp;
   RETURN mi_num_registros_rp;

  EXCEPTION
       WHEN NO_DATA_FOUND THEN
          RETURN 0;

END;


/***********************************************************************************************
 Funcion: fn_pre_cuenta_reg_modif
 Descripcion:trae el total de registros detallados en las modificaciones
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, Numero disponibilidad, Numero Registro
           presupuestal,consecutivo_anulacion.

 Salidas : Total de Registros de anulacion parcial de reservas .
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_cuenta_reg_modif (una_vigencia                NUMBER,
                                  una_compania                VARCHAR2,
                                  una_unidad_ejecutora        VARCHAR2,
                                  un_tipo_documento           VARCHAR2,
                                  un_documentos_numero        NUMBER,
                                  un_rubro_interno            NUMBER,
                                  un_tipo_movimiento          VARCHAR2,
                                  un_numero_disponibilidad    NUMBER)
                                  RETURN NUMBER IS


mi_num_registros_modif  NUMBER;

CURSOR c_deta_fuente_modif IS
  SELECT COUNT(*)
  FROM  PR_DETALLE_FUENTES_MODIF
  WHERE vigencia = una_vigencia
  AND   codigo_compania=una_compania
  AND   codigo_unidad_ejecutora=una_unidad_ejecutora
  AND   tipo_documento = un_tipo_documento
  AND   documentos_numero=un_documentos_numero
  AND   rubro_interno = un_rubro_interno
  AND   tipo_movimiento=un_tipo_movimiento
  AND   numero_disponibilidad=un_numero_disponibilidad;


  BEGIN
   OPEN c_deta_fuente_modif;
   FETCH c_deta_fuente_modif INTO mi_num_registros_modif;
   CLOSE c_deta_fuente_modif;
   RETURN mi_num_registros_modif;

  EXCEPTION
       WHEN NO_DATA_FOUND THEN
          RETURN 0;

END;


/***********************************************************************************************
 Funcion: fn_pre_cuenta_cdp_anulados
 Descripcion:trae el total de registros detallados en la anulacion de disponiobuilidades
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, Numero disponibilidad, Numero Registro
           presupuestal,consecutivo_anulacion.

 Salidas : Total de Registros de anulacion parcial de reservas .
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_cuenta_cdp_anulados (mi_vigencia               NUMBER,
                                    mi_rubro_interno          NUMBER,
                                    mi_compania               VARCHAR2,
                                    mi_unidad_ejecutora       VARCHAR2,
                                    mi_numero_disponibilidad  NUMBER,
                                    mi_numero_registro        NUMBER,
                                    mi_consec_anulacion       NUMBER )RETURN NUMBER IS


mi_num_registros  NUMBER;

CURSOR c_deta_anula_cdp IS
  SELECT COUNT(*)
  FROM PR_ANULA_DETALLE_CDP
  WHERE vigencia = mi_vigencia
  AND   rubro_interno = mi_rubro_interno
  AND   codigo_compania=mi_compania
  AND   codigo_unidad_ejecutora=mi_unidad_ejecutora
  AND   numero_disponibilidad=mi_numero_disponibilidad
  AND   numero_registro=mi_numero_registro
  AND   consecutivo_anulacion=mi_consec_anulacion;



  BEGIN
        OPEN  c_deta_anula_cdp;
        FETCH c_deta_anula_cdp INTO mi_num_registros;
        CLOSE  c_deta_anula_cdp;
        RETURN mi_num_registros;

  EXCEPTION
       WHEN NO_DATA_FOUND THEN
          RETURN 0;

END;


 /***********************************************************************************************
 Funcion: fn_pre_traer_valor_apropia
 Descripcion:Trae el valor de la apropiacion para un rubro
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora

 Salidas : Valor  de la apropiacion para un rubro
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :
***********************************************************************************************/

FUNCTION fn_pre_traer_valor_apropia(una_vigencia               NUMBER,
                                    una_compania               VARCHAR2,
                                    una_unidad_ejecutora       VARCHAR2,
                                    un_rubro_interno           NUMBER
                                    ) RETURN NUMBER IS



mi_valor NUMBER;

BEGIN

  SELECT VALOR INTO mi_valor
  FROM PR_APROPIACION DF
  WHERE VIGENCIA=una_vigencia
  AND   CODIGO_COMPANIA=una_compania
  AND   CODIGO_UNIDAD_EJECUTORA=una_unidad_ejecutora
  AND   RUBRO_INTERNO=un_rubro_interno;

  RETURN mi_valor;

EXCEPTION
     WHEN NO_DATA_FOUND THEN
          RETURN 0;


END fn_pre_traer_valor_apropia;


/***********************************************************************************************
 Funcion: fn_pre_traer_valor_det_apro
 Descripcion:Trae el valor de la apropiacion vigente de una fuente de financiacion
             parte de requerimiento RQ160
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, rubro,fuente de financiacion
           detalle de la fuente, calsificacion
 Salidas : Valor apropiacion vigente de una fuente
 Fecha             Febrero de 2005
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones : RQ160: Se a?ade valor_cambio para CAMBIO_FUENTES
 Fecha          :
 Responsable    :
 Descripcion    :
 ***********************************************************************************************/


FUNCTION fn_pre_traer_valor_det_apro(una_vigencia           NUMBER,
                                una_compania               VARCHAR2,
                                una_unidad_ejecutora       VARCHAR2,
                                un_rubro_interno           NUMBER,
                                una_fuente                 VARCHAR2,
                                un_detalle_fuente          NUMBER,
                                una_clasificacion          VARCHAR2
                                ) RETURN NUMBER IS


mi_valor NUMBER;

BEGIN

  SELECT (NVL(DF.VALOR,0)
         -NVL(DF.VALOR_REZAGO,0)
         +NVL(df.VALOR_MODIFICACIONES,0)+ NVL(df.valor_cambio,0)) INTO mi_valor
 FROM PR_DETALLE_FUENTES_APROPIA DF
  WHERE DF.VIGENCIA=una_vigencia
  AND   DF.RUBRO_INTERNO=un_rubro_interno
  AND   DF.CODIGO_COMPANIA=una_compania
  AND   DF.CODIGO_UNIDAD_EJECUTORA=una_unidad_ejecutora
  AND   CODIGO_FUENTE=una_fuente
  AND   CODIGO_DET_FUENTE_FINANC=un_detalle_fuente
  AND   CLASIFICACION=una_clasificacion;

  RETURN NVL(mi_valor,0);

EXCEPTION
     WHEN NO_DATA_FOUND THEN
          RETURN 0;


END fn_pre_traer_valor_det_apro;


/***********************************************************************************************
 Funcion: fn_pre_traer_valor_cdp
 Descripcion:Trae el valor de detalle de disponibilidades de una fuente de financiacion
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, rubro,fuente de financiacion
           detalle de la fuente, calsificacion
 Salidas : suma de valor  detallado para la fuente de financiacion en los CDP's
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_traer_valor_cdp (una_vigencia               NUMBER,
                                 una_compania               VARCHAR2,
                                 una_unidad_ejecutora       VARCHAR2,
                                 un_rubro_interno           NUMBER,
                                 un_numero_disponibilidad   NUMBER,
                                 una_fuente                 VARCHAR2,
                                 un_detalle_fuente          NUMBER,
                                 una_clasificacion          VARCHAR2) RETURN NUMBER IS
mi_valor NUMBER;

BEGIN

  SELECT SUM(VALOR) INTO mi_valor
  FROM PR_DETALLE_FUENTES_CDP DF,
       PR_DISPONIBILIDADES DIS
  WHERE DF.VIGENCIA=DIS.VIGENCIA
  AND   DF.CODIGO_COMPANIA = DIS.CODIGO_COMPANIA
  AND   DF.CODIGO_UNIDAD_EJECUTORA=DIS.CODIGO_UNIDAD_EJECUTORA
  AND   DF.NUMERO_DISPONIBILIDAD=DIS.NUMERO_DISPONIBILIDAD
  AND   DIS.VIGENCIA=una_vigencia
  AND   DIS.CODIGO_COMPANIA=una_compania
  AND   DIS.CODIGO_UNIDAD_EJECUTORA=una_unidad_ejecutora
  AND   RUBRO_INTERNO=un_rubro_interno
  AND   CODIGO_FUENTE=una_fuente
  AND   CODIGO_DET_FUENTE_FINANC=un_detalle_fuente
  AND   CLASIFICACION=una_clasificacion
  AND   DIS.NUMERO_DISPONIBILIDAD=un_numero_disponibilidad;

  RETURN NVL(mi_valor,0);

EXCEPTION
     WHEN NO_DATA_FOUND THEN
          RETURN 0;

END fn_pre_traer_valor_cdp;

/***********************************************************************************************
 Funcion: fn_pre_traer_valor_acum_cdp  (disponibilidades)
 Descripcion:Trae la suma de valor de detalle de una fuente de financiacion en las sisponibilidades
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, rubro,fuente de financiacion
           detalle de la fuente, calsificacion
 Salidas : suma de valor  detallado para la fuente de financiacion en los CDP's
 Modificaciones :
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_traer_val_acum_cdp (una_vigencia             NUMBER,
                                    una_compania             VARCHAR2,
                                    una_unidad_ejecutora     VARCHAR2,
                                    un_rubro_interno         NUMBER,
                                    una_fuente               VARCHAR2,
                                    un_detalle_fuente        NUMBER,
                                    una_clasificacion        VARCHAR2) RETURN NUMBER IS

mi_valor NUMBER;

BEGIN

SELECT NVL(SUM(NVL(PR_DETALLE_FUENTES_CDP.VALOR,0)),0) INTO mi_valor
FROM PR_DISPONIBILIDAD_RUBRO,
     PR_DISPONIBILIDADES,
	 PR_DETALLE_FUENTES_CDP
WHERE (PR_DETALLE_FUENTES_CDP.vigencia=PR_DISPONIBILIDAD_RUBRO.vigencia
 AND  PR_DETALLE_FUENTES_CDP.rubro_interno=PR_DISPONIBILIDAD_RUBRO.rubro_interno
 AND  PR_DETALLE_FUENTES_CDP.codigo_compania=PR_DISPONIBILIDAD_RUBRO.codigo_compania
 AND  PR_DETALLE_FUENTES_CDP.codigo_unidad_ejecutora=PR_DISPONIBILIDAD_RUBRO.codigo_unidad_ejecutora
 AND  PR_DETALLE_FUENTES_CDP.numero_disponibilidad=PR_DISPONIBILIDAD_RUBRO.numero_disponibilidad)
 AND (PR_DISPONIBILIDAD_RUBRO.NUMERO_DISPONIBILIDAD=PR_DISPONIBILIDADES.NUMERO_DISPONIBILIDAD
 AND PR_DISPONIBILIDAD_RUBRO.CODIGO_UNIDAD_EJECUTORA=PR_DISPONIBILIDADES.CODIGO_UNIDAD_EJECUTORA
 AND PR_DISPONIBILIDAD_RUBRO.CODIGO_COMPANIA=PR_DISPONIBILIDADES.CODIGO_COMPANIA
 AND PR_DISPONIBILIDAD_RUBRO.VIGENCIA=PR_DISPONIBILIDADES.VIGENCIA
 AND PR_DISPONIBILIDAD_RUBRO.CODIGO_UNIDAD_EJECUTORA=una_unidad_ejecutora
 AND PR_DISPONIBILIDAD_RUBRO.CODIGO_COMPANIA=una_compania
 AND PR_DISPONIBILIDAD_RUBRO.VIGENCIA=una_vigencia
 AND PR_DISPONIBILIDAD_RUBRO.RUBRO_INTERNO=un_rubro_interno
 AND PR_DETALLE_FUENTES_CDP.codigo_fuente=una_fuente
 AND PR_DETALLE_FUENTES_CDP.codigo_det_fuente_financ=un_detalle_fuente);


  RETURN NVL(mi_valor,0);

EXCEPTION
     WHEN NO_DATA_FOUND THEN
          RETURN 0;
END fn_pre_traer_val_acum_cdp;


/***********************************************************************************************
 Funcion: fn_pre_traer_valor_rp
 Descripcion:Trae la suma de valor de detalle de una fuente de financiacion en los registros presupuestales
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, rubro,fuente de financiacion
           detalle de la fuente, calsificacion
 Salidas : suma de valor  detallado para la fuente de financiacion en los CDP's
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :
***********************************************************************************************/
FUNCTION fn_pre_traer_valor_rp (una_vigencia               NUMBER,
                                una_compania               VARCHAR2,
                                una_unidad_ejecutora       VARCHAR2,
                                un_rubro_interno           NUMBER,
                                un_numero_disponibilidad   NUMBER,
                                una_fuente                 VARCHAR2,
                                un_detalle_fuente          NUMBER,
                                una_clasificacion          VARCHAR2,
                                un_numero_registro         NUMBER) RETURN NUMBER IS
mi_valor NUMBER;

BEGIN

  SELECT VALOR INTO mi_valor
  FROM PR_DETALLE_FUENTES_RP
  WHERE  VIGENCIA=una_vigencia
  AND    CODIGO_COMPANIA = una_compania
  AND    CODIGO_UNIDAD_EJECUTORA=una_unidad_ejecutora
  AND    RUBRO_INTERNO = un_rubro_interno
  AND    NUMERO_DISPONIBILIDAD=un_numero_disponibilidad
  AND    CODIGO_FUENTE=una_fuente
  AND    CODIGO_DET_FUENTE_FINANC=un_detalle_fuente
  AND    CLASIFICACION=una_clasificacion
  AND    NUMERO_REGISTRO=un_numero_registro;

  RETURN mi_valor;

EXCEPTION
     WHEN NO_DATA_FOUND THEN
          RETURN 0;


END fn_pre_traer_valor_rp;


/***********************************************************************************************
 Funcion: fn_pre_traer_valor_rp
 Descripcion:trae el valor detalllado del op
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, rubro,fuente de financiacion
           detalle de la fuente, calsificacion
 Salidas : suma de valor  detallado para la fuente de financiacion en los CDP's
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/



FUNCTION fn_pre_traer_valor_op (una_vigencia               NUMBER,
                                una_compania               VARCHAR2,
                                una_unidad_ejecutora       VARCHAR2,
                                un_rubro_interno           NUMBER,
                                un_numero_disponibilidad   NUMBER,
                                una_fuente                 VARCHAR2,
                                un_detalle_fuente          NUMBER,
                                una_clasificacion          VARCHAR2,
                                un_numero_registro         NUMBER,
                                un_numero_orden            NUMBER,
                                un_consecutivo_orden       NUMBER
                                  ) RETURN NUMBER IS
mi_valor NUMBER;

BEGIN

SELECT VALOR INTO mi_valor
  FROM PR_DETALLE_FUENTES_OP DFOP,
       PR_ORDEN_DE_PAGO OP
  WHERE DFOP.VIGENCIA=OP.VIGENCIA
  AND  DFOP.CODIGO_COMPANIA =OP.CODIGO_COMPANIA
  AND  DFOP.CODIGO_UNIDAD_EJECUTORA=OP.CODIGO_UNIDAD_EJECUTORA
  AND  DFOP.NUMERO_ORDEN = OP.NUMERO_ORDEN
  AND  OP.ESTADO <> 'ANULADO'
  AND  DFOP.VIGENCIA=una_vigencia
  AND  DFOP.CODIGO_COMPANIA = una_compania
  AND  DFOP.CODIGO_UNIDAD_EJECUTORA=una_unidad_ejecutora
  AND  DFOP.RUBRO_INTERNO = un_rubro_interno
  AND  DFOP.NUMERO_DISPONIBILIDAD=un_numero_disponibilidad
  AND  DFOP.CODIGO_FUENTE=una_fuente
  AND  DFOP.CODIGO_DET_FUENTE_FINANC=un_detalle_fuente
  AND  DFOP.CLASIFICACION=una_clasificacion
  AND  DFOP.NUMERO_REGISTRO=un_numero_registro
  AND  DFOP.NUMERO_ORDEN= un_numero_orden
  AND  DFOP.CONSECUTIVO_ORDEN=un_consecutivo_orden;

  RETURN NVL(mi_valor,0);

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
          RETURN 0;


END fn_pre_traer_valor_op;


/***********************************************************************************************
 Funcion: ffn_pre_traer_valor_pagado
 Descripcion:Trae la suma de valor de ordenes de pago de detalle de una fuente de financiacion
 acumulada por numero disponibilidad, rubro y un registro_presupuestal
 Salidas : suma de valor  detallado para la fuente de financiacion en los OP's
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_traer_valor_pagado (una_vigencia               NUMBER,
                                    una_compania               VARCHAR2,
                                    una_unidad_ejecutora       VARCHAR2,
                                    un_rubro_interno           NUMBER,
                                    un_numero_disponibilidad   NUMBER,
                                    una_fuente                 VARCHAR2,
                                    un_detalle_fuente          NUMBER,
                                    un_numero_registro         NUMBER
                                     ) RETURN NUMBER IS
mi_valor NUMBER;

BEGIN

SELECT SUM(VALOR) INTO mi_valor
  FROM PR_DETALLE_FUENTES_OP DFOP,
       PR_ORDEN_DE_PAGO OP
  WHERE DFOP.VIGENCIA=OP.VIGENCIA
  AND  DFOP.CODIGO_COMPANIA =OP.CODIGO_COMPANIA
  AND  DFOP.CODIGO_UNIDAD_EJECUTORA=OP.CODIGO_UNIDAD_EJECUTORA
  AND  DFOP.NUMERO_REGISTRO = OP.NUMERO_REGISTRO
  AND  DFOP.NUMERO_ORDEN = OP.NUMERO_ORDEN
  AND  DFOP.CONSECUTIVO_ORDEN= OP.CONSECUTIVO_ORDEN
  AND  DFOP.CONSECUTIVO_ORDEN IS NOT NULL
  AND  OP.ESTADO <> 'ANULADO'
  AND  DFOP.VIGENCIA=una_vigencia
  AND  DFOP.CODIGO_COMPANIA = una_compania
  AND  DFOP.CODIGO_UNIDAD_EJECUTORA=una_unidad_ejecutora
  AND  DFOP.NUMERO_REGISTRO=un_numero_registro
  AND  DFOP.NUMERO_DISPONIBILIDAD=un_numero_disponibilidad
  AND  DFOP.RUBRO_INTERNO = un_rubro_interno
  AND  DFOP.CODIGO_FUENTE=una_fuente
  AND  DFOP.CODIGO_DET_FUENTE_FINANC=un_detalle_fuente;


  RETURN NVL(mi_valor,0);

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
          RETURN 0;


END fn_pre_traer_valor_pagado;



/***********************************************************************************************
 Funcion: fn_pre_saldo_op_reservas
 Descripcion:Trae el saldo de ordenes de pago de  reservas  (valor disponible en anulaciones
             parciales de reservas.
 acumulada por numero disponibilidad, rubro y un registro_presupuestal
 Salidas : suma de valor  detallado para la fuente de financiacion en los OP's
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :
***********************************************************************************************/

FUNCTION fn_pre_saldo_op_reservas  (una_vigencia               NUMBER,
                                    una_compania               VARCHAR2,
                                    una_unidad_ejecutora       VARCHAR2,
                                    un_rubro_interno           NUMBER,
                                    una_fuente                 VARCHAR2,
                                    un_detalle_fuente          NUMBER,
                                    un_numero_registro         NUMBER
                                     ) RETURN NUMBER IS
mi_valor NUMBER;

BEGIN

SELECT SUM(VALOR) INTO mi_valor
  FROM PR_DETALLE_FUENTES_OP DFOP,
       PR_ORDEN_DE_PAGO OP
  WHERE DFOP.VIGENCIA=OP.VIGENCIA
  AND  DFOP.CODIGO_COMPANIA =OP.CODIGO_COMPANIA
  AND  DFOP.CODIGO_UNIDAD_EJECUTORA=OP.CODIGO_UNIDAD_EJECUTORA
  AND  DFOP.NUMERO_ORDEN = OP.NUMERO_ORDEN
  AND  DFOP.CONSECUTIVO_ORDEN= OP.CONSECUTIVO_ORDEN
  AND  OP.ESTADO <> 'ANULADO'
  AND  DFOP.VIGENCIA=una_vigencia
  AND  DFOP.CODIGO_COMPANIA = una_compania
  AND  DFOP.CODIGO_UNIDAD_EJECUTORA=una_unidad_ejecutora
  AND  DFOP.NUMERO_REGISTRO=un_numero_registro
  AND  DFOP.RUBRO_INTERNO = un_rubro_interno
  AND  DFOP.CODIGO_FUENTE=una_fuente
  AND  DFOP.CODIGO_DET_FUENTE_FINANC=un_detalle_fuente;


  RETURN NVL(mi_valor,0);

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
          RETURN 0;


END fn_pre_saldo_op_reservas;


/***********************************************************************************************
 Funcion: fn_pre_traer_valor_detalle de los registros presupuestales
 Descripcion:Trae la suma de detalles de un rubro para una determinada fuente
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, rubro, Numero disponibilidad, fuente de financiacion
 Salidas : suma de valores de lo detalladao en los registros presupuestales.
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_traer_valor_detalle (una_vigencia           NUMBER,
                                 una_compania               VARCHAR2,
                                 una_unidad_ejecutora       VARCHAR2,
                                 un_rubro_interno          NUMBER,
                                 un_numero_disponibilidad  NUMBER,
                                 un_fuente                 VARCHAR2,
                                 un_detalle_fuente         NUMBER,
                                 una_clasificacion          VARCHAR2) RETURN NUMBER IS
mi_valor_detalle NUMBER;

BEGIN

  SELECT SUM(VALOR) INTO mi_valor_detalle
  FROM PR_DETALLE_FUENTES_RP DF,
       PR_REGISTRO_PRESUPUESTAL RP
  WHERE DF.VIGENCIA = RP.VIGENCIA
  AND   DF.CODIGO_COMPANIA= RP.CODIGO_COMPANIA
  AND   DF.CODIGO_UNIDAD_EJECUTORA=RP.CODIGO_UNIDAD_EJECUTORA
  AND   DF.NUMERO_REGISTRO = RP.NUMERO_REGISTRO
  AND   DF.NUMERO_DISPONIBILIDAD = RP.NUMERO_DISPONIBILIDAD
  AND   RP.ESTADO<>'ANULADO'
  AND   RP.VIGENCIA=una_vigencia
  AND   RP.CODIGO_COMPANIA=una_compania
  AND   RP.CODIGO_UNIDAD_EJECUTORA=una_unidad_ejecutora
  AND   RUBRO_INTERNO=un_rubro_interno
  AND   RP.NUMERO_DISPONIBILIDAD=un_numero_disponibilidad
  AND   CODIGO_FUENTE=un_fuente
  AND   CODIGO_DET_FUENTE_FINANC=un_detalle_fuente
  AND   CLASIFICACION=una_clasificacion
  GROUP BY DF.VIGENCIA, DF.CODIGO_COMPANIA, DF.CODIGO_UNIDAD_EJECUTORA, DF.RUBRO_INTERNO,
          DF.NUMERO_DISPONIBILIDAD, DF.CODIGO_FUENTE, DF.CODIGO_DET_FUENTE_FINANC;


  RETURN NVL(mi_valor_detalle,0);

EXCEPTION
     WHEN NO_DATA_FOUND THEN
          RETURN 0;


END fn_pre_traer_valor_detalle;


/***********************************************************************************************
 Funcion: fn_pre_traer_valor_deta_anul
 Descripcion:Trae la suma de detalles de un rubro para una determinada fuente
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, rubro, Numero disponibilidad, fuente de financiacion
 Salidas : suma de valores de lo detalladao en los registros presupuestales.
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_traer_valor_deta_anul (una_vigencia             NUMBER,
                                       una_compania             VARCHAR2,
                                       una_unidad_ejecutora     VARCHAR2,
                                       un_rubro                 NUMBER,
                                       una_fuente               VARCHAR2,
                                       un_detalle_fuente        NUMBER
                                      ) RETURN NUMBER IS
mi_valor_detalle NUMBER;

BEGIN

SELECT  SUM(VALOR_ANULADO) INTO mi_valor_detalle
  FROM  PR_CDP_ANULA_AUTORIZA_DETALLE
  WHERE VIGENCIA=una_vigencia
  AND   CODIGO_COMPANIA=una_compania
  AND   CODIGO_UNIDAD_EJECUTORA=una_unidad_ejecutora
  AND   RUBRO_INTERNO=un_rubro
  AND   CODIGO_FUENTE=una_fuente
  AND   CODIGO_DET_FUENTE_FINANC=un_detalle_fuente;




  RETURN NVL(mi_valor_detalle,0);

EXCEPTION
     WHEN NO_DATA_FOUND THEN
          RETURN 0;
END fn_pre_traer_valor_deta_anul;


/***********************************************************************************************
 Funcion: ffn_pre_traer_val_anul_rp
 Descripcion:Trae la suma de detalles de un rubro para una determinada fuente
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, rubro, Numero disponibilidad, fuente de financiacion
 Salidas : suma de valores de lo detalladao en los registros presupuestales.
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_traer_val_anul_rp (una_vigencia             NUMBER,
                                   una_compania             VARCHAR2,
                                   una_unidad_ejecutora     VARCHAR2,
                                   una_disponibilidad       NUMBER,
                                   un_rubro                 NUMBER,
                                   una_fuente               VARCHAR2,
                                   un_detalle_fuente        NUMBER
                                   ) RETURN NUMBER IS
mi_valor_detalle NUMBER;

BEGIN

SELECT  SUM(VALOR_ANULADO) INTO mi_valor_detalle
  FROM  PR_CDP_ANULA_AUTORIZA_DETALLE
  WHERE VIGENCIA=una_vigencia
  AND   CODIGO_COMPANIA=una_compania
  AND   CODIGO_UNIDAD_EJECUTORA=una_unidad_ejecutora
  AND   NUMERO_DISPONIBILIDAD=una_disponibilidad
  AND   RUBRO_INTERNO= un_rubro
  AND   CODIGO_FUENTE=una_fuente
  AND   CODIGO_DET_FUENTE_FINANC=un_detalle_fuente;

  RETURN NVL(mi_valor_detalle,0);

EXCEPTION
     WHEN NO_DATA_FOUND THEN
          RETURN 0;
END fn_pre_traer_val_anul_rp;


/***********************************************************************************************
 Funcion: fn_pre_traer_val_anulTot
 Descripcion:Trae la suma de detalles de fuentes de financiacion registradas en anulaciones totales
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, rubro, Numero disponibilidad, fuente de financiacion
 Salidas : suma de valores de lo detalladao en los anulaciones totales
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o
 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

 ***********************************************************************************************/

FUNCTION fn_pre_traer_val_anulTot (una_vigencia              NUMBER,
                                   una_compania              VARCHAR2,
                                   una_unidad_ejecutora      VARCHAR2,
                                   un_rubro                  NUMBER,
                                   un_doc_anulado            VARCHAR2,
                                   una_fuente                VARCHAR2,
                                   un_detalle_fuente         NUMBER
                                 ) RETURN NUMBER IS
mi_valor_detalle NUMBER;

BEGIN



SELECT SUM(a.VALOR) INTO mi_valor_detalle
  FROM PR_DETALLE_FUENTES_CDP a,
       PR_DISPONIBILIDAD_RUBRO b
  WHERE a.vigencia=b.vigencia
  AND a.codigo_compania=b.codigo_compania
  AND a.codigo_unidad_Ejecutora=b.codigo_unidad_ejecutora
  AND a.numero_disponibilidad=b.numero_disponibilidad
  AND a.vigencia=una_vigencia
  AND a.codigo_compania=una_compania
  AND a.codigo_unidad_ejecutora = una_unidad_ejecutora
  AND a.rubro_interno=un_rubro
  AND a.codigo_fuente=una_fuente
  AND a.codigo_det_fuente_financ=un_detalle_fuente
  AND EXISTS (SELECT numero_documento,codigo_fuente,codigo_det_fuente_financ
              FROM   PR_ANULACION_TOTAL_DETA_FTES c
			  WHERE  a.vigencia=c.vigencia
			  AND    a.codigo_compania=c.codigo_compania
			  AND    a.codigo_unidad_ejecutora=c.codigo_unidad_ejecutora
			  AND    a.codigo_fuente=c.codigo_fuente
			  AND    a.codigo_det_fuente_financ=c.codigo_det_fuente_financ
			  AND    a.numero_disponibilidad=c.numero_documento
			  AND    a.rubro_interno=c.rubro_interno
			  AND    c.documento_anulado=un_doc_anulado);


 RETURN NVL(mi_valor_detalle,0);

EXCEPTION
     WHEN NO_DATA_FOUND THEN
          RETURN 0;


END fn_pre_traer_val_anulTot;


/***********************************************************************************************
 Funcion: fn_pre_traer_valor_detalle de anulaciones parciales de CDP's (Disponibilidades)
 Descripcion:Trae la suma de detalles de un rubro para una determinada fuente
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, rubro, Numero disponibilidad, fuente de financiacion
 Salidas : suma de valores de lo detalladado en los registros presupuestales.
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_traer_valor_anulado (una_vigencia               NUMBER,
                                     una_compania               VARCHAR2,
                                     una_unidad_ejecutora       VARCHAR2,
                                     un_rubro                   NUMBER,
                                     una_fuente                 VARCHAR2,
                                     un_detalle_fuente          NUMBER
                                     ) RETURN NUMBER IS
mi_valor_detalle NUMBER;

BEGIN

  SELECT SUM(VALOR_ANULADO) INTO mi_valor_detalle
  FROM  PR_ANULA_DETALLE_CDP
  WHERE VIGENCIA=una_vigencia
  AND   CODIGO_COMPANIA=una_compania
  AND   CODIGO_UNIDAD_EJECUTORA=una_unidad_ejecutora
  AND   RUBRO_INTERNO=un_rubro
  AND   CODIGO_FUENTE = una_fuente
  AND   CODIGO_DET_FUENTE_FINANC = un_detalle_fuente;

  RETURN NVL(mi_valor_detalle,0);

EXCEPTION
     WHEN NO_DATA_FOUND THEN
          RETURN 0;

END fn_pre_traer_valor_anulado;


/***********************************************************************************************
 Funcion: fn_pre_traer_valor_anul_compro
 Descripcion:Trae la suma de detalles de un rubro para una determinada fuente
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, rubro, Numero disponibilidad, fuente de financiacion
 Salidas : suma de valores de lo detalladado en los registros presupuestales.
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_traer_valor_anul_compro (una_vigencia               NUMBER,
                                         una_compania               VARCHAR2,
                                         una_unidad_ejecutora       VARCHAR2,
                                         un_rubro                   NUMBER,
                                         una_fuente                 VARCHAR2,
                                         un_detalle_fuente          NUMBER,
                                         una_disponibilidad         NUMBER
                                         ) RETURN NUMBER IS
mi_valor_detalle NUMBER;

BEGIN

  SELECT SUM(VALOR_ANULADO) INTO mi_valor_detalle
  FROM  PR_ANULA_DETALLE_CDP
  WHERE VIGENCIA=una_vigencia
  AND   CODIGO_COMPANIA=una_compania
  AND   CODIGO_UNIDAD_EJECUTORA=una_unidad_ejecutora
  AND   RUBRO_INTERNO=un_rubro
  AND   numero_disponibilidad=una_disponibilidad
  AND   CODIGO_FUENTE = una_fuente
  AND   CODIGO_DET_FUENTE_FINANC = un_detalle_fuente;

  RETURN NVL(mi_valor_detalle,0);

EXCEPTION
     WHEN NO_DATA_FOUND THEN
          RETURN 0;

END fn_pre_traer_valor_anul_compro;


/***********************************************************************************************
 Funcion: fn_pre_saldo_rp
 Descripcion:Trae la suma de valores detallados en registros presupuestales (usado para vlor disponible en CDP's )
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, rubro, Numero disponibilidad, fuente de financiacion
 Salidas : suma de valores de lo detalladado en los registros presupuestales.
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_saldo_rp (una_vigencia               NUMBER,
                          una_compania               VARCHAR2,
                          una_unidad_ejecutora       VARCHAR2,
                          un_rubro_interno           NUMBER,
                          un_numero_disponibilidad   NUMBER,
                          una_fuente                 VARCHAR2,
                          un_detalle_fuente          NUMBER
                          ) RETURN NUMBER IS
mi_valor_detalle NUMBER;

BEGIN

SELECT NVL(SUM(NVL(dfrp.valor,0)),0) INTO mi_valor_detalle
FROM  PR_REGISTRO_DISPONIBILIDAD rd,
      PR_DETALLE_FUENTES_RP dfrp
WHERE  rd.vigencia=dfrp.vigencia
AND    rd.codigo_compania=dfrp.codigo_compania
AND    rd.codigo_unidad_ejecutora=dfrp.codigo_unidad_ejecutora
AND    rd.rubro_interno = dfrp.rubro_interno  --0jo
AND    rd.numero_registro=dfrp.numero_registro
AND    rd.numero_disponibilidad=dfrp.numero_disponibilidad
AND    rd.vigencia = una_vigencia
AND    rd.codigo_compania = una_compania
AND    rd.codigo_unidad_ejecutora = una_unidad_ejecutora
AND    rd.numero_disponibilidad = un_numero_disponibilidad
AND    rd.rubro_interno = un_rubro_interno
AND    dfrp.CODIGO_FUENTE=una_fuente
AND    dfrp.CODIGO_DET_FUENTE_FINANC=un_detalle_fuente
AND    dfrp.numero_registro NOT IN (SELECT numero_documento
                                                         FROM PR_ANULACION_TOTAL_DETA_FTES anu
                                                         WHERE anu.vigencia = una_vigencia
                                                         AND   anu.codigo_unidad_ejecutora = una_unidad_ejecutora
                                                         AND   anu.codigo_compania = una_compania
                                                         AND   anu.CODIGO_FUENTE=una_fuente
                                                         AND   anu.CODIGO_DET_FUENTE_FINANC=un_detalle_fuente
                                                         AND   anu.documento_anulado = 'REGISTRO'
														 AND   anu.numero_disponibilidad=un_numero_disponibilidad);


RETURN NVL(mi_valor_detalle,0);

EXCEPTION
     WHEN NO_DATA_FOUND THEN
          RETURN 0;

END fn_pre_saldo_rp;


/***********************************************************************************************
 Funcion: fn_pre_traer_valor_rp_anulado
 Descripcion:Trae la suma de detalles de un rubro para una determinada fuente  de rp's anulados detallados
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, rubro, Numero disponibilidad, fuente de financiacion
 Salidas : suma de valores de lo detalladao en los registros presupuestales.
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_traer_valor_rp_anulado (una_vigencia               NUMBER,
                                        una_compania               VARCHAR2,
                                        una_unidad_ejecutora       VARCHAR2,
                                        un_rubro_interno           NUMBER,
                                        un_numero_disponibilidad   NUMBER,
                                        un_numero_registro         NUMBER,
                                        una_fuente                 VARCHAR2,
                                        un_detalle_fuente          NUMBER,
                                        una_clasificacion          VARCHAR2
                                       ) RETURN NUMBER IS
mi_valor_detalle NUMBER;

BEGIN

  SELECT SUM(VALOR_ANULADO) INTO mi_valor_detalle
  FROM PR_RP_ANULADOS_DETALLE
  WHERE VIGENCIA=una_vigencia
  AND   CODIGO_COMPANIA=una_compania
  AND   CODIGO_UNIDAD_EJECUTORA=una_unidad_ejecutora
  AND   NUMERO_REGISTRO=un_numero_registro
  AND   NUMERO_DISPONIBILIDAD=un_numero_disponibilidad
  AND   RUBRO_INTERNO=un_rubro_interno
  AND   CODIGO_FUENTE = una_fuente
  AND   CODIGO_DET_FUENTE_FINANC = un_detalle_fuente
  GROUP BY VIGENCIA,
           CODIGO_COMPANIA,
           CODIGO_UNIDAD_EJECUTORA,
           NUMERO_REGISTRO,
           NUMERO_DISPONIBILIDAD,
           RUBRO_INTERNO,
           CODIGO_FUENTE,
           CODIGO_DET_FUENTE_FINANC;

  RETURN NVL(mi_valor_detalle,0);

EXCEPTION
     WHEN NO_DATA_FOUND THEN
          RETURN 0;

END fn_pre_traer_valor_rp_anulado;


/***********************************************************************************************
 Funcion: fn_pre_valRp_anul_compro
 Descripcion:Trae la suma de detalles de un rubro para una determinada fuente  de rp's anulados detallados
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, rubro, Numero disponibilidad, fuente de financiacion
 Salidas : suma de valores de lo detalladao en los registros presupuestales.
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_valRp_anul_compro (una_vigencia               NUMBER,
                                   una_compania               VARCHAR2,
                                   una_unidad_ejecutora       VARCHAR2,
                                   un_rubro_interno           NUMBER,
                                   un_numero_disponibilidad   NUMBER,
                                   una_fuente                 VARCHAR2,
                                   un_detalle_fuente          NUMBER
                                   ) RETURN NUMBER IS
mi_valor_detalle NUMBER;

BEGIN

  SELECT SUM(VALOR_ANULADO) INTO mi_valor_detalle
  FROM PR_RP_ANULADOS_DETALLE
  WHERE VIGENCIA=una_vigencia
  AND   CODIGO_COMPANIA=una_compania
  AND   CODIGO_UNIDAD_EJECUTORA=una_unidad_ejecutora
  AND   NUMERO_DISPONIBILIDAD=un_numero_disponibilidad
  AND   RUBRO_INTERNO=un_rubro_interno
  AND   CODIGO_FUENTE = una_fuente
  AND   CODIGO_DET_FUENTE_FINANC = un_detalle_fuente;

  RETURN NVL(mi_valor_detalle,0);

EXCEPTION
     WHEN NO_DATA_FOUND THEN
          RETURN 0;

END fn_pre_valRp_anul_compro;


/***********************************************************************************************
 Funcion: fn_pre_valRp_anul_cdp
 Descripcion:Trae la suma de detalles de un rubro para una determinada fuente  de rp's anulados detallados
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, rubro, Numero disponibilidad, fuente de financiacion
 Salidas : suma de valores de lo detalladao en los registros presupuestales.
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_valRp_anul_cdp    (una_vigencia               NUMBER,
                                   una_compania               VARCHAR2,
                                   una_unidad_ejecutora       VARCHAR2,
                                   un_numero_disponibilidad   NUMBER,
                                   una_fuente                 VARCHAR2,
                                   un_detalle_fuente          NUMBER,
                                   una_clasificacion          VARCHAR2
                                   ) RETURN NUMBER IS
mi_valor_detalle NUMBER;

BEGIN

  SELECT SUM(VALOR_ANULADO) INTO mi_valor_detalle
  FROM PR_RP_ANULADOS_DETALLE
  WHERE VIGENCIA=una_vigencia
  AND   CODIGO_COMPANIA=una_compania
  AND   CODIGO_UNIDAD_EJECUTORA=una_unidad_ejecutora
  AND   NUMERO_DISPONIBILIDAD=un_numero_disponibilidad
  AND   CODIGO_FUENTE = una_fuente
  AND   CODIGO_DET_FUENTE_FINANC = un_detalle_fuente;

  RETURN NVL(mi_valor_detalle,0);

EXCEPTION
     WHEN NO_DATA_FOUND THEN
          RETURN 0;

END fn_pre_valRp_anul_cdp;

/***********************************************************************************************
 Funcion: fn_pre_traer_valor_rp_anul_res
 Descripcion:Trae la suma de detalles de un rubro para una determinada fuente  de rp's anulados detallados
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, rubro, Numero disponibilidad, fuente de financiacion
 Salidas : suma de valores de lo detalladao en los registros presupuestales.
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_traer_valor_rp_anul_res (una_vigencia               NUMBER,
                                         una_compania               VARCHAR2,
                                         una_unidad_ejecutora       VARCHAR2,
                                         un_rubro_interno           NUMBER,
                                         un_numero_registro         NUMBER,
                                         una_fuente                 VARCHAR2,
                                         un_detalle_fuente          NUMBER
                                         ) RETURN NUMBER IS
mi_anulado NUMBER;

BEGIN

  SELECT SUM(VALOR_ANULADO) INTO mi_anulado
  FROM PR_RP_ANULADOS_DETALLE
  WHERE VIGENCIA=una_vigencia
  AND   CODIGO_COMPANIA=una_compania
  AND   CODIGO_UNIDAD_EJECUTORA=una_unidad_ejecutora
  AND   NUMERO_REGISTRO=un_numero_registro
  AND   RUBRO_INTERNO=un_rubro_interno
  AND   CODIGO_FUENTE = una_fuente
  AND   CODIGO_DET_FUENTE_FINANC = un_detalle_fuente;

  RETURN NVL(mi_anulado,0);

EXCEPTION
     WHEN NO_DATA_FOUND THEN
          RETURN 0;

END fn_pre_traer_valor_rp_anul_res;


/***********************************************************************************************
 Funcion: fn_pre_trae_valModif_cdp (disponibilidades)
 Descripcion:Trae la suma de detalles de un rubro de modificaciones presupuestales, para una determinada fuente
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, rubro, Numero disponibilidad, fuente de financiacion
 Salidas : suma de valores de lo detalladao en modificaciones presupuestales.
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_trae_valModif_cdp (una_vigencia               NUMBER,
                                   una_compania               VARCHAR2,
                                   una_unidad_ejecutora       VARCHAR2,
                                   un_tipo_documento          VARCHAR2,
                                   un_rubro_interno           NUMBER,
                                   un_tipo_movimiento         VARCHAR2,
                                   un_numero_disponibilidad   NUMBER,
                                   una_fuente                 VARCHAR2,
                                   un_detalle_fuente          NUMBER,
                                   un_documentos_numero       NUMBER
                                   ) RETURN NUMBER IS
mi_valor_modifica  NUMBER;

BEGIN

IF un_tipo_movimiento='ADICION' THEN
  SELECT SUM(VALOR_CREDITO) INTO mi_valor_modifica
   FROM PR_DETALLE_FUENTES_MODIF
   WHERE VIGENCIA=una_vigencia
   AND   CODIGO_COMPANIA=una_compania
   AND   CODIGO_UNIDAD_EJECUTORA=una_unidad_ejecutora
   AND   NUMERO_DISPONIBILIDAD=un_numero_disponibilidad
   AND   CODIGO_FUENTE = una_fuente
   AND   CODIGO_DET_FUENTE_FINANC = un_detalle_fuente
   AND   TIPO_MOVIMIENTO=un_tipo_movimiento;
--   AND   RUBRO_INTERNO=un_rubro_interno
ELSE  --es REDUCCION o REDUCCION_SUSPENSION

   SELECT SUM(VALOR_CONTRACREDITO) INTO mi_valor_modifica
   FROM PR_DETALLE_FUENTES_MODIF
   WHERE VIGENCIA=una_vigencia
   AND   CODIGO_COMPANIA=una_compania
   AND   CODIGO_UNIDAD_EJECUTORA=una_unidad_ejecutora
   AND   NUMERO_DISPONIBILIDAD=un_numero_disponibilidad
   AND   CODIGO_FUENTE = una_fuente
   AND   CODIGO_DET_FUENTE_FINANC = un_detalle_fuente
   AND   TIPO_MOVIMIENTO=un_tipo_movimiento
   AND   DOCUMENTOS_NUMERO!=un_documentos_numero;
--   AND   RUBRO_INTERNO=un_rubro_interno
END IF;

RETURN NVL(mi_valor_modifica,0);
EXCEPTION
   WHEN NO_DATA_FOUND THEN
        RETURN 0;


END fn_pre_trae_valModif_cdp;


/***********************************************************************************************
 Funcion: fn_pre_trae_AjusReint_cdp
 Descripcion:Trae la suma de detalles de reintegros ajustes, para una determinada fuente PARA UN RUBRO
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, rubro, Numero disponibilidad, fuente de financiacion
 Salidas : suma de valores de lo detalladao en modificaciones presupuestales.
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_trae_AjusReint_cdp (una_vigencia              NUMBER,
                                   una_compania               VARCHAR2,
                                   una_unidad_ejecutora       VARCHAR2,
                                   un_rubro                   NUMBER,
                                   una_fuente                 VARCHAR2,
                                   un_detalle_fuente          NUMBER
                                   ) RETURN NUMBER IS
mi_valor_modifica  NUMBER;

BEGIN

SELECT NVL(SUM(NVL(PR_DETALLE_FUENTES_AJUSTES.valor,0)),0)  INTO mi_valor_modifica
FROM PR_REINTEGRO_AJUSTES, PR_DETALLE_FUENTES_AJUSTES
WHERE (PR_DETALLE_FUENTES_AJUSTES.vigencia=PR_REINTEGRO_AJUSTES.vigencia
AND    PR_DETALLE_FUENTES_AJUSTES.codigo_compania=PR_REINTEGRO_AJUSTES.codigo_compania
AND    PR_DETALLE_FUENTES_AJUSTES.codigo_unidad_ejecutora=PR_REINTEGRO_AJUSTES.codigo_unidad_ejecutora
AND    PR_DETALLE_FUENTES_AJUSTES.numero_orden=PR_REINTEGRO_AJUSTES.numero_orden
AND    PR_DETALLE_FUENTES_AJUSTES.consecutivo_orden=PR_REINTEGRO_AJUSTES.consecutivo_orden
AND    PR_DETALLE_FUENTES_AJUSTES.numero_disponibilidad=PR_REINTEGRO_AJUSTES.numero_disponibilidad
AND    PR_DETALLE_FUENTES_AJUSTES.numero_registro=PR_REINTEGRO_AJUSTES.numero_registro
AND    PR_DETALLE_FUENTES_AJUSTES.consecutivo_ajuste=PR_REINTEGRO_AJUSTES.consecutivo_ajuste)
AND    PR_REINTEGRO_AJUSTES.vigencia = una_vigencia
AND    PR_REINTEGRO_AJUSTES.codigo_compania = una_compania
AND    PR_REINTEGRO_AJUSTES.codigo_unidad_ejecutora = una_unidad_ejecutora
AND    PR_DETALLE_FUENTES_AJUSTES.RUBRO_INTERNO=un_rubro
AND    PR_REINTEGRO_AJUSTES.tipo_movimiento = 'AJUSTE'
AND    PR_DETALLE_FUENTES_AJUSTES.CODIGO_FUENTE=una_fuente
AND    PR_DETALLE_FUENTES_AJUSTES.CODIGO_DET_FUENTE_FINANC=un_detalle_fuente;

RETURN NVL(mi_valor_modifica,0);
EXCEPTION
   WHEN NO_DATA_FOUND THEN
        RETURN 0;


END fn_pre_trae_AjusReint_cdp;


/***********************************************************************************************
 Funcion: ffn_pre_trae_Ajustes_cdp (disponibilidades)
 Descripcion:Trae la suma de detalles de un rubro de ajustes, para una determinada fuente
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, rubro, Numero disponibilidad, fuente de financiacion
 Salidas : suma de valores de lo detalladao en modificaciones presupuestales.
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_trae_Ajustes_cdp  (una_vigencia               NUMBER,
                                   una_compania               VARCHAR2,
                                   una_unidad_ejecutora       VARCHAR2,
                                   un_tipo_documento          VARCHAR2,
                                   un_tipo_movimiento         VARCHAR2,
                                   un_rubro                   NUMBER,
                                   una_fuente                 VARCHAR2,
                                   un_detalle_fuente          NUMBER,
                                   un_documentos_numero       NUMBER
                                   ) RETURN NUMBER IS
mi_valor_modifica  NUMBER;

BEGIN

SELECT NVL(SUM(NVL(PR_DETALLE_FUENTES_AJUSTES.valor,0)),0)  INTO mi_valor_modifica
FROM PR_REINTEGRO_AJUSTES, PR_DETALLE_FUENTES_AJUSTES
WHERE (PR_REINTEGRO_AJUSTES.vigencia=PR_DETALLE_FUENTES_AJUSTES.vigencia
AND    PR_REINTEGRO_AJUSTES.codigo_compania=PR_DETALLE_FUENTES_AJUSTES.codigo_compania
AND    PR_REINTEGRO_AJUSTES.codigo_unidad_ejecutora=PR_DETALLE_FUENTES_AJUSTES.codigo_unidad_ejecutora
AND    PR_REINTEGRO_AJUSTES.numero_orden=PR_DETALLE_FUENTES_AJUSTES.numero_orden
AND    PR_REINTEGRO_AJUSTES.consecutivo_orden=PR_DETALLE_FUENTES_AJUSTES.consecutivo_orden
AND    PR_REINTEGRO_AJUSTES.numero_disponibilidad=PR_DETALLE_FUENTES_AJUSTES.numero_disponibilidad
AND    PR_REINTEGRO_AJUSTES.numero_registro=PR_DETALLE_FUENTES_AJUSTES.numero_registro
AND    PR_REINTEGRO_AJUSTES.consecutivo_ajuste=PR_DETALLE_FUENTES_AJUSTES.consecutivo_ajuste)
AND    PR_REINTEGRO_AJUSTES.vigencia = una_vigencia
AND    PR_REINTEGRO_AJUSTES.codigo_compania = una_compania
AND    PR_REINTEGRO_AJUSTES.codigo_unidad_ejecutora = una_unidad_ejecutora
AND    PR_DETALLE_FUENTES_AJUSTES.RUBRO_INTERNO=un_rubro
AND    PR_REINTEGRO_AJUSTES.tipo_movimiento = 'AJUSTE'
AND    PR_DETALLE_FUENTES_AJUSTES.CODIGO_FUENTE=una_fuente
AND    PR_DETALLE_FUENTES_AJUSTES.CODIGO_DET_FUENTE_FINANC=un_detalle_fuente;

--AND    pr_reintegro_ajustes.cerrado <> '0'

RETURN NVL(mi_valor_modifica,0);
EXCEPTION
   WHEN NO_DATA_FOUND THEN
        RETURN 0;


END fn_pre_trae_Ajustes_cdp;


/***********************************************************************************************
 Funcion: fn_pre_trae_AjusReint_Rp (compromisos)
 Descripcion:Trae la suma de detalles de un rubro de modificaciones presupuestales, para una determinada fuente
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, rubro, Numero disponibilidad, fuente de financiacion
 Salidas : suma de valores de lo detalladao en modificaciones presupuestales.
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_trae_AjusReint_Rp (una_vigencia               NUMBER,
                                   una_compania               VARCHAR2,
                                   una_unidad_ejecutora       VARCHAR2,
                                   un_rubro                   NUMBER,
                                   una_fuente                 VARCHAR2,
                                   un_detalle_fuente          NUMBER,
                                   un_documentos_numero       NUMBER
                                   ) RETURN NUMBER IS
mi_valor_modifica  NUMBER;

BEGIN

SELECT NVL(SUM(NVL(PR_DETALLE_FUENTES_REINT.valor,0)),0)  INTO mi_valor_modifica
FROM PR_REINTEGRO_AJUSTES, PR_DETALLE_FUENTES_REINT
WHERE (PR_REINTEGRO_AJUSTES.vigencia=PR_DETALLE_FUENTES_REINT.vigencia
AND    PR_REINTEGRO_AJUSTES.codigo_compania=PR_DETALLE_FUENTES_REINT.codigo_compania
AND    PR_REINTEGRO_AJUSTES.codigo_unidad_ejecutora=PR_DETALLE_FUENTES_REINT.codigo_unidad_ejecutora
AND    PR_REINTEGRO_AJUSTES.numero_orden=PR_DETALLE_FUENTES_REINT.numero_orden
AND    PR_REINTEGRO_AJUSTES.consecutivo_orden=PR_DETALLE_FUENTES_REINT.consecutivo_orden
AND    PR_REINTEGRO_AJUSTES.numero_disponibilidad=PR_DETALLE_FUENTES_REINT.numero_disponibilidad
AND    PR_REINTEGRO_AJUSTES.numero_registro=PR_DETALLE_FUENTES_REINT.numero_registro
AND    PR_REINTEGRO_AJUSTES.consecutivo_ajuste=PR_DETALLE_FUENTES_REINT.consecutivo_ajuste)
AND    PR_REINTEGRO_AJUSTES.vigencia = una_vigencia
AND    PR_REINTEGRO_AJUSTES.codigo_compania = una_compania
AND    PR_REINTEGRO_AJUSTES.codigo_unidad_ejecutora = una_unidad_ejecutora
AND    PR_DETALLE_FUENTES_REINT.RUBRO_INTERNO=un_rubro
AND    PR_DETALLE_FUENTES_REINT.NUMERO_DISPONIBILIDAD=un_documentos_numero
AND    PR_REINTEGRO_AJUSTES.tipo_movimiento = 'AJUSTE'
AND    PR_DETALLE_FUENTES_REINT.CODIGO_FUENTE=una_fuente
AND    PR_DETALLE_FUENTES_REINT.CODIGO_DET_FUENTE_FINANC=un_detalle_fuente;


--AND    pr_reintegro_ajustes.cerrado <> '0'
RETURN NVL(mi_valor_modifica,0);
EXCEPTION
   WHEN NO_DATA_FOUND THEN
        RETURN 0;


END fn_pre_trae_AjusReint_Rp;



/***********************************************************************************************
 Funcion: fn_pre_trae_Ajustes_Rp (compromisos)
 Descripcion:Trae la suma de detalles de un rubro de ajustes, para una determinada fuente
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, rubro, Numero disponibilidad, fuente de financiacion
 Salidas : suma de valores de lo detalladao en modificaciones presupuestales.
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_trae_Ajustes_Rp (una_vigencia               NUMBER,
                                   una_compania               VARCHAR2,
                                   una_unidad_ejecutora       VARCHAR2,
                                   un_rubro                   NUMBER,
                                   una_fuente                 VARCHAR2,
                                   un_detalle_fuente          NUMBER,
                                   un_documentos_numero       NUMBER
                                   ) RETURN NUMBER IS
mi_valor_modifica  NUMBER;

BEGIN

SELECT NVL(SUM(NVL(PR_DETALLE_FUENTES_AJUSTES.valor,0)),0)  INTO mi_valor_modifica
FROM PR_REINTEGRO_AJUSTES, PR_DETALLE_FUENTES_AJUSTES
WHERE (PR_REINTEGRO_AJUSTES.vigencia=PR_DETALLE_FUENTES_AJUSTES.vigencia
AND    PR_REINTEGRO_AJUSTES.codigo_compania=PR_DETALLE_FUENTES_AJUSTES.codigo_compania
AND    PR_REINTEGRO_AJUSTES.codigo_unidad_ejecutora=PR_DETALLE_FUENTES_AJUSTES.codigo_unidad_ejecutora
AND    PR_REINTEGRO_AJUSTES.numero_orden=PR_DETALLE_FUENTES_AJUSTES.numero_orden
AND    PR_REINTEGRO_AJUSTES.consecutivo_orden=PR_DETALLE_FUENTES_AJUSTES.consecutivo_orden
AND    PR_REINTEGRO_AJUSTES.numero_disponibilidad=PR_DETALLE_FUENTES_AJUSTES.numero_disponibilidad
AND    PR_REINTEGRO_AJUSTES.numero_registro=PR_DETALLE_FUENTES_AJUSTES.numero_registro
AND    PR_REINTEGRO_AJUSTES.consecutivo_ajuste=PR_DETALLE_FUENTES_AJUSTES.consecutivo_ajuste)
AND    PR_REINTEGRO_AJUSTES.vigencia = una_vigencia
AND    PR_REINTEGRO_AJUSTES.codigo_compania = una_compania
AND    PR_REINTEGRO_AJUSTES.codigo_unidad_ejecutora = una_unidad_ejecutora
AND    PR_DETALLE_FUENTES_AJUSTES.RUBRO_INTERNO=un_rubro
AND    PR_DETALLE_FUENTES_AJUSTES.NUMERO_DISPONIBILIDAD=un_documentos_numero
AND    PR_REINTEGRO_AJUSTES.tipo_movimiento = 'AJUSTE'
AND    PR_DETALLE_FUENTES_AJUSTES.CODIGO_FUENTE=una_fuente
AND    PR_DETALLE_FUENTES_AJUSTES.CODIGO_DET_FUENTE_FINANC=un_detalle_fuente;

--AND    pr_reintegro_ajustes.cerrado <> '0'
RETURN NVL(mi_valor_modifica,0);

EXCEPTION
   WHEN NO_DATA_FOUND THEN
        RETURN 0;

END fn_pre_trae_Ajustes_Rp;


/***********************************************************************************************
 Funcion: fn_pre_trae_valReint_cdp  (disponibilidades)
 Descripcion:Trae la suma de detalles de un rubro de modificaciones presupuestales, para una determinada fuente
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, rubro, Numero disponibilidad, fuente de financiacion
 Salidas : suma de valores de lo detalladao en modificaciones presupuestales.
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_trae_valReint_cdp (una_vigencia               NUMBER,
                                   una_compania               VARCHAR2,
                                   una_unidad_ejecutora       VARCHAR2,
                                   un_rubro                   NUMBER,
                                   una_fuente                 VARCHAR2,
                                   un_detalle_fuente          NUMBER
                                   ) RETURN NUMBER IS
mi_valor_modifica  NUMBER;

BEGIN

SELECT NVL(SUM(NVL(PR_DETALLE_FUENTES_REINT.valor,0)),0)  INTO mi_valor_modifica
FROM PR_REINTEGRO_AJUSTES, PR_DETALLE_FUENTES_REINT
WHERE (PR_DETALLE_FUENTES_REINT.vigencia=PR_REINTEGRO_AJUSTES.vigencia
AND    PR_DETALLE_FUENTES_REINT.codigo_compania=PR_REINTEGRO_AJUSTES.codigo_compania
AND    PR_DETALLE_FUENTES_REINT.codigo_unidad_ejecutora=PR_REINTEGRO_AJUSTES.codigo_unidad_ejecutora
AND    PR_DETALLE_FUENTES_REINT.numero_orden=PR_REINTEGRO_AJUSTES.numero_orden
AND    PR_DETALLE_FUENTES_REINT.consecutivo_orden=PR_REINTEGRO_AJUSTES.consecutivo_orden
AND    PR_DETALLE_FUENTES_REINT.numero_disponibilidad=PR_REINTEGRO_AJUSTES.numero_disponibilidad
AND    PR_DETALLE_FUENTES_REINT.numero_registro=PR_REINTEGRO_AJUSTES.numero_registro
AND    PR_DETALLE_FUENTES_REINT.consecutivo_ajuste=PR_REINTEGRO_AJUSTES.consecutivo_ajuste)
AND    PR_DETALLE_FUENTES_REINT.vigencia = una_vigencia
AND    PR_DETALLE_FUENTES_REINT.codigo_compania = una_compania
AND    PR_DETALLE_FUENTES_REINT.codigo_unidad_ejecutora = una_unidad_ejecutora
AND    PR_DETALLE_FUENTES_REINT.RUBRO_INTERNO=un_rubro
AND    PR_REINTEGRO_AJUSTES.tipo_movimiento = 'REINTEGRO'
AND    PR_REINTEGRO_AJUSTES.cerrado <> '0'
AND    PR_DETALLE_FUENTES_REINT.CODIGO_FUENTE=una_fuente
AND    PR_DETALLE_FUENTES_REINT.CODIGO_DET_FUENTE_FINANC=un_detalle_fuente;


RETURN NVL(mi_valor_modifica,0);
EXCEPTION
   WHEN NO_DATA_FOUND THEN
        RETURN 0;


END fn_pre_trae_valReint_cdp;



/***********************************************************************************************
 Funcion: fn_pre_trae_valReint_Rp   (compromisos)
 Descripcion:Trae la suma de detalles de un rubro de modificaciones presupuestales, para una determinada fuente
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, rubro, Numero disponibilidad, fuente de financiacion
 Salidas : suma de valores de lo detalladao en modificaciones presupuestales.
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_trae_valReint_Rp (una_vigencia               NUMBER,
                                  una_compania               VARCHAR2,
                                  una_unidad_ejecutora       VARCHAR2,
                                  un_tipo_documento          VARCHAR2,
                                  un_tipo_movimiento         VARCHAR2,
                                  un_rubro                   NUMBER,
                                  una_fuente                 VARCHAR2,
                                  un_detalle_fuente          NUMBER,
                                  una_disponibilidad         NUMBER
                                   ) RETURN NUMBER IS
mi_valor_modifica  NUMBER;

BEGIN

SELECT NVL(SUM(NVL(PR_DETALLE_FUENTES_REINT.valor,0)),0)  INTO mi_valor_modifica
FROM PR_REINTEGRO_AJUSTES, PR_DETALLE_FUENTES_REINT
WHERE (PR_REINTEGRO_AJUSTES.vigencia=PR_DETALLE_FUENTES_REINT.vigencia
AND    PR_REINTEGRO_AJUSTES.codigo_compania=PR_DETALLE_FUENTES_REINT.codigo_compania
AND    PR_REINTEGRO_AJUSTES.codigo_unidad_ejecutora=PR_DETALLE_FUENTES_REINT.codigo_unidad_ejecutora
AND    PR_REINTEGRO_AJUSTES.numero_orden=PR_DETALLE_FUENTES_REINT.numero_orden
AND    PR_REINTEGRO_AJUSTES.consecutivo_orden=PR_DETALLE_FUENTES_REINT.consecutivo_orden
AND    PR_REINTEGRO_AJUSTES.numero_disponibilidad=PR_DETALLE_FUENTES_REINT.numero_disponibilidad
AND    PR_REINTEGRO_AJUSTES.numero_registro=PR_DETALLE_FUENTES_REINT.numero_registro
AND    PR_REINTEGRO_AJUSTES.consecutivo_ajuste=PR_DETALLE_FUENTES_REINT.consecutivo_ajuste)
AND    PR_REINTEGRO_AJUSTES.vigencia = una_vigencia
AND    PR_REINTEGRO_AJUSTES.codigo_compania = una_compania
AND    PR_REINTEGRO_AJUSTES.codigo_unidad_ejecutora = una_unidad_ejecutora
AND    PR_DETALLE_FUENTES_REINT.RUBRO_INTERNO=un_rubro
AND    PR_DETALLE_FUENTES_REINT.NUMERO_DISPONIBILIDAD = una_disponibilidad
AND    PR_REINTEGRO_AJUSTES.tipo_movimiento = 'REINTEGRO'
AND    PR_REINTEGRO_AJUSTES.cerrado <> '0'
AND    PR_DETALLE_FUENTES_REINT.CODIGO_FUENTE=una_fuente
AND    PR_DETALLE_FUENTES_REINT.CODIGO_DET_FUENTE_FINANC=un_detalle_fuente;

RETURN NVL(mi_valor_modifica,0);
EXCEPTION
   WHEN NO_DATA_FOUND THEN
        RETURN 0;


END fn_pre_trae_valReint_Rp;

/***********************************************************************************************
 Funcion: fn_pre_traer_valor_modif (suspensiones )
 Descripcion:Trae la suma de detalles de un rubro de modificaciones presupuestales, para una determinada fuente
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, rubro, Numero disponibilidad, fuente de financiacion
 Salidas : suma de valores de lo detalladao en modificaciones presupuestales.
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_traer_valor_modif (una_vigencia               NUMBER,
                                   una_compania               VARCHAR2,
                                   una_unidad_ejecutora       VARCHAR2,
                                   un_tipo_documento          VARCHAR2,
                                   un_rubro_interno           NUMBER,
                                   un_tipo_movimiento         VARCHAR2,
                                   un_numero_disponibilidad   NUMBER,
                                   una_fuente                 VARCHAR2,
                                   un_detalle_fuente          NUMBER,
                                   un_documentos_numero       VARCHAR2
                                   ) RETURN NUMBER IS
mi_valor_modifica  NUMBER;

BEGIN

IF un_tipo_movimiento='ADICION' THEN
  SELECT SUM(VALOR_CREDITO) INTO mi_valor_modifica
   FROM PR_DETALLE_FUENTES_MODIF
   WHERE VIGENCIA=una_vigencia
   AND   CODIGO_COMPANIA=una_compania
   AND   CODIGO_UNIDAD_EJECUTORA=una_unidad_ejecutora
   AND   RUBRO_INTERNO=un_rubro_interno
   AND   NUMERO_DISPONIBILIDAD=un_numero_disponibilidad
   AND   CODIGO_FUENTE = una_fuente
   AND   CODIGO_DET_FUENTE_FINANC = un_detalle_fuente
   AND   TIPO_MOVIMIENTO=un_tipo_movimiento;

ELSE  --es REDUCCION o REDUCCION_SUSPENSION

   SELECT SUM(VALOR_CONTRACREDITO) INTO mi_valor_modifica
   FROM PR_DETALLE_FUENTES_MODIF
   WHERE VIGENCIA=una_vigencia
   AND   CODIGO_COMPANIA=una_compania
   AND   CODIGO_UNIDAD_EJECUTORA=una_unidad_ejecutora
   AND   RUBRO_INTERNO=un_rubro_interno
   AND   NUMERO_DISPONIBILIDAD=un_numero_disponibilidad
   AND   CODIGO_FUENTE = una_fuente
   AND   CODIGO_DET_FUENTE_FINANC = un_detalle_fuente
   AND   TIPO_MOVIMIENTO=un_tipo_movimiento;

  --AND   TIPO_MOVIMIENTO='REDUCCION_SUSPENSION';
  --  AND   DOCUMENTOS_NUMERO!=un_documentos_numero;

END IF;

RETURN NVL(mi_valor_modifica,0);
EXCEPTION
   WHEN NO_DATA_FOUND THEN
        RETURN 0;


END fn_pre_traer_valor_modif;

/***********************************************************************************************
 Funcion: fn_pre_traer_valor_rezago
 Descripcion:Trae la suma de detalles de un rubro de suspensiones
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, rubro, fuente de financiacion, detalle_fuente
 Salidas : suma de valores de lo detallados en las suspensiones
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_traer_valor_rezago (una_vigencia              NUMBER,
                                   una_compania               VARCHAR2,
                                   una_unidad_ejecutora       VARCHAR2,
                                   un_rubro_interno           NUMBER,
                                   una_fuente                 VARCHAR2,
                                   un_detalle_fuente          NUMBER
                                   ) RETURN NUMBER IS
mi_valor_rezago  NUMBER;

BEGIN

  SELECT SUM(VALOR_REZAGO) INTO mi_valor_rezago
   FROM PR_DETALLE_FUENTES_REZAGO
   WHERE VIGENCIA=una_vigencia
   AND   CODIGO_COMPANIA=una_compania
   AND   CODIGO_UNIDAD_EJECUTORA=una_unidad_ejecutora
   AND   RUBRO_INTERNO=un_rubro_interno
   AND   CODIGO_FUENTE = una_fuente
   AND   CODIGO_DET_FUENTE_FINANC = un_detalle_fuente;

RETURN NVL(mi_valor_rezago,0);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
       RETURN 0;

END fn_pre_traer_valor_rezago;


/***********************************************************************************************
 Funcion: fn_pre_valor_anul_parc_res
 Descripcion:Trae la suma de detalles de fuentes de financiacion de anulaciones parciales de reservas
 Entradas: Vigencia, Rubro, Compania , Unidad Ejecutora, rubro, fuente de financiacion, detalle_fuente
 Salidas : suma de valores de lo detallados en las suspensiones
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_valor_anul_parc_res (una_vigencia             NUMBER,
                                     una_compania             VARCHAR2,
                                     una_unidad               VARCHAR2,
                                     un_registro              NUMBER,
                                     una_disponibilidad       NUMBER,
                                     un_rubro                 NUMBER,
                                     una_orden                NUMBER,
                                     un_codigo_fuente         VARCHAR2,
                                     un_detalle_fuente        NUMBER) RETURN NUMBER IS


mi_valor_anula_reserva  NUMBER;

BEGIN



  SELECT NVL(SUM(NVL(valor_anulado,0)),0) INTO mi_valor_anula_reserva
          FROM PR_RP_ANULA_RES_DETA
          WHERE vigencia = una_vigencia
          AND   codigo_compania = una_compania
          AND   codigo_unidad_ejecutora = una_unidad
          AND   numero_registro = un_registro
          AND   numero_disponibilidad= una_disponibilidad
          AND   rubro_interno = un_rubro
          AND   codigo_fuente=un_codigo_fuente
          AND   codigo_det_fuente_financ=un_detalle_fuente;


RETURN NVL(mi_valor_anula_reserva,0);

EXCEPTION
   WHEN NO_DATA_FOUND THEN
        RETURN 0;


END fn_pre_valor_anul_parc_res;


/***********************************************************************************************
 Funcion: fn_pre_valor_anula_reserva
 Descripcion:Trae la suma de detalles de fuentes de financiacion de anulaciones totales de reservas
 Entradas: Vigencia, Compania , Unidad Ejecutora, registro presupuestal,Rubro,
           orden de pago, fuente de financiacion, detalle_fuente
 Salidas : suma de valores de lo detallados en anulaciones totales de reservas
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_valor_anula_reserva (una_vigencia             NUMBER,
                                     una_compania             VARCHAR2,
                                     una_unidad               VARCHAR2,
                                     un_registro              NUMBER,
                                     un_rubro                 NUMBER,
                                     una_orden                NUMBER,
                                     un_codigo_fuente         VARCHAR2,
                                     un_detalle_fuente        NUMBER) RETURN NUMBER IS


mi_valor_anula_reserva  NUMBER;

BEGIN



  SELECT NVL(SUM(NVL(valor_anulado,0)),0) INTO mi_valor_anula_reserva
          FROM PR_RP_ANULA_RES_DETA
          WHERE vigencia = una_vigencia
          AND   codigo_compania = una_compania
          AND   codigo_unidad_ejecutora = una_unidad
          AND   numero_registro = un_registro
          AND   rubro_interno = un_rubro
          AND   codigo_fuente=un_codigo_fuente
          AND   codigo_det_fuente_financ=un_detalle_fuente;



RETURN NVL(mi_valor_anula_reserva,0);

EXCEPTION
   WHEN NO_DATA_FOUND THEN
        RETURN 0;

END fn_pre_valor_anula_reserva;


/***********************************************************************************************
 Funcion: fn_traer_cdpsincomp_det
 Descripcion:Devuelve el valor sin comprometer de un rubro de un CDP para una fuente de
             financiacion
 Entradas: Vigencia, Compania , Unidad Ejecutora, registro presupuestal,Rubro,
           orden de pago, fuente de financiacion, detalle_fuente
 Salidas : suma de valores de lo detallados en anulaciones totales de reservas
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones : RQ808/2005

 Fecha          : Mayo 13 de 2005
 Responsable    : Gloria Avila
 Descripcion    : en el valor de rp's quitar los que estan anulados, para calcular el saldo disponible
                  (usada en : anulaciones parciales de cdp y anulaciones parciales autorizadas )

***********************************************************************************************/


FUNCTION fn_traer_cdpsincomp_det(un_numero_cdp      NUMBER,
                                 un_codigo_compania VARCHAR2,
							 	 un_codigo_unidad   VARCHAR2,
        					 	 una_vigencia       NUMBER,
        					 	 un_interno         VARCHAR2,
								 un_codigo_fuente   VARCHAR2,
								 un_detalle_fuente  NUMBER) RETURN NUMBER IS

        -- Declaracion de variables

        mi_valor_sin_comprometer    NUMBER;
        mi_valor_cdp 			    NUMBER;
        mi_valor_rp  			    NUMBER;
        mi_valor_anulado 		    NUMBER;
        mi_valor_rp_anulado 	 	NUMBER;
        mi_valor_anulado_autorizado NUMBER;

        -- Manipula cursor para determinar datos: Total disponible para un rubro
        -- especifico de un CDP

        CURSOR cur_valor_cdp IS
        SELECT NVL(SUM(NVL(deta.VALOR,0)),0)
		FROM PR_DISPONIBILIDADES disp,
             PR_DISPONIBILIDAD_RUBRO dr,
			 PR_DETALLE_FUENTES_CDP deta
        WHERE disp.VIGENCIA = dr.VIGENCIA
		  AND disp.CODIGO_COMPANIA= dr.CODIGO_COMPANIA
		  AND disp.CODIGO_UNIDAD_EJECUTORA=dr.CODIGO_UNIDAD_EJECUTORA
		  AND disp.NUMERO_DISPONIBILIDAD=dr.NUMERO_DISPONIBILIDAD

		  AND dr.VIGENCIA=deta.VIGENCIA
		  AND dr.RUBRO_INTERNO=deta.RUBRO_INTERNO
		  AND dr.CODIGO_COMPANIA=deta.CODIGO_COMPANIA
		  AND dr.CODIGO_UNIDAD_EJECUTORA=deta.CODIGO_UNIDAD_EJECUTORA
		  AND dr.NUMERO_DISPONIBILIDAD=deta.NUMERO_DISPONIBILIDAD

		  AND dr.VIGENCIA = una_vigencia
		  AND dr.RUBRO_INTERNO = un_interno
		  AND dr.CODIGO_COMPANIA = un_codigo_compania
		  AND dr.CODIGO_UNIDAD_EJECUTORA = un_codigo_unidad
		  AND dr.NUMERO_DISPONIBILIDAD = un_numero_cdp
		  AND deta.CODIGO_FUENTE=un_codigo_fuente
		  AND deta.CODIGO_DET_FUENTE_FINANC=un_detalle_fuente
	--	  AND (disp.estado = 'VIGENTE' or disp.estado = 'VIGENTE-AGOTADO')
          GROUP BY dr.VIGENCIA,
                   dr.RUBRO_INTERNO,
                   dr.CODIGO_COMPANIA,
                   dr.CODIGO_UNIDAD_EJECUTORA,
                   dr.NUMERO_DISPONIBILIDAD;

        -- Manipula cursor para determinar datos: Total expedido mediante
        -- Registro Presupuestal para un rubro de un CDP especifico

          CURSOR cur_valor_rp IS
            SELECT NVL(SUM(NVL(deta.valor,0)),0)
            FROM  PR_REGISTRO_DISPONIBILIDAD disp,
			      PR_REGISTRO_PRESUPUESTAL rp,
				  PR_COMPROMISOS com,
				  PR_DETALLE_FUENTES_RP deta
            WHERE   deta.VIGENCIA = disp.VIGENCIA
			    AND deta.CODIGO_COMPANIA = disp.CODIGO_COMPANIA
				AND	deta.CODIGO_UNIDAD_EJECUTORA = disp.CODIGO_UNIDAD_EJECUTORA
				AND	deta.RUBRO_INTERNO = disp.RUBRO_INTERNO
				AND	deta.NUMERO_DISPONIBILIDAD = disp.NUMERO_DISPONIBILIDAD
				AND	deta.NUMERO_REGISTRO = disp.NUMERO_REGISTRO
				AND	disp.NUMERO_DISPONIBILIDAD= rp.NUMERO_DISPONIBILIDAD
                AND disp.NUMERO_REGISTRO= rp.NUMERO_REGISTRO
              	AND	disp.CODIGO_UNIDAD_EJECUTORA= rp.CODIGO_UNIDAD_EJECUTORA
              	AND	disp.CODIGO_COMPANIA= rp.CODIGO_COMPANIA
              	AND	disp.VIGENCIA= rp.VIGENCIA
              	AND	rp.NUMERO_REGISTRO= com.NUMERO_REGISTRO
              	AND	rp.TIPO_COMPROMISO= com.TIPO_COMPROMISO
              	AND	rp.NUMERO_COMPROMISO= com.NUMERO_COMPROMISO
              	AND	rp.CODIGO_UNIDAD_EJECUTORA= com.CODIGO_UNIDAD_EJECUTORA
              	AND	rp.CODIGO_COMPANIA= com.CODIGO_COMPANIA
              	AND	rp.VIGENCIA= com.VIGENCIA
              	AND	disp.VIGENCIA = una_vigencia
              	AND	disp.CODIGO_COMPANIA = un_codigo_compania
              	AND	disp.CODIGO_UNIDAD_EJECUTORA = un_codigo_unidad
              	AND	disp.NUMERO_DISPONIBILIDAD = un_numero_cdp
              	AND	disp.rubro_interno= un_interno
				AND	deta.CODIGO_FUENTE = un_codigo_fuente
				AND deta.CODIGO_DET_FUENTE_FINANC = un_detalle_fuente
				AND	rp.ESTADO <> 'ANULADO';


        -- Manipula cursor para determinar datos: Total anulado para un rubro de un CDP especifico

        CURSOR cur_valor_anulado IS
        SELECT NVL(SUM(NVL(deta.valor_anulado,0)),0)
          FROM PR_CDP_ANULADOS anul,
               PR_ANULA_DETALLE_CDP deta
          WHERE anul.VIGENCIA = deta.VIGENCIA
		    AND anul.CODIGO_COMPANIA = deta.CODIGO_COMPANIA
		    AND anul.CODIGO_UNIDAD_EJECUTORA = deta.CODIGO_UNIDAD_EJECUTORA
		    AND anul.NUMERO_DISPONIBILIDAD = deta.NUMERO_DISPONIBILIDAD
			AND	anul.RUBRO_INTERNO = deta.RUBRO_INTERNO
			AND	anul.NUMERO_REGISTRO = deta.NUMERO_REGISTRO
			AND	anul.NUMERO_COMPROMISO = deta.NUMERO_COMPROMISO
			AND	anul.TIPO_COMPROMISO = deta.TIPO_COMPROMISO
			AND	anul.CONSECUTIVO_ANULACION = deta.CONSECUTIVO_ANULACION
		    AND anul.vigencia = una_vigencia
            AND anul.codigo_compania = un_codigo_compania
            AND anul.codigo_unidad_ejecutora = un_codigo_unidad
            AND anul.numero_disponibilidad = un_numero_cdp
            AND anul.rubro_interno = un_interno
			AND deta.CODIGO_FUENTE = un_codigo_fuente
			AND deta.CODIGO_DET_FUENTE_FINANC = un_detalle_fuente;

        -- Manipula cursor para determinar datos: Total anulado para un rubro de un CDP especifico

        CURSOR cur_valor_rp_anulado IS
        SELECT NVL(SUM(NVL(deta.valor_anulado,0)),0)
        FROM PR_RP_ANULADOS anul,
             PR_RP_ANULADOS_DETALLE deta
        WHERE anul.VIGENCIA = deta.VIGENCIA
          AND anul.CODIGO_COMPANIA = deta.CODIGO_COMPANIA
          AND anul.CODIGO_UNIDAD_EJECUTORA = deta.CODIGO_UNIDAD_EJECUTORA
          AND anul.RUBRO_INTERNO = deta.RUBRO_INTERNO
          AND anul.NUMERO_REGISTRO = deta.NUMERO_REGISTRO
          AND anul.NUMERO_DISPONIBILIDAD = deta.NUMERO_DISPONIBILIDAD
          AND anul.CONSECUTIVO_ANULACION = deta.CONSECUTIVO_ANULACION
          AND anul.vigencia = una_vigencia
          AND anul.codigo_compania = un_codigo_compania
          AND anul.codigo_unidad_ejecutora = un_codigo_unidad
          AND anul.numero_disponibilidad = un_numero_cdp
          AND anul.rubro_interno = un_interno
          AND deta.CODIGO_FUENTE = un_codigo_fuente
          AND deta.CODIGO_DET_FUENTE_FINANC = un_detalle_fuente;

        -- Manipula cursor para determinar datos: Total anulado para un rubro de un CDP con autorizacion

        CURSOR cur_valor_anulado_autorizado IS
          SELECT NVL(SUM(NVL(deta.valor_anulado,0)),0)
          FROM PR_CDP_ANULADOS_AUTORIZADOS anul,
		       PR_CDP_ANULA_AUTORIZA_DETALLE deta
          WHERE anul.VIGENCIA = deta.VIGENCIA
		    AND anul.RUBRO_INTERNO = deta.RUBRO_INTERNO
			AND	anul.CODIGO_COMPANIA = deta.CODIGO_COMPANIA
			AND	anul.CODIGO_UNIDAD_EJECUTORA = deta.CODIGO_UNIDAD_EJECUTORA
			AND	anul.NUMERO_DISPONIBILIDAD = deta.NUMERO_DISPONIBILIDAD
			AND	anul.CONSECUTIVO_ANULACION = deta.CONSECUTIVO_ANULACION
		    AND anul.vigencia = una_vigencia
            AND anul.codigo_compania = un_codigo_compania
            AND anul.codigo_unidad_ejecutora = un_codigo_unidad
            AND anul.numero_disponibilidad = un_numero_cdp
            AND anul.rubro_interno = un_interno
			AND deta.CODIGO_FUENTE = un_codigo_fuente
			AND deta.CODIGO_DET_FUENTE_FINANC = un_detalle_fuente;



          BEGIN

            -- Inicializa variable
            mi_valor_sin_comprometer := NULL;
            mi_valor_cdp := NULL;
            mi_valor_rp := NULL;
            mi_valor_anulado := NULL;
            mi_valor_anulado_autorizado := NULL;

           -- Asigna a mi_valor_cdp el valor total expedido para un rubro
           -- mediante CDP

           OPEN cur_valor_cdp;
           FETCH cur_valor_cdp INTO mi_valor_cdp;
           CLOSE cur_valor_cdp;

           -- Asigna a mi_valor_rp el valor total expedido para un rubro
           -- mediante RP

           OPEN cur_valor_rp;
           FETCH cur_valor_rp INTO mi_valor_rp;
           CLOSE cur_valor_rp;

           -- Asigna a mi_valor_anulado el valor total anulado para un rubro
           -- mediante CDP

           OPEN cur_valor_anulado;
           FETCH cur_valor_anulado INTO mi_valor_anulado;
           CLOSE cur_valor_anulado;

           -- Asigna a mi_valor_anulado el valor total anulado para un rubro
           -- mediante rP

           OPEN cur_valor_rp_anulado;
           FETCH cur_valor_rp_anulado INTO mi_valor_rp_anulado;
           CLOSE cur_valor_rp_anulado;


         -- Valor anulado autorizado

           OPEN cur_valor_anulado_autorizado;
           FETCH cur_valor_anulado_autorizado INTO mi_valor_anulado_autorizado;
           CLOSE cur_valor_anulado_autorizado;

           mi_valor_sin_comprometer := NVL(mi_valor_cdp,0) - NVL(mi_valor_rp,0) - NVL(mi_valor_anulado,0) + NVL(mi_valor_rp_anulado,0)- NVL(mi_valor_anulado_autorizado,0);

            -- Devuelve valor sin comprometer para un rubro
           RETURN mi_valor_sin_comprometer;
           EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    RETURN(NVL(mi_valor_cdp,0));

 END fn_traer_cdpsincomp_det;

/***********************************************************************************************
 Funcion: fn_pre_traer_valor_dis
 Descripcion:Devuelve el valor disponible de na fuente de financiacion determinada
            Parte del Requerimiento RQ163
 Entradas: Vigencia, Compania , Unidad Ejecutora, registro presupuestal,Rubro,
           orden de pago, fuente de financiacion, detalle_fuente
 Salidas : Valor disponible de una fuente de financiacion
 Fecha
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/



FUNCTION fn_pre_traer_valor_dis (un_codigo_compania VARCHAR2,
							 	 un_codigo_unidad   VARCHAR2,
        					 	 una_vigencia       NUMBER,
        					 	 un_interno         VARCHAR2,
								 un_codigo_fuente   VARCHAR2,
								 un_detalle_fuente  NUMBER,
								 una_clasificacion  VARCHAR2)
								 RETURN NUMBER IS

      mi_valor                      NUMBER;
      mi_valor_apropia              NUMBER;
      mi_valor_cdp                  NUMBER;
      mi_total_anulacion_total      NUMBER;
      mi_total_anulados             NUMBER;
      mi_valor_modifica             NUMBER;
      mi_total_anulados_autorizados NUMBER;
      mi_valor_total                NUMBER;
      mi_valor_ajuste_reintegro     NUMBER;
      mi_valor_reintegro            NUMBER;
      mi_total                      NUMBER;
	  mi_valor_disponible           NUMBER;

     BEGIN


      mi_valor_apropia:=Pk_Pr_Detalle_Fuentes.fn_pre_traer_valor_det_apro
                                      (una_vigencia,
                                       un_codigo_compania,
     								   un_codigo_unidad,
                                       un_interno,
                                       un_codigo_fuente,
                                       un_detalle_fuente,
                                       una_clasificacion);

      mi_valor_cdp := NVL(Pk_Pr_Detalle_Fuentes.fn_pre_traer_val_acum_cdp
                                      (una_vigencia,
                                       un_codigo_compania,
     								   un_codigo_unidad,
                                       un_interno,
                                       un_codigo_fuente,
                                       un_detalle_fuente,
                                       una_clasificacion),0);

      mi_total_anulacion_total:= NVL(Pk_Pr_Detalle_Fuentes.fn_pre_traer_val_anulTot
                                    (una_vigencia,
                                     un_codigo_compania,
      								 un_codigo_unidad,
                                     un_interno,
     	                             'CDP',
                                     un_codigo_fuente,
                                     un_detalle_fuente),0);


      mi_total_anulados:=NVL(Pk_Pr_Detalle_Fuentes.fn_pre_traer_valor_anulado
                                      (una_vigencia,
                                       un_codigo_compania,
     								   un_codigo_unidad,
     								   un_interno,
                                       un_codigo_fuente,
                                       un_detalle_fuente),0);


      mi_total_anulados_autorizados:=  NVL(Pk_Pr_Detalle_Fuentes.fn_pre_traer_valor_deta_anul
                                      (una_vigencia,
                                       un_codigo_compania,
     								   un_codigo_unidad,
     								   un_interno,
                                       un_codigo_fuente,
                                       un_detalle_fuente),0);

      mi_total :=  NVL(mi_valor_cdp,0) - NVL(mi_total_anulacion_total,0) -  NVL(mi_total_anulados,0) - NVL(mi_total_anulados_autorizados,0);



      mi_valor_ajuste_reintegro:= NVL(Pk_Pr_Detalle_Fuentes.fn_pre_trae_AjusReint_cdp
                                      (una_vigencia,
                                       un_codigo_compania,
     								   un_codigo_unidad,
     								   un_interno,
                                       un_codigo_fuente,
                                       un_detalle_fuente
                                       ),0);

      mi_valor_reintegro:=NVL(Pk_Pr_Detalle_Fuentes.fn_pre_trae_ValReint_cdp
                                      (una_vigencia,
                                       un_codigo_compania,
     								   un_codigo_unidad,
     								   un_interno,
                                       un_codigo_fuente,
                                       un_detalle_fuente),0);

     mi_valor_disponible:= NVL(mi_valor_apropia,0)-(NVL(mi_total,0) + NVL(mi_valor_ajuste_reintegro,0)+ NVL(mi_valor_reintegro,0));


     RETURN NVL(mi_valor_disponible,0);

     END fn_pre_traer_valor_dis;


/***********************************************************************************************
 Funcion: fn_pre_traer_valor_modifica
  Descripcion:Devuelve el valor de modificaciones para un rubro de
             una fuente de financiacion determinada,
 Entradas: Vigencia pago, fuente de financiacion, detalle_fuente
 Salidas : Valor disponible de una fuente de financiacion
 Fecha             Noviembre  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones : RQ815
 Fecha          : Mayo 19 de 2005
 Responsable    : Gloria Avila
 Descripcion    : Incluir al valor del las modificaicones el total de movimiento "CAMBIO FUENTES"

***********************************************************************************************/


FUNCTION fn_pre_traer_valor_modifica (un_codigo_compania VARCHAR2,
							 	      un_codigo_unidad   VARCHAR2,
        					 	      una_vigencia       NUMBER,
        					 	      un_interno         VARCHAR2,
								      un_codigo_fuente   VARCHAR2,
								      un_detalle_fuente  NUMBER,
									  una_fecha          DATE  )
								      RETURN NUMBER IS

mi_valor_modificacion NUMBER;
mi_valor_cambio       NUMBER;

BEGIN

SELECT NVL(SUM(NVL(modi.valor_credito,0)),0)- NVL(SUM(NVL(modi.valor_contracredito,0)),0) INTO mi_valor_modificacion
  FROM PR_DETALLE_FUENTES_MODIF modi,
       PR_MODIFICACION_PRESUPUESTAL modif
  WHERE modif.VIGENCIA =modi.VIGENCIA AND
        modif.CODIGO_COMPANIA=modi.CODIGO_COMPANIA	AND
		modif.CODIGO_UNIDAD_EJECUTORA =modi.CODIGO_UNIDAD_EJECUTORA AND
		modif.TIPO_DOCUMENTO = modi.TIPO_DOCUMENTO	  AND
		modif.DOCUMENTOS_NUMERO	=modi.DOCUMENTOS_NUMERO AND
		modif.RUBRO_INTERNO	=modi.RUBRO_INTERNO AND
		modif.TIPO_MOVIMIENTO =modi.TIPO_MOVIMIENTO AND
		modif.NUMERO_DISPONIBILIDAD=modi.NUMERO_DISPONIBILIDAD AND
        modi.codigo_compania = un_codigo_compania AND
        modi.codigo_unidad_ejecutora = un_codigo_unidad AND
        modi.vigencia = una_vigencia AND
        modi.rubro_interno = un_interno AND
		modi.CODIGO_FUENTE = un_codigo_fuente AND
		modi.CODIGO_DET_FUENTE_FINANC=un_detalle_fuente AND
		modif.fecha_registro <= una_fecha;


	--RQ815/05  Valor Cambio de Fuentes
    SELECT NVL(SUM(NVL(detModi.valor_cambio,0)),0) INTO mi_valor_cambio
    FROM PR_CAMBIO_FUENTES modi,
	     PR_DETALLE_CAMBIO_FUENTES detModi
    WHERE modi.VIGENCIA =detModi.VIGENCIA AND
	      modi.CODIGO_COMPANIA=detModi.CODIGO_COMPANIA AND
		  modi.CODIGO_UNIDAD_EJECUTORA=detModi.CODIGO_UNIDAD_EJECUTORA AND
		  modi.TIPO_DOCUMENTO=detModi.TIPO_DOCUMENTO AND
		  modi.DOCUMENTOS_NUMERO=detModi.DOCUMENTOS_NUMERO AND
		  modi.RUBRO_INTERNO= detModi.RUBRO_INTERNO AND
		  modi.TIPO_MOVIMIENTO=detModi.TIPO_MOVIMIENTO AND
		  modi.NUMERO_DISPONIBILIDAD=detModi.NUMERO_DISPONIBILIDAD AND
	      modi.vigencia = una_vigencia AND
          modi.codigo_compania = un_codigo_compania AND
          modi.codigo_unidad_ejecutora = un_codigo_unidad AND
          modi.rubro_interno = un_interno AND
		  detModi.CODIGO_FUENTE=un_codigo_fuente AND
		  detModi.CODIGO_DET_FUENTE_FINANC=un_detalle_fuente AND
          modi.fecha_registro <= una_fecha;


	  mi_valor_modificacion:=NVL(mi_valor_modificacion,0)+NVL(mi_valor_cambio,0);


      RETURN NVL(mi_valor_modificacion,0);
 EXCEPTION
   WHEN NO_DATA_FOUND THEN
        RETURN 0;

END fn_pre_traer_valor_modifica;



/***********************************************************************************************
 Funcion: fn_pre_traer_valor_cambiof
 Descripcion:Devuelve el valor de cambios en  fuentes de financiacion para un rubro
             parte del requerimiento RQ160
 Entradas: Vigencia pago, fuente de financiacion, detalle_fuente
 Salidas : Valor disponible de una fuente de financiacion
 Fecha     Febrero de 2005
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_traer_valor_cambiof ( un_codigo_compania VARCHAR2,
							 	      un_codigo_unidad   VARCHAR2,
        					 	      una_vigencia       NUMBER,
        					 	      un_interno         VARCHAR2,
								      un_codigo_fuente   VARCHAR2,
								      un_detalle_fuente  NUMBER,
									  una_fecha          DATE  )
								      RETURN NUMBER IS
mi_valor_cambio NUMBER;

BEGIN

SELECT SUM(NVL(modi.valor_cambio,0)) INTO mi_valor_cambio
  FROM PR_DETALLE_CAMBIO_FUENTES modi,
       PR_CAMBIO_FUENTES modif
  WHERE modif.VIGENCIA =modi.VIGENCIA AND
        modif.CODIGO_COMPANIA=modi.CODIGO_COMPANIA	AND
		modif.CODIGO_UNIDAD_EJECUTORA =modi.CODIGO_UNIDAD_EJECUTORA AND
		modif.TIPO_DOCUMENTO = modi.TIPO_DOCUMENTO	  AND
		modif.DOCUMENTOS_NUMERO	=modi.DOCUMENTOS_NUMERO AND
		modif.RUBRO_INTERNO	=modi.RUBRO_INTERNO AND
		modif.TIPO_MOVIMIENTO =modi.TIPO_MOVIMIENTO AND
		modif.NUMERO_DISPONIBILIDAD=modi.NUMERO_DISPONIBILIDAD AND
        modi.codigo_compania = un_codigo_compania AND
        modi.codigo_unidad_ejecutora = un_codigo_unidad AND
        modi.vigencia = una_vigencia AND
        modi.rubro_interno = un_interno AND
		modi.CODIGO_FUENTE = un_codigo_fuente AND
		modi.CODIGO_DET_FUENTE_FINANC=un_detalle_fuente AND
		modif.fecha_registro <= una_fecha;

      RETURN NVL(mi_valor_cambio,0);
 EXCEPTION
   WHEN NO_DATA_FOUND THEN
        RETURN 0;

END fn_pre_traer_valor_cambiof;

/***********************************************************************************************
 Funcion: fn_pre_traer_valor_dis_cambiof
 Descripcion:Devuelve el valor disponible de na fuente de financiacion determinada,
             para un rubro
			  parte del requerimiento RQ160
 Entradas: Vigencia, Compania , Unidad Ejecutora, registro presupuestal,Rubro,
           orden de pago, fuente de financiacion, detalle_fuente
 Salidas : Valor disponible de una fuente de financiacion
 Fecha             Septiembre de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_traer_valor_discambiof (un_codigo_compania VARCHAR2,
							 	        un_codigo_unidad   VARCHAR2,
        					 	        una_vigencia       NUMBER,
        					 	        un_interno         VARCHAR2,
								        un_codigo_fuente   VARCHAR2,
								        un_detalle_fuente  NUMBER,
								        una_clasificacion  VARCHAR2,
										una_fecha          DATE )
								 RETURN NUMBER IS

      mi_valor                      NUMBER;
      mi_valor_apropia              NUMBER;
      mi_valor_cdp                  NUMBER;
      mi_total_anulacion_total      NUMBER;
      mi_total_anulados             NUMBER;
      mi_valor_modifica             NUMBER;
      mi_total_anulados_autorizados NUMBER;
      mi_valor_total                NUMBER;
      mi_valor_ajuste_reintegro     NUMBER;
      mi_valor_reintegro            NUMBER;
      mi_total                      NUMBER;
	  mi_valor_disponible           NUMBER;
	  mi_apropiacion_vigente        NUMBER;
	  mi_suspensiones               NUMBER;
	  mi_apropiacion_disponible     NUMBER;
	  mi_valor_cambiof              NUMBER;

     BEGIN


   --apropiacion inicial

	  mi_valor_apropia:=Pk_Pr_Detalle_Fuentes.fn_pre_apr_inicial_detalle
                                      (una_vigencia,
                                       un_codigo_compania,
     								   un_codigo_unidad,
                                       un_interno,
                                       un_codigo_fuente,
                                       un_detalle_fuente);


	  mi_valor_modifica:=Pk_Pr_Detalle_Fuentes.fn_pre_traer_valor_modifica
	                                           (un_codigo_compania,
											    un_codigo_unidad,
        					 	                una_vigencia,
        					 	                un_interno,
								                un_codigo_fuente,
								                un_detalle_fuente,
									            una_fecha);


	  --apropiacion vigente =apr inic + modificaciones
      mi_apropiacion_vigente :=	 NVL(mi_valor_apropia,0)+ NVL(mi_valor_modifica,0);


      mi_suspensiones:= NVL(Pk_Pr_Consolidados_Gastos_Det.FN_pre_ValorSuspensionAcum
                                            (una_vigencia,
                                            un_codigo_compania,
							                un_codigo_unidad,
                 							una_fecha,
                    						un_interno,
											un_codigo_fuente,
								            un_detalle_fuente),0);


	  mi_valor_cambiof:=Pk_Pr_Detalle_Fuentes.fn_pre_traer_valor_cambiof
                                      (un_codigo_compania,
									   un_codigo_unidad,
									   una_vigencia,
                                       un_interno,
                                       un_codigo_fuente,
                                       un_detalle_fuente,
                                       una_fecha);


     mi_apropiacion_disponible := NVL(mi_apropiacion_vigente,0)- NVL(mi_suspensiones,0) + NVL(mi_valor_cambiof,0);



     RETURN NVL(mi_apropiacion_disponible,0);

  END fn_pre_traer_valor_discambiof;


/***********************************************************************************************
 Funcion: fn_pre_traer_valor_dis_rp
 Descripcion:Devuelve el valor disponible (para registros presupuetales)
             de una fuente de financiacion determinada
 Entradas: Vigencia, Compania , Unidad Ejecutora, registro presupuestal,Rubro,
           orden de pago, fuente de financiacion, detalle_fuente
 Salidas : Valor disponible de una fuente de financiacion
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/


FUNCTION fn_pre_traer_valor_dis_rp (un_codigo_compania VARCHAR2,
							 	    un_codigo_unidad   VARCHAR2,
        					 	 	una_vigencia       NUMBER,
        					 	 	un_interno         VARCHAR2,
								 	un_codigo_fuente   VARCHAR2,
								 	un_detalle_fuente  NUMBER,
								 	una_clasificacion  VARCHAR2,
								 	una_disponibilidad NUMBER)
								 	RETURN NUMBER IS

 mi_valor_cdp            NUMBER;
 mi_valor_rp             NUMBER;
 mi_valor_detalle_rp     NUMBER;
 mi_valor_cdp_anulados   NUMBER;
 mi_valor_cdp_anula_auto NUMBER;
 mi_valor_rp_anulado     NUMBER;
 mi_valor                NUMBER;
 mi_valor_ajuste         NUMBER;
 mi_valor_ajustes        NUMBER;
 mi_valor_ajus_reint     NUMBER;

BEGIN

 mi_valor_cdp:= NVL(Pk_Pr_Detalle_Fuentes.fn_pre_traer_valor_cdp (una_vigencia,
                                                                  un_codigo_compania,
								                                  un_codigo_unidad,
                                                                  un_interno,
                                                                  una_disponibilidad,
								                                  un_codigo_fuente,
								                                  un_detalle_fuente,
								                                  una_clasificacion),0);


--suma los valoreS detallados de rps para esa fuente
 mi_valor_detalle_rp:= NVL(Pk_Pr_Detalle_Fuentes.fn_pre_saldo_rp (una_vigencia,
                                                             	  un_codigo_compania,
								                                  un_codigo_unidad,
                                                                  un_interno,
                                                                  una_disponibilidad,
								                                  un_codigo_fuente,
								                                  un_detalle_fuente),0);


--calcula VALOR DE CDP'S ANULADOS parciales
  mi_valor_cdp_anulados:= NVL(Pk_Pr_Detalle_Fuentes.fn_pre_traer_valor_anul_compro (una_vigencia,
                                                                                    un_codigo_compania,
								                                                    un_codigo_unidad,
                                                                                    un_interno,
                                                                                    un_codigo_fuente,
								                                                    un_detalle_fuente,
								                                                    una_disponibilidad),0);


--calcula valor cdp's anulados autorizados
mi_valor_rp_anulado:= NVL(Pk_Pr_Detalle_Fuentes.fn_pre_valRp_anul_compro (una_vigencia,
                                                                          un_codigo_compania,
								                                          un_codigo_unidad,
                                                                          un_interno,
                                                                          una_disponibilidad,
								                                          un_codigo_fuente,
   							                                              un_detalle_fuente),0);


--valor de cdp's anulados autorizados
  mi_valor_cdp_anula_auto   := NVL(Pk_Pr_Detalle_Fuentes.fn_pre_traer_val_Anul_Rp
                                                    (una_vigencia,
                                                     un_codigo_compania,
								                     un_codigo_unidad,
								                     una_disponibilidad,
                                                     un_interno,
                                                     un_codigo_fuente,
   							                         un_detalle_fuente),0);

--valor reintegros ajustes opcion reintegros - vigencia actual (pr_reintegros_ajustes -pr_detalle_fuentes_reint)
 mi_valor_ajus_reint:= NVL(Pk_Pr_Detalle_Fuentes.fn_pre_trae_AjusReint_Rp
                                             (una_vigencia,
                                              un_codigo_compania,
								              un_codigo_unidad,
								              un_interno,
                                              un_codigo_fuente,
   							                  un_detalle_fuente,
   							                  una_disponibilidad),0);

--trae valor de ajustes (pr_reintegros_ajustes -pr_detalle_fuentes_ajustes)
 mi_valor_ajustes:= NVL(Pk_Pr_Detalle_Fuentes.fn_pre_trae_Ajustes_Rp
                                             (una_vigencia,
                                              un_codigo_compania,
								              un_codigo_unidad,
								              un_interno,
                                              un_codigo_fuente,
   							                  un_detalle_fuente,
   							                  una_disponibilidad ),0);


 mi_valor_ajuste:= mi_valor_ajus_reint+ mi_valor_ajustes;


 mi_valor:= mi_valor_cdp-mi_valor_detalle_rp-mi_valor_cdp_anulados + mi_valor_rp_anulado -mi_valor_cdp_anula_auto;

RETURN NVL(mi_valor,0);

END fn_pre_traer_valor_dis_rp;


/***********************************************************************************************
 Funcion: fn_pre_traer_valor_dis_anu_au
 Descripcion:Devuelve el valor disponible (para anulaciones parciales autorizadas )
             de una fuente de financiacion determinada
 Entradas: Vigencia, Compania , Unidad Ejecutora, registro presupuestal,Rubro,
           orden de pago, fuente de financiacion, detalle_fuente
 Salidas : Valor disponible de una fuente de financiacion
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/


FUNCTION fn_pre_traer_valor_dis_anu_au (un_codigo_compania VARCHAR2,
							 	    un_codigo_unidad   VARCHAR2,
        					 	 	una_vigencia       NUMBER,
        					 	 	un_interno         VARCHAR2,
								 	un_codigo_fuente   VARCHAR2,
								 	un_detalle_fuente  NUMBER,
								 	una_clasificacion  VARCHAR2,
								 	una_disponibilidad NUMBER)
								 	RETURN NUMBER IS



 mi_valor_cdp            NUMBER;
 mi_valor_rp             NUMBER;
 mi_valor_detalle_rp     NUMBER;
 mi_valor_cdp_anulados   NUMBER;
 mi_valor_cdp_anula_auto NUMBER;
 mi_valor_rp_anulado     NUMBER;
 mi_valor                NUMBER;
 mi_valor_ajuste         NUMBER;
 mi_bloque_actual        VARCHAR2(60);

BEGIN


--trae el valor del cdp cuyo estado es VIGENTE o VIGENTE_AGOTADO
 mi_valor_cdp:= NVL(Pk_Pr_Detalle_Fuentes.fn_pre_traer_valor_cdp (una_vigencia,
                                                                  un_codigo_compania,
								                                  un_codigo_unidad,
                                                                  un_interno,
                                                                  una_disponibilidad,
								                                  un_codigo_fuente,
								                                  un_detalle_fuente,
								                                  una_clasificacion),0);


--suma los valoreS detallados de rps para esa fuente
 mi_valor_detalle_rp:= NVL(Pk_Pr_Detalle_Fuentes.fn_pre_saldo_rp (una_vigencia,
                                                                  un_codigo_compania,
								                                  un_codigo_unidad,
                                                                  un_interno,
                                                                  una_disponibilidad,
								                                  un_codigo_fuente,
								                                  un_detalle_fuente),0);


--calcula VALOR DE CDP'S ANULADOS parciales
  mi_valor_cdp_anulados:= NVL(Pk_Pr_Detalle_Fuentes.fn_pre_traer_valor_anul_compro (una_vigencia,
                                                                                    un_codigo_compania,
								                                                    un_codigo_unidad,
                                                                                    un_interno,
                                                                                    un_codigo_fuente,
								                                                    un_detalle_fuente,
								                                                    una_disponibilidad),0);


--calcula valor cdp's anulados autorizados
mi_valor_rp_anulado:= NVL(Pk_Pr_Detalle_Fuentes.fn_pre_valRp_anul_compro (una_vigencia,
                                                                          un_codigo_compania,
								                                          un_codigo_unidad,
                                                                          un_interno,
                                                                          una_disponibilidad,
								                                          un_codigo_fuente,
   							                                              un_detalle_fuente),0);


--valor de cdp's anulados autorizados
  mi_valor_cdp_anula_auto   := NVL(Pk_Pr_Detalle_Fuentes.fn_pre_traer_val_Anul_Rp
                                                         (una_vigencia,
                                                          un_codigo_compania,
								                          un_codigo_unidad,
								                          una_disponibilidad,
                                                          un_interno,
                                                          un_codigo_fuente,
   							                              un_detalle_fuente),0);

 mi_valor_ajuste:= NVL(Pk_Pr_Detalle_Fuentes.fn_pre_trae_AjusReint_Rp
                                             (una_vigencia,
                                              un_codigo_compania,
								              un_codigo_unidad,
								              un_interno,
                                              un_codigo_fuente,
   							                  un_detalle_fuente,
   							                  una_disponibilidad),0);



 mi_valor:= mi_valor_cdp-mi_valor_detalle_rp-mi_valor_cdp_anulados + mi_valor_rp_anulado -mi_valor_cdp_anula_auto;

RETURN NVL(mi_valor,0);

END fn_pre_traer_valor_dis_anu_au;

/***********************************************************************************************
 Funcion: fn_pre_traer_valor_dis_anu_rp
 Descripcion:Devuelve el valor disponible (para anulaciones parciales de registros presupuetales)
             de una fuente de financiacion determinada
 Entradas: Vigencia, Compania , Unidad Ejecutora, registro presupuestal,Rubro,
           orden de pago, fuente de financiacion, detalle_fuente
 Salidas : Valor disponible de una fuente de financiacion
 Fecha             Marzo de  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_traer_valor_dis_anu_rp (un_codigo_compania VARCHAR2,
							 	    un_codigo_unidad   VARCHAR2,
        					 	 	una_vigencia       NUMBER,
        					 	 	un_interno         VARCHAR2,
								 	un_codigo_fuente   VARCHAR2,
								 	un_detalle_fuente  NUMBER,
								 	una_clasificacion  VARCHAR2,
								 	una_disponibilidad NUMBER,
									un_numero_registro NUMBER)
									RETURN NUMBER IS
 mi_valor_cdp              NUMBER;
 mi_valor_rp               NUMBER;
 mi_valor_detalle_rp       NUMBER;
 mi_valor_detalle_op       NUMBER;
 mi_valor_anulado_reservas NUMBER;
 mi_valor_cdp_anula_auto   NUMBER;
 mi_valor_rp_anulados      NUMBER;
 mi_valor_anulado_total    NUMBER;
 mi_valor_pagado           NUMBER;
 mi_reintegro_reserva      NUMBER;
 mi_valor_disponible       NUMBER;



BEGIN
--suma los valoreS detallados de rps para esa fuente
   mi_valor_detalle_rp:= NVL(Pk_Pr_Detalle_Fuentes.fn_pre_traer_valor_rp
                             (una_vigencia,
                              un_codigo_compania,
							  un_codigo_unidad,
                              un_interno,
                              una_disponibilidad,
						      un_codigo_fuente,
							  un_detalle_fuente,
							  una_clasificacion,
					          un_numero_registro),0);

	mi_valor_pagado:= Pk_Pr_Detalle_Fuentes.fn_pre_saldo_op_reservas
	                        	(una_vigencia,
                                 un_codigo_compania,
								 un_codigo_unidad,
                                 un_interno,
                                 un_codigo_fuente,
								 un_detalle_fuente,
								 un_numero_registro);


  mi_valor_rp_anulados:= NVL(Pk_Pr_Detalle_Fuentes.fn_pre_traer_valor_rp_anul_res (una_vigencia,
                                                             un_codigo_compania,
								                             un_codigo_unidad,
                                                             un_interno,
                                                             un_numero_registro,
								                             un_codigo_fuente,
   							                                 un_detalle_fuente),0);


 /* OJO FALTA NUMERO_ORDEn
 mi_valor_anulado_reservas:= pk_pr_detalle_fuentes.fn_pre_valor_anula_reserva
                             (una_vigencia,
                              un_codigo_compania,
							  un_codigo_unidad,
                              un_numero_registro,
                              un_interno,
                              un_numero_orden,
						      un_codigo_fuente,
   							  un_detalle_fuente);

 */
 -- falta calcular mi_reintegro_reserva
   mi_reintegro_reserva:=0;

    mi_valor_disponible:=  NVL(mi_valor_detalle_rp,0) -  NVL(mi_valor_pagado,0) - NVL(mi_valor_rp_anulados,0) - NVL(mi_valor_anulado_reservas,0);
	RETURN NVL(mi_valor_disponible,0);

END fn_pre_traer_valor_dis_anu_rp;


 FUNCTION fn_saldo_cdp_modif_det(un_numero_cdp      NUMBER,
          				  	     un_codigo_compania VARCHAR2,
                                 un_codigo_unidad   VARCHAR2,
                                 una_vigencia       NUMBER,
                                 un_interno         VARCHAR2,
								 una_fuente         VARCHAR2,
								 un_detalle         NUMBER)
								 RETURN NUMBER IS

        -- Declaracion de variables
        mi_valor_reduccion NUMBER;
        mi_valor_suspension NUMBER;
        mi_valor_cdp NUMBER;
        mi_saldo_cdp NUMBER;

        -- Manipula cursor para determinar datos: Total disponible para un rubro
        -- especifico de un CDP

        CURSOR cur_valor_cdp IS
            SELECT NVL(SUM(NVL(deta.VALOR,0)),0)
            FROM PR_DETALLE_FUENTES_CDP deta,
			     PR_DISPONIBILIDAD_RUBRO dr,
			     PR_DISPONIBILIDADES d
            WHERE ( dr.VIGENCIA=deta.VIGENCIA
			       AND dr.CODIGO_COMPANIA=deta.CODIGO_COMPANIA
				   AND dr.CODIGO_UNIDAD_EJECUTORA=Deta.CODIGO_UNIDAD_EJECUTORA
				   AND dr.RUBRO_INTERNO=deta.RUBRO_INTERNO
				   AND dr.NUMERO_DISPONIBILIDAD=deta.NUMERO_DISPONIBILIDAD
			)AND
			   (dr.NUMERO_DISPONIBILIDAD=d.NUMERO_DISPONIBILIDAD AND
                dr.CODIGO_UNIDAD_EJECUTORA=d.CODIGO_UNIDAD_EJECUTORA AND
                dr.CODIGO_COMPANIA=d.CODIGO_COMPANIA AND
                dr.VIGENCIA=d.VIGENCIA) AND
                dr.VIGENCIA = una_vigencia AND
                dr.RUBRO_INTERNO = un_interno AND
                dr.CODIGO_COMPANIA = un_codigo_compania AND
                dr.CODIGO_UNIDAD_EJECUTORA = un_codigo_unidad AND
                dr.NUMERO_DISPONIBILIDAD = un_numero_cdp AND
                (d.estado = 'VIGENTE' OR d.estado = 'VIGENTE-AGOTADO')
			AND (deta.CODIGO_FUENTE=una_fuente AND
				 deta.CODIGO_DET_FUENTE_FINANC=un_detalle)
            GROUP BY dr.VIGENCIA,
                   dr.RUBRO_INTERNO,
                   dr.CODIGO_COMPANIA,
                   dr.CODIGO_UNIDAD_EJECUTORA,
                   dr.NUMERO_DISPONIBILIDAD,
				   deta.CODIGO_FUENTE,
				   deta.CODIGO_DET_FUENTE_FINANC;


        -- Manipula cursor para determinar datos: Total utilizado de un cdp para
        -- un rubro especifico para una modificacion (Reduccion)

        CURSOR cur_reduccion IS
           SELECT NVL(SUM(NVL(deta.valor_contracredito,0)),0)
           FROM PR_MODIFICACION_PRESUPUESTAL modi,
		        PR_DETALLE_FUENTES_MODIF deta
           WHERE modi.VIGENCIA= deta.VIGENCIA AND
		   		 modi.CODIGO_COMPANIA=deta.CODIGO_COMPANIA AND
				 modi.CODIGO_UNIDAD_EJECUTORA=deta.CODIGO_UNIDAD_EJECUTORA AND
				 modi.TIPO_DOCUMENTO=deta.TIPO_DOCUMENTO AND
				 modi.DOCUMENTOS_NUMERO=deta.DOCUMENTOS_NUMERO AND
				 modi.RUBRO_INTERNO=deta.RUBRO_INTERNO AND
				 modi.TIPO_MOVIMIENTO=Deta.TIPO_MOVIMIENTO AND
				 modi.NUMERO_DISPONIBILIDAD=deta.NUMERO_DISPONIBILIDAD AND
		         modi.vigencia = una_vigencia AND
                 modi.codigo_compania = un_codigo_compania AND
                 modi.codigo_unidad_ejecutora = un_codigo_unidad AND
                 modi.numero_disponibilidad = un_numero_cdp AND
                 modi.rubro_interno = un_interno AND
                 modi.tipo_movimiento = 'REDUCCION_SUSPENSION' AND
				 deta.CODIGO_FUENTE=una_fuente AND
				 deta.CODIGO_DET_FUENTE_FINANC=un_detalle;

        -- Manipula cursor para determinar datos: Total utilizado de un cdp para
        -- un rubro especifico para una modificacion (Suspension)

        CURSOR cur_suspension IS
           SELECT SUM(deta.valor_rezago)
           FROM PR_MODIFICACIONES_REZAGO modi,
		        PR_DETALLE_FUENTES_REZAGO deta
           WHERE modi.VIGENCIA=deta.VIGENCIA AND
		   		 modi.CODIGO_COMPANIA=Deta.CODIGO_COMPANIA AND
				 modi.CODIGO_UNIDAD_EJECUTORA=deta.CODIGO_UNIDAD_EJECUTORA AND
				 modi.RUBRO_INTERNO=deta.RUBRO_INTERNO AND
				 modi.TIPO_DOCUMENTO=deta.TIPO_DOCUMENTO AND
				 modi.DOCUMENTOS_NUMERO=deta.DOCUMENTOS_NUMERO AND
				 modi.TIPO_MOVIMIENTO=Deta.TIPO_MOVIMIENTO AND
				 modi.NUMERO_DISPONIBILIDAD=Deta.NUMERO_DISPONIBILIDAD AND
		         modi.vigencia = una_vigencia AND
                 modi.codigo_compania = un_codigo_compania AND
                 modi.codigo_unidad_ejecutora = un_codigo_unidad AND
                 modi.numero_disponibilidad = un_numero_cdp AND
                 modi.rubro_interno = un_interno AND
				 deta.CODIGO_FUENTE=una_fuente AND
				 deta.CODIGO_DET_FUENTE_FINANC=un_detalle;

          BEGIN

            -- Inicializa variable
            mi_valor_cdp := NULL;
            mi_valor_reduccion := NULL;
            mi_valor_suspension := NULL;
            mi_saldo_cdp := NULL;

           -- Asigna a mi_valor_cdp el valor total expedido para un rubro
           -- mediante CDP

           OPEN cur_valor_cdp;
           FETCH cur_valor_cdp INTO mi_valor_cdp;
           CLOSE cur_valor_cdp;

           -- Asigna a mi_valor_reduccion el valor total utilizado para un rubro
           -- en una modificacion presupuestal (Reduccion)

           OPEN cur_reduccion;
           FETCH cur_reduccion INTO mi_valor_reduccion;
           CLOSE cur_reduccion;

           -- Asigna a mi_valor_anulado el valor total anulado para un rubro
           -- mediante CDP

           OPEN cur_suspension;
           FETCH cur_suspension INTO mi_valor_suspension;
           CLOSE cur_suspension;

           mi_saldo_cdp := NVL(mi_valor_cdp,0) - NVL(mi_valor_reduccion,0) - NVL(mi_valor_suspension,0);

            -- Devuelve valor sin comprometer para un rubro
           RETURN NVL(mi_saldo_cdp,0);
           EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    RETURN(NVL(mi_valor_cdp,0));

    END fn_saldo_cdp_modif_det;

/***********************************************************************************************
 Funcion: pr_pre_actualiza_tempo_fuentes
 Descripcion:actualiza el estado dem la tabla temporal
 Entradas: VIGENCIA, RUBRO_INTERNO, CODIGO_COMPANIA, CODIGO_UNIDAD_EJECUTORA,
         NUMERO_DISPONIBILIDAD, NUMERO_REGISTRO,NUMERO_ORDEN,CONSECUTIVO_ORDEN,
         CONSECUTIVO_AJUSTE,TIPO_DOCUMENTO,DOCUMENTOS_NUMERO,TIPO_MOVIMIENTO,
         SALIR,ESTADO,CONSECUTIVO_ANULACION,FORMA
 Salidas :
 Fecha             Agosto   2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

PROCEDURE pr_pre_actualiza_tempo_fuentes (una_vigencia       PR_TEMPO_FUENTES.vigencia%TYPE,
		  								  un_interno         PR_TEMPO_FUENTES.rubro_interno%TYPE,
                                          una_compania       PR_TEMPO_FUENTES.codigo_compania%TYPE,
                                          una_unidad         PR_TEMPO_FUENTES.codigo_unidad_ejecutora%TYPE,
                                          una_disponibilidad PR_TEMPO_FUENTES.numero_disponibilidad%TYPE,
                                          un_registro        PR_TEMPO_FUENTES.numero_registro%TYPE,
                                          una_orden          PR_TEMPO_FUENTES.numero_orden%TYPE,
                                          un_consec_orden    PR_TEMPO_FUENTES.consecutivo_orden%TYPE,
                                          un_consec_ajus     PR_TEMPO_FUENTES.consecutivo_ajuste%TYPE,
                                          un_tip_doc         PR_TEMPO_FUENTES.tipo_documento%TYPE,
                                          un_doc_num         PR_TEMPO_FUENTES.documentos_numero%TYPE,
                                          un_tip_mov         PR_TEMPO_FUENTES.tipo_movimiento%TYPE,
                                          un_consec_anul     PR_TEMPO_FUENTES.consecutivo_anulacion%TYPE,
                                          una_forma          PR_TEMPO_FUENTES.forma%TYPE) IS
BEGIN

		UPDATE PR_TEMPO_FUENTES
		SET ESTADO = NULL
		WHERE VIGENCIA = una_vigencia
		AND RUBRO_INTERNO = un_interno
		AND CODIGO_COMPANIA = una_compania
		AND CODIGO_UNIDAD_EJECUTORA = una_unidad
		AND NUMERO_DISPONIBILIDAD = una_disponibilidad
		AND NUMERO_REGISTRO = un_registro
		AND NUMERO_ORDEN =	  una_orden
		AND CONSECUTIVO_ORDEN = un_consec_orden
		AND CONSECUTIVO_AJUSTE = un_consec_ajus
		AND TIPO_DOCUMENTO	= un_tip_doc
		AND DOCUMENTOS_NUMERO  = un_doc_num
		AND TIPO_MOVIMIENTO	= un_tip_mov
		AND CONSECUTIVO_ANULACION =un_consec_anul
		AND FORMA =una_forma;


END;



/***********************************************************************************************
 Funcion: fn_pre_apropiacion_inicial
 Descripcion:trae el valor de la apropaicion (teniendo en cuenta modificaciones)
              para un rubro
 Entradas: VIGENCIA, RUBRO_INTERNO, CODIGO_COMPANIA, CODIGO_UNIDAD_EJECUTORA,
 Salidas :
 Fecha             Noviembre  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_apropiacion_inicial (una_vigencia NUMBER,
                             una_compania VARCHAR2,
							 una_unidad   VARCHAR2,
							 un_rubro     NUMBER )
                             RETURN NUMBER IS

CURSOR c_apropiacion IS
   	 --SELECT (NVL(valor,0) - NVL(valor_rezago,0) + NVL(valor_modificaciones,0))
     SELECT NVL(valor,0)
	 FROM PR_APROPIACION
     WHERE vigencia = una_vigencia AND
           codigo_compania = una_compania AND
		   codigo_unidad_ejecutora = una_unidad AND
		   rubro_interno = un_rubro;

mi_apropiacion_inicial  NUMBER;

BEGIN
   OPEN c_apropiacion;
   FETCH c_apropiacion INTO mi_apropiacion_inicial;
   CLOSE c_apropiacion;

   RETURN NVL(mi_apropiacion_inicial,0);

	EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN 0;


END  fn_pre_apropiacion_inicial;



/***********************************************************************************************
 Funcion: fn_pre_apr_inicial_detalle
 Descripcion:trae el valor de la apropiacion inicial de un rubro para una fuente de financiacion
 Entradas: VIGENCIA, RUBRO_INTERNO, CODIGO_COMPANIA, CODIGO_UNIDAD_EJECUTORA,
 Salidas :
 Fecha             Noviembre  2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_apr_inicial_detalle (una_vigencia NUMBER,
                                     una_compania VARCHAR2,
							         una_unidad   VARCHAR2,
							         un_rubro     NUMBER,
									 una_fuente	  VARCHAR2,
									 un_detalle  NUMBER )
                             RETURN NUMBER IS

CURSOR c_apropiacion IS
     SELECT NVL(valor,0)
	 FROM PR_DETALLE_FUENTES_APROPIA
     WHERE vigencia = una_vigencia AND
           codigo_compania = una_compania AND
		   codigo_unidad_ejecutora = una_unidad AND
		   rubro_interno = un_rubro	 AND
		   codigo_fuente=una_fuente AND
		   codigo_det_fuente_financ=un_detalle;

mi_apropiacion_inicial  NUMBER;

BEGIN
   OPEN c_apropiacion;
   FETCH c_apropiacion INTO mi_apropiacion_inicial;
   CLOSE c_apropiacion;

   RETURN NVL(mi_apropiacion_inicial,0);

	EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN 0;


END  fn_pre_apr_inicial_detalle;


/***********************************************************************************************
 Funcion: fn_pre_disponibilidades
 Descripcion: Calcula el total de disponibilidades  para un rubro
 Entradas: VIGENCIA, RUBRO_INTERNO, CODIGO_COMPANIA, CODIGO_UNIDAD_EJECUTORA,
 Salidas :
 Fecha             Noviembre   2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_disponibilidades (una_vigencia NUMBER,
                                  una_compania VARCHAR2,
								  una_unidad   VARCHAR2,
								  una_fecha    DATE,
								  un_rubro     NUMBER )
                                  RETURN NUMBER IS

 mi_valor_disponib_total        NUMBER;
 mi_valor_disponibilidades      NUMBER;
 mi_valor_cdp_anulados          NUMBER;
 mi_valor_cdp_parciales         NUMBER;
 mi_valor_cdp_autorizados       NUMBER;
 mi_valor_ajustes               NUMBER;
 mi_valor_reintegro             NUMBER;
 mi_valor_cdp_suspension		NUMBER;
 mi_anulacion_cdp_sus_no_apl    NUMBER;
BEGIN

  mi_valor_cdp_autorizados    := 0;
  mi_valor_cdp_anulados       := 0;
  mi_valor_cdp_parciales      := 0;
  mi_valor_disponib_total     := 0;
  mi_valor_disponibilidades   := 0;
  mi_valor_ajustes            := 0;
  mi_valor_reintegro          := 0;
  mi_valor_cdp_suspension     := 0;
  mi_anulacion_cdp_sus_no_apl := 0;

  -- Calcula el Valor Total de Disponibilidades

SELECT NVL(SUM(NVL(PR_DISPONIBILIDAD_RUBRO.VALOR,0)),0) INTO mi_valor_disponibilidades
FROM PR_DISPONIBILIDAD_RUBRO, PR_DISPONIBILIDADES
WHERE (PR_DISPONIBILIDAD_RUBRO.NUMERO_DISPONIBILIDAD=PR_DISPONIBILIDADES.NUMERO_DISPONIBILIDAD
 AND PR_DISPONIBILIDAD_RUBRO.CODIGO_UNIDAD_EJECUTORA=PR_DISPONIBILIDADES.CODIGO_UNIDAD_EJECUTORA
 AND PR_DISPONIBILIDAD_RUBRO.CODIGO_COMPANIA=PR_DISPONIBILIDADES.CODIGO_COMPANIA
 AND PR_DISPONIBILIDAD_RUBRO.VIGENCIA=PR_DISPONIBILIDADES.VIGENCIA
 AND PR_DISPONIBILIDAD_RUBRO.CODIGO_UNIDAD_EJECUTORA=una_unidad
 AND PR_DISPONIBILIDAD_RUBRO.CODIGO_COMPANIA=una_compania
 AND PR_DISPONIBILIDAD_RUBRO.VIGENCIA=una_vigencia
 AND PR_DISPONIBILIDAD_RUBRO.RUBRO_INTERNO=un_rubro
 AND PR_DISPONIBILIDADES.PARA_SUSPENSION = 0
 AND PR_DISPONIBILIDADES.fecha_registro <= una_fecha);


-- Inicio Se inlcuye a julio 2001

-- Calcula el Valor Total de Disponibilidades del Mes DE SUSPENSION QUE NO SE HAN APLICADO

SELECT NVL(SUM(NVL(PR_DISPONIBILIDAD_RUBRO.VALOR,0)),0) INTO mi_valor_cdp_suspension
FROM PR_DISPONIBILIDAD_RUBRO, PR_DISPONIBILIDADES
WHERE (PR_DISPONIBILIDAD_RUBRO.NUMERO_DISPONIBILIDAD=PR_DISPONIBILIDADES.NUMERO_DISPONIBILIDAD
 AND PR_DISPONIBILIDAD_RUBRO.CODIGO_UNIDAD_EJECUTORA=PR_DISPONIBILIDADES.CODIGO_UNIDAD_EJECUTORA
 AND PR_DISPONIBILIDAD_RUBRO.CODIGO_COMPANIA=PR_DISPONIBILIDADES.CODIGO_COMPANIA
 AND PR_DISPONIBILIDAD_RUBRO.VIGENCIA=PR_DISPONIBILIDADES.VIGENCIA
 AND PR_DISPONIBILIDAD_RUBRO.CODIGO_UNIDAD_EJECUTORA=una_unidad
 AND PR_DISPONIBILIDAD_RUBRO.CODIGO_COMPANIA=una_compania
 AND PR_DISPONIBILIDAD_RUBRO.VIGENCIA=una_vigencia
 AND PR_DISPONIBILIDAD_RUBRO.RUBRO_INTERNO=un_rubro
 AND PR_DISPONIBILIDADES.PARA_SUSPENSION = 1
 AND PR_DISPONIBILIDADES.fecha_registro <= una_fecha)
 AND NOT PR_DISPONIBILIDAD_RUBRO.NUMERO_DISPONIBILIDAD IN
 (SELECT numero_disponibilidad
 FROM PR_CONFIRMACION_SUSPENSION
 WHERE  PR_CONFIRMACION_SUSPENSION.vigencia = una_vigencia AND
        PR_CONFIRMACION_SUSPENSION.codigo_compania = una_compania AND
        PR_CONFIRMACION_SUSPENSION.codigo_unidad_ejecutora = una_unidad AND
        PR_DISPONIBILIDAD_RUBRO.rubro_interno = un_rubro  AND
        PR_CONFIRMACION_SUSPENSION.fecha_registro <= una_fecha);


 -- Anulaciones de CDP del mes efectuadas

SELECT NVL(SUM(NVL(PR_DISPONIBILIDAD_RUBRO.VALOR,0)),0) INTO mi_valor_cdp_anulados
FROM PR_DISPONIBILIDAD_RUBRO, PR_DISPONIBILIDADES
WHERE PR_DISPONIBILIDAD_RUBRO.NUMERO_DISPONIBILIDAD=PR_DISPONIBILIDADES.NUMERO_DISPONIBILIDAD
 AND PR_DISPONIBILIDAD_RUBRO.CODIGO_UNIDAD_EJECUTORA=PR_DISPONIBILIDADES.CODIGO_UNIDAD_EJECUTORA
 AND PR_DISPONIBILIDAD_RUBRO.CODIGO_COMPANIA=PR_DISPONIBILIDADES.CODIGO_COMPANIA
 AND PR_DISPONIBILIDAD_RUBRO.VIGENCIA=PR_DISPONIBILIDADES.VIGENCIA
 AND PR_DISPONIBILIDAD_RUBRO.CODIGO_UNIDAD_EJECUTORA=una_unidad
 AND PR_DISPONIBILIDAD_RUBRO.CODIGO_COMPANIA=una_compania
 AND PR_DISPONIBILIDAD_RUBRO.VIGENCIA=una_vigencia
 AND PR_DISPONIBILIDAD_RUBRO.RUBRO_INTERNO=un_rubro
 AND PR_DISPONIBILIDADES.fecha_registro <= una_fecha
 AND PR_DISPONIBILIDADES.PARA_SUSPENSION = 0
 AND PR_DISPONIBILIDADES.NUMERO_DISPONIBILIDAD IN (SELECT numero_documento_anulado
                                                   FROM PR_ANULACIONES
                                                   WHERE vigencia = una_vigencia AND
                                                         codigo_compania = una_compania AND
                                                         codigo_unidad_ejecutora = una_unidad AND
                                                         documento_anulado = 'CDP' AND
                                                         fecha_registro <= una_fecha );



  -- Liberaciones Parciales

  SELECT NVL(SUM(NVL(PR_CDP_ANULADOS.valor_anulado,0)),0) INTO mi_valor_cdp_parciales
  FROM   PR_CDP_ANULADOS
  WHERE  vigencia = una_vigencia AND
         codigo_compania = una_compania AND
         codigo_unidad_ejecutora = una_unidad AND
         rubro_interno = un_rubro AND
         fecha_anulacion <= una_fecha AND
         numero_disponibilidad IN (SELECT numero_disponibilidad
                             FROM PR_DISPONIBILIDADES
                             WHERE vigencia = una_vigencia AND
                                   codigo_compania = una_compania AND
                                   codigo_unidad_ejecutora = una_unidad AND
                                   para_suspension = 0 AND
                                   fecha_registro <= una_fecha);



  SELECT NVL(SUM(NVL(PR_CDP_ANULADOS_AUTORIZADOS.valor_anulado,0)),0) INTO mi_valor_cdp_autorizados
  FROM   PR_CDP_ANULADOS_AUTORIZADOS
  WHERE  vigencia = una_vigencia AND
         codigo_compania = una_compania AND
         codigo_unidad_ejecutora = una_unidad AND
         rubro_interno = un_rubro AND
         fecha_anulacion <= una_fecha AND
         numero_disponibilidad IN (SELECT numero_disponibilidad
                             FROM PR_DISPONIBILIDADES
                             WHERE vigencia = una_vigencia AND
                                   codigo_compania = una_compania AND
                                   codigo_unidad_ejecutora = una_unidad AND
                                   para_suspension = 0 AND
                                   fecha_registro <= una_fecha);

-- Ajustes/Reintegros Acumulados

    SELECT NVL(SUM(NVL(PR_REINTEGRO_AJUSTES_RUBRO.valor,0)),0) INTO mi_valor_ajustes
    FROM PR_REINTEGRO_AJUSTES, PR_REINTEGRO_AJUSTES_RUBRO
    WHERE (PR_REINTEGRO_AJUSTES_RUBRO.consecutivo_ajuste=PR_REINTEGRO_AJUSTES.consecutivo_ajuste AND
           PR_REINTEGRO_AJUSTES_RUBRO.numero_registro=PR_REINTEGRO_AJUSTES.numero_registro AND
           PR_REINTEGRO_AJUSTES_RUBRO.numero_disponibilidad=PR_REINTEGRO_AJUSTES.numero_disponibilidad AND
           PR_REINTEGRO_AJUSTES_RUBRO.consecutivo_orden=PR_REINTEGRO_AJUSTES.consecutivo_orden AND
           PR_REINTEGRO_AJUSTES_RUBRO.numero_orden=PR_REINTEGRO_AJUSTES.numero_orden AND
           PR_REINTEGRO_AJUSTES_RUBRO.codigo_unidad_ejecutora=PR_REINTEGRO_AJUSTES.codigo_unidad_ejecutora AND
           PR_REINTEGRO_AJUSTES_RUBRO.codigo_compania=PR_REINTEGRO_AJUSTES.codigo_compania AND
           PR_REINTEGRO_AJUSTES_RUBRO.vigencia=PR_REINTEGRO_AJUSTES.vigencia) AND
           PR_REINTEGRO_AJUSTES_RUBRO.codigo_compania = una_compania AND
           PR_REINTEGRO_AJUSTES_RUBRO.codigo_unidad_ejecutora = una_unidad AND
           PR_REINTEGRO_AJUSTES_RUBRO.vigencia = una_vigencia AND
           PR_REINTEGRO_AJUSTES_RUBRO.rubro_interno = un_rubro AND
           PR_REINTEGRO_AJUSTES.cerrado = '0' AND
           PR_REINTEGRO_AJUSTES.tipo_movimiento = 'AJUSTE' AND
           PR_REINTEGRO_AJUSTES.fecha_registro <= una_fecha ;


 SELECT NVL(SUM(NVL(PR_REINTEGRO_AJUSTES_RUBRO.valor,0)),0) INTO mi_valor_reintegro
    FROM PR_REINTEGRO_AJUSTES, PR_REINTEGRO_AJUSTES_RUBRO
    WHERE (PR_REINTEGRO_AJUSTES_RUBRO.consecutivo_ajuste=PR_REINTEGRO_AJUSTES.consecutivo_ajuste AND
           PR_REINTEGRO_AJUSTES_RUBRO.numero_registro=PR_REINTEGRO_AJUSTES.numero_registro AND
           PR_REINTEGRO_AJUSTES_RUBRO.numero_disponibilidad=PR_REINTEGRO_AJUSTES.numero_disponibilidad AND
           PR_REINTEGRO_AJUSTES_RUBRO.consecutivo_orden=PR_REINTEGRO_AJUSTES.consecutivo_orden AND
           PR_REINTEGRO_AJUSTES_RUBRO.numero_orden=PR_REINTEGRO_AJUSTES.numero_orden AND
           PR_REINTEGRO_AJUSTES_RUBRO.codigo_unidad_ejecutora=PR_REINTEGRO_AJUSTES.codigo_unidad_ejecutora AND
           PR_REINTEGRO_AJUSTES_RUBRO.codigo_compania=PR_REINTEGRO_AJUSTES.codigo_compania AND
           PR_REINTEGRO_AJUSTES_RUBRO.vigencia=PR_REINTEGRO_AJUSTES.vigencia) AND
           PR_REINTEGRO_AJUSTES_RUBRO.codigo_compania = una_compania AND
           PR_REINTEGRO_AJUSTES_RUBRO.codigo_unidad_ejecutora = una_unidad AND
           PR_REINTEGRO_AJUSTES_RUBRO.vigencia = una_vigencia AND
           PR_REINTEGRO_AJUSTES_RUBRO.rubro_interno = un_rubro AND
           PR_REINTEGRO_AJUSTES.fecha_registro <= una_fecha AND
           PR_REINTEGRO_AJUSTES.tipo_movimiento = 'REINTEGRO';

-- Se agrego enero 10 de 2002 - Se presenta un cdp de suspensin que no se aplico y fue anulado directamente

SELECT NVL(SUM(NVL(PR_DISPONIBILIDAD_RUBRO.VALOR,0)),0)  INTO mi_anulacion_cdp_sus_no_apl
FROM PR_DISPONIBILIDAD_RUBRO, PR_DISPONIBILIDADES
WHERE PR_DISPONIBILIDAD_RUBRO.NUMERO_DISPONIBILIDAD=PR_DISPONIBILIDADES.NUMERO_DISPONIBILIDAD
 AND PR_DISPONIBILIDAD_RUBRO.CODIGO_UNIDAD_EJECUTORA=PR_DISPONIBILIDADES.CODIGO_UNIDAD_EJECUTORA
 AND PR_DISPONIBILIDAD_RUBRO.CODIGO_COMPANIA=PR_DISPONIBILIDADES.CODIGO_COMPANIA
 AND PR_DISPONIBILIDAD_RUBRO.VIGENCIA=PR_DISPONIBILIDADES.VIGENCIA
 AND PR_DISPONIBILIDAD_RUBRO.CODIGO_UNIDAD_EJECUTORA=una_unidad
 AND PR_DISPONIBILIDAD_RUBRO.CODIGO_COMPANIA=una_compania
 AND PR_DISPONIBILIDAD_RUBRO.VIGENCIA=una_vigencia
 AND PR_DISPONIBILIDAD_RUBRO.RUBRO_INTERNO=un_rubro
 AND PR_DISPONIBILIDADES.fecha_registro <= una_fecha
 AND PR_DISPONIBILIDADES.PARA_SUSPENSION = 1
 AND PR_DISPONIBILIDADES.NUMERO_DISPONIBILIDAD IN (SELECT numero_documento_anulado
                                                      FROM PR_ANULACIONES
                                                      WHERE vigencia = una_vigencia AND
                                                            codigo_compania = una_compania AND
                                                            codigo_unidad_ejecutora = una_unidad AND
                                                            documento_anulado = 'CDP' AND
                                                            fecha_registro <= una_fecha)
AND NOT PR_DISPONIBILIDAD_RUBRO.NUMERO_DISPONIBILIDAD IN
 (SELECT numero_disponibilidad
 FROM PR_CONFIRMACION_SUSPENSION
 WHERE  PR_CONFIRMACION_SUSPENSION.vigencia = una_vigencia AND
        PR_CONFIRMACION_SUSPENSION.codigo_compania = una_compania AND
        PR_CONFIRMACION_SUSPENSION.codigo_unidad_ejecutora = una_unidad AND
        PR_DISPONIBILIDAD_RUBRO.rubro_interno = un_rubro  AND
        PR_CONFIRMACION_SUSPENSION.fecha_registro <= una_fecha);


  mi_valor_disponib_total := (NVL(mi_valor_disponibilidades,0)+NVL(mi_valor_cdp_suspension,0))-NVL(mi_valor_cdp_anulados,0)-NVL(mi_valor_cdp_parciales,0)-NVL(mi_valor_cdp_autorizados,0)+NVL(mi_valor_ajustes,0)+NVL(mi_valor_reintegro,0)-NVL(mi_anulacion_cdp_sus_no_apl,0);

  RETURN NVL(mi_valor_disponib_total,0);


END fn_pre_disponibilidades;



/***********************************************************************************************
 Funcion: fn_pre_totcdp_detalle
 Descripcion: Calcula el total de disponibilidades  para un rubro , para una fuente de
              financiacion
 Entradas: VIGENCIA, RUBRO_INTERNO, CODIGO_COMPANIA, CODIGO_UNIDAD_EJECUTORA,
 Salidas :
 Fecha             Noviembre   2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_totcdp_detalle (una_vigencia NUMBER,
                                una_compania VARCHAR2,
								una_unidad   VARCHAR2,
								una_fecha    DATE,
								un_rubro     NUMBER,
								una_fuente   VARCHAR2,
								un_detalle   NUMBER )
                                RETURN NUMBER IS

 mi_valor_disponib_total        NUMBER;
 mi_valor_disponibilidades      NUMBER;
 mi_valor_cdp_anulados          NUMBER;
 mi_valor_cdp_parciales         NUMBER;
 mi_valor_cdp_autorizados       NUMBER;
 mi_valor_ajustes               NUMBER;
 mi_valor_reintegro             NUMBER;
 mi_valor_cdp_suspension		NUMBER;
 mi_anulacion_cdp_sus_no_apl    NUMBER;
BEGIN


  mi_valor_cdp_autorizados    := 0;
  mi_valor_cdp_anulados       := 0;
  mi_valor_cdp_parciales      := 0;
  mi_valor_disponib_total     := 0;
  mi_valor_disponibilidades   := 0;
  mi_valor_ajustes            := 0;
  mi_valor_reintegro          := 0;
  mi_valor_cdp_suspension     := 0;
  mi_anulacion_cdp_sus_no_apl := 0;

  -- Calcula el Valor Total de Disponibilidades

SELECT NVL(SUM(NVL(PR_DETALLE_FUENTES_CDP.VALOR,0)),0) INTO mi_valor_disponibilidades
FROM PR_DISPONIBILIDAD_RUBRO,
     PR_DISPONIBILIDADES,
	 PR_DETALLE_FUENTES_CDP
WHERE (PR_DETALLE_FUENTES_CDP.vigencia=PR_DISPONIBILIDAD_RUBRO.vigencia
 AND  PR_DETALLE_FUENTES_CDP.rubro_interno=PR_DISPONIBILIDAD_RUBRO.rubro_interno
 AND  PR_DETALLE_FUENTES_CDP.codigo_compania=PR_DISPONIBILIDAD_RUBRO.codigo_compania
 AND  PR_DETALLE_FUENTES_CDP.codigo_unidad_ejecutora=PR_DISPONIBILIDAD_RUBRO.codigo_unidad_ejecutora
 AND  PR_DETALLE_FUENTES_CDP.numero_disponibilidad=PR_DISPONIBILIDAD_RUBRO.numero_disponibilidad)
 AND (PR_DISPONIBILIDAD_RUBRO.NUMERO_DISPONIBILIDAD=PR_DISPONIBILIDADES.NUMERO_DISPONIBILIDAD
 AND PR_DISPONIBILIDAD_RUBRO.CODIGO_UNIDAD_EJECUTORA=PR_DISPONIBILIDADES.CODIGO_UNIDAD_EJECUTORA
 AND PR_DISPONIBILIDAD_RUBRO.CODIGO_COMPANIA=PR_DISPONIBILIDADES.CODIGO_COMPANIA
 AND PR_DISPONIBILIDAD_RUBRO.VIGENCIA=PR_DISPONIBILIDADES.VIGENCIA
 AND PR_DISPONIBILIDAD_RUBRO.CODIGO_UNIDAD_EJECUTORA=una_unidad
 AND PR_DISPONIBILIDAD_RUBRO.CODIGO_COMPANIA=una_compania
 AND PR_DISPONIBILIDAD_RUBRO.VIGENCIA=una_vigencia
 AND PR_DISPONIBILIDAD_RUBRO.RUBRO_INTERNO=un_rubro
 AND PR_DISPONIBILIDADES.fecha_registro <= una_fecha
 AND PR_DETALLE_FUENTES_CDP.codigo_fuente=una_fuente
 AND PR_DETALLE_FUENTES_CDP.codigo_det_fuente_financ=un_detalle
 AND PR_DISPONIBILIDADES.PARA_SUSPENSION = 0);

-- Inicio Se inlcuye a julio 2001

-- Calcula el Valor Total de Disponibilidades del Mes DE SUSPENSION QUE NO SE HAN APLICADO

SELECT NVL(SUM(NVL(PR_DETALLE_FUENTES_CDP.VALOR,0)),0) INTO mi_valor_cdp_suspension
FROM PR_DISPONIBILIDAD_RUBRO,
     PR_DISPONIBILIDADES,
	 PR_DETALLE_FUENTES_CDP
WHERE (PR_DETALLE_FUENTES_CDP.vigencia=PR_DISPONIBILIDAD_RUBRO.vigencia
 AND  PR_DETALLE_FUENTES_CDP.rubro_interno=PR_DISPONIBILIDAD_RUBRO.rubro_interno
 AND  PR_DETALLE_FUENTES_CDP.codigo_compania=PR_DISPONIBILIDAD_RUBRO.codigo_compania
 AND  PR_DETALLE_FUENTES_CDP.codigo_unidad_ejecutora=PR_DISPONIBILIDAD_RUBRO.codigo_unidad_ejecutora
 AND  PR_DETALLE_FUENTES_CDP.numero_disponibilidad=PR_DISPONIBILIDAD_RUBRO.numero_disponibilidad)
 AND (PR_DISPONIBILIDAD_RUBRO.NUMERO_DISPONIBILIDAD=PR_DISPONIBILIDADES.NUMERO_DISPONIBILIDAD
 AND PR_DISPONIBILIDAD_RUBRO.CODIGO_UNIDAD_EJECUTORA=PR_DISPONIBILIDADES.CODIGO_UNIDAD_EJECUTORA
 AND PR_DISPONIBILIDAD_RUBRO.CODIGO_COMPANIA=PR_DISPONIBILIDADES.CODIGO_COMPANIA
 AND PR_DISPONIBILIDAD_RUBRO.VIGENCIA=PR_DISPONIBILIDADES.VIGENCIA
 AND PR_DISPONIBILIDAD_RUBRO.CODIGO_UNIDAD_EJECUTORA=una_unidad
 AND PR_DISPONIBILIDAD_RUBRO.CODIGO_COMPANIA=una_compania
 AND PR_DISPONIBILIDAD_RUBRO.VIGENCIA=una_vigencia
 AND PR_DISPONIBILIDAD_RUBRO.RUBRO_INTERNO=un_rubro
 AND PR_DISPONIBILIDADES.PARA_SUSPENSION = 1
 AND PR_DISPONIBILIDADES.fecha_registro <= una_fecha)
 AND PR_DETALLE_FUENTES_CDP.codigo_fuente=una_fuente
 AND PR_DETALLE_FUENTES_CDP.codigo_det_fuente_financ=un_detalle
 AND NOT PR_DISPONIBILIDAD_RUBRO.NUMERO_DISPONIBILIDAD IN
   (SELECT numero_disponibilidad
    FROM PR_CONFIRMACION_SUSPENSION
    WHERE  PR_CONFIRMACION_SUSPENSION.vigencia = una_vigencia AND
        PR_CONFIRMACION_SUSPENSION.codigo_compania = una_compania AND
        PR_CONFIRMACION_SUSPENSION.codigo_unidad_ejecutora = una_unidad AND
        PR_DISPONIBILIDAD_RUBRO.rubro_interno = un_rubro  AND
        PR_CONFIRMACION_SUSPENSION.fecha_registro <= una_fecha);

 -- Anulaciones de CDP del mes efectuadas

SELECT NVL(SUM(NVL(PR_DETALLE_FUENTES_CDP.VALOR,0)),0) INTO mi_valor_cdp_anulados
FROM PR_DISPONIBILIDAD_RUBRO, PR_DISPONIBILIDADES, PR_DETALLE_FUENTES_CDP
WHERE (PR_DETALLE_FUENTES_CDP.vigencia=PR_DISPONIBILIDAD_RUBRO.vigencia
 AND  PR_DETALLE_FUENTES_CDP.rubro_interno=PR_DISPONIBILIDAD_RUBRO.rubro_interno
 AND  PR_DETALLE_FUENTES_CDP.codigo_compania=PR_DISPONIBILIDAD_RUBRO.codigo_compania
 AND  PR_DETALLE_FUENTES_CDP.codigo_unidad_ejecutora=PR_DISPONIBILIDAD_RUBRO.codigo_unidad_ejecutora
 AND  PR_DETALLE_FUENTES_CDP.numero_disponibilidad=PR_DISPONIBILIDAD_RUBRO.numero_disponibilidad)
 AND PR_DISPONIBILIDAD_RUBRO.NUMERO_DISPONIBILIDAD=PR_DISPONIBILIDADES.NUMERO_DISPONIBILIDAD
 AND PR_DISPONIBILIDAD_RUBRO.CODIGO_UNIDAD_EJECUTORA=PR_DISPONIBILIDADES.CODIGO_UNIDAD_EJECUTORA
 AND PR_DISPONIBILIDAD_RUBRO.CODIGO_COMPANIA=PR_DISPONIBILIDADES.CODIGO_COMPANIA
 AND PR_DISPONIBILIDAD_RUBRO.VIGENCIA=PR_DISPONIBILIDADES.VIGENCIA
 AND PR_DISPONIBILIDAD_RUBRO.CODIGO_UNIDAD_EJECUTORA=una_unidad
 AND PR_DISPONIBILIDAD_RUBRO.CODIGO_COMPANIA=una_compania
 AND PR_DISPONIBILIDAD_RUBRO.VIGENCIA=una_vigencia
 AND PR_DISPONIBILIDAD_RUBRO.RUBRO_INTERNO=un_rubro
 AND PR_DISPONIBILIDADES.fecha_registro <= una_fecha
 AND PR_DETALLE_FUENTES_CDP.codigo_fuente=una_fuente
 AND PR_DETALLE_FUENTES_CDP.codigo_det_fuente_financ=un_detalle
 AND PR_DISPONIBILIDADES.PARA_SUSPENSION = 0
 AND PR_DISPONIBILIDADES.NUMERO_DISPONIBILIDAD IN (SELECT numero_documento_anulado
                                                   FROM PR_ANULACIONES
                                                   WHERE vigencia = una_vigencia AND
                                                         codigo_compania = una_compania AND
                                                         codigo_unidad_ejecutora = una_unidad AND
                                                         documento_anulado = 'CDP' AND
                                                         fecha_registro <= una_fecha );



  -- Liberaciones Parciales

  SELECT NVL(SUM(NVL(b.valor_anulado,0)),0) INTO mi_valor_cdp_parciales
  FROM   PR_CDP_ANULADOS a,
         PR_ANULA_DETALLE_CDP b
  WHERE  a.vigencia = b.vigencia AND
         a.rubro_interno = b.rubro_interno AND
		 a.codigo_compania = b.codigo_compania AND
         a.codigo_unidad_ejecutora = b.codigo_unidad_ejecutora AND
         a.numero_disponibilidad =b.numero_disponibilidad AND
         a.consecutivo_anulacion =b.consecutivo_anulacion AND
         a.vigencia = una_vigencia AND
         a.codigo_compania = una_compania AND
         a.codigo_unidad_ejecutora = una_unidad AND
         a.rubro_interno = un_rubro AND
		 b.codigo_fuente=una_fuente AND
         b.codigo_det_fuente_financ=un_detalle AND
         a.fecha_anulacion <= una_fecha AND
         a.numero_disponibilidad IN (SELECT numero_disponibilidad
                                     FROM PR_DISPONIBILIDADES
                                     WHERE vigencia = una_vigencia AND
                                          codigo_compania = una_compania AND
                                          codigo_unidad_ejecutora = una_unidad AND
                                          para_suspension = 0 AND
                                          fecha_registro <= una_fecha);

  SELECT NVL(SUM(NVL(b.valor_anulado,0)),0) INTO mi_valor_cdp_autorizados
  FROM   PR_CDP_ANULADOS_AUTORIZADOS a,
         PR_CDP_ANULA_AUTORIZA_DETALLE b
  WHERE  a.vigencia = b.vigencia AND
         a.rubro_interno = b.rubro_interno AND
		 a.codigo_compania = b.codigo_compania AND
         a.codigo_unidad_ejecutora = b.codigo_unidad_ejecutora AND
         a.numero_disponibilidad =b.numero_disponibilidad AND
         a.consecutivo_anulacion =b.consecutivo_anulacion AND
         a.vigencia = una_vigencia AND
         a.codigo_compania = una_compania AND
         a.codigo_unidad_ejecutora = una_unidad AND
         a.rubro_interno = un_rubro AND
 		 b.codigo_fuente=una_fuente AND
         b.codigo_det_fuente_financ=un_detalle AND
         a.fecha_anulacion <= una_fecha AND
         a.numero_disponibilidad IN (SELECT numero_disponibilidad
                                     FROM PR_DISPONIBILIDADES
                                     WHERE vigencia = una_vigencia AND
                                           codigo_compania = una_compania AND
                                           codigo_unidad_ejecutora = una_unidad AND
                                           para_suspension = 0 AND
                                           fecha_registro <= una_fecha);
-- Ajustes/Reintegros Acumulados

    SELECT NVL(SUM(NVL(PR_DETALLE_FUENTES_AJUSTES.valor,0)),0) INTO mi_valor_ajustes
    FROM PR_REINTEGRO_AJUSTES,
	     PR_REINTEGRO_AJUSTES_RUBRO,
		 PR_DETALLE_FUENTES_AJUSTES
    WHERE (PR_DETALLE_FUENTES_AJUSTES.vigencia=PR_REINTEGRO_AJUSTES_RUBRO.vigencia AND
	       PR_DETALLE_FUENTES_AJUSTES.rubro_interno=PR_REINTEGRO_AJUSTES_RUBRO.rubro_interno  AND
		   PR_DETALLE_FUENTES_AJUSTES.codigo_compania=PR_REINTEGRO_AJUSTES_RUBRO.codigo_compania AND
		   PR_DETALLE_FUENTES_AJUSTES.codigo_unidad_ejecutora=PR_REINTEGRO_AJUSTES_RUBRO.codigo_unidad_ejecutora AND
		   PR_DETALLE_FUENTES_AJUSTES.numero_disponibilidad=PR_REINTEGRO_AJUSTES_RUBRO.numero_disponibilidad AND
		   PR_DETALLE_FUENTES_AJUSTES.numero_orden=PR_REINTEGRO_AJUSTES_RUBRO.numero_orden AND
		   PR_DETALLE_FUENTES_AJUSTES.numero_registro=PR_REINTEGRO_AJUSTES_RUBRO.numero_registro AND
		   PR_DETALLE_FUENTES_AJUSTES.consecutivo_orden=PR_REINTEGRO_AJUSTES_RUBRO.consecutivo_orden AND
		   PR_DETALLE_FUENTES_AJUSTES.consecutivo_ajuste=PR_REINTEGRO_AJUSTES_RUBRO.consecutivo_ajuste) AND
		   (PR_REINTEGRO_AJUSTES_RUBRO.consecutivo_ajuste=PR_REINTEGRO_AJUSTES.consecutivo_ajuste AND
           PR_REINTEGRO_AJUSTES_RUBRO.numero_registro=PR_REINTEGRO_AJUSTES.numero_registro AND
           PR_REINTEGRO_AJUSTES_RUBRO.numero_disponibilidad=PR_REINTEGRO_AJUSTES.numero_disponibilidad AND
           PR_REINTEGRO_AJUSTES_RUBRO.consecutivo_orden=PR_REINTEGRO_AJUSTES.consecutivo_orden AND
           PR_REINTEGRO_AJUSTES_RUBRO.numero_orden=PR_REINTEGRO_AJUSTES.numero_orden AND
           PR_REINTEGRO_AJUSTES_RUBRO.codigo_unidad_ejecutora=PR_REINTEGRO_AJUSTES.codigo_unidad_ejecutora AND
           PR_REINTEGRO_AJUSTES_RUBRO.codigo_compania=PR_REINTEGRO_AJUSTES.codigo_compania AND
           PR_REINTEGRO_AJUSTES_RUBRO.vigencia=PR_REINTEGRO_AJUSTES.vigencia) AND
           PR_REINTEGRO_AJUSTES_RUBRO.codigo_compania = una_compania AND
           PR_REINTEGRO_AJUSTES_RUBRO.codigo_unidad_ejecutora = una_unidad AND
           PR_REINTEGRO_AJUSTES_RUBRO.vigencia = una_vigencia AND
           PR_REINTEGRO_AJUSTES_RUBRO.rubro_interno = un_rubro AND
           PR_REINTEGRO_AJUSTES.cerrado = '0' AND
           PR_REINTEGRO_AJUSTES.tipo_movimiento = 'AJUSTE' AND
           PR_REINTEGRO_AJUSTES.fecha_registro <= una_fecha	AND
		   PR_DETALLE_FUENTES_AJUSTES.codigo_fuente=una_fuente AND
           PR_DETALLE_FUENTES_AJUSTES.codigo_det_fuente_financ=un_detalle;


 SELECT NVL(SUM(NVL(PR_DETALLE_FUENTES_REINT.valor,0)),0) INTO mi_valor_reintegro
    FROM PR_REINTEGRO_AJUSTES, PR_REINTEGRO_AJUSTES_RUBRO, PR_DETALLE_FUENTES_REINT
    WHERE (PR_DETALLE_FUENTES_REINT.vigencia=PR_REINTEGRO_AJUSTES_RUBRO.vigencia AND
	       PR_DETALLE_FUENTES_REINT.rubro_interno=PR_REINTEGRO_AJUSTES_RUBRO.rubro_interno  AND
		   PR_DETALLE_FUENTES_REINT.codigo_compania=PR_REINTEGRO_AJUSTES_RUBRO.codigo_compania AND
		   PR_DETALLE_FUENTES_REINT.codigo_unidad_ejecutora=PR_REINTEGRO_AJUSTES_RUBRO.codigo_unidad_ejecutora AND
		   PR_DETALLE_FUENTES_REINT.numero_disponibilidad=PR_REINTEGRO_AJUSTES_RUBRO.numero_disponibilidad AND
		   PR_DETALLE_FUENTES_REINT.numero_orden=PR_REINTEGRO_AJUSTES_RUBRO.numero_orden AND
		   PR_DETALLE_FUENTES_REINT.numero_registro=PR_REINTEGRO_AJUSTES_RUBRO.numero_registro AND
		   PR_DETALLE_FUENTES_REINT.consecutivo_orden=PR_REINTEGRO_AJUSTES_RUBRO.consecutivo_orden AND
		   PR_DETALLE_FUENTES_REINT.consecutivo_ajuste=PR_REINTEGRO_AJUSTES_RUBRO.consecutivo_ajuste) AND
	      (PR_REINTEGRO_AJUSTES_RUBRO.consecutivo_ajuste=PR_REINTEGRO_AJUSTES.consecutivo_ajuste AND
           PR_REINTEGRO_AJUSTES_RUBRO.numero_registro=PR_REINTEGRO_AJUSTES.numero_registro AND
           PR_REINTEGRO_AJUSTES_RUBRO.numero_disponibilidad=PR_REINTEGRO_AJUSTES.numero_disponibilidad AND
           PR_REINTEGRO_AJUSTES_RUBRO.consecutivo_orden=PR_REINTEGRO_AJUSTES.consecutivo_orden AND
           PR_REINTEGRO_AJUSTES_RUBRO.numero_orden=PR_REINTEGRO_AJUSTES.numero_orden AND
           PR_REINTEGRO_AJUSTES_RUBRO.codigo_unidad_ejecutora=PR_REINTEGRO_AJUSTES.codigo_unidad_ejecutora AND
           PR_REINTEGRO_AJUSTES_RUBRO.codigo_compania=PR_REINTEGRO_AJUSTES.codigo_compania AND
           PR_REINTEGRO_AJUSTES_RUBRO.vigencia=PR_REINTEGRO_AJUSTES.vigencia) AND
           PR_REINTEGRO_AJUSTES_RUBRO.codigo_compania = una_compania AND
           PR_REINTEGRO_AJUSTES_RUBRO.codigo_unidad_ejecutora = una_unidad AND
           PR_REINTEGRO_AJUSTES_RUBRO.vigencia = una_vigencia AND
           PR_REINTEGRO_AJUSTES_RUBRO.rubro_interno = un_rubro AND
           PR_REINTEGRO_AJUSTES.fecha_registro <= una_fecha AND
           PR_REINTEGRO_AJUSTES.tipo_movimiento = 'REINTEGRO' AND
   		   PR_DETALLE_FUENTES_REINT.codigo_fuente=una_fuente AND
           PR_DETALLE_FUENTES_REINT.codigo_det_fuente_financ=un_detalle;

-- Se agrego enero 10 de 2002 - Se presenta un cdp de suspensin que no se aplico y fue anulado directamente

SELECT NVL(SUM(NVL(PR_DETALLE_FUENTES_CDP.VALOR,0)),0)  INTO mi_anulacion_cdp_sus_no_apl
FROM PR_DISPONIBILIDAD_RUBRO, PR_DISPONIBILIDADES, PR_DETALLE_FUENTES_CDP
WHERE(PR_DETALLE_FUENTES_CDP.vigencia=PR_DISPONIBILIDAD_RUBRO.vigencia
 AND  PR_DETALLE_FUENTES_CDP.rubro_interno=PR_DISPONIBILIDAD_RUBRO.rubro_interno
 AND  PR_DETALLE_FUENTES_CDP.codigo_compania=PR_DISPONIBILIDAD_RUBRO.codigo_compania
 AND  PR_DETALLE_FUENTES_CDP.codigo_unidad_ejecutora=PR_DISPONIBILIDAD_RUBRO.codigo_unidad_ejecutora
 AND  PR_DETALLE_FUENTES_CDP.numero_disponibilidad=PR_DISPONIBILIDAD_RUBRO.numero_disponibilidad)
 AND  PR_DISPONIBILIDAD_RUBRO.NUMERO_DISPONIBILIDAD=PR_DISPONIBILIDADES.NUMERO_DISPONIBILIDAD
 AND PR_DISPONIBILIDAD_RUBRO.CODIGO_UNIDAD_EJECUTORA=PR_DISPONIBILIDADES.CODIGO_UNIDAD_EJECUTORA
 AND PR_DISPONIBILIDAD_RUBRO.CODIGO_COMPANIA=PR_DISPONIBILIDADES.CODIGO_COMPANIA
 AND PR_DISPONIBILIDAD_RUBRO.VIGENCIA=PR_DISPONIBILIDADES.VIGENCIA
 AND PR_DISPONIBILIDAD_RUBRO.CODIGO_UNIDAD_EJECUTORA=una_unidad
 AND PR_DISPONIBILIDAD_RUBRO.CODIGO_COMPANIA=una_compania
 AND PR_DISPONIBILIDAD_RUBRO.VIGENCIA=una_vigencia
 AND PR_DISPONIBILIDAD_RUBRO.RUBRO_INTERNO=un_rubro
 AND PR_DISPONIBILIDADES.fecha_registro <= una_fecha
 AND PR_DETALLE_FUENTES_CDP.codigo_fuente=una_fuente
 AND PR_DETALLE_FUENTES_CDP.codigo_det_fuente_financ=un_detalle
 AND PR_DISPONIBILIDADES.PARA_SUSPENSION = 1
 AND PR_DISPONIBILIDADES.NUMERO_DISPONIBILIDAD IN (SELECT numero_documento_anulado
                                                   FROM PR_ANULACIONES
                                                   WHERE vigencia = una_vigencia AND
                                                         codigo_compania = una_compania AND
                                                         codigo_unidad_ejecutora = una_unidad AND
                                                         documento_anulado = 'CDP' AND
                                                         fecha_registro <= una_fecha)
AND NOT PR_DISPONIBILIDAD_RUBRO.NUMERO_DISPONIBILIDAD IN
 (SELECT numero_disponibilidad
 FROM PR_CONFIRMACION_SUSPENSION
 WHERE  PR_CONFIRMACION_SUSPENSION.vigencia = una_vigencia AND
        PR_CONFIRMACION_SUSPENSION.codigo_compania = una_compania AND
        PR_CONFIRMACION_SUSPENSION.codigo_unidad_ejecutora = una_unidad AND
        PR_DISPONIBILIDAD_RUBRO.rubro_interno = un_rubro  AND
        PR_CONFIRMACION_SUSPENSION.fecha_registro <= una_fecha);


  mi_valor_disponib_total := (NVL(mi_valor_disponibilidades,0)+NVL(mi_valor_cdp_suspension,0))-NVL(mi_valor_cdp_anulados,0)-NVL(mi_valor_cdp_parciales,0)-NVL(mi_valor_cdp_autorizados,0)+NVL(mi_valor_ajustes,0)+NVL(mi_valor_reintegro,0)-NVL(mi_anulacion_cdp_sus_no_apl,0);

  RETURN NVL(mi_valor_disponib_total,0);


END fn_pre_totcdp_detalle;


 /***********************************************************************************************
 Funcion: fn_pre_saldo_apropiacion
 Descripcion: Calcula el a?saldo de apropiacion para un rubro
 Entradas: VIGENCIA, RUBRO_INTERNO, CODIGO_COMPANIA, CODIGO_UNIDAD_EJECUTORA,
 Salidas :
 Fecha             Noviembre   2004
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_saldo_apropiacion (una_vigencia NUMBER,
                                   una_compania VARCHAR2,
								   una_unidad   VARCHAR2,
								   una_fecha    DATE,
								   un_rubro     NUMBER )
                                   RETURN NUMBER IS


  mi_apropiacion_vigente     NUMBER;
  mi_suspensiones            NUMBER;
  mi_apropiacion_disponible  NUMBER;
  mi_apropiacion_inicial     NUMBER;
  mi_saldo_apropiacion       NUMBER;
  mi_total_disponibilidades  NUMBER;


BEGIN

  mi_apropiacion_inicial:= NVL(Pk_Pr_Detalle_Fuentes.fn_pre_apropiacion_inicial
                                              (una_vigencia,
                                               una_compania,
								               una_unidad,
								               un_rubro),0);

  mi_apropiacion_vigente := NVL(Pk_Pr_Consolidados_Gastos.fn_pre_apr_vigente_fc
                                                   (una_vigencia,
                                                    una_compania,
							                        una_unidad,
                 								    una_fecha,
                    								un_rubro,
													mi_apropiacion_inicial),0);


  mi_suspensiones:= NVL(Pk_Pr_Consolidados_Gastos.fn_pre_ValorSusp_Acum_fc
                                           (una_vigencia,
                                            una_compania,
							                una_unidad,
                 							una_fecha,
                    						un_rubro),0);

  mi_apropiacion_disponible := NVL(mi_apropiacion_vigente,0)- NVL(mi_suspensiones,0);


  mi_total_disponibilidades :=NVL(Pk_Pr_Detalle_Fuentes.fn_pre_disponibilidades
                                           (una_vigencia,
                                            una_compania,
							                una_unidad,
                 							una_fecha,
                    						un_rubro),0);


   mi_saldo_apropiacion := NVL(mi_apropiacion_disponible,0)-NVL(mi_total_disponibilidades,0);

   RETURN NVL(mi_saldo_apropiacion,0);

  EXCEPTION

  WHEN NO_DATA_FOUND THEN
      RETURN 0;

END fn_pre_saldo_apropiacion;



/***********************************************************************************************
 Funcion: fn_pre_apropiacion_dis
 Descripcion: Calcula apropiacion disponible para un rubro
               parte del requerimiento RQ160
 Entradas: VIGENCIA, RUBRO_INTERNO, CODIGO_COMPANIA, CODIGO_UNIDAD_EJECUTORA,
 Salidas :
 Fecha
 Responsable    :  Gloria I. Avila Ni?o

 Modificaciones :  Marzo de 2005
 Fecha          :
 Responsable    :
 Descripcion    :

***********************************************************************************************/

FUNCTION fn_pre_apropiacion_dis (una_vigencia NUMBER,
                                 una_compania VARCHAR2,
								 una_unidad   VARCHAR2,
								 una_fecha    DATE,
								 un_rubro     NUMBER )
                                 RETURN NUMBER IS


  mi_apropiacion_vigente     NUMBER;
  mi_suspensiones            NUMBER;
  mi_apropiacion_disponible  NUMBER;
  mi_apropiacion_inicial     NUMBER;
  mi_saldo_apropiacion       NUMBER;
  mi_total_disponibilidades  NUMBER;


BEGIN

  mi_apropiacion_inicial:= NVL(Pk_Pr_Detalle_Fuentes.fn_pre_apropiacion_inicial
                                              (una_vigencia,
                                               una_compania,
								               una_unidad,
								               un_rubro),0);

 mi_apropiacion_vigente := NVL(Pk_Pr_Consolidados_Gastos.fn_pre_apr_vigente_fc
                                                   (una_vigencia,
                                                    una_compania,
							                        una_unidad,
                 								    una_fecha,
                    								un_rubro,
													mi_apropiacion_inicial),0);


  mi_suspensiones:= NVL(Pk_Pr_Consolidados_Gastos.fn_pre_ValorSusp_Acum_fc
                                           (una_vigencia,
                                            una_compania,
							                una_unidad,
                 							una_fecha,
                    						un_rubro),0);

  mi_apropiacion_disponible := NVL(mi_apropiacion_vigente,0)- NVL(mi_suspensiones,0);



   RETURN NVL(mi_apropiacion_disponible ,0);

  EXCEPTION

  WHEN NO_DATA_FOUND THEN
      RETURN 0;

END fn_pre_apropiacion_dis;



END Pk_Pr_Detalle_Fuentes;