/*INSERT INTO rh_reportes_nomina (
    NFUNCIONARIO, NHASH, NTIPOCONCEPTO, NESNOVEDAD, BRECHAZADO,
    NRETROACTIVO, NCORRIDA_INTERNA, DFECHAREGISTRO, DFECHANOVEDAD,
    DFECHAEFECTIVA, DINICIOPERIODO, DFINALPERIODO, NCORRIDA,
    BESDEFINITIVO, SACTOADMI, NDCAMPO0, NDCAMPO3, NDCAMPO4,
    NDCAMPO6, NDCAMPO13, NDCAMPO14, USER_SESS
)
*/
create or replace view rh_tmp_rn as
SELECT 
    NFUNCIONARIO, NHASH, NTIPOCONCEPTO, NESNOVEDAD, BRECHAZADO,
    NRETROACTIVO, NCORRIDA_INTERNA, DFECHAREGISTRO, DFECHANOVEDAD,
    DFECHAEFECTIVA, DINICIOPERIODO, DFINALPERIODO, NCORRIDA,
    BESDEFINITIVO, SACTOADMI, NDCAMPO0, NDCAMPO3, NDCAMPO4,
    NDCAMPO6, NDCAMPO13, NDCAMPO14
FROM rh_historico_nomina
WHERE dInicioperiodo <= 20260131
  AND dFinalPeriodo  >= 20260101
  --si es tipo C
  AND ndCampo0 <> 0 
  AND (nesnovedad = 0 OR (nesnovedad = 1 AND nhash = 812839052))
  /*--Si tipo es diferente a C
  AND nesnovedad = 1 AND nhash IN ([una_cadena])  --*/
  ;

----
  --pr_leer_conceptos (mi_compania,'DED',mi_tipos_func,mi_fecha_inicial,mi_fecha_final,:b_nom_parafiscales.ntipo_nomina, mi_err);
  create or replace view rh_tmp_ded as
  SELECT 
    co_dv.nombre_corto,
    co_dv.devengado,
    hino_dv.nfuncionario,
    --'DED' 
    hino_dv.ndcampo3, RTRIM(LTRIM(hino_dv.sactoadmi)) sactoadmi, --*/
    hino_dv.ndcampo6,
    SUM(NVL(hino_dv.ndcampo0, 0)) AS valor
FROM 
    rh_tmp_rn hino_dv,
    rh_concepto co_dv,
    rh_funcionario
WHERE 
    hino_dv.nhash = co_dv.codigo_hash
    AND hino_dv.nfuncionario = personas_interno
    AND (
        (hino_dv.ntipoconcepto = 1 AND hino_dv.nretroactivo = (
            SELECT NVL(MIN(a.ndCampo0), 0)
            FROM rh_reportes_nomina a 
            WHERE a.nFuncionario = hino_dv.nFuncionario 
              AND a.nHash = 812839052 
              AND a.dInicioPeriodo <= 20260131
              AND a.dFinalPeriodo >= 20260101
        )) 
        OR hino_dv.ntipoconcepto <> 1
    )
    AND hino_dv.nesnovedad       = 0
    AND hino_dv.brechazado       = 0
    AND hino_dv.ncorrida_interna = 0 
    AND hino_dv.ndCampo0         <> 0
    AND hino_dv.ncorrida = 0
    AND hino_dv.dinicioperiodo  >= 20260101
    AND hino_dv.dfinalperiodo   <= 20260131
    /*--'DEV'
    AND co_dv.devengado = 'S' --*/
    --'DED'
    AND co_dv.devengado = 'N' --*/
    /*-- 'APO'
    AND co_dv.devengado = 'A' --*/
    AND tipo_funcionario > 0
   
GROUP BY 
    co_dv.nombre_corto,
    co_dv.devengado,
    hino_dv.nfuncionario,
    hino_dv.ndcampo6
    --'DED'
     , hino_dv.ndcampo3, RTRIM(LTRIM(hino_dv.sactoadmi)) --*/
     ;

select nombre_corto, sum(valor)
from rh_tmp_ded
group by nombre_corto     
;

select ded.nombre_corto, sum(ded.valor)
from rh_tmp_ded ded
group by ded.nombre_corto
;