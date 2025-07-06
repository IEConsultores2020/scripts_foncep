PROCEDURE PR_PLANOS_RA_SHD(una_compania      VARCHAR2,
                                un_tipo_ra        VARCHAR2,
                                un_grupo_ra       VARCHAR2,
                                un_tipo_nomina    NUMBER,
                                una_fecha_inicial DATE,
                                una_fecha_final   DATE,
                                mi_err            OUT NUMBER) IS
--20250623V3.8
  Cursor rubros(un_nro_ra NUMBER) is
  
    SELECT DISTINCT B.CC RUBRO, b.grupo_ra
      FROM RH_T_LM_VALORES     a,
           RH_LM_CUENTA        b,
           --RH_LM_CENTROS_COSTO L,
           RH_FUNCIONARIO f
     WHERE b.stipo_funcionario = a.stipofuncionario
       AND a.periodo = una_fecha_final
       AND a.ntipo_nomina = un_tipo_nomina
       AND a.sdevengado IN (0, 1)
       AND a.nro_ra = un_nro_ra
       AND b.scompania = una_compania
       AND b.tipo_ra = un_tipo_ra
       AND b.ncierre = 1
       and tipo_ra = un_tipo_ra
       /*--PRUEBAS 2022
            and       a.nfuncionario IN (3428) --*/
       AND b.dfecha_inicio_vig <= una_fecha_final
       AND (b.dfecha_final_vig >= una_fecha_final OR
           b.dfecha_final_vig IS NULL)
       AND f.Personas_interno = a.nFuncionario
       AND B.CC IS NOT NULL
    UNION
    SELECT DISTINCT B.CC RUBRO, b.grupo_ra
      FROM RH_T_LM_VALORES     a,
           RH_LM_CUENTA        b,
           --RH_LM_CENTROS_COSTO L,
           RH_FUNCIONARIO f
     WHERE b.stipo_funcionario = a.stipofuncionario
     /*PRUEBAS
          AND      b.sconcepto         =   a.sconcepto --*/
       AND a.periodo = una_fecha_final
       AND a.ntipo_nomina = un_tipo_nomina
       AND a.sdevengado IN (2, 4)
       AND a.nro_ra = un_nro_ra
       AND b.scompania = una_compania
       AND b.tipo_ra = un_tipo_ra
       AND b.ncierre = 1
       and tipo_ra = un_tipo_ra
          /*--PRUEBAS 2022
            and       a.nfuncionario IN (4966,4946) --*/
       AND b.dfecha_inicio_vig <= una_fecha_final
       AND (b.dfecha_final_vig >= una_fecha_final OR
           b.dfecha_final_vig IS NULL)
       AND f.Personas_interno = a.nFuncionario
       AND B.CC IS NOT NULL
    ;

  cursor reg40(un_nro_ra NUMBER) is
    SELECT 
      '7990990000' cuenta_credito,
      sum(decode(regimen, '3', a.valor,'1',0,'2',0)) valor_rubro,
      '5000001965' rp_doc_presupuestal,
      decode(c.descripcion,'Sueldo básico','0001',c.codigo_nivel7) posicion_doc_presupuestal
    FROM     rh_t_lm_valores a, rh_lm_cuenta b, pr_v_rubros c
      WHERE tipo_ra             = '1' 
      AND   grupo_ra            = '5'
      AND   scompania           = una_compania
      AND   stipo_funcionario   = stipofuncionario
      AND   a.sconcepto         = b.sconcepto
      AND   ncierre             = 1
      AND   c.interno_rubro     = b.codigo_presupuesto
      AND   c.vigencia          = extract(year from una_fecha_final)
      AND   a.ntipo_nomina      = '0'
      AND   dfecha_inicio_vig   <= una_fecha_final 
      AND   (dfecha_final_vig   >= una_fecha_final OR dfecha_final_vig IS NULL) 
      AND   b.codigo_presupuesto IS NOT NULL
      AND   periodo             = una_fecha_final  --:P_FECHA_FINAL
      --AND   nro_ra              = un_nro_ra            ---:P_NRORA
      GROUP BY codigo_nivel1,
                          codigo_nivel2,
                          codigo_nivel3,
                          codigo_nivel4,
                          codigo_nivel7,
                          codigo_nivel5 || '-' || codigo_nivel6 || '-' || codigo_nivel7 || '-' || codigo_nivel8,
                          descripcion,
                          interno_rubro
      ORDER BY codigo_nivel5 || '-' || codigo_nivel6 || '-' || codigo_nivel7 || '-' || codigo_nivel8;

  CURSOR cur_anexos(un_cc number) IS
    SELECT b.codigo,
           b.descripcion,
           'SAP' || a.archivo_plano,
           b.tabla_detalle
      FROM rh_lm_ra_cc a, rh_lm_centros_costo b
     WHERE a.ra = un_tipo_ra
       and a.cc = un_cc
       /*--FTV PRUEBA 202405
          AND a.cc  =   7  --*/
       AND a.cc = b.codigo;

  CURSOR cur_nxp(un_nro_ra NUMBER, un_cc number) IS
  
    SELECT nfuncionario, abs(SUM(valor)) valor, f.CODIGO_BANCO CODIGO_BANCO
      FROM rh_t_lm_valores a,
           rh_lm_cuenta    b,
           rh_funcionario f
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
       /*--PRUEBAS 2022
          --  and      b.codigo_presupuesto=   un_cc
            and       a.nfuncionario IN (4966,4946) --*/
       AND b.dfecha_inicio_vig <= una_fecha_final
       AND (b.dfecha_final_vig >= una_fecha_final OR
           b.dfecha_final_vig IS NULL)
       AND f.Personas_interno = a.nFuncionario
     GROUP BY nfuncionario, f.CODIGO_BANCO;

  CURSOR cur_nxpcc(un_nro_ra NUMBER, un_cc number) IS
    SELECT nfuncionario,
           abs(SUM(valor)) valor,
           to_number(f.CODIGO_BANCO) CODIGO_BANCO
      FROM rh_t_lm_valores a,
           rh_lm_cuenta    b,
           rh_funcionario f
     WHERE 
     b.sconcepto = a.sconcepto
     AND a.periodo = una_fecha_final
     AND a.ntipo_nomina = un_tipo_nomina
     AND a.sdevengado IN (0, 1)
     AND a.nro_ra = un_nro_ra
     AND b.scompania = una_compania
     AND b.tipo_ra = un_tipo_ra
     AND b.grupo_ra IN (un_grupo_ra)
     AND b.ncierre = 1
     and b.codigo_presupuesto = un_cc
    /*--PRUEBAS 
      and       a.nfuncionario IN (4966,4946) --*/
     AND b.dfecha_inicio_vig <= una_fecha_final
     AND (b.dfecha_final_vig >= una_fecha_final OR b.dfecha_final_vig IS NULL)  
     AND f.Personas_interno = a.nFuncionario 
     GROUP BY nfuncionario, f.CODIGO_BANCO;

  /* datos de retencion */
  cursor retefteperiodo(un_nro_ra NUMBER) IS
    SELECT sum(retencion) retencion,
           SUM(base) BASE,
           sum(asignacion) asignacion
      from (SELECT 0 retencion, abs(SUM(valor)) base, 0 Asignacion
              FROM rh_t_lm_valores a
             WHERE a.periodo = una_fecha_final
               AND a.ntipo_nomina = un_tipo_nomina
               AND (a.sdevengado IN (0)
                   --INI SINPROC 3320191 
                   OR (a.sdevengado = 1 and variable_valor like 'NDV%'))
                  --FIN SINPROC 3320191
               AND a.nro_ra = un_nro_ra
            union
            SELECT abs(SUM(valor)) retencion, 0 base, 0 Asignacion
              FROM rh_t_lm_valores a
             WHERE a.periodo = una_fecha_final
               AND a.ntipo_nomina = un_tipo_nomina
               AND a.sdevengado IN (1)
               AND SCONCEPTO LIKE 'RET%FUENTE%'
               AND a.nro_ra = un_nro_ra
            UNION
            SELECT 0 retencion, 0 base, sum(ndcampo4) Asignacion
              FROM RH_HISTORICO_NOMINA
             WHERE nhash = 1128917309
               AND dfechaefectiva >=
                   to_char(una_fecha_inicial, 'yyyymm') || '01'
               AND dfechaefectiva <= to_char(una_fecha_final, 'yyyymmdd')
               and nretroactivo = 0
               and ntipoconcepto = 1
               AND nfuncionario in
                   (select nfuncionario
                      from RH_T_LM_VALORES
                     where nro_ra = un_nro_ra
                       AND PERIODO = una_fecha_final));


  CURSOR cur_fna(un_nro_ra NUMBER) IS  
    SELECT abs(SUM(valor)) valor,
           TIPO_DOCUMENTO,
           NUMERO_DOCUMENTO,
           forma_pago
      FROM rh_t_lm_valores a, rh_lm_cuenta b, RH_ENTIDAD E
     WHERE b.stipo_funcionario = a.stipofuncionario
       AND b.sconcepto = a.sconcepto
       AND a.periodo = una_fecha_final
       AND a.ntipo_nomina = un_tipo_nomina
       AND a.sdevengado IN (3)
       AND a.nro_ra = un_nro_ra
       AND b.scompania = una_compania
       AND b.tipo_ra = un_tipo_ra
       AND b.grupo_ra IN (un_grupo_ra)
       AND b.ncierre = 1
       AND a.sconcepto = 'INFOCESANTIAS_FNA'
       /*--PRUEBAS 2022
            and       a.nfuncionario IN (4966,4946) --*/
       AND b.dfecha_inicio_vig <= una_fecha_final
       AND (b.dfecha_final_vig >= una_fecha_final OR
           b.dfecha_final_vig IS NULL)
       AND a.sconcepto = 'INFOCESANTIAS_FNA'
       AND a.stercero = lpad(E.codigo, 2, 0)
       and e.tipo = 'FONDO_CESANTIAS'
     group by a.nro_ra, TIPO_DOCUMENTO, NUMERO_DOCUMENTO, forma_pago;
  /* fin cesantias fna */
  cursor pagorubro(un_cc number, un_nro_ra NUMBER) is
  
    SELECT abs(SUM(a.valor)) pago, c.concepto_rubro RUBRO
      FROM RH_T_LM_VALORES  a,
           RH_LM_CUENTA     b,
           RH_LM_CUENTAS_RA c,
           RH_FUNCIONARIO f
     WHERE b.stipo_funcionario = a.stipofuncionario
       AND b.sconcepto = a.sconcepto
       AND a.periodo = una_fecha_final
       AND a.ntipo_nomina = un_tipo_nomina
       AND a.sdevengado IN (0, 1)
       AND a.nro_ra = un_nro_ra
       AND b.scompania = una_compania
       AND b.tipo_ra = un_tipo_ra
       AND b.grupo_ra IN (un_grupo_ra)
       AND b.CODIGO_PRESUPUESTO = un_cc
       AND b.ncierre = 1
       AND c.CODIGO_CONCEPTO_CC = B.CODIGO_PRESUPUESTO
       AND c.grupo_ra = b.grupo_ra
       AND b.CODIGO_PRESUPUESTO not in (1, 2)
          /*--PRUEBAS 
            and       a.nfuncionario IN (4966,4946) --*/
       AND b.dfecha_inicio_vig <= una_fecha_final
       AND (b.dfecha_final_vig >= una_fecha_final OR
           b.dfecha_final_vig IS NULL)  
       AND f.Personas_interno = a.nFuncionario
     GROUP BY c.concepto_rubro;

  cursor pagorubronxp(un_cc number, un_nro_ra NUMBER) is
  
    SELECT abs(SUM(valor)) pago
      FROM RH_T_LM_VALORES a
     WHERE a.periodo = una_fecha_final
       AND a.ntipo_nomina = un_tipo_nomina
       AND a.sdevengado IN (0, 1)
       AND a.nro_ra = un_nro_ra;

  CURSOR cur_embargos(un_cc NUMBER, un_nro_ra NUMBER) IS
  --mi_tercero, mi_funcionario, mi_sdescuento,mi_nbeneficiario,mi_codbeneficiario,  mi_fpagobeneficiario, mi_valor;
    SELECT a.stercero,
           a.nfuncionario,
           a.sdescuento,
           bb.beneficiario,
           d.cod_benef_pago,
           d.forma_pago,
           d.proceso,
           SUM(valor) valor,
           d.concepto
      FROM rh_t_lm_valores     a,
           rh_lm_cuenta        b,
           rh_lm_centros_costo c,
           rh_beneficiarios    bb,
           rh_descuentos_f     d
     WHERE b.stipo_funcionario = a.stipofuncionario
       AND b.sconcepto = a.sconcepto
       AND b.cc = c.codigo
       AND a.periodo = una_fecha_final
       AND a.ntipo_nomina = un_tipo_nomina
       and d.funcionario = a.nfuncionario
       and d.beneficiario = a.stercero
       and d.tipo = substr(a.sconcepto, 2)
       AND a.sdevengado IN (0, 1)
       and a.sdescuento = d.numero_descuento
       and d.estado in (1, 2, 4)
       AND a.nro_ra = un_nro_ra
       AND b.scompania = una_compania
       AND b.tipo_ra = un_tipo_ra
       and bb.codigo_beneficiario = a.stercero
       AND b.grupo_ra IN (un_grupo_ra)
       AND b.ncierre = 1
       and d.forma_pago = 'B'
       AND b.dfecha_inicio_vig <= una_fecha_final
       AND (b.dfecha_final_vig >= una_fecha_final OR
           b.dfecha_final_vig IS NULL)
       AND b.cc = 6
    /*--PRUEBAS 2022
      and       a.nfuncionario IN (4966,4946) --*/
     GROUP BY stercero,
              a.nfuncionario,
              bb.beneficiario,
              d.forma_pago,
              a.sdescuento,
              d.cod_benef_pago,
              d.proceso,
              d.concepto;
  
  CURSOR cur_embargosnba(un_cc NUMBER, un_nro_ra NUMBER) IS
  
    SELECT a.stercero,
           a.nfuncionario,
           a.sdescuento,
           bb.beneficiario,
           d.forma_pago,
           d.cod_benef_pago,
           d.banco,
           d.tipo_cuenta,
           d.numero_cuenta,
           d.proceso,
           SUM(valor) valor
      FROM rh_t_lm_valores     a,
           rh_lm_cuenta        b,
           rh_lm_centros_costo c,
           rh_beneficiarios    bb,
           rh_descuentos_f     d
     WHERE b.stipo_funcionario = a.stipofuncionario
       AND b.sconcepto = a.sconcepto
       AND b.cc = c.codigo
       AND a.periodo = una_fecha_final
       AND a.ntipo_nomina = un_tipo_nomina
       and d.funcionario = a.nfuncionario
       and d.beneficiario = a.stercero
       and d.tipo = substr(a.sconcepto, 2)
       AND a.sdevengado IN (0, 1)
       and a.sdescuento = d.numero_descuento
       and d.estado in (1, 2, 4)
       AND a.nro_ra = un_nro_ra
       AND b.scompania = una_compania
       AND b.tipo_ra = un_tipo_ra
       and bb.codigo_beneficiario = a.stercero
       AND b.grupo_ra IN (un_grupo_ra)
       AND b.ncierre = 1
       and d.forma_pago != 'B'
       AND b.dfecha_inicio_vig <= una_fecha_final
       AND (b.dfecha_final_vig >= una_fecha_final OR
           b.dfecha_final_vig IS NULL)
       AND b.cc = 6
    /*--PRUEBAS 2022
      and       a.nfuncionario IN (4966,4946) --*/
     GROUP BY a.stercero,
              a.nfuncionario,
              a.sdescuento,
              bb.beneficiario,
              d.forma_pago,
              d.cod_benef_pago,
              d.banco,
              d.tipo_cuenta,
              d.numero_cuenta,
              d.proceso;

  CURSOR c_ra IS
    SELECT nro_ra, aprobacion
      FROM rh_lm_ra
     WHERE scompania = una_compania
       AND tipo_ra = un_tipo_ra
       AND grupo_ra = un_grupo_ra
       AND dfecha_inicial_periodo = una_fecha_inicial
       AND dfecha_final_periodo = una_fecha_final
       AND ntipo_nomina = un_tipo_nomina;

  TYPE ra_type IS RECORD(
    mi_nro_ra   rh_lm_ra.nro_ra%TYPE,
    mi_aprobado VARCHAR2(1));

  cursor encabezado(un_grupo varchar2) is
  
    SELECT TO_CHAR(sysdate, 'yyyymmdd') fdoc,
           LPAD(1, 10, ' ') ndoc,
           decode(un_tipo_ra, 1, 'NE', 3, 'NE', 'NA') clasedoc,
           '1001' sociedad,
           TO_CHAR(SYSDATE, 'yyyymmdd') fcontab,
           --TO_CHAR(SYSDATE, 'mm') periodo, FCP200250517
           '  ' periodo, --FCP200250517
           'COP' moneda,
           LPAD(' ', 9) cambio,
           'Nomina '||TO_CHAR(SYSDATE, 'FMMONTH', 'NLS_DATE_LANGUAGE = Spanish') nrodoc,
           '13 Nomina '||TO_CHAR(SYSDATE, 'FMMONTH', 'NLS_DATE_LANGUAGE = Spanish') Cabecera
      FROM dual;

  cursor codach(un_banco varchar2) Is
    SELECT lpad(cod_superbancaria, 3, 0) codigo_ach
      FROM RH_ENTIDAD
     WHERE codigo = un_banco
     AND tipo = 'BANCO';

  cursor nom_entidad(una_entidad varchar2) Is
    SELECT ib_primer_nombre nomentidad
      FROM trc_informacion_basica b, trc_terceros t
     WHERE b.id = t.id
       and t.codigo_identificacion = una_entidad
       and ib_fecha_final is null;
  
  Cursor descc(un_cc number) IS
    select max(descripcion) nombrecc
      from rh_lm_centros_costo
     where codigo = un_cc;

  mi_ra_type                ra_type;
  mi_persona_type           pk_detalle_anexos_ra.personas_type;
  mi_funcionario_type       pk_detalle_anexos_ra.funcionario_type;
  mi_beneficiario_type      pk_detalle_anexos_ra.beneficiarios_type;
  mi_entidad_type           pk_detalle_anexos_ra.entidad_type;
  mi_embargo_type           pk_detalle_anexos_ra.embargo_type;
  mi_demandante_type        pk_detalle_anexos_ra.demandante_type;
  mi_demandantes_type       pk_detalle_anexos_ra.demandantes_type;
  mi_incapacidad            rh_t_lm_valores.valor%TYPE;
  mi_saldo                  rh_t_lm_valores.valor%TYPE;
  mi_cc                     rh_lm_centros_costo.codigo%TYPE := NULL;
  mi_funcionario            rh_t_lm_valores.nfuncionario%TYPE;
  mi_texto_nomina_mes			  varchar2(200) ;
  mi_concepto               rh_t_lm_valores.sconcepto%TYPE;
  mi_ofi_origen             varchar2(50); --NFCP rh_descuentos_f.ban_agra_origen%TYPE;
  mi_ofi_destino            varchar2(50); --NFCP rh_descuentos_f.ban_agra_destino%TYPE;
  mi_conceptoemb            varchar2(60);
  mi_concepto_entidad_benef rh_t_lm_valores.sconcepto%TYPE;
  mi_concepto_inc           rh_t_lm_valores.sconcepto%TYPE;
  mi_concepto_saldos        rh_t_lm_valores.sconcepto%TYPE;
  mi_tercero                rh_t_lm_valores.stercero%TYPE;
  mi_sdescuento             rh_t_lm_valores.sdescuento%TYPE;
  mi_valor                  rh_t_lm_valores.valor%TYPE := 0;
  mi_valor_saldo            rh_t_lm_valores.valor_saldo%TYPE;

  mi_grupo_ra               VARCHAR2(200);
  mi_vigencia               VARCHAR2(4);
  mi_mes                    VARCHAR2(2);
  mi_tabla_detalle          VARCHAR2(100);
  mi_tabla                  VARCHAR2(30);
  mi_nombre_entidad         VARCHAR2(60);
  mi_archivo_plano          VARCHAR2(100);
  mi_archivo_planoemb       VARCHAR2(100);
  mi_archivo_planosap       VARCHAR2(100);
  mi_archivo_planosapfoncep VARCHAR2(100);
  mi_descripcion_cc         VARCHAR2(100);
  mi_archivo_path           Text_IO.File_Type;
  mi_archivo_sap            Text_IO.File_Type;
  mi_archivo_sap_foncep     Text_IO.File_Type;
  mi_archivo_sap2           Text_IO.File_Type;
  mi_www_path               VARCHAR2(1000);
  mi_pathweb_ra             VARCHAR2(1000);
  mi_szLinea                VARCHAR2(4000);
  mi_szLinea2               VARCHAR2(4000);
  mi_cursor                 EXEC_SQL.CURSTYPE;
  nIgn                      PLS_INTEGER; --Variable para manejar el cursor diná¡mico
  mi_consulta               VARCHAR2(2000) := NULL;
  mi_autoliq                BOOLEAN := TRUE;
  mi_id_error               text_io.file_type;
  mi_nombre_archivo_err     VARCHAR2(500);
  mi_directorio_carga       VARCHAR2(500);
  mi_pagina_carga           VARCHAR2(500);
  mi_sqlcode                NUMBER;
  mi_terceros_neg           NUMBER := 0;
  mi_nit_agrario            Varchar2(12);
 
  mi_tipo_entidad VARCHAR2(150);
  mi_total_fna    NUMBER := 0;
  mi_consecutivo  Number := 0;
  mi_nro_ra       NUMBER := 0;
  mi_asignacion   NUMBER := 0;
  mi_pago_rubro   NUMBER := 0;
  
  mi_nit_ces     Varchar2(15);
  mi_tiponit_ces Varchar2(3);
  mi_var90rete   Varchar2(2);
  forma_pagoces  Varchar2(3);
  mi_codbanco    Varchar2(3);
  mi_valor_ces   Number;
  mi_basertfte   Varchar2(15);
  mi_retefuente  Varchar2(15);
  mi_cuentarub   varchar2(20);
  mi_codigo      Varchar2(3);
  mi_viapago     Varchar2(1);
  mi_nombrecc    varchar2(50);
  mi_Banco             Varchar2(250);
  mi_cuentareg         Number := 0;
  mi_tipo_cuentafun    varchar2(2);
  mi_tipo_funcionarios varchar2(50);
  mi_BancoRef          Varchar2(250);
  mi_condicion_pago    Varchar2(4);
  mi_codbeneficiario   varchar2(20);
  mi_fpagobeneficiario varchar2(20);
  mi_nbeneficiario     varchar2(120);
  mi_bancoemb          varchar2(3);
  mi_tipo_cuenta_emb   varchar2(3);
  mi_numero_cuenta_emb varchar2(20);
  mi_proceso           varchar2(30);
  mi_cuenta_debito     Varchar2(30);
  mi_cuenta_credito    Varchar2(30);
  mi_texto             Varchar2(30);
  mi_archivo_plano2    VARCHAR2(100);
  mi_archivo_path2     Text_IO.File_Type;

  --FTV usado para guardar la linea ejecutada, se informa en caso de generar una excepción.
  mi_linea_ejecutada varchar(100);
  mi_file_debug_handle Text_IO.File_Type;
  mi_file_debug_path varchar2(1000);
