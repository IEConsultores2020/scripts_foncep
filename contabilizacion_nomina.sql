SELECT 
    SCOMPANIA              COMP,
    VIGENCIA               VIGE,
    GRUPO_RA               GRA,
    VIGENCIA_PRESUPUESTO   VPTO,
    UNIDAD_EJECUTORA       UE,
    ANO_PAC                APAC,
    NTIPO_NOMINA           TNOM,
    MES_PAC                MPAC,
    TIPO_COMPROMISO        TC,
    NUMERO_COMPROMISO      NC,
    CASE TIPO_RA
        WHEN '1' THEN
            '1 - NOMINA'
        WHEN '2' THEN
            '2 - SEGURIDAD SOCIAL'
        WHEN '3' THEN
            '3 - CESANTIAS'
        ELSE
            TIPO_RA
    END                    TIPO_DE_RA,
    NRO_RA                 NRA,
    DFECHA_INICIAL_PERIODO DFECINI,
    DFECHA_FINAL_PERIODO   DFECFIN,
    NRO_RA_OPGET           NRA_OGT,
    APROBACION             A,
    ACTUALIZADO_CONTAB     AC,
    GEN_CXP_OPGET          GCXP,
    CONTABILIZADO          CTDO,
    CONTABILIZAR           CTAR 
FROM
    --UPDATE
    RH_LM_RA --SET CONTABILIZADO = 'N'
WHERE
    SCOMPANIA = 206 --AND DFECHA_INICIAL_PERIODO = '01-SEP-24';
    AND EXTRACT(YEAR FROM DFECHA_INICIAL_PERIODO) = 2025
    AND EXTRACT(MONTH FROM DFECHA_INICIAL_PERIODO) = :MES
    AND NRO_RA=12
ORDER BY
    DFECHA_INICIAL_PERIODO DESC,
    TIPO_RA ASC;

-- AND NRO_RA = 37 --una_fecha_inicial;

--2025 | 1-NOM | 2-CES | 3-AP.SS
-- 01       1             2
-- 02       3             4
-- 03       5             6
-- 04       7             
-- 05     
-- 06
-- 07
-- 08
-- 09     
-- 10     
-- 11
-- 12

SELECT
    *
FROM --DELETE     --Reversar contabilizacion 2/2
    RH_LM_NOMINA_PROCESADA
WHERE
    DFECHA_INICIAL_PERIODO = '01-SEP-24';


/*SELECT
    DISTINCT SCONCEPTO,
    VARIABLE_VALOR,
    SUM(VALOR)     PERIODO*/
   SELECT *
    FROM
    --UPDATE 
    RH_T_LM_VALORES
        --SET STERCERO = 2319
    WHERE
        PERIODO = TO_DATE('20250331', 'YYYYMMDD')
        AND NTIPO_NOMINA = 1
        AND STIPOFUNCIONARIO = 'PLANTA'
        and nro_ra=12
        and nfuncionario = 649
        and sconcepto = 'PENSIONES'
        and stercero = 2324
     order by 1
 /*--AND SCONCEPTO LIKE '%INCAP%'
    GROUP BY
        SCONCEPTO,
        VARIABLE_VALOR
    ORDER BY
        SCONCEPTO*/
;

select * from RH_PERSONAS
where INTERNO_PERSONA in (250,579,589,592  );


select *
from ogt_anexo_nomina
where tipo_ra = 1 and unidad_ejecutora='01' and 
entidad = 206 and vigencia = 2025 and mes ='05'
and consecutivo= 12;

select *
from OGT_CENTRO_COSTOS
where tipo_ra = 1 and unidad_ejecutora='01' and 
entidad = 206 and vigencia = 2025 and mes ='05'
and consecutivo= 12;