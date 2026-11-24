/*
    El reporte de horas extras del trimestre de Julio a Septiembre de 2026 y el sistema esta presentando error y no genera el reporte.
*/

select *
from rh_personas
where numero_identificacion=79576915
;--int 605

select *
from rh_tipos_acto_nove
where nombre like '%EXTRA%'
;

select *
from rh_concepto
where codigo_hash in (442742312,4096477391)
;


select nfuncionario,dfechanovedad,
    dfechaefectiva,
    informativo, 
    RTRIM(SUBSTR(informativo,INSTR(informativo,'=<')+2),'>;') contrim,
    RTRIM(SUBSTR(informativo,INSTR(informativo,'=<')+2),'>;') sintrim,
    case 
        when INSTR(informativo,':') > 0 then 
            to_number(
                rtrim(substr(informativo,INSTR(informativo,'=<')+2,
                                INSTR(informativo,':')-INSTR(informativo,'=<')-2)))+
                round(TO_NUMBER(RTRIM(SUBSTR(informativo,INSTR(informativo,':')+1),'>;'))/60,2)
        else
          --to_number(RTRIM(SUBSTR(informativo,INSTR(informativo,'=<')+2),'>;'))
          case 
           when REGEXP_LIKE(
                RTRIM(SUBSTR(informativo,INSTR(informativo,'=<')+2),'>;')
                , '^-?[0-9]+([.,][0-9]+)?$') then 
                --to_number(RTRIM(SUBSTR(informativo,INSTR(informativo,'=<')+2),'>;'))
                to_number(RTRIM(SUBSTR(informativo,INSTR(informativo,'=<')+2),'>;'),
                  '999D99', 'NLS_NUMERIC_CHARACTERS = ''.,''')
           else 9999
           end 
    end as horas
from rh_historico_nomina
where --informativo like '%HORAS%' 
 nhash IN (3680102388,608470915,442742312,2379761472,4096477391,1304476015)
 and nfuncionario=605
and dfechaefectiva between 20260701 and 20260930

order by 6 desc,dfechanovedad desc
;
/*
442742312  HORAS EXTRAS DIURNAS
4096477391 HORAS EXTRAS NOCTURNAS
*/

select *
from rh_compensa_causados
where funcionario=605
and to_number(to_char(fecha_causacion, 'YYYYMMDD')) between 20260701 and 20260930
;

SELECT DISTINCT
PRIMER_APELLIDO||' '||SEGUNDO_APELLIDO||' '||NOMBRES "NOMBRES ",
NUMERO_IDENTIFICACION,
NFUNCIONARIO,
--ini 2026003429
--TO_NUMBER(RTRIM(SUBSTR(informativo,INSTR(informativo,'=<')+2),'>;')) horas,
    case 
        when INSTR(informativo,':') > 0 then 
           to_number(rtrim(substr(informativo,INSTR(informativo,'=<')+2,
                                INSTR(informativo,':')-INSTR(informativo,'=<')-2)))+
          round(TO_NUMBER(RTRIM(SUBSTR(informativo,INSTR(informativo,':')+1),'>;'))/60,2)
        else
          to_number(decode(INSTR(informativo,'=<'),0,0,TO_NUMBER(RTRIM(SUBSTR(informativo,INSTR(informativo,'=<')+2),'>;'))))
    end as horas,
--fin 2026003429
DFECHAEFECTIVA, 
RH_HISTORICO_NOMINA.NDCAMPO0,       
RH_HISTORICO_NOMINA.NHASH,
RH_CONCEPTO.DESCRIPCION,       
--NDCAMPO2,       
--NDCAMPO3,
--NOMBRE,
RH_POSICIONES.CODIGO_DEPENDENCIA,
--RH_NOVEDADES.FECHA_NOVEDAD,
CARGO,
CARGO_GRADO,
CARGO_NIVEL,
CARGO_FECHA_INICIAL,
RH_DEPENDENCIAS.DESCRIPCION,
rh_funcionario.personas_interno
FROM RH_HISTORICO_NOMINA,
     RH_CONCEPTO,
     RH_PERSONAS,
--     rh_novedades,
     RH_POSICIONES,
     RH_DEPENDENCIAS,
     RH_FUNCIONARIO
WHERE
--  RH_HISTORICO_NOMINA.nfuncionario IN ('574','202')
    RH_HISTORICO_NOMINA.NHASH IN (3680102388,608470915,442742312,2379761472,4096477391,1304476015)
and RH_HISTORICO_NOMINA.besdefinitivo = 1
and RH_HISTORICO_NOMINA.brechazado = 0 
AND RH_HISTORICO_NOMINA.NHASH = RH_CONCEPTO.CODIGO_HASH
--   AND RH_funcionario.personas_interno = RH_NOVEDADES.FUNCIONARIO
AND  RH_HISTORICO_NOMINA.NFUNCIONARIO = RH_PERSONAS.INTERNO_PERSONA
-- AND  rh_historico_nomina.NFUNCIONARIO = rh_posiciones.FUNCIONARIO (+)
and rh_posiciones.secuencia = pk_datos_nomina.buscarposicion (:P_FECHA_FIN, rh_historico_nomina.NFUNCIONARIO)
 AND RH_DEPENDENCIAS.CODIGO_DEPENDENCIA =  RH_POSICIONES.CODIGO_DEPENDENCIA
 AND (RH_POSICIONES.CODIGO_DEPENDENCIA between :P_DEP_INI and  :P_DEP_FIN or RH_POSICIONES.CODIGO_DEPENDENCIA between :P_DEP_fin and  :P_DEP_ini)
 AND  PERSONAS_INTERNO = INTERNO_PERSONA
  AND (TIPO_FUNCIONARIO between  :P_TIPO_FUN_INI and  :P_TIPO_FUN_FIN or TIPO_FUNCIONARIO between  :P_TIPO_FUN_fin and  :P_TIPO_FUN_ini)
 AND  DFECHAEFECTIVA >= TO_NUMBER(TO_CHAR(:P_FECHA_INI,'YYYYMMDD'),'99999999')  
 AND  DFECHAEFECTIVA <= TO_NUMBER(TO_CHAR(:P_FECHA_FIN,'YYYYMMDD'),'99999999')  
--AND RH_HISTORICO_NOMINA.NDCAMPO2 <> 0
order by rh_historico_nomina.dfechaefectiva