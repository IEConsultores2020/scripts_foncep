SELECT interno_persona,
       tipo,
       numero_identificacion,
       nombres,
       primer_apellido,
       segundo_apellido,
       round(valor_devengado, -3),
       fecha_ingreso_entidad ingreso,
       formulario_220,
       VIGENCIA ano, /*estado_funcionario,*/
       CONCEPTO
  FROM (SELECT interno_persona,
               'CC' tipo,
               numero_identificacion,
               nombres,
               primer_apellido,
               segundo_apellido,
               sum(hisnomdv.ndcampo0) valor_devengado,
               fecha_ingreso_entidad,
               formulario_220,
               :VIGENCIA VIGENCIA,
               CONDv.nombre CONCEPTO /*estado_funcionario*/
          FROM rh_historico_nomina hisnomdv,
               rh_concepto condv,
               rh_personas,
               rh_funcionario fun
         WHERE interno_persona = fun.PERSONAS_INTERNO
           and hisnomdv.nfuncionario = interno_persona
           and hisnomdv.nhash = condv.codigo_hash
              --AND  condv.devengado = 'S'
           and hisnomdv.DFECHAefectiva >= TO_NUMBER(:VIGENCIA ||'0101')
           and hisnomdv.DFECHAefectiva <= TO_NUMBER(:VIGENCIA ||'1231')
           AND (hisnomdv.ntipoconcepto IN (2, 4, 3) OR
               (hisnomdv.ntipoconcepto = 1 AND
               hisnomdv.nretroactivo =
               (Select Nvl(Min(ndCampo0), 0)
                    From rh_historico_Nomina
                   Where nFuncionario = hisnomdv.nfuncionario
                     and nHash = 812839052
                     And dInicioPeriodo <=
                         substr(hisnomdv.dinicioperiodo, 1, 4) ||
                         substr(hisnomdv.dinicioperiodo, 5, 2) ||
                         substr(hisnomdv.dinicioperiodo, 7, 2)
                     And dFinalPeriodo >=
                         substr(hisnomdv.dfinalperiodo, 1, 4) ||
                         substr(hisnomdv.dfinalperiodo, 5, 2) ||
                         substr(hisnomdv.dfinalperiodo, 7, 2))))
        -- FIN RQ2655-2005    
        and interno_persona=72
         group by interno_persona,
                  numero_identificacion,
                  nombres,
                  primer_apellido,
                  segundo_apellido,
                  CONDv.nombre,
                  fecha_ingreso_entidad,
                  formulario_220 /*,estado_funcionario*/
        UNION
        /*cesantias año anterior*/
        SELECT interno_persona,
               'CC',
               numero_identificacion,
               nombres,
               primer_apellido,
               segundo_apellido,
               hisnomdv.ndcampo0 valor_devengado,
               fecha_ingreso_entidad,
               formulario_220,  --47
               :VIGENCIA VIGENCIA,
               SUBSTR(CONDv.nombre, 6) CONCEPTO /*,estado_funcionario*/
          FROM rh_historico_nomina hisnomdv,
               rh_TIPOS_ACTO_NOVE condv,
               rh_personas,
               rh_funcionario fun,
               rh_seguridad_social ss
         WHERE interno_persona = fun.PERSONAS_INTERNO
           and hisnomdv.nfuncionario = interno_persona
           and hisnomdv.nhash = condv.codigo_hash
              --AND  condv.devengado = 'S'
           and hisnomdv.DFECHAefectiva >= TO_NUMBER(:VIGENCIA ||'0101')
           and hisnomdv.DFECHAefectiva <= TO_NUMBER(:VIGENCIA ||'1231')
           AND condv.codigo_hash = 2474832525 --929473793 ---987789735
           AND hisnomdv.ntipoconcepto = 1
           AND ss.funcionario = hisnomdv.nfuncionario
           AND ss.tipo_entidad = 'FONDO_CESANTIAS'
           AND to_date( :VIGENCIA ||'1231', 'YYYYMMDD') >= ss.fecha_afiliacion
           AND (to_date( :VIGENCIA ||'1231', 'YYYYMMDD') <= ss.fecha_retiro or
               ss.fecha_retiro is null)
           AND ss.entidad <> '01' --modif
        )
 WHERE formulario_220 IS NOT NULL
 --and rownum < 5000000
  -- and interno_persona = 831
  and numero_identificacion = 39658270
 ORDER BY to_number(numero_identificacion), FORMULARIO_220, CONCEPTO;



 select * from rh_concepto
where codigo_hash in (1128917309,1748960496,359055379)