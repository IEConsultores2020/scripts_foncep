create or replace package pk_ogt_imputacion as
/* Creado para el portal de pagos de cuotas partes
   2024005523 202509 ftorresv Creación

*/
   --Registro de cuentas de cobro
   type type_rec_cuenta_cobro is record (
         id                 sl_pcp_cuenta_cobro.id%type,
         id_encabezado      sl_pcp_cuenta_cobro.id_encabezado%type,
         codigo_entidad     sl_pcp_cuenta_cobro.codigo_entidad%type,
         id_cuenta_cobro    sl_pcp_cuenta_cobro.id_cuenta_cobro%type,
         saldo_cuenta_cobro sl_pcp_cuenta_cobro.saldo_cuenta_cobro%type,
         valor_capital      sl_pcp_cuenta_cobro.valor_capital%type,
         valor_intereses    sl_pcp_cuenta_cobro.valor_intereses%type,
         fecha_sistema      sl_pcp_cuenta_cobro.fecha_sistema%type
   );

   --Registro de pago
   type type_rec_pago is record (
         id                  sl_pcp_pago.id%type,
         nro_referencia_pago sl_pcp_pago.nro_referencia_pago%type,
         id_banco            sl_pcp_pago.id_banco%type,
         cod_autorizacion    sl_pcp_pago.cod_autorizacion%type,
         fecha_autorizacion  sl_pcp_pago.fecha_autorizacion%type,
         metodo_recuado      sl_pcp_pago.metodo_recaudo%type,
         canal               sl_pcp_pago.canal%type,
         jornada             sl_pcp_pago.jornada%type,
         codigo_oficina      sl_pcp_pago.codigo_oficina%type
   );   

   --Registro de cuentas de cobro
   type type_rec_liquidacion is record (
         id                  sl_pcp_liquidaciones.id%type, 	--NUMBER(18,0) NOT NULL ENABLE, 
         id_det_cuenta_cobro sl_pcp_liquidaciones.id_det_cuenta_cobro%type, --NUMBER(18,0) NOT NULL ENABLE, 
         interno_persona     sl_pcp_liquidaciones.interno_persona%type, --NUMBER(15,0) NOT NULL ENABLE, 
         id_factura          sl_pcp_liquidaciones.id_factura%type, --NUMBER(15,0) NOT NULL ENABLE, 
         fecha_periodo_fin   sl_pcp_liquidaciones.fecha_periodo_fin%type,
         saldo_factura       sl_pcp_liquidaciones.saldo_factura%type, --NUMBER(15,0) NOT NULL ENABLE, 
         valor_capital       sl_pcp_liquidaciones.valor_capital%type, --NUMBER(15,0) NOT NULL ENABLE, 
         valor_interes       sl_pcp_liquidaciones.valor_interes%type, --NUMBER(15,0) DEFAULT 0 NOT NULL ENABLE, 
         fecha_sistema       sl_pcp_liquidaciones.fecha_sistema%type, --DATE NOT NULL ENABLE, 
         estado              sl_pcp_liquidaciones.estado%type --CHAR(1 BYTE) '"ESTADO"'
   );

   --Tabla de tipo registro cuenta de cobro
   type type_tab_cuenta_cobro is
      table of type_rec_cuenta_cobro;
   mi_code_id_capital varchar2(20); -- := fn_ogt_traer_code_concepto('RECAUDO CAPITAL CUOTAS PARTES POR APLICAR FIDUDAVIVIENDA');
   mi_code_id_interes varchar2(20); -- := fn_ogt_traer_code_concepto('RECAUDO INTERESES CUOTAS PARTES POR APLICAR FIDUDAVIVIENDA');

   --Procedimiento para procesar imputación
   procedure pr_procesar_imputacion (
      p_nro_referencia_pago sl_pcp_pago.nro_referencia_pago%type,
      p_usuario             varchar2,
      p_resp                out varchar2,
      p_procesado           out boolean
   );

   procedure pr_registrar_documento (
      p_acta_numero         varchar2, --ogt_documento.numero%type,
      p_tipo_acta           varchar2, --ogt_documento.tipo%type,
      p_nro_referencia_pago sl_pcp_pago.nro_referencia_pago%type,
      p_rec_pago            type_rec_pago,
      p_usuario             varchar2,
      p_resp                out varchar2,
      p_procesado           out boolean
   );

   procedure pr_registrar_detalle_documento (
      p_valor_capital           number,
      p_valor_intereses         number,
      p_doc_numero              varchar2, --30
      p_doc_tipo                varchar2, --10
      p_id_tercero_origen       number,
      p_id_tercero_destino      number,
      p_vigencia                number,   --4,0
      p_code_id                 varchar2, --30
      p_info_numero             varchar2, --30
      p_fecha_recaudo           date,
      p_codigo_interno          number,   --10,2
      p_valor_base_impuestos    number,   --20
      p_unidad_ejecutora_origen varchar2, --6
      p_porcentaje              number,   --10,4
      p_centro_costo            varchar2, --20
      p_numero_sisla            varchar2, --20
      p_estado_sisla            varchar2, --50
      p_resp                    out varchar2,
      p_procesado               out boolean
   );

   procedure pr_contabilizar_imputacion (
      p_nro_referencia_pago sl_pcp_pago.nro_referencia_pago%type,
      p_usuario             varchar2,
      p_resp                out varchar2,
      p_procesado           out boolean
   );

   function fn_traer_valor_referencia_pago (
      p_nro_referencia_pago sl_pcp_pago.nro_referencia_pago%type
   ) return number;

