--Tomado de varios.sql linea 98

select SUM (APORTE_EMPLEADO)
from ogt_anexo_nomina
where vigencia = 2025
and consecutivo = 26
AND CODIGO_CENTRO_COSTOS IN ( 5, 1285, 1267)
;


select * --consecutivo, SUM (APORTE_EMPLEADO)
from ogt_anexo_nomina
where vigencia = 2025
and consecutivo between 24 and 28
AND CODIGO_CENTRO_COSTOS IN ( 5, 1285, 1267)
group by consecutivo
;