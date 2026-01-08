--select * from shd.binconsecutivo where vigencia=2023 order by 1;
select GRUPO, NOMBRE, VIGENCIA, CODIGO_COMPANIA, CODIGO_UNIDAD_EJECUTORA,SECUENCIAL
from shd.binconsecutivo where vigencia=2025  and GRUPO in ('OPGET','PREDIS','RH')
--and secuencial <> 0
UNION
select GRUPO, NOMBRE, VIGENCIA, CODIGO_COMPANIA, CODIGO_UNIDAD_EJECUTORA,SECUENCIAL
from shd.binconsecutivo where vigencia=2026 and GRUPO in ('OPGET','PREDIS','RH')

order by grupo, nombre, vigencia, codigo_compania, codigo_unidad_ejecutora, secuencial  
--44 ok

select * from shd.bintablas where NOMBRE LIKE '%VIGE%' AND resultado in ('2025','2026')
and  grupo in ('OPGET','PREDIS','RH');
--2

select * from binconsecutivo where grupo ='PREDIS' and vigencia=2025;

select * 
from PR_VIGEJEC_ENTIDADES

--2. VERIFICAR

select distinct(grupo)
from binconsecutivo;




--