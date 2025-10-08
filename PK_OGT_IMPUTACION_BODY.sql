create or replace package body pk_ogt_imputacion as

   procedure pr_procesar_imputacion (
      p_nro_referencia_pago sl_pcp_pago.nro_referencia_pago%type,
      p_usuario             varchar2,
      p_resp                out varchar2,
      p_procesado           out boolean
   ) as
      ref_cur_cuentas_cobro sys_refcursor;
      mi_rec_pago           type_rec_pago;
      my_exception exception;
      mi_acta_numero        number;
      mi_tipo_acta          varchar2(10) /*ogt_documento.tipo%type*/ := 'ALE';
      mi_valor_pagado       number;
      mi_num_resp           number;
   begin
      mi_code_id_capital   := fn_ogt_traer_code_concepto('RECAUDO CAPITAL CUOTAS PARTES POR APLICAR FIDUDAVIVIENDA');
      mi_code_id_interes   := fn_ogt_traer_code_concepto('RECAUDO INTERESES CUOTAS PARTES POR APLICAR FIDUDAVIVIENDA');

      dbms_output.put_line('IMP. Iniciando imputacion');
      dbms_output.put_line('IMP Creando acta');
      pr_traer_sl_pcp_pago(
         p_nro_referencia_pago => p_nro_referencia_pago,
         p_resp                => p_resp,
         p_rec_pago            => mi_rec_pago
      );
      if p_resp is not null then
         p_resp := p_resp
                   || chr(10)
                   || ' No encuentro registros de pago para la referencia de pago '
                   || p_nro_referencia_pago;
         p_procesado := false;
      else
         -- Inicio registro acta
         mi_acta_numero := pk_secuencial.fn_traer_consecutivo(
            'OPGET',
            'ACTA_LEGAL_ID',
            '0000',
            '000'
         ) + 1;
         if mi_acta_numero is not null then
            mi_valor_pagado := fn_traer_valor_referencia_pago(p_nro_referencia_pago => p_nro_referencia_pago);
            if nvl(
               mi_valor_pagado,
               0
            ) > 0 then
               --si el acta se crea correctamente mi_num_resp=1 
               mi_num_resp := fn_crear_acta(
                  un_documento    => mi_acta_numero,
                  un_tipo         => mi_tipo_acta,
                  una_fecha       => sysdate,
                  un_estado       => 'RE',
                  una_unidad      => 'FINANCIERO',
                  una_observacion => 'PAGADO PORTAL REF. PAGO: ' || to_char(p_nro_referencia_pago),
                  un_usuario      => p_usuario,
                  un_valor        => mi_valor_pagado
               );
               --Una vez creada el acta mi_num_resp = 1, se crea el documento y detalle del mismo
               if mi_num_resp = 1 then
                  pk_secuencial.pr_actualizar_consecutivo(mi_acta_numero);
               --Se crea el documento y detalle documento del acta
               
                  pr_registrar_documento(
                     p_acta_numero         => mi_acta_numero,
                     p_tipo_acta           => mi_tipo_acta,
                     p_nro_referencia_pago => p_nro_referencia_pago,
                     p_rec_pago            => mi_rec_pago,
                     p_usuario             => p_usuario,
                     p_resp                => p_resp,
                     p_procesado           => p_procesado
                  );
                  --Actualiza encabezado y guarda o rechaza actualizaciones de acuerdo al resultado en p_procesado
                  pr_actualizar_encabezado(
                     p_nro_referencia_pago => p_nro_referencia_pago,
                     p_proceso             => 'RA', --Registro Acta  
                     p_resp                => p_resp,
                     p_procesado           => p_procesado
                  );
                  --Contabilizar y actualiza sisla
                  if p_procesado = true then
                     pr_contabilizar_imputacion(
                        p_nro_referencia_pago => p_nro_referencia_pago,
                        p_usuario             => p_usuario,
                        p_resp                => p_resp,
                        p_procesado           => p_procesado
                     );
                     --Actualiza encabezado y guarda o rechaza actualizaciones de acuerdo al resultado en p_procesado
                     pr_actualizar_encabezado(
                        p_nro_referencia_pago => p_nro_referencia_pago,
                        p_proceso             => 'LM', --Registro Acta  
                        p_resp                => p_resp,
                        p_procesado           => p_procesado
                     );

                  end if;
               end if;
            else
               p_resp := p_resp
                         || chr(10)
                         || ' El valor de la referencia de pago debe ser mayor a cero (0) para la referencia de pago '
                         || p_nro_referencia_pago;
               p_procesado := false;
            end if;
         else
            p_resp := p_resp
                      || chr(10)
                      || ' No es posible obtener el secuencial para generar el acta y procesar la referencia de pago '
                      || p_nro_referencia_pago;
            p_procesado := false;
         end if;  --if mi_acta_numero is not null then
      end if; --if mi_rec_pago is null then
   exception
      when others then
         p_procesado := false;
         p_resp := dbms_utility.format_error_stack;
   end pr_procesar_imputacion;


   procedure pr_registrar_documento (
      p_numero_acta         varchar2, --ogt_documento.numero%type,
      p_tipo_acta           varchar2, --ogt_documento.tipo%type,
      p_nro_referencia_pago sl_pcp_pago.nro_referencia_pago%type,
      p_rec_pago            type_rec_pago,
      p_usuario             varchar2,
      p_resp                out varchar2,
      p_procesado           out boolean
   ) as
      mi_rec_cuenta_cobro   type_rec_cuenta_cobro;
      mi_cur_cuentas_cobro  sys_refcursor;
      mi_numero_documento   varchar2(30);
      mi_entidad            usuarios_compania.codigo_compania%type := 206;
      mi_id_tercero_destino number;
      mi_id_tercero_origen  number;
      mi_centro_costo       varchar2(30);
      mi_vigencia           number;
      mi_ingreso            number;
      mi_tipo_documento     varchar2(3) := 'XYZ';
      mi_estado_documento   varchar2(2) := 'RE';
      mi_bin_tipo_cuenta    varchar2(2) := 'FID';
      mi_unte_codigo        varchar2(10) := 'FINANCIERO';
      mi_cuba_numero        varchar2(12) := '482800043630';
      mi_tipo_soporte       varchar2(3) := 'NCR';
      mi_situacion_fondos   varchar2(1) := 'S';
      mi_unidad_ejecutora   varchar2(2);
      mi_id_cuenta_cobro10  varchar2(15);  --Se recorta a 10 caracateres si es mayor
   begin
      mi_unidad_ejecutora := '01'; --pk_permisos_entidad_unieje.fn_leer_unieje_actual('OPGET');
      if mi_cuba_numero is null then
         mi_situacion_fondos := 'N';
      end if;
      select extract(year from sysdate)
        into mi_vigencia
        from dual;
      begin
         --Crea documento
         mi_numero_documento := pk_secuencial.fn_traer_consecutivo(
                  'OPGET',
                  'DOC_NUM',
                  '2002',
                  '000'
               ) + 1;
         if mi_numero_documento is null then
            p_resp := p_resp
               || chr(10)
               || 'No fue posible obtener el consecutivo para registro de la cuenta de cobro '
               || mi_rec_cuenta_cobro.id;
               p_procesado := false;
         else
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
                     mi_tipo_documento,
                     mi_estado_documento,
                     sysdate,
                     p_rec_pago.id_banco,
                     mi_unte_codigo,
                     mi_bin_tipo_cuenta,
                     null,
                     mi_cuba_numero,
                     p_usuario,
                     p_usuario,
                     mi_tipo_soporte,
                     p_rec_pago.fecha_autorizacion,
                     p_rec_pago.fecha_autorizacion,
                     mi_vigencia,
                     p_numero_acta,
                     p_tipo_acta );
            pk_secuencial.pr_actualizar_consecutivo(mi_numero_documento);
            ogt_pk_ingreso.pr_insertar_tercero(p_rec_pago.id_banco);
            p_procesado := true;
         end if; --if mi_numero_documento is null then
      exception
         when others then
            p_resp := p_resp
                      || chr(10)
                      || 'No fue posible ingresar el documento con referencia nro.:'
                      || p_nro_referencia_pago
                      || '. '
                      || sqlerrm;
            p_procesado := false;
      end;    
      if p_procesado := true then    
         --ref_cuentas_cobro := pk_sl_interfaz_opget_cp.pr_trae_cuentas_cobro(p_nro_referencia_pago,);
         --p_resp en caso de error o no encontrar datos
         --ref_cuentas_cobro retorna las cuentas de cobro asociadas a p_nro_referencia_pago o nulo si no existen
         pr_traer_cuentas_cobro(
            p_nro_referencia_pago => p_nro_referencia_pago,
            p_resp                => p_resp,
            p_ref_cursor          => mi_cur_cuentas_cobro
         );
         if p_resp is not null
         or mi_unidad_ejecutora is null then
            p_resp := p_resp
                     || chr(10)
                     || ' No se encontraron cuentas de cobro de ref. pago'
                     || p_nro_referencia_pago;
            p_procesado := false;
         else
            p_resp := p_resp
                     || chr(10)
                     || 'Cuentas de cobro cargadas de la ref. pago'
                     || p_nro_referencia_pago;
         end if;
            --/*
         if p_procesado = true then
            loop
               fetch mi_cur_cuentas_cobro into mi_rec_cuenta_cobro;
               exit when mi_cur_cuentas_cobro%notfound;

               dbms_output.put_line('ID Cuenta cobro= ' || mi_rec_cuenta_cobro.id);
               if p_procesado = true then
                  begin
                     /* ogt_detalle_documento.doc_numero = ogt_documento.NUMERO AND
                        ogt_detalle_documento.doc_tipo = ogt_documento.tipo */
                        --Inserta detalle documento
                     mi_id_tercero_destino := pk_sit_infentidades.sit_fn_id_entidad(
                        mi_entidad,
                        sysdate
                     );
                     --Si no encuentra la entidad
                     if mi_entidad is null then
                        p_resp := p_resp
                                 || chr(10)
                                 || ' Entidad actual no se encuentra verifique k_permisos_entidad_unieje.FN_LEER_ENTIDAD_ACTUAL'
                                 ;
                        p_procesado := false;
                     --si encuentra la entidad, busca su id tercero
                     else
                        mi_id_tercero_origen := sl_id_tercero(
                           mi_rec_cuenta_cobro.codigo_entidad,
                           p_resp
                        );
                        if mi_id_tercero_origen is null then
                           p_procesado := false;
                           p_resp := p_resp
                                    || chr(10)
                                    || 'No se encontro id tercero origne para id_cuenta_cobro '
                                    || mi_rec_cuenta_cobro.id;
                        end if;
                     end if; --if mi_entidad is null then
                     --Si no encuentra el id tercero de la entidad
                     if p_procesado = true then
                        --extrae los 10 últimos caracteres
                        mi_id_cuenta_cobro10 := lpad(
                           to_char(mi_rec_cuenta_cobro.id_cuenta_cobro),
                           10,
                           '0'
                        );
                        mi_id_cuenta_cobro10 := substr(
                           mi_id_cuenta_cobro10,
                           -10,
                           10
                        );
                        --Crea detalle documento por liquidación.

                                 --Registra capital e intereses
                        pr_registrar_detalle_documento(
                           p_valor_capital           => mi_rec_cuenta_cobro.valor_capital,
                           p_valor_intereses         => mi_rec_cuenta_cobro.valor_intereses,
                           p_ter_id_destino          => mi_id_tercero_destino,
                           p_doc_numero              => mi_numero_documento,
                           p_doc_tipo                => mi_tipo_documento,
                           p_ter_id_origen           => mi_id_tercero_origen,
                           p_ter_id_recaudador       => null,
                           p_ter_id_entidad_origen   => null,
                           p_vigencia_ingreso        => mi_vigencia,
                           p_info_numero             => p_nro_referencia_pago,
                           p_fecha_recaudo           => p_rec_pago.fecha_autorizacion,
                           p_codigo_interno          => mi_rec_cuenta_cobro.id_cuenta_cobro,
                           p_valor_base_impuestos    => null,
                           p_unidad_ejecutora_origen => null,
                           p_porcentaje              => 0,
                           p_centro_costo            => mi_centro_costo,
                           p_numero_sisla            => mi_id_cuenta_cobro10,
                           p_estado_sisla            => 'PL' --por legalizar
                        );
                     end if;  --if p_procesado = true then
                  exception
                     when others then
                        p_resp := p_resp
                                 || chr(10)
                                 || 'No fue posible ingresar el detalle documento de cuenta cobro.:'
                                 || mi_rec_cuenta_cobro.id
                                 || '. '
                                 || sqlerrm;
                        p_procesado := false;
                  end;
               end if; --if p_procesado = true then
            end loop;
         end if;
         --cierro el cursor
         close mi_cur_cuentas_cobro;
      end if; --if p_procesado = true then
   end pr_registrar_documento;


