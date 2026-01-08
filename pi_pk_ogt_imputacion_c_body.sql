create or replace package body pk_ogt_imputacion as

  /* Procedimiento para imputar pagos pendientes*/
   procedure pr_imputaciones (    
      p_usuario            varchar2,
      p_nro_referencia     sl_pcp_pago.nro_referencia_pago%type default null
   ) as
   mi_cur_encabezados      sys_refcursor;
   mi_rec_encabezado       type_rec_encabezado;
   mi_nro_referencia_pago  sl_pcp_pago.nro_referencia_pago%type;
   mi_resp                 varchar2(2000);
   mi_procesado            boolean;
   begin
      pr_traer_encabezados(
         p_estado          => 'PAG',
         p_resp            => mi_resp,
         p_nro_referencia  => p_nro_referencia,
         p_ref_cursor      => mi_cur_encabezados
      );
     if mi_cur_encabezados is null Then
        mi_resp := 'OPGET:'+to_char(sysdate,'YYYYMMDD')+': No hay encabezados con estado PAG para procesar';
        seguimiento(mi_resp);
        mi_procesado := false;
     else
        loop
           fetch mi_cur_encabezados into mi_rec_encabezado;
           exit when mi_cur_encabezados%notfound;
           mi_nro_referencia_pago := mi_rec_encabezado.nro_referencia_pago;
           dbms_output.put_line('Procesando referencia de pago: ' || mi_nro_referencia_pago);
           pr_procesar_imputacion(
              p_nro_referencia_pago => mi_nro_referencia_pago,
              p_usuario             => p_usuario,
              p_resp                => mi_resp,
              p_procesado           => mi_procesado
           );
          -- mi_resp := 'OPGET: '; --||to_char(sysdate,'YYYYMMDD') || mi_nro_referencia_pago || ': ' || mi_resp;
         --  seguimiento(mi_resp);
        end loop;
        close mi_cur_encabezados;
     end if;
   end pr_imputaciones;

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
      mi_estado_acta        varchar2(2) := 'RE';
      mi_valor_pagado       number;
      mi_num_resp           number;
      mi_estado_encabezado  varchar2(3);
   begin
      mi_concepto_capital := fn_ogt_traer_code_concepto('RECAUDO CAPITAL CUOTAS PARTES POR APLICAR FIDUDAVIVIENDA');
      mi_concepto_interes := fn_ogt_traer_code_concepto('RECAUDO INTERESES CUOTAS PARTES POR APLICAR FIDUDAVIVIENDA');
      --00-02-37-19-00-00-00
      mi_concepto_causa_interes := fn_ogt_traer_code_concepto('CAUSACION INTERESES CUOTAS PARTES POR APLICAR FIDUDAVIVIENDA');
      if
         mi_concepto_capital is not null
         and mi_concepto_interes is not null
      then
         p_resp := 'OPGET: Iniciando imputacion con referencia: ' || p_nro_referencia_pago;
         seguimiento(p_resp);
         dbms_output.put_line(p_resp);
         pr_traer_estado_encabezado(
            p_nro_referencia_pago => p_nro_referencia_pago,
            p_resp                => mi_estado_encabezado );
         if mi_estado_encabezado not in ('PAG','REG','DIS') then
            p_resp := 'OPGET: Imputación fallida. El estado debe ser PAGada o REGistrada de la referencia: '|| p_nro_referencia_pago;
            seguimiento(p_resp);
            p_procesado := false;
         else
            pr_traer_sl_pcp_pago(
               p_nro_referencia_pago => p_nro_referencia_pago,
               p_resp                => p_resp,
               p_rec_pago            => mi_rec_pago
            );

            if p_resp is null then
               pr_traer_numero_acta (
                  un_tipo           => mi_tipo_acta,
                  una_unidad        => 'FINANCIERO',
                  un_numero_externo => p_nro_referencia_pago,
                  un_estado         => mi_estado_acta,
                  un_acta_numero    => mi_acta_numero);

               --Si encuentro el acta y esta en AProbada, no se procesa             
               if mi_acta_numero > 1 and mi_estado_acta = 'AP' then
                  p_resp := 'Ya estaba aprobada, acta '||mi_acta_numero||' referencia '||p_nro_referencia_pago;
                  seguimiento(p_resp);
                  p_procesado := false;
               elsif mi_acta_numero = -2 then
                  p_resp := 'OPGET: Hay más de una acta para la referencia '||p_nro_referencia_pago;
                  seguimiento(p_resp);
                  p_procesado := false;                    
               elsif mi_acta_numero = -1 and mi_estado_encabezado = 'REG' then --El acta debe existir
                  p_resp := 'OPGET: Inconsistencia en Imputacion. Para factura REGistrada, debe existir un acta '
                     || mi_estado_encabezado;
                  seguimiento(p_resp);
                  p_procesado := false;
               elsif mi_acta_numero = -1 and mi_estado_encabezado in ('PAG','DIS') then --El acta no ha sido creada, se procede a crearla 
                  -- Inicio registro acta
                  mi_acta_numero := pk_secuencial.fn_traer_consecutivo( 'OPGET', 'ACTA_LEGAL_ID', '0000', '000' ) + 1;
                  p_resp := 'OPGET: Consecutivo acta legal: ' || mi_acta_numero;
                  seguimiento(p_resp);
                  if mi_acta_numero > 0 then --el acta aún no ha sido creada.
                     mi_valor_pagado := fn_traer_valor_referencia_pago(p_nro_referencia_pago => p_nro_referencia_pago);
                     if nvl(mi_valor_pagado,0) > 0 then
                        --si el acta se crea correctamente mi_num_resp=1 
                        mi_estado_acta := 'RE';
                        mi_num_resp := fn_crear_acta(
                           un_documento      => mi_acta_numero,
                           un_tipo           => mi_tipo_acta,
                           una_fecha         => mi_rec_pago.fecha_autorizacion,
                           un_estado         => mi_estado_acta,
                           una_unidad        => 'FINANCIERO',
                           un_numero_externo => to_char(p_nro_referencia_pago),
                           una_observacion   => 'PAGADO PORTAL REF. PAGO: ' || to_char(p_nro_referencia_pago),
                           un_usuario        => p_usuario,
                           un_valor          => mi_valor_pagado
                        );
                        --Una vez creada el acta mi_num_resp = 1, se crea el documento y detalle del mismo
                        if mi_num_resp = 1 then                           
                           commit;
                           p_resp :=  'OPGET: Acta guardada '||mi_acta_numero;
                           seguimiento(p_resp);
                           p_procesado := true;
                        end if;
                        --Se crea el documento y detalle documento del acta
                     else
                        p_resp := 'OPGET: El valor de la referencia de pago debe ser mayor a cero (0) para la referencia de pago '
                                 || p_nro_referencia_pago;
                        seguimiento(p_resp);                                 
                        p_procesado := false;
                     end if; --if nvl(mi_valor_pagado,0) > 0 then
                  else
                     p_resp := 'OPGET: No es posible obtener el secuencial (ACTA_LEGAL_ID) para generar el acta '
                              || p_nro_referencia_pago;
                     seguimiento(p_resp);
                     p_procesado := false;
                  end if; --if mi_acta_numero is not null then
               elsif mi_acta_numero > -1 then
                  p_procesado := true;
               end if; --if fn_existe_acta(p_nro_referencia_pago) = false then
               p_resp := 'OPGET: Acta número '||mi_acta_numero;
               seguimiento(p_resp);
               if p_procesado = true and nvl(mi_acta_numero,-1) > -1
                  and mi_estado_encabezado in ('PAG','DIS') then --Se procede a registar los documentos
                  pr_registrar_documento(
                     p_acta_numero         => mi_acta_numero,
                     p_acta_tipo           => mi_tipo_acta,
                     p_estado              => mi_estado_acta,
                     p_nro_referencia_pago => p_nro_referencia_pago,
                     p_rec_pago            => mi_rec_pago,
                     p_usuario             => p_usuario,
                     p_resp                => p_resp,
                     p_procesado           => p_procesado
                  );
                  p_resp := 'OPGET: Documento(s) creado(s) ... inicio registro para legalización' || p_resp ;
                  seguimiento(p_resp);
                  if p_procesado = true then
                     --Contabilizar y actualiza sisla
                     p_resp := '';
                     pr_ingreso_imputacion(
                        p_nro_referencia_pago => p_nro_referencia_pago,
                        p_usuario             => p_usuario,
                        p_resp                => p_resp,
                        p_procesado           => p_procesado
                     );
                     p_resp := 'OPGET: Resultado imputación->REGistro. '||p_resp;
                     seguimiento(p_resp);
                     if p_procesado = true then
                        --Actualiza encabezado y guarda o rechaza actualizaciones de acuerdo al resultado en p_procesado
                        mi_estado_encabezado := 'REG';
                        pr_actualizar_encabezado(
                           p_nro_referencia_pago => p_nro_referencia_pago,
                           p_nuevo_estado        => mi_estado_encabezado, --Registro Limay
                           p_resp                => p_resp,
                           p_procesado           => p_procesado
                        );
                     else
                        p_resp := 'OPGET: Reversado proceso registro';
                        seguimiento(p_resp);
                        rollback;
                     end if; --if p_procesado = true then
                  else
                     p_resp := 'OPGET: Reversado proceso registro';
                     seguimiento(p_resp);
                     rollback;
                  end if; --if p_procesado = true then contabiliza
               elsif p_procesado = true and nvl(mi_acta_numero,-1) > -1 
                  and mi_estado_encabezado = 'REG' then
                  p_resp := 'OPGET: El acta y el ingreso fueron generados previo al proceso actual';
                  seguimiento(p_resp);
                  p_procesado := true;
               else
                  p_resp := 'OPGET: Revise que el acta se encuentre creada';
                  seguimiento(p_resp);
               end if;  --if mi_num_resp = 1 and nvl(mi_acta_numero,-1) > -1 and mi_estado_encabezado = 'PAG' 

               --Se procede a legalizar
               if p_procesado = true and nvl(mi_acta_numero,-1) > -1 and mi_estado_encabezado = 'REG'  then
                  pr_legalizar_financiero (
                  p_nro_referencia_pago => p_nro_referencia_pago,
                  p_resp                => p_resp,
                  p_procesado           => p_procesado
                  );    
                  dbms_output.put_line(p_resp);
               end if; --if p_procesado = true and nvl(mi_acta_numero,-1) > -1    and mi_estado_encabezado = 'REG'  then
               if p_procesado = true and mi_estado_encabezado = 'RE' then
                  --Actualiza encabezado y guarda o rechaza actualizaciones de acuerdo al resultado en p_procesado
                  pr_actualizar_encabezado(
                     p_nro_referencia_pago => p_nro_referencia_pago,
                     p_nuevo_estado        => 'IMP', --Registro Limay y Sisla
                     p_resp                => p_resp,
                     p_procesado           => p_procesado
                  );
               else
                  p_resp := 'OPGET: Reversando legalización';
                  seguimiento(p_resp);
                  p_procesado := false;
                  rollback;
               end if;
            else
               p_resp := 'OPGET: No hay registros de pago para referencia ' || p_nro_referencia_pago;
               seguimiento(p_resp);
               p_procesado := false;
            end if; --if mi_rec_pago is null then
         end if; --if mi_estado_encabezado not in ('PAG','REG') then
      else
         p_resp := 'OPGET: No existe el concepto para capita ó intereses ';
         seguimiento(p_resp);
      end if; --if mi_concepto_capital is null or mi_concepto_interes is null THEN
   exception
      when others then
         p_procesado := false;
         p_resp := 'OPGET: Fin imputacion con referencia: ' || p_nro_referencia_pago||'. Error:'||sqlerrm;
         seguimiento(p_resp);
   end pr_procesar_imputacion;


   procedure pr_registrar_documento (
      p_acta_numero         varchar2, --ogt_documento.numero%type,
      p_acta_tipo           varchar2, --ogt_documento.tipo%type,
      p_estado              varchar2,
      p_nro_referencia_pago sl_pcp_pago.nro_referencia_pago%type,
      p_rec_pago            type_rec_pago,
      p_usuario             varchar2,
      p_resp                out varchar2,
      p_procesado           out boolean
   ) as
      mi_rec_cuenta_cobro   type_rec_cuenta_cobro;
      mi_cur_cuentas_cobro  sys_refcursor;
      mi_numero_documento   varchar2(30);
      mi_tipo_documento     varchar2(3) := 'XYZ';
      mi_entidad            usuarios_compania.codigo_compania%type := 206;
      mi_id_tercero_destino number;
      mi_id_tercero_origen  number(20);
      mi_id_tercero_tac     number;
      mi_nit_origen         varchar2(20);
      mi_centro_costo       varchar2(30);
      mi_vigencia           number;
      mi_ingreso            number;
      --mi_estado_documento   varchar2(2) := 'AP';
      mi_bin_tipo_cuenta    varchar2(3) := 'FD';
      mi_unte_codigo        varchar2(10) := 'FINANCIERO';
      mi_cuba_numero        varchar2(12) := '482800043630';
      mi_tipo_soporte       varchar2(3) := 'NCR';
      mi_id_cuenta_cobro10  varchar2(15);  --Se recorta a 10 caracateres si es mayor
   begin
      --Si no encuentra la entidad
      if mi_entidad is null then
         p_resp := 'OPGET:RD: Entidad sin valor';
         seguimiento(p_resp);
         p_procesado := false;
      else
         mi_id_tercero_destino := pk_sit_infentidades.sit_fn_id_entidad(
            mi_entidad,
            sysdate
         );
         if mi_id_tercero_destino is null then
            p_resp := ' entidad destino no encontrada';
            seguimiento(p_resp);
         else
            p_procesado := true;
         end if;
      end if;

      select extract(year from sysdate)
        into mi_vigencia
        from dual;

      pr_traer_cuentas_cobro(
         p_nro_referencia_pago => p_nro_referencia_pago,
         p_resp                => p_resp,
         p_ref_cursor          => mi_cur_cuentas_cobro
      );
      if p_resp is not null then
         p_resp := 'OPGET:RD:No encuentra cuentas de cobro de referencia'|| p_nro_referencia_pago;
         seguimiento(p_resp);
         p_procesado := false;
      else
         p_resp := 'OPGET:RD:Cuentas de cobro cargadas de referencia'|| p_nro_referencia_pago;
         seguimiento(p_resp);
      end if;

      if p_procesado = true then
         loop
            fetch mi_cur_cuentas_cobro into mi_rec_cuenta_cobro;
            exit when mi_cur_cuentas_cobro%notfound;
            p_resp := 'OPGET:RD:ID Cuenta cobro= ' || mi_rec_cuenta_cobro.id;
            seguimiento(p_resp);
            sl_id_tercero_y_centro_costo(
               mi_rec_cuenta_cobro.codigo_entidad,
               mi_id_tercero_tac,
               mi_nit_origen,
               mi_centro_costo,
               p_resp
            );
            if mi_id_tercero_tac is null
               or mi_centro_costo is null or mi_nit_origen is null then
               p_procesado := false;
               p_resp := 'OPGET:RD:No encuentra tercero tac de la id_cuenta_cobro '
                         || mi_rec_cuenta_cobro.id;
               seguimiento(p_resp);
            else
               mi_id_tercero_origen := pk_sit_infbasica.sit_fn_get_id('NIT',mi_nit_origen,sysdate);
               if mi_id_tercero_origen is null then
                  p_procesado := false;
                  p_resp := 'OPGET:RD:No encuentra tercero origen de la cuenta_cobro '
                        || mi_rec_cuenta_cobro.id;
                  seguimiento(p_resp);      
               end if;
            end if;
            mi_numero_documento := pk_secuencial.fn_traer_consecutivo(
               'OPGET', 'DOC_NUM', '2002', '000' ) + 1;
            --Crea documento
            if mi_numero_documento is null then
               p_resp := 'OPGET:RD:No fue posible obtener el consecutivo (DOC_NUM) para registrar documento '
                        || mi_rec_cuenta_cobro.id;
               seguimiento(p_resp);   
               p_procesado := false;
               exit;
            else
               begin
                  insert into ogt_documento (
                     numero,
                     tipo,
                     estado,
                     fecha,
                     fecha_emision_titulo,
                     ter_id_receptor,
                     unte_codigo,
                     bin_tipo_cuenta,
                     bin_tipo_titulo,
                     cuba_numero,
                     usuario_elaboro,
                     usuario_reviso,
                     numero_soporte,
                     tipo_soporte,
                     fecha_compra_titulo,
                     fecha_soporte,
                     numero_timbre,
                     numero_legal,
                     tipo_legal
                  ) values ( mi_numero_documento,
                             mi_tipo_documento,
                             p_estado,
                             sysdate,trunc(sysdate,'mm'),
                             p_rec_pago.id_banco,
                             mi_unte_codigo,
                             mi_bin_tipo_cuenta,
                             null,
                             mi_cuba_numero,
                             p_usuario,
                             p_usuario,
                             p_acta_numero,
                             mi_tipo_soporte,
                             p_rec_pago.fecha_autorizacion,
                             p_rec_pago.fecha_autorizacion,
                             mi_vigencia,
                             p_acta_numero,
                             p_acta_tipo );
                  ogt_pk_ingreso.pr_insertar_tercero(p_rec_pago.id_banco);
                  p_procesado := true;
               exception
                  when others then
                     p_resp :='OPGET:RD:No ingresó documento para cuenta de cobro:'
                               || mi_rec_cuenta_cobro.id_cuenta_cobro|| '. '|| sqlerrm;
                     seguimiento(p_resp);
                     p_procesado := false;
                     exit;
               end;
            end if; --if mi_numero_documento is null then

            --Inserción en la tabla detalle documento
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
               begin
                  --Registra capital e intereses
                  pr_registrar_detalle_docum(
                     p_id_cuenta_cobro         => mi_rec_cuenta_cobro.id,
                     p_valor_capital           => mi_rec_cuenta_cobro.valor_capital,
                     p_valor_interes           => mi_rec_cuenta_cobro.valor_intereses,
                     p_doc_numero              => mi_numero_documento,
                     p_doc_tipo                => mi_tipo_documento,
                     p_unte_codigo             => mi_unte_codigo,
                     p_ter_id_origen           => mi_id_tercero_origen,
                     p_centro_costo            => mi_centro_costo,
                     p_ter_id_destino          => mi_id_tercero_destino,
                     p_ter_id_recaudador       => p_rec_pago.id_banco,
                     p_ter_id_entidad_origen   => null,
                     p_tipo_cuenta             => mi_bin_tipo_cuenta,
                     p_cuba_numero             => mi_cuba_numero,
                     p_vigencia_ingreso        => mi_vigencia,
                     p_info_numero             => p_nro_referencia_pago,
                     p_fecha_recaudo           => p_rec_pago.fecha_autorizacion,
                     p_codigo_interno          => mi_rec_cuenta_cobro.id_cuenta_cobro,
                     p_valor_base_impuestos    => null,
                     p_unidad_ejecutora_origen => null,
                     p_porcentaje              => 0,
                     p_numero_sisla            => mi_id_cuenta_cobro10,
                     p_estado_sisla            => 'PL', --por legalizar,
                     p_acta_tipo               => p_acta_tipo, --10
                     p_acta_numero             => p_acta_numero,
                     p_resp                    => p_resp,
                     p_procesado               => p_procesado
                  );
                  if p_procesado = false then
                     p_resp := 'OPGET:RD:Fallido ingreso ocumento';
                     seguimiento(p_resp);
                     exit;
                  end if;
               exception
                  when others then
                     p_resp := 'OPGET:RD:Fallido detalle del documento para cuenta de cobro:'
                               || mi_rec_cuenta_cobro.id_cuenta_cobro
                               || '. '
                               || sqlerrm;
                     seguimiento(p_resp);
                     p_procesado := false;
                     exit;
               end;
            else
               exit;
            end if;  --if p_procesado = true then
         end loop;
      end if;
      --cierro el cursor
      close mi_cur_cuentas_cobro;
   end pr_registrar_documento;


