select *
  from ogt_tipo_transaccion --ogt_tipo_operacion
  where cltr_nombre = 'EGRESOS'
  and nombre like 'CAUSACION ORDENES DE PAGO';

select *
  from ogt_tipo_operacion
  where cltr_nombre = 'EGRESOS'
  and titr_nombre like 'CAUSACION ORDENES DE PAGO';
;

select id, descripcion, cote_id, fecha_inicial, fecha_final
from ogt_concepto_tesoreria
where descripcion  in ('CAUSACION PAGO SUBSIDIO PRACTICANTES',
                        'CAUSACION OTROS SERVICOS',
                        'CAUSACION MANTENIMIENTO MUEBLES ENSERES Y EQUIPO DE OFICINA')
    --id like '00-01-99%'
--like 'CAUSACION%MANTENIMIENTO%' --like 'CAUSACION%'
;

select id, descripcion, cote_id, fecha_inicial, fecha_final
from
--update 
    ogt_concepto_tesoreria
    set cote_id = '00-01-00-08-00-00-00' 
where descripcion  = 'CAUSACION PAGO SUBSIDIO PRACTICANTES'
and id = '00-01-99-08-00-00-00'
;
rollback
commit;

select * from (
SELECT id,
 LPAD(' ',3*LEVEL)||descripcion descripcion,
 fecha_inicial,fecha_final 
FROM ogt_concepto_tesoreria
CONNECT BY PRIOR  id = (SELECT id
   FROM ogt_concepto_tesoreria
   WHERE cote_id IS NULL
     AND ROWNUM = 1)
) S
where S.DESCRIPCION LIKE 'CAUSACION%'
     ;
 