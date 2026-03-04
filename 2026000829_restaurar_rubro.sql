select *
from pr_rubro where descripcion in (
  select *
  FROM pr_rubro WHERE interno IN 
                (select interno from pr_rubro where vigencia=2025
                  intersect
                  select interno from pr_rubro where vigencia=2026
                )  and vigencia=2025
  and vigencia=2026)
order by descripcion;


select '2025' vig, r25.* from pr_v_rubros r25 
where r25.vigencia=2025 and r25.descripcion='Servicios de organización y asistencia de ferias comerciales'
union
select '2026' vig, r26.* from pr_v_rubros r26 
where r26.vigencia=2026 and (r26.descripcion='Servicios de organización y asistencia de ferias comerciales'
or interno_rubro=1956)
;


select *
from PR_MODIFICACION_PRESUPUESTAL
where vigencia=2026
and documentos_numero='01679'
--Esta borrado, ver disponibilidad a la que le asigna 
--2-3-02-02-02-008-000-0085962 Servicios de organización y asistencia de ferias comerciales
--credito 73431334  total traslado
--credito del rubro seria 12.843.615

and rubro_interno in 
(
  select * from pr_v_rubros r26 
where r26.vigencia=2026 and r26.descripcion='Servicios de organización y asistencia de ferias comerciales'
);

select *
from pr_disponibilidad_rubro
where vigencia=2026
and numero_disponibilidad=214
;


update 
pr_modificacion_presupuestal 
set numero_disponibilidad=0
where vigencia=2026
and codigo_compania=206
and codigo_unidad_ejecutora='01'
and tipo_documento='04'
and documentos_numero='01679'
and rubro_interno=1844
and tipo_movimiento='TRASLADO'
and numero_disponibilidad=214
and fecha_registro=to_date('26/02/2026','dd/mm/yyyy')
and valor_credito=12843615
;

select *
from 
pr_apropiacion
valor_modificaciones
where vigencia = 2026
and codigo_compania = 206
and codigo_unidad_ejecutora='01'
and rubro_interno=1844;



commit;

--Se inserta el traslado manual
INSERT INTO pr_apropiacion
          (vigencia, codigo_compania, codigo_unidad_ejecutora, rubro_interno,
           valor, valor_rezago, valor_modificaciones)
           VALUES
          (2026, 206, '01', 1844,
           0,0,12843615);



select *
from pr_disponibilidad_rubro
where vigencia=2026
and numero_disponibilidad=214
and rubro_interno = 1844;


 UPDATE pr_apropiacion 
         SET valor_modificaciones = NVL(valor_modificaciones,0) + NVL(12843615,0)
         WHERE vigencia = 2026 AND 
               codigo_compania = 206 AND
               codigo_unidad_ejecutora = '01' AND
               rubro_interno = 1844;


commit;

--Pendiente modificaciones


select *
from pr_modificacion_presupuestal
where vigencia=2026
and codigo_compania=206
and codigo_unidad_ejecutora='01'
--and tipo_documento
and documentos_numero=1679
and valor_credito=254889717
;

select *
from pr_documentos
where vigencia=2026
and numero='01679'