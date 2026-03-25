--ingresos
insert into pr_rubro (vigencia,	interno,	interno_nivel1,	interno_nivel2,	interno_nivel3,	interno_nivel4,	interno_nivel5,
	interno_nivel6,	interno_nivel7,	interno_nivel8,	descripcion,	tipo_plan,	administracion,	inversion,	programacion,
    codigo_tipo,	codigo_componente,	codigo_objeto,	codigo_fuente,	codigo_det_fuente) 
select vigencia,	interno,	interno_nivel1,	interno_nivel2,	interno_nivel3,	interno_nivel4,	interno_nivel5,
	interno_nivel6,	interno_nivel7,	interno_nivel8,	descripcion,	tipo_plan,	administracion,	inversion,	programacion,
    codigo_tipo,	codigo_componente,	codigo_objeto,	codigo_fuente,	codigo_det_fuente
     from pr_rubros_no2026 where interno in (1551,1734,1566,1561,1563,1564,1724,1557,1559,1722,1727,1599,1728)

;

rollback