BEGIN
  mi_err := 0;
  --mi_file_debug_handle := pr_debug_activa;
  if :B_RA.cta_x_nomina = '999999999' then
  	If Get_Application_Property(OPERATING_SYSTEM) Like '%WIN%' Then
  		mi_file_debug_path :='Z:\temp';
  		mi_file_debug_path := mi_file_debug_path ||'\rh_lm_ra_form_log.txt';
  	else
			mi_file_debug_path := p_bintablas.tbuscar('PATH_ANEXO_RA',
                                       'NOMINA',
                                       'QUERY',
                                       TO_CHAR(SYSDATE, 'dd/mm/yyyy'));  
     mi_file_debug_path := mi_file_debug_path ||'/rh_lm_ra_form_log.txt';
    end if;    
   
		mi_file_debug_handle := text_io.fopen(mi_file_debug_path, 'w'); 
  end if;
  
  --Validar que los conceptos de saldos a favor o en contra o incapacidades en la autoliquidación
  --no tengan marcado centro de costo
  mi_autoliq := pk_detalle_anexos_ra.fn_validar_cc_salud_arp(una_compania,
                                                             una_fecha_final,
                                                             mi_err);
  --message('aportes ');
  IF mi_err = 1 THEN
    RETURN;
  END IF;
  IF mi_autoliq THEN
    pr_despliega_mensaje('AL_STOP_1',
                         'Existen conceptos de autoliquidación para incapacidades o saldos a favor o en contra asociados a un centro de costo.');
    mi_err := 1;
    RETURN;
  END IF;
  If Get_Application_Property(OPERATING_SYSTEM) Like '%WIN%' Then
  	mi_www_path :='Z:\temp';
  else
  	mi_www_path   := p_bintablas.tbuscar('PATH_ANEXO_RA',
                                       'NOMINA',
                                       'QUERY',
                                       TO_CHAR(SYSDATE, 'dd/mm/yyyy'));
  end if;
  mi_pathweb_ra := p_bintablas.tbuscar('PATH_WEBANEXO_RA',
                                       'NOMINA',
                                       'QUERY',
                                       TO_CHAR(SYSDATE, 'dd/mm/yyyy'));
  /* Comentariar quitando los dos -- para pasar a producciá²n
  pr_despliega_mensaje('AL_STOP_1','Modifique la ruta del codigo fuente antes de pasar a producción');
  mi_www_path :='Z:\Planossap'; --USAR SOLO PARA PROBAR LOCAL
  --*/
  --   message('Ruta '|| mi_www_path);
  --mi_www_path :='d:\apps\descarga';
  IF mi_www_path IS NULL THEN
    pr_despliega_mensaje('AL_STOP_1',
                         'No se encuentra definido en bintablas el path para generar el archivo');
    mi_err := 1;
    RETURN;
  END IF;
  mi_nit_agrario := p_bintablas.tbuscar('BANCO_AGRARIO',
                                        'GENERAL',
                                        'NIT',
                                        TO_CHAR(SYSDATE, 'dd/mm/yyyy'));
  -- adicionar archivo encabezado 20181018 WN
  mi_archivo_planosap := :B_RA_SEQ.secuencial || '-nomina' || una_compania ||
                         to_char(sysdate, 'yyyymmddhhmiss') ||
                         to_char(una_fecha_final, 'yyyymm') || '.txt';
  BEGIN
    IF GET_APPLICATION_PROPERTY(USER_INTERFACE) = 'WEB' THEN
      --mi_id_error      := text_io.fopen(mi_directorio_carga||'/'||mi_nombre_archivo_err, 'w');
      --Mensaje pruebas si cta_x_nomina = 999999999
      pr_debug_registra(mi_file_debug_handle,'Linea 534 IF GET_APPLICATION_PROPERTY(USER_INTERFACE) = WEB es cierto');
      If Get_Application_Property(OPERATING_SYSTEM) Like '%WIN%' Then
        mi_archivo_sap := text_io.fopen(mi_www_path || '\' ||
                                        mi_archivo_planosap,
                                        'w');
      Else
        mi_archivo_sap := text_io.fopen(mi_www_path || '/' ||
                                        mi_archivo_planosap,
                                        'w');
      End If;
    ELSE
      mi_archivo_sap := text_io.fopen('c:\' || mi_archivo_planosap, 'w');
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
                           '1 Ocurrió un error ' || SQLERRM() || ' ' ||
                           SQLCODE());
      mi_err := 1;
      RETURN;
  END;
  mi_condicion_pago := una_compania || '1';

  mi_tipo_funcionarios := p_bintablas.tbuscar(un_grupo_ra,
                                              'NOMINA',
                                              'RELACIONAUTORIZACION_GRUPOS',
                                              TO_CHAR(SYSDATE, 'dd/mm/yyyy')) ||
                          p_bintablas.tbuscar(un_tipo_ra,
                                              'NOMINA',
                                              'RELACIONAUTORIZACION',
                                              TO_CHAR(SYSDATE, 'dd/mm/yyyy'));

  for e in encabezado(un_grupo_ra) loop
    mi_szLinea := 'C' || chr(09) || e.NDOC || chr(09) ||
                  to_char(sysdate, 'yyyymmdd') || chr(09) || e.CLASEDOC ||
                  chr(09) || e.SOCIEDAD || chr(09) || e.FCONTAB || chr(09) ||
                  e.PERIODO || chr(09) || e.MONEDA || chr(09) || e.CAMBIO ||
                  chr(09) || e.NRODOC || chr(09) || e.CABECERA;
    mi_texto   := 'NA '; --N/A'e.CABECERA||to_char(una_fecha_final,'yyyymm');
    Text_IO.Put_Line(mi_archivo_sap, mi_szLinea);
    pr_debug_registra(mi_file_debug_handle,'Linea 582 Text_IO.Put_Line(mi_archivo_sap, mi_szLinea)');
  end loop;

  for e in reg40(mi_nro_ra) loop
  	  pr_debug_registra(mi_file_debug_handle,'reg40 posicion:valor_rubro ' 
  	  									||e.posicion_doc_presupuestal||':'||e.VALOR_RUBRO);   
      mi_szLinea     := 'P' || chr(09) || '40' || chr(09) ||
                        e.cuenta_credito || chr(09) || chr(09) || chr(09) ||
                        chr(09) || chr(09) || e.VALOR_RUBRO || chr(09) || ' ' ||
                        chr(09) || e.rp_doc_presupuestal || chr(09) || e.posicion_doc_presupuestal  ; 
      Text_IO.Put_Line(mi_archivo_sap, mi_szLinea);
  end loop;

  OPEN c_ra;
  LOOP
    FETCH c_ra
      INTO mi_ra_type;
    EXIT WHEN c_ra%NOTFOUND;
    IF mi_ra_type.mi_aprobado = 'N' THEN
      pr_despliega_mensaje('AL_STOP_1',
                           'No se ha aprobado la relación de autorización.');
      RAISE Form_Trigger_Failure;
    END IF;
  
    mi_consecutivo := 0;
  
    -- recorrer por los rubros registrados 
    -- message(' planos '||mi_archivo_planosap|| mi_ra_type.mi_nro_ra);
  
    mi_BancoRef := p_bintablas.tbuscar('BANCO_REFERENCIA',
                                       'NOMINA',
                                       'PARAMETROS NOMINA',
                                       TO_CHAR(SYSDATE, 'dd/mm/yyyy'));
    IF mi_BancoRef IS NULL THEN
      pr_despliega_mensaje('AL_STOP_1',
                           'No se encuentra definido el pará¡metro NOMINA/PARAMETROS NOMINA/BANCO_REFERENCIA. Se generará¡ un solo archivo para el pago a funcionarios.');
      RETURN;
    END IF;
    mi_directorio_carga := p_bintablas.tbuscar('DIRECTORIO_PAGINA_CARGA',
                                               'NOMINA',
                                               'PATH',
                                               TO_CHAR(SYSDATE, 'dd/mm/yyyy'));
    IF mi_directorio_carga IS NULL THEN
      pr_despliega_mensaje('AL_STOP_1',
                           'No se encuentra definido el pará¡metro DIRECTORIO_PAGINA_CARGA.  Por favor revise.');
      RETURN;
    END IF;
    mi_pagina_carga := p_bintablas.tbuscar('WWW_PAGINA_CARGA',
                                           'NOMINA',
                                           'PATH',
                                           TO_CHAR(SYSDATE, 'dd/mm/yyyy'));
    IF mi_pagina_carga IS NULL THEN
      pr_despliega_mensaje('AL_STOP_1',
                           'No se encuentra definido el pará¡metro WWW_PAGINA_CARGA.  Por favor revise.');
      RETURN;
    END IF;
    mi_grupo_ra := p_bintablas.tbuscar(un_grupo_ra,
                                       'NOMINA',
                                       'RELACIONAUTORIZACION_GRUPOS_RA',
                                       TO_CHAR(SYSDATE, 'dd/mm/yyyy'));
    mi_vigencia := To_Char(una_fecha_final, 'YYYY');
    mi_mes      := To_Char(una_fecha_final, 'MM');
    --Para abrir el archivo que genera listado de terceros con pagos negativos
    mi_nombre_archivo_err := 'TERCEROS_NEGATIVOS.TXT';
    BEGIN
      IF GET_APPLICATION_PROPERTY(USER_INTERFACE) = 'WEB' THEN
        --mi_id_error      := text_io.fopen(mi_directorio_carga||'/'||mi_nombre_archivo_err, 'w');
        If Get_Application_Property(OPERATING_SYSTEM) Like '%WIN%' Then
          mi_id_error := text_io.fopen(mi_www_path || '\' ||
                                       mi_nombre_archivo_err,
                                       'w');
        Else
          mi_id_error := text_io.fopen(mi_www_path || '/' ||
                                       mi_nombre_archivo_err,
                                       'w');
        End If;
      ELSE
        mi_id_error := text_io.fopen('c:\' || mi_nombre_archivo_err, 'w');
      END IF;
      pr_debug_registra(mi_file_debug_handle,'651 mi_nombre_archivo_err :');
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
                             '1 Ocurrió un error ' || SQLERRM() || ' ' ||
                             SQLCODE());
        mi_err := 1;
        RETURN;
    END;
    text_io.put_line(mi_id_error, 'Terceros con pagos negativos');
    Text_IO.fClose(mi_id_error); --wn 20190515
    pr_debug_registra(mi_file_debug_handle,'670 Cierra Terceros con pagos negativos');
    mi_texto_nomina_mes :=  'Nomina '||TO_CHAR(SYSDATE, 'FMMONTH', 'NLS_DATE_LANGUAGE = Spanish');
    mi_cuentareg := 0;
  	
    mi_archivo_planosapfoncep := :B_RA_SEQ.secuencial || '-nominafoncep' ||
                                 una_compania ||
                                 to_char(sysdate, 'yyyymmddhhmiss') ||
                                 to_char(una_fecha_final, 'yyyymm') ||
                                 '.txt';
		if get_application_property(OPERATING_SYSTEM) Like '%WIN%' Then                                 
    	mi_archivo_sap_foncep := text_io.fopen(mi_www_path || '\' ||
                                               mi_archivo_planosapfoncep,
                                               'w');
		else
			mi_archivo_sap_foncep := text_io.fopen(mi_www_path || '/' ||
                                               mi_archivo_planosapfoncep,
                                               'w');
		end if;
    pr_debug_registra(mi_file_debug_handle,'689 open mi_archivo_sap_foncep');
    for e in encabezado(un_grupo_ra) loop
      mi_szLinea := 'C' || chr(09) || e.NDOC || chr(09) ||
                    to_char(sysdate, 'yyyymmdd') || chr(09) || e.CLASEDOC ||
                    chr(09) || e.SOCIEDAD || chr(09) || e.FCONTAB ||
                    chr(09) || e.PERIODO || chr(09) || e.MONEDA || chr(09) ||
                    e.CAMBIO || chr(09) || e.NRODOC || chr(09) || '10' ||
                    e.CABECERA;
      mi_texto   := 'NA '; --N/A'e.CABECERA||to_char(una_fecha_final,'yyyymm');
      Text_IO.Put_Line(mi_archivo_sap_foncep, mi_szLinea);
    end loop;
    for r in rubros(mi_ra_type.mi_nro_ra) loop
    
      for d in descc(r.rubro) loop
        mi_nombrecc := d.nombrecc;
      end loop;
      mi_nro_ra     := mi_ra_type.mi_nro_ra;
      mi_pago_rubro := fn_pago_rubrosap(r.rubro,
                                        una_fecha_final,
                                        mi_ra_type.mi_nro_ra,
                                        un_tipo_nomina,
                                        un_grupo_ra,
                                        un_tipo_ra);
      mi_cuentarub  := FN_CUENTA_RUBROSAP(r.rubro);
    
      mi_codigo     := 31;
      mi_basertfte  := ' ';
      mi_retefuente := ' ';
    
      /* for p in pagorubronxp (r.rubro,mi_nro_ra) loop
              mi_szLinea2 :=r.rubro||' Detalle=' ||mi_nombrecc;          
                 Text_IO.Put_Line( mi_archivo_sap, mi_szLinea2 );
      end loop;  */
      pr_debug_registra(mi_file_debug_handle,'746 Inicia cur_anexos');
      OPEN cur_anexos(r.rubro);
      LOOP
        FETCH cur_anexos
          INTO mi_cc, mi_descripcion_cc, mi_archivo_plano, mi_tabla_detalle;
        EXIT WHEN cur_anexos%NOTFOUND;
        --FTV PRUEBA 202405 linea para mostrar en caso de error.
       /* mi_linea_ejecutada := 'FETCH cur_anexos mi_cc||mi_archivo_plano||mi_tabla_detalle :' ||
                              mi_cc || '|' || mi_archivo_plano || '|' ||
                              mi_tabla_detalle;*/
        pr_debug_registra(mi_file_debug_handle,'756 Inicia cur_anexos');
        if r.rubro in (9, 2, 3, 4, 5, 10, 11, 13, 14, 15, 18, 19, 20, 21) then
          if r.rubro in (13 /*FTV20211205 ,21*/
             ) then
            mi_viapago := 'C';
          else
            mi_viapago := 'M';
          end if;
        else
          mi_viapago := ' ';
        end if;
      
        IF UPPER(mi_descripcion_cc) LIKE '%NOMINA%' THEN
          BEGIN
            OPEN cur_nxp(mi_ra_type.mi_nro_ra, r.rubro);
            LOOP
              FETCH cur_nxp
                INTO mi_funcionario, mi_valor, mi_banco;
              EXIT WHEN cur_nxp%NOTFOUND;
              --FTV PRUEBA 202405 linea para mostrar en caso de error.
              mi_linea_ejecutada := 'FETCH cur_nxp INTO mi_funcionario mi_funcionario||mi_valor||mi_banco:' ||
                                    mi_funcionario || '|' || mi_valor || '|' ||
                                    mi_banco;
              pr_debug_registra(mi_file_debug_handle,'773 '||mi_linea_ejecutada);
              mi_persona_type := pk_detalle_anexos_ra.fn_detalle_personas(mi_funcionario,
                                                                          mi_err);
              IF mi_err = 1 THEN
                pr_despliega_mensaje('AL_STOP_1',
                                     'Ocurrió un error al recuperar información de personas :' ||
                                     mi_funcionario);
                RAISE Form_Trigger_Failure;
              END IF;
              mi_funcionario_type := pk_detalle_anexos_ra.fn_detalle_funcionario(mi_funcionario,
                                                                                 mi_err);
              IF mi_err = 1 THEN
                pr_despliega_mensaje('AL_STOP_1',
                                     'Ocurrió un error al recuperar información de funcionarios :' ||
                                     mi_funcionario);
                RAISE Form_Trigger_Failure;
              END IF;
              IF mi_funcionario_type.mi_forma_pago IS NULL THEN
                pr_despliega_mensaje('AL_STOP_1',
                                     'No se ha registrado la forma de pago para el funcionario ' ||
                                     mi_funcionario);
                RAISE Form_Trigger_Failure;
              END IF;
            
              mi_codigo := 31;
            
              mi_cuentareg := mi_cuentareg + 1;
              -- 20200914  adicionar por cambio en plantilla de SHD
            
              for j in retefteperiodo(mi_ra_type.mi_nro_ra) loop
                begin
                
                  mi_basertfte  := j.base;
                  mi_retefuente := j.retencion;
                  mi_asignacion := j.asignacion;
                  mi_var90rete  := 90;
                exception
                  when others then
                    mi_basertfte  := ' ';
                    mi_retefuente := ' ';
                    mi_asignacion := ' ';
                end;
              end loop;
            
              -- 20200914  para registro 50se quita debe controlarse adicionarse solo en el primer registro de Nomina por pagar
            
              mi_codigo := 31;
              if mi_cuentareg > 1 then
                mi_basertfte  := ' ';
                mi_retefuente := ' ';
                mi_asignacion := '';
                mi_var90rete  := ' ';
              else
                -- Ajuste solicitado Secretaria de Hacienda 20201203- abono retencion en la fuente a funcionarios
                mi_valor := mi_valor;
                --mi_valor:=mi_valor+nvl(mi_retefuente,0);
              end if;
            
              IF un_tipo_ra = '1' THEN
                IF mi_funcionario_type.mi_tipo_cuenta like '%A%' THEN
                  mi_tipo_cuentafun := '02';
                elsif mi_funcionario_type.mi_tipo_cuenta like '%C%' then
                  mi_tipo_cuentafun := '01';
                else
                  mi_tipo_cuentafun := '  ';
                END IF;
              
                -- obtner ach sap
                for b in codach(mi_banco) loop
                  mi_codbanco := b.codigo_ach;
                end loop;
              
                --INI PRUEBA FTV20240619
                if mi_persona_type.mi_nro_doc = 3102899 then
                  message('Puedes ubicar un breakpoint aqui');
                end if;
              
                --FIN FTV20240619
              
                mi_szLinea := 'P' || chr(09) || mi_codigo || chr(09) ||
                              chr(09) ||
                              rpad(mi_persona_type.mi_tipo_doc, 2, ' ') ||
                              chr(09) ||
                              rpad(mi_persona_type.mi_nro_doc, 12, ' ') ||
                              chr(09) || chr(09) || mi_cuentarub || chr(09) ||
                              mi_valor;
                mi_szLinea := mi_szLinea || chr(09) || chr(09) || chr(09) ||
                              chr(09) || chr(09) || chr(09) || chr(09) ||
                              chr(09) || chr(09) || chr(09) || chr(09) ||
                              chr(09) || chr(09) || chr(09) || chr(09);
                mi_szLinea := mi_szLinea || chr(09) || mi_condicion_pago ||
                              chr(09) || mi_texto || chr(09) || mi_texto_nomina_mes ||
                              chr(09) || chr(09) || chr(09) || chr(09) ||
                              mi_viapago || chr(09) || chr(09) || chr(09) ||
                              chr(09) || chr(09) || chr(09) || chr(09) ||
                              lpad(mi_codbanco, 3, 0) || chr(09) ||
                              rpad(mi_funcionario_type.mi_numero_cuenta,
                                   20,
                                   ' ') || chr(09) ||
                              rpad(mi_tipo_cuentafun, 2, ' ');
                --20200914 mi_szLinea :=mi_szLinea||chr(09)||'  '||chr(09)||mi_basertfte||chr(09)||chr(09)||chr(09)||chr(09);          
                mi_szLinea := mi_szLinea || chr(09) || '  ' || mi_var90rete ||
                              chr(09) || mi_var90rete || chr(09) ||
                              mi_asignacion || chr(09) || mi_retefuente ||
                              chr(09);
                Text_IO.Put_Line(mi_archivo_sap, mi_szLinea);
              
              ELSE
                mi_basertfte  := ' ';
                mi_retefuente := ' ';
                IF mi_funcionario_type.mi_tipo_cuenta like '%A%' THEN
                  mi_tipo_cuentafun := '02';
                elsif mi_funcionario_type.mi_tipo_cuenta like '%C%' then
                  mi_tipo_cuentafun := '01';
                else
                  mi_tipo_cuentafun := '  ';
                END IF;
              
                -- obtner ach sap
                for b in codach(mi_banco) loop
                  mi_codbanco := b.codigo_ach;
                end loop;
                mi_szLinea := 'P' || chr(09) || mi_codigo || chr(09) ||
                              chr(09) ||
                              rpad(mi_persona_type.mi_tipo_doc, 2, ' ') ||
                              chr(09) ||
                              rpad(mi_persona_type.mi_nro_doc, 12, ' ') ||
                              chr(09) || chr(09) || mi_cuentarub || chr(09) ||
                              mi_valor;
                mi_szLinea := mi_szLinea || chr(09) || chr(09) || chr(09) ||
                              chr(09) || chr(09) || chr(09) || chr(09) ||
                              chr(09) || chr(09) || chr(09) || chr(09) ||
                              chr(09) || chr(09) || chr(09) || chr(09);
                mi_szLinea := mi_szLinea || chr(09) || mi_condicion_pago ||
                              chr(09) || mi_texto || chr(09) || chr(09) ||
                              chr(09) || chr(09) || chr(09) || chr(09) ||
                              mi_viapago || chr(09) || chr(09) || chr(09) ||
                              chr(09) || chr(09) || chr(09) ||
                              lpad(mi_codbanco, 3, 0) || chr(09) ||
                              rpad(mi_funcionario_type.mi_numero_cuenta,
                                   20,
                                   ' ') || chr(09) ||
                              rpad(mi_tipo_cuentafun, 2, ' ');
                mi_szLinea := mi_szLinea || chr(09) || '  ' || chr(09) ||
                              mi_basertfte || chr(09) || chr(09) || chr(09) ||
                              chr(09);
                Text_IO.Put_Line(mi_archivo_sap, mi_szLinea);
              
              END IF;
              IF mi_valor < 0 THEN
                text_io.put_line(mi_id_error,
                                 'Funcionario con pago negativo.  Cá©dula: ' ||
                                 mi_persona_type.mi_nro_doc || '. Valor: ' ||
                                 mi_valor);
                text_io.put_line(mi_id_error,
                                 'en la Relación de autorización ' ||
                                 mi_ra_type.mi_nro_ra);
                mi_terceros_neg := mi_terceros_neg + 1;
              END IF;
              -- Fargelm 20120719, Requeimiento 05
            END LOOP;
          
            CLOSE cur_nxp;
            pr_debug_registra(mi_file_debug_handle,'916 CLOSE cur_nxp');
            if mi_cc in (16) and un_tipo_ra = '2' then
              /* fna */
            
              mi_archivo_plano2 := una_compania || '_' || mi_vigencia || '_' ||
                                   mi_mes || '_' || mi_ra_type.mi_nro_ra ||
                                   'FNA';
              If Get_Application_Property(OPERATING_SYSTEM) Like '%WIN%' Then
                mi_archivo_path := Text_IO.FOpen(mi_www_path || '\' ||
                                                 mi_archivo_plano2,
                                                 'w');
              Else
                mi_archivo_path := Text_IO.FOpen(mi_www_path || '/' ||
                                                 mi_archivo_plano2,
                                                 'w');
              End If;
            
              --  message('FNA');
              OPEN cur_fna(mi_nro_ra);
              LOOP
                FETCH cur_fna
                  INTO mi_total_fna, mi_tiponit_ces, mi_nit_ces, forma_pagoces;
                EXIT WHEN cur_fna%NOTFOUND;
              
                if mi_funcionario_type.mi_tipo_cuenta = 'A' then
                  mi_funcionario_type.mi_tipo_cuenta := '02';
                elsif mi_funcionario_type.mi_tipo_cuenta = 'C' then
                  mi_funcionario_type.mi_tipo_cuenta := '01';
                else
                  mi_funcionario_type.mi_tipo_cuenta := '  ';
                end if;
              
                -- obtner ach sap
                for b in codach(mi_funcionario_type.mi_banco) loop
                  mi_codbanco := b.codigo_ach;
                end loop;
              
                for e in nom_entidad(mi_nit_ces) loop
                  mi_nombre_entidad := substr(e.nomentidad, 1, 50);
                end loop;
              
                mi_szLinea := 'P' || chr(09) || mi_codigo || chr(09) ||
                              chr(09) || rpad(mi_tiponit_ces, 3, ' ') ||
                              chr(09) || rpad(mi_nit_ces, 12, ' ') ||
                              chr(09) || chr(09) || mi_cuentarub || chr(09) ||
                              mi_valor;
                mi_szLinea := mi_szLinea || chr(09) || chr(09) || chr(09) ||
                              chr(09) || chr(09) || chr(09) || chr(09) ||
                              chr(09) || chr(09) || chr(09) || chr(09) ||
                              chr(09) || chr(09) || chr(09) || chr(09);
                mi_szLinea := mi_szLinea || chr(09) || mi_condicion_pago ||
                              chr(09) || mi_texto || chr(09) || chr(09) ||
                              chr(09) || chr(09) || chr(09) || chr(09) ||
                              mi_viapago || chr(09) || chr(09) || chr(09) ||
                              chr(09) || chr(09) || chr(09) || mi_codbanco ||
                              chr(09) || rpad(mi_funcionario_type.mi_numero_cuenta,
                                              20,
                                              ' ') || chr(09) ||
                              rpad(mi_tipo_cuentafun, 2, ' ');
                mi_szLinea := mi_szLinea || chr(09) || '  ' || chr(09) ||
                              mi_basertfte || chr(09) || chr(09) || chr(09) ||
                              chr(09);
              
                Text_IO.Put_Line(mi_archivo_path, mi_szLinea);
              
              end loop;
            
              CLOSE cur_fna;
              Text_IO.Put_Line(mi_archivo_path, 'linea fin');
              Text_IO.fClose(mi_archivo_path);
              web.show_document(mi_pathweb_ra || mi_archivo_plano2,
                                '_blank');
            end if;
          EXCEPTION
            WHEN OTHERS THEN
              IF SQLCODE = -302000 THEN
                pr_despliega_mensaje('AL_STOP_1',
                                     'Ocurrio un error intentando escribir el archivo ' ||
                                     mi_archivo_plano2);
              ELSE
                pr_despliega_mensaje('AL_STOP_1',
                                     'Ocurrió el error: ' ||
                                     To_Char(SQLCODE));
              END IF;
            
              RAISE Form_Trigger_Failure;
          END; --Anexo Neto de nómina
        
        ELSIF UPPER(mi_descripcion_cc) LIKE '%EMBARGO%' and mi_cc = 6 /*FTv*/ THEN
          BEGIN
            --FTV PRUEBA 202405 linea para mostrar en caso de error.
            mi_linea_ejecutada := 'mi_archivo_planoemb operating_system||mi_descripcion_cc ' ||
                                  Get_Application_Property(OPERATING_SYSTEM) ||
                                  mi_descripcion_cc;
          
            mi_archivo_planoemb := una_compania || '_' || mi_vigencia || '_' ||
                                   mi_mes || '_' ||
                                   to_char(sysdate, 'yyyymmddhhmiss') || '_' ||
                                   mi_ra_type.mi_nro_ra || '_' ||
                                   'Embargos.txt';
            If Get_Application_Property(OPERATING_SYSTEM) Like '%WIN%' Then
              mi_archivo_path := Text_IO.FOpen(mi_www_path || '\' ||
                                               mi_archivo_planoemb,
                                               'w');
            Else
              mi_archivo_path := Text_IO.FOpen(mi_www_path || '/' ||
                                               mi_archivo_planoemb,
                                               'w');
            End If;
            OPEN cur_embargos(mi_cc, mi_ra_type.mi_nro_ra);
            LOOP
              FETCH cur_embargos
                INTO mi_tercero, mi_funcionario, mi_sdescuento, mi_nbeneficiario, mi_codbeneficiario, mi_fpagobeneficiario, mi_concepto, mi_valor, mi_conceptoemb;
              EXIT WHEN cur_embargos%NOTFOUND;
            
              mi_embargo_type := pk_detalle_anexos_ra.fn_detalle_embargos(mi_tercero,
                                                                          mi_funcionario,
                                                                          mi_sdescuento,
                                                                          mi_err);
              IF mi_err = 1 THEN
                pr_despliega_mensaje('AL_STOP_1',
                                     'Ocurrió un error al recuperar información de os para el funcionario ' ||
                                     mi_funcionario);
                RAISE Form_Trigger_Failure;
              END IF;
              IF mi_embargo_type.mi_tipo_doc_benef_pago IS NULL OR
                 mi_embargo_type.mi_nro_doc_benef_pago IS NULL THEN
                pr_despliega_mensaje('AL_STOP_1',
                                     'No se encuentra registrado el beneficiario del pago para el o del funcionario ' ||
                                     mi_funcionario);
                RAISE Form_Trigger_Failure;
              END IF;
              IF mi_embargo_type.mi_forma_pago IS NULL THEN
                pr_despliega_mensaje('AL_STOP_1',
                                     'No se encuentra registrada la forma de pago para el o del funcionario ' ||
                                     mi_funcionario);
                RAISE Form_Trigger_Failure;
              END IF;
              mi_demandante_type  := pk_detalle_anexos_ra.fn_detalle_demandante(mi_tercero,
                                                                                mi_funcionario,
                                                                                mi_sdescuento,
                                                                                mi_err);
              mi_demandantes_type := pk_detalle_anexos_ra.fn_detalle_demandantes(mi_tercero,
                                                                                 mi_funcionario,
                                                                                 mi_sdescuento,
                                                                                 mi_err);
              IF mi_err = 1 THEN
                pr_despliega_mensaje('AL_STOP_1',
                                     'Ocurrió un error al recuperar información del demandante para el o para el funcionario ' ||
                                     mi_funcionario);
                RAISE Form_Trigger_Failure;
              END IF;
              IF mi_demandante_type.mi_nombre_ddte IS NULL THEN
                pr_despliega_mensaje('AL_STOP_1',
                                     'No se encuentra registrado el nombre del demandante para el o del funcionario ' ||
                                     mi_funcionario);
                RAISE Form_Trigger_Failure;
              END IF;
              mi_persona_type := pk_detalle_anexos_ra.fn_detalle_personas(mi_funcionario,
                                                                          mi_err);
              IF mi_err = 1 THEN
                pr_despliega_mensaje('AL_STOP_1',
                                     'Ocurrió un error al recuperar información de personas: ' ||
                                     mi_funcionario);
                RAISE Form_Trigger_Failure;
              END IF;
              -- RQ1849-2006    17/11/2006
            
              mi_beneficiario_type := pk_detalle_anexos_ra.fn_detalle_beneficiarios(TO_NUMBER(mi_tercero),
                                                                                    mi_err);
              IF mi_err = 1 THEN
                pr_despliega_mensaje('AL_STOP_1',
                                     'Eg1: Ocurrió un error al recuperar información de beneficiarios ' ||
                                     mi_tercero);
                RAISE Form_Trigger_Failure;
              END IF;
              -- Fin RQ1849-2006
            
              -- DOMINIOS DE BOGADATA
              IF mi_demandante_type.mi_tipo_doc_ddte = 'CC' THEN
                mi_demandante_type.mi_tipo_doc_ddte := 1;
              ELSIF mi_demandante_type.mi_tipo_doc_ddte = 'NIT' THEN
                mi_demandante_type.mi_tipo_doc_ddte := 3;
              ELSIF mi_demandante_type.mi_tipo_doc_ddte = 'CE' THEN
                mi_demandante_type.mi_tipo_doc_ddte := 2;
              ELSIF mi_demandante_type.mi_tipo_doc_ddte = 'PA' THEN
                mi_demandante_type.mi_tipo_doc_ddte := 4;
              ELSIF mi_demandante_type.mi_tipo_doc_ddte = 'TI' THEN
                mi_demandante_type.mi_tipo_doc_ddte := 5;
              END IF;
              /*IF mi_embargo_type.mi_concepto='EJECUTIVO' then
                mi_embargo_type.mi_concepto:=1;
              ELSIF mi_embargo_type.mi_concepto='POR ALIMENTOS' then
                mi_embargo_type.mi_concepto:=6;
              ELSIF mi_embargo_type.mi_concepto='CIVIL' then  
                mi_embargo_type.mi_concepto:=2;
              ELSIF mi_embargo_type.mi_concepto='COACTIVO' then  
                mi_embargo_type.mi_concepto:=2;
              end if;*/
              IF mi_conceptoemb = 'EJECUTIVO' then
                mi_concepto := 1;
              ELSIF mi_conceptoemb = 'POR ALIMENTOS' then
                mi_concepto := 6;
              ELSIF mi_conceptoemb = 'CIVIL' then
                mi_concepto := 2;
              ELSIF mi_conceptoemb = 'COACTIVO' then
                mi_concepto := 2;
              end if;
            
              IF mi_demandantes_type.mi_ban_destino IS NULL THEN
                mi_ofi_destino := '0010';
              ELSE
                mi_ofi_destino := mi_demandantes_type.mi_ban_destino;
              END IF;
            
              IF mi_demandantes_type.mi_ban_origen IS NULL THEN
                mi_ofi_origen := '0030';
              ELSE
                mi_ofi_origen := mi_demandantes_type.mi_ban_origen;
              END IF;
            
              mi_szLinea := una_compania || chr(09); -- segmento A
              mi_szLinea := mi_szLinea || rpad(abs(mi_valor), 10, ' ') ||
                            chr(09); -- valor del o  B
              mi_szLinea := mi_szLinea ||
                            mi_demandantes_type.mi_cod_juzgado || chr(09); -- codigo del juzgado C
              mi_szLinea := mi_szLinea || rpad(mi_ofi_destino, 4, ' ') ||
                            chr(09); --codigo_oficina destino D            
              mi_szLinea := mi_szLinea || rpad(mi_ofi_origen, 4, ' ') ||
                            chr(09); -- codigo oficina del banco agrario E
              --mi_szLinea :=mi_szLinea||rpad( nvl(mi_embargo_type.mi_numero_cuenta,''),30,' ')||chr(09);-- numerp de cuenta F
              mi_szLinea := mi_szLinea || rpad(nvl(0, ''), 10, ' ') ||
                            chr(09);
              mi_szLinea := mi_szLinea ||
                            substr(mi_demandantes_type.mi_proceso, 13, 12) ||
                            chr(09);
              --mi_szLinea :=mi_szLinea||rpad(mi_beneficiario_type.mi_nro_doc ,15,' ')||chr(09);-- numero de oficio del o G mi_o_type.mi_nro_oficio
              mi_szLinea := mi_szLinea || rpad(1, 10, ' ') || chr(09); -- >OJO
              mi_szLinea := mi_szLinea ||
                            rpad(mi_persona_type.mi_nro_doc, 20, ' ') ||
                            chr(09); -- benficiario documento I
              --mi_szLinea :=mi_szLinea||mi_persona_type.mi_primer_apellido||' '||mi_persona_type.mi_segundo_apellido||chr(09);-- apellidos demandado J
              --mi_szLinea :=mi_szLinea||rpad(mi_persona_type.mi_nombre,40,' ')||chr(09);-- nombre demandado K
              mi_szLinea := mi_szLinea || rpad((mi_persona_type.mi_primer_apellido || ' ' ||
                                               mi_persona_type.mi_segundo_apellido ||
                                               mi_persona_type.mi_nombre),
                                               80,
                                               ' ') || chr(09);
              mi_szLinea := mi_szLinea || rpad(mi_demandante_type.mi_tipo_doc_ddte,
                                               20,
                                               ' ') || chr(09); -- tipo documento L
              mi_szLinea := mi_szLinea || rpad(mi_demandante_type.mi_nro_doc_ddte,
                                               20,
                                               ' ') || chr(09); -- Numero documento M
              mi_szLinea := mi_szLinea || rpad(mi_concepto, 30, ' ') ||
                            chr(09); -- concepto demandante N
              if mi_demandantes_type.mi_apellidos_ddte = ' ' then
                mi_szLinea := mi_szLinea || rpad(mi_demandantes_type.mi_nombre_ddte,
                                                 30,
                                                 ' ') || chr(09); -- apellidos demandante O
              else
                mi_szLinea := mi_szLinea || rpad(mi_demandantes_type.mi_apellidos_ddte,
                                                 30,
                                                 ' ') || chr(09); -- apellidos demandante O
              end if;
              mi_szLinea := mi_szLinea || rpad(mi_demandantes_type.mi_nombre_ddte,
                                               40,
                                               ' ') || chr(09); -- Nombre  demandante P
              -- mi_szLinea :=mi_szLinea||mi_embargo_type.mi_concepto||chr(09);  -- numero expediente Q
              mi_szLinea := mi_szLinea || mi_demandantes_type.mi_proceso ||
                            chr(09); -- numero expediente Q
              mi_szLinea := mi_szLinea || rpad(:B_RA.CTA_X_NOMINA, 10, ' ') ||
                            chr(09);
              Text_IO.Put_Line(mi_archivo_path, mi_szLinea);
              /* adicionar lineas banco agrario 20201021 */
              mi_szLinea := 'P' || chr(09) || mi_codigo || chr(09) ||
                            chr(09) || 'NIT' || chr(09) ||
                            rpad(mi_nit_agrario, 12, ' ') || chr(09) ||
                            chr(09) || mi_cuentarub || chr(09) ||
                            abs(mi_valor);
              mi_szLinea := mi_szLinea || chr(09) || chr(09) || chr(09) ||
                            chr(09) || chr(09) || chr(09) || chr(09) ||
                            chr(09) || chr(09) || chr(09) || chr(09) ||
                            chr(09) || chr(09) || chr(09) || chr(09);
              mi_szLinea := mi_szLinea || chr(09) || mi_condicion_pago ||
                            chr(09) || mi_texto || chr(09) || chr(09) ||
                            chr(09) || chr(09) || chr(09) || chr(09) || 'B' ||
                            chr(09) || chr(09) || chr(09) || chr(09) ||
                            chr(09) || chr(09) || chr(09) || chr(09) ||
                            chr(09) || chr(09) || chr(09);
              mi_szLinea := mi_szLinea || chr(09) || chr(09) || chr(09) ||
                            chr(09) || chr(09) || chr(09) || chr(09) ||
                            chr(09);
              --Text_IO.Put_Line( mi_archivo_planoemb, mi_szLinea ); 
              Text_IO.Put_Line(mi_archivo_sap, mi_szLinea);
            
            END LOOP;
           	
            CLOSE cur_embargos;
          
            Text_IO.fClose(mi_archivo_path);
            
            web.show_document(mi_pathweb_ra||mi_archivo_planoemb,'_blank');
          
            ------------ otros embargos se adicionan al archivo de Nomina 20200708
            /*   mi_archivo_planoemb:=una_compania||'_'||mi_vigencia||'_'||mi_mes||'_'||to_char(sysdate,'yyyymmddhhmiss')||'_'||mi_ra_type.mi_nro_ra||'_'||'osnba.txt';
                   If Get_Application_Property(OPERATING_SYSTEM) Like '%WIN%' Then
                     mi_archivo_path := Text_IO.FOpen( mi_www_path || '\' || mi_archivo_planoemb, 'w' );
                   Else
                     mi_archivo_path := Text_IO.FOpen( mi_www_path || '/' || mi_archivo_planoemb, 'w' );
                   End If;
            for e in encabezado(un_grupo_ra) loop
                       --mi_szLinea := 'C'||chr(09)|| to_char(una_fecha_final,'ddmmyyyy')||chr(09)||e.NDOC||chr(09)||e.CLASEDOC||chr(09)||e.SOCIEDAD||chr(09)||e.FCONTAB||chr(09)||e.PERIODO||chr(09)||e.MONEDA||chr(09)||e.CAMBIO||chr(09)||e.NRODOC||chr(09)||e.CABECERA;
                       mi_szLinea := 'C'||chr(09)||e.NDOC||chr(09)|| to_char(una_fecha_final,'ddmmyyyy')||chr(09)||e.CLASEDOC||chr(09)||e.SOCIEDAD||chr(09)||e.FCONTAB||chr(09)||e.PERIODO||chr(09)||e.MONEDA||chr(09)||e.CAMBIO||chr(09)||e.NRODOC||chr(09)||'10'||e.CABECERA;
                       Text_IO.Put_Line( mi_archivo_path, mi_szLinea );
                  end loop;
                   */
            pr_debug_registra(mi_file_debug_handle,'1232 voy a  OPEN cur_embargosnba(mi_cc, mi_ra_type.mi_nro_ra)');       
            OPEN cur_embargosnba(mi_cc, mi_ra_type.mi_nro_ra);
            LOOP
              FETCH cur_embargosnba
                INTO mi_tercero, mi_funcionario, mi_sdescuento, mi_nbeneficiario, mi_fpagobeneficiario, mi_codbeneficiario, mi_bancoemb, mi_tipo_cuenta_emb, mi_numero_cuenta_emb, mi_proceso, mi_valor;
              EXIT WHEN cur_embargosnba%NOTFOUND;
            
              --FTV PRUEBA 202405 linea para mostrar en caso de error.
              mi_linea_ejecutada := 'FETCH cur_embargosnba INTO mi_tercero||mi_funcionario||mi_sdescuento||mi_nbeneficiario:' ||
                                    mi_tercero || '|' || mi_funcionario || '|' ||
                                    mi_sdescuento || '|' ||
                                    mi_nbeneficiario;
            
              mi_embargo_type := pk_detalle_anexos_ra.fn_detalle_embargos(mi_tercero,
                                                                          mi_funcionario,
                                                                          mi_sdescuento,
                                                                          mi_err);
              IF mi_err = 1 THEN
                pr_despliega_mensaje('AL_STOP_1',
                                     'Ocurrió un error al recuperar información de os para el funcionario ' ||
                                     mi_funcionario);
                RAISE Form_Trigger_Failure;
              END IF;
              IF mi_embargo_type.mi_tipo_doc_benef_pago IS NULL OR
                 mi_embargo_type.mi_nro_doc_benef_pago IS NULL THEN
                pr_despliega_mensaje('AL_STOP_1',
                                     'No se encuentra registrado el beneficiario del pago para el o del funcionario ' ||
                                     mi_funcionario);
                RAISE Form_Trigger_Failure;
              END IF;
              IF mi_embargo_type.mi_forma_pago IS NULL THEN
                pr_despliega_mensaje('AL_STOP_1',
                                     'No se encuentra registrada la forma de pago para el o del funcionario ' ||
                                     mi_funcionario);
                RAISE Form_Trigger_Failure;
              END IF;
              mi_demandante_type  := pk_detalle_anexos_ra.fn_detalle_demandante(mi_tercero,
                                                                                mi_funcionario,
                                                                                mi_sdescuento,
                                                                                mi_err);
              mi_demandantes_type := pk_detalle_anexos_ra.fn_detalle_demandantes(mi_tercero,
                                                                                 mi_funcionario,
                                                                                 mi_sdescuento,
                                                                                 mi_err);
              IF mi_err = 1 THEN
                pr_despliega_mensaje('AL_STOP_1',
                                     'Ocurrió un error al recuperar información del demandante para el o para el funcionario ' ||
                                     mi_funcionario);
                RAISE Form_Trigger_Failure;
              END IF;
              IF mi_demandante_type.mi_nombre_ddte IS NULL THEN
                pr_despliega_mensaje('AL_STOP_1',
                                     'No se encuentra registrado el nombre del demandante para el o del funcionario ' ||
                                     mi_funcionario);
                RAISE Form_Trigger_Failure;
              END IF;
              mi_persona_type := pk_detalle_anexos_ra.fn_detalle_personas(mi_funcionario,
                                                                          mi_err);
              IF mi_err = 1 THEN
                pr_despliega_mensaje('AL_STOP_1',
                                     'Ocurrió un error al recuperar información de personas: ' ||
                                     mi_funcionario);
                RAISE Form_Trigger_Failure;
              END IF;
              -- RQ1849-2006    17/11/2006
            
              mi_beneficiario_type := pk_detalle_anexos_ra.fn_detalle_beneficiarios(TO_NUMBER(mi_tercero),
                                                                                    mi_err);
              IF mi_err = 1 THEN
                pr_despliega_mensaje('AL_STOP_1',
                                     'Eg2: Ocurrió un error al recuperar información de beneficiarios ' ||
                                     mi_tercero);
                RAISE Form_Trigger_Failure;
              END IF;
              -- Fin RQ1849-2006
            
              -- DOMINIOS DE BOGADATA
              /*IF mi_demandante_type.mi_tipo_doc_ddte='CC' THEN
                   mi_demandante_type.mi_tipo_doc_ddte:=1;
              ELSIF mi_demandante_type.mi_tipo_doc_ddte='NIT' THEN
                 mi_demandante_type.mi_tipo_doc_ddte:=3;
              ELSIF mi_demandante_type.mi_tipo_doc_ddte='CE' THEN
                mi_demandante_type.mi_tipo_doc_ddte:=2;
              ELSIF mi_demandante_type.mi_tipo_doc_ddte='PA' THEN
                mi_demandante_type.mi_tipo_doc_ddte:=4;
                ELSIF mi_demandante_type.mi_tipo_doc_ddte='TI' THEN
                mi_demandante_type.mi_tipo_doc_ddte:=5;
                END IF;*/
              IF mi_embargo_type.mi_concepto = 'EJECUTIVO' then
                mi_embargo_type.mi_concepto := 1;
              ELSIF mi_embargo_type.mi_concepto = 'POR ALIMENTOS' then
                mi_embargo_type.mi_concepto := 6;
              ELSIF mi_embargo_type.mi_concepto = 'CIVIL' then
                mi_embargo_type.mi_concepto := 2;
              ELSIF mi_embargo_type.mi_concepto = 'COACTIVO' then
                mi_embargo_type.mi_concepto := 2;
              end if;
            
              if mi_tipo_cuenta_emb = 'A' then
                mi_tipo_cuenta_emb := '02';
              elsif mi_tipo_cuenta_emb = 'C' then
                mi_tipo_cuenta_emb := '01';
              else
                mi_tipo_cuenta_emb := '  ';
              end if;
            
              /*  mi_szLinea :=una_compania||chr(09);-- segmento A
               mi_szLinea :=mi_szLinea||rpad(abs(mi_valor),16,' ')||chr(09);-- valor del embargo  B
               mi_szLinea :=mi_szLinea||mi_demandantes_type.mi_cod_juzgado||chr(09);-- codigo del juzgado C
               mi_szLinea :=mi_szLinea||rpad(' ',30,' ')||chr(09);--codigo_oficina destino D            
               mi_szLinea :=mi_szLinea||' '||chr(09);-- codigo oficina del banco agrario E
               mi_szLinea :=mi_szLinea||rpad( nvl(mi_embargo_type.mi_numero_cuenta,''),30,' ')||chr(09);-- numerp de cuenta F
               mi_szLinea :=mi_szLinea||rpad(mi_beneficiario_type.mi_nro_doc ,15,' ')||chr(09);-- numero de oficio del embargo G mi_embargo_type.mi_nro_oficio
               mi_szLinea :=mi_szLinea||rpad(1,30,' ')||chr(09);-- >H
               mi_szLinea :=mi_szLinea||rpad(mi_persona_type.mi_nro_doc,30,' ')||chr(09);-- benficiario documento I
               mi_szLinea :=mi_szLinea||mi_persona_type.mi_primer_apellido||mi_persona_type.mi_segundo_apellido||chr(09);-- apellidos demandado J
               mi_szLinea :=mi_szLinea||rpad(mi_persona_type.mi_nombre,40,' ')||chr(09);-- nombre demandado K
               mi_szLinea :=mi_szLinea||rpad(mi_demandante_type.mi_tipo_doc_ddte,30,' ')||chr(09);-- tipo documento L
               mi_szLinea :=mi_szLinea||mi_demandante_type.mi_nro_doc_ddte||chr(09);-- Numero documento M
               mi_szLinea :=mi_szLinea||mi_embargo_type.mi_concepto||chr(09);-- concepto demandante N
               mi_szLinea :=mi_szLinea||rpad(mi_demandantes_type.mi_apellidos_ddte,30,' ')||chr(09); -- apellidos demandante O
              mi_szLinea :=mi_szLinea||mi_demandantes_type.mi_nombre_ddte||chr(09);  -- Nombre  demandante P
              mi_szLinea :=mi_szLinea||mi_embargo_type.mi_nro_oficio||chr(09);  -- numero expediente Q*/
              mi_szLinea := 'P' || chr(09) || mi_codigo || chr(09) ||
                            chr(09) || rpad(mi_demandante_type.mi_tipo_doc_ddte,
                                            2,
                                            ' ') || chr(09) ||
                            rpad(mi_demandante_type.mi_nro_doc_ddte,
                                 12,
                                 ' ') || chr(09) || chr(09) || mi_cuentarub ||
                            chr(09) || abs(mi_valor);
              mi_szLinea := mi_szLinea || chr(09) || chr(09) || chr(09) ||
                            chr(09) || chr(09) || chr(09) || chr(09) ||
                            chr(09) || chr(09) || chr(09) || chr(09) ||
                            chr(09) || chr(09) || chr(09) || chr(09);
              mi_szLinea := mi_szLinea || chr(09) || mi_condicion_pago ||
                            chr(09) || mi_texto || chr(09) || chr(09) ||
                            chr(09) || chr(09) || chr(09) || chr(09) ||
                            mi_viapago || chr(09) || chr(09) || chr(09) ||
                            chr(09) || chr(09) || chr(09) ||
                            lpad(mi_bancoemb, 3, 0) || chr(09) ||
                            rpad(mi_numero_cuenta_emb, 20, ' ') || chr(09) ||
                            rpad(mi_tipo_cuenta_emb, 2, ' ');
              mi_szLinea := mi_szLinea || chr(09) || '  ' || chr(09) ||
                            mi_basertfte || chr(09) || chr(09) || chr(09) ||
                            chr(09);
              --Text_IO.Put_Line( mi_archivo_planoemb, mi_szLinea ); 
              Text_IO.Put_Line(mi_archivo_sap, mi_szLinea);
            END LOOP;
          
            CLOSE cur_embargosnba;
          	Text_IO.Put_Line(mi_archivo_path, 'linea fin');
            Text_IO.fClose(mi_archivo_path);
            web.show_document(mi_pathweb_ra ||'/'|| mi_archivo_planoemb,
                              '_blank');
          
          EXCEPTION
            WHEN OTHERS THEN
              IF SQLCODE = -302000 THEN
                pr_despliega_mensaje('AL_STOP_1',
                                     'Ocurrio un error intentando escribir el archivo ' ||
                                     mi_archivo_planoemb);
              ELSE
                pr_despliega_mensaje('AL_STOP_1',
                                     'Ocurrió el error: ' ||
                                     To_Char(SQLCODE));
              END IF;
              IF Text_IO.Is_Open(mi_archivo_path) THEN
                Text_IO.fClose(mi_archivo_path);
              END IF;
              RAISE Form_Trigger_Failure;
          END; --Anexo Embargos
          /*  no requiere encabezadpo for e in encabezado(un_grupo_ra) loop
             --mi_szLinea := 'C'||chr(09)|| to_char(una_fecha_final,'ddmmyyyy')||chr(09)||e.NDOC||chr(09)||e.CLASEDOC||chr(09)||e.SOCIEDAD||chr(09)||e.FCONTAB||chr(09)||e.PERIODO||chr(09)||e.MONEDA||chr(09)||e.CAMBIO||chr(09)||e.NRODOC||chr(09)||e.CABECERA;
             mi_szLinea := 'C'||chr(09)||e.NDOC||chr(09)|| to_char(una_fecha_final,'ddmmyyyy')||chr(09)||e.CLASEDOC||chr(09)||e.SOCIEDAD||chr(09)||e.FCONTAB||chr(09)||e.PERIODO||chr(09)||e.MONEDA||chr(09)||e.CAMBIO||chr(09)||e.NRODOC||chr(09)||'10'||e.CABECERA;
             Text_IO.Put_Line( mi_archivo_path, mi_szLinea );
          end loop;*/
        
          /*  OPEN cur_embargos(mi_cc, mi_ra_type.mi_nro_ra);
            LOOP
              FETCH cur_embargos INTO mi_tercero, mi_funcionario, mi_sdescuento, mi_valor;
              EXIT WHEN cur_embargos%NOTFOUND;
              
            
            mi_embargo_type:=pk_detalle_anexos_ra.fn_detalle_embargos(mi_tercero, mi_funcionario, mi_sdescuento, mi_err); 
              IF mi_err = 1 THEN
                  pr_despliega_mensaje('AL_STOP_1','Ocurrió un error al recuperar información de embargos para el funcionario ' || mi_funcionario);
                  RAISE Form_Trigger_Failure;
              END IF;    
              IF mi_embargo_type.mi_tipo_doc_benef_pago IS NULL OR
                  mi_embargo_type.mi_nro_doc_benef_pago  IS NULL THEN
                  pr_despliega_mensaje('AL_STOP_1','No se encuentra registrado el beneficiario del pago para el embargo del funcionario ' || mi_funcionario);
                 RAISE Form_Trigger_Failure;
              END IF;
              IF mi_embargo_type.mi_forma_pago IS NULL THEN
                  pr_despliega_mensaje('AL_STOP_1','No se encuentra registrada la forma de pago para el embargo del funcionario ' || mi_funcionario);
                  RAISE Form_Trigger_Failure;
              END IF;
              mi_demandante_type:=pk_detalle_anexos_ra.fn_detalle_demandante(mi_tercero, mi_funcionario, mi_sdescuento, mi_err);
               mi_demandantes_type:=pk_detalle_anexos_ra.fn_detalle_demandantes(mi_tercero, mi_funcionario, mi_sdescuento, mi_err);
              IF mi_err = 1 THEN
                  pr_despliega_mensaje('AL_STOP_1','Ocurrió un error al recuperar información del demandante para el embargo para el funcionario ' || mi_funcionario);
                  RAISE Form_Trigger_Failure;
              END IF;
              IF mi_demandante_type.mi_nombre_ddte IS NULL THEN
                  pr_despliega_mensaje('AL_STOP_1','No se encuentra registrado el nombre del demandante para el embargo del funcionario ' || mi_funcionario);
                  RAISE Form_Trigger_Failure;
              END IF;
              mi_persona_type:=pk_detalle_anexos_ra.fn_detalle_personas (mi_funcionario, mi_err);
              IF mi_err = 1 THEN
                  pr_despliega_mensaje('AL_STOP_1','Ocurrió un error al recuperar información de personas: ' || mi_funcionario);
                  RAISE Form_Trigger_Failure;
              END IF;
             -- RQ1849-2006    17/11/2006
             
             mi_beneficiario_type:=pk_detalle_anexos_ra.fn_detalle_beneficiarios(TO_NUMBER(mi_tercero), mi_err);
             IF mi_err = 1 THEN
                 pr_despliega_mensaje('AL_STOP_1','Ocurrió un error al recuperar información de beneficiarios ' || mi_tercero);
                 RAISE Form_Trigger_Failure;
             END IF;
             -- Fin RQ1849-2006
             
           -- DOMINIOS DE BOGADATA
              IF mi_demandante_type.mi_tipo_doc_ddte='CC' THEN
                   mi_demandante_type.mi_tipo_doc_ddte:=1;
              ELSIF mi_demandante_type.mi_tipo_doc_ddte='NIT' THEN
                 mi_demandante_type.mi_tipo_doc_ddte:=3;
              ELSIF mi_demandante_type.mi_tipo_doc_ddte='CE' THEN
                mi_demandante_type.mi_tipo_doc_ddte:=2;
              ELSIF mi_demandante_type.mi_tipo_doc_ddte='PA' THEN
                mi_demandante_type.mi_tipo_doc_ddte:=4;
                ELSIF mi_demandante_type.mi_tipo_doc_ddte='TI' THEN
                mi_demandante_type.mi_tipo_doc_ddte:=5;
                END IF;
                IF mi_embargo_type.mi_concepto='EJECUTIVO' then
                  mi_embargo_type.mi_concepto:=1;
                ELSIF mi_embargo_type.mi_concepto='POR ALIMENTOS' then
                  mi_embargo_type.mi_concepto:=6;
                ELSIF mi_embargo_type.mi_concepto='CIVIL' then  
                  mi_embargo_type.mi_concepto:=2;
                ELSIF mi_embargo_type.mi_concepto='COACTIVO' then  
                  mi_embargo_type.mi_concepto:=2;
                end if;
               mi_szLinea :=una_compania||chr(09);-- segmento A
               mi_szLinea :=mi_szLinea||rpad(abs(mi_valor),16,' ')||chr(09);-- valor del embargo  B
               mi_szLinea :=mi_szLinea||mi_demandantes_type.mi_cod_juzgado||chr(09);-- codigo del juzgado C
               mi_szLinea :=mi_szLinea||rpad(' ',30,' ')||chr(09);--codigo_oficina destino D            
               mi_szLinea :=mi_szLinea||' '||chr(09);-- codigo oficina del banco agrario E
               mi_szLinea :=mi_szLinea||rpad( nvl(mi_embargo_type.mi_numero_cuenta,''),30,' ')||chr(09);-- numerp de cuenta F
               mi_szLinea :=mi_szLinea||rpad(mi_beneficiario_type.mi_nro_doc ,15,' ')||chr(09);-- numero de oficio del embargo G mi_embargo_type.mi_nro_oficio
               mi_szLinea :=mi_szLinea||rpad(1,30,' ')||chr(09);-- >H
               mi_szLinea :=mi_szLinea||rpad(mi_persona_type.mi_nro_doc,30,' ')||chr(09);-- benficiario documento I
               mi_szLinea :=mi_szLinea||mi_persona_type.mi_primer_apellido||mi_persona_type.mi_segundo_apellido||chr(09);-- apellidos demandado J
               mi_szLinea :=mi_szLinea||rpad(mi_persona_type.mi_nombre,40,' ')||chr(09);-- nombre demandado K
               mi_szLinea :=mi_szLinea||rpad(mi_demandante_type.mi_tipo_doc_ddte,30,' ')||chr(09);-- tipo documento L
               mi_szLinea :=mi_szLinea||mi_demandante_type.mi_nro_doc_ddte||chr(09);-- Numero documento M
               mi_szLinea :=mi_szLinea||mi_embargo_type.mi_concepto||chr(09);-- concepto demandante N
               mi_szLinea :=mi_szLinea||rpad(mi_demandantes_type.mi_apellidos_ddte,30,' ')||chr(09); -- apellidos demandante O
              mi_szLinea :=mi_szLinea||mi_demandantes_type.mi_nombre_ddte||chr(09);  -- Nombre  demandante P
              mi_szLinea :=mi_szLinea||mi_embargo_type.mi_concepto||chr(09);  -- numero expediente Q
              
              Text_IO.Put_Line( mi_archivo_path, mi_szLinea );
            END LOOP;   
            
            CLOSE cur_embargos;
          
            Text_IO.fClose( mi_archivo_path );
            web.show_document(mi_pathweb_ra||mi_archivo_planoemb,'_blank');
          
          EXCEPTION
            WHEN OTHERS THEN
              IF SQLCODE = -302000 THEN
                 pr_despliega_mensaje('AL_STOP_1', 'Ocurrio un error intentando escribir el archivo ' || mi_archivo_planoemb  );
              ELSE
                 pr_despliega_mensaje('AL_STOP_1', 'Ocurrió el error: ' || To_Char(SQLCODE) );
              END IF;
              IF Text_IO.Is_Open( mi_archivo_path ) THEN
                 Text_IO.fClose( mi_archivo_path );
              END IF;
              RAISE Form_Trigger_Failure;
          END;  --Anexo Embargos*/
        ELSE
          BEGIN
            /*if r.rubro in(9,2,3,4,5,10,11,12,13,14,15,19,20,21) then
              mi_viapago:='M';
               
            else
               mi_viapago:=' ';
              end if;*/
            mi_viapago := ' ';
            mi_cursor  := EXEC_SQL.Open_Cursor(EXEC_SQL.DEFAULT_CONNECTION);
            -- Se construye la sentencia de la consulta
            mi_consulta := 'SELECT  ';
            IF mi_tabla_detalle LIKE '%NOMBRE%' OR
               mi_tabla_detalle = 'ENTIDAD_BENEFICIARIOS' THEN
              mi_consulta := mi_consulta || 'a.sconcepto, ';
            END IF;
            mi_consulta := mi_consulta ||
                           ' a.stercero, SUM(valor) valor, SUM(valor_saldo) valor_saldo '||
                          'FROM     rh_t_lm_valores a, rh_lm_cuenta b, rh_lm_centros_costo c ' ||
                          'WHERE    b.stipo_funcionario =  a.stipofuncionario '||
                          'AND      b.sconcepto         =  a.sconcepto '||
                          'AND      b.cc                =  c.codigo '||
                          'AND      a.periodo           =  TO_DATE(''' ||
                          TO_CHAR(una_fecha_final, 'DD-MM-YYYY HH:MI:SS AM') ||
                           ''',''DD-MM-YYYY HH:MI:SS AM'') ' || 
                           'AND     a.ntipo_nomina      =  ' ||
                           un_tipo_nomina || ' AND  a.sdevengado ';
            IF un_tipo_ra = '1' THEN
              --mi_consulta:=mi_consulta || 'IN (0,1) ';
              mi_consulta := mi_consulta ||
                             'IN (0,1)  AND      c.codigo    not  IN (2,3,4) ';
            ELSE
              mi_consulta := mi_consulta || 'NOT IN (0,1) ';
            END IF;
            mi_consulta := mi_consulta ||
                           ' AND a.nro_ra    = ' || mi_ra_type.mi_nro_ra || 
                           ' AND b.scompania =  ' || CHR(39) || una_compania || CHR(39) ||
                           ' AND b.tipo_ra   =  ' || CHR(39) || un_tipo_ra || CHR(39) ||
                           ' AND b.grupo_ra IN (' || CHR(39) || un_grupo_ra || CHR(39) || 
                                                ') AND  b.ncierre =  1 '|| 
                          -- RQ2523-2005   05/12/2005
                           ' AND b.dfecha_inicio_vig <= TO_DATE(''' || 
                                 TO_CHAR(una_fecha_final, 'DD-MM-YYYY HH:MI:SS AM') ||
                                 ''',''DD-MM-YYYY HH:MI:SS AM'') '||
                           ' AND (b.dfecha_final_vig  >= TO_DATE(''' ||
                                 TO_CHAR(una_fecha_final, 'DD-MM-YYYY HH:MI:SS AM') ||
                           ''',''DD-MM-YYYY HH:MI:SS AM'') OR b.dfecha_final_vig IS NULL) '||
                          -- Fin RQ2523  
                           ' AND      b.cc =  ' || mi_cc;
            IF (mi_tabla_detalle LIKE '%NOMBRE%' OR
               mi_tabla_detalle = 'ENTIDAD_BENEFICIARIOS') THEN
              mi_consulta := mi_consulta ||
                             ' GROUP BY a.sconcepto, a.stercero';
            ELSE
              mi_consulta := mi_consulta || ' GROUP BY a.stercero';
            END IF;
            --pr_muestra_varios_debug('La Consulta '||mi_consulta);
            pr_debug_registra(mi_file_debug_handle,mi_consulta);
            -- Text_IO.Put_Line( mi_archivo_sap, mi_consulta );
            -- Se construye diná¡micamente el cursor
            --FTV PRUEBA 202405 linea para mostrar en caso de error.
            mi_linea_ejecutada := 'EXEC_SQL.PARSE mi_consulta ' ||
                                  substr(mi_consulta, 1, 50);

	          pr_debug_registra(mi_file_debug_handle,'1596 EXEC_SQL.parse '||mi_consulta);   
	          pr_debug_registra(mi_file_debug_handle,'1597 mi_tabla_detalle '||mi_tabla_detalle);     
            EXEC_SQL.PARSE(EXEC_SQL.DEFAULT_CONNECTION,
                           mi_cursor,
                           mi_consulta,
                          	exec_sql.V7);
            -- Se definen las columnas en donde se almacenaran los resultados
            IF (mi_tabla_detalle LIKE '%NOMBRE%' OR
               mi_tabla_detalle = 'ENTIDAD_BENEFICIARIOS') THEN
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
            pr_debug_registra(mi_file_debug_handle,'1629 EXEC_SQL.EXECUTE(EXEC_SQL.DEFAULT_CONNECTION ');     
            -- Se ejecuta el cursor
            nIgn := EXEC_SQL.EXECUTE(EXEC_SQL.DEFAULT_CONNECTION, mi_cursor);
            WHILE EXEC_SQL.FETCH_ROWS(EXEC_SQL.DEFAULT_CONNECTION,
                                      mi_cursor) > 0 LOOP
              IF (mi_tabla_detalle LIKE '%NOMBRE%' OR
                 mi_tabla_detalle = 'ENTIDAD_BENEFICIARIOS') THEN
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
                    RAISE Form_Trigger_Failure;
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
                
                  mi_entidad_type := pk_detalle_anexos_ra.fn_detalle_entidad(mi_tipo_entidad,
                                                                             mi_tercero,
                                                                             mi_err);
                
                  IF mi_err = 1 THEN
                    pr_despliega_mensaje('AL_STOP_1',
                                         'Ocurrió un error al recuperar información de entidades ' ||
                                         mi_tipo_entidad || ' ' ||
                                         mi_tercero);
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
                  IF un_tipo_ra = '1' AND mi_valor < 0 THEN
                    mi_valor := mi_valor * (-1);
                  END IF;
                  IF un_tipo_ra = '1' THEN
                  
                    if mi_entidad_type.mi_tipo_cuenta = 'A' then
                      mi_entidad_type.mi_tipo_cuenta := '02';
                    
                    Elsif mi_entidad_type.mi_tipo_cuenta = 'C' then
                      mi_entidad_type.mi_tipo_cuenta := '01';
                    else
                      mi_entidad_type.mi_tipo_cuenta := '  ';
                    end if;
                  
                    -- obtner ach sap
                    for b in codach(mi_entidad_type.mi_banco) loop
                      mi_codbanco := b.codigo_ach;
                    end loop;
                    if trim(mi_codbanco) is null then
                    	mi_codbanco := 'C';
                    else
	                    if mi_viapago = 'M' then
	                      mi_codbanco := '   ';
	                    end if;
	                  end if;
                    for e in nom_entidad(mi_entidad_type.mi_nro_doc) loop
                      mi_nombre_entidad := substr(e.nomentidad, 1, 50);
                    end loop;
                  
                    mi_szLinea := 'P' || chr(09) || mi_codigo || chr(09) ||
                                  chr(09) ||
                                  rpad(mi_entidad_type.mi_tipo_doc, 3, ' ') ||
                                  chr(09) ||
                                  rpad(mi_entidad_type.mi_nro_doc, 12, ' ') ||
                                  chr(09) || chr(09) || mi_cuentarub ||
                                  chr(09) || mi_valor;
                    mi_szLinea := mi_szLinea || chr(09) || chr(09) ||
                                  chr(09) || chr(09) || chr(09) || chr(09) ||
                                  chr(09) || chr(09) || chr(09) || chr(09) ||
                                  chr(09) || chr(09) || chr(09) || chr(09) ||
                                  chr(09);
                    mi_szLinea := mi_szLinea || chr(09) ||
                                  mi_condicion_pago || chr(09) || mi_texto ||
                                  chr(09) || chr(09) || chr(09) || chr(09) ||
                                  chr(09) || chr(09) || mi_viapago ||
                                  chr(09) || chr(09) || chr(09) || chr(09) ||
                                  chr(09) || chr(09) || mi_codbanco ||
                                  chr(09) || rpad(mi_entidad_type.mi_numero_cuenta,
                                                  20,
                                                  ' ') || chr(09) ||
                                  rpad(mi_entidad_type.mi_tipo_cuenta,
                                       2,
                                       ' ');
                    mi_szLinea := mi_szLinea || chr(09) || '  ' || chr(09) ||
                                  mi_basertfte || chr(09) || chr(09) ||
                                  chr(09) || chr(09);
                    Text_IO.Put_Line(mi_archivo_sap, mi_szLinea);
                  
                  ELSE
                    mi_incapacidad := 0;
                    mi_saldo       := 0;
                    IF UPPER(mi_descripcion_cc) LIKE '%SALUD%' OR
                       UPPER(mi_descripcion_cc) LIKE '%ARP%' THEN
                      IF UPPER(mi_descripcion_cc) LIKE '%SALUD%' THEN
                        mi_concepto_inc    := 'INCAPACIDADES_AUTOL_SALUD';
                        mi_concepto_saldos := 'SALDOS_SALUD';
                      ELSE
                        mi_concepto_inc    := 'INCAPACIDADES_AUTOL_ARP';
                        mi_concepto_saldos := 'SALDOS_ARP';
                      END IF;
                      mi_incapacidad := pk_detalle_anexos_ra.fn_detalle_incapacidades(una_compania,
                                                                                      mi_concepto_inc,
                                                                                      un_tipo_nomina,
                                                                                      mi_tercero,
                                                                                      una_fecha_final,
                                                                                      mi_ra_type.mi_nro_ra,
                                                                                      un_grupo_ra,
                                                                                      mi_err);
                      IF mi_err = 1 THEN
                        pr_despliega_mensaje('AL_STOP_1',
                                             'Ocurrió un error al recuperar información de incapacidades EPS ' ||
                                             mi_tercero);
                        RAISE Form_Trigger_Failure;
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
                                                                         mi_ra_type.mi_nro_ra,
                                                                         un_grupo_ra,
                                                                         mi_err);
                      IF mi_err = 1 THEN
                        pr_despliega_mensaje('AL_STOP_1',
                                             'Ocurrió un error al recuperar información de saldos a favor o en contra de la EPS ' ||
                                             mi_tercero);
                        RAISE Form_Trigger_Failure;
                      END IF;
                      IF mi_saldo <> 0 THEN
                        --mi_valor:=mi_valor - mi_saldo;
                        mi_saldo := mi_saldo * (-1);
                      
                      END IF;
                    END IF;
                  
                    if mi_entidad_type.mi_tipo_cuenta = 'A' then
                      mi_entidad_type.mi_tipo_cuenta := '02';
                    Elsif mi_entidad_type.mi_tipo_cuenta = 'C' then
                      mi_entidad_type.mi_tipo_cuenta := '01';
                    else
                      mi_entidad_type.mi_tipo_cuenta := '  ';
                    end if;
                    for b in codach(mi_entidad_type.mi_banco) loop
                      mi_codbanco := b.codigo_ach;
                    end loop;
                  
                    for e in nom_entidad(mi_entidad_type.mi_nro_doc) loop
                      mi_nombre_entidad := substr(e.nomentidad, 1, 50);
                    end loop;
                    if mi_viapago = 'M' then
                      mi_codbanco := '   ';
                    end if;
                  
                    --20201030
                    if r.rubro in
                       (2, 3, 4, 11, 13, 14, 15, 16, 18, 21, 22, 23, 24) then
                      mi_valor                         := mi_valor +
                                                          mi_valor_saldo;
                      if r.rubro = 13 and trim(mi_codbanco) is null then
                      	mi_viapago										 := 'C';
                      else
                      	mi_viapago                     := 'M';
                      end if;
                      mi_entidad_type.mi_tipo_cuenta   := ' ';
                      mi_codbanco                      := '   ';
                      mi_entidad_type.mi_numero_cuenta := ' ';
                      if r.rubro in (13,18, 21) then
                        mi_viapago := 'C';
                      end if;
                    end if;
                  
                    mi_szLinea := 'P' || chr(09) || mi_codigo || chr(09) ||
                                  chr(09) ||
                                  rpad(mi_entidad_type.mi_tipo_doc, 3, ' ') ||
                                  chr(09) ||
                                  rpad(mi_entidad_type.mi_nro_doc, 12, ' ') ||
                                  chr(09) || chr(09) || mi_cuentarub ||
                                  chr(09) || mi_valor;
                    mi_szLinea := mi_szLinea || chr(09) || chr(09) ||
                                  chr(09) || chr(09) || chr(09) || chr(09) ||
                                  chr(09) || chr(09) || chr(09) || chr(09) ||
                                  chr(09) || chr(09) || chr(09) || chr(09) ||
                                  chr(09);
                    mi_szLinea := mi_szLinea || chr(09) ||
                                  mi_condicion_pago || chr(09) || mi_texto ||
                                  chr(09) || chr(09) || chr(09) || chr(09) ||
                                  chr(09) || chr(09) || mi_viapago ||
                                  chr(09) || chr(09) || chr(09) || chr(09) ||
                                  chr(09) || chr(09) || mi_codbanco ||
                                  chr(09) || rpad(mi_entidad_type.mi_numero_cuenta,
                                                  20,
                                                  ' ') || chr(09) ||
                                  rpad(mi_entidad_type.mi_tipo_cuenta,
                                       2,
                                       ' ');
                    mi_szLinea := mi_szLinea || chr(09) || '  ' || chr(09) ||
                                  mi_basertfte || chr(09) || chr(09) ||
                                  chr(09) || chr(09);
                    Text_IO.Put_Line(mi_archivo_sap, mi_szLinea);
                    --Puede ocurrir si la incapacidad es menor que el aporte por EPS                
                    IF mi_valor < 0 THEN
                      text_io.put_line(mi_id_error,
                                       'Entidad con pago negativo :' ||
                                       mi_entidad_type.mi_nro_doc ||
                                       '. Valor:' || mi_valor);
                      text_io.put_line(mi_id_error,
                                       'en la Relación de autorización ' ||
                                       mi_ra_type.mi_nro_ra);
                      mi_terceros_neg := mi_terceros_neg + 1;
                    END IF;
                  END IF;
                  Text_IO.Put_Line(mi_archivo_path, mi_szLinea);
                ELSE
                  --Si la tabla detalle es beneficiarios
                  mi_beneficiario_type := pk_detalle_anexos_ra.fn_detalle_beneficiarios(TO_NUMBER(mi_tercero),
                                                                                        mi_err);
                
                  IF mi_err = 1 THEN
                    pr_despliega_mensaje('AL_STOP_1',
                                         'Sd: Ocurrió un error al recuperar información de beneficiarios ' ||
                                         mi_tercero);
                    RAISE Form_Trigger_Failure;
                  END IF;
                  IF mi_beneficiario_type.mi_forma_pago IS NULL THEN
                    pr_despliega_mensaje('AL_STOP_1',
                                         'No se ha registrado la forma de pago para el beneficiario ' ||
                                         mi_beneficiario_type.mi_nro_doc);
                    RAISE Form_Trigger_Failure;
                  END IF;
                  IF mi_valor < 0 THEN
                    mi_valor := mi_valor * (-1);
                  END IF;
                  IF un_tipo_ra = '1' THEN
                    mi_szLinea := null;
                  
                    if mi_beneficiario_type.mi_tipo_cuenta = 'A' then
                      mi_beneficiario_type.mi_tipo_cuenta := '02';
                    ELSif mi_beneficiario_type.mi_tipo_cuenta = 'C' then
                      mi_beneficiario_type.mi_tipo_cuenta := '01';
                    else
                      mi_beneficiario_type.mi_tipo_cuenta := '  ';
                    end if;
                    -- for b in codach(mi_beneficiario_type.mi_banco) loop
                    --    mi_codbanco:=b.codigo_ach;
                    --end loop;
                    mi_codbanco := lpad(mi_beneficiario_type.mi_banco, 3, 0);
                    for e in nom_entidad(mi_beneficiario_type.mi_nro_doc) loop
                      mi_nombre_entidad := substr(e.nomentidad, 1, 50);
                    end loop;
                    -- observaciones 05/05/2020 shd
                    if trim(mi_codbanco) is null then
                    	if r.rubro = 13 then --AFC 202506
                    		mi_viapago := 'C';	
                    	else
                      	mi_viapago := 'M';
                      end if;
                    end if;
                  
                    mi_szLinea := 'P' || chr(09) || mi_codigo || chr(09) ||
                                  chr(09) || rpad(mi_beneficiario_type.mi_tipo_doc,
                                                  3,
                                                  ' ') || chr(09) ||
                                  rpad(mi_beneficiario_type.mi_nro_doc,
                                       12,
                                       ' ') || chr(09) || chr(09) ||
                                  mi_cuentarub || chr(09) || mi_valor;
                    mi_szLinea := mi_szLinea || chr(09) || chr(09) ||
                                  chr(09) || chr(09) || chr(09) || chr(09) ||
                                  chr(09) || chr(09) || chr(09) || chr(09) ||
                                  chr(09) || chr(09) || chr(09) || chr(09) ||
                                  chr(09);
                    mi_szLinea := mi_szLinea || chr(09) ||
                                  mi_condicion_pago || chr(09) || mi_texto ||
                                  chr(09) || chr(09) || chr(09) || chr(09) ||
                                  chr(09) || chr(09) || mi_viapago ||
                                  chr(09) || chr(09) || chr(09) || chr(09) ||
                                  chr(09) || chr(09) || mi_codbanco ||
                                  chr(09) || rpad(mi_beneficiario_type.mi_numero_cuenta,
                                                  20,
                                                  ' ') || chr(09) ||
                                  rpad(mi_beneficiario_type.mi_tipo_cuenta,
                                       2,
                                       ' ');
                    mi_szLinea := mi_szLinea || chr(09) || '  ' || chr(09) ||
                                  mi_basertfte || chr(09) || chr(09) ||
                                  chr(09) || chr(09);
                  
                    Text_IO.Put_Line(mi_archivo_sap, mi_szLinea);
                  
                  ELSE
                  
                    ---------- tipo ra  2
                  
                    if mi_beneficiario_type.mi_tipo_cuenta = 'A' then
                      mi_beneficiario_type.mi_tipo_cuenta := '02';
                    ELSif mi_beneficiario_type.mi_tipo_cuenta = 'C' then
                      mi_beneficiario_type.mi_tipo_cuenta := '01';
                    else
                      mi_beneficiario_type.mi_tipo_cuenta := '  ';
                    end if;
                    --for b in codach(mi_beneficiario_type.mi_banco) loop
                    --      mi_codbanco:=b.codigo_ach;
                    --end loop;
                    mi_codbanco := lpad(mi_beneficiario_type.mi_banco, 3, 0);
                    for e in nom_entidad(mi_beneficiario_type.mi_nro_doc) loop
                      mi_nombre_entidad := substr(e.nomentidad, 1, 50);
                    end loop;
                    mi_szLinea := null;
                    /*if mi_viapago='M' then
                      mi_codbanco:='   ';
                    end if;  */
                    if mi_codbanco is null then
                      mi_viapago := 'M';
                      --mi_codbanco:='   ';
                    end if;
                    if r.rubro in
                       /*(2, 3, 4, 11, 13, 14, 15, 16, 18, 21, 22, 23, 24)*/
                       /*   2	    APORTES A SEGURIDAD SOCIAL EN SALUD
                            3	    APORTES A FONDOS PENSIONALES
                            11	  APORTE RIESGOS PROFESIONALES - ARP
                            13	  APORTES PENSION VOLUNTARIOS
                            16	  DESCUENTO CREDITO VIVIENDA
                            17	  APORTE FONDO GARANTIA
                            18	  CESANTIAS
                            1316	APORTES SENA
                            1317	APORTES ICBF
                            1318	APORTES CAJA DE COMPENSACION
                            */
                       (2, 3, 11, 13, 16, 17, 18, 1316, 1317, 1318) then
                      mi_valor                              := mi_valor +
                                                               mi_valor_saldo;
                      if r.rubro = 13 and trim(mi_codbanco) is null then
                      	mi_viapago 													:= 'C';
                      else
                      	mi_viapago                          := 'M';
                      end if;
                      mi_beneficiario_type.mi_tipo_cuenta   := ' ';
                      mi_codbanco                           := '   ';
                      mi_beneficiario_type.mi_numero_cuenta := ' ';
                      if r.rubro in (13, 18, 21) then
                        mi_viapago := 'C';
                      end if;
                    end if;
                    mi_szLinea := 'P' || chr(09) || mi_codigo || chr(09) ||
                                  chr(09) || rpad(mi_beneficiario_type.mi_tipo_doc,
                                                  3,
                                                  ' ') || chr(09) ||
                                  rpad(mi_beneficiario_type.mi_nro_doc,
                                       12,
                                       ' ') || chr(09) || chr(09) ||
                                  mi_cuentarub || chr(09) || mi_valor;
                    mi_szLinea := mi_szLinea || chr(09) || chr(09) ||
                                  chr(09) || chr(09) || chr(09) || chr(09) ||
                                  chr(09) || chr(09) || chr(09) || chr(09) ||
                                  chr(09) || chr(09) || chr(09) || chr(09) ||
                                  chr(09);
                    mi_szLinea := mi_szLinea || chr(09) ||
                                  mi_condicion_pago || chr(09) || mi_texto ||
                                  chr(09) || chr(09) || chr(09) || chr(09) ||
                                  chr(09) || chr(09) || mi_viapago ||
                                  chr(09) || chr(09) || chr(09) || chr(09) ||
                                  chr(09) || chr(09) || mi_codbanco ||
                                  chr(09) || rpad(mi_beneficiario_type.mi_numero_cuenta,
                                                  20,
                                                  ' ') || chr(09) ||
                                  rpad(mi_beneficiario_type.mi_tipo_cuenta,
                                       2,
                                       ' ');
                    mi_szLinea := mi_szLinea || chr(09) || '  ' || chr(09) ||
                                  mi_basertfte || chr(09) || chr(09) ||
                                  chr(09) || chr(09);
                    ----
                    Text_IO.Put_Line(mi_archivo_sap, mi_szLinea);
                  
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
                --  MESSAGE('mi_descripcion_cc2 '||mi_descripcion_cc);
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
                IF un_tipo_ra = '1' AND mi_valor < 0 THEN
                  mi_valor := mi_valor * (-1);
                END IF;
                IF un_tipo_ra = '1' THEN
                  --   message('concepto3 '||mi_descripcion_cc);
                
                  if mi_entidad_type.mi_tipo_cuenta = 'A' then
                    mi_entidad_type.mi_tipo_cuenta := '02';
                  Elsif mi_entidad_type.mi_tipo_cuenta = 'C' then
                    mi_entidad_type.mi_tipo_cuenta := '01';
                  else
                    mi_entidad_type.mi_tipo_cuenta := '  ';
                  end if;
                
                  for b in codach(mi_entidad_type.mi_banco) loop
                    mi_codbanco := b.codigo_ach;
                  end loop;
                  for e in nom_entidad(mi_entidad_type.mi_nro_doc) loop
                    mi_nombre_entidad := substr(e.nomentidad, 1, 50);
                  end loop;
                
                  if trim(mi_codbanco) is null and r.rubro = 13 then
                  	mi_viapago := 'C';
                  else 
                  	mi_viapago := 'M';
                    mi_codbanco := '   ';
                  end if;
                  IF UPPER(mi_descripcion_cc) not LIKE '%SALUD%' THEN
                    -- descartar salud
                    mi_szLinea := 'P' || chr(09) || mi_codigo || chr(09) ||
                                  chr(09) ||
                                  rpad(mi_entidad_type.mi_tipo_doc, 3, ' ') ||
                                  chr(09) ||
                                  rpad(mi_entidad_type.mi_nro_doc, 12, ' ') ||
                                  chr(09) || chr(09) || mi_cuentarub ||
                                  chr(09) || mi_valor;
                    mi_szLinea := mi_szLinea || chr(09) || chr(09) ||
                                  chr(09) || chr(09) || chr(09) || chr(09) ||
                                  chr(09) || chr(09) || chr(09) || chr(09) ||
                                  chr(09) || chr(09) || chr(09) || chr(09) ||
                                  chr(09);
                    mi_szLinea := mi_szLinea || chr(09) ||
                                  mi_condicion_pago || chr(09) || mi_texto ||
                                  chr(09) || chr(09) || chr(09) || chr(09) ||
                                  chr(09) || chr(09) || mi_viapago ||
                                  chr(09) || chr(09) || chr(09) || chr(09) ||
                                  chr(09) || chr(09) || mi_codbanco ||
                                  chr(09) || rpad(mi_entidad_type.mi_numero_cuenta,
                                                  20,
                                                  ' ') || chr(09) ||
                                  rpad(mi_entidad_type.mi_tipo_cuenta,
                                       2,
                                       ' ');
                    mi_szLinea := mi_szLinea || chr(09) || '  ' || chr(09) ||
                                  mi_basertfte || chr(09) || chr(09) ||
                                  chr(09) || chr(09);
                  
                    Text_IO.Put_Line(mi_archivo_sap, mi_szLinea);
                  else
                    mi_szLinea := 'P' || chr(09) || mi_codigo || chr(09) ||
                                  chr(09) ||
                                  rpad(mi_entidad_type.mi_tipo_doc, 3, ' ') ||
                                  chr(09) ||
                                  rpad(mi_entidad_type.mi_nro_doc, 12, ' ') ||
                                  chr(09) || chr(09) || mi_cuentarub ||
                                  chr(09) || mi_valor;
                    mi_szLinea := mi_szLinea || chr(09) || chr(09) ||
                                  chr(09) || chr(09) || chr(09) || chr(09) ||
                                  chr(09) || chr(09) || chr(09) || chr(09) ||
                                  chr(09) || chr(09) || chr(09) || chr(09) ||
                                  chr(09);
                    mi_szLinea := mi_szLinea || chr(09) ||
                                  mi_condicion_pago || chr(09) || mi_texto ||
                                  chr(09) || chr(09) || chr(09) || chr(09) ||
                                  chr(09) || chr(09) || mi_viapago ||
                                  chr(09) || chr(09) || chr(09) || chr(09) ||
                                  chr(09) || chr(09) || mi_codbanco ||
                                  chr(09) || rpad(mi_entidad_type.mi_numero_cuenta,
                                                  20,
                                                  ' ') || chr(09) ||
                                  rpad(mi_entidad_type.mi_tipo_cuenta,
                                       2,
                                       ' ');
                    mi_szLinea := mi_szLinea || chr(09) || '  ' || chr(09) ||
                                  mi_basertfte || chr(09) || chr(09) ||
                                  chr(09) || chr(09);
                  
                    Text_IO.Put_Line(mi_archivo_sap, mi_szLinea);
                  
                  END IF;
                ELSE
                  mi_incapacidad := 0;
                  mi_saldo       := 0;
                  IF UPPER(mi_descripcion_cc) LIKE '%SALUD%' OR
                     UPPER(mi_descripcion_cc) LIKE '%ARP%' THEN
                    IF UPPER(mi_descripcion_cc) LIKE '%SALUD%' THEN
                      mi_concepto_inc    := 'INCAPACIDADES_AUTOL_SALUD';
                      mi_concepto_saldos := 'SALDOS_SALUD';
                    ELSE
                      mi_concepto_inc    := 'INCAPACIDADES_AUTOL_ARP';
                      mi_concepto_saldos := 'SALDOS_ARP';
                    END IF;
                    mi_incapacidad := pk_detalle_anexos_ra.fn_detalle_incapacidades(una_compania,
                                                                                    mi_concepto_inc,
                                                                                    un_tipo_nomina,
                                                                                    mi_tercero,
                                                                                    una_fecha_final,
                                                                                    mi_ra_type.mi_nro_ra,
                                                                                    un_grupo_ra,
                                                                                    mi_err);
                    IF mi_err = 1 THEN
                      pr_despliega_mensaje('AL_STOP_1',
                                           'Ocurrió un error al recuperar información de incapacidades EPS ' ||
                                           mi_tercero);
                      RAISE Form_Trigger_Failure;
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
                                                                       mi_ra_type.mi_nro_ra,
                                                                       un_grupo_ra,
                                                                       mi_err);
                    IF mi_err = 1 THEN
                      pr_despliega_mensaje('AL_STOP_1',
                                           'Ocurrió un error al recuperar información de saldos a favor o en contra de la EPS ' ||
                                           mi_tercero);
                      RAISE Form_Trigger_Failure;
                    END IF;
                    IF mi_saldo <> 0 THEN
                      --mi_valor:=mi_valor - mi_saldo;
                      mi_saldo := mi_saldo * (-1);
                    END IF;
                  END IF;
                  IF (UPPER(mi_descripcion_cc) LIKE '%ARP%') and
                     mi_incapacidad <> 0 THEN
                    mi_valor := mi_valor; -- - mi_incapacidad WN 12122008;
                    --mi_saldo:=mi_saldo*(-1);
                  END IF;
                
                  if mi_entidad_type.mi_tipo_cuenta = 'A' then
                    mi_entidad_type.mi_tipo_cuenta := '02';
                  Elsif mi_entidad_type.mi_tipo_cuenta = 'C' then
                    mi_entidad_type.mi_tipo_cuenta := '01';
                  else
                    mi_entidad_type.mi_tipo_cuenta := '  ';
                  end if;
                  -- codigo ach
                  for b in codach(mi_entidad_type.mi_banco) loop
                    mi_codbanco := b.codigo_ach;
                  end loop;
                  if mi_viapago = 'M' then
                    mi_codbanco := '   ';
                  end if;
                  for e in nom_entidad(mi_entidad_type.mi_nro_doc) loop
                    mi_nombre_entidad := substr(e.nomentidad, 1, 50);
                  end loop;
                  if r.rubro in /*(2, 3, 4, 11, 13, 14, 15, 16 , 22, 23, 24)*/
                    (2,3,11,17,18,1316,1317,1318) 
                    /*
                    2	    APORTES A SEGURIDAD SOCIAL EN SALUD
                    3	    APORTES A FONDOS PENSIONALES
                    11	    APORTE RIESGOS PROFESIONALES - ARP
                    17	    APORTE FONDO GARANTIA
                    18	    CESANTIAS
                    1316	APORTES SENA
                    1317	APORTES ICBF
                    1318	APORTES CAJA DE COMPENSACION

                  */
                   then
                    mi_valor                         := mi_valor +
                                                        mi_valor_saldo;
                    mi_codbanco                      := '   ';
                    if trim(mi_codbanco) is null and r.rubro = 13 then
                    	mi_viapago										 := 'C';
                    else
                    	mi_viapago                     := 'M';
                    end if;
                    mi_entidad_type.mi_tipo_cuenta   := ' ';
                    mi_entidad_type.mi_numero_cuenta := ' ';
                    if r.rubro in (13, 18, 21) then
                      mi_viapago := 'C';
                    end if;
                  end if;
                
                  mi_szLinea := 'P' || chr(09) || mi_codigo || chr(09) ||
                                chr(09) ||
                                rpad(mi_entidad_type.mi_tipo_doc, 3, ' ') ||
                                chr(09) ||
                                rpad(mi_entidad_type.mi_nro_doc, 12, ' ') ||
                                chr(09) || chr(09) || mi_cuentarub ||
                                chr(09) || mi_valor;
                  mi_szLinea := mi_szLinea || chr(09) || chr(09) || chr(09) ||
                                chr(09) || chr(09) || chr(09) || chr(09) ||
                                chr(09) || chr(09) || chr(09) || chr(09) ||
                                chr(09) || chr(09) || chr(09) || chr(09);
                  mi_szLinea := mi_szLinea || chr(09) || mi_condicion_pago ||
                                chr(09) || mi_texto || chr(09) || chr(09) ||
                                chr(09) || chr(09) || chr(09) || chr(09) ||
                                mi_viapago || chr(09) || chr(09) || chr(09) ||
                                chr(09) || chr(09) || chr(09) ||
                                mi_codbanco || chr(09) ||
                                rpad(mi_entidad_type.mi_numero_cuenta,
                                     20,
                                     ' ') || chr(09) ||
                                rpad(mi_entidad_type.mi_tipo_cuenta, 2, ' ');
                  mi_szLinea := mi_szLinea || chr(09) || '  ' || chr(09) ||
                                mi_basertfte || chr(09) || chr(09) ||
                                chr(09) || chr(09);
                
                  Text_IO.Put_Line(mi_archivo_sap, mi_szLinea);
                
                  --Puede ocurrir si la incapacidad es menor que el aporte por EPS                
                  IF mi_valor < 0 THEN
                    text_io.put_line(mi_id_error,
                                     'Entidad con pago negativo :' ||
                                     mi_entidad_type.mi_nro_doc ||
                                     '. Valor:' || mi_valor);
                    text_io.put_line(mi_id_error,
                                     'en la Relación de autorización ' ||
                                     mi_ra_type.mi_nro_ra);
                    mi_terceros_neg := mi_terceros_neg + 1;
                  END IF;
                END IF;
                Text_IO.Put_Line(mi_archivo_path, mi_szLinea);
              ELSIF mi_tabla_detalle LIKE '%BENEFICIARIOS%' THEN
                IF mi_tabla_detalle LIKE '%NOMBRE%' THEN
                  mi_beneficiario_type := pk_detalle_anexos_ra.fn_detalle_beneficiarios(mi_concepto,
                                                                                        mi_err);
                  IF mi_err = 1 THEN
                    pr_despliega_mensaje('AL_STOP_1',
                                         'Bf2: Ocurrió un error al recuperar información de beneficiarios');
                    RAISE Form_Trigger_Failure;
                  END IF;
                ELSE
                
                  mi_beneficiario_type := pk_detalle_anexos_ra.fn_detalle_beneficiarios(TO_NUMBER(mi_tercero),
                                                                                        mi_err);
                  IF mi_err = 1 THEN
                    pr_despliega_mensaje('AL_STOP_1',
                                         'Bf1: Ocurrió un error al recuperar información de beneficiarios ' ||
                                         mi_tercero);
                    RAISE Form_Trigger_Failure;
                  END IF;
                END IF;
                IF mi_beneficiario_type.mi_forma_pago IS NULL THEN
                  pr_despliega_mensaje('AL_STOP_1',
                                       'No se ha registrado la forma de pago para el beneficiario ' ||
                                       mi_beneficiario_type.mi_nro_doc);
                  RAISE Form_Trigger_Failure;
                END IF;
                IF mi_valor < 0 THEN
                  mi_valor := mi_valor * (-1);
                END IF;
                IF un_tipo_ra = '1' THEN
                
                  if mi_beneficiario_type.mi_tipo_cuenta = 'A' then
                    mi_beneficiario_type.mi_tipo_cuenta := '02';
                  ELSif mi_beneficiario_type.mi_tipo_cuenta = 'C' then
                    mi_beneficiario_type.mi_tipo_cuenta := '01';
                  else
                    mi_beneficiario_type.mi_tipo_cuenta := '  ';
                  end if;
                  -- codigo ach
                  -- for b in codach(mi_beneficiario_type.mi_banco) loop
                  --     mi_codbanco:=b.codigo_ach;
                  -- end loop; 
                  mi_codbanco := lpad(mi_beneficiario_type.mi_banco, 3, 0);
                  for e in nom_entidad(mi_beneficiario_type.mi_nro_doc) loop
                    mi_nombre_entidad := substr(e.nomentidad, 1, 50);
                  end loop;
                  /*if mi_viapago='M' then
                   mi_codbanco:='   ';
                  end if;*/
                  if trim(mi_codbanco) is null and r.rubro = 13 then
                  	mi_viapago := 'C';	
                  elsif trim(mi_codbanco) is null then
                    mi_viapago := 'M';
                    --mi_codbanco:='   ';
                  end if;
                
                  if r.rubro = 8 then
                  /* 8 RETENCION FUENTE - SALARIOS Y PAGOS LABORALES */
                    mi_codigo := 50;
                    /*for j in retefteperiodo(mi_ra_type.mi_nro_ra) loop
                            begin
                              
                               mi_basertfte:=j.base;
                               mi_retefuente:=j.retencion;
                               mi_asignacion:=j.asignacion;
                            exception when others then
                               mi_basertfte:=' ';
                               mi_retefuente:=' ';
                               mi_asignacion:=0;
                             end;
                    end loop;
                                    
                       -- Retencion fuente cambio
                      mi_szLinea :='P'||chr(09)||mi_codigo||chr(09)||mi_cuentarub||chr(09)||chr(09)||chr(09)||chr(09)||chr(09)|| mi_valor;   
                      mi_szLinea :=mi_szLinea||chr(09)||chr(09)||chr(09)||chr(09)||chr(09)||chr(09)||chr(09)||chr(09)||chr(09)||chr(09)||chr(09)||chr(09)||chr(09)||chr(09)||chr(09);
                      mi_szLinea :=mi_szLinea||chr(09)||mi_condicion_pago||chr(09)||mi_texto||chr(09)||chr(09)||chr(09)||chr(09)||chr(09)||chr(09)||chr(09)||chr(09)||mi_asignacion||chr(09)||chr(09)||chr(09)||chr(09)||chr(09)||chr(09)||chr(09);
                      mi_szLinea :=mi_szLinea||chr(09)||'  '||chr(09)||chr(09)||mi_basertfte||chr(09)||chr(09)||chr(09)||chr(09);          
                      Text_IO.Put_Line( mi_archivo_sap, mi_szLinea );                                */
                  
                  else
                  
                    /* 20201030 */
                    if r.rubro in /*(2, 3, 4, 11, 13, 14, 15, 16 /* FTV202203,18 FTV202112, 21* /
                       , 22, 23, 24)*/ (2,3,11,17,18,1316,1317,1318)
                       /*
                        2	    APORTES A SEGURIDAD SOCIAL EN SALUD
                        3	    APORTES A FONDOS PENSIONALES
                        11	    APORTE RIESGOS PROFESIONALES - ARP
                        17	    APORTE FONDO GARANTIA
                        18	    CESANTIAS
                        1316	APORTES SENA
                        1317	APORTES ICBF
                        1318	APORTES CAJA DE COMPENSACION
                       */
                        then
                      --mi_valor:=mi_valor+mi_valor_saldo;
                      mi_codbanco                           := '   ';
                      mi_viapago                            := 'M';
                      mi_beneficiario_type.mi_tipo_cuenta   := ' ';
                      mi_beneficiario_type.mi_numero_cuenta := ' ';
                      if r.rubro in (13,18, 21) then
                        mi_viapago := 'C';
                      end if;
                    end if;
                    mi_szLinea := 'P' || chr(09) || mi_codigo || chr(09) ||
                                  chr(09) || rpad(mi_beneficiario_type.mi_tipo_doc,
                                                  3,
                                                  ' ') || chr(09) ||
                                  rpad(mi_beneficiario_type.mi_nro_doc,
                                       12,
                                       ' ') || chr(09) || chr(09) ||
                                  mi_cuentarub || chr(09) || mi_valor;
                    mi_szLinea := mi_szLinea || chr(09) || chr(09) ||
                                  chr(09) || chr(09) || chr(09) || chr(09) ||
                                  chr(09) || chr(09) || chr(09) || chr(09) ||
                                  chr(09) || chr(09) || chr(09) || chr(09) ||
                                  chr(09);
                    mi_szLinea := mi_szLinea || chr(09) ||
                                  mi_condicion_pago || chr(09) || mi_texto ||
                                  chr(09) || chr(09) || chr(09) || chr(09) ||
                                  chr(09) || chr(09) || mi_viapago ||
                                  chr(09) || chr(09) || chr(09) || chr(09) ||
                                  chr(09) || chr(09) || mi_codbanco ||
                                  chr(09) || rpad(mi_beneficiario_type.mi_numero_cuenta,
                                                  20,
                                                  ' ') || chr(09) ||
                                  rpad(mi_beneficiario_type.mi_tipo_cuenta,
                                       2,
                                       ' ');
                    mi_szLinea := mi_szLinea || chr(09) || '  ' || chr(09) ||
                                  mi_basertfte || chr(09) || chr(09) ||
                                  chr(09) || chr(09);
                  
                    Text_IO.Put_Line(mi_archivo_sap, mi_szLinea);
                  end if;
                  -- mi_szLinea :=' beneficiario';
                ELSE
                
                  if un_tipo_ra = '2' then
                    mi_valor := mi_valor + mi_valor_saldo;
                  
                  end if;
                  if mi_beneficiario_type.mi_tipo_cuenta = 'A' then
                    mi_beneficiario_type.mi_tipo_cuenta := '02';
                  ELSif mi_beneficiario_type.mi_tipo_cuenta = 'C' then
                    mi_beneficiario_type.mi_tipo_cuenta := '01';
                  else
                    mi_beneficiario_type.mi_tipo_cuenta := '  ';
                  end if;
                
                  --for b in codach(mi_beneficiario_type.mi_banco) loop
                  --mi_codbanco:=b.codigo_ach;
                  mi_codbanco := lpad(mi_beneficiario_type.mi_banco, 3, 0);
                  --end loop;                                        
                  for e in nom_entidad(mi_entidad_type.mi_nro_doc) loop
                    mi_nombre_entidad := substr(e.nomentidad, 1, 50);
                  end loop;
                  if mi_codbanco is null then
                    mi_viapago := 'M';
                    --mi_codbanco:='   ';
                  end if;
                
                  if r.rubro in (2, 3, 4, 11, 13, 14, 15, 16, 22, 23, 24) then
                    -- mi_valor:=mi_valor+mi_valor_saldo;
                    if r.rubro = 13 and trim(mi_codbanco) is null then
                    	mi_viapago := 'C';
                    else
                    	mi_viapago                            := 'M';
                    end if;
                    mi_codbanco                           := '   ';
                    mi_beneficiario_type.mi_tipo_cuenta   := ' ';
                    mi_beneficiario_type.mi_numero_cuenta := ' ';
                    --FTV 202203 
                    /*
                    if r.rubro in (18 --FTV202112  ,21
                         ) then
                        mi_viapago:='C';  
                    end if;  
                    --*/
                  end if;
                  /* COMISION FONCEP 
                     FONCEP
                     Conceptos no existen en FONCEP */
                  /*if r.rubro in (13, 14) then
                    mi_szLinea := 'P' || chr(09) || mi_codigo || chr(09) ||
                                  chr(09) || rpad(mi_beneficiario_type.mi_tipo_doc,
                                                  3,
                                                  ' ') || chr(09) ||
                                  rpad(mi_beneficiario_type.mi_nro_doc,
                                       12,
                                       ' ') || chr(09) || chr(09) ||
                                  mi_cuentarub || chr(09) || mi_valor;
                    mi_szLinea := mi_szLinea || chr(09) || chr(09) ||
                                  chr(09) || chr(09) || chr(09) || chr(09) ||
                                  chr(09) || chr(09) || chr(09) || chr(09) ||
                                  chr(09) || chr(09) || chr(09) || chr(09) ||
                                  chr(09);
                    mi_szLinea := mi_szLinea || chr(09) ||
                                  mi_condicion_pago || chr(09) || mi_texto ||
                                  chr(09) || chr(09) || chr(09) || chr(09) ||
                                  chr(09) || chr(09) || mi_viapago ||
                                  chr(09) || chr(09) || chr(09) || chr(09) ||
                                  chr(09) || chr(09) || mi_codbanco ||
                                  chr(09) || rpad(mi_beneficiario_type.mi_numero_cuenta,
                                                  20,
                                                  ' ') || chr(09) ||
                                  rpad(mi_beneficiario_type.mi_tipo_cuenta,
                                       2,
                                       ' ');
                    mi_szLinea := mi_szLinea || chr(09) || '  ' || chr(09) ||
                                  mi_basertfte || chr(09) || chr(09) ||
                                  chr(09) || chr(09);
                    Text_IO.Put_Line(mi_archivo_sap_foncep, mi_szLinea);
                  else*/
                    mi_szLinea := 'P' || chr(09) || mi_codigo || chr(09) ||
                                  chr(09) || rpad(mi_beneficiario_type.mi_tipo_doc,
                                                  3,
                                                  ' ') || chr(09) ||
                                  rpad(mi_beneficiario_type.mi_nro_doc,
                                       12,
                                       ' ') || chr(09) || chr(09) ||
                                  mi_cuentarub || chr(09) || mi_valor;
                    mi_szLinea := mi_szLinea || chr(09) || chr(09) ||
                                  chr(09) || chr(09) || chr(09) || chr(09) ||
                                  chr(09) || chr(09) || chr(09) || chr(09) ||
                                  chr(09) || chr(09) || chr(09) || chr(09) ||
                                  chr(09);
                    mi_szLinea := mi_szLinea || chr(09) ||
                                  mi_condicion_pago || chr(09) || mi_texto ||
                                  chr(09) || chr(09) || chr(09) || chr(09) ||
                                  chr(09) || chr(09) || mi_viapago ||
                                  chr(09) || chr(09) || chr(09) || chr(09) ||
                                  chr(09) || chr(09) || mi_codbanco ||
                                  chr(09) || rpad(mi_beneficiario_type.mi_numero_cuenta,
                                                  20,
                                                  ' ') || chr(09) ||
                                  rpad(mi_beneficiario_type.mi_tipo_cuenta,
                                       2,
                                       ' ');
                    mi_szLinea := mi_szLinea || chr(09) || '  ' || chr(09) ||
                                  mi_basertfte || chr(09) || chr(09) ||
                                  chr(09) || chr(09);
                    Text_IO.Put_Line(mi_archivo_sap, mi_szLinea);
                  --end if;
                END IF;
              
              END IF;
            END LOOP;
            EXEC_SQL.CLOSE_CURSOR(EXEC_SQL.DEFAULT_CONNECTION, mi_cursor);
          
          EXCEPTION
            WHEN OTHERS THEN
              IF SQLCODE = -302000 THEN
                pr_despliega_mensaje('AL_STOP_1',
                                     'Ocurrio un error intentando escribir el archivo ' ||
                                     mi_archivo_plano);
              ELSE
                pr_despliega_mensaje('AL_STOP_1',
                                     'Ocurrió el error: ' ||
                                     To_Char(SQLCODE));
              END IF;
            
              RAISE Form_Trigger_Failure;
          END; --Otros Anexos
        
        END IF;
      END LOOP; --Termina de recorrer los centros de costo para el tipo de nómina
      CLOSE cur_anexos;
      --
    END LOOP; --Termina de recorrer el loop de las RA a generar (una para la vigencia,
    --otra para reservas)
    Text_IO.fClose(mi_archivo_sap_foncep);
    pr_debug_registra(mi_file_debug_handle,'2550 Text_IO.fClose(mi_archivo_sap_foncep) y mostrar archivos');
    web.show_document(mi_pathweb_ra ||'/'|| mi_archivo_planosap, '_blank');
   -- web.show_document(mi_pathweb_ra ||'/'|| mi_archivo_planosapfoncep, '_blank');
    IF mi_cc IS NULL THEN
      pr_despliega_mensaje('AL_STOP_1',
                           'No se han definido centros de costo para el tipo de RA.' ||
                           mi_cc);
    ELSE
      IF mi_terceros_neg > 0 THEN
        text_io.fclose(mi_id_error);
        pr_despliega_mensaje('AL_STOP_1',
                             'Existen terceros con pagos negativos.  Será¡ rechazada la RA en OPGET.');
        IF GET_APPLICATION_PROPERTY(USER_INTERFACE) = 'WEB' THEN
          web.show_document(mi_pagina_carga || '/' ||
                            mi_nombre_archivo_err,
                            '_BLANK');
        ELSE
          HOST('NOTEPAD.EXE ' || 'c:\' || mi_nombre_archivo_err);
        END IF;
      END IF;
      IF text_io.is_open(mi_id_error) THEN
        text_io.fclose(mi_id_error);
      END IF;
      Text_IO.fClose(mi_archivo_sap);
      If Text_IO.Is_Open(mi_archivo_sap) Then
        Text_IO.fClose(mi_archivo_sap);
        web.show_document(mi_pathweb_ra ||'/'|| mi_archivo_planosap, '_blank');
      End If;
      pr_despliega_mensaje('AL_STOP_1',
                           'Fueron generados los archivos planos.');
    END IF;
  end loop;
  CLOSE c_ra;
  Text_IO.fClose(mi_archivo_sap);
  If Text_IO.Is_Open(mi_archivo_sap) Then
    Text_IO.fClose(mi_archivo_sap);
    web.show_document(mi_pathweb_ra ||'/'|| mi_archivo_planosap, '_blank');
  End If;
  if :B_RA.cta_x_nomina = '999999999' then    
		if text_io.is_open(mi_file_debug_handle) then 
			Text_IO.fClose(mi_file_debug_handle) ;
		end if; 
	end if;
EXCEPTION
  WHEN OTHERS THEN
    IF text_io.is_open(mi_id_error) THEN
      text_io.fclose(mi_id_error);
    END IF;
    mi_sqlcode := SQLCODE;
    IF mi_sqlcode = 100 THEN
      NULL;
    ELSE

     pr_despliega_mensaje('AL_STOP_1',  '22 Ocurrió un error. mi_cc | SQLERRM | linea :' ||
                           mi_cc || ' | ' || SQLERRM() || '| ' ||
                           mi_linea_ejecutada);
     pr_debug_registra(mi_file_debug_handle,'22 Ocurrió un error. mi_cc | SQLERRM | linea :V' ||
                           mi_cc || ' | ' || SQLERRM() || '| ' ||
                           mi_linea_ejecutada);                       
     pr_debug_registra(mi_file_debug_handle,'22 Ocurrió un error. mi_cc | SQLERRM | query : ' ||
                           mi_cc || ' | ' || SQLERRM() || '| ' ||
                           mi_consulta);   
     	if :B_RA.cta_x_nomina = '999999999' then                      
				if text_io.is_open(mi_file_debug_handle) then 
					Text_IO.fClose(mi_file_debug_handle) ;
				end if;             
			end if;
     -- dbms_output.put_line(substr(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,500));
    END IF;
    mi_err := 1;
  
END PR_PLANOS_RA_SHD;