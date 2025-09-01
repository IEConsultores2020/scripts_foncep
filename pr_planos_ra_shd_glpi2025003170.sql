   procedure pr_planos_ra_shd (
      una_compania      varchar2,
      un_tipo_ra        varchar2,
      un_grupo_ra       varchar2,
      un_tipo_nomina    number,
      una_fecha_inicial date,
      una_fecha_final   date,
      mi_err            out number
   ) is
--20250623			V3.8	CREACION FTORRESV
--2025003170		V.4 	20250821 FTORRESV
      cursor rubros (
         un_nro_ra number
      ) is
      select distinct b.cc rubro,
                      b.grupo_ra
        from rh_t_lm_valores a,
             rh_lm_cuenta b,
           --RH_LM_CENTROS_COSTO L,
             rh_funcionario f
       where b.stipo_funcionario = a.stipofuncionario
         and a.periodo = una_fecha_final
         and a.ntipo_nomina = un_tipo_nomina
         and a.sdevengado in ( 0,
                               1 )
         and a.nro_ra = un_nro_ra
         and b.scompania = una_compania
         and b.tipo_ra = un_tipo_ra
         and b.ncierre = 1
         and tipo_ra = un_tipo_ra
       /*--PRUEBAS 2022
            and       a.nfuncionario IN (3428) --*/
         and b.dfecha_inicio_vig <= una_fecha_final
         and ( b.dfecha_final_vig >= una_fecha_final
          or b.dfecha_final_vig is null )
         and f.personas_interno = a.nfuncionario
         and b.cc is not null
      union
      select distinct b.cc rubro,
                      b.grupo_ra
        from rh_t_lm_valores a,
             rh_lm_cuenta b,
           --RH_LM_CENTROS_COSTO L,
             rh_funcionario f
       where b.stipo_funcionario = a.stipofuncionario
     /*PRUEBAS
          AND      b.sconcepto         =   a.sconcepto --*/
         and a.periodo = una_fecha_final
         and a.ntipo_nomina = un_tipo_nomina
         and a.sdevengado in ( 2,
                               4 )
         and a.nro_ra = un_nro_ra
         and b.scompania = una_compania
         and b.tipo_ra = un_tipo_ra
         and b.ncierre = 1
         and tipo_ra = un_tipo_ra
          /*--PRUEBAS 2022
            and       a.nfuncionario IN (4966,4946) --*/
         and b.dfecha_inicio_vig <= una_fecha_final
         and ( b.dfecha_final_vig >= una_fecha_final
          or b.dfecha_final_vig is null )
         and f.personas_interno = a.nfuncionario
         and b.cc is not null;

      cursor reg40 (
         un_nro_ra number
      ) is
      select '7990990000' cuenta_credito,
             sum(decode(
                regimen,
                '3',
                a.valor,
                '1',
                0,
                '2',
                0
             )) valor_rubro,
             '5000001965' rp_doc_presupuestal,
             decode(
                c.descripcion,
                'Sueldo básico',
                '0001',
                c.codigo_nivel7
             ) posicion_doc_presupuestal
        from rh_t_lm_valores a,
             rh_lm_cuenta b,
             pr_v_rubros c
       where tipo_ra = '1'
         and grupo_ra = '5'
         and scompania = una_compania
         and stipo_funcionario = stipofuncionario
         and a.sconcepto = b.sconcepto
         and ncierre = 1
         and c.interno_rubro = b.codigo_presupuesto
         and c.vigencia = extract(year from una_fecha_final)
         and a.ntipo_nomina = '0'
         and dfecha_inicio_vig <= una_fecha_final
         and ( dfecha_final_vig >= una_fecha_final
          or dfecha_final_vig is null )
         and b.codigo_presupuesto is not null
         and periodo = una_fecha_final  --:P_FECHA_FINAL
      --AND   nro_ra              = un_nro_ra            ---:P_NRORA
       group by codigo_nivel1,
                codigo_nivel2,
                codigo_nivel3,
                codigo_nivel4,
                codigo_nivel7,
                codigo_nivel5
                || '-'
                || codigo_nivel6
                || '-'
                || codigo_nivel7
                || '-'
                || codigo_nivel8,
                descripcion,
                interno_rubro
       order by codigo_nivel5
                || '-'
                || codigo_nivel6
                || '-'
                || codigo_nivel7
                || '-'
                || codigo_nivel8;

      cursor cur_anexos (
         un_cc number
      ) is
      select b.codigo,
             b.descripcion,
             'SAP' || a.archivo_plano,
             b.tabla_detalle
        from rh_lm_ra_cc a,
             rh_lm_centros_costo b
       where a.ra = un_tipo_ra
         and a.cc = un_cc
       /*--FTV PRUEBA 202405
          AND a.cc  =   7  --*/
         and a.cc = b.codigo;

      cursor cur_nxp (
         un_nro_ra number,
         un_cc     number
      ) is
      select nfuncionario,
             abs(sum(valor)) valor,
             f.codigo_banco codigo_banco
        from rh_t_lm_valores a,
             rh_lm_cuenta b,
             rh_funcionario f
       where b.stipo_funcionario = a.stipofuncionario
         and b.sconcepto = a.sconcepto
         and a.periodo = una_fecha_final
         and a.ntipo_nomina = un_tipo_nomina
         and a.sdevengado in ( 0,
                               1 )
         and a.nro_ra = un_nro_ra
         and b.scompania = una_compania
         and b.tipo_ra = un_tipo_ra
         and b.grupo_ra in ( un_grupo_ra )
         and b.ncierre = 1
       /*--PRUEBAS 2022
          --  and      b.codigo_presupuesto=   un_cc
            and       a.nfuncionario IN (4966,4946) --*/
         and b.dfecha_inicio_vig <= una_fecha_final
         and ( b.dfecha_final_vig >= una_fecha_final
          or b.dfecha_final_vig is null )
         and f.personas_interno = a.nfuncionario
       group by nfuncionario,
                f.codigo_banco;

      cursor cur_nxpcc (
         un_nro_ra number,
         un_cc     number
      ) is
      select nfuncionario,
             abs(sum(valor)) valor,
             to_number(f.codigo_banco) codigo_banco
        from rh_t_lm_valores a,
             rh_lm_cuenta b,
             rh_funcionario f
       where b.sconcepto = a.sconcepto
         and a.periodo = una_fecha_final
         and a.ntipo_nomina = un_tipo_nomina
         and a.sdevengado in ( 0,
                               1 )
         and a.nro_ra = un_nro_ra
         and b.scompania = una_compania
         and b.tipo_ra = un_tipo_ra
         and b.grupo_ra in ( un_grupo_ra )
         and b.ncierre = 1
         and b.codigo_presupuesto = un_cc
    /*--PRUEBAS 
      and       a.nfuncionario IN (4966,4946) --*/
         and b.dfecha_inicio_vig <= una_fecha_final
         and ( b.dfecha_final_vig >= una_fecha_final
          or b.dfecha_final_vig is null )
         and f.personas_interno = a.nfuncionario
       group by nfuncionario,
                f.codigo_banco;

  /* datos de retencion */
      cursor retefteperiodo (
         un_nro_ra number
      ) is
      select sum(retencion) retencion,
             sum(base) base,
             sum(asignacion) asignacion
        from (
         select 0 retencion,
                abs(sum(valor)) base,
                0 asignacion
           from rh_t_lm_valores a
          where a.periodo = una_fecha_final
            and a.ntipo_nomina = un_tipo_nomina
            and ( a.sdevengado in ( 0 )
                   --INI SINPROC 3320191 
             or ( a.sdevengado = 1
            and variable_valor like 'NDV%' ) )
                  --FIN SINPROC 3320191
            and a.nro_ra = un_nro_ra
         union
         select abs(sum(valor)) retencion,
                0 base,
                0 asignacion
           from rh_t_lm_valores a
          where a.periodo = una_fecha_final
            and a.ntipo_nomina = un_tipo_nomina
            and a.sdevengado in ( 1 )
            and sconcepto like 'RET%FUENTE%'
            and a.nro_ra = un_nro_ra
         union
         select 0 retencion,
                0 base,
                sum(ndcampo4) asignacion
           from rh_historico_nomina
          where nhash = 1128917309
            and dfechaefectiva >= to_char(
               una_fecha_inicial,
               'yyyymm'
            )
                   || '01'
            and dfechaefectiva <= to_char(
               una_fecha_final,
               'yyyymmdd'
            )
            and nretroactivo = 0
            and ntipoconcepto = 1
            and nfuncionario in (
            select nfuncionario
              from rh_t_lm_valores
             where nro_ra = un_nro_ra
               and periodo = una_fecha_final
         )
      );


      cursor cur_fna (
         un_nro_ra number
      ) is
      select abs(sum(valor)) valor,
             tipo_documento,
             numero_documento,
             forma_pago
        from rh_t_lm_valores a,
             rh_lm_cuenta b,
             rh_entidad e
       where b.stipo_funcionario = a.stipofuncionario
         and b.sconcepto = a.sconcepto
         and a.periodo = una_fecha_final
         and a.ntipo_nomina = un_tipo_nomina
         and a.sdevengado in ( 3 )
         and a.nro_ra = un_nro_ra
         and b.scompania = una_compania
         and b.tipo_ra = un_tipo_ra
         and b.grupo_ra in ( un_grupo_ra )
         and b.ncierre = 1
         and a.sconcepto = 'INFOCESANTIAS_FNA'
       /*--PRUEBAS 2022
            and       a.nfuncionario IN (4966,4946) --*/
         and b.dfecha_inicio_vig <= una_fecha_final
         and ( b.dfecha_final_vig >= una_fecha_final
          or b.dfecha_final_vig is null )
         and a.sconcepto = 'INFOCESANTIAS_FNA'
         and a.stercero = lpad(
         e.codigo,
         2,
         0
      )
         and e.tipo = 'FONDO_CESANTIAS'
       group by a.nro_ra,
                tipo_documento,
                numero_documento,
                forma_pago;
  /* fin cesantias fna */
      cursor pagorubro (
         un_cc     number,
         un_nro_ra number
      ) is
      select abs(sum(a.valor)) pago,
             c.concepto_rubro rubro
        from rh_t_lm_valores a,
             rh_lm_cuenta b,
             rh_lm_cuentas_ra c,
             rh_funcionario f
       where b.stipo_funcionario = a.stipofuncionario
         and b.sconcepto = a.sconcepto
         and a.periodo = una_fecha_final
         and a.ntipo_nomina = un_tipo_nomina
         and a.sdevengado in ( 0,
                               1 )
         and a.nro_ra = un_nro_ra
         and b.scompania = una_compania
         and b.tipo_ra = un_tipo_ra
         and b.grupo_ra in ( un_grupo_ra )
         and b.codigo_presupuesto = un_cc
         and b.ncierre = 1
         and c.codigo_concepto_cc = b.codigo_presupuesto
         and c.grupo_ra = b.grupo_ra
         and b.codigo_presupuesto not in ( 1,
                                           2 )
          /*--PRUEBAS 
            and       a.nfuncionario IN (4966,4946) --*/
         and b.dfecha_inicio_vig <= una_fecha_final
         and ( b.dfecha_final_vig >= una_fecha_final
          or b.dfecha_final_vig is null )
         and f.personas_interno = a.nfuncionario
       group by c.concepto_rubro;

      cursor pagorubronxp (
         un_cc     number,
         un_nro_ra number
      ) is
      select abs(sum(valor)) pago
        from rh_t_lm_valores a
       where a.periodo = una_fecha_final
         and a.ntipo_nomina = un_tipo_nomina
         and a.sdevengado in ( 0,
                               1 )
         and a.nro_ra = un_nro_ra;

      cursor cur_embargos (
         un_cc     number,
         un_nro_ra number
      ) is
  --mi_tercero, mi_funcionario, mi_sdescuento,mi_nbeneficiario,mi_codbeneficiario,  mi_fpagobeneficiario, mi_valor;
      select a.stercero,
             a.nfuncionario,
             a.sdescuento,
             bb.beneficiario,
             d.cod_benef_pago,
             d.forma_pago,
             d.proceso,
             sum(valor) valor,
             d.concepto
        from rh_t_lm_valores a,
             rh_lm_cuenta b,
             rh_lm_centros_costo c,
             rh_beneficiarios bb,
             rh_descuentos_f d
       where b.stipo_funcionario = a.stipofuncionario
         and b.sconcepto = a.sconcepto
         and b.cc = c.codigo
         and a.periodo = una_fecha_final
         and a.ntipo_nomina = un_tipo_nomina
         and d.funcionario = a.nfuncionario
         and d.beneficiario = a.stercero
         and d.tipo = substr(
         a.sconcepto,
         2
      )
         and a.sdevengado in ( 0,
                               1 )
         and a.sdescuento = d.numero_descuento
         and d.estado in ( 1,
                           2,
                           4 )
         and a.nro_ra = un_nro_ra
         and b.scompania = una_compania
         and b.tipo_ra = un_tipo_ra
         and bb.codigo_beneficiario = a.stercero
         and b.grupo_ra in ( un_grupo_ra )
         and b.ncierre = 1
         and d.forma_pago = 'B'
         and b.dfecha_inicio_vig <= una_fecha_final
         and ( b.dfecha_final_vig >= una_fecha_final
          or b.dfecha_final_vig is null )
         and b.cc = 6
    /*--PRUEBAS 2022
      and       a.nfuncionario IN (4966,4946) --*/
       group by stercero,
                a.nfuncionario,
                bb.beneficiario,
                d.forma_pago,
                a.sdescuento,
                d.cod_benef_pago,
                d.proceso,
                d.concepto;

      cursor cur_embargosnba (
         un_cc     number,
         un_nro_ra number
      ) is
      select a.stercero,
             a.nfuncionario,
             a.sdescuento,
             bb.beneficiario,
             d.forma_pago,
             d.cod_benef_pago,
             d.banco,
             d.tipo_cuenta,
             d.numero_cuenta,
             d.proceso,
             sum(valor) valor
        from rh_t_lm_valores a,
             rh_lm_cuenta b,
             rh_lm_centros_costo c,
             rh_beneficiarios bb,
             rh_descuentos_f d
       where b.stipo_funcionario = a.stipofuncionario
         and b.sconcepto = a.sconcepto
         and b.cc = c.codigo
         and a.periodo = una_fecha_final
         and a.ntipo_nomina = un_tipo_nomina
         and d.funcionario = a.nfuncionario
         and d.beneficiario = a.stercero
         and d.tipo = substr(
         a.sconcepto,
         2
      )
         and a.sdevengado in ( 0,
                               1 )
         and a.sdescuento = d.numero_descuento
         and d.estado in ( 1,
                           2,
                           4 )
         and a.nro_ra = un_nro_ra
         and b.scompania = una_compania
         and b.tipo_ra = un_tipo_ra
         and bb.codigo_beneficiario = a.stercero
         and b.grupo_ra in ( un_grupo_ra )
         and b.ncierre = 1
         and d.forma_pago != 'B'
         and b.dfecha_inicio_vig <= una_fecha_final
         and ( b.dfecha_final_vig >= una_fecha_final
          or b.dfecha_final_vig is null )
         and b.cc = 6
    /*--PRUEBAS 2022
      and       a.nfuncionario IN (4966,4946) --*/
       group by a.stercero,
                a.nfuncionario,
                a.sdescuento,
                bb.beneficiario,
                d.forma_pago,
                d.cod_benef_pago,
                d.banco,
                d.tipo_cuenta,
                d.numero_cuenta,
                d.proceso;

      cursor c_ra is
      select nro_ra,
             aprobacion
        from rh_lm_ra
       where scompania = una_compania
         and tipo_ra = un_tipo_ra
         and grupo_ra = un_grupo_ra
         and dfecha_inicial_periodo = una_fecha_inicial
         and dfecha_final_periodo = una_fecha_final
         and ntipo_nomina = un_tipo_nomina;

      type ra_type is record (
            mi_nro_ra   rh_lm_ra.nro_ra%type,
            mi_aprobado varchar2(1)
      );
      cursor encabezado (
         un_grupo varchar2
      ) is
      select to_char(
         sysdate,
         'yyyymmdd'
      ) fdoc,
             lpad(
                1,
                10,
                ' '
             ) ndoc,
             decode(
                un_tipo_ra,
                1,
                'NE',
                3,
                'NE',
                'NA'
             ) clasedoc,
             '1001' sociedad,
             to_char(
                sysdate,
                'yyyymmdd'
             ) fcontab,
           --TO_CHAR(SYSDATE, 'mm') periodo, FCP200250517
             '  ' periodo, --FCP200250517
             'COP' moneda,
             lpad(
                ' ',
                9
             ) cambio,
             'Nomina '
             || to_char(
                sysdate,
                'FMMONTH',
                'NLS_DATE_LANGUAGE = Spanish'
             ) nrodoc,
             '13 Nomina '
             || to_char(
                sysdate,
                'FMMONTH',
                'NLS_DATE_LANGUAGE = Spanish'
             ) cabecera
        from dual;

      cursor codach (
         un_banco varchar2
      ) is
      select lpad(
         cod_superbancaria,
         3,
         0
      ) codigo_ach
        from rh_entidad
       where codigo = un_banco
         and tipo = 'BANCO';

      cursor nom_entidad (
         una_entidad varchar2
      ) is
      select ib_primer_nombre nomentidad
        from trc_informacion_basica b,
             trc_terceros t
       where b.id = t.id
         and t.codigo_identificacion = una_entidad
         and ib_fecha_final is null;

      cursor descc (
         un_cc number
      ) is
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
      mi_incapacidad            rh_t_lm_valores.valor%type;
      mi_saldo                  rh_t_lm_valores.valor%type;
      mi_cc                     rh_lm_centros_costo.codigo%type := null;
      mi_funcionario            rh_t_lm_valores.nfuncionario%type;
      mi_texto_nomina_mes       varchar2(200);
      mi_concepto               rh_t_lm_valores.sconcepto%type;
      mi_ofi_origen             varchar2(50); --NFCP rh_descuentos_f.ban_agra_origen%TYPE;
      mi_ofi_destino            varchar2(50); --NFCP rh_descuentos_f.ban_agra_destino%TYPE;
      mi_conceptoemb            varchar2(60);
      mi_concepto_entidad_benef rh_t_lm_valores.sconcepto%type;
      mi_concepto_inc           rh_t_lm_valores.sconcepto%type;
      mi_concepto_saldos        rh_t_lm_valores.sconcepto%type;
      mi_tercero                rh_t_lm_valores.stercero%type;
      mi_sdescuento             rh_t_lm_valores.sdescuento%type;
      mi_valor                  rh_t_lm_valores.valor%type := 0;
      mi_valor_saldo            rh_t_lm_valores.valor_saldo%type;
      mi_grupo_ra               varchar2(200);
      mi_vigencia               varchar2(4);
      mi_mes                    varchar2(2);
      mi_tabla_detalle          varchar2(100);
      mi_tabla                  varchar2(30);
      mi_nombre_entidad         varchar2(60);
      mi_archivo_plano          varchar2(100);
      mi_archivo_planoemb       varchar2(100);
      mi_archivo_planosap       varchar2(100);
      mi_archivo_planosapfoncep varchar2(100);
      mi_descripcion_cc         varchar2(100);
      mi_archivo_path           text_io.file_type;
      mi_archivo_sap            text_io.file_type;
      mi_archivo_sap_foncep     text_io.file_type;
      mi_archivo_sap2           text_io.file_type;
      mi_www_path               varchar2(1000);
      mi_pathweb_ra             varchar2(1000);
      mi_szlinea                varchar2(4000);
      mi_szlinea2               varchar2(4000);
      mi_cursor                 exec_sql.curstype;
      nign                      pls_integer; --Variable para manejar el cursor diná¡mico
      mi_consulta               varchar2(2000) := null;
      mi_autoliq                boolean := true;
      mi_id_error               text_io.file_type;
      mi_nombre_archivo_err     varchar2(500);
      mi_directorio_carga       varchar2(500);
      mi_pagina_carga           varchar2(500);
      mi_sqlcode                number;
      mi_terceros_neg           number := 0;
      mi_nit_agrario            varchar2(12);
      mi_tipo_entidad           varchar2(150);
      mi_total_fna              number := 0;
      mi_consecutivo            number := 0;
      mi_nro_ra                 number := 0;
      mi_asignacion             number := 0;
      mi_pago_rubro             number := 0;
      mi_nit_ces                varchar2(15);
      mi_tiponit_ces            varchar2(3);
      mi_var90rete              varchar2(2);
      forma_pagoces             varchar2(3);
      mi_codbanco               varchar2(3);
      mi_valor_ces              number;
      mi_basertfte              varchar2(15);
      mi_retefuente             varchar2(15);
      mi_cuentarub              varchar2(20);
      mi_codigo                 varchar2(3);
      mi_viapago                varchar2(1);
      mi_nombrecc               varchar2(50);
      mi_banco                  varchar2(250);
      mi_cuentareg              number := 0;
      mi_tipo_cuentafun         varchar2(2);
      mi_tipo_funcionarios      varchar2(50);
      mi_bancoref               varchar2(250);
      mi_condicion_pago         varchar2(4);
      mi_codbeneficiario        varchar2(20);
      mi_fpagobeneficiario      varchar2(20);
      mi_nbeneficiario          varchar2(120);
      mi_bancoemb               varchar2(3);
      mi_tipo_cuenta_emb        varchar2(3);
      mi_numero_cuenta_emb      varchar2(20);
      mi_proceso                varchar2(30);
      mi_cuenta_debito          varchar2(30);
      mi_cuenta_credito         varchar2(30);
      mi_texto                  varchar2(30);
      mi_archivo_plano2         varchar2(100);
      mi_archivo_path2          text_io.file_type;

  --FTV usado para guardar la linea ejecutada, se informa en caso de generar una excepción.
      mi_linea_ejecutada        varchar(100);
      mi_file_debug_handle      text_io.file_type;
      mi_file_debug_path        varchar2(1000);
   begin
      mi_err := 0;
  --mi_file_debug_handle := pr_debug_activa;
      if :b_ra.cta_x_nomina = '999999999' then
         if get_application_property(operating_system) like '%WIN%' then
            mi_file_debug_path := 'Z:\temp';
            mi_file_debug_path := mi_file_debug_path || '\rh_lm_ra_form_log.txt';
         else
            mi_file_debug_path := p_bintablas.tbuscar(
               'PATH_ANEXO_RA',
               'NOMINA',
               'QUERY',
               to_char(
                     sysdate,
                     'dd/mm/yyyy'
                  )
            );
            mi_file_debug_path := mi_file_debug_path || '/rh_lm_ra_form_log.txt';
         end if;

         mi_file_debug_handle := text_io.fopen(
            mi_file_debug_path,
            'w'
         );
      end if;
  
  --Validar que los conceptos de saldos a favor o en contra o incapacidades en la autoliquidación
  --no tengan marcado centro de costo
      mi_autoliq := pk_detalle_anexos_ra.fn_validar_cc_salud_arp(
         una_compania,
         una_fecha_final,
         mi_err
      );
  --message('aportes ');
      if mi_err = 1 then
         return;
      end if;
      if mi_autoliq then
         pr_despliega_mensaje(
            'AL_STOP_1',
            'Existen conceptos de autoliquidación para incapacidades o saldos a favor o en contra asociados a un centro de costo.'
         );
         mi_err := 1;
         return;
      end if;
      if get_application_property(operating_system) like '%WIN%' then
         mi_www_path := 'Z:\temp';
      else
         mi_www_path := p_bintablas.tbuscar(
            'PATH_ANEXO_RA',
            'NOMINA',
            'QUERY',
            to_char(
               sysdate,
               'dd/mm/yyyy'
            )
         );
      end if;
      mi_pathweb_ra := p_bintablas.tbuscar(
         'PATH_WEBANEXO_RA',
         'NOMINA',
         'QUERY',
         to_char(
            sysdate,
            'dd/mm/yyyy'
         )
      );
  /* Comentariar quitando los dos -- para pasar a producciá²n
  pr_despliega_mensaje('AL_STOP_1','Modifique la ruta del codigo fuente antes de pasar a producción');
  mi_www_path :='Z:\Planossap'; --USAR SOLO PARA PROBAR LOCAL
  --*/
  --   message('Ruta '|| mi_www_path);
  --mi_www_path :='d:\apps\descarga';
      if mi_www_path is null then
         pr_despliega_mensaje(
            'AL_STOP_1',
            'No se encuentra definido en bintablas el path para generar el archivo'
         );
         mi_err := 1;
         return;
      end if;
      mi_nit_agrario := p_bintablas.tbuscar(
         'BANCO_AGRARIO',
         'GENERAL',
         'NIT',
         to_char(
            sysdate,
            'dd/mm/yyyy'
         )
      );
  -- adicionar archivo encabezado 20181018 WN
      mi_archivo_planosap := :b_ra_seq.secuencial
                             || '-nomina'
                             || una_compania
                             || to_char(
         sysdate,
         'yyyymmddhhmiss'
      )
                             || to_char(
         una_fecha_final,
         'yyyymm'
      )
                             || '.txt';
      begin
         if get_application_property(user_interface) = 'WEB' then
      --mi_id_error      := text_io.fopen(mi_directorio_carga||'/'||mi_nombre_archivo_err, 'w');
      --Mensaje pruebas si cta_x_nomina = 999999999
            pr_debug_registra(
               mi_file_debug_handle,
               'Linea 534 IF GET_APPLICATION_PROPERTY(USER_INTERFACE) = WEB es cierto'
            );
            if get_application_property(operating_system) like '%WIN%' then
               mi_archivo_sap := text_io.fopen(
                  mi_www_path
                  || '\'
                  || mi_archivo_planosap,
                  'w'
               );
            else
               mi_archivo_sap := text_io.fopen(
                  mi_www_path
                  || '/'
                  || mi_archivo_planosap,
                  'w'
               );
            end if;
         else
            mi_archivo_sap := text_io.fopen(
               'c:\' || mi_archivo_planosap,
               'w'
            );
         end if;
      exception
         when others then
            mi_sqlcode := sqlcode;
            if mi_sqlcode = -302000 then
               loop
                  exit when tool_err.nerrors = 0;
                  message(to_char(tool_err.code)
                          || ': '
                          || tool_err.message);
                  tool_err.pop;
               end loop;
            end if;
            pr_despliega_mensaje(
               'AL_STOP_1',
               '1 Ocurrió un error '
               || sqlerrm()
               || ' '
               || sqlcode()
            );
            mi_err := 1;
            return;
      end;
      mi_condicion_pago := una_compania || '1';
      mi_tipo_funcionarios := p_bintablas.tbuscar(
         un_grupo_ra,
         'NOMINA',
         'RELACIONAUTORIZACION_GRUPOS',
         to_char(
            sysdate,
            'dd/mm/yyyy'
         )
      )
                              || p_bintablas.tbuscar(
         un_tipo_ra,
         'NOMINA',
         'RELACIONAUTORIZACION',
         to_char(
            sysdate,
            'dd/mm/yyyy'
         )
      );

      for e in encabezado(un_grupo_ra) loop
         mi_szlinea := 'C'
                       || chr(09)
                       || e.ndoc
                       || chr(09)
                       || to_char(
            sysdate,
            'yyyymmdd'
         )
                       || chr(09)
                       || e.clasedoc
                       || chr(09)
                       || e.sociedad
                       || chr(09)
                       || e.fcontab
                       || chr(09)
                       || e.periodo
                       || chr(09)
                       || e.moneda
                       || chr(09)
                       || e.cambio
                       || chr(09)
                       || e.nrodoc
                       || chr(09)
                       || e.cabecera;
         mi_texto := 'NA '; --N/A'e.CABECERA||to_char(una_fecha_final,'yyyymm');
         text_io.put_line(
            mi_archivo_sap,
            mi_szlinea
         );
         pr_debug_registra(
            mi_file_debug_handle,
            'Linea 582 Text_IO.Put_Line(mi_archivo_sap, mi_szLinea)'
         );
      end loop;

      for e in reg40(mi_nro_ra) loop
         pr_debug_registra(
            mi_file_debug_handle,
            'reg40 posicion:valor_rubro '
            || e.posicion_doc_presupuestal
            || ':'
            || e.valor_rubro
         );
         mi_szlinea := 'P'
                       || chr(09)
                       || '40'
                       || chr(09)
                       || e.cuenta_credito
                       || chr(09)
                       || chr(09)
                       || chr(09)
                       || chr(09)
                       || chr(09)
                       || e.valor_rubro
                       || chr(09)
                       || ' '
                       || chr(09)
                       || e.rp_doc_presupuestal
                       || chr(09)
                       || e.posicion_doc_presupuestal;
         text_io.put_line(
            mi_archivo_sap,
            mi_szlinea
         );
      end loop;

      open c_ra;
      loop
         fetch c_ra into mi_ra_type;
         exit when c_ra%notfound;
         if mi_ra_type.mi_aprobado = 'N' then
            pr_despliega_mensaje(
               'AL_STOP_1',
               'No se ha aprobado la relación de autorización.'
            );
            raise form_trigger_failure;
         end if;

         mi_consecutivo := 0;
  
    -- recorrer por los rubros registrados 
    -- message(' planos '||mi_archivo_planosap|| mi_ra_type.mi_nro_ra);

         mi_bancoref := p_bintablas.tbuscar(
            'BANCO_REFERENCIA',
            'NOMINA',
            'PARAMETROS NOMINA',
            to_char(
               sysdate,
               'dd/mm/yyyy'
            )
         );
         if mi_bancoref is null then
            pr_despliega_mensaje(
               'AL_STOP_1',
               'No se encuentra definido el pará¡metro NOMINA/PARAMETROS NOMINA/BANCO_REFERENCIA. Se generará¡ un solo archivo para el pago a funcionarios.'
            );
            return;
         end if;
         mi_directorio_carga := p_bintablas.tbuscar(
            'DIRECTORIO_PAGINA_CARGA',
            'NOMINA',
            'PATH',
            to_char(
               sysdate,
               'dd/mm/yyyy'
            )
         );
         if mi_directorio_carga is null then
            pr_despliega_mensaje(
               'AL_STOP_1',
               'No se encuentra definido el pará¡metro DIRECTORIO_PAGINA_CARGA.  Por favor revise.'
            );
            return;
         end if;
         mi_pagina_carga := p_bintablas.tbuscar(
            'WWW_PAGINA_CARGA',
            'NOMINA',
            'PATH',
            to_char(
               sysdate,
               'dd/mm/yyyy'
            )
         );
         if mi_pagina_carga is null then
            pr_despliega_mensaje(
               'AL_STOP_1',
               'No se encuentra definido el pará¡metro WWW_PAGINA_CARGA.  Por favor revise.'
            );
            return;
         end if;
         mi_grupo_ra := p_bintablas.tbuscar(
            un_grupo_ra,
            'NOMINA',
            'RELACIONAUTORIZACION_GRUPOS_RA',
            to_char(
               sysdate,
               'dd/mm/yyyy'
            )
         );
         mi_vigencia := to_char(
            una_fecha_final,
            'YYYY'
         );
         mi_mes := to_char(
            una_fecha_final,
            'MM'
         );
    --Para abrir el archivo que genera listado de terceros con pagos negativos
         mi_nombre_archivo_err := 'TERCEROS_NEGATIVOS.TXT';
         begin
            if get_application_property(user_interface) = 'WEB' then
        --mi_id_error      := text_io.fopen(mi_directorio_carga||'/'||mi_nombre_archivo_err, 'w');
               if get_application_property(operating_system) like '%WIN%' then
                  mi_id_error := text_io.fopen(
                     mi_www_path
                     || '\'
                     || mi_nombre_archivo_err,
                     'w'
                  );
               else
                  mi_id_error := text_io.fopen(
                     mi_www_path
                     || '/'
                     || mi_nombre_archivo_err,
                     'w'
                  );
               end if;
            else
               mi_id_error := text_io.fopen(
                  'c:\' || mi_nombre_archivo_err,
                  'w'
               );
            end if;
            pr_debug_registra(
               mi_file_debug_handle,
               '651 mi_nombre_archivo_err :'
            );
         exception
            when others then
               mi_sqlcode := sqlcode;
               if mi_sqlcode = -302000 then
                  loop
                     exit when tool_err.nerrors = 0;
                     message(to_char(tool_err.code)
                             || ': '
                             || tool_err.message);
                     tool_err.pop;
                  end loop;
               end if;
               pr_despliega_mensaje(
                  'AL_STOP_1',
                  '1 Ocurrió un error '
                  || sqlerrm()
                  || ' '
                  || sqlcode()
               );
               mi_err := 1;
               return;
         end;
         text_io.put_line(
            mi_id_error,
            'Terceros con pagos negativos'
         );
         text_io.fclose(mi_id_error); --wn 20190515
         pr_debug_registra(
            mi_file_debug_handle,
            '670 Cierra Terceros con pagos negativos'
         );
         mi_texto_nomina_mes := 'Nomina '
                                || to_char(
            sysdate,
            'FMMONTH',
            'NLS_DATE_LANGUAGE = Spanish'
         );
         mi_cuentareg := 0;
         mi_archivo_planosapfoncep := :b_ra_seq.secuencial
                                      || '-nominafoncep'
                                      || una_compania
                                      || to_char(
            sysdate,
            'yyyymmddhhmiss'
         )
                                      || to_char(
            una_fecha_final,
            'yyyymm'
         )
                                      || '.txt';
         if get_application_property(operating_system) like '%WIN%' then
            mi_archivo_sap_foncep := text_io.fopen(
               mi_www_path
               || '\'
               || mi_archivo_planosapfoncep,
               'w'
            );
         else
            mi_archivo_sap_foncep := text_io.fopen(
               mi_www_path
               || '/'
               || mi_archivo_planosapfoncep,
               'w'
            );
         end if;
         pr_debug_registra(
            mi_file_debug_handle,
            '689 open mi_archivo_sap_foncep'
         );
         for e in encabezado(un_grupo_ra) loop
            mi_szlinea := 'C'
                          || chr(09)
                          || e.ndoc
                          || chr(09)
                          || to_char(
               sysdate,
               'yyyymmdd'
            )
                          || chr(09)
                          || e.clasedoc
                          || chr(09)
                          || e.sociedad
                          || chr(09)
                          || e.fcontab
                          || chr(09)
                          || e.periodo
                          || chr(09)
                          || e.moneda
                          || chr(09)
                          || e.cambio
                          || chr(09)
                          || e.nrodoc
                          || chr(09)
                          || '10'
                          || e.cabecera;
            mi_texto := 'NA '; --N/A'e.CABECERA||to_char(una_fecha_final,'yyyymm');
            text_io.put_line(
               mi_archivo_sap_foncep,
               mi_szlinea
            );
         end loop;
         for r in rubros(mi_ra_type.mi_nro_ra) loop
            for d in descc(r.rubro) loop
               mi_nombrecc := d.nombrecc;
            end loop;
            mi_nro_ra := mi_ra_type.mi_nro_ra;
            mi_pago_rubro := fn_pago_rubrosap(
               r.rubro,
               una_fecha_final,
               mi_ra_type.mi_nro_ra,
               un_tipo_nomina,
               un_grupo_ra,
               un_tipo_ra
            );
            mi_cuentarub := fn_cuenta_rubrosap(r.rubro);
            mi_codigo := 31;
            mi_basertfte := ' ';
            mi_retefuente := ' ';
    
      /* for p in pagorubronxp (r.rubro,mi_nro_ra) loop
              mi_szLinea2 :=r.rubro||' Detalle=' ||mi_nombrecc;          
                 Text_IO.Put_Line( mi_archivo_sap, mi_szLinea2 );
      end loop;  */
            pr_debug_registra(
               mi_file_debug_handle,
               '746 Inicia cur_anexos'
            );
            open cur_anexos(r.rubro);
            loop
               fetch cur_anexos into
                  mi_cc,
                  mi_descripcion_cc,
                  mi_archivo_plano,
                  mi_tabla_detalle;
               exit when cur_anexos%notfound;
        --FTV PRUEBA 202405 linea para mostrar en caso de error.
       /* mi_linea_ejecutada := 'FETCH cur_anexos mi_cc||mi_archivo_plano||mi_tabla_detalle :' ||
                              mi_cc || '|' || mi_archivo_plano || '|' ||
                              mi_tabla_detalle;*/
               pr_debug_registra(
                  mi_file_debug_handle,
                  '756 Inicia cur_anexos'
               );
               if r.rubro in ( 9,
                               2,
                               3,
                               4,
                               5,
                               10,
                               11,
                               13,
                               14,
                               15,
                               18,
                               19,
                               20,
                               21 ) then
                  if r.rubro in ( 13 /*FTV20211205 ,21*/ ) then
                     mi_viapago := 'C';
                  else
                     mi_viapago := 'M';
                  end if;
               else
                  mi_viapago := ' ';
               end if;

               if upper(mi_descripcion_cc) like '%NOMINA%' then
                  begin
                     open cur_nxp(
                        mi_ra_type.mi_nro_ra,
                        r.rubro
                     );
                     loop
                        fetch cur_nxp into
                           mi_funcionario,
                           mi_valor,
                           mi_banco;
                        exit when cur_nxp%notfound;
              --FTV PRUEBA 202405 linea para mostrar en caso de error.
                        mi_linea_ejecutada := 'FETCH cur_nxp INTO mi_funcionario mi_funcionario||mi_valor||mi_banco:'
                                              || mi_funcionario
                                              || '|'
                                              || mi_valor
                                              || '|'
                                              || mi_banco;
                        pr_debug_registra(
                           mi_file_debug_handle,
                           '773 ' || mi_linea_ejecutada
                        );
                        mi_persona_type := pk_detalle_anexos_ra.fn_detalle_personas(
                           mi_funcionario,
                           mi_err
                        );
                        if mi_err = 1 then
                           pr_despliega_mensaje(
                              'AL_STOP_1',
                              'Ocurrió un error al recuperar información de personas :' || mi_funcionario
                           );
                           raise form_trigger_failure;
                        end if;
                        mi_funcionario_type := pk_detalle_anexos_ra.fn_detalle_funcionario(
                           mi_funcionario,
                           mi_err
                        );
                        if mi_err = 1 then
                           pr_despliega_mensaje(
                              'AL_STOP_1',
                              'Ocurrió un error al recuperar información de funcionarios :' || mi_funcionario
                           );
                           raise form_trigger_failure;
                        end if;
                        if mi_funcionario_type.mi_forma_pago is null then
                           pr_despliega_mensaje(
                              'AL_STOP_1',
                              'No se ha registrado la forma de pago para el funcionario ' || mi_funcionario
                           );
                           raise form_trigger_failure;
                        end if;

                        mi_codigo := 31;
                        mi_cuentareg := mi_cuentareg + 1;
              -- 20200914  adicionar por cambio en plantilla de SHD

                        for j in retefteperiodo(mi_ra_type.mi_nro_ra) loop
                           begin
                              mi_basertfte := j.base;
                              mi_retefuente := j.retencion;
                              mi_asignacion := j.asignacion;
                              mi_var90rete := 90;
                           exception
                              when others then
                                 mi_basertfte := ' ';
                                 mi_retefuente := ' ';
                                 mi_asignacion := ' ';
                           end;
                        end loop;
            
              -- 20200914  para registro 50se quita debe controlarse adicionarse solo en el primer registro de Nomina por pagar

                        mi_codigo := 31;
                        if mi_cuentareg > 1 then
                           mi_basertfte := ' ';
                           mi_retefuente := ' ';
                           mi_asignacion := '';
                           mi_var90rete := ' ';
                        else
                -- Ajuste solicitado Secretaria de Hacienda 20201203- abono retencion en la fuente a funcionarios
                           mi_valor := mi_valor;
                --mi_valor:=mi_valor+nvl(mi_retefuente,0);
                        end if;

                        if un_tipo_ra = '1' then
                           if mi_funcionario_type.mi_tipo_cuenta like '%A%' then
                              mi_tipo_cuentafun := '02';
                           elsif mi_funcionario_type.mi_tipo_cuenta like '%C%' then
                              mi_tipo_cuentafun := '01';
                           else
                              mi_tipo_cuentafun := '  ';
                           end if;
              
                -- obtner ach sap
                           for b in codach(mi_banco) loop
                              mi_codbanco := b.codigo_ach;
                           end loop;
              
                --INI PRUEBA FTV20240619
                           if mi_persona_type.mi_nro_doc = 3102899 then
                              message('Puedes ubicar un breakpoint aqui');
                           end if;
              
                --FIN FTV20240619
                --lineas funcionarios              
                           mi_szlinea := 'P'
                                         || chr(09)
                                         || mi_codigo
                                         || chr(09)
                                         || chr(09)
                                         || rpad(
                              mi_persona_type.mi_tipo_doc,
                              2,
                              ' '
                           )
                                         || chr(09)
                                         || rpad(
                              mi_persona_type.mi_nro_doc,
                              12,
                              ' '
                           )
                                         || chr(09)
                                         || chr(09)
                                         || mi_cuentarub
                                         || chr(09)
                                         || mi_valor;
                           mi_szlinea := mi_szlinea
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || chr(09);
                           mi_szlinea := mi_szlinea
                                         || chr(09)
                                         || mi_condicion_pago
                                         || chr(09)
                                         || mi_texto
                                         || chr(09)
                                         || mi_texto_nomina_mes
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || mi_viapago
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || lpad(
                              mi_codbanco,
                              3,
                              0
                           )
                                         || chr(09)
                                         || rpad(
                              mi_funcionario_type.mi_numero_cuenta,
                              20,
                              ' '
                           )
                                         || chr(09)
                                         || rpad(
                              mi_tipo_cuentafun,
                              2,
                              ' '
                           );
                --20200914 mi_szLinea :=mi_szLinea||chr(09)||'  '||chr(09)||mi_basertfte||chr(09)||chr(09)||chr(09)||chr(09);          
                           mi_szlinea := mi_szlinea
                                         || chr(09)
                                         || '  '
                                         || mi_var90rete
                                         || chr(09)
                                         || mi_var90rete
                                         || chr(09)
                                         || mi_asignacion
                                         || chr(09)
                                         || mi_retefuente
                                         || chr(09);
                           text_io.put_line(
                              mi_archivo_sap,
                              mi_szlinea
                           );
                        else
                           mi_basertfte := ' ';
                           mi_retefuente := ' ';
                           if mi_funcionario_type.mi_tipo_cuenta like '%A%' then
                              mi_tipo_cuentafun := '02';
                           elsif mi_funcionario_type.mi_tipo_cuenta like '%C%' then
                              mi_tipo_cuentafun := '01';
                           else
                              mi_tipo_cuentafun := '  ';
                           end if;
              
                -- obtner ach sap
                           for b in codach(mi_banco) loop
                              mi_codbanco := b.codigo_ach;
                           end loop;
                           mi_szlinea := 'P'
                                         || chr(09)
                                         || mi_codigo
                                         || chr(09)
                                         || chr(09)
                                         || rpad(
                              mi_persona_type.mi_tipo_doc,
                              2,
                              ' '
                           )
                                         || chr(09)
                                         || rpad(
                              mi_persona_type.mi_nro_doc,
                              12,
                              ' '
                           )
                                         || chr(09)
                                         || chr(09)
                                         || mi_cuentarub
                                         || chr(09)
                                         || mi_valor;
                           mi_szlinea := mi_szlinea
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || chr(09);
                           mi_szlinea := mi_szlinea
                                         || chr(09)
                                         || mi_condicion_pago
                                         || chr(09)
                                         || mi_texto
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || mi_viapago
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || lpad(
                              mi_codbanco,
                              3,
                              0
                           )
                                         || chr(09)
                                         || rpad(
                              mi_funcionario_type.mi_numero_cuenta,
                              20,
                              ' '
                           )
                                         || chr(09)
                                         || rpad(
                              mi_tipo_cuentafun,
                              2,
                              ' '
                           );
                           mi_szlinea := mi_szlinea
                                         || chr(09)
                                         || '  '
                                         || chr(09)
                                         || mi_basertfte
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || chr(09);
                           text_io.put_line(
                              mi_archivo_sap,
                              mi_szlinea
                           );
                        end if;
                        if mi_valor < 0 then
                           text_io.put_line(
                              mi_id_error,
                              'Funcionario con pago negativo.  Cá©dula: '
                              || mi_persona_type.mi_nro_doc
                              || '. Valor: '
                              || mi_valor
                           );
                           text_io.put_line(
                              mi_id_error,
                              'en la Relación de autorización ' || mi_ra_type.mi_nro_ra
                           );
                           mi_terceros_neg := mi_terceros_neg + 1;
                        end if;
              -- Fargelm 20120719, Requeimiento 05
                     end loop;

                     close cur_nxp;
                     pr_debug_registra(
                        mi_file_debug_handle,
                        '916 CLOSE cur_nxp'
                     );
                     if
                        mi_cc in ( 16 )
                        and un_tipo_ra = '2'
                     then
              /* fna */

                        mi_archivo_plano2 := una_compania
                                             || '_'
                                             || mi_vigencia
                                             || '_'
                                             || mi_mes
                                             || '_'
                                             || mi_ra_type.mi_nro_ra
                                             || 'FNA';
                        if get_application_property(operating_system) like '%WIN%' then
                           mi_archivo_path := text_io.fopen(
                              mi_www_path
                              || '\'
                              || mi_archivo_plano2,
                              'w'
                           );
                        else
                           mi_archivo_path := text_io.fopen(
                              mi_www_path
                              || '/'
                              || mi_archivo_plano2,
                              'w'
                           );
                        end if;
            
              --  message('FNA');
                        open cur_fna(mi_nro_ra);
                        loop
                           fetch cur_fna into
                              mi_total_fna,
                              mi_tiponit_ces,
                              mi_nit_ces,
                              forma_pagoces;
                           exit when cur_fna%notfound;
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
                              mi_nombre_entidad := substr(
                                 e.nomentidad,
                                 1,
                                 50
                              );
                           end loop;

                           mi_szlinea := 'P'
                                         || chr(09)
                                         || mi_codigo
                                         || chr(09)
                                         || chr(09)
                                         || rpad(
                              mi_tiponit_ces,
                              3,
                              ' '
                           )
                                         || chr(09)
                                         || rpad(
                              mi_nit_ces,
                              12,
                              ' '
                           )
                                         || chr(09)
                                         || chr(09)
                                         || mi_cuentarub
                                         || chr(09)
                                         || mi_valor;
                           mi_szlinea := mi_szlinea
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || chr(09);
                           mi_szlinea := mi_szlinea
                                         || chr(09)
                                         || mi_condicion_pago
                                         || chr(09)
                                         || mi_texto
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || mi_viapago
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || mi_codbanco
                                         || chr(09)
                                         || rpad(
                              mi_funcionario_type.mi_numero_cuenta,
                              20,
                              ' '
                           )
                                         || chr(09)
                                         || rpad(
                              mi_tipo_cuentafun,
                              2,
                              ' '
                           );
                           mi_szlinea := mi_szlinea
                                         || chr(09)
                                         || '  '
                                         || chr(09)
                                         || mi_basertfte
                                         || chr(09)
                                         || chr(09)
                                         || chr(09)
                                         || chr(09);

                           text_io.put_line(
                              mi_archivo_path,
                              mi_szlinea
                           );
                        end loop;

                        close cur_fna;
                        text_io.put_line(
                           mi_archivo_path,
                           'linea fin'
                        );
                        text_io.fclose(mi_archivo_path);
                        web.show_document(
                           mi_pathweb_ra || mi_archivo_plano2,
                           '_blank'
                        );
                     end if;
                  exception
                     when others then
                        if sqlcode = -302000 then
                           pr_despliega_mensaje(
                              'AL_STOP_1',
                              'Ocurrio un error intentando escribir el archivo ' || mi_archivo_plano2
                           );
                        else
                           pr_despliega_mensaje(
                              'AL_STOP_1',
                              'Ocurrió el error: ' || to_char(sqlcode)
                           );
                        end if;

                        raise form_trigger_failure;
                  end; --Anexo Neto de nómina

               elsif
                  upper(mi_descripcion_cc) like '%EMBARGO%'
                  and mi_cc = 6 /*FTv*/
               then
                  begin
            --FTV PRUEBA 202405 linea para mostrar en caso de error.
                     mi_linea_ejecutada := 'mi_archivo_planoemb operating_system||mi_descripcion_cc '
                                           || get_application_property(operating_system)
                                           || mi_descripcion_cc;
                     mi_archivo_planoemb := una_compania
                                            || '_'
                                            || mi_vigencia
                                            || '_'
                                            || mi_mes
                                            || '_'
                                            || to_char(
                        sysdate,
                        'yyyymmddhhmiss'
                     )
                                            || '_'
                                            || mi_ra_type.mi_nro_ra
                                            || '_'
                                            || 'Embargos.txt';
                     if get_application_property(operating_system) like '%WIN%' then
                        mi_archivo_path := text_io.fopen(
                           mi_www_path
                           || '\'
                           || mi_archivo_planoemb,
                           'w'
                        );
                     else
                        mi_archivo_path := text_io.fopen(
                           mi_www_path
                           || '/'
                           || mi_archivo_planoemb,
                           'w'
                        );
                     end if;
                     open cur_embargos(
                        mi_cc,
                        mi_ra_type.mi_nro_ra
                     );
                     loop
                        fetch cur_embargos into
                           mi_tercero,
                           mi_funcionario,
                           mi_sdescuento,
                           mi_nbeneficiario,
                           mi_codbeneficiario,
                           mi_fpagobeneficiario,
                           mi_concepto,
                           mi_valor,
                           mi_conceptoemb;
                        exit when cur_embargos%notfound;
                        mi_embargo_type := pk_detalle_anexos_ra.fn_detalle_embargos(
                           mi_tercero,
                           mi_funcionario,
                           mi_sdescuento,
                           mi_err
                        );
                        if mi_err = 1 then
                           pr_despliega_mensaje(
                              'AL_STOP_1',
                              'Ocurrió un error al recuperar información de os para el funcionario ' || mi_funcionario
                           );
                           raise form_trigger_failure;
                        end if;
                        if mi_embargo_type.mi_tipo_doc_benef_pago is null
                        or mi_embargo_type.mi_nro_doc_benef_pago is null then
                           pr_despliega_mensaje(
                              'AL_STOP_1',
                              'No se encuentra registrado el beneficiario del pago para el o del funcionario ' || mi_funcionario
                           );
                           raise form_trigger_failure;
                        end if;
                        if mi_embargo_type.mi_forma_pago is null then
                           pr_despliega_mensaje(
                              'AL_STOP_1',
                              'No se encuentra registrada la forma de pago para el o del funcionario ' || mi_funcionario
                           );
                           raise form_trigger_failure;
                        end if;
                        mi_demandante_type := pk_detalle_anexos_ra.fn_detalle_demandante(
                           mi_tercero,
                           mi_funcionario,
                           mi_sdescuento,
                           mi_err
                        );
                        mi_demandantes_type := pk_detalle_anexos_ra.fn_detalle_demandantes(
                           mi_tercero,
                           mi_funcionario,
                           mi_sdescuento,
                           mi_err
                        );
                        if mi_err = 1 then
                           pr_despliega_mensaje(
                              'AL_STOP_1',
                              'Ocurrió un error al recuperar información del demandante para el o para el funcionario ' || mi_funcionario
                           );
                           raise form_trigger_failure;
                        end if;
                        if mi_demandante_type.mi_nombre_ddte is null then
                           pr_despliega_mensaje(
                              'AL_STOP_1',
                              'No se encuentra registrado el nombre del demandante para el o del funcionario ' || mi_funcionario
                           );
                           raise form_trigger_failure;
                        end if;
                        mi_persona_type := pk_detalle_anexos_ra.fn_detalle_personas(
                           mi_funcionario,
                           mi_err
                        );
                        if mi_err = 1 then
                           pr_despliega_mensaje(
                              'AL_STOP_1',
                              'Ocurrió un error al recuperar información de personas: ' || mi_funcionario
                           );
                           raise form_trigger_failure;
                        end if;
              -- RQ1849-2006    17/11/2006

                        mi_beneficiario_type := pk_detalle_anexos_ra.fn_detalle_beneficiarios(
                           to_number(mi_tercero),
                           mi_err
                        );
                        if mi_err = 1 then
                           pr_despliega_mensaje(
                              'AL_STOP_1',
                              'Eg1: Ocurrió un error al recuperar información de beneficiarios ' || mi_tercero
                           );
                           raise form_trigger_failure;
                        end if;
              -- Fin RQ1849-2006
            
              -- DOMINIOS DE BOGADATA
                        if mi_demandante_type.mi_tipo_doc_ddte = 'CC' then
                           mi_demandante_type.mi_tipo_doc_ddte := 1;
                        elsif mi_demandante_type.mi_tipo_doc_ddte = 'NIT' then
                           mi_demandante_type.mi_tipo_doc_ddte := 3;
                        elsif mi_demandante_type.mi_tipo_doc_ddte = 'CE' then
                           mi_demandante_type.mi_tipo_doc_ddte := 2;
                        elsif mi_demandante_type.mi_tipo_doc_ddte = 'PA' then
                           mi_demandante_type.mi_tipo_doc_ddte := 4;
                        elsif mi_demandante_type.mi_tipo_doc_ddte = 'TI' then
                           mi_demandante_type.mi_tipo_doc_ddte := 5;
                        end if;
              /*IF mi_embargo_type.mi_concepto='EJECUTIVO' then
                mi_embargo_type.mi_concepto:=1;
              ELSIF mi_embargo_type.mi_concepto='POR ALIMENTOS' then
                mi_embargo_type.mi_concepto:=6;
              ELSIF mi_embargo_type.mi_concepto='CIVIL' then  
                mi_embargo_type.mi_concepto:=2;
              ELSIF mi_embargo_type.mi_concepto='COACTIVO' then  
                mi_embargo_type.mi_concepto:=2;
              end if;*/
                        if mi_conceptoemb = 'EJECUTIVO' then
                           mi_concepto := 1;
                        elsif mi_conceptoemb = 'POR ALIMENTOS' then
                           mi_concepto := 6;
                        elsif mi_conceptoemb = 'CIVIL' then
                           mi_concepto := 2;
                        elsif mi_conceptoemb = 'COACTIVO' then
                           mi_concepto := 2;
                        end if;

                        if mi_demandantes_type.mi_ban_destino is null then
                           mi_ofi_destino := '0010';
                        else
                           mi_ofi_destino := mi_demandantes_type.mi_ban_destino;
                        end if;

                        if mi_demandantes_type.mi_ban_origen is null then
                           mi_ofi_origen := '0030';
                        else
                           mi_ofi_origen := mi_demandantes_type.mi_ban_origen;
                        end if;

                        mi_szlinea := una_compania || chr(09); -- segmento A
                        mi_szlinea := mi_szlinea
                                      || rpad(
                           abs(mi_valor),
                           10,
                           ' '
                        )
                                      || chr(09); -- valor del o  B
                        mi_szlinea := mi_szlinea
                                      || mi_demandantes_type.mi_cod_juzgado
                                      || chr(09); -- codigo del juzgado C
                        mi_szlinea := mi_szlinea
                                      || rpad(
                           mi_ofi_destino,
                           4,
                           ' '
                        )
                                      || chr(09); --codigo_oficina destino D            
                        mi_szlinea := mi_szlinea
                                      || rpad(
                           mi_ofi_origen,
                           4,
                           ' '
                        )
                                      || chr(09); -- codigo oficina del banco agrario E
              --mi_szLinea :=mi_szLinea||rpad( nvl(mi_embargo_type.mi_numero_cuenta,''),30,' ')||chr(09);-- numerp de cuenta F
                        mi_szlinea := mi_szlinea
                                      || rpad(
                           nvl(
                              0,
                              ''
                           ),
                           10,
                           ' '
                        )
                                      || chr(09);
                        mi_szlinea := mi_szlinea
                                      || substr(
                           mi_demandantes_type.mi_proceso,
                           13,
                           12
                        )
                                      || chr(09);
              --mi_szLinea :=mi_szLinea||rpad(mi_beneficiario_type.mi_nro_doc ,15,' ')||chr(09);-- numero de oficio del o G mi_o_type.mi_nro_oficio
                        mi_szlinea := mi_szlinea
                                      || rpad(
                           1,
                           10,
                           ' '
                        )
                                      || chr(09); -- >OJO
                        mi_szlinea := mi_szlinea
                                      || rpad(
                           mi_persona_type.mi_nro_doc,
                           20,
                           ' '
                        )
                                      || chr(09); -- benficiario documento I
              --mi_szLinea :=mi_szLinea||mi_persona_type.mi_primer_apellido||' '||mi_persona_type.mi_segundo_apellido||chr(09);-- apellidos demandado J
              --mi_szLinea :=mi_szLinea||rpad(mi_persona_type.mi_nombre,40,' ')||chr(09);-- nombre demandado K
                        mi_szlinea := mi_szlinea
                                      || rpad(
                           (mi_persona_type.mi_primer_apellido
                            || ' '
                            || mi_persona_type.mi_segundo_apellido
                            || mi_persona_type.mi_nombre),
                           80,
                           ' '
                        )
                                      || chr(09);
                        mi_szlinea := mi_szlinea
                                      || rpad(
                           mi_demandante_type.mi_tipo_doc_ddte,
                           20,
                           ' '
                        )
                                      || chr(09); -- tipo documento L
                        mi_szlinea := mi_szlinea
                                      || rpad(
                           mi_demandante_type.mi_nro_doc_ddte,
                           20,
                           ' '
                        )
                                      || chr(09); -- Numero documento M
                        mi_szlinea := mi_szlinea
                                      || rpad(
                           mi_concepto,
                           30,
                           ' '
                        )
                                      || chr(09); -- concepto demandante N
                        if mi_demandantes_type.mi_apellidos_ddte = ' ' then
                           mi_szlinea := mi_szlinea
                                         || rpad(
                              mi_demandantes_type.mi_nombre_ddte,
                              30,
                              ' '
                           )
                                         || chr(09); -- apellidos demandante O
                        else
                           mi_szlinea := mi_szlinea
                                         || rpad(
                              mi_demandantes_type.mi_apellidos_ddte,
                              30,
                              ' '
                           )
                                         || chr(09); -- apellidos demandante O
                        end if;
                        mi_szlinea := mi_szlinea
                                      || rpad(
                           mi_demandantes_type.mi_nombre_ddte,
                           40,
                           ' '
                        )
                                      || chr(09); -- Nombre  demandante P
              -- mi_szLinea :=mi_szLinea||mi_embargo_type.mi_concepto||chr(09);  -- numero expediente Q
                        mi_szlinea := mi_szlinea
                                      || mi_demandantes_type.mi_proceso
                                      || chr(09); -- numero expediente Q
                        mi_szlinea := mi_szlinea
                                      || rpad(
                           :b_ra.cta_x_nomina,
                           10,
                           ' '
                        )
                                      || chr(09);
                        text_io.put_line(
                           mi_archivo_path,
                           mi_szlinea
                        );
              /* adicionar lineas banco agrario 20201021 */
                        mi_szlinea := 'P'
                                      || chr(09)
                                      || mi_codigo
                                      || chr(09)
                                      || chr(09)
                                      || 'NIT'
                                      || chr(09)
                                      || rpad(
                           '1000466363',
                           12,
                           ' '
                        )
                                      || chr(09)
                                      || --rpad(mi_nit_agrario, 12, ' ') || chr(09) ||   --2025003170  
                                       chr(09)
                                      || mi_cuentarub
                                      || chr(09)
                                      || abs(mi_valor);
                        mi_szlinea := mi_szlinea
                                      || chr(09)
                                      || chr(09)
                                      || chr(09)
                                      || chr(09)
                                      || chr(09)
                                      || chr(09)
                                      || chr(09)
                                      || chr(09)
                                      || chr(09)
                                      || chr(09)
                                      || chr(09)
                                      || chr(09)
                                      || chr(09)
                                      || chr(09)
                                      || chr(09);
                        mi_szlinea := mi_szlinea
                                      || chr(09)
                                      || mi_condicion_pago
                                      || chr(09)
                                      || mi_texto
                                      || chr(09)
                                      || chr(09)
                                      || chr(09)
                                      || chr(09)
                                      || chr(09)
                                      || chr(09)
                                      || 'B'
                                      || chr(09)
                                      || chr(09)
                                      || chr(09)
                                      || chr(09)
                                      || chr(09)
                                      || chr(09)
                                      || chr(09)
                                      || chr(09)
                                      || chr(09)
                                      || chr(09)
                                      || chr(09);
                        mi_szlinea := mi_szlinea
                                      || chr(09)
                                      || chr(09)
                                      || chr(09)
                                      || chr(09)
                                      || chr(09)
                                      || chr(09)
                                      || chr(09)
                                      || chr(09);
              --Text_IO.Put_Line( mi_archivo_planoemb, mi_szLinea ); 
                        text_io.put_line(
                           mi_archivo_sap,
                           mi_szlinea
                        );
                     end loop;

                     close cur_embargos;
                     text_io.fclose(mi_archivo_path);
                     web.show_document(
                        mi_pathweb_ra || mi_archivo_planoemb,
                        '_blank'
                     );
          
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
                     pr_debug_registra(
                        mi_file_debug_handle,
                        '1232 voy a  OPEN cur_embargosnba(mi_cc, mi_ra_type.mi_nro_ra)'
                     );
                     open cur_embargosnba(
                        mi_cc,
                        mi_ra_type.mi_nro_ra
                     );
                     loop
                        fetch cur_embargosnba into
                           mi_tercero,
                           mi_funcionario,
                           mi_sdescuento,
                           mi_nbeneficiario,
                           mi_fpagobeneficiario,
                           mi_codbeneficiario,
                           mi_bancoemb,
                           mi_tipo_cuenta_emb,
                           mi_numero_cuenta_emb,
                           mi_proceso,
                           mi_valor;
                        exit when cur_embargosnba%notfound;
            
              --FTV PRUEBA 202405 linea para mostrar en caso de error.
                        mi_linea_ejecutada := 'FETCH cur_embargosnba INTO mi_tercero||mi_funcionario||mi_sdescuento||mi_nbeneficiario:'
                                              || mi_tercero
                                              || '|'
                                              || mi_funcionario
                                              || '|'
                                              || mi_sdescuento
                                              || '|'
                                              || mi_nbeneficiario;

                        mi_embargo_type := pk_detalle_anexos_ra.fn_detalle_embargos(
                           mi_tercero,
                           mi_funcionario,
                           mi_sdescuento,
                           mi_err
                        );
                        if mi_err = 1 then
                           pr_despliega_mensaje(
                              'AL_STOP_1',
                              'Ocurrió un error al recuperar información de os para el funcionario ' || mi_funcionario
                           );
                           raise form_trigger_failure;
                        end if;
                        if mi_embargo_type.mi_tipo_doc_benef_pago is null
                        or mi_embargo_type.mi_nro_doc_benef_pago is null then
                           pr_despliega_mensaje(
                              'AL_STOP_1',
                              'No se encuentra registrado el beneficiario del pago para el o del funcionario ' || mi_funcionario
                           );
                           raise form_trigger_failure;
                        end if;
                        if mi_embargo_type.mi_forma_pago is null then
                           pr_despliega_mensaje(
                              'AL_STOP_1',
                              'No se encuentra registrada la forma de pago para el o del funcionario ' || mi_funcionario
                           );
                           raise form_trigger_failure;
                        end if;
                        mi_demandante_type := pk_detalle_anexos_ra.fn_detalle_demandante(
                           mi_tercero,
                           mi_funcionario,
                           mi_sdescuento,
                           mi_err
                        );
                        mi_demandantes_type := pk_detalle_anexos_ra.fn_detalle_demandantes(
                           mi_tercero,
                           mi_funcionario,
                           mi_sdescuento,
                           mi_err
                        );
                        if mi_err = 1 then
                           pr_despliega_mensaje(
                              'AL_STOP_1',
                              'Ocurrió un error al recuperar información del demandante para el o para el funcionario ' || mi_funcionario
                           );
                           raise form_trigger_failure;
                        end if;
                        if mi_demandante_type.mi_nombre_ddte is null then
                           pr_despliega_mensaje(
                              'AL_STOP_1',
                              'No se encuentra registrado el nombre del demandante para el o del funcionario ' || mi_funcionario
                           );
                           raise form_trigger_failure;
                        end if;
                        mi_persona_type := pk_detalle_anexos_ra.fn_detalle_personas(
                           mi_funcionario,
                           mi_err
                        );
                        if mi_err = 1 then
                           pr_despliega_mensaje(
                              'AL_STOP_1',
                              'Ocurrió un error al recuperar información de personas: ' || mi_funcionario
                           );
                           raise form_trigger_failure;
                        end if;
              -- RQ1849-2006    17/11/2006

                        mi_beneficiario_type := pk_detalle_anexos_ra.fn_detalle_beneficiarios(
                           to_number(mi_tercero),
                           mi_err
                        );
                        if mi_err = 1 then
                           pr_despliega_mensaje(
                              'AL_STOP_1',
                              'Eg2: Ocurrió un error al recuperar información de beneficiarios ' || mi_tercero
                           );
                           raise form_trigger_failure;
                        end if;
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
                        if mi_embargo_type.mi_concepto = 'EJECUTIVO' then
                           mi_embargo_type.mi_concepto := 1;
                        elsif mi_embargo_type.mi_concepto = 'POR ALIMENTOS' then
                           mi_embargo_type.mi_concepto := 6;
                        elsif mi_embargo_type.mi_concepto = 'CIVIL' then
                           mi_embargo_type.mi_concepto := 2;
                        elsif mi_embargo_type.mi_concepto = 'COACTIVO' then
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
                        mi_szlinea := 'P'
                                      || chr(09)
                                      || mi_codigo
                                      || chr(09)
                                      || chr(09)
                                      || rpad(
                           mi_demandante_type.mi_tipo_doc_ddte,
                           2,
                           ' '
                        )
                                      || chr(09)
                                      || rpad(
                           mi_demandante_type.mi_nro_doc_ddte,
                           12,
                           ' '
                        )
                                      || chr(09)
                                      || chr(09)
                                      || mi_cuentarub
                                      || chr(09)
                                      || abs(mi_valor);
                        mi_szlinea := mi_szlinea
                                      || chr(09)
                                      || chr(09)
                                      || chr(09)
                                      || chr(09)
                                      || chr(09)
                                      || chr(09)
                                      || chr(09)
                                      || chr(09)
                                      || chr(09)
                                      || chr(09)
                                      || chr(09)
                                      || chr(09)
                                      || chr(09)
                                      || chr(09)
                                      || chr(09);
                        mi_szlinea := mi_szlinea
                                      || chr(09)
                                      || mi_condicion_pago
                                      || chr(09)
                                      || mi_texto
                                      || chr(09)
                                      || chr(09)
                                      || chr(09)
                                      || chr(09)
                                      || chr(09)
                                      || chr(09)
                                      || mi_viapago
                                      || chr(09)
                                      || chr(09)
                                      || chr(09)
                                      || chr(09)
                                      || chr(09)
                                      || chr(09)
                                      || lpad(
                           mi_bancoemb,
                           3,
                           0
                        )
                                      || chr(09)
                                      || rpad(
                           mi_numero_cuenta_emb,
                           20,
                           ' '
                        )
                                      || chr(09)
                                      || rpad(
                           mi_tipo_cuenta_emb,
                           2,
                           ' '
                        );
                        mi_szlinea := mi_szlinea
                                      || chr(09)
                                      || '  '
                                      || chr(09)
                                      || mi_basertfte
                                      || chr(09)
                                      || chr(09)
                                      || chr(09)
                                      || chr(09);
              --Text_IO.Put_Line( mi_archivo_planoemb, mi_szLinea ); 
                        text_io.put_line(
                           mi_archivo_sap,
                           mi_szlinea
                        );
                     end loop;

                     close cur_embargosnba;
                     text_io.put_line(
                        mi_archivo_path,
                        'linea fin'
                     );
                     text_io.fclose(mi_archivo_path);
                     web.show_document(
                        mi_pathweb_ra
                        || '/'
                        || mi_archivo_planoemb,
                        '_blank'
                     );
                  exception
                     when others then
                        if sqlcode = -302000 then
                           pr_despliega_mensaje(
                              'AL_STOP_1',
                              'Ocurrio un error intentando escribir el archivo ' || mi_archivo_planoemb
                           );
                        else
                           pr_despliega_mensaje(
                              'AL_STOP_1',
                              'Ocurrió el error: ' || to_char(sqlcode)
                           );
                        end if;
                        if text_io.is_open(mi_archivo_path) then
                           text_io.fclose(mi_archivo_path);
                        end if;
                        raise form_trigger_failure;
                  end; --Anexo Embargos
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
               else
                  begin
            /*if r.rubro in(9,2,3,4,5,10,11,12,13,14,15,19,20,21) then
              mi_viapago:='M';
               
            else
               mi_viapago:=' ';
              end if;*/
                     mi_viapago := ' ';
                     mi_cursor := exec_sql.open_cursor(exec_sql.default_connection);
            -- Se construye la sentencia de la consulta
                     mi_consulta := 'SELECT  ';
                     if mi_tabla_detalle like '%NOMBRE%'
                     or mi_tabla_detalle = 'ENTIDAD_BENEFICIARIOS' then
                        mi_consulta := mi_consulta || 'a.sconcepto, ';
                     end if;
                     mi_consulta := mi_consulta
                                    || ' a.stercero, SUM(valor) valor, SUM(valor_saldo) valor_saldo '
                                    || 'FROM     rh_t_lm_valores a, rh_lm_cuenta b, rh_lm_centros_costo c '
                                    || 'WHERE    b.stipo_funcionario =  a.stipofuncionario '
                                    || 'AND      b.sconcepto         =  a.sconcepto '
                                    || 'AND      b.cc                =  c.codigo '
                                    || 'AND      a.periodo           =  TO_DATE('''
                                    || to_char(
                        una_fecha_final,
                        'DD-MM-YYYY HH:MI:SS AM'
                     )
                                    || ''',''DD-MM-YYYY HH:MI:SS AM'') '
                                    || 'AND     a.ntipo_nomina      =  '
                                    || un_tipo_nomina
                                    || ' AND  a.sdevengado ';
                     if un_tipo_ra = '1' then
              --mi_consulta:=mi_consulta || 'IN (0,1) ';
                        mi_consulta := mi_consulta || 'IN (0,1)  AND      c.codigo    not  IN (2,3,4) ';
                     else
                        mi_consulta := mi_consulta || 'NOT IN (0,1) ';
                     end if;
                     mi_consulta := mi_consulta
                                    || ' AND a.nro_ra    = '
                                    || mi_ra_type.mi_nro_ra
                                    || ' AND b.scompania =  '
                                    || chr(39)
                                    || una_compania
                                    || chr(39)
                                    || ' AND b.tipo_ra   =  '
                                    || chr(39)
                                    || un_tipo_ra
                                    || chr(39)
                                    || ' AND b.grupo_ra IN ('
                                    || chr(39)
                                    || un_grupo_ra
                                    || chr(39)
                                    || ') AND  b.ncierre =  1 '
                                    || 
                          -- RQ2523-2005   05/12/2005
                                     ' AND b.dfecha_inicio_vig <= TO_DATE('''
                                    || to_char(
                        una_fecha_final,
                        'DD-MM-YYYY HH:MI:SS AM'
                     )
                                    || ''',''DD-MM-YYYY HH:MI:SS AM'') '
                                    || ' AND (b.dfecha_final_vig  >= TO_DATE('''
                                    || to_char(
                        una_fecha_final,
                        'DD-MM-YYYY HH:MI:SS AM'
                     )
                                    || ''',''DD-MM-YYYY HH:MI:SS AM'') OR b.dfecha_final_vig IS NULL) '
                                    ||
                          -- Fin RQ2523  
                                     ' AND      b.cc =  '
                                    || mi_cc;
                     if ( mi_tabla_detalle like '%NOMBRE%'
                     or mi_tabla_detalle = 'ENTIDAD_BENEFICIARIOS' ) then
                        mi_consulta := mi_consulta || ' GROUP BY a.sconcepto, a.stercero';
                     else
                        mi_consulta := mi_consulta || ' GROUP BY a.stercero';
                     end if;
            --pr_muestra_varios_debug('La Consulta '||mi_consulta);
                     pr_debug_registra(
                        mi_file_debug_handle,
                        mi_consulta
                     );
            -- Text_IO.Put_Line( mi_archivo_sap, mi_consulta );
            -- Se construye diná¡micamente el cursor
            --FTV PRUEBA 202405 linea para mostrar en caso de error.
                     mi_linea_ejecutada := 'EXEC_SQL.PARSE mi_consulta '
                                           || substr(
                        mi_consulta,
                        1,
                        50
                     );
                     pr_debug_registra(
                        mi_file_debug_handle,
                        '1596 EXEC_SQL.parse ' || mi_consulta
                     );
                     pr_debug_registra(
                        mi_file_debug_handle,
                        '1597 mi_tabla_detalle ' || mi_tabla_detalle
                     );
                     exec_sql.parse(
                        exec_sql.default_connection,
                        mi_cursor,
                        mi_consulta,
                        exec_sql.v7
                     );
            -- Se definen las columnas en donde se almacenaran los resultados
                     if ( mi_tabla_detalle like '%NOMBRE%'
                     or mi_tabla_detalle = 'ENTIDAD_BENEFICIARIOS' ) then
                        exec_sql.define_column(
                           exec_sql.default_connection,
                           mi_cursor,
                           1,
                           mi_concepto,
                           30
                        );
                        exec_sql.define_column(
                           exec_sql.default_connection,
                           mi_cursor,
                           2,
                           mi_tercero,
                           30
                        );
                        exec_sql.define_column(
                           exec_sql.default_connection,
                           mi_cursor,
                           3,
                           mi_valor
                        );
                        exec_sql.define_column(
                           exec_sql.default_connection,
                           mi_cursor,
                           4,
                           mi_valor_saldo
                        );
                     else
                        exec_sql.define_column(
                           exec_sql.default_connection,
                           mi_cursor,
                           1,
                           mi_tercero,
                           30
                        );
                        exec_sql.define_column(
                           exec_sql.default_connection,
                           mi_cursor,
                           2,
                           mi_valor
                        );
                        exec_sql.define_column(
                           exec_sql.default_connection,
                           mi_cursor,
                           3,
                           mi_valor_saldo
                        );
                     end if;
                     pr_debug_registra(
                        mi_file_debug_handle,
                        '1629 EXEC_SQL.EXECUTE(EXEC_SQL.DEFAULT_CONNECTION '
                     );     
            -- Se ejecuta el cursor
                     nign := exec_sql.execute(
                        exec_sql.default_connection,
                        mi_cursor
                     );
                     while exec_sql.fetch_rows(
                        exec_sql.default_connection,
                        mi_cursor
                     ) > 0 loop
                        if ( mi_tabla_detalle like '%NOMBRE%'
                        or mi_tabla_detalle = 'ENTIDAD_BENEFICIARIOS' ) then
                           exec_sql.column_value(
                              exec_sql.default_connection,
                              mi_cursor,
                              1,
                              mi_concepto
                           );
                           exec_sql.column_value(
                              exec_sql.default_connection,
                              mi_cursor,
                              2,
                              mi_tercero
                           );
                           exec_sql.column_value(
                              exec_sql.default_connection,
                              mi_cursor,
                              3,
                              mi_valor
                           );
                           exec_sql.column_value(
                              exec_sql.default_connection,
                              mi_cursor,
                              4,
                              mi_valor_saldo
                           );
                        else
                           exec_sql.column_value(
                              exec_sql.default_connection,
                              mi_cursor,
                              1,
                              mi_tercero
                           );
                           exec_sql.column_value(
                              exec_sql.default_connection,
                              mi_cursor,
                              2,
                              mi_valor
                           );
                           exec_sql.column_value(
                              exec_sql.default_connection,
                              mi_cursor,
                              3,
                              mi_valor_saldo
                           );
                        end if;

                        if mi_tabla_detalle = 'ENTIDAD_BENEFICIARIOS' then
                --Pregunta si el concepto es descuento en la nómina por salud o fondo de garantia para tomar la información de 
                --rh_entidad o sino toma la información de rh_beneficiarios
                           mi_concepto_entidad_benef := null;
                           begin
                              select stipo_funcionario
                                into mi_concepto_entidad_benef
                                from rh_lm_det_grp_funcionario
                               where scompania = una_compania
                                 and sgtipo = 'DESCUENTO'
                                 and stipo_funcionario = mi_concepto
                                 and una_fecha_final between dfecha_inicio_vig and dfecha_final_vig
                                 and ncierre = 1;
                           exception
                              when no_data_found then
                                 mi_concepto_entidad_benef := null;
                              when others then
                                 pr_despliega_mensaje(
                                    'AL_STOP_1',
                                    'Ocurrió un error al validar si el concepto '
                                    || mi_concepto
                                    || ' se asocia a rh_entidad. '
                                    || substr(
                                       sqlerrm,
                                       1,
                                       120
                                    )
                                 );
                                 raise form_trigger_failure;
                           end;
                           if mi_concepto_entidad_benef is null then
                              mi_tabla := 'BENEFICIARIOS';
                           else
                              mi_tabla := 'ENTIDAD';
                           end if;
                           if mi_tabla = 'ENTIDAD' then
                              mi_tipo_entidad := p_bintablas.tbuscar(
                                 mi_descripcion_cc,
                                 'NOMINA',
                                 'CCOSTO_ENTIDAD',
                                 to_char(
                                                         sysdate,
                                                         'DD-MM-YYYY'
                                                      )
                              );
                              if mi_tipo_entidad is null then
                                 pr_despliega_mensaje(
                                    'AL_STOP_1',
                                    'No encontró tipo entidad para el c. costo '
                                    || mi_descripcion_cc
                                    || ' verifique CCOSTO_ENTIDAD en bintablas'
                                 );
                                 raise form_trigger_failure;
                              end if;

                              mi_entidad_type := pk_detalle_anexos_ra.fn_detalle_entidad(
                                 mi_tipo_entidad,
                                 mi_tercero,
                                 mi_err
                              );
                              if mi_err = 1 then
                                 pr_despliega_mensaje(
                                    'AL_STOP_1',
                                    'Ocurrió un error al recuperar información de entidades '
                                    || mi_tipo_entidad
                                    || ' '
                                    || mi_tercero
                                 );
                                 raise form_trigger_failure;
                              end if;
                  -- FIN RQ1718-2006
                              if mi_entidad_type.mi_forma_pago is null then
                                 pr_despliega_mensaje(
                                    'AL_STOP_1',
                                    'No se ha registrado la forma de pago para la entidad '
                                    || mi_tipo_entidad
                                    || ' '
                                    || mi_entidad_type.mi_nro_doc
                                 );
                                 raise form_trigger_failure;
                              end if;
                              if
                                 un_tipo_ra = '1'
                                 and mi_valor < 0
                              then
                                 mi_valor := mi_valor * ( -1 );
                              end if;
                              if un_tipo_ra = '1' then
                                 if mi_entidad_type.mi_tipo_cuenta = 'A' then
                                    mi_entidad_type.mi_tipo_cuenta := '02';
                                 elsif mi_entidad_type.mi_tipo_cuenta = 'C' then
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
                                    mi_nombre_entidad := substr(
                                       e.nomentidad,
                                       1,
                                       50
                                    );
                                 end loop;

                                 mi_szlinea := 'P'
                                               || chr(09)
                                               || mi_codigo
                                               || chr(09)
                                               || chr(09)
                                               || rpad(
                                    mi_entidad_type.mi_tipo_doc,
                                    3,
                                    ' '
                                 )
                                               || chr(09)
                                               || rpad(
                                    mi_entidad_type.mi_nro_doc,
                                    12,
                                    ' '
                                 )
                                               || chr(09)
                                               || chr(09)
                                               || mi_cuentarub
                                               || chr(09)
                                               || mi_valor;
                                 mi_szlinea := mi_szlinea
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09);
                                 mi_szlinea := mi_szlinea
                                               || chr(09)
                                               || mi_condicion_pago
                                               || chr(09)
                                               || mi_texto
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || mi_viapago
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || mi_codbanco
                                               || chr(09)
                                               || rpad(
                                    mi_entidad_type.mi_numero_cuenta,
                                    20,
                                    ' '
                                 )
                                               || chr(09)
                                               || rpad(
                                    mi_entidad_type.mi_tipo_cuenta,
                                    2,
                                    ' '
                                 );
                                 mi_szlinea := mi_szlinea
                                               || chr(09)
                                               || '  '
                                               || chr(09)
                                               || mi_basertfte
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09);
                                 text_io.put_line(
                                    mi_archivo_sap,
                                    mi_szlinea
                                 );
                              else
                                 mi_incapacidad := 0;
                                 mi_saldo := 0;
                                 if upper(mi_descripcion_cc) like '%SALUD%'
                                 or upper(mi_descripcion_cc) like '%ARP%' then
                                    if upper(mi_descripcion_cc) like '%SALUD%' then
                                       mi_concepto_inc := 'INCAPACIDADES_AUTOL_SALUD';
                                       mi_concepto_saldos := 'SALDOS_SALUD';
                                    else
                                       mi_concepto_inc := 'INCAPACIDADES_AUTOL_ARP';
                                       mi_concepto_saldos := 'SALDOS_ARP';
                                    end if;
                                    mi_incapacidad := pk_detalle_anexos_ra.fn_detalle_incapacidades(
                                       una_compania,
                                       mi_concepto_inc,
                                       un_tipo_nomina,
                                       mi_tercero,
                                       una_fecha_final,
                                       mi_ra_type.mi_nro_ra,
                                       un_grupo_ra,
                                       mi_err
                                    );
                                    if mi_err = 1 then
                                       pr_despliega_mensaje(
                                          'AL_STOP_1',
                                          'Ocurrió un error al recuperar información de incapacidades EPS ' || mi_tercero
                                       );
                                       raise form_trigger_failure;
                                    end if;
                                    if mi_incapacidad <> 0 then
                        --mi_valor:=mi_valor - mi_incapacidad;
                                       mi_incapacidad := mi_incapacidad * ( -1 );
                                    end if;
                                    mi_saldo := pk_detalle_anexos_ra.fn_detalle_saldos(
                                       una_compania,
                                       mi_concepto_saldos,
                                       un_tipo_nomina,
                                       mi_tercero,
                                       una_fecha_final,
                                       mi_ra_type.mi_nro_ra,
                                       un_grupo_ra,
                                       mi_err
                                    );
                                    if mi_err = 1 then
                                       pr_despliega_mensaje(
                                          'AL_STOP_1',
                                          'Ocurrió un error al recuperar información de saldos a favor o en contra de la EPS ' || mi_tercero
                                       );
                                       raise form_trigger_failure;
                                    end if;
                                    if mi_saldo <> 0 then
                        --mi_valor:=mi_valor - mi_saldo;
                                       mi_saldo := mi_saldo * ( -1 );
                                    end if;
                                 end if;

                                 if mi_entidad_type.mi_tipo_cuenta = 'A' then
                                    mi_entidad_type.mi_tipo_cuenta := '02';
                                 elsif mi_entidad_type.mi_tipo_cuenta = 'C' then
                                    mi_entidad_type.mi_tipo_cuenta := '01';
                                 else
                                    mi_entidad_type.mi_tipo_cuenta := '  ';
                                 end if;
                                 for b in codach(mi_entidad_type.mi_banco) loop
                                    mi_codbanco := b.codigo_ach;
                                 end loop;

                                 for e in nom_entidad(mi_entidad_type.mi_nro_doc) loop
                                    mi_nombre_entidad := substr(
                                       e.nomentidad,
                                       1,
                                       50
                                    );
                                 end loop;
                                 if mi_viapago = 'M' then
                                    mi_codbanco := '   ';
                                 end if;
                  
                    --20201030
                                 if r.rubro in ( 2,
                                                 3,
                                                 4,
                                                 11,
                                                 13,
                                                 14,
                                                 15,
                                                 16,
                                                 18,
                                                 21,
                                                 22,
                                                 23,
                                                 24 ) then
                                    mi_valor := mi_valor + mi_valor_saldo;
                                    if
                                       r.rubro = 13
                                       and trim(mi_codbanco) is null
                                    then
                                       mi_viapago := 'C';
                                    else
                                       mi_viapago := 'M';
                                    end if;
                                    mi_entidad_type.mi_tipo_cuenta := ' ';
                                    mi_codbanco := '   ';
                                    mi_entidad_type.mi_numero_cuenta := ' ';
                                    if r.rubro in ( 13,
                                                    18,
                                                    21 ) then
                                       mi_viapago := 'C';
                                    end if;
                                 end if;

                                 mi_szlinea := 'P'
                                               || chr(09)
                                               || mi_codigo
                                               || chr(09)
                                               || chr(09)
                                               || rpad(
                                    mi_entidad_type.mi_tipo_doc,
                                    3,
                                    ' '
                                 )
                                               || chr(09)
                                               || rpad(
                                    mi_entidad_type.mi_nro_doc,
                                    12,
                                    ' '
                                 )
                                               || chr(09)
                                               || chr(09)
                                               || mi_cuentarub
                                               || chr(09)
                                               || mi_valor;
                                 mi_szlinea := mi_szlinea
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09);
                                 mi_szlinea := mi_szlinea
                                               || chr(09)
                                               || mi_condicion_pago
                                               || chr(09)
                                               || mi_texto
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || mi_viapago
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || mi_codbanco
                                               || chr(09)
                                               || rpad(
                                    mi_entidad_type.mi_numero_cuenta,
                                    20,
                                    ' '
                                 )
                                               || chr(09)
                                               || rpad(
                                    mi_entidad_type.mi_tipo_cuenta,
                                    2,
                                    ' '
                                 );
                                 mi_szlinea := mi_szlinea
                                               || chr(09)
                                               || '  '
                                               || chr(09)
                                               || mi_basertfte
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09);
                                 text_io.put_line(
                                    mi_archivo_sap,
                                    mi_szlinea
                                 );
                    --Puede ocurrir si la incapacidad es menor que el aporte por EPS                
                                 if mi_valor < 0 then
                                    text_io.put_line(
                                       mi_id_error,
                                       'Entidad con pago negativo :'
                                       || mi_entidad_type.mi_nro_doc
                                       || '. Valor:'
                                       || mi_valor
                                    );
                                    text_io.put_line(
                                       mi_id_error,
                                       'en la Relación de autorización ' || mi_ra_type.mi_nro_ra
                                    );
                                    mi_terceros_neg := mi_terceros_neg + 1;
                                 end if;
                              end if;
                              text_io.put_line(
                                 mi_archivo_path,
                                 mi_szlinea
                              );
                           else
                  --Si la tabla detalle es beneficiarios
                              mi_beneficiario_type := pk_detalle_anexos_ra.fn_detalle_beneficiarios(
                                 to_number(mi_tercero),
                                 mi_err
                              );
                              if mi_err = 1 then
                                 pr_despliega_mensaje(
                                    'AL_STOP_1',
                                    'Sd: Ocurrió un error al recuperar información de beneficiarios ' || mi_tercero
                                 );
                                 raise form_trigger_failure;
                              end if;
                              if mi_beneficiario_type.mi_forma_pago is null then
                                 pr_despliega_mensaje(
                                    'AL_STOP_1',
                                    'No se ha registrado la forma de pago para el beneficiario ' || mi_beneficiario_type.mi_nro_doc
                                 );
                                 raise form_trigger_failure;
                              end if;
                              if mi_valor < 0 then
                                 mi_valor := mi_valor * ( -1 );
                              end if;
                              if un_tipo_ra = '1' then
                                 mi_szlinea := null;
                                 if mi_beneficiario_type.mi_tipo_cuenta = 'A' then
                                    mi_beneficiario_type.mi_tipo_cuenta := '02';
                                 elsif mi_beneficiario_type.mi_tipo_cuenta = 'C' then
                                    mi_beneficiario_type.mi_tipo_cuenta := '01';
                                 else
                                    mi_beneficiario_type.mi_tipo_cuenta := '  ';
                                 end if;
                    -- for b in codach(mi_beneficiario_type.mi_banco) loop
                    --    mi_codbanco:=b.codigo_ach;
                    --end loop;
                                 mi_codbanco := lpad(
                                    mi_beneficiario_type.mi_banco,
                                    3,
                                    0
                                 );
                                 for e in nom_entidad(mi_beneficiario_type.mi_nro_doc) loop
                                    mi_nombre_entidad := substr(
                                       e.nomentidad,
                                       1,
                                       50
                                    );
                                 end loop;
                    -- observaciones 05/05/2020 shd
                                 if trim(mi_codbanco) is null then
                                    if r.rubro = 13 then --AFC 202506
                                       mi_viapago := 'C';
                                    else
                                       mi_viapago := 'M';
                                    end if;
                                 end if;

                                 mi_szlinea := 'P'
                                               || chr(09)
                                               || mi_codigo
                                               || chr(09)
                                               || chr(09)
                                               || rpad(
                                    mi_beneficiario_type.mi_tipo_doc,
                                    3,
                                    ' '
                                 )
                                               || chr(09)
                                               || rpad(
                                    mi_beneficiario_type.mi_nro_doc,
                                    12,
                                    ' '
                                 )
                                               || chr(09)
                                               || chr(09)
                                               || mi_cuentarub
                                               || chr(09)
                                               || mi_valor;
                                 mi_szlinea := mi_szlinea
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09);
                                 mi_szlinea := mi_szlinea
                                               || chr(09)
                                               || mi_condicion_pago
                                               || chr(09)
                                               || mi_texto
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || mi_viapago
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || mi_codbanco
                                               || chr(09)
                                               || rpad(
                                    mi_beneficiario_type.mi_numero_cuenta,
                                    20,
                                    ' '
                                 )
                                               || chr(09)
                                               || rpad(
                                    mi_beneficiario_type.mi_tipo_cuenta,
                                    2,
                                    ' '
                                 );
                                 mi_szlinea := mi_szlinea
                                               || chr(09)
                                               || '  '
                                               || chr(09)
                                               || mi_basertfte
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09);

                                 text_io.put_line(
                                    mi_archivo_sap,
                                    mi_szlinea
                                 );
                              else
                  
                    ---------- tipo ra  2

                                 if mi_beneficiario_type.mi_tipo_cuenta = 'A' then
                                    mi_beneficiario_type.mi_tipo_cuenta := '02';
                                 elsif mi_beneficiario_type.mi_tipo_cuenta = 'C' then
                                    mi_beneficiario_type.mi_tipo_cuenta := '01';
                                 else
                                    mi_beneficiario_type.mi_tipo_cuenta := '  ';
                                 end if;
                    --for b in codach(mi_beneficiario_type.mi_banco) loop
                    --      mi_codbanco:=b.codigo_ach;
                    --end loop;
                                 mi_codbanco := lpad(
                                    mi_beneficiario_type.mi_banco,
                                    3,
                                    0
                                 );
                                 for e in nom_entidad(mi_beneficiario_type.mi_nro_doc) loop
                                    mi_nombre_entidad := substr(
                                       e.nomentidad,
                                       1,
                                       50
                                    );
                                 end loop;
                                 mi_szlinea := null;
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
                            */ ( 2,
                                                 3,
                                                 11,
                                                 13,
                                                 16,
                                                 17,
                                                 18,
                                                 1316,
                                                 1317,
                                                 1318 ) then
                                    mi_valor := mi_valor + mi_valor_saldo;
                                    if
                                       r.rubro = 13
                                       and trim(mi_codbanco) is null
                                    then
                                       mi_viapago := 'C';
                                    else
                                       mi_viapago := 'M';
                                    end if;
                                    mi_beneficiario_type.mi_tipo_cuenta := ' ';
                                    mi_codbanco := '   ';
                                    mi_beneficiario_type.mi_numero_cuenta := ' ';
                                    if r.rubro in ( 13,
                                                    18,
                                                    21 ) then
                                       mi_viapago := 'C';
                                    end if;
                                 end if;
                                 mi_szlinea := 'P'
                                               || chr(09)
                                               || mi_codigo
                                               || chr(09)
                                               || chr(09)
                                               || rpad(
                                    mi_beneficiario_type.mi_tipo_doc,
                                    3,
                                    ' '
                                 )
                                               || chr(09)
                                               || rpad(
                                    mi_beneficiario_type.mi_nro_doc,
                                    12,
                                    ' '
                                 )
                                               || chr(09)
                                               || chr(09)
                                               || mi_cuentarub
                                               || chr(09)
                                               || mi_valor;
                                 mi_szlinea := mi_szlinea
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09);
                                 mi_szlinea := mi_szlinea
                                               || chr(09)
                                               || mi_condicion_pago
                                               || chr(09)
                                               || mi_texto
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || mi_viapago
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || mi_codbanco
                                               || chr(09)
                                               || rpad(
                                    mi_beneficiario_type.mi_numero_cuenta,
                                    20,
                                    ' '
                                 )
                                               || chr(09)
                                               || rpad(
                                    mi_beneficiario_type.mi_tipo_cuenta,
                                    2,
                                    ' '
                                 );
                                 mi_szlinea := mi_szlinea
                                               || chr(09)
                                               || '  '
                                               || chr(09)
                                               || mi_basertfte
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09);
                    ----
                                 text_io.put_line(
                                    mi_archivo_sap,
                                    mi_szlinea
                                 );
                              end if;

                           end if;
                        elsif mi_tabla_detalle = 'ENTIDAD' then
                           mi_tipo_entidad := p_bintablas.tbuscar(
                              mi_descripcion_cc,
                              'NOMINA',
                              'CCOSTO_ENTIDAD',
                              to_char(
                                                   sysdate,
                                                   'DD-MM-YYYY'
                                                )
                           );
                           if mi_tipo_entidad is null then
                              pr_despliega_mensaje(
                                 'AL_STOP_1',
                                 'No encontró tipo entidad para el c. costo '
                                 || mi_descripcion_cc
                                 || ' verifique CCOSTO_ENTIDAD en bintablas'
                              );
                              raise form_trigger_failure;
                           end if;
                --  MESSAGE('mi_descripcion_cc2 '||mi_descripcion_cc);
                           mi_entidad_type := pk_detalle_anexos_ra.fn_detalle_entidad(
                              mi_tipo_entidad,
                              mi_tercero,
                              mi_err
                           );
                           if mi_err = 1 then
                              pr_despliega_mensaje(
                                 'AL_STOP_1',
                                 'Ocurrió un error al recuperar información de entidades '
                                 || mi_tipo_entidad
                                 || ' '
                                 || mi_tercero
                              );
                              raise form_trigger_failure;
                           end if;
                -- FIN RQ1718-2006
                           if mi_entidad_type.mi_forma_pago is null then
                              pr_despliega_mensaje(
                                 'AL_STOP_1',
                                 'No se ha registrado la forma de pago para la entidad '
                                 || mi_tipo_entidad
                                 || ' '
                                 || mi_entidad_type.mi_nro_doc
                              );
                              raise form_trigger_failure;
                           end if;
                           if
                              un_tipo_ra = '1'
                              and mi_valor < 0
                           then
                              mi_valor := mi_valor * ( -1 );
                           end if;
                           if un_tipo_ra = '1' then
                  --   message('concepto3 '||mi_descripcion_cc);

                              if mi_entidad_type.mi_tipo_cuenta = 'A' then
                                 mi_entidad_type.mi_tipo_cuenta := '02';
                              elsif mi_entidad_type.mi_tipo_cuenta = 'C' then
                                 mi_entidad_type.mi_tipo_cuenta := '01';
                              else
                                 mi_entidad_type.mi_tipo_cuenta := '  ';
                              end if;

                              for b in codach(mi_entidad_type.mi_banco) loop
                                 mi_codbanco := b.codigo_ach;
                              end loop;
                              for e in nom_entidad(mi_entidad_type.mi_nro_doc) loop
                                 mi_nombre_entidad := substr(
                                    e.nomentidad,
                                    1,
                                    50
                                 );
                              end loop;

                              if
                                 trim(mi_codbanco) is null
                                 and r.rubro = 13
                              then
                                 mi_viapago := 'C';
                              else
                                 mi_viapago := 'M';
                                 mi_codbanco := '   ';
                              end if;
                              if upper(mi_descripcion_cc) not like '%SALUD%' then
                    -- descartar salud
                                 mi_szlinea := 'P'
                                               || chr(09)
                                               || mi_codigo
                                               || chr(09)
                                               || chr(09)
                                               || rpad(
                                    mi_entidad_type.mi_tipo_doc,
                                    3,
                                    ' '
                                 )
                                               || chr(09)
                                               || rpad(
                                    mi_entidad_type.mi_nro_doc,
                                    12,
                                    ' '
                                 )
                                               || chr(09)
                                               || chr(09)
                                               || mi_cuentarub
                                               || chr(09)
                                               || mi_valor;
                                 mi_szlinea := mi_szlinea
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09);
                                 mi_szlinea := mi_szlinea
                                               || chr(09)
                                               || mi_condicion_pago
                                               || chr(09)
                                               || mi_texto
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || mi_viapago
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || mi_codbanco
                                               || chr(09)
                                               || rpad(
                                    mi_entidad_type.mi_numero_cuenta,
                                    20,
                                    ' '
                                 )
                                               || chr(09)
                                               || rpad(
                                    mi_entidad_type.mi_tipo_cuenta,
                                    2,
                                    ' '
                                 );
                                 mi_szlinea := mi_szlinea
                                               || chr(09)
                                               || '  '
                                               || chr(09)
                                               || mi_basertfte
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09);

                                 text_io.put_line(
                                    mi_archivo_sap,
                                    mi_szlinea
                                 );
                              else
                                 mi_szlinea := 'P'
                                               || chr(09)
                                               || mi_codigo
                                               || chr(09)
                                               || chr(09)
                                               || rpad(
                                    mi_entidad_type.mi_tipo_doc,
                                    3,
                                    ' '
                                 )
                                               || chr(09)
                                               || rpad(
                                    mi_entidad_type.mi_nro_doc,
                                    12,
                                    ' '
                                 )
                                               || chr(09)
                                               || chr(09)
                                               || mi_cuentarub
                                               || chr(09)
                                               || mi_valor;
                                 mi_szlinea := mi_szlinea
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09);
                                 mi_szlinea := mi_szlinea
                                               || chr(09)
                                               || mi_condicion_pago
                                               || chr(09)
                                               || mi_texto
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || mi_viapago
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || mi_codbanco
                                               || chr(09)
                                               || rpad(
                                    mi_entidad_type.mi_numero_cuenta,
                                    20,
                                    ' '
                                 )
                                               || chr(09)
                                               || rpad(
                                    mi_entidad_type.mi_tipo_cuenta,
                                    2,
                                    ' '
                                 );
                                 mi_szlinea := mi_szlinea
                                               || chr(09)
                                               || '  '
                                               || chr(09)
                                               || mi_basertfte
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09);

                                 text_io.put_line(
                                    mi_archivo_sap,
                                    mi_szlinea
                                 );
                              end if;
                           else
                              mi_incapacidad := 0;
                              mi_saldo := 0;
                              if upper(mi_descripcion_cc) like '%SALUD%'
                              or upper(mi_descripcion_cc) like '%ARP%' then
                                 if upper(mi_descripcion_cc) like '%SALUD%' then
                                    mi_concepto_inc := 'INCAPACIDADES_AUTOL_SALUD';
                                    mi_concepto_saldos := 'SALDOS_SALUD';
                                 else
                                    mi_concepto_inc := 'INCAPACIDADES_AUTOL_ARP';
                                    mi_concepto_saldos := 'SALDOS_ARP';
                                 end if;
                                 mi_incapacidad := pk_detalle_anexos_ra.fn_detalle_incapacidades(
                                    una_compania,
                                    mi_concepto_inc,
                                    un_tipo_nomina,
                                    mi_tercero,
                                    una_fecha_final,
                                    mi_ra_type.mi_nro_ra,
                                    un_grupo_ra,
                                    mi_err
                                 );
                                 if mi_err = 1 then
                                    pr_despliega_mensaje(
                                       'AL_STOP_1',
                                       'Ocurrió un error al recuperar información de incapacidades EPS ' || mi_tercero
                                    );
                                    raise form_trigger_failure;
                                 end if;
                                 if mi_incapacidad <> 0 then
                      --mi_valor:=mi_valor - mi_incapacidad;
                                    mi_incapacidad := mi_incapacidad * ( -1 );
                                 end if;
                                 mi_saldo := pk_detalle_anexos_ra.fn_detalle_saldos(
                                    una_compania,
                                    mi_concepto_saldos,
                                    un_tipo_nomina,
                                    mi_tercero,
                                    una_fecha_final,
                                    mi_ra_type.mi_nro_ra,
                                    un_grupo_ra,
                                    mi_err
                                 );
                                 if mi_err = 1 then
                                    pr_despliega_mensaje(
                                       'AL_STOP_1',
                                       'Ocurrió un error al recuperar información de saldos a favor o en contra de la EPS ' || mi_tercero
                                    );
                                    raise form_trigger_failure;
                                 end if;
                                 if mi_saldo <> 0 then
                      --mi_valor:=mi_valor - mi_saldo;
                                    mi_saldo := mi_saldo * ( -1 );
                                 end if;
                              end if;
                              if
                                 ( upper(mi_descripcion_cc) like '%ARP%' )
                                 and mi_incapacidad <> 0
                              then
                                 mi_valor := mi_valor; -- - mi_incapacidad WN 12122008;
                    --mi_saldo:=mi_saldo*(-1);
                              end if;

                              if mi_entidad_type.mi_tipo_cuenta = 'A' then
                                 mi_entidad_type.mi_tipo_cuenta := '02';
                              elsif mi_entidad_type.mi_tipo_cuenta = 'C' then
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
                                 mi_nombre_entidad := substr(
                                    e.nomentidad,
                                    1,
                                    50
                                 );
                              end loop;
                              if r.rubro in /*(2, 3, 4, 11, 13, 14, 15, 16 , 22, 23, 24)*/ ( 2,
                                              3,
                                              11,
                                              17,
                                              18,
                                              1316,
                                              1317,
                                              1318 ) 
                    /*
                    2	    APORTES A SEGURIDAD SOCIAL EN SALUD
                    3	    APORTES A FONDOS PENSIONALES
                    11	    APORTE RIESGOS PROFESIONALES - ARP
                    17	    APORTE FONDO GARANTIA
                    18	    CESANTIAS
                    1316	APORTES SENA
                    1317	APORTES ICBF
                    1318	APORTES CAJA DE COMPENSACION

                  */ then
                                 mi_valor := mi_valor + mi_valor_saldo;
                                 mi_codbanco := '   ';
                                 if
                                    trim(mi_codbanco) is null
                                    and r.rubro = 13
                                 then
                                    mi_viapago := 'C';
                                 else
                                    mi_viapago := 'M';
                                 end if;
                                 mi_entidad_type.mi_tipo_cuenta := ' ';
                                 mi_entidad_type.mi_numero_cuenta := ' ';
                                 if r.rubro in ( 13,
                                                 18,
                                                 21 ) then
                                    mi_viapago := 'C';
                                 end if;
                              end if;

                              mi_szlinea := 'P'
                                            || chr(09)
                                            || mi_codigo
                                            || chr(09)
                                            || chr(09)
                                            || rpad(
                                 mi_entidad_type.mi_tipo_doc,
                                 3,
                                 ' '
                              )
                                            || chr(09)
                                            || rpad(
                                 mi_entidad_type.mi_nro_doc,
                                 12,
                                 ' '
                              )
                                            || chr(09)
                                            || chr(09)
                                            || mi_cuentarub
                                            || chr(09)
                                            || mi_valor;
                              mi_szlinea := mi_szlinea
                                            || chr(09)
                                            || chr(09)
                                            || chr(09)
                                            || chr(09)
                                            || chr(09)
                                            || chr(09)
                                            || chr(09)
                                            || chr(09)
                                            || chr(09)
                                            || chr(09)
                                            || chr(09)
                                            || chr(09)
                                            || chr(09)
                                            || chr(09)
                                            || chr(09);
                              mi_szlinea := mi_szlinea
                                            || chr(09)
                                            || mi_condicion_pago
                                            || chr(09)
                                            || mi_texto
                                            || chr(09)
                                            || chr(09)
                                            || chr(09)
                                            || chr(09)
                                            || chr(09)
                                            || chr(09)
                                            || mi_viapago
                                            || chr(09)
                                            || chr(09)
                                            || chr(09)
                                            || chr(09)
                                            || chr(09)
                                            || chr(09)
                                            || mi_codbanco
                                            || chr(09)
                                            || rpad(
                                 mi_entidad_type.mi_numero_cuenta,
                                 20,
                                 ' '
                              )
                                            || chr(09)
                                            || rpad(
                                 mi_entidad_type.mi_tipo_cuenta,
                                 2,
                                 ' '
                              );
                              mi_szlinea := mi_szlinea
                                            || chr(09)
                                            || '  '
                                            || chr(09)
                                            || mi_basertfte
                                            || chr(09)
                                            || chr(09)
                                            || chr(09)
                                            || chr(09);

                              text_io.put_line(
                                 mi_archivo_sap,
                                 mi_szlinea
                              );
                
                  --Puede ocurrir si la incapacidad es menor que el aporte por EPS                
                              if mi_valor < 0 then
                                 text_io.put_line(
                                    mi_id_error,
                                    'Entidad con pago negativo :'
                                    || mi_entidad_type.mi_nro_doc
                                    || '. Valor:'
                                    || mi_valor
                                 );
                                 text_io.put_line(
                                    mi_id_error,
                                    'en la Relación de autorización ' || mi_ra_type.mi_nro_ra
                                 );
                                 mi_terceros_neg := mi_terceros_neg + 1;
                              end if;
                           end if;
                           text_io.put_line(
                              mi_archivo_path,
                              mi_szlinea
                           );
                        elsif mi_tabla_detalle like '%BENEFICIARIOS%' then
                           if mi_tabla_detalle like '%NOMBRE%' then
                              mi_beneficiario_type := pk_detalle_anexos_ra.fn_detalle_beneficiarios(
                                 mi_concepto,
                                 mi_err
                              );
                              if mi_err = 1 then
                                 pr_despliega_mensaje(
                                    'AL_STOP_1',
                                    'Bf2: Ocurrió un error al recuperar información de beneficiarios'
                                 );
                                 raise form_trigger_failure;
                              end if;
                           else
                              mi_beneficiario_type := pk_detalle_anexos_ra.fn_detalle_beneficiarios(
                                 to_number(mi_tercero),
                                 mi_err
                              );
                              if mi_err = 1 then
                                 pr_despliega_mensaje(
                                    'AL_STOP_1',
                                    'Bf1: Ocurrió un error al recuperar información de beneficiarios ' || mi_tercero
                                 );
                                 raise form_trigger_failure;
                              end if;
                           end if;
                           if mi_beneficiario_type.mi_forma_pago is null then
                              pr_despliega_mensaje(
                                 'AL_STOP_1',
                                 'No se ha registrado la forma de pago para el beneficiario ' || mi_beneficiario_type.mi_nro_doc
                              );
                              raise form_trigger_failure;
                           end if;
                           if mi_valor < 0 then
                              mi_valor := mi_valor * ( -1 );
                           end if;
                           if un_tipo_ra = '1' then
                              if mi_beneficiario_type.mi_tipo_cuenta = 'A' then
                                 mi_beneficiario_type.mi_tipo_cuenta := '02';
                              elsif mi_beneficiario_type.mi_tipo_cuenta = 'C' then
                                 mi_beneficiario_type.mi_tipo_cuenta := '01';
                              else
                                 mi_beneficiario_type.mi_tipo_cuenta := '  ';
                              end if;
                  -- codigo ach
                  -- for b in codach(mi_beneficiario_type.mi_banco) loop
                  --     mi_codbanco:=b.codigo_ach;
                  -- end loop; 
                              mi_codbanco := lpad(
                                 mi_beneficiario_type.mi_banco,
                                 3,
                                 0
                              );
                              for e in nom_entidad(mi_beneficiario_type.mi_nro_doc) loop
                                 mi_nombre_entidad := substr(
                                    e.nomentidad,
                                    1,
                                    50
                                 );
                              end loop;
                  /*if mi_viapago='M' then
                   mi_codbanco:='   ';
                  end if;*/
                              if /*2025003170 trim(mi_codbanco) is null and*/ r.rubro = 13 then
                                 mi_viapago := 'M';
                              elsif trim(mi_codbanco) is null then
                   -- mi_viapago := 'M';
                                 mi_viapago := '   ';   ---2025003170
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
                       , 22, 23, 24)*/ ( 2,
                                                 3,
                                                 11,
                                                 17,
                                                 18,
                                                 1316,
                                                 1317,
                                                 1318 )
                       /*
                        2	    APORTES A SEGURIDAD SOCIAL EN SALUD
                        3	    APORTES A FONDOS PENSIONALES
                        11	    APORTE RIESGOS PROFESIONALES - ARP
                        17	    APORTE FONDO GARANTIA
                        18	    CESANTIAS
                        1316	APORTES SENA
                        1317	APORTES ICBF
                        1318	APORTES CAJA DE COMPENSACION
                       */ then
                      --mi_valor:=mi_valor+mi_valor_saldo;
                                    mi_codbanco := '   ';
                                    mi_viapago := 'M';
                                    mi_beneficiario_type.mi_tipo_cuenta := ' ';
                                    mi_beneficiario_type.mi_numero_cuenta := ' ';
                                    if r.rubro in ( 13,
                                                    18,
                                                    21 ) then
                                       mi_viapago := 'C';
                                    end if; 
                     --INI 2025003170
                                 elsif r.rubro in ( 5 ) then
                                    mi_viapago := ' '; 
                    --FIN 2025003170
                                 end if;
                                 mi_szlinea := 'P'
                                               || chr(09)
                                               || mi_codigo
                                               || chr(09)
                                               || chr(09)
                                               || rpad(
                                    mi_beneficiario_type.mi_tipo_doc,
                                    3,
                                    ' '
                                 )
                                               || chr(09)
                                               || rpad(
                                    mi_beneficiario_type.mi_nro_doc,
                                    12,
                                    ' '
                                 )
                                               || chr(09)
                                               || chr(09)
                                               || mi_cuentarub
                                               || chr(09)
                                               || mi_valor;
                                 mi_szlinea := mi_szlinea
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09);
                                 mi_szlinea := mi_szlinea
                                               || chr(09)
                                               || mi_condicion_pago
                                               || chr(09)
                                               || mi_texto
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || mi_viapago
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || mi_codbanco
                                               || chr(09)
                                               || rpad(
                                    mi_beneficiario_type.mi_numero_cuenta,
                                    20,
                                    ' '
                                 )
                                               || chr(09)
                                               || rpad(
                                    mi_beneficiario_type.mi_tipo_cuenta,
                                    2,
                                    ' '
                                 );
                                 mi_szlinea := mi_szlinea
                                               || chr(09)
                                               || '  '
                                               || chr(09)
                                               || mi_basertfte
                                               || chr(09)
                                               || chr(09)
                                               || chr(09)
                                               || chr(09);

                                 text_io.put_line(
                                    mi_archivo_sap,
                                    mi_szlinea
                                 );
                              end if;
                  -- mi_szLinea :=' beneficiario';
                           else
                              if un_tipo_ra = '2' then
                                 mi_valor := mi_valor + mi_valor_saldo;
                              end if;
                              if mi_beneficiario_type.mi_tipo_cuenta = 'A' then
                                 mi_beneficiario_type.mi_tipo_cuenta := '02';
                              elsif mi_beneficiario_type.mi_tipo_cuenta = 'C' then
                                 mi_beneficiario_type.mi_tipo_cuenta := '01';
                              else
                                 mi_beneficiario_type.mi_tipo_cuenta := '  ';
                              end if;
                
                  --for b in codach(mi_beneficiario_type.mi_banco) loop
                  --mi_codbanco:=b.codigo_ach;
                              mi_codbanco := lpad(
                                 mi_beneficiario_type.mi_banco,
                                 3,
                                 0
                              );
                  --end loop;                                        
                              for e in nom_entidad(mi_entidad_type.mi_nro_doc) loop
                                 mi_nombre_entidad := substr(
                                    e.nomentidad,
                                    1,
                                    50
                                 );
                              end loop;
                              if mi_codbanco is null then
                                 mi_viapago := 'M';
                    --mi_codbanco:='   ';
                              end if;
                              if r.rubro in ( 2,
                                              3,
                                              4,
                                              11,
                                              13,
                                              14,
                                              15,
                                              16,
                                              22,
                                              23,
                                              24 ) then
                    -- mi_valor:=mi_valor+mi_valor_saldo;
                                 if
                                    r.rubro = 13
                                    and trim(mi_codbanco) is null
                                 then
                                    mi_viapago := 'C';
                                 else
                                    mi_viapago := 'M';
                                 end if;
                                 mi_codbanco := '   ';
                                 mi_beneficiario_type.mi_tipo_cuenta := ' ';
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
                              mi_szlinea := 'P'
                                            || chr(09)
                                            || mi_codigo
                                            || chr(09)
                                            || chr(09)
                                            || rpad(
                                 mi_beneficiario_type.mi_tipo_doc,
                                 3,
                                 ' '
                              )
                                            || chr(09)
                                            || rpad(
                                 mi_beneficiario_type.mi_nro_doc,
                                 12,
                                 ' '
                              )
                                            || chr(09)
                                            || chr(09)
                                            || mi_cuentarub
                                            || chr(09)
                                            || mi_valor;
                              mi_szlinea := mi_szlinea
                                            || chr(09)
                                            || chr(09)
                                            || chr(09)
                                            || chr(09)
                                            || chr(09)
                                            || chr(09)
                                            || chr(09)
                                            || chr(09)
                                            || chr(09)
                                            || chr(09)
                                            || chr(09)
                                            || chr(09)
                                            || chr(09)
                                            || chr(09)
                                            || chr(09);
                              mi_szlinea := mi_szlinea
                                            || chr(09)
                                            || mi_condicion_pago
                                            || chr(09)
                                            || mi_texto
                                            || chr(09)
                                            || chr(09)
                                            || chr(09)
                                            || chr(09)
                                            || chr(09)
                                            || chr(09)
                                            || mi_viapago
                                            || chr(09)
                                            || chr(09)
                                            || chr(09)
                                            || chr(09)
                                            || chr(09)
                                            || chr(09)
                                            || mi_codbanco
                                            || chr(09)
                                            || rpad(
                                 mi_beneficiario_type.mi_numero_cuenta,
                                 20,
                                 ' '
                              )
                                            || chr(09)
                                            || rpad(
                                 mi_beneficiario_type.mi_tipo_cuenta,
                                 2,
                                 ' '
                              );
                              mi_szlinea := mi_szlinea
                                            || chr(09)
                                            || '  '
                                            || chr(09)
                                            || mi_basertfte
                                            || chr(09)
                                            || chr(09)
                                            || chr(09)
                                            || chr(09);
                              text_io.put_line(
                                 mi_archivo_sap,
                                 mi_szlinea
                              );
                  --end if;
                           end if;

                        end if;
                     end loop;
                     exec_sql.close_cursor(
                        exec_sql.default_connection,
                        mi_cursor
                     );
                  exception
                     when others then
                        if sqlcode = -302000 then
                           pr_despliega_mensaje(
                              'AL_STOP_1',
                              'Ocurrio un error intentando escribir el archivo ' || mi_archivo_plano
                           );
                        else
                           pr_despliega_mensaje(
                              'AL_STOP_1',
                              'Ocurrió el error: ' || to_char(sqlcode)
                           );
                        end if;

                        raise form_trigger_failure;
                  end; --Otros Anexos

               end if;
            end loop; --Termina de recorrer los centros de costo para el tipo de nómina
            close cur_anexos;
      --
         end loop; --Termina de recorrer el loop de las RA a generar (una para la vigencia,
    --otra para reservas)
         text_io.fclose(mi_archivo_sap_foncep);
         pr_debug_registra(
            mi_file_debug_handle,
            '2550 Text_IO.fClose(mi_archivo_sap_foncep) y mostrar archivos'
         );
         web.show_document(
            mi_pathweb_ra
            || '/'
            || mi_archivo_planosap,
            '_blank'
         );
   -- web.show_document(mi_pathweb_ra ||'/'|| mi_archivo_planosapfoncep, '_blank');
         if mi_cc is null then
            pr_despliega_mensaje(
               'AL_STOP_1',
               'No se han definido centros de costo para el tipo de RA.' || mi_cc
            );
         else
            if mi_terceros_neg > 0 then
               text_io.fclose(mi_id_error);
               pr_despliega_mensaje(
                  'AL_STOP_1',
                  'Existen terceros con pagos negativos.  Será¡ rechazada la RA en OPGET.'
               );
               if get_application_property(user_interface) = 'WEB' then
                  web.show_document(
                     mi_pagina_carga
                     || '/'
                     || mi_nombre_archivo_err,
                     '_BLANK'
                  );
               else
                  host('NOTEPAD.EXE '
                       || 'c:\'
                       || mi_nombre_archivo_err);
               end if;
            end if;
            if text_io.is_open(mi_id_error) then
               text_io.fclose(mi_id_error);
            end if;
            text_io.fclose(mi_archivo_sap);
            if text_io.is_open(mi_archivo_sap) then
               text_io.fclose(mi_archivo_sap);
               web.show_document(
                  mi_pathweb_ra
                  || '/'
                  || mi_archivo_planosap,
                  '_blank'
               );
            end if;
            pr_despliega_mensaje(
               'AL_STOP_1',
               'Fueron generados los archivos planos.'
            );
         end if;
      end loop;
      close c_ra;
      text_io.fclose(mi_archivo_sap);
      if text_io.is_open(mi_archivo_sap) then
         text_io.fclose(mi_archivo_sap);
         web.show_document(
            mi_pathweb_ra
            || '/'
            || mi_archivo_planosap,
            '_blank'
         );
      end if;
      if :b_ra.cta_x_nomina = '999999999' then
         if text_io.is_open(mi_file_debug_handle) then
            text_io.fclose(mi_file_debug_handle);
         end if;
      end if;
   exception
      when others then
         if text_io.is_open(mi_id_error) then
            text_io.fclose(mi_id_error);
         end if;
         mi_sqlcode := sqlcode;
         if mi_sqlcode = 100 then
            null;
         else
            pr_despliega_mensaje(
               'AL_STOP_1',
               '22 Ocurrió un error. mi_cc | SQLERRM | linea :'
               || mi_cc
               || ' | '
               || sqlerrm()
               || '| '
               || mi_linea_ejecutada
            );
            pr_debug_registra(
               mi_file_debug_handle,
               '22 Ocurrió un error. mi_cc | SQLERRM | linea :V'
               || mi_cc
               || ' | '
               || sqlerrm()
               || '| '
               || mi_linea_ejecutada
            );
            pr_debug_registra(
               mi_file_debug_handle,
               '22 Ocurrió un error. mi_cc | SQLERRM | query : '
               || mi_cc
               || ' | '
               || sqlerrm()
               || '| '
               || mi_consulta
            );
            if :b_ra.cta_x_nomina = '999999999' then
               if text_io.is_open(mi_file_debug_handle) then
                  text_io.fclose(mi_file_debug_handle);
               end if;
            end if;
     -- dbms_output.put_line(substr(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,500));
         end if;
         mi_err := 1;
   end pr_planos_ra_shd;