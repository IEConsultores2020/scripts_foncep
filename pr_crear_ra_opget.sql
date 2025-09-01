  CURSOR  c_ra  IS
    SELECT nro_ra, nro_ra_opget, vigencia, vigencia_presupuesto, numero_compromiso, aprobacion
    FROM   rh_lm_ra
    WHERE  scompania              = 206 --:parameter.p_compania
    AND    tipo_ra                = 2 --:parameter.p_tipo_ra 1-nomina, 2-seguridad social
    AND    grupo_ra               = 5 --:parameter.p_grupo_ra
    AND    dfecha_inicial_periodo = '01/06/25' --:parameter.p_fecha_inicial
    AND    dfecha_final_periodo   = '30/06/25' --:parameter.p_fecha_final
    AND    ntipo_nomina           = 0  --:parameter.p_tipo_nomina
    ORDER BY vigencia_presupuesto;

	TYPE ra_type IS RECORD 
	 (mi_nro_ra                rh_lm_ra.nro_ra%TYPE,
	  mi_nro_ra_opget          rh_lm_ra.nro_ra_opget%TYPE,
	  mi_vigencia              rh_lm_ra.vigencia%TYPE,
	  mi_vigencia_presupuesto  rh_lm_ra.vigencia_presupuesto%TYPE,
	  mi_numero_compromiso     rh_lm_ra.numero_compromiso%TYPE,
	  mi_aprobacion            rh_lm_ra.aprobacion%TYPE);
  
    mi_ra_type             ra_type; 

	FETCH c_ra INTO mi_ra_type;       


--Valida iputación igual a distribución
pr_validar_imputacion_pre

--llena mi_Tbl_RA_Ogt OUT pk_ogt_bd_crear_ra.rarec
pr_llenar_ra(
    una_compania           VARCHAR2,
    una_vigencia           NUMBER,
    una_unidad_ejecutora   VARCHAR2,
    un_nro_ra              NUMBER,
    un_numero_compromiso   rh_lm_ra.numero_compromiso%TYPE,
    un_tipo_ra             rh_lm_ra.tipo_ra%TYPE,
    una_fecha_inicial      DATE,
    una_fecha_final        DATE,
    un_mes                 NUMBER,
    mi_Tbl_RA_Ogt      OUT pk_ogt_bd_crear_ra.rarec,
    mi_err             OUT NUMBER
            )

--llena mi_Tbl_Imputacion_Ogt OUT pk_ogt_bd_crear_ra.imptab,
pr_llenar_tabla_imputacion(
    una_compania              VARCHAR2, => :parameter.p_compania
    una_vigencia              NUMBER,   => mi_ra_type.mi_vigencia
    una_vigencia_presupuesto  NUMBER,   => mi_ra_type.mi_vigencia_presupuesto
    una_unidad_ejecutora      VARCHAR2, => :parameter.p_unidad
    un_nro_ra                 NUMBER,   => mi_ra_type.mi_nro_ra
    un_tipo_ra                VARCHAR2, => :parameter.p_tipo_ra
    un_grupo_ra               VARCHAR2, => :parameter.p_grupo_ra
    un_tipo_nomina            NUMBER,   => :parameter.p_tipo_nomina
    una_fecha_inicial         DATE,     => :parameter.p_fecha_inicial
    una_fecha_final           DATE,     => :parameter.p_fecha_final
    mi_Tbl_Imputacion_Ogt     OUT pk_ogt_bd_crear_ra.imptab,
                                        => mi_Tbl_Imputacion_Ogt
     mi_err                   OUT NUMBER=> mi_err          
)
      CURSOR c_imputacion IS
    SELECT /*a.ano_pac,
           a.mes_pac,
           b.interno_rubro,
           b.disponibilidad,
           b.valor_bruto,
           b.registro_presupuestal,
           b.valor_rp*/
           a.*
    FROM   rh_lm_ra a, rh_lm_ra_presupuesto b
    WHERE  a.scompania              = b.compania
    AND    a.vigencia               = b.vigencia
    AND    a.vigencia_presupuesto   = b.vigencia_presupuesto
    AND    a.unidad_ejecutora       = b.unidad_ejecutora
    AND    a.nro_ra                 = b.nro_ra
    AND    a.scompania              = 206   --una_compania
    AND    a.vigencia               = 2025  --una_vigencia
    AND    a.vigencia_presupuesto   = 2025  --una_vigencia_presupuesto
    AND    a.unidad_ejecutora       = '01'  --una_unidad_ejecutora
    AND    a.nro_ra                 = 14    --un_nro_ra
    AND    a.tipo_ra                = 1     --un_tipo_ra
    AND    a.grupo_ra               = 5     --un_grupo_ra
    AND    a.ntipo_nomina           = 0     --un_tipo_nomina
    AND    a.dfecha_inicial_periodo = '01/06/25'  --una_fecha_inicial
    AND    a.dfecha_final_periodo   = '30/06/25' ; --una_fecha_final;