--Registra capital e intereses
   procedure pr_registrar_detalle_docum (
      p_id_cuenta_cobro         sl_pcp_cuenta_cobro.id%type,
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
   ) as
      p_code_id             number;
      mi_rec_liquidacion    type_rec_liquidacion;
      mi_cur_liquidacion    sys_refcursor;
      mi_id_ingreso_capital number;
      mi_id_ingreso_interes number;
      mi_det_pen_num        number;
      mi_situacion_fondos   varchar2(1) := 'S';
      mi_unidad_ejecutora   varchar2(2) := '01';
      mi_id_tercero          sl_relacion_terceros.id_tercero%type; 
   begin
      mi_unidad_ejecutora := '01'; --pk_permisos_entidad_unieje.fn_leer_unieje_actual('OPGET');
      if p_valor_capital <= 0 then
         p_resp := 'OPGET:RDD:No hay capital a registrar cuenta de cobro '|| p_id_cuenta_cobro;
         seguimiento(p_resp);
      else
         --********************************
         --Inicio inserción capital
         --********************************
         insert into ogt_detalle_documento (
            cote_id,
            valor,
            ter_id_destino,
            doc_numero,
            doc_tipo,
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
         ) values ( mi_concepto_capital,
                    p_valor_capital,
                    p_ter_id_destino,
                    p_doc_numero,
                    p_doc_tipo,
                    p_ter_id_origen,
                    p_ter_id_recaudador,
                    null,
                    p_vigencia_ingreso,
                    p_info_numero,
                    p_fecha_recaudo,
                    p_id_cuenta_cobro,
                    null,
                    null,
                    0,
                    p_centro_costo,
                    p_codigo_interno,
                    'PL' --por legalizar
                     );
         --********************************
         --Inicio inserción Intereses
         --********************************
         --Registro intereses intereses
         if p_valor_interes > 0 then
            --Recaudo de intereses
            insert into ogt_detalle_documento (
               cote_id,
               valor,
               ter_id_destino,
               doc_numero,
               doc_tipo,
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
            ) values ( mi_concepto_interes,
                        p_valor_interes,
                        p_ter_id_destino,
                        p_doc_numero,
                        p_doc_tipo,
                        p_ter_id_origen,
                        null,
                        null,
                        p_vigencia_ingreso,
                        p_info_numero,
                        p_fecha_recaudo,
                        p_id_cuenta_cobro,
                        null,
                        null,
                        0,
                        p_centro_costo,
                        p_codigo_interno,
                        'PL' --por legalizar
                        );
            /*--Legalizacion de intereses
            insert into ogt_detalle_documento (
               cote_id,
               valor,
               ter_id_destino,
               doc_numero,
               doc_tipo,
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
            ) values ( mi_concepto_causa_interes,
                        p_valor_interes,
                        p_ter_id_destino,
                        p_doc_numero,
                        p_doc_tipo,
                        p_ter_id_origen,
                        null,
                        null,
                        p_vigencia_ingreso,
                        p_info_numero,
                        p_fecha_recaudo,
                        p_id_cuenta_cobro,
                        null,
                        null,
                        0,
                        p_centro_costo,
                        p_codigo_interno,
                        'PL' --por legalizar
                        );            */
            --insertar los id de los terceros en la tabla de terceros de ingresos
            if ( p_ter_id_origen is not null ) then
               ogt_pk_ingreso.pr_insertar_tercero(p_ter_id_origen);
            end if;
            if ( p_ter_id_destino is not null ) then
               ogt_pk_ingreso.pr_insertar_tercero(p_ter_id_destino);
            end if;   
         end if; --if mi_rec_liquidacion.valor_interes > 0 then
      end if; --if p_valor_capital <= 0 then
      --ref_liquidaciones retorna las liquidaciones asociadas a una cuentas de cobro
      --para ingresar los detalles del pensionado ogt_detalle_pensionado
      pr_traer_liquidaciones(
         p_id_det_cuenta_cobro => p_id_cuenta_cobro,
         p_resp                => p_resp,
         p_ref_cursor          => mi_cur_liquidacion
      );
      if mi_cur_liquidacion is null then
         p_resp := 'OPGET:RDD No encuentra liquidaciones de la cuenta de cobro ' || p_codigo_interno;
         seguimiento(p_resp);
         p_procesado := false;
      else
         --Ingresa información detallada del pensionado
         begin
            loop
               fetch mi_cur_liquidacion into mi_rec_liquidacion;
               exit when mi_cur_liquidacion%notfound;
               mi_id_ingreso_capital := null;
               mi_id_ingreso_interes := null;
               --crear el ingreso del capital registrado
               mi_id_ingreso_capital := ogt_pk_ingreso.fn_crear(
                  una_vigencia            => p_vigencia_ingreso,
                  una_fecha_legalizacion  => sysdate,
                  una_fecha_consignacion  => sysdate,
                  un_concepto             => mi_concepto_capital,
                  un_soporte              => p_doc_numero,
                  un_tipo_soporte         => p_doc_tipo,
                  una_unidad              => p_unte_codigo,
                  un_tercero_origen       => p_ter_id_origen, 
                  un_tercero_destino      => p_ter_id_destino,  
                  una_cuenta_bancaria     => p_cuba_numero,
                  un_tipo_cuenta_bancaria => p_tipo_cuenta,
                  una_sucursal            => null,
                  una_entidad_financiera  => p_ter_id_recaudador,
                  un_valor                => mi_rec_liquidacion.valor_capital,
                  un_estado               => 'EL',
                  un_tpo_doc_legaliza     => p_acta_tipo,
                  un_nro_doc_legaliza     => p_acta_numero,
                  una_situacion_fondos    => mi_situacion_fondos,
                  una_unidad_ejecutora    => mi_unidad_ejecutora,
                  una_entidad_pptal       => null,
                  una_forma_recaudo       => 'E',
                  un_reconocimiento       => 0
               ); 
               if mi_id_ingreso_capital is null then
                  p_resp := 'OPGET:RDD:No registra ingreso de la cuenta de cobro '|| p_id_cuenta_cobro;
                  seguimiento(p_resp);
                  p_procesado := false; --No continua, el ingreso debe ser garantizado
               else
                  begin
                     select id_tercero
                     into mi_id_tercero
                     from SL_RELACION_TERCEROS
                     where id_sisla = mi_rec_liquidacion.interno_persona;  --in (16791,47125)
                  exception
                     when others then
                        p_procesado := false;
                        p_resp := 'Error buscando terceros '||sqlerrm;
                        seguimiento (p_resp);
                  end;
                  if p_procesado = false then --Encontro el tercero de trc desde id_tercero de sisla
                     exit;
                  else
                     --Registro detalle pensionado capital
                     insert into ogt_detalle_pensionado (
                        doc_numero,
                        doc_tipo,
                        id_ingreso,
                        tercero_origen,
                        tercero_pensionado,
                        cote_id,
                        valor
                     ) values ( p_doc_numero,
                              p_doc_tipo,
                              mi_id_ingreso_capital,
                              p_ter_id_origen,
                              mi_id_tercero,
                              mi_concepto_capital,
                              mi_rec_liquidacion.valor_capital );
                     if nvl(mi_rec_liquidacion.valor_interes ,0)>0 then
                        --crear el ingreso de interes registrado
                        mi_id_ingreso_interes := ogt_pk_ingreso.fn_crear(
                           una_vigencia            => p_vigencia_ingreso,
                           una_fecha_legalizacion  => sysdate,
                           una_fecha_consignacion  => sysdate,
                           un_concepto             => mi_concepto_interes,
                           un_soporte              => p_doc_numero,
                           un_tipo_soporte         => p_doc_tipo,
                           una_unidad              => p_unte_codigo,
                           un_tercero_origen       => p_ter_id_origen, 
                           un_tercero_destino      => p_ter_id_destino,
                           una_cuenta_bancaria     => p_cuba_numero,
                           un_tipo_cuenta_bancaria => p_tipo_cuenta,
                           una_sucursal            => null,
                           una_entidad_financiera  => p_ter_id_recaudador,
                           un_valor                => mi_rec_liquidacion.valor_interes,
                           un_estado               => 'EL',
                           un_tpo_doc_legaliza     => p_acta_tipo,
                           un_nro_doc_legaliza     => p_acta_numero,
                           una_situacion_fondos    => mi_situacion_fondos,
                           una_unidad_ejecutora    => mi_unidad_ejecutora,
                           una_entidad_pptal       => null,
                           una_forma_recaudo       => 'E',
                           un_reconocimiento       => 0
                        );
                        if mi_id_ingreso_interes is null then
                           p_resp := 'OPGET:RDD:No registrar ingreso de la cuenta de cobro '
                                    || p_id_cuenta_cobro;
                           seguimiento(p_resp);
                           p_procesado := false;
                        else
                           insert into ogt_detalle_pensionado (
                              --id,
                              doc_numero,
                              doc_tipo,
                              id_ingreso,
                              tercero_origen,
                              tercero_pensionado,
                              cote_id,
                              valor
                           ) values ( --mi_det_pen_num,
                              p_doc_numero,
                              p_doc_tipo,
                              mi_id_ingreso_interes,
                              p_ter_id_origen,
                              mi_id_tercero,
                              mi_concepto_interes,
                              mi_rec_liquidacion.valor_interes );
                        end if; --if mi_id_ingreso_interes is null then
                        --Crear causacion interes
                        mi_id_ingreso_interes := ogt_pk_ingreso.fn_crear(
                           una_vigencia            => p_vigencia_ingreso,
                           una_fecha_legalizacion  => sysdate,
                           una_fecha_consignacion  => sysdate,
                           un_concepto             => mi_concepto_causa_interes,
                           un_soporte              => p_doc_numero,
                           un_tipo_soporte         => p_doc_tipo,
                           una_unidad              => p_unte_codigo,
                           un_tercero_origen       => p_ter_id_origen, 
                           un_tercero_destino      => p_ter_id_destino,
                           una_cuenta_bancaria     => p_cuba_numero,
                           un_tipo_cuenta_bancaria => p_tipo_cuenta,
                           una_sucursal            => null,
                           una_entidad_financiera  => p_ter_id_recaudador,
                           un_valor                => mi_rec_liquidacion.valor_interes,
                           un_estado               => 'EL',
                           un_tpo_doc_legaliza     => p_acta_tipo,
                           un_nro_doc_legaliza     => p_acta_numero,
                           una_situacion_fondos    => mi_situacion_fondos,
                           una_unidad_ejecutora    => mi_unidad_ejecutora,
                           una_entidad_pptal       => null,
                           una_forma_recaudo       => 'E',
                           un_reconocimiento       => 0
                        );
                        if mi_id_ingreso_interes is null then
                           p_resp := 'OPGET:RDD:No registrar causacion interes de la cuenta de cobro '
                                    || p_id_cuenta_cobro;
                           seguimiento(p_resp);
                           p_procesado := false;
                        else
                           insert into ogt_detalle_pensionado (
                              --id,
                              doc_numero,
                              doc_tipo,
                              id_ingreso,
                              tercero_origen,
                              tercero_pensionado,
                              cote_id,
                              valor
                           ) values ( --mi_det_pen_num,
                              p_doc_numero,
                              p_doc_tipo,
                              mi_id_ingreso_interes,
                              p_ter_id_origen,
                              mi_id_tercero,
                              mi_concepto_causa_interes,
                              mi_rec_liquidacion.valor_interes );
                        end if; --if mi_id_cusacuib_interes is null then                        
                     end if; --if nvl(mi_rec_liquidacion.valor_interes ,0)>0 then
                  end if; --if p_procesado = false then --Encontro el tercero de trc desde id_tercero de sisla
               end if; --if mi_id_ingreso_capital is null then
            end loop;
            p_procesado := true;
         exception
            when others then
               p_resp := 'OPGET:RDD:Error ingresando detalle pensionado: ' || sqlerrm;
               seguimiento(p_resp);
               p_procesado := false;
         end;
      end if; --if p_resp is not null then
   end pr_registrar_detalle_docum;

   --Ingresa la información en tablas que se  pueden visualizar en la forma ogt_ingreso
   procedure pr_ingreso_imputacion (
      p_nro_referencia_pago sl_pcp_pago.nro_referencia_pago%type,
      p_usuario             varchar2,
      p_resp                out varchar2,
      p_procesado           out boolean
   ) as

      ogt_ingresos_rec  ogt_ingreso%rowtype;
      cursor cursor_ingresos (
         pc_nro_referencia_pago sl_pcp_pago.nro_referencia_pago%type
      ) is
      select ogt_ingreso.*
        from ogt_ingreso
      --where id = 608377
       where doc_numero||'-'|| doc_tipo in (
         select distinct doc_numero||'-'|| doc_tipo
           from ogt_detalle_documento 
               --where doc_numero in ('55502','54861') --'55503'
          where doc_numero|| '-'||doc_tipo in 
            (select numero|| '-'|| tipo
              from ogt_documento
             where numero_legal in (
               select numero
                 from ogt_documento
                where tipo = 'ALE'
                  --and estado='RE'
                  and unte_codigo = 'FINANCIERO'
                  --and numero in ( 55502, 55503,  54861 )
                  and numero_externo = p_nro_referencia_pago
            )  and tipo = 'XYZ'
         )  and doc_tipo = 'XYZ'
                           --and estado = 'RE'
      ) order by id desc;

      mi_tipo_operacion number;
   begin
      p_procesado :=true;
      open cursor_ingresos(pc_nro_referencia_pago => p_nro_referencia_pago);
      loop
         fetch cursor_ingresos into ogt_ingresos_rec;
         exit when cursor_ingresos%notfound;
         --Prepara la información para contabilización
         begin
            mi_tipo_operacion := ogt_pk_ingreso.ogt_fn_tipo_operacion(
               un_ingreso          => ogt_ingresos_rec.id,
               un_tipo_transaccion => 'SISTEMA FINANCIERO');
         exception
            when others then
               p_resp := 'OPGET:RI:Verifique ogt_pk_ingreso.ogt_fn_tipo_operacion ' || sqlerrm;
               seguimiento(p_resp);
               p_procesado := false;
               exit;
         end;
      end loop;
      if p_procesado is null then
         p_procesado := true;
      end if;
   exception
      when others then
         p_resp := 'OPGET:RI:Verifique pr_ingreso_imputacion ' || sqlerrm;
         seguimiento(p_resp);
         p_procesado := false;
   end pr_ingreso_imputacion;

   procedure pr_legalizar_financiero (
      p_nro_referencia_pago sl_pcp_pago.nro_referencia_pago%type,
      p_resp                out varchar2,
      p_procesado           out boolean
      ) is

      id_transaccion    pls_integer :=0;
      mi_numero_acta    ogt_documento.numero%type;
      mi_msg            Varchar2(500);
      mi_tipo_acta      ogt_documento.tipo%TYPE := 'ALE';
      mi_usuario        varchar2(30);
      mi_codigo_res     varchar2(30);
      mi_unidad_ejecutora_limay  ogt_ingreso.unidad_ejecutora_limay%type;

      cursor c_ingreso IS 
         select id, ing_id, entidad_pptal from   
         ogt_ingreso 
         where num_doc_legalizacion = mi_numero_acta;


   begin
      p_resp := 'OPGET:LEG:Inicio legalización referencia: ' || p_nro_referencia_pago || '.';
      seguimiento(p_resp);
      p_procesado := TRUE;
      mi_usuario := user;
      begin
         --Obtengo el número de acta
         select numero
         into mi_numero_acta
         from ogt_documento
         where tipo = mi_tipo_acta  --'ALE'
            and estado = 'RE'
            and unte_codigo = 'FINANCIERO'
            and numero_externo = p_nro_referencia_pago;
      exception
         when no_data_found then
            p_resp := 'OPGET:LF:No existe acta para referencia: ' || p_nro_referencia_pago || '.';
            seguimiento(p_resp);
            p_procesado := FALSE;
         when too_many_rows then
            p_resp := 'OPGET:LF:Más de un acta para referencia' || p_nro_referencia_pago || '.';
            seguimiento(p_resp);
            p_procesado := FALSE;  
      end;    

      if p_procesado = TRUE then

         -- Legalizar los ingresos seleccionados
         for mi_ingreso IN c_ingreso  loop
            id_transaccion := ogt_pk_ingreso.ogt_fn_Legalizar(mi_ingreso.id);
            if nvl(id_transaccion,0) = 0 then
               rollback;
               p_resp := 'OGT:LEG:Legalización FALLIDA ingreso '||mi_ingreso.id||'.';
               p_procesado := FALSE;
               exit;
            else
               p_resp := 'OGT:LEG:Legalización EXITOSA ingreso: '||mi_ingreso.id||'. Transaccion '||id_transaccion;
               p_procesado := true;
               --asigno unidad ejecutora limay
               begin
                  select resultado
                  into mi_unidad_ejecutora_limay
                  from bintablas
                  where grupo = 'OPGET'
                  and nombre = 'LIMAY_INGRESO_PORTAL'
                  and argumento ='CENTRO CONTABLE';
                 -- mi_unidad_ejecutora_limay  := '02';
               exception
                  when others then
                     p_resp := 'Verifique que exista y sea unico el CENTRO CONTABLE en el grupo de OPGET nombre LIMAY_INGRESO_PORTAL';
                     p_procesado:= false;
               end;
               if p_procesado = true then
                  update ogt_ingreso
                     set unidad_ejecutora_limay = mi_unidad_ejecutora_limay
                  where id = mi_ingreso.id;
                  p_resp := fn_actualiza_ejecutora(
                     mi_ingreso.entidad_pptal, 
                     'OPGET', 
                     id_transaccion, 
                     mi_unidad_ejecutora_limay);
                  if p_resp = 'Operacion Exitosa!' then
                     p_resp := 'OGT:LEG:Actualiza Ejecutora: '||p_resp ;
                     p_procesado := true;
                  else
                     p_resp := 'OGT:LEG:No fue posible actualizar la unidad ejecutora';
                     p_procesado := false;
                  end if;
               end if;
            end if;            
            seguimiento (p_resp);
         end loop;

         if p_procesado = TRUE then
            commit;
         else
            rollback;
         end if;

         if p_procesado = TRUE then
            mi_codigo_res := null;
            update ogt_documento
               set estado='AP',usuario_reviso=mi_usuario
            where numero=mi_numero_acta
               and tipo=mi_tipo_acta;
            pk_sl_interfaz_opget_cp.pr_actualiza_recaudo_pcp (p_referencia_pago     => p_nro_referencia_pago,
                                     p_acta_legalizacion    => mi_numero_acta,
                                     p_fecha_legalizacion   => sysdate,
                                     p_cod_rta_proceso      => mi_codigo_res,
                                     p_des_rta_proceso      => p_resp
                                    );
            seguimiento(p_resp);
            if mi_codigo_res = 'ERROR' then
               p_resp := 'OGT:LEG:Recaudo FALLIDO en SISLA para referencia: ' || p_nro_referencia_pago || '. ' || p_resp;
               p_procesado := FALSE;
               rollback;
            else
               p_resp := 'OGT:LEG:Recaudo EXITOSO para referencia: ' || p_nro_referencia_pago || '. '|| p_resp;
               p_procesado := TRUE;
               commit;
            end if;
            seguimiento(p_resp);
         else
            rollback;
         end if;
      end if; --if p_procesado = TRUE THEN
   exception
   when OTHERS then
      rollback;
      p_resp := 'OGT:LEG:Proceso detenido: '||sqlerrm;
      seguimiento(p_resp);
      p_procesado := FALSE;

   end pr_legalizar_financiero; 

   procedure pr_traer_encabezados (
      p_estado             sl_pcp_encabezado.estado%type,      
      p_nro_referencia     sl_pcp_pago.nro_referencia_pago%type default null,
      p_resp               out varchar2,
      p_ref_cursor         out sys_refcursor
   ) as
   begin
      open p_ref_cursor for select id,
                                   nro_referencia_pago,
                                   estado,
                                   centro_costo
                             from sl_pcp_encabezado
                             where estado in ('PAG','REG')
                             and  extract(year from fecha_sistema) > 2025
                             and nro_referencia_pago = nvl(p_nro_referencia,nro_referencia_pago); 
   exception
      when OTHERS then  
         p_resp := 'Error al obtener los encabezados: ' || sqlerrm;
   end pr_traer_encabezados;

   --Trae el valor pagado
   function fn_traer_valor_referencia_pago (
      p_nro_referencia_pago sl_pcp_pago.nro_referencia_pago%type
   ) return number as
      v_valor_referencia number;
   begin
      select valor_referencia
        into v_valor_referencia
        from sl_pcp_encabezado
       where nro_referencia_pago = p_nro_referencia_pago
         and rownum = 1;
      return v_valor_referencia;
   exception
      when others then
         return 0;
   end fn_traer_valor_referencia_pago;

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
      p_id_det_cuenta_cobro sl_pcp_liquidaciones.id_det_cuenta_cobro%type,
      p_resp                out varchar2,
      p_ref_cursor          out sys_refcursor
   ) as
   begin
      open p_ref_cursor for select id,
                                   id_det_cuenta_cobro,
                                   id_factura,
                                   interno_persona,
                                   fecha_periodo_ini,
                                   fecha_periodo_fin,
                                   saldo_factura,
                                   valor_capital,
                                   valor_interes,
                                   fecha_sistema,
                                   estado
                                                    from sl_pcp_liquidaciones
                             where id_det_cuenta_cobro = p_id_det_cuenta_cobro;
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
      un_documento      varchar2,   --ogt_documento.numero%type,
      un_tipo           varchar2,   --ogt_documento.tipo%type,
      una_fecha         date,       --ogt_documento.fecha%type :=SYSDATE,
      un_estado         varchar2,   --ogt_documento.estado%type,
      una_unidad        varchar2,   --ogt_documento.unte_codigo%type,
      un_numero_externo varchar2,  --ogt_documento.numero_externo%type
      una_observacion   varchar2,   --ogt_documento.observaciones%type,
      un_usuario        varchar2,   --ogt_documento.usuario_elaboro%type,
      un_valor          number      --ogt_documento.valor%type
   ) return number is
   begin
      insert into ogt_documento (
         numero,
         tipo,
         estado,
         fecha,
         unte_codigo,
         numero_externo,
         observaciones,
         usuario_elaboro,
         usuario_reviso
      ) values ( un_documento,
                 un_tipo,
                 un_estado,
                 una_fecha,
                 una_unidad,
                 un_numero_externo,
                 una_observacion,
                 un_usuario,
                 un_usuario );
      return 1;
   exception
      when others then
         return 0;
   end fn_crear_acta;

   procedure pr_actualizar_encabezado (
      p_nro_referencia_pago sl_pcp_encabezado.nro_referencia_pago%type,
      p_nuevo_estado        varchar2,
      p_resp                out varchar2,
      p_procesado           in out boolean
   ) as
   begin
      --Registro las cuentas de cobro en opget creando correctamente el acta
      update sl_pcp_encabezado
         set
         estado = p_nuevo_estado
       where nro_referencia_pago = p_nro_referencia_pago;
      commit;
    /* elsif
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
      end if;*/
   exception
      when others then
         p_procesado := false;
         p_resp := dbms_utility.format_error_stack;
   end pr_actualizar_encabezado;

