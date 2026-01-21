SELECT 
   -- SCOMPANIA              COMP,  VIGENCIA               VIGE,
   -- GRUPO_RA               GRA,
    VIGENCIA_PRESUPUESTO   VPTO,
   -- UNIDAD_EJECUTORA       UE,
   -- ANO_PAC                APAC,
    NTIPO_NOMINA           TNOM,
   -- MES_PAC                MPAC,
    --DFECHA_INICIAL_PERIODO  FECHA_INI,
    TIPO_COMPROMISO        TC,
    NUMERO_COMPROMISO      NC,
    NRO_RA                 NRA,
    NRO_RA_OPGET           NRA_OGT,
    CASE TIPO_RA
        WHEN '1' THEN
            '1 - NOMINA'
        WHEN '2' THEN
            '2 - SEGURIDAD SOCIAL'
        WHEN '3' THEN
            '3 - CESANTIAS'
        WHEN '4' THEN
            '4 - CESANTIAS FONDOS'
        ELSE
            TIPO_RA
    END                    TIPO_DE_RA ,
    DFECHA_INICIAL_PERIODO DFECINI,
    DFECHA_FINAL_PERIODO   DFECFIN,
    APROBACION             A,
    ACTUALIZADO_CONTAB     AC,
    GEN_CXP_OPGET          GCXP,
    CONTABILIZADO          CTDO,
    CONTABILIZAR           CTAR 
   -- UPDATE
FROM
    RH_LM_RA -- SET /*ACTUALIZADO_CONTAB='N', */ GEN_CXP_OPGET = 'N' /*, CONTABILIZADO = 'N'*/, CONTABILIZAR = 'S'
WHERE
    SCOMPANIA = 206 --AND DFECHA_INICIAL_PERIODO = '01-DEC-24';
    AND EXTRACT(YEAR FROM DFECHA_INICIAL_PERIODO) = 2025
     AND EXTRACT(MONTH FROM DFECHA_INICIAL_PERIODO) = :MES
   -- AND NRO_RA=12
ORDER BY
    DFECHA_INICIAL_PERIODO DESC,
    TIPO_RA ASC;

delete --select * from 
RH_LM_RA
where nro_ra IN (29,30) and ANO_PAC is null and vigencia_presupuesto=2025

commit;
rollback;
/*
-- TIPO MES  NRO_RA       AP  AC   GCXP  CDO CTAR
                          S   N     N     N    S 
    SS   01   10     A    S   S     S     N    S
    SS   01   2
    SS   02   11     A    S   S     S     S    N
    SS   02   4
    SS   05   13     A    S   S     S     S    N
*/
                AND     aprobacion           =  'S'
                AND     actualizado_contab   =  'S'
                AND     gen_cxp_opget        =  'S'
                AND     contabilizado        =  'N'
                AND     contabilizar         =  'S'

SELECT
    *
FROM --DELETE     --Reversar contabilizacion 2/2
    RH_LM_NOMINA_PROCESADA
WHERE
    --EXTRACT(YEAR FROM DFECHA_INICIAL_PERIODO) = 2025;
    DFECHA_INICIAL_PERIODO = '01-JUN-20';


SELECT sum(valor)
FROM
    --UPDATE 
    RH_T_LM_VALORES
WHERE
    EXTRACT(YEAR FROM PERIODO) = 2025 AND
    STIPOFUNCIONARIO = 'PLANTA' AND
    sconcepto like 'APORTE%' AND 
    NRO_RA in (28,29)
GROUP BY PERIODO 
    -- SCONCEPTO,    VARIABLE_VALOR */
ORDER BY  1
;

SELECT *
FROM
    --UPDATE 
    RH_T_LM_VALORES
WHERE
    EXTRACT(YEAR FROM PERIODO) = 2025 AND
    STIPOFUNCIONARIO = 'PLANTA' AND
    --sconcepto like 'APORTE%' AND 
    NRO_RA = 20
