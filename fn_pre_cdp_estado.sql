   function fn_pre_cdp_estado (
      una_vigencia             number,
      un_codigo_compania       varchar2,
      un_codigo_unidad         varchar2,
      un_numero_disponibilidad number,
      una_fecha_corte          date,
      un_rubro_interno         number
   ) return char is
      mi_valor_cdp_parciales  number;
      mi_valor_anulado        number;
      mi_valor_registro       number;
      mi_valor_cdp_autorizado number;
      mi_valor_rp_parciales   number;
      mi_saldo                number;
      mi_valor_modificacion   number;
      mi_estado               varchar2(30);
      mi_descripcion_estado   bintablas.resultado%type;
      mi_valor_ajustes        number;
      mi_valor                number;

            -- Identifica si CDP fue anulado

      cursor cur_cdp_anulado is
      select nvl(
         sum(nvl(
            valor,
            0
         )),
         0
      )
        from pr_anulaciones
       where vigencia = :una_vigencia
         and codigo_compania = :un_codigo_compania
         and codigo_unidad_ejecutora = :un_codigo_unidad
         and documento_anulado = 'CDP'
         and numero_documento_anulado = :un_numero_disponibilidad
         and fecha_registro <= :una_fecha_corte;
--cur_cdp_anulado 0
        -- Total RP de la disponibilidad que no han sido anulados en el mes

      cursor cur_total_registros is
      select nvl(
         sum(nvl(
            pr_registro_disponibilidad.valor,
            0
         )),
         0
      )
        from pr_registro_presupuestal,
             pr_registro_disponibilidad
       where not exists (
         select numero_documento_anulado
           from pr_anulaciones anu
          where anu.vigencia = pr_registro_presupuestal.vigencia
            and anu.codigo_unidad_ejecutora = pr_registro_presupuestal.codigo_unidad_ejecutora
            and anu.codigo_compania = pr_registro_presupuestal.codigo_compania
            and anu.numero_documento_anulado = pr_registro_presupuestal.numero_registro
            and anu.documento_anulado = 'REGISTRO'
            and anu.fecha_registro <= :una_fecha_corte
      )
         and pr_registro_presupuestal.vigencia = pr_registro_disponibilidad.vigencia
         and pr_registro_presupuestal.codigo_compania = pr_registro_disponibilidad.codigo_compania
         and pr_registro_presupuestal.codigo_unidad_ejecutora = pr_registro_disponibilidad.codigo_unidad_ejecutora
         and pr_registro_presupuestal.numero_registro = pr_registro_disponibilidad.numero_registro
         and pr_registro_presupuestal.numero_disponibilidad = pr_registro_disponibilidad.numero_disponibilidad
         and pr_registro_presupuestal.vigencia = :una_vigencia
         and pr_registro_presupuestal.codigo_compania = :un_codigo_compania
         and pr_registro_presupuestal.codigo_unidad_ejecutora = :un_codigo_unidad
         and pr_registro_presupuestal.numero_disponibilidad = :un_numero_disponibilidad
         and pr_registro_presupuestal.fecha_registro <= :una_fecha_corte
         and pr_registro_disponibilidad.rubro_interno = :un_rubro_interno;
--cur_tota_registros 11972019



        -- Total de anulaciones parciales del cdp

      cursor cur_cdp_anulacion_parcial is
      select nvl(
         sum(nvl(
            pr_cdp_anulados.valor_anulado,
            0
         )),
         0
      )
        from pr_cdp_anulados
       where vigencia = :una_vigencia
         and codigo_compania = :un_codigo_compania
         and codigo_unidad_ejecutora = :un_codigo_unidad
         and numero_disponibilidad = :un_numero_disponibilidad
         and rubro_interno = :un_rubro_interno
         and fecha_anulacion <= :una_fecha_corte;
 --cur_cdp_anulacion_parcial 935000


        -- Total de anulaciones parciales del cdp autorizadas

      cursor cur_cdp_anulacion_parcial_au is
      select nvl(
         sum(nvl(
            valor_anulado,
            0
         )),
         0
      )
        from pr_cdp_anulados_autorizados
       where vigencia = :una_vigencia
         and codigo_compania = :un_codigo_compania
         and codigo_unidad_ejecutora = :un_codigo_unidad
         and numero_disponibilidad = :un_numero_disponibilidad
         and rubro_interno = :un_rubro_interno
         and fecha_anulacion <= :una_fecha_corte;
