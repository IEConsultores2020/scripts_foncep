--MI DEDUCIDO
SELECT co_dv.nombre_corto,
       co_dv.devengado,
       hino_dv.nfuncionario,
       hino_dv.ndcampo3,
       RTRIM(LTRIM(hino_dv.sactoadmi)),
       hino_dv.ndcampo6,
       SUM((nvl(hino_dv.ndcampo0, 0))) valor
  FROM rh_historico_nomina /*rh_reportes_nomina*/ hino_dv, rh_concepto co_dv, rh_funcionario
 WHERE hino_dv.nhash = co_dv.codigo_hash
   AND hino_dv.nfuncionario = personas_interno
   AND ((hino_dv.ntipoconcepto IN (1) AND
       hino_dv.nretroactivo =
       (SELECT Nvl(MIN(a.ndCampo0), 0)
            FROM rh_historico_nomina /*rh_reportes_nomina*/ a
           WHERE a.nFuncionario = hino_dv.nFuncionario
             AND a.nHash = 812839052
             AND a.dInicioPeriodo <= to_number('20250131')
             AND a.dFinalPeriodo >= to_number('20250101')
             /*AND USER_SESS = USERENV('SESSIONID')*/ )) OR
       hino_dv.ntipoconcepto <> 1)
   AND hino_dv.nesnovedad = 0
   AND hino_dv.brechazado = 0
   AND hino_dv.ncorrida_interna = 0
   AND hino_dv.ndCampo0 <> 0
   AND hino_dv.ncorrida = 0
   --INI 2025002642 
   AND co_dv.nombre_corto not in 
   (SELECT stipo_funcionario
        FROM rh_lm_det_grp_funcionario
       WHERE scompania = 206 --una_compania
         AND sGrupo    IN ('SALUD','PENSION') --un_grupo
         AND sGtipo    = 'DESCUENTO'
         AND '31/JAN/2025' BETWEEN dfecha_inicio_vig AND dfecha_final_vig
         AND hino_dv.dinicioperiodo >= (SELECT TO_NUMBER(TO_CHAR(TO_DATE(RESULTADO,'mmddyyyy'),'yyyymmdd'))
                                        FROM BINTABLAS
                                        WHERE GRUPO='NOMINA'
                                        AND NOMBRE='VARIABLES_LIQUIDACION_FECHA'
                                        AND ARGUMENTO='FECHAINICIOCUENTAUNICA'
                                        AND SYSDATE BETWEEN VIG_INICIAL AND NVL(VIG_FINAL, SYSDATE)
                                        AND ROWNUM =1)
         AND ncierre   = 1   )
  --FIN 2025002642
   AND hino_dv.dinicioperiodo >= to_number('20250101')
   AND hino_dv.dfinalperiodo <= to_number('20250131')
   AND (co_dv.devengado = 'N')
   AND instr('5', tipo_funcionario) > 0
   /*AND USER_SESS = USERENV('SESSIONID')*/
 GROUP BY co_dv.nombre_corto,
          co_dv.devengado,
          hino_dv.nfuncionario,
          hino_dv.ndcampo6,
          hino_dv.ndcampo3,
          RTRIM(LTRIM(hino_dv.sactoadmi))
          ;

--rh_pg_lm_general.fn_conceptos_descuentos(una_compania,'SALUD',una_fecha_final, mi_mensaje_err);	
--CURSOR c_conceptos_dtos IS
      SELECT stipo_funcionario
        FROM rh_lm_det_grp_funcionario
       WHERE scompania = 206 --una_compania
         AND sGrupo    = 'PENSION' --un_grupo
         AND sGtipo    = 'DESCUENTO'
         AND '30/JUN/2025' BETWEEN dfecha_inicio_vig AND dfecha_final_vig
         AND ncierre   = 1;          

SELECT  SHD_PG_BINTABLAS.FN_BUSCAR_RDF(
    'FECHAINICIOCUENTAUNICA',
    'NOMINA',
    'VARIABLES_LIQUIDACION_FECHA',
    SYSDATE) RESULTADO, SYSDATE
FROM DUAL;

SELECT TO_DATE(RESULTADO,'mmddyyyy')
FROM BINTABLAS
WHERE GRUPO='NOMINA'
AND NOMBRE='VARIABLES_LIQUIDACION_FECHA'
AND ARGUMENTO='FECHAINICIOCUENTAUNICA'
AND SYSDATE BETWEEN VIG_INICIAL AND NVL(VIG_FINAL, SYSDATE);

 SELECT Resultado From BinTablas
        WHERE Grupo = 'NOMINA' AND
            Nombre = 'VARIABLES_LIQUIDACION_FECHA' AND
            Argumento = 'FECHAINICIOCUENTAUNICA' AND
            Vig_Inicial <= SYSDATE AND
            (Vig_Final >= SYSDATE OR
            Vig_final IS NULL);