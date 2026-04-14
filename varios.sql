SELECT SECUENCIAL
FROM     BINCONSECUTIVO
WHERE   GRUPO = 'OPGET'
    AND NOMBRE = 'ACTA_LEGAL_ID'
    AND VIGENCIA = '0000'
    AND CODIGO_COMPANIA = '000'
    AND CODIGO_UNIDAD_EJECUTORA = '00'
    ;

    SELECT NUMERO FROM OGT_DOCUMENTO
    ORDER BY 1 DESC
    ;

SELECT *
FROM 
--UPDATE 
BINTABLAS
--SET RESULTADO='RptSvr_seul_asinst_2'
WHERE GRUPO in ('GENERAL')
AND NOMBRE='IDENTIFICACION'
--AND ARGUMENTO='REPORTSERVER'
AND VIG_INICIAL <= SYSDATE
AND (VIG_FINAL IS NULL OR VIG_FINAL >= SYSDATE)
;



select * from rh_maestro_personas
where nfuncionario in 
(select * --interno_persona, numero_identificacion, nombres, primer_apellido, segundo_apellido
 from rh_personas
--where nombres ='DIANA MARCELA' and primer_apellido='SANABRIA'
where numero_identificacion in (52116283)) --651, 652
--or interno_persona= 643   --  20730522
--649 --1030575813
;


SELECT *
FROM shd_informacion_entidades
      WHERE id = 51 AND ie_fecha_inicial <= SYSDATE AND
      (ie_fecha_final >= SYSDATE OR ie_fecha_final IS NULL);

select *
from bintablas
where grupo='OPGET'
AND ARGUMENTO = 'REPORTSERVER'
AND SYSDATE BETWEEN VIG_INICIAL AND NVL(VIG_FINAL,SYSDATE);
--'Parametros archivo favidi'


select *
from rh_personas
where interno_persona in (646,588) --20730522, 52876090
nombres like 'MARGARITA%' --numero_identificacion= 79693028
;

select *
from pr_rubro
where interno = 1547
;



select *
from rh_personas
where numero_identificacion in (51604666);
/*
JF 79355621 65 PUBLICO
SUESCA 52316271 595 PRIVADO
SANDOVAL 1049606827 607 PRIVADO
*/
;

select *
from rh_concepto
where nombre like '%EMBAR%'
;

select * 
from rh_historico_nomina
where dinicioperiodo = 20260301
and nhash in (561030782,2979462679,1190232691,3247840384)
and ncorrida = 1;


select *  --personas_interno
from rh_funcionario
where /*personas_interno=20
and */ codigo_fondo_pensiones <>61
and estado_funcionario =1
order by personas_interno asc
;



select TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS')  as fysdate from dual
;

select *
from pr_rubro