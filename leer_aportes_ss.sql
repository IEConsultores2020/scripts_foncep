SELECT co_dv.devengado,
           hino_dv.nfuncionario,
           hino_dv.ndcampo3,
           RTRIM(LTRIM(hino_dv.sactoadmi)),
           hino_dv.ndcampo6,
           SUM((nvl(hino_dv.ndcampo0, 0))) valor
      FROM rh_reportes_nomina hino_dv,
           rh_concepto co_dv,
           rh_funcionario,
           rh_entidad,
           rh_seguridad_social ss
     WHERE hino_dv.nhash = co_dv.codigo_hash
       AND hino_dv.nfuncionario = personas_interno
       AND (hino_dv.nretroactivo =
           (SELECT Nvl(MIN(a.ndCampo0), 0)
               FROM rh_reportes_nomina a
              WHERE a.nFuncionario = hino_dv.nFuncionario
                AND a.nHash = 812839052
                AND to_date(a.dInicioPeriodo, 'YYYYMMDD') <= '31/JAN/26'
                AND to_date(a.dFinalPeriodo, 'YYYYMMDD') >=  '01/JAN/26'
                AND USER_SESS = USERENV('SESSIONID')) OR
           hino_dv.ntipoconcepto in (2, 3))
       AND hino_dv.nesnovedad = 0
       AND hino_dv.brechazado = 0
       AND hino_dv.ncorrida_interna = 0
       AND hino_dv.ndCampo0 <> 0
       AND hino_dv.ncorrida = 0
       AND to_date(hino_dv.dinicioperiodo, 'YYYYMMDD') >= '01/JAN/26' ----una_fecha_inicial
       AND to_date(hino_dv.dfinalperiodo, 'YYYYMMDD') <= '01/JAN/26' ----una_fecha_final
       AND (co_dv.devengado = 'N')
       AND instr('5', tipo_funcionario) > 0
          --ADD
       AND NOMBRE_CORTO = mi_nombre_concepto
       AND USER_SESS = USERENV('SESSIONID')
       AND hino_dv.nfuncionario = ss.funcionario
       AND ss.entidad = rh_entidad.codigo
       AND ss.tipo_entidad = rh_entidad.tipo
       AND ss.tipo_entidad = mi_tipo_entidad
       AND ss.fecha_afiliacion <=
           to_date(hino_dv.dfinalperiodo, 'YYYYMMDD')
       AND (nvl(ss.fecha_retiro, to_date(hino_dv.dfinalperiodo, 'YYYYMMDD')) between
           to_date(hino_dv.dinicioperiodo, 'YYYYMMDD') and
           to_date(hino_dv.dfinalperiodo, 'YYYYMMDD'))
     GROUP BY co_dv.nombre_corto,
              co_dv.devengado,
              hino_dv.nfuncionario,
              hino_dv.ndcampo6,
              hino_dv.ndcampo3,
              RTRIM(LTRIM(hino_dv.sactoadmi));