select id_limay
        from sl_relacion_tac
       where codigo_compa = 107766;  --400293

select nit from sl_compania com where com.codigo_compania = 107766       
    

select id
  from shd_informacion_basica
 where shd_informacion_basica.ib_tipo_identificacion = nvl(
      :un_tipo_identificacion,
      shd_informacion_basica.ib_tipo_identificacion
   )
   and shd_informacion_basica.ib_codigo_identificacion = :una_identificacion
   and shd_informacion_basica.ib_fecha_inicial <= :una_fecha
   and ( shd_informacion_basica.ib_fecha_final >= :una_fecha
    or shd_informacion_basica.ib_fecha_final is null );
            --nit 890399011 31514
            ;

pk_sit_infentidades.sit_fn_infentidades(:ogt_detalle_documento.ter_id_entidad_origen,SYSDATE);
SELECT  shd_informacion_entidades.id,
            shd_informacion_entidades.ie_fecha_inicial,
            shd_informacion_entidades.ie_fecha_final,
            shd_informacion_entidades.ie_tipo,
            shd_informacion_entidades.ie_procedencia,
            shd_informacion_entidades.ie_sector,
            shd_informacion_entidades.ie_regimen_tributario,
            shd_informacion_entidades.ie_gran_contribuyente,
            shd_informacion_entidades.ie_autorretenedor,
            shd_informacion_entidades.ie_matricula_mercantil,
            shd_informacion_entidades.ie_fecha_matricula,
            shd_informacion_entidades.ie_filial_colombia,
            shd_informacion_entidades.ie_fecha_constitucion,
            shd_informacion_entidades.ie_sigla,
            shd_informacion_entidades.ie_codigo_superbancaria,
            shd_informacion_entidades.ie_otra_codificacion,
            shd_informacion_entidades.ie_representante_legal,
            shd_informacion_entidades.ie_identificacion_rl,
            shd_informacion_entidades.ie_procedencia_rl,
            shd_informacion_entidades.ie_delegado,
            shd_informacion_entidades.ie_identificacion_dl,
            shd_informacion_entidades.ie_procedencia_dl,
            shd_informacion_entidades.ie_ep_clase,
            shd_informacion_entidades.ie_ep_nivel,
            shd_informacion_entidades.ie_ep_sector,
            shd_informacion_entidades.ie_ep_tipo,
            shd_informacion_entidades.ie_otra_clasificacion,
            shd_informacion_entidades.ie_contaduria_gral
      FROM shd_informacion_entidades
      WHERE id = :un_id AND ie_fecha_inicial <= :una_fecha AND
      (ie_fecha_final >= :una_fecha OR ie_fecha_final IS NULL)            

      select * from sit_terceros