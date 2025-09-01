select *
from rh_personas
where NUMERO_IDENTIFICACION = 24182848  --int 509
--INTERNO_PERSONA = 45 --CC 40030681
/*  INT     CC
    509     24182848
    45      40030681
*/
;

select *
from RH_ACTOS_ADMINISTRATIVOS
where FUNCIONARIO = 218
and extract(year from  fecha_FINAL ) = 2025
and tipo_acto = 040
;

select *
from RH_CONCEPTO
where nombre like '%LIBRANZA%'  --929560918
;

select *
from RH_TIPOS_ACTO_NOVE
where nombre like '%LIBRANZA%'  --tipo 9010
;
/*
NOMBRE      TIPO    CODIGO_HASH
LIBRANZA    9010    726156787
*/

select NFUNCIONARIO, DFECHAEFECTIVA, NDCAMPO1 VALOR, NDCAMPO3 CODIGO_BENEFICIARIO
from rh_historico_nomina
where NFUNCIONARIO = 509
and nhash = 726156787
and dfecharegistro >= 20210207
and ndcampo3 = 2920
ORDER BY DFECHAEFECTIVA DESC