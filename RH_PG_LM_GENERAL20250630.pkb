create or replace PACKAGE BODY RH_PG_LM_GENERAL AS

  -- Devuelve el valor del campo resultado de BINTABLAS para los parametros suministrados
  FUNCTION T_Buscar(Argumento VARCHAR2, Grupo VARCHAR2, Nombre VARCHAR2, Vigencia VARCHAR2)
  RETURN VARCHAR2 IS

    tResultado	BinTablas.Resultado%TYPE;
    fVigencia		DATE;

    CURSOR CResulBinTab (Var_Argumento Varchar2
                        ,Var_Grupo     Varchar2
                        ,Var_Nombre    Varchar2
                        ,Var_Vigencia  DATE) IS
      SELECT Resultado
        FROM BinTablas
	 WHERE Grupo       = Var_Grupo
         AND Nombre      = Var_Nombre
         AND Argumento   = Var_Argumento
         AND Vig_Inicial <=Var_Vigencia
         AND (Vig_Final  >=Var_Vigencia OR Vig_final IS NULL);

  BEGIN
    tResultado := NULL;
    fVigencia := TO_DATE(Vigencia, 'dd/mm/yyyy');
    OPEN CResulBinTab(Argumento, Grupo, Nombre, fVigencia);
    FETCH CResulBinTab INTO tResultado;
    CLOSE CResulBinTab;
    Return tResultado;
  END T_Buscar;

  --Asocia el id de Terceros utilizando la tabla rh_terceros
  FUNCTION fn_asociar_tercero (una_asociacion   VARCHAR2,
                               un_tipo          VARCHAR2,
                               un_funcionario   NUMBER,
                               mi_mensaje_err   OUT VARCHAR2) RETURN NUMBER IS

    --Tipo es F para el funcionario,  P para pension,  A para ARP,
    --S para salud,   B para beneficiario,  C para cesantias
    mi_tercero    NUMBER:=0;
    mi_caja       rh_terceros.entidad_codigo%TYPE;

  BEGIN
    mi_mensaje_err:=NULL;
    IF un_tipo = 'F' THEN
  	 BEGIN
  	   SELECT id_tercero INTO mi_tercero
  	     FROM rh_terceros
  	   WHERE  esquema  = 'RH'
  	     AND  personas = un_funcionario;
  	 EXCEPTION
         WHEN NO_DATA_FOUND THEN
           mi_mensaje_err:='No se encuentra el tercero asociado para el funcionario ' || un_funcionario;
           RETURN 0;
	   WHEN OTHERS THEN
           mi_mensaje_err:='No se encuentra el tercero asociado para el funcionario ' || un_funcionario || SQLERRM;
           RETURN 0;
  	 END;
    ELSIF un_tipo = 'B' THEN
  	 BEGIN
  	   SELECT id_tercero INTO mi_tercero
  	     FROM rh_terceros
  	    WHERE esquema       = 'RH'
  	      AND beneficiarios = una_asociacion;
  	 EXCEPTION
  	   WHEN NO_DATA_FOUND THEN
           mi_mensaje_err:='No se encuentra el tercero asociado para el beneficiario ' || una_asociacion;
           RETURN 0;
	   WHEN OTHERS THEN
           mi_mensaje_err:='No se encuentra el tercero asociado para el beneficiario ' || una_asociacion || SQLERRM;
           RETURN 0;
       END;
    -- RQ1718-2006	31/10/2006
    /*
    ELSE un_tipo = 'A' THEN
  	 BEGIN
  	   SELECT id_tercero INTO mi_tercero
  	     FROM rh_terceros
  	    WHERE esquema        = 'RH'
            AND entidad_tipo   = 'ARP'
            AND entidad_codigo = una_asociacion;
  	 EXCEPTION
  	   WHEN NO_DATA_FOUND THEN
           mi_mensaje_err:='No se encuentra el tercero asociado para la ARP ' || una_asociacion || ' del funcionario ' || un_funcionario;
           RETURN 0;
	   WHEN OTHERS THEN
           mi_mensaje_err:='No se encuentra el tercero asociado para la ARP ' || una_asociacion || ' del funcionario ' || un_funcionario || SQLERRM;
           RETURN 0;
       END;
    ELSIF un_tipo = 'P' THEN
  	 BEGIN
  	   SELECT id_tercero INTO mi_tercero
  	     FROM rh_terceros
  	    WHERE esquema        = 'RH'
            AND entidad_tipo   = 'FONDO_PENSIONES'
            AND entidad_codigo = una_asociacion;
  	 EXCEPTION
  	   WHEN NO_DATA_FOUND THEN
           mi_mensaje_err:='No se encuentra el tercero asociado para el fondo de Pensiones ' || una_asociacion || ' del funcionario ' || un_funcionario;
           RETURN 0;
	   WHEN OTHERS THEN
           mi_mensaje_err:='No se encuentra el tercero asociado para el fondo de Pensiones ' || una_asociacion || ' del funcionario ' || un_funcionario || SQLERRM;
           RETURN 0;
       END;
    ELSIF un_tipo = 'S' THEN
  	 BEGIN
  	   SELECT id_tercero INTO mi_tercero
  	     FROM rh_terceros
  	    WHERE esquema        = 'RH'
            AND entidad_tipo   = 'EPS'
            AND entidad_codigo = una_asociacion;
  	 EXCEPTION
  	   WHEN NO_DATA_FOUND THEN
           mi_mensaje_err:='No se encuentra el tercero asociado para la EPS ' || una_asociacion || ' del funcionario ' || un_funcionario;
           RETURN 0;
	   WHEN OTHERS THEN
           mi_mensaje_err:='No se encuentra el tercero asociado para la EPS ' || una_asociacion || ' del funcionario ' || un_funcionario || SQLERRM;
           RETURN 0;
  	 END;
    ELSIF un_tipo = 'C' THEN
  	 BEGIN
  	   SELECT id_tercero INTO mi_tercero
  	     FROM rh_terceros
  	    WHERE esquema        = 'RH'
            AND entidad_tipo   = 'FONDO_CESANTIAS'
            AND entidad_codigo = una_asociacion;
  	 EXCEPTION
  	   WHEN NO_DATA_FOUND THEN
           mi_mensaje_err:='No se encuentra el tercero asociado para el fondo de Cesantias ' || una_asociacion || ' del funcionario ' || un_funcionario;
           RETURN 0;
	   WHEN OTHERS THEN
           mi_mensaje_err:='No se encuentra el tercero asociado para el fondo de Cesantias ' || una_asociacion || ' del funcionario ' || un_funcionario;
           RETURN 0;
       END;
    */
    ELSE
  	BEGIN
  	  SELECT id_tercero INTO mi_tercero
  	    FROM rh_terceros
  	   WHERE esquema        = 'RH'
             AND entidad_tipo   = un_tipo
            AND entidad_codigo = una_asociacion;
  	 EXCEPTION
  	   WHEN NO_DATA_FOUND THEN
           mi_mensaje_err:='No se encuentra el tercero asociado para la entidad ' || un_tipo || ': ' || una_asociacion || ' del funcionario ' || un_funcionario;
           RETURN 0;
	   WHEN OTHERS THEN
           mi_mensaje_err:='No se encuentra el tercero asociado para la entidad ' || un_tipo || ': '  || una_asociacion || ' del funcionario ' || un_funcionario || SQLERRM;
           RETURN 0;
  	 END;
    END IF;
    -- Fin rq1718-2006
    RETURN mi_tercero;
  END fn_asociar_tercero;

  /**************************************************************************************
  Funcion               : fn_tercero_favidi
  Parametros de Entrada : fecha
  Parametros de Salida  : numerico, id de tercero
  Descripcion           : Devuelve el tercero de favidi, tomando el parametro de favidi
  regimen antiguo parametrizado en bintablas y correspondiente a rh_entidad
  ***************************************************************************************/
  FUNCTION FN_TERCERO_FAVIDI (una_fecha     DATE,
                              mi_mensaje_err OUT VARCHAR2) RETURN NUMBER IS

    mi_tercero_favidi   NUMBER;
    mi_codigo_favidi    VARCHAR2(30);

  BEGIN
    mi_mensaje_err := NULL;
    mi_codigo_favidi := rh_pg_lm_general.t_buscar('CODIGO_ENTIDAD'
                                                 ,'NOMINA'
                                                 ,'FAVIDI_REGIMEN_ANTIGUO'
                                                 ,TO_CHAR(SYSDATE,'dd/mm/yyyy'));
    IF mi_codigo_favidi IS NULL THEN
	  mi_mensaje_err := 'No encontro el codigo de Favidi';
	  RETURN 0;
    END IF;
    -- RQ785-2006	27-12-2006
    -- mi_tercero_favidi:= fn_asociar_tercero(mi_codigo_favidi,'C',NULL,mi_mensaje_err);
    mi_tercero_favidi:= fn_asociar_tercero(mi_codigo_favidi,'FONDO_CESANTIAS',NULL,mi_mensaje_err);
    -- FIN RQ785-2006
    IF mi_tercero_favidi = 0 THEN
 	  mi_mensaje_err := 'No encontro el tercero de Favidi';
	  RETURN 0;
    END IF;
    RETURN mi_tercero_favidi;
  END FN_TERCERO_FAVIDI;

  /***************************************************************************
  Funcion : fn_conceptos_descuentos
  Parametros de Entrada : Grupo
  Descripcion :  Devuelve en una cadena los conceptos asociados a un descuento
  Parametros de salida : Varchar
  ****************************************************************************/
  FUNCTION fn_conceptos_descuentos (una_compania     VARCHAR2,
                                    un_grupo         VARCHAR2,
                                    una_fecha_final  DATE,
                                    mi_mensaje_err   OUT VARCHAR2) RETURN VARCHAR2 IS

    CURSOR c_conceptos_dtos IS
      SELECT stipo_funcionario
        FROM rh_lm_det_grp_funcionario
       WHERE scompania = una_compania
         AND sGrupo    = un_grupo
         AND sGtipo    = 'DESCUENTO'
         AND una_fecha_final BETWEEN dfecha_inicio_vig AND dfecha_final_vig
         AND ncierre   = 1;

    mi_concepto    VARCHAR2(30);
    mi_cadena      VARCHAR2(500):=NULL;

  BEGIN
    mi_mensaje_err := NULL;
    OPEN c_conceptos_dtos;
    LOOP
    	FETCH c_conceptos_dtos INTO mi_concepto;
    	EXIT WHEN c_conceptos_dtos%NOTFOUND;
        IF mi_cadena IS NULL THEN
           mi_cadena:= mi_concepto;
        ELSE
           mi_cadena:= mi_cadena || ',' || mi_concepto;
        END IF;
    END LOOP;
    CLOSE c_conceptos_dtos;
    IF mi_cadena IS NULL THEN
       mi_mensaje_err:='Error al buscar el concepto de nomina para ' || un_grupo;
    END IF;
    RETURN mi_cadena;
  EXCEPTION
    WHEN OTHERS THEN
      IF c_conceptos_dtos%ISOPEN THEN
         CLOSE c_conceptos_dtos;
      END IF;
	mi_mensaje_err := 'Error al buscar el concepto de nomina para ' || un_grupo || SQLERRM;
	RETURN NULL;
  END fn_conceptos_descuentos;

  /*****************************************************************
  Funcion: fn_cuenta
  Parametros de Entrada: Compania, tipo de funcionario, funcionario
  concepto de nomina,  fecha,  devengado (tipo de transaccion),
  tercero, variable que indica si se debe registrar por tipo de
  funcionario: administrativo u operativo
  Parametros de Salida: Nombre de la cuenta
  Descripcion: Busca el nombre de la variable valor asociada a un
  concepto de nomina
  *****************************************************************/
  FUNCTION fn_cuenta(una_compania        VARCHAR2,
                     un_tipo_funcionario VARCHAR2,
                     un_funcionario      NUMBER,
                     un_concepto         VARCHAR2,
                     una_fecha_inicio    DATE,
                     un_devengado        NUMBER,
                     un_global_adm_ope   VARCHAR2,
                     un_adm_ope          VARCHAR2,
                     mi_mensaje_err  OUT VARCHAR2) RETURN VARCHAR2 IS

   mi_cuenta           rh_lm_cuenta.scuenta%TYPE;
   mi_adm_ope          VARCHAR2(1);
   mi_adtiva_operativa rh_funcionario.adtiva_operativa%TYPE;

  BEGIN
    mi_mensaje_err:=NULL;
    -- RQ2523-2005   05/12/2005
    BEGIN
      SELECT cta.scuenta, cc.adm_ope
        INTO mi_cuenta, mi_adm_ope
        FROM rh_lm_cuenta_contable cc, rh_lm_cuenta cta
       WHERE cc.cuenta = cta.scuenta
         AND cta.scompania = una_compania
         AND cta.stipo_funcionario = un_tipo_funcionario
         AND cta.sconcepto = un_concepto
         AND cta.dfecha_inicio_vig <= una_fecha_inicio
         AND (cta.dfecha_final_vig >= una_fecha_inicio OR
              cta.dfecha_final_vig IS NULL)
         AND ncierre = 1;
    EXCEPTION
      WHEN OTHERS THEN
        mi_mensaje_err:='Error al asociar cuenta del plan alterno para ' ||un_concepto||' y '|| un_tipo_funcionario||SUBSTR(SQLERRM,1,120);
        RETURN NULL;
    END;
    -- Fin RQ2523-2005
    IF un_global_adm_ope = 'S' THEN
       IF un_devengado = 8 THEN
          mi_adtiva_operativa := 'A'; -- No se registran saldos a favor o en conta de la EPS a nivel del funcionario
       ELSIF un_devengado <> 2
	     -- RQ1639-2006	12/09/2006
	     OR un_concepto not like '%FAVIDI' THEN
		 -- Fin RQ1639-2006
          BEGIN
            SELECT adtiva_operativa
              INTO mi_adtiva_operativa
              FROM rh_funcionario
             WHERE personas_interno = un_funcionario;
          EXCEPTION
            WHEN OTHERS THEN
               mi_mensaje_err:='Error al asociar tipo de funcionario (adm/ope) para el funcionario '|| un_funcionario || SUBSTR(SQLERRM,1,120);
               RETURN NULL;
          END;
       END IF;
       --Todos los funcionarios deben tener su clasificacion en administrativos u operativos si la variable global indica
       --que se requiere la clasificacion
       IF (un_devengado <> 2
         -- RQ1639-2006		12/09/2006
	     OR un_concepto not like '%FAVIDI')
		 -- Fin RQ1639-2006
	     AND mi_adtiva_operativa IS NULL THEN
          mi_mensaje_err:='Error al asociar tipo de funcionario (adm/ope) para el funcionario '||un_funcionario;
          RETURN NULL;
       END IF;
       --Adiciona a la variable valor los caracteres '-ADM' o '-OPE' para los registros marcados en rh_lm_cuenta
       IF mi_adm_ope = 'S' THEN
          IF un_devengado = 2
		     -- RQ1639-2006	12/09/2006
	         AND un_concepto like '%FAVIDI' THEN
		     -- Fin RQ1639-2006
             mi_cuenta := mi_cuenta ||'-'|| un_adm_ope;
          ELSIF mi_adtiva_operativa = 'A' THEN
             mi_cuenta := mi_cuenta || '-ADM';
          ELSE
             mi_cuenta := mi_cuenta || '-OPE';
          END IF;
       END IF;
    END IF;  --Si un global ADM_OPE es SI
    RETURN(mi_cuenta);
  EXCEPTION
    WHEN OTHERS THEN
      mi_mensaje_err:='Error al asociar cuenta del plan alterno para '||un_concepto||' y '|| un_tipo_funcionario ||SUBSTR(SQLERRM,1,120);
      RETURN NULL;
  END fn_cuenta;

  /**************************************************************************************
   Funcion : fn_detalle_funcionario
   Parametros de Entrada : Compania, fecha final, funcionario, tipo de funcionario,
   un_indicador, control de error
   un_indicador es cero si no se requiere asociar ni eps, ni pension, ni cesantias
   un_indicador es uno  si se requiere asociar eps
   un_indicador es dos  si se requiere asociar pension
   un_indicador es tres si se requiere asociar cesantias
   Parametros de Salida  : Type con informacion del funcionario
   Descripcion           : Retorna informacion del funcionario al leer datos del historico
   ***************************************************************************************/
   FUNCTION FN_DETALLE_FUNCIONARIO (una_compania        VARCHAR2,
                                    una_fecha_final     DATE,
                                    un_funcionario      NUMBER,
                                    un_tipo_funcionario VARCHAR2,
                                    un_indicador        NUMBER,
                                    mi_mensaje_err  OUT VARCHAR2) RETURN rh_pg_lm_general.funcionarioh_type IS
   CURSOR c_tipo_funcionario IS
   SELECT tipo_funcionario, tipo_regimen
     FROM rh_funcionario
    WHERE personas_interno = un_funcionario;

   CURSOR c_eps IS
   SELECT entidad
     FROM rh_seguridad_social
    WHERE funcionario = un_funcionario
      AND tipo_entidad = 'EPS'
      AND fecha_afiliacion <= una_fecha_final
      AND (fecha_retiro >= una_fecha_final OR fecha_retiro IS NULL);

   CURSOR c_fondo_pensiones IS
   SELECT entidad
     FROM rh_seguridad_social
    WHERE funcionario = un_funcionario
      AND tipo_entidad = 'FONDO_PENSIONES'
      AND fecha_afiliacion <= una_fecha_final
      AND (fecha_retiro >= una_fecha_final OR fecha_retiro IS NULL);

   CURSOR c_fondo_cesantias IS
   SELECT entidad
     FROM rh_seguridad_social
    WHERE funcionario = un_funcionario
      AND tipo_entidad = 'FONDO_CESANTIAS'
      AND fecha_afiliacion <= una_fecha_final
      AND (fecha_retiro >= una_fecha_final OR fecha_retiro IS NULL);

      -- definicion de variables
      mi_funcionarioh       rh_pg_lm_general.funcionarioh_type;
      mi_tipofuncionariof   rh_funcionario.tipo_funcionario%TYPE;

    BEGIN
      mi_mensaje_err:=NULL;
      IF un_funcionario IS NOT NULL THEN
         OPEN c_tipo_funcionario;
         FETCH c_tipo_funcionario INTO mi_tipofuncionariof, mi_funcionarioh.mi_regimen;
         IF c_tipo_funcionario%NOTFOUND THEN
            CLOSE c_tipo_funcionario;
            mi_mensaje_err:='No se pudo obtener tipo de funcionario de ' || un_funcionario;
            RETURN mi_funcionarioh;
         END IF;
         CLOSE c_tipo_funcionario;
         IF un_indicador = 1 THEN
            OPEN c_eps;
            FETCH c_eps INTO mi_funcionarioh.mi_codigo_eps;
            IF c_eps%NOTFOUND THEN
               CLOSE c_eps;
               mi_mensaje_err:='No se pudo obtener la eps del funcionario ' || un_funcionario;
               RETURN mi_funcionarioh;
            END IF;
            CLOSE c_eps;
         END IF;
         IF mi_tipofuncionariof <> '8' AND un_indicador = 2 THEN
            OPEN c_fondo_pensiones;
            FETCH c_fondo_pensiones INTO mi_funcionarioh.mi_codigo_pension;
            IF c_fondo_pensiones%NOTFOUND THEN
               CLOSE c_fondo_pensiones;
               mi_mensaje_err:='No se pudo obtener fondo de pensiones del funcionario ' || un_funcionario;
               RETURN mi_funcionarioh;
            END IF;
            CLOSE c_fondo_pensiones;
         END IF;
         IF mi_tipofuncionariof <> '8' AND un_indicador = 3 THEN
            OPEN c_fondo_cesantias;
            FETCH c_fondo_cesantias INTO mi_funcionarioh.mi_codigo_cesantias;
            IF c_fondo_cesantias%NOTFOUND THEN
               CLOSE c_fondo_cesantias;
               mi_mensaje_err:='No se pudo obtener fondo de cesantias del funcionario ' || un_funcionario;
               RETURN mi_funcionarioh;
            END IF;
            CLOSE c_fondo_cesantias;
         END IF;
      END IF;
      IF un_tipo_funcionario IS NOT NULL THEN
         mi_tipofuncionariof:= un_tipo_funcionario;
      END IF;
      BEGIN
         SELECT sgrupo INTO mi_funcionarioh.mi_tipofuncionario
           FROM rh_lm_det_grp_funcionario
          WHERE scompania         = una_compania
            AND sgtipo            ='FUNCIONARIO'
            AND stipo_funcionario = mi_tipofuncionariof
            AND una_fecha_final   BETWEEN dfecha_inicio_vig AND dfecha_final_vig
            AND ncierre           = 1;
         RETURN mi_funcionarioh;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
           mi_mensaje_err:='No se pudo obtener datos del funcionario ' || un_funcionario || SUBSTR(SQLERRM,1,120);
           RETURN mi_funcionarioh;
         WHEN OTHERS THEN
           mi_mensaje_err:='Error obteniendo datos del funcionario ' || un_funcionario || SUBSTR(SQLERRM,1,120);
           RETURN mi_funcionarioh;
      END;
  EXCEPTION
    WHEN OTHERS THEN
      mi_mensaje_err:='Error al buscar detalle para el funcionario '||un_funcionario||' ' ||SUBSTR(SQLERRM,1,120);
      RETURN mi_funcionarioh;
  END FN_DETALLE_FUNCIONARIO;

  /**************************************************************************************
  Funcion               : fn_validar_func_favidi
  Parametros de Entrada : Interno del funcionario
  Parametros de Salida  : Type con el estado actual y fecha de ingreso al distrito
  Descripcion           : Valida si es un funcionario de la entidad, devuelve la fecha de
                          ingreso y el estado actual del funcionario.
  ***************************************************************************************/
  FUNCTION FN_VALIDAR_FUNC_FAVIDI  (un_interno     NUMBER,
                                    mi_mensaje_err OUT VARCHAR2) RETURN rh_pg_lm_general.inf_func_type IS

    CURSOR c_inf_funcionario  IS
    SELECT estado_funcionario, fecha_ingreso_distrito
      FROM rh_funcionario
     WHERE personas_interno = un_interno;

    -- Define variables
    mi_inf_funcionario        inf_func_type;

  BEGIN
    mi_mensaje_err:=NULL;
    mi_inf_funcionario:=NULL;
    OPEN c_inf_funcionario;
    FETCH c_inf_funcionario INTO mi_inf_funcionario;
    IF c_inf_funcionario%NOTFOUND THEN
       CLOSE c_inf_funcionario;
       mi_mensaje_err:='No se obtuvo estado y fecha ingreso distrito de ' || un_interno;
       RETURN mi_inf_funcionario;
    END IF;
    CLOSE  c_inf_funcionario;
    RETURN mi_inf_funcionario;
  END FN_VALIDAR_FUNC_FAVIDI;

  -- RQ117-2008		25/02/2008
  -- Obtiene la version
    FUNCTION FN_VERSION RETURN NUMBER IS
    mi_version NUMBER;
  BEGIN
    mi_version := 19;
    RETURN mi_version;
  END;
  -- Fin RQ117-2008

END;