--Retorna las cuentas de cobro asociados a una referencia de pago
   procedure pr_traer_cuentas_cobro (
      p_nro_referencia_pago sl_pcp_pago.nro_referencia_pago%type,
      p_resp                out varchar2,
      p_ref_cursor          out sys_refcursor
   );

--Retorna las liquidaciones asociadas la cuenta de cobro id_det_cuenta_cobro
   procedure pr_traer_liquidaciones (
      p_id_det_cuenta_cobro sl_pcp_liquidaciones.id_det_cuenta_cobro%type,
      p_resp                out varchar2,
      p_ref_cursor          out sys_refcursor
   );

   procedure pr_traer_sl_pcp_pago (
      p_nro_referencia_pago sl_pcp_pago.nro_referencia_pago%type,
      p_resp                out varchar2,
      p_rec_pago            out type_rec_pago
   );

   function fn_crear_acta (
      un_documento    varchar2,   --ogt_documento.numero%type,
      un_tipo         varchar2,   --ogt_documento.tipo%type,
      una_fecha       date,       --ogt_documento.fecha%type :=SYSDATE,
      un_estado       varchar2,   --ogt_documento.estado%type,
      una_unidad      varchar2,   --ogt_documento.unte_codigo%type,
      una_observacion varchar2,   --ogt_documento.observaciones%type,
      un_usuario      varchar2,   --ogt_documento.usuario_elaboro%type,
      un_valor        number      --ogt_documento.valor%type
   ) return number;

   procedure pr_actualizar_encabezado (
      p_nro_referencia_pago sl_pcp_encabezado.nro_referencia_pago%type,
      p_proceso             varchar2,
      p_resp                out varchar2,
      p_procesado           in out boolean
   );

   function sl_id_tercero (
      p_codigo_compa sl_relacion_tac.codigo_compa%type,
      p_resp         out varchar2
   ) return sl_relacion_tac.id_limay%type;

   --Trae el code_id del concepto asociado
   function fn_ogt_traer_code_concepto (
      p_descripcion varchar
   ) return varchar2;
   
   --Trea el centro de costo del tercero origen
   function fn_ogt_traer_centro_costo (
      p_id_tercero_origen varchar2
   ) return varchar2;

end pk_ogt_imputacion;
/