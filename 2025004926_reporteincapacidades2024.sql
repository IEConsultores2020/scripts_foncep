select nn.descripcion TIPO_INCAPACIDAD, nv.justificacion,pp.tipo_documento, pp.primer_apellido, pp.segundo_apellido, pp.nombres, nv.numero_novedad NUMERO_OFICIO,nv.fecha_efectividad fecha_incapacidad ,dt.valor dias, dtn.valor FECHANOMINA
  from rh_tipos_acto_nove nn, rh_novedades nv, rh_personas pp, rh_detalle_novedad dt, rh_detalle_novedad dtn
 where nn.nombre like '%INCAPA%'
   and nn.codigo_hash <> 1206258708
   and nv.tipo_novedad = nn.codigo_tipo
   and nv.fecha_efectividad >= to_date('01/01/2024','dd/mm/yyyy')
   and nv.fecha_efectividad < to_date('01/01/2025','dd/mm/yyyy')
   and nv.funcionario = pp.interno_persona
   and dt.fecha_novedad = nv.fecha_novedad
   and dt.funcionario = nv.funcionario
   and dt.tipo_novedad = nv.tipo_novedad
   and dt.nombre_detalle = 'DIAS'
   and dtn.fecha_novedad = nv.fecha_novedad
   and dtn.funcionario = nv.funcionario
   and dtn.tipo_novedad = nv.tipo_novedad
   and dtn.nombre_detalle = 'FECHANOMINA'