GROUP BY PERIODO 
    -- SCONCEPTO,    VARIABLE_VALOR */
ORDER BY  1
;




select * from RH_PERSONAS
where NUMERO_IDENTIFICACION IN (40030681,1018432331) 
--INTERNO_PERSONA in (250,579,589,592  );
;

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



SELECT
  SCOMPANIA              ENTIDAD,
  SSISTEMA               SISTEMA,
  TRANSACCION            TXN,
  NTIPO_NOMINA           TIPO_NOM,
  DFECHA_INICIAL_PERIODO FECHA_INI,
  DFECHA_FINAL_PERIODO   FECHA_FIN,
  DFECHA_PROCESO         FECHA_PROCESO,
  NTRANSACCION           NRO_TXN,
  NRO_RA,
  GRUPO_RA               GRUPORA
FROM -- DELETE     --Reversar contabilizacion 2/2
  RH_LM_NOMINA_PROCESADA
WHERE
  DFECHA_INICIAL_PERIODO = TO_DATE('20250801' ,'YYYYMMDD') 
  and NTIPO_NOMINA = 1
 -- AND NTRANSACCION IN (477,478);
--ENE 477 478
--FEB 479 480
  COMMIT;


 ---valida para contabilizar

  	   --SELECT  *     FROM    (
            SELECT TIPO_RA, GRUPO_RA, aprobacion, actualizado_contab, gen_cxp_opget , contabilizado, contabilizar 
                FROM                rh_lm_ra
                WHERE   scompania            =  206
                AND     dfecha_final_periodo =  '31-JAN-25' --una_fecha_final
                --Inicio RQ2014-1117-225   10/12/2014
                AND    grupo_ra in (5) --mi_grupo_ra)
                --Fin RQ2014-1117-225
                AND     aprobacion           =  'S'
                AND     actualizado_contab   =  'N'
                AND     gen_cxp_opget        =  'N'
                AND     contabilizado        =  'N'
                AND     contabilizar         =  'S'
                ;
        --       );  

--Segunda validación de contabilización
       SELECT DISTINCT SCONCEPTO -- COUNT(0) INTO mi_nro_registros
       FROM    rh_t_lm_valores a, rh_lm_ra b, rh_lm_ra_transaccion c
       WHERE   b.tipo_ra              = c.ra
       AND     b.ntipo_nomina         = a.ntipo_nomina
       AND     b.dfecha_final_periodo = a.periodo
       AND     a.sdevengado           = c.transaccion
       -- Inicio RQ2014-1117-225 10/12/2014
       AND instr('PLANTA' /*mi_tipo_func*/,a.stipofuncionario) > 0
       -- Fin RQ2014-1117
       AND     b.scompania            = 206 --una_compania
       AND     b.dfecha_final_periodo = '30/JUN/25' --TO_DATE('01-01-2025','DD-MM-YYYY') --una_fecha_final
       /*AND     b.aprobacion           = 'S'
       AND     b.contabilizado        = 'N' 
       AND     b.contabilizar         = 'S'*/
       ;

       select distinct periodo, a.ntipo_nomina, NRO_RA
       from rh_t_lm_valores a
       where a.ntipo_nomina = 2        and 
       extract(year from periodo)  = 2025
       order by periodo desc
      -- and a.periodo = '31/03/25'
       ;

SELECT *
FROM RH_T_LM_VALORES
WHERE SCONCEPTO = 'CEMBARGO'
AND PERIODO ='30/JUN/2025'
ORDER BY 1
;

SELECT
    *
FROM 
--UPDATE 
    RH_LM_NOMINA_PROCESADA
--SET DFECHA_FINAL_PERIODO = TO_DATE('30/06/2020','DD/MM/YYYY')
WHERE
    /*DFECHA_INICIAL_PERIODO = '01-JUN-2020'
AND*/ DFECHA_FINAL_PERIODO = '30-JUN-2025';

COMMIT;
