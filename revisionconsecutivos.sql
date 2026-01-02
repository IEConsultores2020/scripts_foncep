--select * from shd.binconsecutivo where vigencia=2023 order by 1;
select GRUPO, NOMBRE, VIGENCIA, CODIGO_COMPANIA, CODIGO_UNIDAD_EJECUTORA,SECUENCIAL
from shd.binconsecutivo where vigencia=2025  and GRUPO in ('OPGET','PREDIS','RH')
UNION
select GRUPO, NOMBRE, VIGENCIA, CODIGO_COMPANIA, CODIGO_UNIDAD_EJECUTORA,SECUENCIAL
from shd.binconsecutivo where vigencia=2026 and GRUPO in ('OPGET','PREDIS','RH')
order by grupo, nombre, vigencia, codigo_compania, codigo_unidad_ejecutora, secuencial  
--44 ok

select * from shd.binconsecutivo where nombre in ('CTA_CBR_CP_2017','FACTURA_CP_2017') and vigencia in (2024,2025)
order by nombre;

select * from shd.bintablas where NOMBRE LIKE '%VIGE%' AND resultado in ('2025','2026')
and  grupo in ('OPGET','PREDIS','RH');

select * from shd.bintablas where NOMBRE LIKE '%VIGE%' AND resultado not in ('2025','2026')
and  grupo in ('OPGET','PREDIS','RH');

--2

select * from  shd.bintablas where NOMBRE LIKE '%VIGE%' AND VIG_FINAL IS NULL AND resultado='2024';


--Update bintablas set vig_final='31/12/2023' where NOMBRE LIKE '%VIGE%' AND VIG_FINAL IS NULL AND resultado='2023';
--Commit;

Update shd.bintablas set vig_final='31/12/2024' where NOMBRE LIKE '%VIGE%' AND VIG_FINAL IS NULL AND resultado='2024';
Commit;

SELECT * FROM cor.COR_SECUENCIA_CODDOC where vigencia=2024;

--Insert into  cor.COR_SECUENCIA_CODDOC
--SELECT  2024,EXTERNA_INTERNA, ENVIADA_RECIBIDA, 0
--FROM cor.COR_SECUENCIA_CODDOC where vigencia=2023;
--Commit;

Insert into  cor.COR_SECUENCIA_CODDOC
SELECT  2025,EXTERNA_INTERNA, ENVIADA_RECIBIDA, 0
FROM cor.COR_SECUENCIA_CODDOC where vigencia=2024;
Commit;

SELECT  * FROM cor.COR_SECUENCIA where vigencia=2024;

--Insert into  cor.COR_SECUENCIA
--SELECT  dependencia_origen,externa_interna,2024,0
--FROM cor.COR_SECUENCIA where vigencia=2023;
--Commit;

Insert into  cor.COR_SECUENCIA
SELECT  dependencia_origen,externa_interna,2025,0
FROM cor.COR_SECUENCIA where vigencia=2024;
Commit;

select * from cor_secuencia where vigencia=2025;


select *
from  BINTABLAS where grupo='PREDIS'
and argumento in ('VIG_EJEC','VIGENCIA_MODIFICACION','VIG_PROG','VIG_RESER') and vig_final='31/12/2025' order by 3,4;

select * from binconsecutivo where grupo ='PREDIS' and vigencia=2025;


SELECT * FROM PR.PR_VIGEJEC_ENTIDADES;

--Update PR.PR_VIGEJEC_ENTIDADES SET VIGENCIA_EJECUCION=2024, VIGENCIA_PROGRAMACION=2024, VIGENCIA_PLANTA=2024;
--Commit;

Update PR.PR_VIGEJEC_ENTIDADES SET VIGENCIA_EJECUCION=2025, VIGENCIA_PROGRAMACION=2025, VIGENCIA_PLANTA=2025;
Commit;


--2. VERIFICAR

select distinct(grupo)
from binconsecutivo;

select * from binconsecutivo
where grupo in ('PREDIS')
AND VIGENCIA IN (2025,2025,2023)
--AND SECUENCIAL > 0
ORDER BY  1,2;

select * from binconsecutivo;

select *
from rh_beneficiarios