--Registra capital e intereses
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
   ) as
      p_code_id            number;
      mi_rec_liquidacion   type_rec_liquidacion;
      mi_cur_liquidacion   sys_refcursor;
   begin
      --ref_liquidaciones retorna las liquidaciones asociadas a una cuentas de cobro
      pr_traer_liquidaciones(
         p_nro_referencia_pago => p_nro_referencia_pago,
         p_resp                => p_resp,
         p_ref_cursor          => mi_cur_liquidacion
      );
      if p_resp is not null then
         p_resp := p_resp
                   || chr(10)
                   || ' No se encontraron liquidaciones de la cuenta de cobro '
                   || p_codigo_interno;
         p_resp := false;
      else
         loop
            fetch mi_cur_liquidacion into mi_rec_liquidacion;
            exit when mi_cur_liquidacion%notfound;
            
            if mi_rec_liquidacion.valor_capital <= 0 then
               p_resp := p_resp
                  || chr(10)
                  || 'No hay valor de capital a registrar de la liquidacion '
                  || mi_rec_liquidacion.id;
            else
               --mi_code_id_capital := fn_ogt_traer_code_concepto('RECAUDO CAPITAL CUOTAS PARTES POR APLICAR FIDUDAVIVIENDA');
               if mi_code_id_capital is null then
                  p_resp := p_resp
                        || chr(10)
                        || 'En OGT No existe el concepto para registro de capital '
                        || 'RECAUDO CAPITAL CUOTAS PARTES POR APLICAR FIDUDAVIVIENDA';
               else
                  mi_centro_costo := fn_ogt_traer_centro_costo(p_id_tercero_origen => mi_id_tercero_origen);
                  if mi_centro_costo is null then
                     p_resp := p_resp
                                 || chr(10) || 'No existe el centro de costo para la entidad '
                                 || mi_rec_cuenta_cobro.codigo_entidad;
                  else
                     --********************************
                     --Inicio inserción capital
                     --********************************
                     insert into ogt_detalle_documento (
                              code_id,
                              valor,
                              ter_id_destino,
                              doc_numero,
                              doc_tipo,
                              mi_unte_codigo,
                              ter_id_origen,
                              ter_id_recaudador,
                              ter_id_entidad_origen,
                              vigencia_ingreso,
                              info_numero,
                              fecha_recaudo,
                              codigo_interno,
                              valor_base_impuestos,
                              unidad_ejecutora_origen,
                              porcentaje,
                              centro_costo,
                              numero_sisla,
                              estado_sisla
                              ) values ( mi_code_id_interes,
                              mi_rec_liquidacion.valor_capital,
                              mi_id_tercero_destino,
                              mi_numero_documento,
                              mi_tipo_documento,
                              mi_id_tercero_origen,
                              null,
                              null,
                              mi_vigencia,
                              p_nro_referencia_pago,
                              p_rec_pago.fecha_autorizacion,
                              mi_rec_cuenta_cobro.id_cuenta_cobro,
                              null,
                              null,
                              0,
                              null,
                              mi_centro_costo,
                              mi_rec_cuenta_cobro.id_cuenta_cobro,
                              'PL' --por legalizar
                        );
                           --crear el ingreso del capital registrado
                     mi_ingreso := ogt_pk_ingreso.ogt_fn_crear(
                                       mi_vigencia,
                                       null,
                                       sysdate,
                                       mi_code_id_capital,
                                       mi_numero_documento,
                                       mi_tipo_documento,
                                       mi_unte_codigo,
                                       mi_id_tercero_origen,
                                       mi_id_tercero_destino,
                                       mi_cuba_numero,
                                       mi_bin_tipo_cuenta,
                                       null,
                                       p_rec_pago.id_banco,
                                       mi_rec_cuenta_cobro.valor_capital,
                                       'EL',
                                       p_tipo_acta,
                                       p_numero_acta,
                                       null,
                                       null,
                                       null,
                                       mi_situacion_fondos,
                                       mi_unidad_ejecutora,
                                       mi_unidad_ejecutora,
                                       'E',
                                       0
                              ); 
                           -- * /
                     if mi_ingreso is null then
                        p_resp := p_resp
                                       || chr(10)
                                       || 'No fue posible registrar el ingreso de la cuenta de cobro '
                                       || mi_rec_cuenta_cobro.id_cuenta_cobro;
                                       p_procesado := false; --No continua, el ingreso debe ser garantizado
                        
                        exit;
                     end if; --if mi_ingreso is null then
                     --********************************
                     --Inicio inserción Intereses
                     --********************************
                     --Registro intereses intereses
                     --mi_code_id_interes := fn_ogt_traer_code_concepto('RECAUDO INTERESES CUOTAS PARTES POR APLICAR FIDUDAVIVIENDA'
                        );
                     if mi_code_id_interes is null then
                        p_resp := p_resp
                                       || chr(10)
                                       || 'En OGT No existe el concepto para registro de intereses: '
                                       || 'RECAUDO CAPITAL CUOTAS PARTES POR APLICAR FIDUDAVIVIENDA';
                     else
                        if mi_rec_liquidacion.valor_interes > 0 then
                           insert into ogt_detalle_documento (
                                    code_id,
                                    valor,
                                    ter_id_destino,
                                    doc_numero,
                                    doc_tipo,
                                    mi_unte_codigo,
                                    ter_id_origen,
                                    ter_id_recaudador,
                                    ter_id_entidad_origen,
                                    vigencia_ingreso,
                                    info_numero,
                                    fecha_recaudo,
                                    codigo_interno,
                                    valor_base_impuestos,
                                    unidad_ejecutora_origen,
                                    porcentaje,
                                    centro_costo,
                                    numero_sisla,
                                    estado_sisla
                                    ) values ( mi_code_id_interes,
                                    mi_rec_liquidacion.valor_interes,
                                    mi_id_tercero_destino,
                                    mi_numero_documento,
                                    mi_tipo_documento,
                                    mi_id_tercero_origen,
                                    null,
                                    null,
                                    mi_vigencia,
                                    p_nro_referencia_pago,
                                    p_rec_pago.fecha_autorizacion,
                                    mi_rec_cuenta_cobro.id_cuenta_cobro,
                                    null,
                                    null,
                                    0,
                                    null,
                                    mi_centro_costo,
                                    mi_rec_cuenta_cobro.id_cuenta_cobro,
                                    'PL' --por legalizar
                                    );
                           --insertar los id de los terceros en la tabla de terceros de ingresos
                           if ( mi_id_tercero_origen is not null ) then
                              ogt_pk_ingreso.pr_insertar_tercero(mi_id_tercero_origen);
                           end if;
                           if ( mi_id_tercero_origen is not null ) then
                              ogt_pk_ingreso.pr_insertar_tercero(mi_id_tercero_destino);
                           end if;   
                           --crear el ingreso del capital registrado
                           mi_ingreso := ogt_pk_ingreso.fn_crear(
                                    mi_vigencia,
                                    null,
                                    sysdate,
                                    mi_code_id_interes,
                                    mi_numero_documento,
                                    mi_tipo_documento,
                                    mi_unte_codigo,
                                    mi_id_tercero_origen,
                                    mi_id_tercero_destino,
                                    mi_cuba_numero,
                                    mi_bin_tipo_cuenta,
                                    null,
                                    p_rec_pago.id_banco,
                                    mi_rec_liquidacion.valor_capital,
                                    'EL',
                                    p_tipo_acta,
                                    p_numero_acta,
                                    null,
                                    null,
                                    null,
                                    mi_situacion_fondos,
                                    mi_unidad_ejecutora,
                                    mi_unidad_ejecutora,
                                    'E',
                                    0
                                    );
                           if mi_ingreso is null then
                              p_resp := p_resp
                                       || chr(10)
                                       || 'No fue posible registrar el ingreso de la cuenta de cobro '
                                       || mi_rec_cuenta_cobro.id_cuenta_cobro;
                                       p_procesado := false;
                                       exit;
                           end if; --if mi_ingreso is null then
                        end if; --if mi_rec_liquidacion.valor_interes > 0 then
                     end if; --if mi_code_id_interes is null then
                  end if; --if mi_centro_costo is null THEN */
               end if; --if mi_code_id_capital is null then
            end if; --if p_valor_capital <= 0 then
         end loop;
      end if; --if p_resp is not null then
   end pr_registrar_detalle_documento;

   


   --Retorna las cuentas de cobro de un encabezado con p_id_encabezado
   procedure pr_traer_cuentas_cobro (
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
         --p_ref_cursor := null;
         p_resp := 'No se encontraron cuentas de cobro para la referencia de pago: ' || p_nro_referencia_pago;
      when others then
         --p_ref_cursor := null;
         p_resp := 'Error al obtener las cuentas de cobro: ' || sqlerrm;
   end pr_traer_cuentas_cobro;


   --Retorna las liquidaciones asociadas la cuenta de cobro id_det_cuenta_cobro
   procedure pr_traer_liquidaciones (
      p_id_det_cuenta_cobro sl_pcp_cuenta_cobro.id_det_cuenta_cobro%type,
      p_resp                out varchar2,
      p_ref_cursor          out sys_refcursor
   );   
   begin
      open p_ref_cursor for 
         select id,
            id_det_cuenta_cobro,
            id_factura,
            interno_persona,
            fecha_periodo_ini,
            fecha_periodo_fin,
            saldo_factura,
            valor_capital,
            valor_interes,
            fecha_sistema
         from sl_pcp_liquidaciones
          where id_det_cuenta_cobro =  p_id_det_cuenta_cobro;
   exception
      when no_data_found then
         --p_ref_cursor := null;
         p_resp := 'No se encontraron liquidaciones para la cuenta de cobro : ' || p_id_det_cuenta_cobro;
      when others then
         --p_ref_cursor := null;
         p_resp := 'Error al obtener las liquidaciones: ' || sqlerrm;
   end pr_traer_liquidaciones;

   procedure pr_traer_sl_pcp_pago (
      p_nro_referencia_pago sl_pcp_pago.nro_referencia_pago%type,
      p_resp                out varchar2,
      p_rec_pago            out type_rec_pago
   ) as
   begin
      select id,
             nro_referencia_pago,
             id_banco,
             cod_autorizacion,
             fecha_autorizacion,
             metodo_recaudo,
             canal,
             jornada,
             codigo_oficina
        into
         p_rec_pago.id,
         p_rec_pago.nro_referencia_pago,
         p_rec_pago.id_banco,
         p_rec_pago.cod_autorizacion,
         p_rec_pago.fecha_autorizacion,
         p_rec_pago.metodo_recuado,
         p_rec_pago.canal,
         p_rec_pago.jornada,
         p_rec_pago.codigo_oficina
        from sl_pcp_pago
       where nro_referencia_pago = p_nro_referencia_pago
         and rownum = 1;
   exception
      when no_data_found then
         p_rec_pago := null;
         p_resp := 'No se encontró el pago de la referencia de pago: ' || p_nro_referencia_pago;
      when others then
         p_rec_pago := null;
         p_resp := 'Error al obtener información del pago: '
                   || p_nro_referencia_pago
                   || '.'
                   || sqlerrm;
   end pr_traer_sl_pcp_pago;

   function fn_crear_acta (
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

   procedure pr_actualizar_encabezado (
      p_nro_referencia_pago sl_pcp_encabezado.nro_referencia_pago%type,
      p_proceso             varchar2,
      p_resp                out varchar2,
      p_procesado           in out boolean
   ) as
   begin
      if
         p_proceso = 'OGT'
         and p_procesado = true
      then 
      --Registro las cuentas de cobro en opget creando correctamente el acta
         update sl_pcp_encabezado
            set
            estado = p_proceso
          where nro_referencia_pago = p_nro_referencia_pago;
         commit;
      elsif
         p_proceso = 'LM'
         and p_procesado = true
      then 
      --Registro las liquidaciones en LM, contabilizando y causandolas correctamente
         update sl_pcp_encabezado
            set
            estado = 'LM'
          where nro_referencia_pago = p_nro_referencia_pago;
         commit;
      elsif
         p_proceso = 'SL'
         and p_procesado = true
      then
      --Actualizó correctamente las solicitudes en SISLa
         update sl_pcp_encabezado
            set
            estado = 'SL'
          where nro_referencia_pago = p_nro_referencia_pago;
         commit;
      else
         p_resp := p_resp
                   || chr(10)
                   || ' Fallido para la referencia de pago '
                   || p_nro_referencia_pago
                   || ' Proceso'
                   || p_proceso;
         rollback;
      end if;
   exception
      when others then
         p_procesado := false;
         p_resp := dbms_utility.format_error_stack;
   end pr_actualizar_encabezado;

--- Para obtenere el centro de costo
-- para el obtener el tercero o pensionado usar sl_relacion_persona
   function sl_id_tercero (
      p_codigo_compa sl_relacion_tac.codigo_compa%type,
      p_resp         out varchar2
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

   --Trae el code_id del concepto asociado
   function fn_ogt_traer_code_concepto (
      p_descripcion varchar
   ) return varchar2 as
      mi_id varchar2(20);
   begin
      select id
        into mi_id
        from ogt_concepto_tesoreria
       where descripcion = p_descripcion;
      return mi_id;
   exception
      when others then
         return null;
   end fn_ogt_traer_code_concepto;

   function fn_ogt_traer_centro_costo (
      p_id_tercero_origen varchar2
   ) return varchar2 as
      mi_result varchar2(30);
   begin
      select cod_centro_costo
        into mi_result
        from ogt_tercero_cc
       where id_tercero = p_id_tercero_origen;
      return mi_result;
   exception
      when others then
         return null;
   end fn_ogt_traer_centro_costo;

end pk_ogt_imputacion;
/