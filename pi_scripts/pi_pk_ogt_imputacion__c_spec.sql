create or replace package pk_ogt_imputacion as
/* Creado para el portal de pagos de cuotas partes
   2024005523 202509 ftorresv Creación

*/
   --Registro de cuentas de cobro
   type type_rec_cuenta_cobro is record (
         id                 number(18,0),
         id_encabezado      number(18,0),
         codigo_entidad     varchar2(10 BYTE),
         id_cuenta_cobro    number(15,0),
         saldo_cuenta_cobro number(15,0),
         valor_capital      number(15,0),
         valor_intereses    number(15,0),
         fecha_sistema      date
   );

   --Registro de pago
   type type_rec_pago is record (
         id                  number(18,0),
         nro_referencia_pago varchar2(15 BYTE),
         id_banco            number(2,0),
         cod_autorizacion    number(10,0),
         fecha_autorizacion  date,
         metodo_recuado      number(3,0),
         canal               number(3,0),
         jornada             number(2,0),
         codigo_oficina      number(10,0)
   );   

   type type_rec_encabezado is record (
         id                  number(18,0),
         nro_referencia_pago varchar2(15 BYTE),
         estado              varchar2(3 BYTE),
         centro_costo        number(38,0)
   );

   --Registro de cuentas de cobro
   type type_rec_liquidacion is record (
         id                  number(18,0), 	
         id_det_cuenta_cobro number(18,0), 
         id_factura          number(15,0), 
         interno_persona     number(18,0), 
         fecha_periodo_ini   date,
         fecha_periodo_fin   date,
         saldo_factura       number(15,0), 
         valor_capital       number(15,0), 
         valor_interes       number(15,0), 
         fecha_sistema       date,  
         estado              char(1 BYTE) 
   );

   --Tabla de tipo registro cuenta de cobro
   type type_tab_cuenta_cobro is table of type_rec_cuenta_cobro;

   mi_concepto_capital        varchar2(20);        -- := fn_ogt_traer_code_concepto('RECAUDO CAPITAL CUOTAS PARTES POR APLICAR FIDUDAVIVIENDA');
   mi_concepto_interes        varchar2(20);        -- := fn_ogt_traer_code_concepto('RECAUDO INTERESES CUOTAS PARTES POR APLICAR FIDUDAVIVIENDA');
   mi_concepto_causa_interes  varchar2(20);  -- := fn_ogt_traer_code_concepto('CAUSACION INTERESES CUOTAS PARTES POR APLICAR FIDUDAVIVIENDA');

  /* Procedimiento para imputar pagos pendientes*/
   procedure pr_imputaciones (    
      p_usuario            varchar2,
      p_nro_referencia     varchar2 default null
   ) ;

   --Procedimiento para procesar imputación
   procedure pr_procesar_imputacion (
      p_nro_referencia_pago varchar2,
      p_usuario             varchar2,
      p_resp                out varchar2,
      p_procesado           out boolean
   );

   procedure pr_registrar_documento (
      p_acta_numero         varchar2, 
      p_acta_tipo           varchar2, 
      p_estado              varchar2, 
      p_nro_referencia_pago varchar2,
      p_rec_pago            type_rec_pago,
      p_usuario             varchar2,
      p_resp                out varchar2,
      p_procesado           out boolean
   );

   procedure pr_registrar_detalle_docum (
      p_id_cuenta_cobro         number, 
      p_valor_capital           number,
      p_valor_interes           number,
      p_doc_numero              varchar2, --30
      p_doc_tipo                varchar2, --10
      p_unte_codigo             varchar2, --10
      p_ter_id_origen           number,
      p_centro_costo            varchar2, --30
      p_ter_id_destino          number,
      p_ter_id_recaudador       number,
      p_ter_id_entidad_origen   number,
      p_tipo_cuenta             varchar2, --3
      p_cuba_numero             varchar2,
      p_vigencia_ingreso        number,   --4,0
      p_info_numero             varchar2, --30
      p_fecha_recaudo           date,
      p_codigo_interno          number,   --10,2
      p_valor_base_impuestos    number,   --20
      p_unidad_ejecutora_origen varchar2, --6
      p_porcentaje              number,   --10,4
      p_numero_sisla            varchar2, --20
      p_estado_sisla            varchar2, --50
      p_acta_tipo               varchar2, --10
      p_acta_numero             number,
      p_resp                    out varchar2,
      p_procesado               out boolean
   );

   procedure pr_ingreso_imputacion (
      p_nro_referencia_pago varchar2,
      p_usuario             varchar2,
      p_resp                out varchar2,
      p_procesado           out boolean
   );

   procedure pr_legalizar_financiero (
      p_nro_referencia_pago varchar2,
      p_resp                out varchar2,
      p_procesado           out boolean
   );    

   procedure pr_traer_encabezados (
      p_estado              varchar2,      
      p_nro_referencia      varchar2 default null,
      p_resp                out varchar2,
      p_ref_cursor          out sys_refcursor
   );

   function fn_traer_valor_referencia_pago (
      p_nro_referencia_pago varchar2
   ) return number;