-- Para obtenere el id del tercero y centro de costo
-- para el obtener el tercero o pensionado usar sl_relacion_persona
   procedure sl_id_tercero_y_centro_costo (
      p_codigo_compa      sl_relacion_tac.codigo_compa%type,
      p_id_tercero_origen out number,
      p_nit_origen        out varchar2,
      p_centro_costo      out varchar2,
      p_resp              out varchar2
   ) as
   begin
      select id_limay,
             nit,
             id_sisla
        into
         p_id_tercero_origen,
         p_nit_origen,
         p_centro_costo
        from sl_relacion_tac
       where codigo_compa = p_codigo_compa;

   exception
      when others then
         p_resp := p_resp
                   || chr(10)
                   || ' Error al buscar el tercero y centro de costo '
                   || sqlerrm;
   end sl_id_tercero_y_centro_costo;

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

   --Trae el número del acta registrada para la referencia de pago ó -1 por defecto
   procedure pr_traer_numero_acta (
      un_tipo              varchar2,   --ogt_documento.tipo%type,
      una_unidad           varchar2,   --ogt_documento.unte_codigo%type,
      un_numero_externo    ogt_documento.numero_externo%type,
      un_estado            out ogt_documento.estado%type,
      un_acta_numero       out ogt_documento.numero%type
   )  as
      mi_numero number;
   begin
      select estado, numero
        into un_estado, un_acta_numero
        from ogt_documento
       where tipo = un_tipo
         and unte_codigo = una_unidad
         and numero_externo = un_numero_externo;
   exception
      when no_data_found then
         un_acta_numero := -1;
      when too_many_rows then
         un_acta_numero := -2;   
      when others then
         un_acta_numero := -1;
   end pr_traer_numero_acta;

   --Trae el estado del encabezado
   procedure pr_traer_estado_encabezado (
      p_nro_referencia_pago sl_pcp_encabezado.nro_referencia_pago%type,
      p_resp                out varchar2
   ) is
   begin
      select estado
        into p_resp
        from sl_pcp_encabezado
       where nro_referencia_pago = p_nro_referencia_pago;

   exception
      when others then
         p_resp := sqlerrm;
   end pr_traer_estado_encabezado;

end pk_ogt_imputacion;