-- cursor cur_cdp_anulacion_parcial_au is 0

        -- Total de anulaciones parciales de RP

      cursor cur_total_rp_anulacion_parcial is
      select nvl(
         sum(nvl(
            valor_anulado,
            0
         )),
         0
      )
        from pr_rp_anulados
       where vigencia = :una_vigencia
         and codigo_compania = :un_codigo_compania
         and codigo_unidad_ejecutora = :un_codigo_unidad
         and numero_disponibilidad = :un_numero_disponibilidad
         and rubro_interno = :un_rubro_interno
         and fecha_anulacion <= :una_fecha_corte;
--cur_total_rp_anulacion_parcial 935000

        -- Total de Modificaciones Presupuestales

      cursor cur_total_modificacion is
      select nvl(
         sum(nvl(
            valor_contracredito,
            0
         )),
         0
      )
        from pr_modificacion_presupuestal,
             pr_documentos
       where ( pr_modificacion_presupuestal.tipo_movimiento = pr_documentos.tipo_movimiento
         and pr_modificacion_presupuestal.documentos_numero = pr_documentos.numero
         and pr_modificacion_presupuestal.tipo_documento = pr_documentos.tipo_documento )
         and pr_modificacion_presupuestal.vigencia = :una_vigencia
         and pr_modificacion_presupuestal.codigo_compania = :un_codigo_compania
         and pr_modificacion_presupuestal.codigo_unidad_ejecutora = :un_codigo_unidad
         and pr_modificacion_presupuestal.numero_disponibilidad = :un_numero_disponibilidad
         and pr_modificacion_presupuestal.rubro_interno = :un_rubro_interno
         and pr_documentos.fecha_registro <= :una_fecha_corte;
--cur_total_modificacion 0


      cursor cur_ajustes is
      select nvl(
         sum(nvl(
            pr_reintegro_ajustes_rubro.valor,
            0
         )),
         0
      )
        from pr_reintegro_ajustes,
             pr_reintegro_ajustes_rubro
       where pr_reintegro_ajustes.vigencia = pr_reintegro_ajustes_rubro.vigencia
         and pr_reintegro_ajustes.codigo_compania = pr_reintegro_ajustes_rubro.codigo_compania
         and pr_reintegro_ajustes.codigo_unidad_ejecutora = pr_reintegro_ajustes_rubro.codigo_unidad_ejecutora
         and pr_reintegro_ajustes.numero_orden = pr_reintegro_ajustes_rubro.numero_orden
         and pr_reintegro_ajustes.consecutivo_orden = pr_reintegro_ajustes_rubro.consecutivo_orden
         and pr_reintegro_ajustes.numero_disponibilidad = pr_reintegro_ajustes_rubro.numero_disponibilidad
         and pr_reintegro_ajustes.numero_registro = pr_reintegro_ajustes_rubro.numero_registro
         and pr_reintegro_ajustes.consecutivo_ajuste = pr_reintegro_ajustes_rubro.consecutivo_ajuste
         and pr_reintegro_ajustes.vigencia = :una_vigencia
         and pr_reintegro_ajustes.codigo_compania = :un_codigo_compania
         and pr_reintegro_ajustes.codigo_unidad_ejecutora = :un_codigo_unidad
         and pr_reintegro_ajustes.numero_disponibilidad = :un_numero_disponibilidad
         and
                          --pr_reintegro_ajustes.cerrado <> '0' AND  Se cambia <> 0 por = 0 12/12/2002
          pr_reintegro_ajustes.cerrado = '0'
         and pr_reintegro_ajustes.tipo_movimiento = 'AJUSTE'
         and pr_reintegro_ajustes.fecha_registro <= :una_fecha_corte
         and pr_reintegro_ajustes_rubro.rubro_interno = :un_rubro_interno;


   begin
      mi_valor_cdp_parciales := null;
      mi_valor_anulado := null;
      mi_valor_registro := null;
      mi_valor_cdp_autorizado := null;
      mi_valor_rp_parciales := null;
      mi_saldo := null;
      mi_valor_modificacion := null;
      mi_estado := null;
      mi_valor_ajustes := null;


            -- Determina si fue anulado en el mes

      open cur_cdp_anulado;
      fetch cur_cdp_anulado into mi_valor_anulado;
      close cur_cdp_anulado;
      if nvl(mi_valor_anulado,0) = 0 then



                -- Calcula el Valor Total de Registros Acumulados

         open cur_total_registros;
         fetch cur_total_registros into mi_valor_registro;
         close cur_total_registros;

               -- Liberaciones Parciales de CDP Acumuladas

         open cur_cdp_anulacion_parcial;
         fetch cur_cdp_anulacion_parcial into mi_valor_cdp_parciales;
         close cur_cdp_anulacion_parcial;

                -- Liberaciones Parciales Autorizadas

         open cur_cdp_anulacion_parcial_au;
         fetch cur_cdp_anulacion_parcial_au into mi_valor_cdp_autorizado;
         close cur_cdp_anulacion_parcial_au;


                -- Liberciones Parciales de Rp

         open cur_total_rp_anulacion_parcial;
         fetch cur_total_rp_anulacion_parcial into mi_valor_rp_parciales;
         close cur_total_rp_anulacion_parcial;

                -- Ajustes

         open cur_ajustes;
         fetch cur_ajustes into mi_valor_ajustes;
         close cur_ajustes;      


                --mi_saldo := NVL(:valor,0) - NVL(mi_valor_cdp_autorizado,0) - NVL(mi_valor_cdp_parciales,0) - (NVL(mi_valor_registro,0) -  NVL(mi_valor_rp_parciales,0));


         mi_valor := 11972019
         select  pk_pr_disponibilidades.fn_pre_cdp_valor(
            :una_vigencia,
            :un_codigo_compania,
            :un_codigo_unidad,
            :un_numero_disponibilidad,
            :un_rubro_interno
         ) from dual