--Retorna las cuentas de cobro asociados a una referencia de pago
   procedure pr_traer_cuentas_cobro (
      p_nro_referencia_pago varchar2,
      p_resp                out varchar2,
      p_ref_cursor          out sys_refcursor
   );

--Retorna las liquidaciones asociadas la cuenta de cobro id_det_cuenta_cobro
   procedure pr_traer_liquidaciones (
      p_id_det_cuenta_cobro number,
      p_resp                out varchar2,
      p_ref_cursor          out sys_refcursor
   );

   procedure pr_traer_sl_pcp_pago (
      p_nro_referencia_pago varchar2,
      p_resp                out varchar2,
      p_rec_pago            out type_rec_pago
   );

   function fn_crear_acta (
      un_documento      varchar2,   --ogt_documento.numero%type,
      un_tipo           varchar2,   --ogt_documento.tipo%type,
      una_fecha         date,       --ogt_documento.fecha%type :=SYSDATE,
      un_estado         varchar2,   --ogt_documento.estado%type,
      una_unidad        varchar2,   --ogt_documento.unte_codigo%type,
      un_numero_externo varchar2,  --ogt_documento.numero_externo%type
      una_observacion   varchar2,   --ogt_documento.observaciones%type,
      un_usuario        varchar2,   --ogt_documento.usuario_elaboro%type,
      un_valor          number      --ogt_documento.valor%type
   ) return number;

   procedure pr_actualizar_encabezado (
      p_nro_referencia_pago varchar2,
      p_nuevo_estado        varchar2,
      p_resp                out varchar2,
      p_procesado           in out boolean
   );

   procedure sl_id_tercero_y_centro_costo (
      p_codigo_compa      varchar2,
      p_id_tercero_origen out number,
      p_nit_origen        out varchar2,
      p_centro_costo      out varchar2,
      p_resp              out varchar2
   );

   --Trae el code_id del concepto asociado
   function fn_ogt_traer_code_concepto (
      p_descripcion varchar
   ) return varchar2;
   

   --Trae el número del acta registrada para la referencia de pago ó -1 por defecto
   procedure pr_traer_numero_acta (
      un_tipo            varchar2,   --ogt_documento.tipo%type,
      una_unidad         varchar2,   --ogt_documento.unte_codigo%type,
      un_numero_externo  ogt_documento.numero_externo%type,
      un_estado      out ogt_documento.estado%type,
      un_acta_numero out ogt_documento.numero%type);


   --Trae el estado del encabezado
   procedure pr_traer_estado_encabezado (
      p_nro_referencia_pago varchar2,
      p_resp                out varchar2
   );

end pk_ogt_imputacion;
/