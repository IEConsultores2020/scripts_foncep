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

   --Tabla de tipo registro cuenta de cobro
   type type_tab_cuenta_cobro is
      table of type_rec_cuenta_cobro;

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

   function fn_traer_valor_referencia_pago (
      p_nro_referencia_pago sl_pcp_pago.nro_referencia_pago%type
   ) return number;

--Retorna las cuentas de cobro asociados a una referencia de pago
   procedure pr_trae_cuentas_cobro (
      p_nro_referencia_pago sl_pcp_pago.nro_referencia_pago%type,
      p_resp                out varchar2,
      p_ref_cursor          out sys_refcursor
   );

   procedure pr_traerr_sl_pcp_pago (
      p_nro_referencia_pago sl_pcp_pago.nro_referencia_pago%type,
      p_resp                out varchar2,
      p_ref_cursor          out sys_refcursor
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

   procedure pr_actualiza_encabezado (
      p_nro_referencia_pago sl_pcp_encabezado.nro_referencia_pago%type,
      p_resp                out varchar2,
      p_procesado           in out boolean
   );

   function sl_id_tercero (
      p_codigo_compa sl_relacion_tac.codigo_compa%type,
      p_resp         varchar2
   ) return sl_relacion_tac.id_limay%type;

end pk_ogt_imputacion;
/

create or replace package body pk_ogt_imputacion as

   procedure pr_procesar_imputacion (
      p_nro_referencia_pago sl_pcp_pago.nro_referencia_pago%type,
      p_usuario             varchar2,
      p_resp                out varchar2,
      p_procesado           out boolean
   ) as
      v_type_rec_cuenta_cobro type_rec_cuenta_cobro;
      ref_cur_cuentas_cobro   sys_refcursor;
      my_exception exception;
      mi_acta_numero          number;
      mi_tipo_acta            varchar2(10) /*ogt_documento.tipo%type*/ := 'ALE';
   begin
      dbms_output.put_line('IMP. Iniciando imputacion');
      dbms_output.put_line('IMP Creando acta');
      -- Inicio registro acta
      mi_acta_numero := pk_secuencial.fn_traer_consecutivo(
         'OPGET',
         'ACTA_LEGAL_ID',
         '0000',
         '000'
      ) + 1;
      pk_secuencial.pr_actualizar_consecutivo(mi_acta_numero);
      if mi_acta_numero is not null then
         mi_valor := fn_traer_valor_referencia_pago(p_nro_referencia_pago => p_nro_referencia_pago);
         --si el acta se crea correctamente mi_resp=1 
         mi_resp := fn_crear_acta(
            un_documento    => mi_acta_numero,
            un_tipo         => mi_tipo_acta,
            una_fecha       => sysdate,
            un_estado       => 'RE',
            una_unidad      => 'FINANCIERO',
            una_observacion => 'PAGADO PORTAL REF. PAGO: ' || p_nro_referencia_pago,
            un_usuario      => p_usuario,
            un_valor        => mi_valor
         );
         --Una vez creada el acta, se crea el documento y detalle del mismo
         if mi_resp = 1 then
            --Se crea el documento del acta
            pr_registrar_documento(
               p_acta_numero         => mi_acta_numero,
               p_tipo_acta           => mi_tipo_acta,
               p_nro_referencia_pago => p_nro_referencia_pago,
               p_usuario             => p_usuario,
               p_resp                => p_resp,
               p_procesado           => p_procesado
            );
            --Se crea documento_detalle
         else
            p_resp := p_resp
                      || chr(10)
                      || ' No se creo acta para cuenta de cobro'
                      || p_rec_cuenta_cobro.id;
         end if;
      end if;
      p_procesado := true;
      select sysdate || 'En construcción desde 09/01/2025'
        into p_resp
        from dual;
      pr_actualiza_encabezado(
         p_nro_referencia_pago => p_nro_referencia_pago,
         p_resp                => p_resp,
         p_procesado           => p_procesado
      );
   exception
      when others then
         p_procesado := false;
         p_resp := dbms_utility.format_error_stack;
   end pr_procesar_imputacion;

   procedure pr_registrar_documento (
      p_acta_numero         varchar2, --ogt_documento.numero%type,
      p_tipo_acta           varchar2, --ogt_documento.tipo%type,
      p_nro_referencia_pago sl_pcp_pago.nro_referencia_pago%type,
      p_rec_pago            type_rec_pago,
      p_usuario             varchar2,
      p_resp                out varchar2,
      p_procesado           out boolean
   ) as
      mi_rec_cuenta_cobro   v_type_rec_cuenta_cobro;
      mi_numero_documento   ogt_documento.numero%type;
      mi_entidad            usuarios_compania.codigo_compania%type := 206;
      mi_id_tercero_destino ogt_tercero.id%type;
      mi_id_tercero_origen  sl_relacion_tac.id_limay%type;
   begin
         --ref_cuentas_cobro := pk_sl_interfaz_opget_cp.pr_trae_cuentas_cobro(p_nro_referencia_pago,);
         --p_resp en caso de error o no encontrar datos
         --ref_cuentas_cobro retorna las cuentas de cobro asociadas a p_nro_referencia_pago o nulo si no existen
      pr_trae_cuentas_cobro(
         p_nro_referencia_pago => p_nro_referencia_pago,
         p_resp                => p_resp,
         p_ref_cursor          => ref_cur_cuentas_cobro
      );
      if p_resp is not null then
         dbms_output.put_line('Intentando cargar cuentas cobro, resp:' || p_resp);
         raise my_exception;
      else
         dbms_output.put_line('Cuentas de cobro cargadas');
      end if;
         --/*
      loop
         fetch ref_cur_cuentas_cobro into rec_cuenta_cobro;
         exit when ref_cur_cuentas_cobro%notfound;
         p_procesado := true;
         dbms_output.put_line('ID Cuenta cobro= ' || mi_rec_cuenta_cobro.id);
            --Crea documento
         mi_numero_documento := pk_secuencial.fn_traer_consecutivo(
            'OPGET',
            'DOC_NUM',
            '2002',
            '000'
         ) + 1;
         begin
            insert into ogt_documento (
               numero,
               tipo,
               estado,
               fecha,
               ter_id_receptor,
               unte_codigo,
               bin_tipo_cuenta,
               bin_tipo_titulo,
               cuba_numero,
               usuario_elaboro,
               usuario_reviso,
               tipo_soporte,
               fecha_compra_titulo,
               fecha_soporte,
               numero_timbre,
               numero_legal,
               tipo_legal
            ) values ( mi_numero_documento,
                       'XYZ',
                       'RE',
                       sysdate,
                       p_rec_pago.id_banco,
                       'FINANCIERO',
                       'FID',
                       null,
                       '482800043630',
                       p_usuario,
                       p_usuario,
                       'NCR',
                       p_rec_pago.fecha_autorizacion,
                       p_rec_pago.fecha_autorizacion,
                       extract(year from sysdate),
                       p_acta_numero,
                       p_tipo_acta );
            pk_secuencial.pr_actualizar_consecutivo(mi_numero_documento);
            ogt_pk_ingreso.pr_insertar_tercero(p_rec_pago.id_banco);
         exception
            when others then
               resp := resp + chr(10)
                       || "No fue posible ingresar el documento con referencia nro.:"
                       || p_nro_referencia_pago
                       || '. '
                       || sqlerrm;
               p_procesado := false;
         end;
         if p_procesado = true then
            begin
                  --Inserta detalle documento
               mi_id_tercero_destino := pk_sit_infentidades.sit_fn_id_entidad(
                  mi_entidad,
                  sysdate
               );
               if mi_entidad is null then
                  p_resp := p_resp
                            || chr(10)
                            || ' Entidad actual no se encuentra verifique k_permisos_entidad_unieje.FN_LEER_ENTIDAD_ACTUAL';
                  p_procesado := false;
               else
                  mi_id_tercero_origen := sl_id_tercero(
                     mi_rec_cuenta_cobro.codigo_entidad,
                     p_resp
                  );
                  if mi_id_tercero_origin is null then
                     p_procesado := false;
                     p_resp := 'id_cuenta_cobro '
                               || mi_rec_cuenta_cobro.id
                               || ' '
                               || p_resp;
                  end if;
               end if;

               if p_procesado then
                     --OGT_DETALLE_DOCUMENTO.DOC_NUMERO = OGT_DOCUMENTO.NUMERO AND
                     --OGT_DETALLE_DOCUMENTO.DOC_TIPO = OGT_DOCUMENTO.TIPO
                     --Crea detalle documento
                     --Registro capital
                  dbms_output.putline('Listo para registrar id cuenta cobro ' || mi_rec_cuenta_cobro.id);
                     /*insert into ogt_detalle_documento (
                        code_id,                valor,         
                        ter_id_destino,         doc_numero,             doc_tipo,      ter_id_origen,
                        ter_id_recaudador,      ter_id_entidad_origen,
                        vigencia_ingreso,                               info_numero,            fecha_recaudo,
                        codigo_interno,         valor_base_impuestos,
                        unidad_ejecutora_origen,porcentaje,             centro_costo,
                        numero_sisla,           estado_sisla
                     )
                     values
                     (  null,                   mi_rec_cuenta_cobro.valor_capital,          
                        mi_id_tercero_destino,  mi_numero_documento,    'XYZ',         mi_id_tercero_origen,
                        null,                   null,
                        extract(year from sysdate),                     p_nro_referencia_pago,

                     );
                     --Registro intereses

                  --Crea ingreso
                  --insertar los id de los terceros en la tabla de terceros de ingresos
                     IF(:ogt_detalle_documento.ter_id_origen IS NOT NULL)THEN
                     ogt_pk_ingreso.pr_insertar_tercero(:ogt_detalle_documento.ter_id_origen);
                     END IF;
                     IF(:ogt_detalle_documento.ter_id_entidad_origen IS NOT NULL)THEN
                        ogt_pk_ingreso.pr_insertar_tercero(:ogt_detalle_documento.ter_id_entidad_origen);
                     END IF;
                     IF(:ogt_detalle_documento.ter_id_recaudador IS NOT NULL)THEN
                        ogt_pk_ingreso.pr_insertar_tercero(:ogt_detalle_documento.ter_id_recaudador);
                     END IF;
                     ogt_pk_ingreso.pr_insertar_tercero(:ogt_detalle_documento.ter_id_destino);
               
                     --crear el ingreso  
                     mi_ingreso:= ogt_pk_ingreso.ogt_fn_crear(
                     :ogt_detalle_documento.vigencia_ingreso,
                     null,
                     :ogt_acta.fecha,
                     :ogt_detalle_documento.cote_id,
                     :ogt_documento.numero,
                     :ogt_documento.tipo,
                     :ogt_documento.unte_codigo,
                     :ogt_detalle_documento.ter_id_origen,
                     :ogt_detalle_documento.ter_id_destino,
                     :ogt_documento.cuba_numero,
                     :ogt_documento.bin_tipo_cuenta,
                     null,
                     :ogt_documento.ter_id_receptor,
                     :ogt_detalle_documento.valor,
                     'EL',
                     :ogt_acta.tipo,
                     :ogt_acta.numero,
                     NULL,
                     NULL,
                     NULL,
                     mi_situacion_fondos,
                     pk_permisos_entidad_unieje.FN_LEER_UNIEJE_ACTUAL('OPGET'),
                     pk_permisos_entidad_unieje.FN_LEER_ENTIDAD_ACTUAL('OPGET'),
                     'E',
                     0); -- */
               end if;
            exception
               when others then
                  resp := resp + chr(10) + "No fue posible ingresar el detalle documento con referencia nro.:"
                          || p_nro_referencia_pago
                          || '. '
                          || sqlerrm;
                  p_procesado := false;
            end;
         end if;
      end loop;
         --cierro el cursor
      close ref_cur_cuentas_cobro;
   end pr_registrar_documento;

   function fn_traer_valor_referencia_pago (
      p_nro_referencia_pago sl_pcp_pago.nro_referencia_pago%type
   ) return number is
      mi_valor number;
   begin
      select valor
        into mi_valor
        from sl_pcl_encabezado
       where nro_referencia_pago = p_nro_referencia_pago;
      return valor;
   exception
      when others then
         return 0;
   end fn_traer_valor_referencia_pago;


   --Retorna las cuentas de cobro de un encabezado con p_id_encabezado
   procedure pr_trae_cuentas_cobro (
      p_nro_referencia_pago sl_pcp_pago.nro_referencia_pago%type,
      p_resp                out varchar2,
      p_ref_cursor          out sys_refcursor
   ) as
   begin
      open p_ref_cursor for select id,
                                   id_encabezado,
                                   codigo_entidad,
                                   id_cuenta_cobro,
                                   saldo_cuenta_cobro,
                                   valor_capital,
                                   valor_intereses,
                                   fecha_sistema
                                                    from sl_pcp_cuenta_cobro
                             where id_encabezado in (
                               select id
                                 from sl_pcp_encabezado
                                where nro_referencia_pago = p_nro_referencia_pago
                            );
   exception
      when no_data_found then
         p_ref_cursor := null;
         p_resp := 'No se encontraron cuentas de cobro para la referencia de pago: ' || p_nro_referencia_pago;
      when others then
         p_ref_cursor := null;
         p_resp := 'Error al obtener las cuentas de cobro: ' || sqlerrm;
   end pr_trae_cuentas_cobro;

   procedure pr_traer_sl_pcp_pago (
      p_nro_referencia_pago sl_pcp_pago.nro_referencia_pago%type,
      p_resp                out varchar2,
      p_ref_cursor          out sys_refcursor
   ) as
   begin
      open p_ref_cursor for select id,
                                   nro_referencia_pago,
                                   id_banco,
                                   cod_autorizacion,
                                   fecha_autorizacion,
                                   metodo_recuado,
                                   canal,
                                   jornada,
                                   codigo_oficina
                                                    from sl_pcp_pago
                             where nro_referencia_pago = p_nro_referencia_pago;
   exception
      when no_data_found then
         p_ref_cursor := null;
         p_resp := 'No se encontró el pago de la referencia de pago: ' || p_nro_referencia_pago;
      when others then
         p_ref_cursor := null;
         p_resp := 'Error al obtener información del pago: '
                   || p_nro_referencia_pago
                   || '.'
                   || sqlerrm;
   end pr_traer_sl_pcp_pago;

   function fn_crear_acta (
      un_documento    ogt_documento.numero%type,
      un_documento    varchar2,   --ogt_documento.numero%type,
      un_tipo         varchar2,   --ogt_documento.tipo%type,
      una_fecha       date,       --ogt_documento.fecha%type :=SYSDATE,
      un_estado       varchar2,   --ogt_documento.estado%type,
      una_unidad      varchar2,   --ogt_documento.unte_codigo%type,
      una_observacion varchar2,   --ogt_documento.observaciones%type,
      un_usuario      varchar2,   --ogt_documento.usuario_elaboro%type,
      un_valor        number      --ogt_documento.valor%type
   ) return number is
   begin
      insert into ogt_documento (
         numero,
         tipo,
         estado,
         fecha,
         unte_codigo,
         observaciones,
         usuario_elaboro,
         valor
      ) values ( un_documento,
                 un_tipo,
                 'EL',
                 una_fecha,
                 una_unidad,
                 una_observacion,
                 un_usuario_elaboro,
                 un_valor );
      return 1;
   exception
      when others then
         return 0;
   end fn_crear_acta;

   procedure pr_actualiza_encabezado (
      p_nro_referencia_pago sl_pcp_encabezado.nro_referencia_pago%type,
      p_resp                out varchar2,
      p_procesado           in out boolean
   ) as
   begin
      --PIM (Parcialmente IMputado): Faltaron cuentas de cobro o liquidaciones por registrar (R)
      if not nvl(
         p_procesado,
         false
      ) then
         update sl_pcp_encabezado
            set
            estado = 'PIM'
          where nro_referencia_pago = p_nro_referencia_pago;
      else
      --IMP (IMputado): Todas las cuentas de cobro y liquidaciones fueron completamente registradas (R)
         update sl_pcp_encabezado
            set
            estado = 'PIM'
          where nro_referencia_pago = p_nro_referencia_pago;
      end if;
      --commit;
      p_procesado := true;
   exception
      when others then
         p_procesado := false;
         p_resp := dbms_utility.format_error_stack;
   end pr_actualiza_encabezado;

   function sl_id_tercero (
      p_codigo_compa sl_relacion_tac.codigo_compa%type,
      p_resp         varchar2
   ) return sl_relacion_tac.id_limay%type as
      mi_id_limay sl_relacion_tac.id_limay%type;
   begin
      select id_limay
        into mi_id_limay
        from sl_relacion_tac
       where codigo_compa = p_codigo_compa;

      return mi_id_limay;
   exception
      when others then
         p_resp := p_resp
                   || chr(10)
                   || ' No fue posible encontrar el tercero';
         return null;
   end sl_id_tercero;


end pk_ogt_imputacion;
/