--mi_valor_anulado 0
--mi_valor_registro 11972019
--mi_valor_cdp_parciales 935000
--mi_valor_cdp_autorizado is 0
--mi_valor_rp_parciales 935000
--cur_total_modificacion 0
--mi_valor_ajustes 0   
--mi_valor := 11972019
mi_saldo = 11972019 - 0 - 935000 - 11972019 - 935000 - 0

                --Se incluyen los ajustes 12/12/2002
         mi_saldo := nvl(mi_valor,0) 
         - nvl(mi_valor_cdp_autorizado,0) 
         - nvl(mi_valor_cdp_parciales,0) 
         - ( nvl(mi_valor_registro,0) 
         - nvl(mi_valor_rp_parciales,0) ) 
         - nvl(mi_valor_ajustes, 0 );


         if nvl(mi_saldo,0) = 0 then
            mi_estado := 'AGOTADO';
         elsif nvl(mi_saldo,0) < nvl(mi_valor,0) then
            mi_estado := 'VIGENTE-AGOTADO';
         elsif nvl(mi_saldo,0) = nvl( mi_valor,) then
            mi_estado := 'VIGENTE';
         end if;

      else
         mi_estado := 'ANULADO';
      end if;

      if mi_valor = fn_pre_cdp_anulaciones(
         una_vigencia,
         un_codigo_compania,
         un_codigo_unidad,
         un_numero_disponibilidad,
         una_fecha_corte,
         un_rubro_interno
      ) then
         mi_estado := 'ANULADO';
      end if;

      begin
         select resultado
           into mi_descripcion_estado
           from bintablas
          where grupo = 'PREDIS'
            and nombre = 'ESTADO_CDP'
            and argumento = mi_estado
            and vig_inicial <= to_date('01-01-' || una_vigencia,
        'DD-MM-YYYY')
            and ( vig_final >= to_date('01-01-' || una_vigencia,
        'DD-MM-YYYY')
             or vig_final is null );
      exception
         when others then
            mi_descripcion_estado := '';
      end;

      return nvl(
         mi_descripcion_estado,
         ''
      );
   end;