--llena mi_Tbl_CC_Ogt         OUT pk_ogt_bd_crear_ra.cctab,
pr_llenar_tabla_cc

--No se usan fuentes
pr_llenar_tabla_fte


pk_ogt_bd_crear_ra.pr_crea_ra(
        UN_REG_RA             IN     RAREC  => mi_Tbl_RA_Ogt
        ,UN_CODIGO            IN OUT NUMBER => mi_err
        ,UNA_TABLA_IMPUTACION IN     IMPTAB => mi_Tbl_Imputacion_Ogt
        ,UNA_TABLA_CENTRO     IN     CCTAB  => mi_Tbl_CC_Ogt
        ,UNA_TABLA_NOMINA     IN     ANTAB  => mi_Tbl_AN_Ogt
        ,UNA_TABLA_EMBARGO    IN     AETAB  => mi_Tbl_AE_Ogt
        ,UNA_TABLA_APORTES    IN     APTAB  => mi_Tbl_AP_Ogt
        ,UN_CONSECUTIVO       IN OUT OGT_RELACION_AUTORIZACION.CONSECUTIVO%TYPE
                                            => mi_consecutivo_Ogt
        ,UN_PL_ERR            IN OUT ERTAB  => mi_tbl_err_Ogt 
        )

    INSERT INTO OGT_DOCUMENTO_PAGO
    INSERT INTO OGT_RELACION_AUTORIZACION
    -- CREAR LA IMPUTACION
    PK_OGT_BD_CREAR_RA.PR_CREA_IMPUTACION(
            UN_REG_RA       IN     RAREC    => UN_REG_RA
            ,UNA_TABLA_IMP  IN     IMPTAB   => UNA_TABLA_IMPUTACION
            ,UN_CONSECUTIVO IN VARCHAR2     => UN_CONSECUTIVO
            ,UN_CODIGO      IN OUT NUMBER   => UN_CODIGO
            ,UN_PL_ERR      IN OUT ERTAB    -- LISTA DE ERRORES
            ,UN_ABORTE      IN OUT VARCHAR2 -- INDICA SI HAY POR LO MENOS UN ERROR QUE NO PERMITE CARGUE '1'
            ,UN_I           IN OUT NUMBER   -- CONTADOR DE LA TABLA PL
            ) IS
        INSERT INTO OGT_IMPUTACION
        INSERT INTO OGT_REGISTRO_PRESUPUESTAL
    -- VERIFICAR QUE EL TOTAL DE LA IMPUTACION SEA IGUAL A LA RA
    -- CREAR CC
     PK_OGT_BD_CREAR_RA.PR_CREA_CC 
        INSERT INTO OGT_CENTRO_COSTOS

     -- VERIFICAR QUE EL TOTAL SEA IGUAL A SU HOMOLOGO DE CC
    -- CREAR AN
     PK_OGT_BD_CREAR_RA.PR_CREA_AN
        INSERT INTO OGT_RA_FORMA_PAGO
        INSERT INTO OGT_ANEXO_NOMINA

    -- VERIFICAR QUE EL TOTAL SEA IGUAL A SU HOMOLOGO DE CC
    -- CREAR AE
    PK_OGT_BD_CREAR_RA.PR_CREA_AE
        INSERT INTO OGT_ANEXO_PATRONAL
        INSERT INTO OGT_ANEXO_EMBARGO

    -- VERIFICAR QUE EL TOTAL SEA IGUAL A SU HOMOLOGO DE CC
    -- VERIFICAR SALDO EN AP
    -- CREAR AA
    PK_OGT_BD_CREAR_RA.PR_CREA_AP
        INSERT INTO OGT_ANEXO_PATRONAL

    --NUEVO RECOMENDADO
    PK_OGT_BD_CREAR_RA.PR_ACTUALIZA_IMPUTACION

--Actualiza el campo nro_ra_opget con el consecutivo retornado por OPGET
pr_actualiza_nro_ra_ogt 

