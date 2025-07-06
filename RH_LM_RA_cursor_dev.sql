--MIS DEV
SELECT co_dv.nombre_corto,
       co_dv.devengado,
       hino_dv.nfuncionario,
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
             AND a.dInicioPeriodo <= to_number('20250630')
             AND a.dFinalPeriodo >= to_number('20250601')
             /*AND USER_SESS = USERENV('SESSIONID')*/)) OR
       hino_dv.ntipoconcepto <> 1)
   AND hino_dv.nesnovedad = 0
   AND hino_dv.brechazado = 0
   AND hino_dv.ncorrida_interna = 0
   AND hino_dv.ndCampo0 <> 0
   AND hino_dv.ncorrida = 0
   AND hino_dv.dinicioperiodo >= to_number('20250601')
   AND hino_dv.dfinalperiodo <= to_number('20250630')
   AND (co_dv.devengado = 'S')
   AND instr('5', tipo_funcionario) > 0
   /*AND USER_SESS = USERENV('SESSIONID')*/
 GROUP BY co_dv.nombre_corto,
          co_dv.devengado,
          hino_dv.nfuncionario,
          hino_dv.ndcampo6