--Rubros
select *
from pr_rubro
WHERE ltrim(trim(descripcion)) is null LIKE 'Serv%m%dico%'
and vigencia=2025;
--15

--UPDATE
OGT_DETALLE_ACTAS
SET DOC_ENTIDAD = 99  --VALOR ANTERIOR. 206
where tipo_documento = 'AR'
  AND VIGENCIA=2025
  AND UNIDAD_EJECUTORA='01'
  AND rubro_interno =1526
  AND ENTIDAD=206
  AND DOC_CONSECUTIVO IN (5)
  AND DOC_ENTIDAD = 206
;
commit;


--Solicitar al funcionario que realice el traslado
--Una vez guarda la información de traslado se procede a reversar la inactivación del reembolso.

UPDATE
OGT_DETALLE_ACTAS
SET DOC_ENTIDAD = 206  --VALOR ANTERIOR. 206
where tipo_documento = 'AR'
  AND VIGENCIA=2025
  AND UNIDAD_EJECUTORA='01'
  AND rubro_interno =1526
  AND ENTIDAD=206
  AND DOC_CONSECUTIVO IN (5)
  AND DOC_ENTIDAD = 99
;
commit;

